import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../services/auth_sync_service.dart';
import '../services/vault_service.dart';

class GoogleSyncDialog extends StatefulWidget {
  final NovaTheme theme;

  const GoogleSyncDialog({super.key, required this.theme});

  static void show(BuildContext context, NovaTheme theme) {
    showDialog(
      context: context,
      builder: (ctx) => GoogleSyncDialog(theme: theme),
    );
  }

  @override
  State<GoogleSyncDialog> createState() => _GoogleSyncDialogState();
}

class _GoogleSyncDialogState extends State<GoogleSyncDialog> {
  final _authService = AuthSyncService();
  bool _isLoading = false;

  Future<void> _handleRealGoogleSignIn() async {
    setState(() => _isLoading = true);
    final success = await _authService.startProductionGoogleOAuth();

    if (success) {
      await _authService.syncWithGoogleDrive(VaultService().items);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (mounted) {
      if (success) {
        final email = _authService.userEmail;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Connected to Google as $email! Google Drive sync active.'),
            backgroundColor: const Color(0xFF137333),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.syncStatus),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final isLoggedIn = _authService.isLoggedIn;
        final vaultItems = VaultService().items;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.isDark ? const Color(0xFF07183E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.cardBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: NovaTokens.brandGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Google Cloud Sync',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: theme.text,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'End-to-End Encrypted Google Drive Backup',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: theme.muted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: Icon(Icons.close_rounded, color: theme.muted, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 22),

                  if (isLoggedIn) ...[
                    // Connected State with Real Google Profile
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.isDark ? const Color(0x1A2F6FE0) : const Color(0xFFEDF4FE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.isDark ? const Color(0x406FA8FF) : const Color(0xFFA9C4F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: NovaTokens.royal700,
                            backgroundImage: _authService.photoUrl != null
                                ? NetworkImage(_authService.photoUrl!)
                                : null,
                            child: _authService.photoUrl == null
                                ? Text(
                                    _authService.displayName.isNotEmpty
                                        ? _authService.displayName.substring(0, 1).toUpperCase()
                                        : 'G',
                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _authService.displayName,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.text,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, size: 16, color: NovaTokens.successGreen),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _authService.userEmail,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.cloud_done_rounded, size: 13, color: NovaTokens.successGreen),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Google Drive AppData: ${_authService.syncStatus}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: NovaTokens.accentBlueDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _syncDeviceRow(
                            icon: Icons.cloud_upload_rounded,
                            title: 'Encrypted Cloud Backup',
                            subtitle: 'File: novavault_vault.enc (${vaultItems.length} items synced)',
                            isSynced: true,
                            theme: theme,
                          ),
                          const Divider(height: 16),
                          _syncDeviceRow(
                            icon: Icons.security_rounded,
                            title: 'Zero-Knowledge Privacy',
                            subtitle: 'Encrypted with AES-256 before uploading to Google Drive',
                            isSynced: true,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0x40E53935)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await _authService.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Disconnected from Google Account')),
                                );
                              }
                            },
                            icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                            label: Text(
                              'Disconnect',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: NovaTokens.royal700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    await _authService.syncWithGoogleDrive(VaultService().items);
                                    if (mounted) {
      setState(() => _isLoading = false);
    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Vault synced with Google Drive AppData!')),
                                      );
                                    }
                                  },
                            icon: _isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.sync_rounded, size: 16, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Syncing...' : 'Sync to Drive',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Not Connected State - Clean Production Google Sign-In
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.selectedBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.selectedBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: NovaTokens.royal700, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Zero-Knowledge Cloud Sync',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in with your Google account to securely back up and sync your AES-256 encrypted vault across your Windows and Android devices.',
                            style: GoogleFonts.inter(fontSize: 12.5, color: theme.muted, height: 1.45),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _syncDeviceRow(
                            icon: Icons.lock_outline_rounded,
                            title: 'Private AppData Folder',
                            subtitle: 'Only NovaVault can access your encrypted backup',
                            isSynced: false,
                            theme: theme,
                          ),
                          const Divider(height: 16),
                          _syncDeviceRow(
                            icon: Icons.devices_rounded,
                            title: 'Multi-Device Sync',
                            subtitle: 'Automatic sync between PC & Mobile',
                            isSynced: false,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Button: Continue with Google
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F1F1F),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.cardBorder, width: 1.2),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleRealGoogleSignIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: NovaTokens.royal700),
                              )
                            else
                              Image.network(
                                'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 26),
                              ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _isLoading ? 'Signing in with Google...' : 'Continue with Google',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F1F)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _syncDeviceRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSynced,
    required NovaTheme theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: theme.muted)),
            ],
          ),
        ),
        Icon(
          isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
          size: 18,
          color: isSynced ? NovaTokens.successGreen : theme.muted,
        ),
      ],
    );
  }
}
