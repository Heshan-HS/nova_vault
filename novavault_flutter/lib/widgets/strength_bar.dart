import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

class StrengthBarWidget extends StatelessWidget {
  final int score; // 0 - 100
  final Color? trackColor;
  final Color? fillColor;

  const StrengthBarWidget({
    super.key,
    this.score = 88,
    this.trackColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = (score.clamp(0, 100)) / 100.0;

    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: trackColor ?? NovaTokens.darkRingTrack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            gradient: fillColor == null ? NovaTokens.brandGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
