import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../widgets/logo_tile.dart';
import '../widgets/primary_button.dart';
import '../services/vault_service.dart';
import '../services/security_auth_service.dart';

class SecuritySetupScreen extends StatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  // 0 = Master Password, 1 = Device Lock Only, 2 = No Lock
  int _mode = 0;
  final _pwdController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _alsoBiometric = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _pwdController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    final vault = VaultService();
    setState(() => _error = null);

    if (_mode == 0) {
      final p1 = _pwdController.text.trim();
      final p2 = _confirmController.text.trim();
      if (p1.length < 4) {
        setState(() => _error = 'Master password must be at least 4 characters');
        return;
      }
      if (p1 != p2) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
      var bio = vault.canUseDeviceLock && _alsoBiometric;
      if (bio) {
        setState(() => _busy = true);
        final ok = await SecurityAuthService.authenticateDevice(
          title: 'Enable Device Unlock',
          subtitle: 'Verify your fingerprint, pattern, or PIN',
        );
        if (!mounted) return;
        setState(() => _busy = false);
        if (!ok) {
          bio = false;
        }
      }
      await vault.completeSecuritySetup(
        lockEnabled: true,
        biometricEnabled: bio,
        masterPassword: p1,
      );
    } else if (_mode == 1) {
      setState(() => _busy = true);
      final ok = await SecurityAuthService.authenticateDevice(
        title: 'Set Up Device Lock',
        subtitle: 'Verify your fingerprint, pattern, or PIN to protect NovaVault',
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (!ok) {
        setState(() => _error = 'Device verification cancelled or failed');
        return;
      }
      await vault.completeSecuritySetup(
        lockEnabled: true,
        biometricEnabled: true,
        masterPassword: null,
      );
    } else {
      await vault.completeSecuritySetup(
        lockEnabled: false,
        biometricEnabled: false,
        masterPassword: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDevice = VaultService().canUseDeviceLock;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [NovaTokens.darkBgStart, NovaTokens.darkBgMid, NovaTokens.darkBgEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NovaLogo(isDesktop: true, showWordmark: true),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: NovaTokens.darkCard,
                        borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
                        border: Border.all(color: NovaTokens.darkCardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x80000000),
                            blurRadius: 44,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Set up vault security',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose how you want to unlock NovaVault. You can change this anytime in Settings.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: NovaTokens.darkMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _modeTile(
                            index: 0,
                            icon: Icons.password_rounded,
                            title: 'Master Password',
                            subtitle: canDevice
                                ? 'Strong vault password + optional fingerprint / pattern'
                                : 'Protect your vault with a master password',
                          ),
                          if (canDevice) ...[
                            const SizedBox(height: 10),
                            _modeTile(
                              index: 1,
                              icon: Icons.fingerprint_rounded,
                              title: 'Device Lock Only',
                              subtitle: 'Unlock with phone fingerprint, pattern, or PIN',
                            ),
                          ],
                          const SizedBox(height: 10),
                          _modeTile(
                            index: 2,
                            icon: Icons.lock_open_rounded,
                            title: 'No Lock',
                            subtitle: 'Open vault directly without a lock screen',
                          ),

                          if (_mode == 0) ...[
                            const SizedBox(height: 18),
                            _passwordField(
                              controller: _pwdController,
                              hint: 'Create master password',
                              obscure: _obscure1,
                              onToggle: () => setState(() => _obscure1 = !_obscure1),
                            ),
                            const SizedBox(height: 10),
                            _passwordField(
                              controller: _confirmController,
                              hint: 'Confirm master password',
                              obscure: _obscure2,
                              onToggle: () => setState(() => _obscure2 = !_obscure2),
                              onSubmitted: (_) => _finishSetup(),
                            ),
                            if (canDevice) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.fingerprint_rounded,
                                      size: 18, color: NovaTokens.accentBlueDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Also unlock with Fingerprint / Pattern / PIN',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  Switch(
                                    value: _alsoBiometric,
                                    activeThumbColor: NovaTokens.accentBlueDark,
                                    onChanged: (v) => setState(() => _alsoBiometric = v),
                                  ),
                                ],
                              ),
                            ],
                          ],

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 14, color: NovaTokens.dangerRed),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: NovaTokens.dangerRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),

                          NovaPrimaryButton(
                            text: _busy
                                ? 'Verifying...'
                                : _mode == 2
                                    ? 'Continue without lock'
                                    : 'Save & Continue',
                            height: 46,
                            onPressed: _busy ? null : _finishSetup,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _mode == index;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = index;
        _error = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? NovaTokens.darkSelectedBg : NovaTokens.darkInputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? NovaTokens.darkSelectedBorder : NovaTokens.darkInputBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? NovaTokens.royal700
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: NovaTokens.darkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? NovaTokens.accentBlueDark : NovaTokens.darkMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NovaTokens.darkInputBg,
        borderRadius: BorderRadius.circular(NovaTokens.radiusInput),
        border: Border.all(color: NovaTokens.darkInputBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: NovaTokens.darkMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: NovaTokens.darkMuted,
              size: 18,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
