import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';

class VaultHealthRing extends StatelessWidget {
  final int score;
  final double size;
  final Color? overrideTrack;
  final Color? overrideFill;
  final Color? overrideText;

  const VaultHealthRing({
    super.key,
    this.score = 82,
    this.size = 56.0,
    this.overrideTrack,
    this.overrideFill,
    this.overrideText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: HealthRingPainter(
              progress: (score.clamp(0, 100)) / 100.0,
              strokeWidth: 5.0,
              trackColor: overrideTrack ?? NovaTokens.darkRingTrack,
              fillColor: overrideFill ?? NovaTokens.accentBlueRing,
            ),
          ),
          Text(
            '$score',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: overrideText ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  HealthRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HealthRingPainter oldDelegate) => false;
}
