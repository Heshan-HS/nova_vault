import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../services/totp_service.dart';

class TotpRingWidget extends StatefulWidget {
  final int initialSeconds;
  final int period;
  final String code;
  final String secret;
  final bool isDesktop;
  final bool showCode;
  final NovaTheme? theme;

  const TotpRingWidget({
    super.key,
    this.initialSeconds = 18,
    this.period = 30,
    this.code = '482 913',
    this.secret = 'JBSWY3DPEHPK3PXP',
    this.isDesktop = true,
    this.showCode = true,
    this.theme,
  });

  @override
  State<TotpRingWidget> createState() => _TotpRingWidgetState();
}

class _TotpRingWidgetState extends State<TotpRingWidget> {
  late int _secondsLeft;
  late String _currentCode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = TotpService.getRemainingSeconds(period: widget.period);
    _currentCode = TotpService.generateTotp(secret: widget.secret, period: widget.period);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft = TotpService.getRemainingSeconds(period: widget.period);
        _currentCode = TotpService.generateTotp(secret: widget.secret, period: widget.period);
      });
    });
  }

  @override
  void didUpdateWidget(covariant TotpRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secret != widget.secret || oldWidget.period != widget.period) {
      _secondsLeft = TotpService.getRemainingSeconds(period: widget.period);
      _currentCode = TotpService.generateTotp(secret: widget.secret, period: widget.period);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double boxDim = widget.isDesktop ? 76.0 : 64.0;
    final double stroke = widget.isDesktop ? 6.0 : 6.5;

    final theme = widget.theme;
    final trackColor = theme?.ringTrack ?? NovaTokens.darkRingTrack;
    final fillColor = theme?.ringFill ?? NovaTokens.accentBlueRing;
    final secondsColor = (theme?.isDark ?? true) ? Colors.white : theme!.text;
    final codeColor = theme != null
        ? (theme.isDark ? NovaTokens.accentBlueDark : NovaTokens.royal700)
        : NovaTokens.accentBlueDark;
    final labelColor = theme?.muted ?? NovaTokens.darkMuted;

    return Row(
      children: [
        // Countdown Ring
        SizedBox(
          width: boxDim,
          height: boxDim,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(boxDim, boxDim),
                painter: CircularCountdownPainter(
                  progress: _secondsLeft / widget.period,
                  strokeWidth: stroke,
                  trackColor: trackColor,
                  fillColor: fillColor,
                ),
              ),
              Text(
                '${_secondsLeft}s',
                style: GoogleFonts.inter(
                  fontSize: widget.isDesktop ? 13 : 11,
                  fontWeight: FontWeight.w700,
                  color: secondsColor,
                ),
              ),
            ],
          ),
        ),

        if (widget.showCode) ...[
          const SizedBox(width: 16),
          // Code digits with FittedBox to prevent any overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentCode,
                    style: GoogleFonts.inter(
                      fontSize: widget.isDesktop ? 30 : 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: widget.isDesktop ? 3.0 : 2.0,
                      color: codeColor,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Refreshes automatically',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class CircularCountdownPainter extends CustomPainter {
  final double progress; // 1.0 to 0.0
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  CircularCountdownPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc (starting at top = -pi/2)
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
  bool shouldRepaint(covariant CircularCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
