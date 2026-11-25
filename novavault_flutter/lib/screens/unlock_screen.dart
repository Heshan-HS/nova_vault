import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../widgets/logo_tile.dart';
import '../widgets/primary_button.dart';
import '../services/vault_service.dart';
import '../services/security_auth_service.dart';

class UnlockScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const UnlockScreen({super.key, required this.onUnlock});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _rememberDevice = true;
  bool _authenticating = false;
  String? _error;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Auto-trigger device fingerprint / pattern / PIN if enabled
    final vault = VaultService();
    if (vault.biometricEnabled && vault.canUseDeviceLock) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBiometricUnlock());
    }
  }

  Future<void> _triggerBiometricUnlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _error = null;
    });
    final ok = await SecurityAuthService.authenticateDevice(
      title: 'Unlock NovaVault',
      subtitle: 'Verify with fingerprint, pattern, or PIN',
    );
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (ok) {
      VaultService().unlockWithBiometrics();
      widget.onUnlock();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _submit() {
    final pwd = _controller.text.trim();
    if (pwd.isEmpty) {
      setState(() => _error = 'Please enter your master password');
      _shakeController.forward(from: 0.0);
      return;
    }
    final success = VaultService().unlock(pwd);
    if (success) {
      widget.onUnlock();
    } else {
      setState(() => _error = 'Incorrect master password. Please try again.');
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const NovaLogo(isDesktop: true, showWordmark: true),
                  const SizedBox(height: 28),

                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value * (_shakeController.isAnimating ? 1 : 0), 0),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: NovaTokens.darkCard,
                        borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
                        border: Border.all(color: NovaTokens.darkCardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x80000000),
                            blurRadius: 50,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Unlock your vault',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            VaultService().hasMasterPassword
                                ? 'Enter your master password to decrypt'
                                : 'Verify with your device lock to continue',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: NovaTokens.darkMuted),
                          ),
                          const SizedBox(height: 22),

                          if (VaultService().hasMasterPassword) ...[
                            // Input
                            TextField(
                              controller: _controller,
                              obscureText: _obscure,
                              autofocus: !VaultService().biometricEnabled,
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.white, letterSpacing: _obscure ? 2.0 : 0.0),
                              decoration: InputDecoration(
                                hintText: 'Master password',
                                hintStyle: GoogleFonts.inter(fontSize: 14, color: NovaTokens.darkMuted),
                                filled: true,
                                fillColor: NovaTokens.darkInputBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(NovaTokens.radiusInput),
                                  borderSide: BorderSide(color: _error != null ? NovaTokens.dangerRed : NovaTokens.darkInputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(NovaTokens.radiusInput),
                                  borderSide: BorderSide(color: _error != null ? NovaTokens.dangerRed : NovaTokens.darkInputBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(NovaTokens.radiusInput),
                                  borderSide: BorderSide(color: _error != null ? NovaTokens.dangerRed : NovaTokens.midBlue, width: 1.5),
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.content_paste_rounded, color: NovaTokens.accentBlueDark, size: 18),
                                      tooltip: 'Paste from clipboard',
                                      onPressed: () async {
                                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                                        if (data?.text != null && data!.text!.isNotEmpty) {
                                          _controller.text = data.text!;
                                          setState(() => _error = null);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: NovaTokens.darkMuted, size: 18),
                                      tooltip: _obscure ? 'Show password' : 'Hide password',
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: NovaTokens.dangerRed, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: NovaTokens.dangerRed)),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Remember Device
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberDevice,
                                    activeColor: NovaTokens.midBlue,
                                    onChanged: (v) => setState(() => _rememberDevice = v ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Remember this device', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xB8FFFFFF))),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: NovaPrimaryButton(
                                    text: 'Unlock Vault',
                                    onPressed: _submit,
                                  ),
                                ),
                                if (VaultService().biometricEnabled && VaultService().canUseDeviceLock) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0x1AFFFFFF),
                                      borderRadius: BorderRadius.circular(NovaTokens.radiusButton),
                                      border: Border.all(color: const Color(0x26FFFFFF)),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.fingerprint_rounded, color: NovaTokens.accentBlueDark, size: 22),
                                      tooltip: 'Unlock with Fingerprint / Device Lock',
                                      onPressed: _triggerBiometricUnlock,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ] else ...[
                            NovaPrimaryButton(
                              text: _authenticating ? 'Verifying...' : 'Unlock with Fingerprint / Device Lock',
                              onPressed: _authenticating ? null : _triggerBiometricUnlock,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: Color(0x8CFFFFFF)),
                      const SizedBox(width: 6),
                      Text(
                        'Zero-Knowledge AES-256-GCM Architecture',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0x8CFFFFFF)),
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
}
