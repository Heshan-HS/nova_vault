import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';

enum BrandType {
  google,
  binance,
  server,
  card,
  note,
  github,
  spotify,
  netflix,
  discord,
  generic,
}

class ItemAvatar extends StatelessWidget {
  final String name;
  final String? category;
  final String? username;
  final String? url;
  final double size;
  final double radius;
  final bool isDark;
  final bool isHero;

  const ItemAvatar({
    super.key,
    required this.name,
    this.category,
    this.username,
    this.url,
    this.size = 44.0,
    this.radius = 12.0,
    this.isDark = false,
    this.isHero = false,
  });

  static BrandType detectBrand({
    required String name,
    String? category,
    String? username,
    String? url,
  }) {
    if (category == 'server') return BrandType.server;
    if (category == 'card') return BrandType.card;
    if (category == 'note') return BrandType.note;

    final lowerName = name.toLowerCase();
    final lowerUser = (username ?? '').toLowerCase();
    final lowerUrl = (url ?? '').toLowerCase();
    final all = '$lowerName $lowerUser $lowerUrl';

    if (all.contains('vps') || all.contains('node') || all.contains('server') || all.contains('ssh')) {
      return BrandType.server;
    }

    if (all.contains('gmail') ||
        all.contains('google') ||
        all.contains('youtube') ||
        all.contains('gdrive') ||
        all.contains('android') ||
        all.contains('myaccount.google')) {
      return BrandType.google;
    }

    if (all.contains('binance')) {
      return BrandType.binance;
    }

    if (all.contains('github')) {
      return BrandType.github;
    }

    if (all.contains('spotify')) {
      return BrandType.spotify;
    }

    if (all.contains('netflix')) {
      return BrandType.netflix;
    }

    if (all.contains('discord')) {
      return BrandType.discord;
    }

    return BrandType.generic;
  }

  Widget _buildSquircle({
    required Widget child,
    Color? customBg,
    Color? customBorder,
  }) {
    // In light mode, ALL avatars share the clean white squircle background
    final bg = customBg ?? (isDark ? const Color(0xFF0D2352) : Colors.white);
    final border = customBorder ?? (isDark ? const Color(0x336FA8FF) : const Color(0x1F000000));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = detectBrand(
      name: name,
      category: category,
      username: username,
      url: url,
    );

    switch (brand) {
      case BrandType.google:
        return _buildSquircle(
          child: CustomPaint(
            size: Size(size * 0.54, size * 0.54),
            painter: GoogleGLogoPainter(),
          ),
        );

      case BrandType.binance:
        return _buildSquircle(
          child: CustomPaint(
            size: Size(size * 0.52, size * 0.52),
            painter: BinanceLogoPainter(),
          ),
        );

      case BrandType.server:
        return _buildSquircle(
          child: Icon(
            Icons.dns_rounded,
            size: size * 0.52,
            color: isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700,
          ),
        );

      case BrandType.card:
        return _buildSquircle(
          child: Icon(
            Icons.credit_card_rounded,
            size: size * 0.52,
            color: isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700,
          ),
        );

      case BrandType.note:
        return _buildSquircle(
          child: Icon(
            Icons.lock_outline_rounded,
            size: size * 0.52,
            color: isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700,
          ),
        );

      case BrandType.github:
        return _buildSquircle(
          child: Icon(
            Icons.code_rounded,
            size: size * 0.52,
            color: isDark ? Colors.white : const Color(0xFF24292F),
          ),
        );

      case BrandType.spotify:
        return _buildSquircle(
          child: Icon(
            Icons.graphic_eq_rounded,
            size: size * 0.55,
            color: const Color(0xFF1DB954),
          ),
        );

      case BrandType.netflix:
        return _buildSquircle(
          child: Text(
            'N',
            style: GoogleFonts.bebasNeue(
              fontSize: size * 0.65,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE50914),
            ),
          ),
        );

      case BrandType.discord:
        return _buildSquircle(
          child: Icon(
            Icons.gamepad_rounded,
            size: size * 0.52,
            color: const Color(0xFF5865F2),
          ),
        );

      case BrandType.generic:
        final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
        return _buildSquircle(
          child: Text(
            letter,
            style: GoogleFonts.inter(
              color: isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.42,
              height: 1.0,
            ),
          ),
        );
    }
  }
}

/// Official Google 4-Color 'G' Logo Vector Painter
class GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    canvas.save();
    canvas.scale(s / 48.0, s / 48.0);

    // 1. Red (Top curve)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final redPath = Path()
      ..moveTo(24.0, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24.0, 9.5)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // 2. Blue (Right side and crossbar)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2)
      ..lineTo(39.89, 42.2)
      ..cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 3. Yellow (Left curve)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0)
      ..cubicTo(9.77, 22.4, 10.04, 20.86, 10.53, 19.41)
      ..lineTo(2.55, 13.22)
      ..cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0)
      ..cubicTo(0.0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Green (Bottom curve)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.5, 24.0, 38.5)
      ..cubicTo(17.74, 38.5, 12.43, 34.28, 10.53, 28.59)
      ..lineTo(2.56, 34.78)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Binance Diamond Vector Painter
class BinanceLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    canvas.save();
    canvas.scale(s / 48.0, s / 48.0);

    // Brand Binance Gold #F0B90B
    final goldPaint = Paint()
      ..color = const Color(0xFFF0B90B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Center diamond
    final centerPath = Path()
      ..moveTo(24.0, 17.5)
      ..lineTo(30.5, 24.0)
      ..lineTo(24.0, 30.5)
      ..lineTo(17.5, 24.0)
      ..close();
    canvas.drawPath(centerPath, goldPaint);

    // Top chevron
    final topPath = Path()
      ..moveTo(24.0, 5.0)
      ..lineTo(29.0, 10.0)
      ..lineTo(24.0, 15.0)
      ..lineTo(19.0, 10.0)
      ..close();
    canvas.drawPath(topPath, goldPaint);

    // Bottom chevron
    final bottomPath = Path()
      ..moveTo(24.0, 33.0)
      ..lineTo(29.0, 38.0)
      ..lineTo(24.0, 43.0)
      ..lineTo(19.0, 38.0)
      ..close();
    canvas.drawPath(bottomPath, goldPaint);

    // Left chevron
    final leftPath = Path()
      ..moveTo(10.0, 19.0)
      ..lineTo(15.0, 24.0)
      ..lineTo(10.0, 29.0)
      ..lineTo(5.0, 24.0)
      ..close();
    canvas.drawPath(leftPath, goldPaint);

    // Right chevron
    final rightPath = Path()
      ..moveTo(38.0, 19.0)
      ..lineTo(43.0, 24.0)
      ..lineTo(38.0, 29.0)
      ..lineTo(33.0, 24.0)
      ..close();
    canvas.drawPath(rightPath, goldPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
