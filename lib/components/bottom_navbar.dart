import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils.dart';

class BottomNavApp extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavApp({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              context: context,
              svgAsset: 'assets/icons/badges.svg',
              label: 'Badges',
              index: 0,
            ),
            _buildNavItem(
              context: context,
              svgAsset: 'assets/icons/stats.svg',
              label: 'Stats',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String svgAsset,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    // 2. Gunakan warna dari utils.dart
    // brand500 untuk item aktif, neutral400 untuk item non-aktif
    final color = isSelected ? brand500 : neutral400;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgAsset,
                width: 28,
                height: 28,
                // Properti ini penting agar SVG bisa berubah warna
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                // 3. Gunakan TextStyle dari utils.dart
                // Kita gunakan bodyText12 dan menimpanya (override) dengan warna dinamis
                style: bodyText12.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
