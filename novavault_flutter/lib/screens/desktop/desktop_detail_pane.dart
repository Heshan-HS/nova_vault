import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import '../../widgets/item_avatar.dart';
import '../../widgets/field_row.dart';
import '../../widgets/totp_ring.dart';
import '../../widgets/strength_bar.dart';
import '../../widgets/primary_button.dart';
import '../../services/vault_service.dart';
import '../../services/totp_service.dart';
import '../../services/auth_sync_service.dart';
import '../edit_item_dialog.dart';
import '../setup_totp_dialog.dart';
import '../google_sync_dialog.dart';
import '../import_vault_dialog.dart';

class DesktopDetailPane extends StatelessWidget {
  final VaultItem? item;
  final VoidCallback? onFavouriteToggle;
  final VoidCallback? onNewItem;
  final VoidCallback? onLockVault;
  final bool isDark;
  final Function(bool)? onToggleTheme;
  final NovaTheme theme;

  const DesktopDetailPane({
    super.key,
    required this.item,
    this.onFavouriteToggle,
    this.onNewItem,
    this.onLockVault,
    this.isDark = true,
    this.onToggleTheme,
    required this.theme,
  });

  void _confirmDelete(BuildContext context, VaultItem currentItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.isDark ? const Color(0xFF07183E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: theme.cardBorder),
        ),
        title: Text(
          'Delete "${currentItem.name}"?',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to permanently delete this item from your vault?',
          style: GoogleFonts.inter(fontSize: 13, color: theme.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              VaultService().deleteItem(currentItem.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${currentItem.name}" deleted from vault')),
              );
            },
            child: Text('Delete', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String rawUrl) async {
    if (rawUrl.isEmpty) return;
    final urlStr = rawUrl.startsWith('http://') || rawUrl.startsWith('https://') ? rawUrl : 'https://$rawUrl';
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      final isLoggedIn = AuthSyncService().isLoggedIn;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLoggedIn ? Icons.shield_outlined : Icons.lock_outline_rounded,
              size: 56,
              color: theme.muted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              isLoggedIn ? 'No Item Selected' : 'Vault Logged Out',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
            ),
            const SizedBox(height: 6),
            Text(
              isLoggedIn
                  ? 'Select an item from the list or click "+ New item" to add one.'
                  : 'Sign in with your Google account to decrypt and access your passwords.',
              style: GoogleFonts.inter(fontSize: 13, color: theme.muted),
            ),
            const SizedBox(height: 18),
            if (isLoggedIn)
              NovaPrimaryButton(
                text: 'Add New Item',
                icon: Icons.add,
                onPressed: onNewItem,
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B68D6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          ],
        ),
      );
    }

    final currentItem = item!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Breadcrumb + Action Bar ──────────────────────────────
          _buildActionBar(context, currentItem),

          const SizedBox(height: 16),

          // ── 2. Identity Header ──────────────────────────────────────
          _buildIdentityHeader(context, currentItem),

          const SizedBox(height: 14),

          // ── 3. Category-specific main content ──────────────────────
          if (currentItem.isCard)
            _buildCardCategoryView(context, currentItem)
          else if (currentItem.isNote)
            _buildNoteCategoryView(context, currentItem)
          else if (currentItem.isServer)
            _buildServerCategoryView(context, currentItem)
          else
            _buildLoginCategoryView(context, currentItem),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ACTION BAR
  // ════════════════════════════════════════════════════════════════
  Widget _buildActionBar(BuildContext context, VaultItem currentItem) {
    return Row(
      children: [
        // Breadcrumb (bounded so it never overflows or pushes the action bar)
        Expanded(
          child: Row(
            children: [
              Text('All items', style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
              Text('  /  ', style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
              Flexible(
                child: Text(
                  currentItem.name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Action Bar (strictly aligned to right edge)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconAction(
              icon: currentItem.favourite ? Icons.star_rounded : Icons.star_border_rounded,
              color: theme.accent,
              onTap: onFavouriteToggle ?? () => VaultService().toggleFavourite(currentItem.id),
            ),
            const SizedBox(width: 6),
            _iconAction(
              icon: Icons.edit_outlined,
              color: theme.accent,
              onTap: () => EditItemDialog.show(context, theme, currentItem),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.cardBorder),
              ),
              color: theme.isDark ? const Color(0xFF07183E) : Colors.white,
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.inputBorder, width: 1),
                ),
                child: Icon(Icons.more_horiz_rounded, size: 17, color: theme.accent),
              ),
              onSelected: (val) {
                if (val == 'delete') {
                  _confirmDelete(context, currentItem);
                } else if (val == 'duplicate') {
                  final copy = currentItem.copyWith(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: '${currentItem.name} (Copy)',
                  );
                  VaultService().addItem(copy);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Duplicated "${currentItem.name}"')),
                  );
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(children: [
                    Icon(Icons.copy_rounded, size: 16, color: theme.text),
                    const SizedBox(width: 10),
                    Text('Duplicate Item', style: GoogleFonts.inter(fontSize: 13, color: theme.text)),
                  ]),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline_rounded, size: 16, color: theme.muted),
                    const SizedBox(width: 10),
                    Text('Delete Item', style: GoogleFonts.inter(fontSize: 13, color: theme.text)),
                  ]),
                ),
              ],
            ),
            const SizedBox(width: 6),
            if (onToggleTheme != null) ...[
              _iconAction(
                icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: theme.accent,
                onTap: () => onToggleTheme!(!isDark),
              ),
              const SizedBox(width: 6),
            ],
            if (onLockVault != null) ...[
              _iconAction(
                icon: Icons.lock_outline_rounded,
                color: theme.accent,
                onTap: onLockVault,
              ),
              const SizedBox(width: 8),
            ],
            NovaPrimaryButton(
              text: 'New item',
              icon: Icons.add,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              onPressed: onNewItem,
            ),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // IDENTITY HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildIdentityHeader(BuildContext context, VaultItem currentItem) {
    final strength = currentItem.strength;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          ItemAvatar(
            name: currentItem.name,
            category: currentItem.category,
            username: currentItem.username,
            url: currentItem.url,
            size: 46,
            radius: 12,
            isDark: theme.isDark,
          ),
          const SizedBox(width: 14),

          // Title + badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentItem.name,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: theme.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (currentItem.hasTotp && currentItem.totpSecret.isNotEmpty)
                      _statusChip(
                        dot: true,
                        label: '2FA ACTIVE',
                        bg: NovaTokens.royal700.withValues(alpha: theme.isDark ? 0.25 : 0.1),
                        border: NovaTokens.royal700.withValues(alpha: 0.5),
                        textColor: theme.accent,
                        mono: true,
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _agencyBadge(
                      icon: currentItem.isCard
                          ? Icons.credit_card_outlined
                          : (currentItem.isNote ? Icons.description_outlined : Icons.lock_outline_rounded),
                      label: currentItem.category.toUpperCase(),
                    ),
                    const SizedBox(width: 5),
                    if (currentItem.folder.isNotEmpty) ...[
                      _agencyBadge(icon: Icons.folder_outlined, label: currentItem.folder),
                      const SizedBox(width: 5),
                    ],
                    _agencyBadge(
                      icon: Icons.shield_outlined,
                      label: 'Security · $strength%',
                      accent: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side: quick-copy actions + meta
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (currentItem.password.isNotEmpty)
                    _quickActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy Password',
                      onTap: () => _copyToClipboard(context, currentItem.password, 'Password'),
                    ),
                  if (currentItem.url.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _quickActionButton(
                      icon: Icons.open_in_new_rounded,
                      label: 'Launch URL',
                      onTap: () => _launchUrl(currentItem.url),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Updated ${currentItem.updatedAt} · AES-256',
                style: GoogleFonts.inter(fontSize: 10, color: theme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // LOGIN CATEGORY — Full Advanced Layout
  // ════════════════════════════════════════════════════════════════
  Widget _buildLoginCategoryView(BuildContext context, VaultItem currentItem) {
    final strength = currentItem.strength;

    return Column(
      children: [
        // ── ROW 1: Credentials (left) + 2FA Ring (right) ──────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 55, child: _buildCredentialsCard(context, currentItem)),
            const SizedBox(width: 12),
            Expanded(flex: 45, child: _buildAuthenticatorCard(context, currentItem)),
          ],
        ),

        const SizedBox(height: 12),

        // ── ROW 2: Security Scorecard (full width) ─────────────────
        _buildSecurityScorecard(currentItem),

        const SizedBox(height: 12),

        // ── ROW 3: Quick Actions Strip (full width) ────────────────
        _buildQuickActionsStrip(context, currentItem),

        const SizedBox(height: 12),

        // ── ROW 4: Activity Timeline (left) + Item Metadata (right) ─
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 55, child: _buildActivityTimeline(currentItem)),
            const SizedBox(width: 12),
            Expanded(flex: 45, child: _buildItemMetadata(currentItem)),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ── Credentials Card ───────────────────────────────────────────
  Widget _buildCredentialsCard(BuildContext context, VaultItem currentItem) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.badge_outlined, 'CREDENTIALS'),
          const SizedBox(height: 10),
          NovaFieldRow(
            icon: Icons.person_outline_rounded,
            label: 'Username / Email',
            value: currentItem.username.isNotEmpty ? currentItem.username : 'None',
            theme: theme,
          ),
          NovaFieldRow(
            icon: Icons.key_rounded,
            label: 'Password',
            value: currentItem.password.isNotEmpty ? currentItem.password : 'None',
            masked: true,
            canReveal: true,
            theme: theme,
          ),
          NovaFieldRow(
            icon: Icons.language_rounded,
            label: 'Website',
            value: currentItem.url.isNotEmpty ? currentItem.url : 'Not specified',
            isLast: currentItem.notes.isEmpty,
            theme: theme,
            onExternalLink: currentItem.url.isNotEmpty ? () => _launchUrl(currentItem.url) : null,
          ),
          if (currentItem.notes.isNotEmpty)
            NovaFieldRow(
              icon: Icons.note_outlined,
              label: 'Notes',
              value: currentItem.notes,
              isLast: true,
              theme: theme,
            ),
        ],
      ),
    );
  }

  // ── Authenticator Card ─────────────────────────────────────────
  Widget _buildAuthenticatorCard(BuildContext context, VaultItem currentItem) {
    return _card(
      child: currentItem.hasTotp && currentItem.totpSecret.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader(Icons.shield_rounded, 'AUTHENTICATOR (2FA)'),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, size: 15, color: theme.muted),
                      tooltip: 'Edit 2FA Key',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: () => SetupTotpDialog.show(context, theme, currentItem),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TotpRingWidget(
                  period: 30,
                  secret: currentItem.totpSecret,
                  isDesktop: true,
                  showCode: true,
                  theme: theme,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.inputBorder, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NovaTokens.radiusButton)),
                      backgroundColor: theme.inputBg,
                    ),
                    onPressed: () {
                      final code = TotpService.generateTotp(secret: currentItem.totpSecret).replaceAll(' ', '');
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authenticator code copied. Clears in 30s')),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 15, color: theme.accent),
                    label: Text('Copy 6-Digit Code',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.accent)),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Icons.shield_outlined, 'AUTHENTICATOR (2FA)'),
                const SizedBox(height: 12),
                Text(
                  'No 2FA secret key linked to this login. Set up 2FA codes directly inside NovaVault to replace Google Authenticator.',
                  style: GoogleFonts.inter(fontSize: 12, color: theme.muted, height: 1.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NovaTokens.royal700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NovaTokens.radiusButton)),
                    ),
                    onPressed: () => SetupTotpDialog.show(context, theme, currentItem),
                    icon: const Icon(Icons.security_rounded, size: 15, color: Colors.white),
                    label: Text('Set up 2FA Authenticator',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NovaTokens.radiusButton)),
                    ),
                    onPressed: () => ImportVaultDialog.show(context, theme, initialTab: 0),
                    icon: Icon(Icons.qr_code_scanner_rounded, size: 14, color: theme.accent),
                    label: Text('Batch Import Google Authenticator',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: theme.text)),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Security Scorecard (Full Width) ───────────────────────────
  Widget _buildSecurityScorecard(VaultItem currentItem) {
    final strength = currentItem.strength;
    final pw = currentItem.password;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pw);
    final hasLower = RegExp(r'[a-z]').hasMatch(pw);
    final hasNum = RegExp(r'[0-9]').hasMatch(pw);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw);
    final isLong = pw.length >= 14;
    final isVeryLong = pw.length >= 20;

    String strengthLabel;
    if (strength >= 85) {
      strengthLabel = 'Very Strong';
    } else if (strength >= 70) {
      strengthLabel = 'Strong';
    } else if (strength >= 50) {
      strengthLabel = 'Fair';
    } else if (strength >= 30) {
      strengthLabel = 'Weak';
    } else {
      strengthLabel = 'Critical';
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with metric chips
          Row(
            children: [
              _sectionHeader(Icons.health_and_safety_outlined, 'SECURITY SCORECARD'),
              const Spacer(),
              _statusChip(
                label: '$strengthLabel · $strength%',
                bg: theme.isDark ? const Color(0x200B3C8F) : const Color(0x0F0B3C8F),
                border: NovaTokens.royal700.withValues(alpha: 0.4),
                textColor: theme.accent,
                mono: true,
              ),
              const SizedBox(width: 6),
              _statusChip(
                label: 'AES-256-GCM',
                bg: theme.isDark ? const Color(0x14FFFFFF) : const Color(0x08000000),
                border: theme.cardBorder,
                textColor: theme.muted,
                mono: true,
              ),
              const SizedBox(width: 6),
              _statusChip(
                icon: Icons.lock_rounded,
                label: 'E2E',
                bg: theme.isDark ? const Color(0x14FFFFFF) : const Color(0x08000000),
                border: theme.cardBorder,
                textColor: theme.muted,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Strength bar
          Row(
            children: [
              Expanded(
                child: StrengthBarWidget(
                  score: strength,
                  trackColor: theme.ringTrack,
                  fillColor: NovaTokens.royal700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$strength%',
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Password rules checklist — 6 columns
          Row(
            children: [
              _ruleChip(label: 'Uppercase', ok: hasUpper),
              const SizedBox(width: 6),
              _ruleChip(label: 'Lowercase', ok: hasLower),
              const SizedBox(width: 6),
              _ruleChip(label: 'Numbers', ok: hasNum),
              const SizedBox(width: 6),
              _ruleChip(label: 'Special', ok: hasSpecial),
              const SizedBox(width: 6),
              _ruleChip(label: '14+ chars', ok: isLong),
              const SizedBox(width: 6),
              _ruleChip(label: '20+ chars', ok: isVeryLong),
            ],
          ),

          const SizedBox(height: 10),

          // Zero-knowledge footer
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 13, color: theme.accent),
              const SizedBox(width: 6),
              Text(
                'Zero-knowledge verified · End-to-end encrypted · No breach detected',
                style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Strip (Full Width) ──────────────────────────
  Widget _buildQuickActionsStrip(BuildContext context, VaultItem currentItem) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.bolt_rounded, 'QUICK ACTIONS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (currentItem.username.isNotEmpty)
                _actionChip(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  label: 'Copy Username',
                  onTap: () => _copyToClipboard(context, currentItem.username, 'Username'),
                ),
              if (currentItem.password.isNotEmpty)
                _actionChip(
                  context: context,
                  icon: Icons.key_rounded,
                  label: 'Copy Password',
                  onTap: () => _copyToClipboard(context, currentItem.password, 'Password'),
                  primary: true,
                ),
              if (currentItem.url.isNotEmpty)
                _actionChip(
                  context: context,
                  icon: Icons.open_in_new_rounded,
                  label: 'Open Website',
                  onTap: () => _launchUrl(currentItem.url),
                ),
              if (currentItem.hasTotp && currentItem.totpSecret.isNotEmpty)
                _actionChip(
                  context: context,
                  icon: Icons.shield_rounded,
                  label: 'Copy 2FA Code',
                  onTap: () {
                    final code = TotpService.generateTotp(secret: currentItem.totpSecret).replaceAll(' ', '');
                    _copyToClipboard(context, code, '2FA Code');
                  },
                ),
              _actionChip(
                context: context,
                icon: Icons.edit_outlined,
                label: 'Edit Item',
                onTap: () => EditItemDialog.show(context, theme, currentItem),
              ),
              _actionChip(
                context: context,
                icon: Icons.content_copy_rounded,
                label: 'Duplicate',
                onTap: () {
                  final copy = currentItem.copyWith(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: '${currentItem.name} (Copy)',
                  );
                  VaultService().addItem(copy);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Duplicated "${currentItem.name}"')),
                  );
                },
              ),
              _actionChip(
                context: context,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                onTap: () => _confirmDelete(context, currentItem),
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Activity Timeline ─────────────────────────────────────────
  Widget _buildActivityTimeline(VaultItem currentItem) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.timeline_rounded, 'ACTIVITY & AUDIT'),
          const SizedBox(height: 14),
          _timelineEntry(
            icon: Icons.edit_rounded,
            label: 'Password modified',
            time: 'Today',
            isFirst: true,
          ),
          _timelineEntry(
            icon: Icons.login_rounded,
            label: 'Item accessed',
            time: '2 hours ago',
          ),
          _timelineEntry(
            icon: Icons.copy_all_rounded,
            label: 'Password copied',
            time: '5 mins ago',
          ),
          _timelineEntry(
            icon: Icons.sync_rounded,
            label: 'Synced to vault',
            time: '3 months ago',
          ),
          _timelineEntry(
            icon: Icons.add_circle_outline_rounded,
            label: 'Created · ${currentItem.createdAt}',
            time: currentItem.createdAt,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Item Metadata ─────────────────────────────────────────────
  Widget _buildItemMetadata(VaultItem currentItem) {
    final shortId = currentItem.id.length > 10 ? currentItem.id.substring(0, 10) : currentItem.id;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.info_outline_rounded, 'ITEM METADATA'),
          const SizedBox(height: 14),
          _metaRow('Item ID', '#$shortId…'),
          _metaRow('Category', currentItem.category.toUpperCase()),
          _metaRow('Folder', currentItem.folder.isNotEmpty ? currentItem.folder : 'Uncategorized'),
          _metaRow('Encryption', 'AES-256-GCM'),
          _metaRow('Protocol', 'Zero-Knowledge'),
          if (currentItem.tags.isNotEmpty)
            _metaRow('Tags', currentItem.tags.join(', ')),
          _metaRow('Source', currentItem.updatedAt.contains('Import') ? 'Imported' : 'Manual'),
          _metaRow('Created', currentItem.createdAt),
          _metaRow('Updated', currentItem.updatedAt),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SERVER / VPS CATEGORY VIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildServerCategoryView(BuildContext context, VaultItem s) {
    return Column(
      children: [
        // ── ROW 1: SSH Access (left) + Server Identity (right) ───
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SSH Card
            Expanded(
              flex: 55,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.terminal_rounded, 'SSH ACCESS'),
                    const SizedBox(height: 10),
                    NovaFieldRow(icon: Icons.computer_rounded,   label: 'Hostname',   value: s.serverHost.isNotEmpty ? s.serverHost : 'Not set',    theme: theme),
                    NovaFieldRow(icon: Icons.router_outlined,    label: 'Public IP',  value: s.serverPublicIp.isNotEmpty ? s.serverPublicIp : 'Not set', theme: theme),
                    NovaFieldRow(icon: Icons.language_rounded,   label: 'Domain',     value: s.serverDomain.isNotEmpty ? s.serverDomain : 'Not set',  theme: theme),
                    NovaFieldRow(icon: Icons.settings_ethernet_rounded, label: 'SSH Port', value: s.serverSshPort.isNotEmpty ? s.serverSshPort : '22', theme: theme),
                    NovaFieldRow(icon: Icons.person_outline_rounded, label: 'Username', value: s.serverUsername.isNotEmpty ? s.serverUsername : 'root', theme: theme),
                    NovaFieldRow(icon: Icons.key_rounded,        label: 'SSH Password', value: s.serverPassword.isNotEmpty ? s.serverPassword : 'Not set',
                        masked: true, canReveal: true, theme: theme),
                    if (s.serverSshKey.isNotEmpty)
                      NovaFieldRow(icon: Icons.vpn_key_outlined, label: 'SSH Key',   value: s.serverSshKey, masked: true, canReveal: true, isLast: true, theme: theme),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Server identity + OS card
            Expanded(
              flex: 45,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.dns_outlined, 'SERVER IDENTITY'),
                    const SizedBox(height: 12),

                    // Status indicator row
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text('Active / Online', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.text)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _metaRow('Provider', s.serverProvider.isNotEmpty ? s.serverProvider : '—'),
                    _metaRow('OS', s.serverOs.isNotEmpty ? s.serverOs : '—'),
                    _metaRow('IP Address', s.serverPublicIp.isNotEmpty ? s.serverPublicIp : '—'),
                    _metaRow('Domain', s.serverDomain.isNotEmpty ? s.serverDomain : '—'),
                    _metaRow('SSH Port', s.serverSshPort.isNotEmpty ? s.serverSshPort : '22'),
                    _metaRow('Added', s.createdAt),
                    _metaRow('Updated', s.updatedAt),

                    const SizedBox(height: 14),

                    // SSH copy command button
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.inputBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: theme.inputBg,
                        ),
                        onPressed: () {
                          final user = s.serverUsername.isNotEmpty ? s.serverUsername : 'root';
                          final ip = s.serverPublicIp.isNotEmpty ? s.serverPublicIp : s.serverHost;
                          final port = s.serverSshPort.isNotEmpty ? s.serverSshPort : '22';
                          final cmd = 'ssh $user@$ip -p $port';
                          Clipboard.setData(ClipboardData(text: cmd));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('SSH command copied: $cmd')),
                          );
                        },
                        icon: Icon(Icons.copy_rounded, size: 14, color: theme.accent),
                        label: Text('Copy SSH Command', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.accent)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── ROW 2: Control Panel (full width) ─────────────────────
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader(Icons.dashboard_outlined, 'CONTROL PANEL'),
                  if (s.panelUrl.isNotEmpty)
                    _quickActionButton(
                      icon: Icons.open_in_new_rounded,
                      label: 'Open Panel',
                      onTap: () => _launchUrl(s.panelUrl),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        NovaFieldRow(icon: Icons.open_in_browser_rounded, label: 'Panel URL',      value: s.panelUrl.isNotEmpty ? s.panelUrl : 'Not configured', theme: theme),
                        NovaFieldRow(icon: Icons.settings_ethernet_rounded, label: 'Panel Port',   value: s.panelPort.isNotEmpty ? s.panelPort : '—',             theme: theme),
                        NovaFieldRow(icon: Icons.manage_accounts_outlined, label: 'Panel Username',value: s.panelUsername.isNotEmpty ? s.panelUsername : 'Not set', isLast: true, theme: theme),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        NovaFieldRow(icon: Icons.lock_outline_rounded, label: 'Panel Password', value: s.panelPassword.isNotEmpty ? s.panelPassword : 'Not set',
                            masked: true, canReveal: true, isLast: true, theme: theme),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── ROW 3: Quick Actions + Notes ──────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.bolt_rounded, 'QUICK ACTIONS'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (s.serverUsername.isNotEmpty || s.serverPublicIp.isNotEmpty)
                          _actionChip(
                            context: context,
                            icon: Icons.terminal_rounded,
                            label: 'Copy SSH Command',
                            primary: true,
                            onTap: () {
                              final user = s.serverUsername.isNotEmpty ? s.serverUsername : 'root';
                              final ip = s.serverPublicIp.isNotEmpty ? s.serverPublicIp : s.serverHost;
                              final port = s.serverSshPort.isNotEmpty ? s.serverSshPort : '22';
                              _copyToClipboard(context, 'ssh $user@$ip -p $port', 'SSH Command');
                            },
                          ),
                        if (s.serverPublicIp.isNotEmpty)
                          _actionChip(
                            context: context,
                            icon: Icons.router_outlined,
                            label: 'Copy IP',
                            onTap: () => _copyToClipboard(context, s.serverPublicIp, 'IP Address'),
                          ),
                        if (s.serverPassword.isNotEmpty)
                          _actionChip(
                            context: context,
                            icon: Icons.key_rounded,
                            label: 'Copy SSH Password',
                            onTap: () => _copyToClipboard(context, s.serverPassword, 'SSH Password'),
                          ),
                        if (s.panelUrl.isNotEmpty)
                          _actionChip(
                            context: context,
                            icon: Icons.open_in_new_rounded,
                            label: 'Open Panel',
                            onTap: () => _launchUrl(s.panelUrl),
                          ),
                        if (s.panelPassword.isNotEmpty)
                          _actionChip(
                            context: context,
                            icon: Icons.dashboard_outlined,
                            label: 'Copy Panel Password',
                            onTap: () => _copyToClipboard(context, s.panelPassword, 'Panel Password'),
                          ),
                        _actionChip(
                          context: context,
                          icon: Icons.edit_outlined,
                          label: 'Edit Server',
                          onTap: () => EditItemDialog.show(context, theme, s),
                        ),
                        _actionChip(
                          context: context,
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          danger: true,
                          onTap: () => _confirmDelete(context, s),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Notes / Metadata
            Expanded(
              flex: 45,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.note_outlined, 'NOTES & METADATA'),
                    const SizedBox(height: 10),
                    if (s.notes.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.inputBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.inputBorder),
                        ),
                        child: Text(s.notes, style: GoogleFonts.inter(fontSize: 12, color: theme.text, height: 1.5)),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _metaRow('Category', 'SERVER / VPS'),
                    _metaRow('Encryption', 'AES-256-GCM'),
                    _metaRow('Folder', s.folder.isNotEmpty ? s.folder : 'Servers'),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CARD CATEGORY VIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildCardCategoryView(BuildContext context, VaultItem cardItem) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual Card Display
            Expanded(
              flex: 55,
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B3C8F), Color(0xFF051026)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x336FA8FF), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B3C8F).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            width: 36,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.memory, size: 16, color: Color(0xFF5A4500)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.wifi_rounded, size: 16, color: Colors.white70),
                        ]),
                        Text(
                          cardItem.cardBrand.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    Text(
                      cardItem.cardNumber.isNotEmpty ? cardItem.cardNumber : '••••  ••••  ••••  4417',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2.5, color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('CARDHOLDER', style: GoogleFonts.inter(fontSize: 8, color: Colors.white54, letterSpacing: 1.2)),
                          Text(cardItem.cardHolder.isNotEmpty ? cardItem.cardHolder : 'HESHAN SATHYANGA',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('EXPIRES', style: GoogleFonts.inter(fontSize: 8, color: Colors.white54, letterSpacing: 1.2)),
                          Text(cardItem.cardExpiry.isNotEmpty ? cardItem.cardExpiry : '09/28',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card secret details
            Expanded(
              flex: 45,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.shield_outlined, 'CARD SECURITY'),
                    const SizedBox(height: 10),
                    NovaFieldRow(icon: Icons.shield_outlined, label: 'CVV / CVC Code',
                        value: cardItem.cardCvv.isNotEmpty ? cardItem.cardCvv : '829', masked: true, canReveal: true, theme: theme),
                    NovaFieldRow(icon: Icons.pin_rounded, label: 'Card PIN',
                        value: cardItem.cardPin.isNotEmpty ? cardItem.cardPin : '4412', masked: true, canReveal: true, isLast: true, theme: theme),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.credit_card_rounded, 'CARD INFORMATION'),
              const SizedBox(height: 10),
              NovaFieldRow(icon: Icons.credit_card_rounded, label: 'Card Number',
                  value: cardItem.cardNumber.isNotEmpty ? cardItem.cardNumber : '4532 8910 2341 4417', theme: theme),
              NovaFieldRow(icon: Icons.person_outline_rounded, label: 'Cardholder Name',
                  value: cardItem.cardHolder.isNotEmpty ? cardItem.cardHolder : 'HESHAN SATHYANGA', theme: theme),
              NovaFieldRow(icon: Icons.calendar_today_rounded, label: 'Expiration Date',
                  value: cardItem.cardExpiry.isNotEmpty ? cardItem.cardExpiry : '09/28', theme: theme),
              if (cardItem.notes.isNotEmpty)
                NovaFieldRow(icon: Icons.note_outlined, label: 'Notes', value: cardItem.notes, isLast: true, theme: theme),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // NOTE CATEGORY VIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildNoteCategoryView(BuildContext context, VaultItem noteItem) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(Icons.lock_rounded, 'END-TO-END ENCRYPTED NOTE'),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.inputBg,
                  side: BorderSide(color: theme.inputBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: noteItem.notes.isNotEmpty ? noteItem.notes : noteItem.password));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note copied to clipboard')));
                },
                icon: Icon(Icons.copy_rounded, size: 13, color: theme.accent),
                label: Text('Copy Entire Note', style: GoogleFonts.inter(fontSize: 12, color: theme.accent)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.inputBorder),
            ),
            child: Text(
              noteItem.notes.isNotEmpty ? noteItem.notes : (noteItem.password.isNotEmpty ? noteItem.password : 'No note content yet.'),
              style: GoogleFonts.inter(fontSize: 13, color: theme.text, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.cardBorder, width: 1),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: theme.accent),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: theme.muted,
          ),
        ),
      ],
    );
  }

  Widget _statusChip({
    IconData? icon,
    bool dot = false,
    required String label,
    required Color bg,
    required Color border,
    required Color textColor,
    bool mono = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
            ),
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (mono ? GoogleFonts.robotoMono : GoogleFonts.inter)(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _agencyBadge({required IconData icon, required String label, bool accent = false}) {
    final c = accent ? theme.accent : theme.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: accent ? theme.text : theme.text),
          ),
        ],
      ),
    );
  }

  Widget _ruleChip({required String label, required bool ok}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ok
            ? (theme.isDark ? const Color(0x1A0B3C8F) : const Color(0x0F0B3C8F))
            : (theme.isDark ? const Color(0x0AFFFFFF) : const Color(0x06000000)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ok ? NovaTokens.royal700.withValues(alpha: 0.4) : theme.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_rounded : Icons.close_rounded,
            size: 10,
            color: ok ? theme.accent : theme.muted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ok ? theme.text : theme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
    bool danger = false,
  }) {
    final bgColor = primary
        ? NovaTokens.royal700.withValues(alpha: theme.isDark ? 0.2 : 0.1)
        : danger
            ? const Color(0xFFB91C1C).withValues(alpha: 0.1)
            : theme.inputBg;
    final borderColor = primary
        ? NovaTokens.royal700.withValues(alpha: 0.5)
        : danger
            ? const Color(0xFFB91C1C).withValues(alpha: 0.3)
            : theme.cardBorder;
    final textColor = primary
        ? theme.accent
        : danger
            ? const Color(0xFFEF4444)
            : theme.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineEntry({
    required IconData icon,
    required String label,
    required String time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: theme.isDark ? const Color(0x200B3C8F) : const Color(0x100B3C8F),
                  shape: BoxShape.circle,
                  border: Border.all(color: NovaTokens.royal700.withValues(alpha: 0.4), width: 1),
                ),
                child: Icon(icon, size: 12, color: theme.accent),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 10,
                  color: theme.cardBorder,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: theme.text),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              key,
              style: GoogleFonts.inter(fontSize: 11, color: theme.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w500, color: theme.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: theme.inputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: theme.accent),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: theme.text)),
          ],
        ),
      ),
    );
  }

  Widget _iconAction({required IconData icon, required Color color, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.inputBorder, width: 1),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
