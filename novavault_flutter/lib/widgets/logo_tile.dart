import 'package:flutter/material.dart';

class NovaLogo extends StatelessWidget {
  final bool isDesktop;
  final bool showWordmark;

  const NovaLogo({
    super.key,
    this.isDesktop = true,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final double h = isDesktop ? 38.0 : 32.0;

    if (showWordmark) {
      // Full horizontal banner logo
      return SizedBox(
        height: h,
        child: Image.asset(
          'assets/logo_banner.png',
          height: h,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to square logo if banner fails
            return Image.asset(
              'assets/logo.png',
              height: h,
              fit: BoxFit.contain,
            );
          },
        ),
      );
    } else {
      // Icon only
      return SizedBox(
        width: h,
        height: h,
        child: Image.asset(
          'assets/logo.png',
          width: h,
          height: h,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    }
  }
}
