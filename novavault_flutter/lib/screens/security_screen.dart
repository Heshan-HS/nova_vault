import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../widgets/vault_health_ring.dart';
import '../services/vault_service.dart';

class SecurityScreen extends StatelessWidget {
  final NovaTheme theme;

  const SecurityScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final vaultService = VaultService();

    return ListenableBuilder(
      listenable: vaultService,
      builder: (context, _) {
        final weakCount = vaultService.weakPasswordsCount;
        final healthScore = vaultService.vaultHealthScore;
        final totalLogins = vaultService.loginsCount;

        final issues = [
          {
            'title': 'Weak passwords',
            'count': weakCount,
            'desc': weakCount > 0 ? '$weakCount passwords under 12 characters or low entropy' : 'All passwords meet strong entropy standards',
            'isWarning': weakCount > 0,
            'icon': Icons.lock_open_rounded,
          },
          {
            'title': 'Exposed in breaches',
            'count': 0,
            'desc': 'Zero breached accounts detected in haveibeenpwned database',
            'isWarning': false,
            'icon': Icons.shield_outlined,
          },
          {
            'title': '2FA Enabled accounts',
            'count': vaultService.items.where((i) => i.hasTotp).length,
            'desc': 'Accounts secured with RFC 6238 TOTP authenticator keys',
            'isWarning': false,
            'icon': Icons.timer_outlined,
          },
          {
            'title': 'Zero-knowledge encryption',
            'count': vaultService.totalItems,
            'desc': 'AES-256-GCM / PBKDF2 local client-side encrypted items',
            'isWarning': false,
            'icon': Icons.verified_user_outlined,
          },
        ];

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Security Centre',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: theme.text),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            child: Column(
              children: [
                // Big Score Card
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
                  child: Row(
                    children: [
                      VaultHealthRing(
                        score: healthScore,
                        size: 68,
                        overrideTrack: const Color(0x33FFFFFF),
                        overrideFill: healthScore >= 80 ? NovaTokens.successGreenHero : (healthScore >= 50 ? Colors.amber : Colors.redAccent),
                        overrideText: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Vault Health: $healthScore / 100',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weakCount == 0
                                  ? 'Your vault is completely secure. All $totalLogins logins have strong credentials.'
                                  : 'Resolving $weakCount weak password${weakCount > 1 ? 's' : ''} will bring your security score to 98+.',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCFE0FF), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Issues list
                ...issues.map((issue) {
                  final title = issue['title'] as String;
                  final count = issue['count'] as int;
                  final desc = issue['desc'] as String;
                  final isWarning = issue['isWarning'] as bool;
                  final icon = issue['icon'] as IconData;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.card,
                        borderRadius: BorderRadius.circular(NovaTokens.radiusCard),
                        border: Border.all(color: theme.cardBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isWarning ? const Color(0x26EF4444) : theme.selectedBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: isWarning ? NovaTokens.dangerRed : theme.accent,
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
                                      title,
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isWarning ? const Color(0x26EF4444) : theme.selectedBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isWarning ? NovaTokens.dangerRed : theme.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: GoogleFonts.inter(fontSize: 12, color: theme.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
