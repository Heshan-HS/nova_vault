import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../widgets/strength_bar.dart';

class GeneratorScreen extends StatefulWidget {
  final NovaTheme theme;

  const GeneratorScreen({super.key, required this.theme});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  double _length = 20;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;
  late String _password;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _password = _generatePassword();
  }

  String _generatePassword() {
    String chars = '';
    if (_uppercase) chars += 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    if (_lowercase) chars += 'abcdefghijkmnopqrstuvwxyz';
    if (_numbers) chars += '23456789';
    if (_symbols) chars += '!@#\$%^&*()_+-=~';
    if (chars.isEmpty) chars = 'abcdefghjkmnpqrstuvwxyz';

    final r = Random.secure();
    return List.generate(_length.toInt(), (_) => chars[r.nextInt(chars.length)]).join();
  }

  void _regenerate() {
    setState(() {
      _password = _generatePassword();
    });
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _password));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard')),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = min(100, (_length / 24 * 100).toInt());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Password Generator',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: widget.theme.text),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        child: Column(
          children: [
            // Display Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: NovaTokens.heroGradient,
                borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66051026),
                    blurRadius: 40,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _password,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: NovaTokens.successGreenHero),
                          const SizedBox(width: 6),
                          Text(
                            'Strong · $score%',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: NovaTokens.successGreenHero),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                            onPressed: _regenerate,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: NovaTokens.navy900,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: _copy,
                            icon: Icon(_copied ? Icons.check : Icons.copy_rounded, size: 16),
                            label: Text(
                              _copied ? 'Copied' : 'Copy',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StrengthBarWidget(score: score),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Options Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.theme.card,
                borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
                border: Border.all(color: widget.theme.cardBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUSTOMIZATION',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: widget.theme.muted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Length', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: widget.theme.text)),
                      Text('${_length.toInt()} chars', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: widget.theme.accent)),
                    ],
                  ),
                  Slider(
                    value: _length,
                    min: 8,
                    max: 64,
                    activeColor: widget.theme.accent,
                    onChanged: (v) {
                      setState(() {
                        _length = v;
                        _password = _generatePassword();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _switchTile('Uppercase (A-Z)', _uppercase, (v) => setState(() { _uppercase = v; _regenerate(); })),
                  _switchTile('Lowercase (a-z)', _lowercase, (v) => setState(() { _lowercase = v; _regenerate(); })),
                  _switchTile('Numbers (0-9)', _numbers, (v) => setState(() { _numbers = v; _regenerate(); })),
                  _switchTile('Symbols (!@#\$)', _symbols, (v) => setState(() { _symbols = v; _regenerate(); })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool val, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, color: widget.theme.text)),
      value: val,
      activeThumbColor: widget.theme.accent,
      onChanged: onChanged,
    );
  }
}
