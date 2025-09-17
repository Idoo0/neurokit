import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color; // untuk tint (aktif/non-aktif)

  const AppIcon({super.key, required this.asset, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final isSvg = asset.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }
    // PNG/JPG
    return Image.asset(
      asset,
      width: size,
      height: size,
      // kalau mau tint juga bisa; hapus kalau tidak perlu tint PNG
      color: color,
    );
  }
}
