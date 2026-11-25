import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import '../../widgets/item_avatar.dart';
import '../../services/auth_sync_service.dart';
import '../google_sync_dialog.dart';
import '../import_vault_dialog.dart';

class DesktopListPane extends StatelessWidget {
  final List<VaultItem> items;
  final String? selectedId;
  final Function(String) onSelect;
  final String searchQuery;
  final Function(String) onSearchChange;
  final String activeChip;
  final Function(String) onChipChange;
  final Function(String)? onToggleFavourite;
  final NovaTheme theme;
  final String title;

  const DesktopListPane({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.searchQuery,
    required this.onSearchChange,
    required this.activeChip,
    required this.onChipChange,
    this.onToggleFavourite,
    required this.theme,
    this.title = 'All items',
  });

  @override
  Widget build(BuildContext context) {
    const chips = ['All', 'Logins', 'Cards', 'Weak'];

    return Container(
      width: 372,
      decoration: BoxDecoration(
        color: theme.listTint,
        border: Border(
          right: BorderSide(color: theme.cardBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                    letterSpacing: -0.3,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${items.length} items',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.muted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.file_download_outlined, size: 18, color: theme.accent),
                      tooltip: 'Import from Google Authenticator (2FA) / Bitwarden / Chrome',
                      onPressed: () => ImportVaultDialog.show(context, theme),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Input with Ctrl K
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: theme.inputBg,
                borderRadius: BorderRadius.circular(NovaTokens.radiusInput),
                border: Border.all(color: theme.inputBorder, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: theme.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChange,
                      style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                      decoration: InputDecoration(
                        hintText: 'Search vault',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: theme.muted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.inputBorder, width: 1),
                    ),
                    child: Text(
                      'Ctrl K',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: chips.map((chip) {
                final isActive = activeChip == chip;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(NovaTokens.radiusChip),
                      onTap: () => onChipChange(chip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? NovaTokens.royal700 : theme.card,
                          borderRadius: BorderRadius.circular(NovaTokens.radiusChip),
                          border: isActive ? null : Border.all(color: theme.cardBorder, width: 1),
                        ),
                        child: Text(
                          chip,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive ? Colors.white : theme.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Items List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: theme.cardBorder),
                            ),
                            child: Icon(
                              AuthSyncService().isLoggedIn ? Icons.inbox_outlined : Icons.lock_person_outlined,
                              size: 28,
                              color: theme.muted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AuthSyncService().isLoggedIn ? 'No Items Found' : 'Vault Logged Out',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AuthSyncService().isLoggedIn
                                ? 'No credentials match the current view.'
                                : 'Sign in with your Google account to sync and access your vault items.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: theme.muted,
                              height: 1.4,
                            ),
                          ),
                          if (!AuthSyncService().isLoggedIn) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B68D6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.sync_lock_rounded, size: 16),
                                label: Text(
                                  'Sign in with Google',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                onPressed: () => GoogleSyncDialog.show(context, theme),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                final primaryTag = item.tags.isNotEmpty ? item.tags.first : null;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(NovaTokens.radiusListRow),
                    onTap: () => onSelect(item.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.selectedBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(NovaTokens.radiusListRow),
                        border: isSelected ? Border.all(color: theme.selectedBorder, width: 1) : null,
                      ),
                      child: Row(
                        children: [
                          ItemAvatar(
                            name: item.name,
                            category: item.category,
                            username: item.username,
                            url: item.url,
                            size: 44,
                            radius: 12,
                            isDark: theme.isDark,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.text,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.username.isNotEmpty ? item.username : (item.url.isNotEmpty ? item.url : item.category),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: theme.muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (primaryTag != null && primaryTag.toLowerCase() != 'imported') ...[
                            Text(
                              primaryTag,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => onToggleFavourite?.call(item.id),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                item.favourite ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 16,
                                color: item.favourite ? theme.accent : theme.muted.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
