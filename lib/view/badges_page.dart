// badges_page.dart

import 'package:flutter/material.dart';
import '../utils.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';

// Kelas data untuk informasi lencana
class BadgeInfo {
  final String level;
  final String title;
  final bool isUnlocked;
  final Color color;

  BadgeInfo({
    required this.level,
    required this.title,
    required this.isUnlocked,
    required this.color,
  });
}

class BadgesPage extends StatefulWidget { // <-- Diubah menjadi StatefulWidget
  final VoidCallback onBackPressed;
  const BadgesPage({super.key, required this.onBackPressed});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final storageService = Get.find<LocalStorageService>();
    final stats = await storageService.getStats();
    if (mounted) {
      setState(() {
        _currentStreak = stats['streakCount'] ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Definisi warna dan allBadgesData tidak berubah)
    const Color badgeBlue = Color(0xFF1A5CBA);
    const Color badgeYellow = Color(0xFFFFD702);

    final List<Map<String, dynamic>> allBadgesData = [
      {'level': 'Level 1', 'title': 'Spark Seeker', 'requiredStreak': 1, 'color': badgeBlue},
      {'level': 'Level 2', 'title': 'Memory Scout', 'requiredStreak': 7, 'color': badgeYellow},
      {'level': 'Level 3', 'title': 'Clarity Chaser', 'requiredStreak': 14, 'color': badgeBlue},
      {'level': 'Level 4', 'title': 'Mind Pathfinder', 'requiredStreak': 30, 'color': badgeYellow},
      {'level': 'Level 5', 'title': 'Light Jumper', 'requiredStreak': 60, 'color': badgeBlue},
      {'level': 'Level 6', 'title': 'Aurora Architect', 'requiredStreak': 90, 'color': badgeYellow},
      {'level': 'Level 7', 'title': 'Cognitive Climb', 'requiredStreak': 180, 'color': badgeBlue},
      {'level': 'Level 8', 'title': 'Mind Guardian', 'requiredStreak': 365, 'color': badgeYellow},
    ];

    // Logika ini sekarang menggunakan _currentStreak dari state
    final List<BadgeInfo> badges = allBadgesData.map((badgeData) {
      final bool isUnlocked = _currentStreak >= badgeData['requiredStreak'];
      return BadgeInfo(
        level: badgeData['level'],
        title: badgeData['title'],
        isUnlocked: isUnlocked,
        color: isUnlocked ? badgeData['color'] : Colors.grey,
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (UI AppBar tidak berubah)
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Achievement', style: desktopH3),
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.defaultPadding),
          child: CircleAvatar(
            backgroundColor: brand800,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBackPressed,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: GridView.builder(
                // ... (UI GridView tidak berubah)
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    return _buildBadgeItem(badges[index]);
                  },
              ),
            ),
    );
  }

  Widget _buildBadgeItem(BadgeInfo badge) {
    // ... (UI _buildBadgeItem tidak berubah)
    final Color badgeColor = badge.isUnlocked ? badge.color : neutral200;
    final Color textColor = badge.isUnlocked ? Colors.white : neutral400;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: 0.9,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: HexagonClipper(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.white), // Border
                    Container(
                      margin: const EdgeInsets.all(5), // Tebal border
                      color: badgeColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                badge.level,
                                style: mobileH4.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                badge.title,
                                style: bodyText14.copyWith(color: textColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ... (HexagonClipper tidak berubah)
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0); // Titik atas
    path.lineTo(size.width, size.height * 0.25); // Kanan atas
    path.lineTo(size.width, size.height * 0.75); // Kanan bawah
    path.lineTo(size.width * 0.5, size.height); // Titik bawah
    path.lineTo(0, size.height * 0.75); // Kiri bawah
    path.lineTo(0, size.height * 0.25); // Kiri atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}