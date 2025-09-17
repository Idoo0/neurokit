import 'package:flutter/material.dart';
// Make sure your utils.dart file path is correct
import '../utils.dart'; 

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors from the design for easy reuse
    const Color lightBlue = Color(0xFFD1E5FF);
    const Color brightYellow = Color(0xFFFFD143);
    const Color darkBlue = Color(0xFF001F54);

    // The main content is a SingleChildScrollView to prevent overflow
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // A slightly off-white background
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        title: Text(
          'Overview',
          style: desktopH2.copyWith(color: neutral900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: neutral900,
                size: 28,
              ),
              onPressed: () {
                // TODO: Implement menu drawer opening
              },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Row for Streak and Total Focused Time
            Row(
              children: [
                Expanded(child: _buildStreakCard()),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildTotalTimeCard(lightBlue)),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Level card
            _buildLevelCard(brightYellow),
            const SizedBox(height: AppConstants.defaultPadding),

            // Quotes of The Day card
            _buildQuoteCard(darkBlue),
          ],
        ),
      ),
    );
  }

  // --- Custom Helper Widgets for each card ---

  Widget _buildStreakCard() {
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
      // This is essential: it clips the overflowing image to the rounded border.
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. IMAGE: Positioned precisely in the corner.
          // The negative values push the large image partially outside the frame.
          Positioned(
            right: -40,
            bottom: -50,
            child: Image.asset(
              'assets/images/star.png',
              // Make the image larger than the corner space.
              width: 270,
            ),
          ),

          // 2. TEXT: This remains the same, padded and on top.
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streak', style: TextStyle(color: Colors.white, fontSize: 16)),
                const Spacer(),
                const Text(
                  '123',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text('Days', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeCard(Color color) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Focused Time', style: bodyText14.copyWith(color: neutral600)),
          const Spacer(),
          Text('14h 10m', style: mobileH2.copyWith(color: neutral900)),
          const SizedBox(height: 4),
          Text('this week', style: bodyText14.copyWith(color: neutral600)),
        ],
      ),
    );
  }
  
  Widget _buildLevelCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Level 2', style: bodyText14.copyWith(color: neutral900, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('MasterrrMind', style: mobileH2.copyWith(color: neutral900)),
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
                  child: const LinearProgressIndicator(
                    value: 1240 / 2500, // Progress value
                    backgroundColor: Colors.white54,
                    valueColor: AlwaysStoppedAnimation<Color>(neutral900),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('1240/2500', style: bodyText14.copyWith(color: neutral900, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuoteCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Quotes of The Day',
            style: mobileH2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '"Rasa lelah dan bosan yang kamu lawan saat ini hanyalah sementara, namun pemahaman yang kamu raih akan menjadi fondasi permanen yang membangun kecerdasan dan masa depanmu"',
            style: bodyText14.copyWith(color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
        ],
      ),
    );
  }
}