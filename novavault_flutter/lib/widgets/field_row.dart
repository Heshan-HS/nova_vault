import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';

class NovaFieldRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool masked;
  final bool canCopy;
  final bool canReveal;
  final bool isLast;
  final VoidCallback? onExternalLink;
  final NovaTheme theme;

  const NovaFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.masked = false,
    this.canCopy = true,
    this.canReveal = false,
    this.isLast = false,
    this.onExternalLink,
    required this.theme,
  });

  @override
  State<NovaFieldRow> createState() => _NovaFieldRowState();
}

class _NovaFieldRowState extends State<NovaFieldRow> {
  bool _revealed = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied. Clears in 30s'),
        duration: const Duration(seconds: 2),
        backgroundColor: widget.theme.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.masked && !_revealed ? '••••••••••••' : widget.value;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: widget.isLast
            ? null
            : Border(
                bottom: BorderSide(color: widget.theme.cardBorder, width: 1),
              ),
      ),
      child: Row(
        children: [
          // 36x36 Icon tile
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.theme.selectedBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.theme.accent,
            ),
          ),
          const SizedBox(width: 14),

          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: widget.theme.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.text,
                    letterSpacing: widget.masked && !_revealed ? 3.0 : 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.canReveal)
                IconButton(
                  icon: Icon(
                    _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: widget.theme.accent,
                  ),
                  onPressed: () => setState(() => _revealed = !_revealed),
                ),
              if (widget.canCopy)
                IconButton(
                  icon: Icon(
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 18,
                    color: _copied ? NovaTokens.successGreen : widget.theme.accent,
                  ),
                  onPressed: _copy,
                ),
              if (widget.onExternalLink != null)
                IconButton(
                  icon: Icon(
                    Icons.open_in_new_outlined,
                    size: 18,
                    color: widget.theme.accent,
                  ),
                  onPressed: widget.onExternalLink,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
