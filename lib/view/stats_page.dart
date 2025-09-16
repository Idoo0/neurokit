import 'package:flutter/material.dart';
import '../utils.dart'; // Impor utils untuk gaya

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Menghilangkan bayangan di bawah AppBar
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Overview',
          // Menggunakan gaya dari utils.dart
          style: desktopH2.copyWith(color: neutral900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
            child: IconButton(
              // 1. Ikon diubah menjadi ikon pengaturan
              icon: const Icon(
                Icons.settings_outlined,
                color: neutral900,
                size: 28,
              ),
              onPressed: () {
                // 2. TODO diubah untuk mencerminkan navigasi ke pengaturan
                // TODO: Implement navigation to settings page
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
            // Baris untuk Streak dan Total Focused Time
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Streak',
                    value: '123',
                    unit: 'Days',
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Total Focused Time',
                    value: '14h 10m',
                    unit: 'this week',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Kartu untuk Badges Level
            _buildStatCard(
              context: context,
              label: 'Badges',
              value: 'MasterrrMind',
              unit: 'Level 2',
              isLarge: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Baris untuk Badges Warm Up dan Points
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Badges Warm Up',
                    value: 'Puanass Poolll',
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Points earned',
                    value: '1240',
                    unit: 'Points',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membangun setiap kartu statistik agar tidak terjadi duplikasi kode
  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    String? unit,
    bool isLarge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: neutral50, // Warna latar belakang kartu
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyText14.copyWith(color: neutral600)),
          const SizedBox(height: 8),
          Text(
            value,
            style: (isLarge ? desktopH2 : mobileH2).copyWith(color: neutral900),
          ),
          if (unit != null) const SizedBox(height: 4),
          if (unit != null)
            Text(unit, style: bodyText14.copyWith(color: neutral600)),
        ],
      ),
    );
  }
}
