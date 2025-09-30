import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/services/motivation_service.dart';
// Make sure your utils.dart file path is correct
import '../utils.dart';

import '../routes/routes_name.dart';
import '../services/local_storage_service.dart';
import '../utils/gamification_util.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // --- LANGKAH 1: SIAPKAN VARIABEL UNTUK MENAMPUNG DATA ---
  bool _isLoading = true;
  int _streakDays = 0;
  int _totalFocusedSeconds = 0;
  LevelInfo? _levelInfo;
  // int _currentPoints = 0;
  // int _pointsForNextLevel = 10000;
  // int _level = 0;
  // String _levelTitle = '';
  String _quoteOfTheDay = 'Memuat kutipan...';
  late final MotivationService _motivationService;
  

  @override
  void initState() {
    super.initState();
    _motivationService = Get.put(MotivationService());
    _loadStatsData();
  }

  // --- LANGKAH 2: BUAT FUNGSI UNTUK MENGAMBIL DATA ---
  // Di sinilah tempat Anda akan mengambil data dari local storage.
  // Untuk sekarang, kita isi dengan data hardcoded.
  Future<void> _loadStatsData() async {
    // Memastikan setState tidak dipanggil jika widget sudah di-dispose
    if (!mounted) return;

    final storageService = Get.find<LocalStorageService>();
    
    // 3. PANGGIL KEDUA FUNGSI SECARA BERSAMAAN
    // Ini lebih efisien daripada menunggu satu per satu
    final results = await Future.wait([
      storageService.getStats(),
      storageService.getTotalPoints(),
      _motivationService.getQuoteOfTheDay(), // Ambil kutipan
    ]);

    // Ambil hasil dari `Future.wait`
    final stats = results[0] as Map<String, int>;
    final totalPoints = results[1] as int;
    final newQuote = results[2] as String;

    if (mounted) {
      setState(() {
        _streakDays = stats['streakCount'] ?? 0;
        _totalFocusedSeconds = stats['weeklyFocusSec'] ?? 0;
        _levelInfo = calculateLevelInfo(totalPoints);
        _quoteOfTheDay = newQuote; // Update kutipan dari service

        _isLoading = false; // Data selesai dimuat
      });
    }
  }
  
  // Helper untuk memformat menit menjadi "Xh Ym"
  // String _formatMinutes(int minutes) {
  //   if (minutes < 0) return "0m";
  //   int hours = minutes ~/ 60;
  //   int remainingMinutes = minutes % 60;
  //   if (hours > 0) {
  //     return '${hours}h ${remainingMinutes}m';
  //   } else {
  //     return '${remainingMinutes}m';
  //   }
  // }

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) return "0m";
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
}

  @override
  Widget build(BuildContext context) {
    const Color lightBlue = Color(0xFFD1E5FF);
    const Color brightYellow = Color(0xFFFFD143);
    const Color darkBlue = Color(0xFF001F54);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Overview',
          style: desktopH2.copyWith(color: neutral900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
            child: IconButton(
              icon: const Icon(Icons.menu, color: neutral900, size: 28),
              onPressed: () => Get.toNamed(RoutesName.settings),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: AppConstants.defaultBorderRadius,
                  side: const BorderSide(color: neutral200, width: 1.5),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
      // --- LANGKAH 3: TAMPILKAN LOADING ATAU KONTEN ---
      body: _isLoading || _levelInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Kirim data ke widget kartu
                      Expanded(child: _buildStreakCard(_streakDays)),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(child: _buildTotalTimeCard(lightBlue, _totalFocusedSeconds)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildLevelCard(brightYellow, _levelInfo!),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildQuoteCard(darkBlue, _quoteOfTheDay),
                ],
              ),
            ),
    );
  }

  // --- LANGKAH 4: UBAH WIDGET KARTU UNTUK MENERIMA DATA ---

  Widget _buildStreakCard(int streakDays) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA500), Color(0xFFFFD143)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset('assets/images/star.png', width: 175, height: 175, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streak', style: TextStyle(color: Colors.white, fontSize: 16)),
                const Spacer(),
                Text(
                  streakDays.toString(), // Gunakan data dari variabel
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text('Days', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeCard(Color color, int totalSeconds) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(color: color, borderRadius: AppConstants.defaultBorderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Focused Time', style: bodyText14.copyWith(color: neutral600)),
          const Spacer(),
          Text(
            _formatSeconds(totalSeconds), // Gunakan data yang diformat
            style: mobileH2.copyWith(color: neutral900),
          ),
          const SizedBox(height: 4),
          Text('this week', style: bodyText14.copyWith(color: neutral600)),
        ],
      ),
    );
  }

  Widget _buildLevelCard(Color color, LevelInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(color: color, borderRadius: AppConstants.defaultBorderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Level ${info.level}', style: bodyText14.copyWith(color: neutral900, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(info.title, style: mobileH2.copyWith(color: neutral900)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Points earned', style: bodyText14.copyWith(color: neutral600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: info.progress, // Use the calculated progress
                    backgroundColor: Colors.white54,
                    valueColor: const AlwaysStoppedAnimation<Color>(neutral900),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${info.currentPoints}/${info.pointsForNextLevel}', style: bodyText14.copyWith(color: neutral900, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuoteCard(Color color, String quote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(color: color, borderRadius: AppConstants.defaultBorderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Quotes of The Day', style: mobileH2.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            quote, // Gunakan data dari variabel
            textAlign: TextAlign.center, // Pusatkan teks kutipan
            style: bodyText14.copyWith(color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
        ],
      ),
    );
  }
}