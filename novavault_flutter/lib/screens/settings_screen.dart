import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../tokens/tokens.dart';
import '../services/auth_sync_service.dart';
import '../services/vault_service.dart';
import '../services/security_auth_service.dart';
import 'google_sync_dialog.dart';
import 'import_vault_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final NovaTheme theme;
  final bool isDark;
  final Function(bool) onToggleTheme;
  final VoidCallback? onLockVault;

  const SettingsScreen({
    super.key,
    required this.theme,
    required this.isDark,
    required this.onToggleTheme,
    this.onLockVault,
  });

  void _showChangeMasterPassword(BuildContext context) {
    final vault = VaultService();
    final hasExisting = vault.hasMasterPassword;
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.isDark ? const Color(0xFF07183E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: theme.cardBorder)),
        title: Text(hasExisting ? 'Change Master Password' : 'Set Master Password',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasExisting) ...[
              TextField(
                controller: oldController,
                obscureText: true,
                style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                decoration: InputDecoration(
                  hintText: 'Current Master Password',
                  filled: true,
                  fillColor: theme.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.inputBorder)),
                ),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: newController,
              obscureText: true,
              style: GoogleFonts.inter(fontSize: 14, color: theme.text),
              decoration: InputDecoration(
                hintText: 'New Master Password',
                filled: true,
                fillColor: theme.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.inputBorder)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              obscureText: true,
              style: GoogleFonts.inter(fontSize: 14, color: theme.text),
              decoration: InputDecoration(
                hintText: 'Confirm New Master Password',
                filled: true,
                fillColor: theme.inputBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.inputBorder)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.inter(color: theme.muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NovaTokens.royal700),
            onPressed: () async {
              if (newController.text.trim().isEmpty) return;
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                return;
              }
              final ok = await VaultService().changeMasterPassword(oldController.text, newController.text);
              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Master password updated successfully!' : 'Incorrect current password')),
                );
              }
            },
            child: Text('Update', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthSyncService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: theme.text),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        child: Column(
          children: [
            // Google Account & Cloud Sync Card
            ListenableBuilder(
              listenable: authService,
              builder: (context, _) {
                return _card(
                  title: 'GOOGLE ACCOUNT & SYNC',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: authService.isLoggedIn ? NovaTokens.royal700 : theme.selectedBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: authService.isLoggedIn
                              ? Text(
                                  authService.displayName.substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                )
                              : Icon(Icons.cloud_sync_rounded, color: theme.accent, size: 22),
                        ),
                      ),
                      title: Text(
                        authService.isLoggedIn ? authService.displayName : 'Google Cloud Sync',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                      ),
                      subtitle: Text(
                        authService.isLoggedIn ? authService.userEmail : 'Sync PC & Mobile seamlessly',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: authService.isLoggedIn ? theme.inputBg : NovaTokens.royal700,
                          side: BorderSide(color: theme.inputBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => GoogleSyncDialog.show(context, theme),
                        child: Text(
                          authService.isLoggedIn ? 'Manage' : 'Sign in',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: authService.isLoggedIn ? theme.accent : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Appearance Card
            _card(
              title: 'APPEARANCE',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _themeBtn(
                        label: 'Light Mode',
                        icon: Icons.light_mode_outlined,
                        isSelected: !isDark,
                        onTap: () => onToggleTheme(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _themeBtn(
                        label: 'Dark Mode',
                        icon: Icons.dark_mode_outlined,
                        isSelected: isDark,
                        onTap: () => onToggleTheme(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Security Card
            ListenableBuilder(
              listenable: VaultService(),
              builder: (context, _) {
                final vault = VaultService();
                return _card(
                  title: 'SECURITY & LOCK',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(vault.lockEnabled ? Icons.lock_outline_rounded : Icons.lock_open_rounded, color: theme.accent, size: 20),
                      ),
                      title: Text('App Lock', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text)),
                      subtitle: Text(
                        vault.lockEnabled ? 'Require unlock when opening NovaVault' : 'Disabled — opens directly without lock',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                      ),
                      value: vault.lockEnabled,
                      activeThumbColor: theme.accent,
                      onChanged: (v) async {
                        if (!v) {
                          await vault.setLockEnabled(false);
                        } else if (!vault.hasMasterPassword && !vault.biometricEnabled) {
                          if (vault.canUseDeviceLock) {
                            final ok = await SecurityAuthService.authenticateDevice(
                              title: 'Enable App Lock',
                              subtitle: 'Verify your fingerprint, pattern, or PIN',
                            );
                            if (ok) await vault.setBiometricEnabled(true);
                          } else {
                            if (context.mounted) _showChangeMasterPassword(context);
                          }
                        } else {
                          await vault.setLockEnabled(true);
                        }
                      },
                    ),
                    Divider(color: theme.cardBorder),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.password_rounded, color: theme.accent, size: 20),
                      ),
                      title: Text(
                        vault.hasMasterPassword ? 'Change Master Password' : 'Set Master Password',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                      ),
                      subtitle: Text(
                        vault.hasMasterPassword ? 'Update vault encryption key' : 'Add a master password in addition to device lock',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: theme.muted),
                      onTap: () => _showChangeMasterPassword(context),
                    ),
                    if (vault.canUseDeviceLock) ...[
                      Divider(color: theme.cardBorder),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.fingerprint_rounded, color: theme.accent, size: 20),
                        ),
                        title: Text('Fingerprint / Device Lock', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text)),
                        subtitle: Text('Use phone fingerprint, pattern, or PIN', style: GoogleFonts.inter(fontSize: 12, color: theme.muted)),
                        value: vault.biometricEnabled,
                        activeThumbColor: theme.accent,
                        onChanged: (v) async {
                          if (v) {
                            final ok = await SecurityAuthService.authenticateDevice(
                              title: 'Enable Device Unlock',
                              subtitle: 'Verify your fingerprint, pattern, or PIN',
                            );
                            if (ok) await vault.setBiometricEnabled(true);
                          } else {
                            await vault.setBiometricEnabled(false);
                          }
                        },
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Vault Data & Import Card
            _card(
              title: 'VAULT DATA & IMPORT',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF38BDF8), size: 20),
                  ),
                  title: Text('Google Authenticator 2FA Import', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text)),
                  subtitle: Text('Batch export all 2FA keys from your phone in one go', style: GoogleFonts.inter(fontSize: 12, color: theme.muted)),
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.muted),
                  onTap: () => ImportVaultDialog.show(context, theme, initialTab: 0),
                ),
                Divider(color: theme.cardBorder),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.download_rounded, color: theme.accent, size: 20),
                  ),
                  title: Text('Import Passwords', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text)),
                  subtitle: Text('Import from Bitwarden JSON, CSV, or Chrome CSV', style: GoogleFonts.inter(fontSize: 12, color: theme.muted)),
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.muted),
                  onTap: () => ImportVaultDialog.show(context, theme, initialTab: 1),
                ),
                Divider(color: theme.cardBorder),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: const Color(0x1AEF4444), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                  ),
                  title: Text('Clear Demo Data / Start Fresh', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  subtitle: Text('Wipe sample items to keep only your personal passwords', style: GoogleFonts.inter(fontSize: 12, color: theme.muted)),
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.muted),
                  onTap: () => ImportVaultDialog.show(context, theme),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Devices Card
            _card(
              title: 'SYNCED DEVICES',
              children: [
                _deviceRow(
                  icon: Icons.laptop_rounded,
                  name: Platform.isWindows ? 'Windows PC (This device)' : 'Windows PC',
                  sub: 'Encrypted Google Drive AppData sync',
                ),
                Divider(color: theme.cardBorder),
                _deviceRow(
                  icon: Icons.smartphone_rounded,
                  name: Platform.isAndroid ? 'Android Mobile (This device)' : 'Mobile Device (Android)',
                  sub: 'Biometric & cloud sync ready',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About Card
            _card(
              title: 'ABOUT',
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showAboutDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: NovaTokens.heroGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'NovaVault',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: theme.text,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.selectedBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: theme.selectedBorder),
                                    ),
                                    child: Text(
                                      'v1.0.0',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: theme.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NovaGenSoftware Solutions · Who we are & Security specs',
                                style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: theme.muted),
                      ],
                    ),
                  ),
                ),
                Divider(color: theme.cardBorder),
                _aboutInfoRow(
                  icon: Icons.business_rounded,
                  label: 'Developer',
                  value: 'NovaGenSoftware Solutions',
                ),
                Divider(color: theme.cardBorder),
                _aboutInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Founder & Lead Engineer',
                  value: 'Heshan Sathyanga',
                ),
                Divider(color: theme.cardBorder),
                _aboutInfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Encryption',
                  value: 'AES-256-GCM · Zero-Knowledge',
                ),
              ],
            ),

            if (VaultService().lockEnabled) ...[
              const SizedBox(height: 20),

              // Lock Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x66EF4444)),
                    backgroundColor: const Color(0x1AEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onLockVault,
                  icon: const Icon(Icons.lock_outline_rounded, color: NovaTokens.dangerRed, size: 18),
                  label: Text(
                    'Lock Vault Now',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: NovaTokens.dangerRed),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
        border: Border.all(color: theme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: theme.muted),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _themeBtn({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? theme.selectedBorder : theme.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? theme.accent : theme.muted),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.accent : theme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.accent),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12.5, color: theme.muted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(fontSize: 12.5, color: theme.text, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: NovaTokens.heroGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NovaVault Password Manager',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                            ),
                            Text(
                              'Version 1.0.0 · Production Release',
                              style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.muted, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.selectedBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.selectedBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who We Are',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: theme.text),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NovaVault is built by NovaGenSoftware Solutions, a Sri Lankan software engineering studio founded by Heshan Sathyanga — focused on high-security privacy tools, encrypted networking, and cross-platform productivity software.',
                          style: GoogleFonts.inter(fontSize: 12, color: theme.muted, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _aboutInfoRow(icon: Icons.security_rounded, label: 'Vault Cipher', value: 'AES-256-GCM (Zero-Knowledge)'),
                  Divider(color: theme.cardBorder, height: 12),
                  _aboutInfoRow(icon: Icons.timer_outlined, label: '2FA Standard', value: 'RFC 6238 TOTP Authenticator'),
                  Divider(color: theme.cardBorder, height: 12),
                  _aboutInfoRow(icon: Icons.cloud_done_outlined, label: 'Cloud Storage', value: 'Private Google Drive AppData'),
                  Divider(color: theme.cardBorder, height: 12),
                  _aboutInfoRow(icon: Icons.email_outlined, label: 'Contact', value: 'novagensoftware@gmail.com'),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: theme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            launchUrl(Uri.parse('https://novagenvpn.com/'), mode: LaunchMode.externalApplication);
                          },
                          icon: Icon(Icons.language_rounded, size: 16, color: theme.accent),
                          label: Text(
                            'novagenvpn.com',
                            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: NovaTokens.royal700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deviceRow({required IconData icon, required String name, required String sub}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: theme.selectedBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: theme.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
              const SizedBox(height: 2),
              Text(sub, style: GoogleFonts.inter(fontSize: 11, color: theme.muted)),
            ],
          ),
        ),
        const Icon(Icons.cloud_done_rounded, color: NovaTokens.successGreen, size: 16),
      ],
    );
  }
}
