import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokens/tokens.dart';
import '../../widgets/logo_tile.dart';
import '../../widgets/vault_health_ring.dart';
import '../../services/vault_service.dart';
import '../../services/auth_sync_service.dart';
import '../google_sync_dialog.dart';

class DesktopSidebar extends StatelessWidget {
  final String activeNav;
  final Function(String) onNavChange;
  final String? selectedFolder;
  final Function(String?) onFolderSelect;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenGenerator;
  final NovaTheme theme;

  const DesktopSidebar({
    super.key,
    required this.activeNav,
    required this.onNavChange,
    this.selectedFolder,
    required this.onFolderSelect,
    this.onOpenSettings,
    this.onOpenGenerator,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final vaultService = VaultService();
    final authService = AuthSyncService();

    return ListenableBuilder(
      listenable: Listenable.merge([vaultService, authService]),
      builder: (context, _) {
        final navItems = [
          {'key': 'all', 'label': 'All items', 'count': vaultService.totalItems, 'icon': Icons.shield_outlined},
          {'key': 'favorites', 'label': 'Favorites', 'count': vaultService.favouritesCount, 'icon': Icons.star_border_rounded},
          {'key': 'logins', 'label': 'Logins', 'count': vaultService.loginsCount, 'icon': Icons.lock_outline_rounded},
          {'key': 'cards', 'label': 'Cards', 'count': vaultService.cardsCount, 'icon': Icons.credit_card_outlined},
          {'key': 'notes', 'label': 'Secure notes', 'count': vaultService.notesCount, 'icon': Icons.description_outlined},
          {'key': 'identities', 'label': 'Identities', 'count': vaultService.identitiesCount, 'icon': Icons.person_outline_rounded},
          {'key': 'servers', 'label': 'Servers', 'count': vaultService.serversCount, 'icon': Icons.dns_outlined},
          {'key': 'generator', 'label': 'Generator', 'count': null, 'icon': Icons.auto_fix_high_rounded},
        ];

        final folders = [
          {'name': 'Work', 'count': vaultService.countForFolder('Work')},
          {'name': 'Personal', 'count': vaultService.countForFolder('Personal')},
          {'name': 'Servers', 'count': vaultService.countForFolder('Servers')},
        ];

        return Container(
          width: 264,
          decoration: const BoxDecoration(
            gradient: NovaTokens.sidebarGradient,
            border: Border(
              right: BorderSide(color: Color(0x14FFFFFF), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Logo Lockup
              const Padding(
                padding: EdgeInsets.only(bottom: 22, left: 4),
                child: NovaLogo(isDesktop: true, showWordmark: true),
              ),

              // 2. Navigation Items
              ...navItems.map((item) {
                final key = item['key'] as String;
                final label = item['label'] as String;
                final count = item['count'] as int?;
                final icon = item['icon'] as IconData;
                final isActive = activeNav == key && selectedFolder == null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (key == 'generator') {
                          onOpenGenerator?.call();
                        } else {
                          onFolderSelect(null);
                          onNavChange(key);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0x1AFFFFFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive ? Border.all(color: const Color(0x1FFFFFFF), width: 1) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isActive ? Colors.white : const Color(0xB8FFFFFF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                  color: isActive ? Colors.white : const Color(0xB8FFFFFF),
                                ),
                              ),
                            ),
                            if (count != null)
                              Text(
                                '$count',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.white : const Color(0x7AFFFFFF),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // 3. Folders Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Text(
                  'FOLDERS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0x99FFFFFF),
                  ),
                ),
              ),

              // Folders List
              ...folders.map((folder) {
                final name = folder['name'] as String;
                final count = folder['count'] as int;
                final isFolderActive = selectedFolder == name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onFolderSelect(name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFolderActive ? const Color(0x1AFFFFFF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isFolderActive ? Border.all(color: const Color(0x1FFFFFFF), width: 1) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 18,
                              color: isFolderActive ? Colors.white : const Color(0xB8FFFFFF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isFolderActive ? FontWeight.w600 : FontWeight.w400,
                                  color: isFolderActive ? Colors.white : const Color(0xB8FFFFFF),
                                ),
                              ),
                            ),
                            Text(
                              '$count',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isFolderActive ? Colors.white : const Color(0x7AFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // 4. Vault Health Card
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  vaultService.setFilterChip('Weak');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
                  ),
                  child: Row(
                    children: [
                      VaultHealthRing(score: vaultService.vaultHealthScore),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vault health',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${vaultService.weakPasswordsCount} weak passwords',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xA3FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 5. Account Row (Google Account & Sync)
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0x14FFFFFF), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => GoogleSyncDialog.show(context, theme),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: authService.isLoggedIn ? NovaTokens.royal700 : const Color(0x1FFFFFFF),
                          shape: BoxShape.circle,
                          image: authService.photoUrl != null
                              ? DecorationImage(image: NetworkImage(authService.photoUrl!), fit: BoxFit.cover)
                              : null,
                          border: Border.all(
                            color: authService.isLoggedIn ? NovaTokens.accentBlueDark : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: authService.photoUrl == null
                            ? Center(
                                child: Text(
                                  authService.isLoggedIn && authService.displayName.isNotEmpty
                                      ? authService.displayName.substring(0, 1).toUpperCase()
                                      : 'G',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => GoogleSyncDialog.show(context, theme),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    authService.displayName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (authService.isLoggedIn) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF6FA8FF)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.sync,
                                  size: 11,
                                  color: Color(0xFF6FA8FF),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    authService.isLoggedIn && authService.userEmail.isNotEmpty
                                        ? authService.userEmail
                                        : authService.syncStatus,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: const Color(0x99FFFFFF),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0x99FFFFFF)),
                      tooltip: 'Vault Settings',
                      onPressed: onOpenSettings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
