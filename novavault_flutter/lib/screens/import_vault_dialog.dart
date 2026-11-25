import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../models/vault_item.dart';
import '../services/vault_importer.dart';
import '../services/vault_service.dart';
import '../services/totp_service.dart';
import '../services/google_auth_migration_parser.dart';
import '../widgets/primary_button.dart';

class ImportVaultDialog extends StatefulWidget {
  final NovaTheme theme;
  final int initialTab;

  const ImportVaultDialog({super.key, required this.theme, this.initialTab = 0});

  static void show(BuildContext context, NovaTheme theme, {int initialTab = 0}) {
    showDialog(
      context: context,
      builder: (ctx) => ImportVaultDialog(theme: theme, initialTab: initialTab),
    );
  }

  @override
  State<ImportVaultDialog> createState() => _ImportVaultDialogState();
}

class _ImportVaultDialogState extends State<ImportVaultDialog> {
  final _textController = TextEditingController();
  final _googleAuthController = TextEditingController();
  late int _tab;
  List<GoogleAuthAccount> _parsedGoogleAccounts = [];
  Timer? _totpRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _googleAuthController.addListener(_onGoogleAuthInputChanged);
    _totpRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _parsedGoogleAccounts.isNotEmpty) {
        setState(() {}); // refresh live TOTP codes
      }
    });
  }

  @override
  void dispose() {
    _totpRefreshTimer?.cancel();
    _textController.dispose();
    _googleAuthController.dispose();
    super.dispose();
  }

  void _onGoogleAuthInputChanged() {
    final text = _googleAuthController.text.trim();
    if (text.isEmpty) {
      if (_parsedGoogleAccounts.isNotEmpty) {
        setState(() => _parsedGoogleAccounts = []);
      }
      return;
    }
    final accounts = GoogleAuthMigrationParser.parse(text);
    setState(() {
      _parsedGoogleAccounts = accounts;
    });
  }

  Future<void> _importGoogleAuth() async {
    if (_parsedGoogleAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Google Authenticator accounts found. Please paste valid export data.')),
      );
      return;
    }

    final count = await VaultService().batchApplyTotp(_parsedGoogleAccounts);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported and activated $count 2FA Authenticator accounts!'),
          backgroundColor: NovaTokens.royal700,
        ),
      );
    }
  }

  void _import() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste exported JSON or CSV content')),
      );
      return;
    }

    int count = 0;
    if (text.startsWith('{') || text.contains('"items"')) {
      count = VaultImporter.importBitwardenJson(text);
    } else {
      count = VaultImporter.importCsv(text);
    }

    if (count > 0) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $count real items into your vault!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not parse vault export. Please check format.')),
      );
    }
  }

  void _clearVault() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.isDark ? const Color(0xFF07183E) : Colors.white,
        title: Text('Clear All Items?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: widget.theme.text)),
        content: Text(
          'This will remove all demo passwords and give you a 100% clean, empty vault for your personal accounts.',
          style: GoogleFonts.inter(fontSize: 13, color: widget.theme.muted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.inter(color: widget.theme.muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await VaultService().clearAllItems();
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All demo items cleared! Your vault is now clean and empty.')),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 700),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: NovaTokens.brandGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.download_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import & Sync Vault',
                          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: theme.text),
                        ),
                        Text(
                          'Google Authenticator 2FA batch export, Bitwarden, or Chrome',
                          style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.muted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tab selector
            Row(
              children: [
                _tabBtn('Google Authenticator 2FA', 0, theme),
                const SizedBox(width: 8),
                _tabBtn('Bitwarden / Chrome Passwords', 1, theme),
                const SizedBox(width: 8),
                _tabBtn('Reset / Clean Vault', 2, theme),
              ],
            ),

            const SizedBox(height: 18),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tab == 0) _buildGoogleAuthTab(theme),
                    if (_tab == 1) _buildBitwardenTab(theme),
                    if (_tab == 2) _buildResetTab(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleAuthTab(NovaTheme theme) {
    final existingItems = VaultService().items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual Step-by-Step Guide
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  Text(
                    'How to batch export from Google Authenticator App:',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _guideStep('1', 'Open Google Authenticator on your phone -> Tap ☰ (Menu) -> "Transfer accounts" -> "Export accounts".', theme),
              const SizedBox(height: 6),
              _guideStep('2', 'Select accounts (Tip: select 10-15 accounts per batch, or all. If you have many accounts, Google splits them into multiple QR codes).', theme),
              const SizedBox(height: 6),
              _guideStep('3', 'Scan the QR with Google Lens/Camera -> Tap "Copy text" (starts with otpauth-migration://offline?data=...).', theme),
              const SizedBox(height: 6),
              _guideStep('4', 'Paste the link below! You can paste multiple links (one per line) if you scanned multiple QR codes.', theme),
            ],
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _googleAuthController,
          maxLines: 4,
          style: GoogleFonts.robotoMono(fontSize: 11, color: theme.text),
          decoration: InputDecoration(
            hintText: 'Paste one or more otpauth-migration://offline?data=... links here (one per line)',
            hintStyle: GoogleFonts.inter(fontSize: 11, color: theme.muted.withValues(alpha: 0.6)),
            filled: true,
            fillColor: theme.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: NovaTokens.midBlue, width: 1.5)),
          ),
        ),

        const SizedBox(height: 16),

        // Preview of Parsed Accounts
        if (_parsedGoogleAccounts.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2010B981),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x6010B981)),
                    ),
                    child: Text(
                      '${_parsedGoogleAccounts.length} Accounts Found',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: NovaTokens.successGreen),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Real TOTP codes ticking live',
                    style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: theme.muted),
                  const SizedBox(width: 4),
                  Text(
                    '${TotpService.getRemainingSeconds()}s left',
                    style: GoogleFonts.robotoMono(fontSize: 11, color: NovaTokens.accentBlueDark, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: theme.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorder),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _parsedGoogleAccounts.length,
              separatorBuilder: (_, __) => Divider(color: theme.cardBorder, height: 8),
              itemBuilder: (ctx, idx) {
                final acc = _parsedGoogleAccounts[idx];
                final match = existingItems.firstWhere(
                  (i) => i.username.toLowerCase().contains(acc.cleanAccountName.toLowerCase()) ||
                         i.name.toLowerCase().contains(acc.displayTitle.toLowerCase()),
                  orElse: () => VaultItem(id: '', name: '', category: '', tags: [], folder: ''),
                );
                final hasMatch = match.id.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  acc.displayTitle,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: hasMatch ? const Color(0x2010B981) : const Color(0x2038BDF8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    hasMatch ? 'Links to: ${match.name}' : 'New item',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: hasMatch ? NovaTokens.successGreen : const Color(0xFF38BDF8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              acc.cleanAccountName,
                              style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.cardBorder),
                        ),
                        child: Text(
                          acc.liveCode,
                          style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.w700, color: NovaTokens.accentBlueDark, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: theme.muted)),
            ),
            const SizedBox(width: 12),
            NovaPrimaryButton(
              text: _parsedGoogleAccounts.isEmpty
                  ? 'Paste Export Data Above'
                  : 'Import & Activate ${_parsedGoogleAccounts.length} 2FA Accounts',
              icon: Icons.shield_rounded,
              onPressed: _parsedGoogleAccounts.isEmpty ? null : _importGoogleAuth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _guideStep(String number, String text, NovaTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: NovaTokens.midBlue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: NovaTokens.midBlue),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 11, color: theme.text, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBitwardenTab(NovaTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export your vault from Bitwarden (Settings -> Export Vault -> JSON or CSV) or Google Chrome (Passwords -> Export Passwords -> CSV), and paste the content below:',
          style: GoogleFonts.inter(fontSize: 12, color: theme.muted, height: 1.4),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _textController,
          maxLines: 7,
          style: GoogleFonts.robotoMono(fontSize: 12, color: theme.text),
          decoration: InputDecoration(
            hintText: 'Paste Bitwarden JSON, CSV, or Chrome CSV here...',
            hintStyle: GoogleFonts.inter(fontSize: 12, color: theme.muted.withValues(alpha: 0.6)),
            filled: true,
            fillColor: theme.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: theme.muted)),
            ),
            const SizedBox(width: 12),
            NovaPrimaryButton(
              text: 'Import Passwords',
              icon: Icons.file_upload_outlined,
              onPressed: _import,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetTab(NovaTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0x1AEF4444),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x40EF4444)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 10),
                  Text('Wipe Demo Items', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: theme.text)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Remove all mock/dummy entries (GitHub, Netflix, Spotify, Bank Card demo) and start fresh with your personal passwords only.',
                style: GoogleFonts.inter(fontSize: 12, color: theme.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _clearVault,
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                label: const Text('Clear All Demo Items Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Restore Initial Demo Items', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text)),
              const SizedBox(height: 6),
              Text('If you ever want to preview sample items again, you can restore them anytime.', style: GoogleFonts.inter(fontSize: 12, color: theme.muted)),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.inputBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await VaultService().resetToDemoItems();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo items restored.')));
                  }
                },
                child: Text('Restore Demo Items', style: GoogleFonts.inter(color: theme.text, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBtn(String label, int index, NovaTheme theme) {
    final active = _tab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? NovaTokens.royal700 : theme.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? NovaTokens.royal700 : theme.inputBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : theme.muted,
          ),
        ),
      ),
    );
  }
}
