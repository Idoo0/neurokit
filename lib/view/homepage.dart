import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/bottom_navbar.dart';
import '../components/mode_picker_sheet.dart' show showModePicker;
import '../widgets/api_debug_widget.dart';

import '../controllers/bluetooth_controller.dart';
import '../controllers/session_controller.dart';

import '../routes/routes_name.dart';
import '../services/local_storage_service.dart';
import '../utils.dart';
import '../utils/constants.dart' show SessionDefaults;

// Ganti import ini dengan file real kamu
import 'badges_page.dart';
import 'stats_page.dart';

class HomepagePage extends StatefulWidget {
  const HomepagePage({super.key});

  @override
  State<HomepagePage> createState() => _HomepagePageState();
}

class _HomepagePageState extends State<HomepagePage> {
  int _selectedIndex = 1;

  // Key untuk akses HomeTab state
  final GlobalKey<_HomeTabState> _homeTabKey = GlobalKey<_HomeTabState>();

  // Ambil controller dari GetX (pastikan sudah di-Get.put di bootstrap)
  final BluetoothController bt = Get.find<BluetoothController>();
  final SessionController session = Get.find<SessionController>();

  void _onItemTapped(int i) {
    setState(() => _selectedIndex = i);

    // Refresh nama ketika kembali ke tab Home
    if (i == 1) {
      // Post frame callback untuk memastikan widget sudah di-mount
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeTabKey.currentState?.refreshName();
      });
    }
  }

  late final List<Widget> _pages = <Widget>[
    BadgesPage(onBackPressed: () => _onItemTapped(1)),
    HomeTab(
      key: _homeTabKey, // Tambahkan key
      starAsset: 'assets/images/star-sleep.png',
      bt: bt,
      session: session,
    ),
    const StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavApp(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

/// --------------------------------------------------------------
///                       HOME TAB
/// --------------------------------------------------------------
class HomeTab extends StatefulWidget {
  final String starAsset;
  final BluetoothController bt;
  final SessionController session;

  const HomeTab({
    super.key,
    required this.starAsset,
    required this.bt,
    required this.session,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  // Key yang unik untuk memaksa rebuild FutureBuilder (nama & bintang)
  Key _nameWidgetKey = UniqueKey();
  Key _starWidgetKey = UniqueKey();
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force rebuild nama & bintang saat balik ke foreground
      setState(() {
        _nameWidgetKey = UniqueKey();
        _starWidgetKey = UniqueKey();
      });
    }
  }

  // Helper local untuk bandingkan YMD
  int _toYmd(DateTime dt) => dt.year * 10000 + dt.month * 100 + dt.day;

  // Cek apakah ada sesi belajar (duration > 0) untuk "hari ini"
  Future<bool> _hasStudyToday() async {
    final store = Get.find<LocalStorageService>();
    final history = await store
        .getSessionHistory(); // List<Map<String,dynamic>>
    if (history.isEmpty) return false;

    final todayYmd = _toYmd(DateTime.now());
    for (final item in history) {
      final endedAtStr = item['endedAt'] as String?;
      final dur = (item['durationSec'] ?? 0) as int;
      if (endedAtStr == null || dur <= 0) continue;

      final dt = DateTime.tryParse(endedAtStr);
      if (dt == null) continue;

      if (_toYmd(dt) == todayYmd) return true;
    }
    return false;
  }

  // Method untuk refresh nama dari luar jika diperlukan
  void refreshName() {
    if (!mounted) return;
    setState(() {
      _nameWidgetKey = UniqueKey();
      _starWidgetKey = UniqueKey(); // sekalian refresh ikon bintang
    });
  }

  Future<void> _openModePicker() async {
    final picked = await showModePicker(context);
    if (picked == null) return;

    // Persist pilihan user (punyamu sudah benar)
    final store = Get.find<LocalStorageService>();
    await store.setSelectedModeString(picked.name);

    // Pastikan sudah terhubung ke ESP32
    if (!widget.bt.isConnected.value) {
      try {
        await widget.bt.scanAndConnect();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungkan device: $e')),
        );
        return;
      }
    }

    // Map mode UI -> string command
    final modeStr = picked.name.toUpperCase().contains('LEARN')
        ? 'LEARN'
        : 'CHILL';

    // Compose command PREPARE <MODE> <dur> <vol> <tChill> <tLearn> <tMotiv>
    final dur = SessionDefaults.durationSec;
    final vol = SessionDefaults.volumePct;
    final tChill = SessionDefaults.trackChill;
    final tLearn = SessionDefaults.trackLearn;
    final tMotiv = SessionDefaults.motivationTrack;

    // Kirim ke ESP32 (baris diakhiri \n oleh service)
    await widget.bt.sendLine('$modeStr');

    // (opsional) minta status sekali untuk memastikan sisi ESP32 siap
    await widget.bt.sendLine('STATUS?');

    if (!mounted) return;

    // (opsional) tetap panggil selectMode milik controller-mu, kalau ada
    try {
      (widget.session as dynamic).selectMode(picked);
    } catch (_) {}

    // Lanjut ke Motivation
    Get.toNamed(RoutesName.motivation, arguments: {'isStarting': true});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 160),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),

              // === Heading & Nama jadi dinamis berdasar study duration hari ini ===
              FutureBuilder<bool>(
                key: _starWidgetKey, // direfresh bareng ikon bintang
                future: _hasStudyToday(),
                builder: (context, snapHas) {
                  final hasToday = snapHas.data ?? false;
                  final title = hasToday
                      ? 'Bintangnya menyala'
                      : 'Bintangnya redup';
                  final prefix = hasToday ? 'Ayo Fokus Lagi!' : 'Ayo Nyalain';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: mobileH2,
                        ),
                      ),

                      // ---- Nama (tetap ambil storage, tapi kalimatnya ikut prefix) ----
                      FutureBuilder<Map<String, String>>(
                        key: _nameWidgetKey,
                        future: Get.find<LocalStorageService>().getUserData(),
                        builder: (context, snapshot) {
                          final raw = (snapshot.data?['name'] ?? '').trim();
                          final firstName = raw.isEmpty
                              ? ''
                              : raw.split(' ').first;
                          final suffix = firstName.isEmpty
                              ? ''
                              : ', $firstName';
                          return Text(
                            '$prefix$suffix!',
                            textAlign: TextAlign.center,
                            style: mobileH1,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 4),

              // ---- Star button (dinamis berdasar sesi hari ini) ----
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _openModePicker,
                child: SizedBox(
                  height: 400,
                  child: FutureBuilder<bool>(
                    key: _starWidgetKey,
                    future: _hasStudyToday(),
                    builder: (context, snap) {
                      // default (sementara loading / error) pakai yang lama
                      final hasToday = snap.data ?? false;
                      final assetPath = hasToday
                          ? 'assets/images/star-wink.png'
                          : 'assets/images/star-sleep.png';

                      return Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Connect pill (reactive) ----------
              Obx(() {
                final connected = widget.bt.isConnected.value;

                // 🔹 “busy” = discover + connecting lokal
                final busy = widget.bt.isDiscovering.value || _connecting;

                final bg = connected ? green50 : Colors.white;
                final border = connected
                    ? green400
                    : (busy ? Colors.orange : Colors.red);
                final textColor = connected
                    ? green600
                    : (busy ? Colors.orange : Colors.red);

                // 🔹 Ubah label dinamis
                final label = connected
                    ? 'terhubung'
                    : (busy ? 'menghubungkan...' : 'hubungkan perangkat');

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    if (busy) return;

                    // putuskan jika sudah terhubung
                    if (connected) {
                      setState(() => _connecting = true);
                      try {
                        await widget.bt.disconnect();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Terputus dari perangkat'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memutus: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _connecting = false);
                      }
                      return;
                    }

                    // 🔹 langsung pairing+connect via MAC (tanpa buka Settings)
                    setState(() => _connecting = true);
                    try {
                      await widget.bt.scanAndConnect();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terhubung ke NEUROKIT'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghubungkan: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _connecting = false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        busy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: textColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: bodyText14.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
