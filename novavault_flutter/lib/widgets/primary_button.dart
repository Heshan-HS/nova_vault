import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';

class NovaPrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final EdgeInsetsGeometry? padding;

  const NovaPrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.height = 44.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: NovaTokens.brandGradient,
        borderRadius: BorderRadius.circular(NovaTokens.radiusButton),
        boxShadow: const [
          BoxShadow(
            color: Color(0x730B3C8F),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(NovaTokens.radiusButton),
          onTap: onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
