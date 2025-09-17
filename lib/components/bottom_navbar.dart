// lib/components/bottom_navbar.dart
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

  /// Jarak tombol tengah “menggantung” dari atas pill
  final double centerLift;

  /// Jarak pill dari tepi bawah layar
  final double pillBottomMargin;

  const BottomNavApp({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    // default PNG (ganti sesuai asetmu)
    this.badges = 'assets/images/badges.png',
    this.badgesActive,
    this.home = 'assets/images/home.png',
    this.homeActive,
    this.stats = 'assets/images/stats.png',
    this.statsActive,
    this.iconSize = 44, // bebas dinaikkan; anti-overflow
    this.sideItemVerticalPadding = 10, // kiri/kanan
    this.centerItemVerticalPadding = 14, // tengah (circle)
    this.centerLift = 14, // makin besar, makin “menggantung”
    this.pillBottomMargin = 22, // jarak pill dari tepi bawah
  });

  @override
  Widget build(BuildContext context) {
    // hitung tinggi teks real (ikut textScaleFactor)
    final double textH = _measureOneLineHeight(context, bodyText12, 'home');

    const double gapIconText = 6;
    const double shadowPad = 24; // ruang ekstra buat shadow

    // tinggi pill menyesuaikan icon + teks + padding
    double pillHeight =
        iconSize + gapIconText + textH + (sideItemVerticalPadding * 2);
    pillHeight = _ceilToEven(pillHeight);
    pillHeight = _clampDouble(pillHeight, 64, 96);

    // diameter tombol tengah (circle) dari total konten + buffer
    double centerContentH =
        iconSize + gapIconText + textH + (centerItemVerticalPadding * 2);
    double centerDiameter = _ceilToEven(centerContentH + 10); // +buffer
    centerDiameter = _clampDouble(centerDiameter, 56, 132);

    // ruang kosong di tengah supaya kiri/kanan gak ketabrak circle
    final double reservedMiddleWidth = centerDiameter + 24;

    // posisi vertikal tombol tengah relatif terhadap pill
    final double centerBottom =
        pillBottomMargin + (pillHeight / 2) + centerLift;

    // tinggi total navbar (agar aman dari overflow)
    final double navTotalHeight =
        centerBottom + (centerDiameter / 2) + shadowPad;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: navTotalHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // ---- pill background (rounded + shadow) ----
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

            // ---- tombol tengah (home) ----
            Positioned(
              bottom: centerBottom,
              child: _buildCenterItem(
                ctx: context, // << penting: kirim context ke helper
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

  /// Item kiri/kanan di dalam pill
  Widget _buildSideItem({
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
            Text(
              label,
              style: bodyText12.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Item tengah (circle + shadow) — ukuran dikunci oleh `diameter`
  Widget _buildCenterItem({
    required BuildContext ctx, // << terima ctx buat MediaQuery
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
              // batasi textScale di tombol tengah agar tidak meledak
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

/// Ukur tinggi satu baris teks (menghormati textScaleFactor)
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
  return tp.height + 2; // buffer kecil buat asc/desc
}

/// Bulatkan ke angka genap biar layout “rapi”
double _ceilToEven(double v) {
  final x = v.ceil();
  return x.isOdd ? (x + 1).toDouble() : x.toDouble();
}

/// Clamp double (karena clamp() mengembalikan num)
double _clampDouble(double v, double min, double max) {
  if (v < min) return min;
  if (v > max) return max;
  return v;
}
