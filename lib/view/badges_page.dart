import 'package:flutter/material.dart';
import '../utils.dart';

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

class BadgesPage extends StatelessWidget {
  // Callback untuk menangani tombol kembali
  final VoidCallback onBackPressed;

  const BadgesPage({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    // Warna kustom sesuai permintaan Anda
    const Color badgeBlue = Color(0xFF1A5CBA);
    const Color badgeYellow = Color(0xFFFFD702);

    final List<BadgeInfo> badges = [
      BadgeInfo(
        level: 'Level 1',
        title: 'Spark Seeker',
        isUnlocked: true,
        color: badgeBlue,
      ),
      BadgeInfo(
        level: 'Level 2',
        title: 'Memory Scout',
        isUnlocked: true,
        color: badgeYellow,
      ),
      BadgeInfo(
        level: 'Level 3',
        title: 'Clarity Chaser',
        isUnlocked: false,
        color: Colors.grey,
      ),
      BadgeInfo(
        level: 'Level 4',
        title: 'Mind Pathfinder',
        isUnlocked: false,
        color: Colors.grey,
      ),
      BadgeInfo(
        level: 'Level 5',
        title: 'Light Jumper',
        isUnlocked: false,
        color: Colors.grey,
      ),
      BadgeInfo(
        level: 'Level 6',
        title: 'Aurora Architect',
        isUnlocked: false,
        color: Colors.grey,
      ),
      BadgeInfo(
        level: 'Level 7',
        title: 'Cognitive Climb',
        isUnlocked: false,
        color: Colors.grey,
      ),
      BadgeInfo(
        level: 'Level 8',
        title: 'Mind Guardian',
        isUnlocked: false,
        color: Colors.grey,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
              onPressed: onBackPressed,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: GridView.builder(
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
    final Color badgeColor = badge.isUnlocked ? badge.color : neutral200;
    final Color textColor = badge.isUnlocked ? Colors.white : neutral400;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- PERBAIKAN DI SINI ---
        // Menambahkan Flexible untuk mencegah overflow di dalam Column
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

// Kalkulasi Heksagon yang Proporsional
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
