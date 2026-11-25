import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import '../../widgets/item_avatar.dart';
import '../../widgets/vault_health_ring.dart';
import '../../services/vault_service.dart';
import '../../services/auth_sync_service.dart';
import '../google_sync_dialog.dart';

class MobileVaultList extends StatefulWidget {
  final List<VaultItem> items;
  final Function(VaultItem) onSelectItem;
  final VoidCallback? onNewItem;
  final VoidCallback? onOpenSecurity;
  final NovaTheme theme;
  final double bottomPadding;

  const MobileVaultList({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.onNewItem,
    this.onOpenSecurity,
    required this.theme,
    this.bottomPadding = 80,
  });

  @override
  State<MobileVaultList> createState() => _MobileVaultListState();
}

class _MobileVaultListState extends State<MobileVaultList>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _activeFilter = 'All';
  String? _copiedId;
  bool _isReordering = false;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _searchAnim;

  static const _filters = ['All', 'Logins', 'Cards', 'Servers', 'Weak'];

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchAnim.dispose();
    super.dispose();
  }

  List<VaultItem> get _filtered {
    var items = widget.items;
    if (_activeFilter == 'Logins') {
      items = items.where((e) => e.category == 'login').toList();
    } else if (_activeFilter == 'Cards') {
      items = items.where((e) => e.category == 'card').toList();
    } else if (_activeFilter == 'Servers') {
      items = items.where((e) => e.category == 'server').toList();
    } else if (_activeFilter == 'Weak') {
      items = items.where((e) {
        final score = e.password.length;
        return score > 0 && score < 12;
      }).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.username.toLowerCase().contains(q) ||
              e.url.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  void _copyPassword(VaultItem item) {
    final text = item.password.isNotEmpty ? item.password : item.username;
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedId = item.id);
    _showCopied();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copiedId = null);
    });
  }

  void _showCopied() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Password copied to clipboard',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0B3C8F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1800),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.isDark;
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed Top Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NovaVault',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: widget.theme.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${widget.items.length} items secured',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: widget.theme.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SyncChip(theme: widget.theme),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onNewItem,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: NovaTokens.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x660B3C8F),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── Fixed Search Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SearchBar(
                controller: _searchController,
                theme: widget.theme,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            // ── Fixed Vault Health Card ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _VaultHealthCard(
                theme: widget.theme,
                onTap: widget.onOpenSecurity,
              ),
            ),

            // ── Fixed Filter Chips ───────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _FilterChip(
                  label: _filters[i],
                  isActive: _activeFilter == _filters[i],
                  theme: widget.theme,
                  onTap: () => setState(() => _activeFilter = _filters[i]),
                ),
              ),
            ),

            // ── Fixed Section Header / Reorder Banner ────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isReordering
                  ? Container(
                      key: const ValueKey('reorder-bar'),
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D2352)
                            : NovaTokens.royal700.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: NovaTokens.royal700.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.drag_indicator_rounded,
                            size: 17,
                            color: isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Drag items to reorder',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.theme.text,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isReordering = false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Done',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      key: const ValueKey('normal-bar'),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            _activeFilter == 'All' ? 'All items' : _activeFilter,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.theme.muted,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${items.length}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.theme.muted,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? const Color(0x14FFFFFF) : const Color(0xFFE2E8F0),
            ),

            // ── Scrollable Items List ONLY ───────────────────
            Expanded(
              child: items.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: _EmptyState(
                          query: _searchQuery,
                          filter: _activeFilter,
                          theme: widget.theme,
                          onNewItem: widget.onNewItem,
                        ),
                      ),
                    )
                  : _isReordering
                      ? ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: EdgeInsets.fromLTRB(16, 10, 16, widget.bottomPadding),
                          itemCount: items.length,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 8,
                              shadowColor: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              child: child,
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            HapticFeedback.selectionClick();
                            VaultService().reorderFilteredItems(oldIndex, newIndex, items);
                          },
                          itemBuilder: (context, i) {
                            final item = items[i];
                            return Padding(
                              key: ValueKey(item.id),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ReorderableDragStartListener(
                                index: i,
                                child: _VaultListRow(
                                  item: item,
                                  theme: widget.theme,
                                  isCopied: _copiedId == item.id,
                                  isReordering: true,
                                  onTap: () {},
                                  onCopy: () {},
                                  onFavToggle: () {},
                                ),
                              ),
                            );
                          },
                        )
                      : RefreshIndicator(
                          color: NovaTokens.royal700,
                          onRefresh: () async {
                            if (AuthSyncService().isLoggedIn) {
                              await AuthSyncService().syncWithGoogleDrive(VaultService().items);
                            }
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: EdgeInsets.fromLTRB(16, 10, 16, widget.bottomPadding),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _VaultListRow(
                                  item: item,
                                  theme: widget.theme,
                                  isCopied: _copiedId == item.id,
                                  onTap: () => widget.onSelectItem(item),
                                  onLongPress: () {
                                    HapticFeedback.mediumImpact();
                                    setState(() => _isReordering = true);
                                  },
                                  onCopy: () => _copyPassword(item),
                                  onFavToggle: () {
                                    VaultService().toggleFavourite(item.id);
                                    setState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Sync chip widget
// ─────────────────────────────────────────────────────────
class _SyncChip extends StatelessWidget {
  final NovaTheme theme;
  const _SyncChip({required this.theme});

  @override
  Widget build(BuildContext context) {
    final authService = AuthSyncService();
    final isSignedIn = authService.isLoggedIn;

    return GestureDetector(
      onTap: () => GoogleSyncDialog.show(context, theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.selectedBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.selectedBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSignedIn
                    ? const Color(0xFF059669)
                    : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isSignedIn ? 'Synced' : 'Offline',              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.accent,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Search bar
// ─────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final NovaTheme theme;
  final ValueChanged<String> onChanged;
  const _SearchBar(
      {required this.controller,
      required this.theme,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x14FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child: Icon(Icons.search_rounded,
                size: 18, color: theme.muted),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.text,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search vault…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.muted,
                    fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded,
                    size: 16, color: theme.muted),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Vault health card
// ─────────────────────────────────────────────────────────
class _VaultHealthCard extends StatelessWidget {
  final NovaTheme theme;
  final VoidCallback? onTap;
  const _VaultHealthCard({required this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    final score = VaultService().vaultHealthScore;
    final weakCount = VaultService()
        .filteredItems
        .where((e) => e.password.isNotEmpty && e.password.length < 12)
        .length;

    final grade = score >= 90
        ? 'Excellent'
        : score >= 75
            ? 'Good'
            : score >= 60
                ? 'Fair'
                : 'Needs attention';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF051026), Color(0xFF0B3C8F)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x550B3C8F),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ring
            VaultHealthRing(
              score: score,
              size: 54,
              overrideTrack: const Color(0x33FFFFFF),
              overrideFill: Colors.white,
              overrideText: Colors.white,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vault Health',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    grade,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (weakCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFBC40),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '$weakCount weak password${weakCount > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFBC40),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Filter chip
// ─────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final NovaTheme theme;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.isActive,
      required this.theme,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF0B3C8F) : NovaTokens.royal700)
              : (isDark
                  ? const Color(0x14FFFFFF)
                  : const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0xFFE2E8F0)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : theme.muted,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Vault list row
// ─────────────────────────────────────────────────────────
class _VaultListRow extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final bool isCopied;
  final bool isReordering;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onCopy;
  final VoidCallback onFavToggle;

  const _VaultListRow({
    required this.item,
    required this.theme,
    required this.isCopied,
    this.isReordering = false,
    required this.onTap,
    this.onLongPress,
    required this.onCopy,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.isDark;
    final has2FA = item.totpSecret.isNotEmpty;
    final folder = item.folder.isNotEmpty ? item.folder : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isReordering ? null : onTap,
        onLongPress: isReordering ? null : onLongPress,
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.accent.withOpacity(0.06),
        highlightColor: theme.accent.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x0FFFFFFF)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0x1AFFFFFF)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              ItemAvatar(
                name: item.name,
                category: item.category,
                username: item.username,
                url: item.url,
                size: 40,
                radius: 10,
              ),
              const SizedBox(width: 12),
              // Name + username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.favourite) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFF0B3C8F)),
                        ],
                        if (has2FA) ...[
                          const SizedBox(width: 4),
                          _MicroBadge(
                              label: '2FA',
                              color: const Color(0xFF059669)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (item.username.isNotEmpty)
                          Flexible(
                            child: Text(
                              item.username,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.muted,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (folder != null && item.username.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 6),
                            child: _MicroBadge(
                                label: folder,
                                color: theme.accent),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Copy button or Drag handle in reorder mode
              if (isReordering)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.selectedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.selectedBorder, width: 1),
                  ),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: 18,
                    color: theme.accent,
                  ),
                )
              else
                GestureDetector(
                  onTap: onCopy,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCopied
                        ? const Color(0xFF059669).withOpacity(0.1)
                        : theme.selectedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCopied
                          ? const Color(0xFF059669).withOpacity(0.3)
                          : theme.selectedBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isCopied
                        ? Icons.check_rounded
                        : Icons.copy_rounded,
                    size: 15,
                    color: isCopied
                        ? const Color(0xFF059669)
                        : theme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Micro badge
// ─────────────────────────────────────────────────────────
class _MicroBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MicroBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  final String filter;
  final NovaTheme theme;
  final VoidCallback? onNewItem;
  const _EmptyState(
      {required this.query,
      required this.filter,
      required this.theme,
      this.onNewItem});

  @override
  Widget build(BuildContext context) {
    final isSearch = query.isNotEmpty;
    final isLoggedOut = !AuthSyncService().isLoggedIn && !isSearch;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.selectedBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSearch
                    ? Icons.search_off_rounded
                    : isLoggedOut
                        ? Icons.cloud_off_rounded
                        : Icons.lock_outline_rounded,
                size: 28,
                color: theme.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearch
                  ? 'No results'
                  : isLoggedOut
                      ? 'Sign in to sync vault'
                      : 'No items yet',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.text,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearch
                  ? 'Try a different search term'
                  : isLoggedOut
                      ? 'Connect your Google account to sync your encrypted vault across devices.'
                      : 'Add your first login, card or note',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.muted,
              ),
              textAlign: TextAlign.center,
            ),
            if (isLoggedOut) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => GoogleSyncDialog.show(context, theme),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: NovaTokens.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Sign in with Google',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!isSearch && onNewItem != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onNewItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: NovaTokens.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+ Add item',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
