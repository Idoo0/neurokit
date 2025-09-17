// lib/components/bottom_navbar.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils.dart';

class BottomNavApp extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  // PNG assets (non-aktif & aktif opsional)
  final String badges;
  final String? badgesActive;

  final String home;
  final String? homeActive;

  final String stats;
  final String? statsActive;

  /// Besar ikon (semua item)
  final double iconSize;

  /// Padding vertikal item kiri/kanan di dalam pill
  final double sideItemVerticalPadding;

  /// Padding vertikal konten tombol tengah (di dalam circle)
  final double centerItemVerticalPadding;

  /// Jarak tombol tengah “menggantung” dari atas pill (dasar)
  final double centerLift;

  /// Jarak pill dari tepi bawah layar
  final double pillBottomMargin;

  /// Fine-tune khusus lingkaran (positif = TURUN, negatif = NAIK)
  final double centerOffset;

  const BottomNavApp({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.badges = 'assets/images/badges.png',
    this.badgesActive,
    this.home = 'assets/images/home.png',
    this.homeActive,
    this.stats = 'assets/images/stats.png',
    this.statsActive,
    this.iconSize = 44,
    this.sideItemVerticalPadding = 10,
    this.centerItemVerticalPadding = 14,
    this.centerLift = 2,
    this.pillBottomMargin = 22,
    this.centerOffset = 0, // << baru
  });

  @override
  Widget build(BuildContext context) {
    // Ukur tinggi teks aktual (hormat ke textScaleFactor)
    final double textH = _measureOneLineHeight(context, bodyText12, 'home');

    const double gapIconText = 6;
    const double shadowPad = 24;

    // ---- Tinggi pill: konten + padding + buffer ----
    final double innerNeeded = iconSize + gapIconText + textH;
    double pillHeight =
        innerNeeded + (sideItemVerticalPadding * 2) + 4; // +buffer
    pillHeight = _ceilToEven(pillHeight).clamp(64, 100);

    // ---- Diameter circle tengah: konten + padding + buffer ----
    double centerContentH =
        iconSize + gapIconText + textH + (centerItemVerticalPadding * 2);
    double centerDiameter = _ceilToEven(centerContentH + 10).clamp(56, 132);

    // ---- Posisi “dasar” circle relatif ke bottom ----
    final double centerBottomBase =
        pillBottomMargin + (pillHeight / 2) + centerLift;

    // Terapkan offset khusus circle (positif = turun)
    final double centerBottom = math.max(0, centerBottomBase - centerOffset);

    // ---- Lebar ruang kosong di tengah agar sisi tidak ketabrak circle ----
    final double reservedMiddleWidth = centerDiameter + 24;

    // ---- Tinggi total navbar: maksimal antara tinggi pill & tinggi circle ----
    final double pillTopExtent = pillBottomMargin + pillHeight;
    final double circleTopExtent = centerBottom + (centerDiameter / 2);
    final double navTotalHeight =
        math.max(pillTopExtent, circleTopExtent) + shadowPad;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: navTotalHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none, // << jangan clip kalau ada rounding 1–2px
          children: [
            // ---- Pill background ----
            Positioned(
              left: 16,
              right: 16,
              bottom: pillBottomMargin,
              child: Container(
                height: pillHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSideItem(
                        ctx: context,
                        asset: badges,
                        activeAsset: badgesActive,
                        label: 'badges',
                        index: 0,
                        iconSize: iconSize,
                        vPad: sideItemVerticalPadding,
                        gap: gapIconText,
                      ),
                    ),
                    SizedBox(width: reservedMiddleWidth),
                    Expanded(
                      child: _buildSideItem(
                        ctx: context,
                        asset: stats,
                        activeAsset: statsActive,
                        label: 'stats',
                        index: 2,
                        iconSize: iconSize,
                        vPad: sideItemVerticalPadding,
                        gap: gapIconText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Tombol tengah (home) ----
            Positioned(
              bottom: centerBottom,
              child: _buildCenterItem(
                ctx: context,
                asset: home,
                activeAsset: homeActive,
                label: 'home',
                index: 1,
                diameter: centerDiameter,
                iconSize: iconSize,
                vPad: centerItemVerticalPadding,
                gap: gapIconText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Item kiri/kanan dalam pill
  Widget _buildSideItem({
    required BuildContext ctx,
    required String asset,
    String? activeAsset,
    required String label,
    required int index,
    required double iconSize,
    required double vPad,
    required double gap,
  }) {
    final isSelected = selectedIndex == index;
    final chosen = isSelected ? (activeAsset ?? asset) : asset;
    final color = isSelected ? brand500 : neutral400;

    return InkWell(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              chosen,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(height: gap),
            // kunci scale biar gak nambah 1px & bikin overflow
            MediaQuery(
              data: MediaQuery.of(ctx).copyWith(textScaleFactor: 1.0),
              child: Text(
                label,
                style: bodyText12.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Item tengah (circle + shadow)
  Widget _buildCenterItem({
    required BuildContext ctx,
    required String asset,
    String? activeAsset,
    required String label,
    required int index,
    required double diameter,
    required double iconSize,
    required double vPad,
    required double gap,
  }) {
    final isSelected = selectedIndex == index;
    final chosen = isSelected ? (activeAsset ?? asset) : asset;
    final color = isSelected ? brand500 : neutral400;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                chosen,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              SizedBox(height: gap),
              MediaQuery(
                data: MediaQuery.of(ctx).copyWith(textScaleFactor: 1.0),
                child: Text(
                  label,
                  style: bodyText12.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Helpers ---

double _measureOneLineHeight(
  BuildContext context,
  TextStyle style,
  String sample,
) {
  final tp = TextPainter(
    text: TextSpan(text: sample, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaleFactor: MediaQuery.of(context).textScaleFactor,
  )..layout();
  return tp.height + 2; // buffer
}

double _ceilToEven(double v) {
  final x = v.ceil();
  return x.isOdd ? (x + 1).toDouble() : x.toDouble();
}
