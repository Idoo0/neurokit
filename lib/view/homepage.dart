import 'package:flutter/material.dart';
import 'badges_page.dart';
import 'stats_page.dart';
import 'study_session_page.dart';
import '../components/bottom_navbar.dart';
import '../utils.dart';

class HomepagePage extends StatefulWidget {
  const HomepagePage({super.key});

  @override
  State<HomepagePage> createState() => _HomepagePageState();
}

class _HomepagePageState extends State<HomepagePage> {
  final GlobalKey<StudySessionPageState> _studySessionKey =
      GlobalKey<StudySessionPageState>();
  // Default ke halaman Stats/Overview
  int _selectedIndex = 2;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      // --- PERBAIKAN DI SINI ---
      // Kita berikan fungsi _onItemTapped(2) untuk parameter onBackPressed.
      // Ini akan mengganti halaman ke StatsPage (indeks 2) saat tombol kembali ditekan.
      BadgesPage(onBackPressed: () => _onItemTapped(2)),
      StudySessionPage(key: _studySessionKey),
      const StatsPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (_studySessionKey.currentState?.mounted == true &&
        _studySessionKey.currentState?.timerState == TimerState.running) {
      AppUtils.showSnackBar(context, 'Selesaikan sesi fokus terlebih dahulu!');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFocusButtonTapped() {
    setState(() {
      _selectedIndex = 1; // Pindah ke tab fokus
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _studySessionKey.currentState?.startFocusSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan IndexedStack agar state halaman tidak hilang saat berpindah tab
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFocusButtonTapped,
        shape: const CircleBorder(),
        backgroundColor: yellow600,
        child: const Icon(Icons.lightbulb_outline, color: neutral900, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavApp(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
