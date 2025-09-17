import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/bottom_navbar.dart';
import '../components/mode_picker_sheet.dart' show showModePicker;

import '../controllers/bluetooth_controller.dart';
import '../controllers/session_controller.dart';

import '../models/mode.dart';
import '../models/session_state.dart'; // <-- pakai enum SessionPhase
import '../utils.dart';

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

  // Ambil controller dari GetX (pastikan sudah di-Get.put di bootstrap)
  final BluetoothController bt = Get.find<BluetoothController>();
  final SessionController session = Get.find<SessionController>();

  void _onItemTapped(int i) => setState(() => _selectedIndex = i);

  late final List<Widget> _pages = <Widget>[
    BadgesPage(onBackPressed: () => _onItemTapped(1)),
    HomeTab(
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
      widget.bt.onAppResumed();
    }
  }

  Future<void> _openModePicker() async {
    final mode = await showModePicker(context);
    if (mode == null) return;
    await widget.session.selectMode(mode);
    AppUtils.showSnackBar(
      context,
      'Mode ${mode.name} tersimpan. Mulai sesi di halaman fokus.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 160), // ruang utk navbar
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Heading ----------
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                child: Text(
                  'Bintangnya redup',
                  textAlign: TextAlign.center,
                  style: mobileH2,
                ),
              ),
              Text(
                'Ayo Nyalain, Josha !',
                textAlign: TextAlign.center,
                style: mobileH1,
              ),

              const SizedBox(height: 24),

              // ---------- Star button (pakai PNG kamu) ----------
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _openModePicker,
                child: SizedBox(
                  height: 200,
                  child: Image.asset(
                    widget.starAsset,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Connect pill (reactive) ----------
              Obx(() {
                final connected = widget.bt.isConnected.value;
                final busy = widget.bt.isScanning.value;

                final bg = connected ? green50 : Colors.white;
                final border = connected ? green400 : Colors.red;
                final textColor = connected ? green600 : Colors.red;
                final label = connected ? 'terhubung' : 'hubungkan perangkat';

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    if (busy) return;
                    if (connected) {
                      await widget.bt.disconnect();
                    } else {
                      await widget.bt.openSystemBluetoothSettings();
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
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textColor,
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

              // ---------- Mode siap (kecil & rapi) ----------
              const SizedBox(height: 12),
              Obx(() {
                final isPrepared =
                    widget.session.phase.value == SessionPhase.prepared;
                final selectedMode = widget.session.info?.mode;
                if (!isPrepared || selectedMode == null) {
                  return const SizedBox.shrink();
                }
                return Text(
                  'Mode siap: ${selectedMode.name}',
                  style: bodyText12.copyWith(color: neutral600),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
