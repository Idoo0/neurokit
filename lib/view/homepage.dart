import 'package:flutter/material.dart';
import '../components/bottom_navbar.dart';
import '../components/mode_picker_sheet.dart'; // <- showModePicker & SessionMode
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

  // ====== stub callback: isi logic bluetooth nanti ======
  Future<void> _requestConnectDevice() async {
    AppUtils.showSnackBar(context, "Hubungkan perangkat (stub)");
  }

  Future<void> _requestDisconnectDevice() async {
    AppUtils.showSnackBar(context, "Putuskan perangkat (stub)");
  }

  void _onStartSession(SessionMode mode) {
    AppUtils.showSnackBar(context, "Mulai sesi: ${mode.name}");
  }

  void _onItemTapped(int i) => setState(() => _selectedIndex = i);

  late final List<Widget> _pages = <Widget>[
    BadgesPage(onBackPressed: () => _onItemTapped(1)),
    HomeTab(
      starAsset: 'assets/images/star-sleep.png', // <-- pakai PNG kamu di sini
      onConnectRequested: _requestConnectDevice,
      onDisconnectRequested: _requestDisconnectDevice,
      onStartSession: _onStartSession,
    ),
    const StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // bg putih
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
///                       HOME TAB (satu file)
/// --------------------------------------------------------------
class HomeTab extends StatefulWidget {
  final String starAsset;
  final Future<void> Function() onConnectRequested;
  final Future<void> Function() onDisconnectRequested;
  final void Function(SessionMode mode) onStartSession;

  const HomeTab({
    super.key,
    required this.starAsset,
    required this.onConnectRequested,
    required this.onDisconnectRequested,
    required this.onStartSession,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _connected = false;

  Future<void> _openModePicker() async {
    final mode = await showModePicker(context);
    if (mode != null) {
      widget.onStartSession(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // ekstra jarak atas + menghormati notch/status bar
    final double topPad = media.padding.top + 56; // <- atur sesuka (24–56)
    // reserve/ruang untuk pill navbar + gesture bar
    final double bottomPad = media.padding.bottom + 180; // <- 140–180 enak

    return Container(
      color: Colors.white, // jaga supaya putih
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          topPad,
          24,
          bottomPad,
        ), // ruang utk navbar
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                "Bintangnya redup",
                textAlign: TextAlign.center,
                style: mobileH2,
              ),
              const SizedBox(height: 4),
              Text(
                "Ayo Nyalain, Josha !",
                textAlign: TextAlign.center,
                style: mobileH1,
              ),
              const SizedBox(height: 120),

              // ---- STAR PNG BUTTON (pakai aset-mu, tetap tappable) ----
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _openModePicker,
                  child: SizedBox(
                    height: 180, // bebas kamu adjust
                    child: Image.asset(
                      widget.starAsset,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.star, size: 180, color: brand500),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 58),

              // ---- CONNECT INDICATOR (toggle; nanti ganti dgn logic BT) ----
              _ConnectPill(
                connected: _connected,
                onTap: () async {
                  if (_connected) {
                    await widget.onDisconnectRequested();
                  } else {
                    await widget.onConnectRequested();
                  }
                  setState(() => _connected = !_connected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------
///                  CONNECT PILL (dua kondisi)
/// --------------------------------------------------------------
class _ConnectPill extends StatelessWidget {
  final bool connected;
  final VoidCallback onTap;

  const _ConnectPill({required this.connected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = connected ? green50 : Colors.white;
    final border = connected ? green400 : Colors.red;
    final textColor = connected ? green600 : Colors.red;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              connected ? "terhubung" : "hubungkan perangkat",
              style: bodyText14.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
