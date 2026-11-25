import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../models/vault_item.dart';
import '../services/vault_service.dart';
import '../services/totp_service.dart';
import '../widgets/primary_button.dart';

class SetupTotpDialog extends StatefulWidget {
  final NovaTheme theme;
  final VaultItem item;

  const SetupTotpDialog({super.key, required this.theme, required this.item});

  static void show(BuildContext context, NovaTheme theme, VaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => SetupTotpDialog(theme: theme, item: item),
    );
  }

  @override
  State<SetupTotpDialog> createState() => _SetupTotpDialogState();
}

class _SetupTotpDialogState extends State<SetupTotpDialog> {
  late final TextEditingController _keyController;
  String _livePreviewCode = '------';

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.item.totpSecret);
    _updatePreview(_keyController.text);
    _keyController.addListener(() => _updatePreview(_keyController.text));
  }

  void _updatePreview(String raw) {
    final clean = raw.trim().toUpperCase().replaceAll(' ', '');
    if (clean.length >= 8) {
      try {
        final code = TotpService.generateTotp(secret: clean);
        setState(() => _livePreviewCode = code);
      } catch (_) {
        setState(() => _livePreviewCode = 'Invalid key');
      }
    } else {
      setState(() => _livePreviewCode = '------');
    }
  }

  Future<void> _save() async {
    final secret = _keyController.text.trim().toUpperCase().replaceAll(' ', '');
    if (secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 2FA secret key')),
      );
      return;
    }

    await VaultService().setTotpSecret(widget.item.id, secret);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('2FA Authenticator activated for ${widget.item.name}!')),
      );
    }
  }

  Future<void> _remove() async {
    await VaultService().removeTotp(widget.item.id);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('2FA Authenticator removed from ${widget.item.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDark ? const Color(0xFF07183E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: NovaTokens.brandGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.timer_outlined, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set up 2FA Authenticator',
                                style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: theme.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'For ${widget.item.name}',
                                style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.muted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            Text(
              'When you enable Two-Factor Authentication on ${widget.item.name} (GitHub, Google, Binance, AWS, etc.), copy the secret key provided by the service and paste it here:',
              style: GoogleFonts.inter(fontSize: 12, color: theme.muted, height: 1.4),
            ),

            const SizedBox(height: 16),

            Text('2FA SECRET KEY (BASE32)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: theme.muted, letterSpacing: 1.0)),
            const SizedBox(height: 6),
            TextField(
              controller: _keyController,
              style: GoogleFonts.robotoMono(fontSize: 14, color: theme.text),
              decoration: InputDecoration(
                hintText: 'e.g. JBSWY3DPEHPK3PXP or HXDMVJECJJWSRB3H',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: theme.muted.withValues(alpha: 0.6)),
                filled: true,
                fillColor: theme.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
              ),
            ),

            const SizedBox(height: 18),

            // Live Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.selectedBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.selectedBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: NovaTokens.successGreen, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Authenticator Code Preview', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: theme.muted)),
                        const SizedBox(height: 2),
                        Text(
                          _livePreviewCode,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.0,
                            color: NovaTokens.royal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (widget.item.hasTotp) ...[
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    onPressed: _remove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Remove 2FA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.inter(color: theme.muted)),
                ),
                const SizedBox(width: 12),
                NovaPrimaryButton(
                  text: 'Save 2FA Key',
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
