import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import '../../widgets/item_avatar.dart';
import '../../widgets/totp_ring.dart';
import '../../services/vault_service.dart';
import '../edit_item_dialog.dart';
import '../setup_totp_dialog.dart';

class MobileItemDetail extends StatefulWidget {
  final VaultItem item;
  final VoidCallback onBack;
  final NovaTheme theme;
  final double bottomPadding;

  const MobileItemDetail({
    super.key,
    required this.item,
    required this.onBack,
    required this.theme,
    this.bottomPadding = 80,
  });

  @override
  State<MobileItemDetail> createState() => _MobileItemDetailState();
}

class _MobileItemDetailState extends State<MobileItemDetail> {
  late VaultItem _item;
  final Map<String, bool> _revealed = {};
  final Map<String, bool> _copied = {};

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _launchUrl(String raw) async {
    if (raw.isEmpty) return;
    final s = raw.startsWith('http') ? raw : 'https://$raw';
    try {
      final uri = Uri.parse(s);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _copy(String fieldKey, String value) {
    if (value.isEmpty) return;
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: value));
    setState(() => _copied[fieldKey] = true);
    _showToast('Copied to clipboard');
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied.remove(fieldKey));
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 15),
          const SizedBox(width: 8),
          Text(message,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
        ]),
        backgroundColor: const Color(0xFF0B3C8F),
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.fromLTRB(16, 0, 16, widget.bottomPadding - 20),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1600),
        elevation: 0,
      ),
    );
  }

  void _toggleReveal(String key) =>
      setState(() => _revealed[key] = !(_revealed[key] ?? false));

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final score = item.strength;
    final has2FA = item.totpSecret.isNotEmpty;
    final scoreColor = score >= 80
        ? const Color(0xFF059669)
        : score >= 60
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Gradient Header ──────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            actions: [
              // Favourite
              GestureDetector(
                onTap: () {
                  VaultService().toggleFavourite(item.id);
                  setState(() => _item = _item.copyWith(
                      favourite: !_item.favourite));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _item.favourite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 18,
                    color:
                        _item.favourite ? const Color(0xFFFFBC40) : Colors.white,
                  ),
                ),
              ),
              // Edit
              GestureDetector(
                onTap: () =>
                    EditItemDialog.show(context, widget.theme, item),
                child: Container(
                  margin:
                      const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF051026), Color(0xFF0B3C8F)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ItemAvatar(
                          name: item.name,
                          category: item.category,
                          username: item.username,
                          url: item.url,
                          size: 56,
                          radius: 14,
                          isHero: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _HeaderChip(
                                      label: item.category.toUpperCase()),
                                  if (item.folder.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    _HeaderChip(label: item.folder),
                                  ],
                                  if (has2FA) ...[
                                    const SizedBox(width: 6),
                                    _HeaderChip(
                                        label: '2FA ACTIVE',
                                        color: const Color(0xFF059669)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Strength bar mini
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: score / 100,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                scoreColor),
                                        minHeight: 3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Security · $score%',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.7),
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
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, widget.bottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick actions bar
                _QuickActionsBar(
                  item: item,
                  theme: widget.theme,
                  onCopy: _copy,
                  onLaunch: _launchUrl,
                ),
                const SizedBox(height: 14),

                // ── Login section
                if (item.isLogin || (item.username.isNotEmpty)) ...[
                  _SectionLabel(label: 'CREDENTIALS', theme: widget.theme),
                  const SizedBox(height: 8),
                  _CredentialsCard(
                    item: item,
                    theme: widget.theme,
                    revealed: _revealed,
                    copied: _copied,
                    onCopy: _copy,
                    onToggleReveal: _toggleReveal,
                  ),
                  const SizedBox(height: 14),
                ],

                // ── 2FA section
                if (item.isLogin || item.isServer) ...[
                  _SectionLabel(label: 'AUTHENTICATOR', theme: widget.theme),
                  const SizedBox(height: 8),
                  if (has2FA)
                    _TotpCard(item: item, theme: widget.theme, onCopy: _copy)
                  else
                    _Setup2FACard(item: item, theme: widget.theme),
                  const SizedBox(height: 14),
                ],

                // ── Server section
                if (item.isServer) ...[
                  _SectionLabel(label: 'SERVER ACCESS', theme: widget.theme),
                  const SizedBox(height: 8),
                  _ServerCard(
                    item: item,
                    theme: widget.theme,
                    revealed: _revealed,
                    copied: _copied,
                    onCopy: _copy,
                    onToggleReveal: _toggleReveal,
                    onLaunch: _launchUrl,
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Card section
                if (item.isCard) ...[
                  _SectionLabel(label: 'CARD DETAILS', theme: widget.theme),
                  const SizedBox(height: 8),
                  _CardDetailsCard(
                    item: item,
                    theme: widget.theme,
                    revealed: _revealed,
                    copied: _copied,
                    onCopy: _copy,
                    onToggleReveal: _toggleReveal,
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Security scorecard
                _SectionLabel(label: 'SECURITY', theme: widget.theme),
                const SizedBox(height: 8),
                _SecurityCard(item: item, theme: widget.theme),
                const SizedBox(height: 14),

                // ── Notes
                if (item.notes.isNotEmpty) ...[
                  _SectionLabel(label: 'NOTES', theme: widget.theme),
                  const SizedBox(height: 8),
                  _NotesCard(item: item, theme: widget.theme),
                  const SizedBox(height: 14),
                ],

                // ── Metadata
                _SectionLabel(label: 'ITEM INFO', theme: widget.theme),
                const SizedBox(height: 8),
                _MetaCard(item: item, theme: widget.theme),
                const SizedBox(height: 20),

                // ── Danger zone
                _DangerCard(
                  item: item,
                  theme: widget.theme,
                  onDelete: () {
                    VaultService().deleteItem(item.id);
                    widget.onBack();
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Header chip
// ─────────────────────────────────────────────────────────
class _HeaderChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _HeaderChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color ?? Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Section label
// ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final NovaTheme theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: theme.muted,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Card wrapper
// ─────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final NovaTheme theme;
  final EdgeInsets? padding;

  const _Card(
      {required this.child, required this.theme, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: theme.isDark
            ? const Color(0x0FFFFFFF)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.isDark
              ? const Color(0x1AFFFFFF)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Quick actions bar
// ─────────────────────────────────────────────────────────
class _QuickActionsBar extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final Function(String, String) onCopy;
  final Function(String) onLaunch;

  const _QuickActionsBar({
    required this.item,
    required this.theme,
    required this.onCopy,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickBtn(
          icon: Icons.copy_rounded,
          label: 'Copy Password',
          theme: theme,
          isPrimary: true,
          onTap: () => onCopy('password', item.password),
        ),
        const SizedBox(width: 8),
        if (item.url.isNotEmpty)
          _QuickBtn(
            icon: Icons.open_in_new_rounded,
            label: 'Launch URL',
            theme: theme,
            onTap: () => onLaunch(item.url),
          ),
        if (item.url.isNotEmpty) const SizedBox(width: 8),
        _QuickBtn(
          icon: Icons.person_outline_rounded,
          label: 'Copy Username',
          theme: theme,
          onTap: () => onCopy('username', item.username),
        ),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final NovaTheme theme;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isPrimary ? NovaTokens.brandGradient : null,
            color: isPrimary ? null : theme.selectedBg,
            borderRadius: BorderRadius.circular(10),
            border: isPrimary
                ? null
                : Border.all(color: theme.selectedBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: isPrimary ? Colors.white : theme.accent),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : theme.accent,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Credentials card
// ─────────────────────────────────────────────────────────
class _CredentialsCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final Map<String, bool> revealed;
  final Map<String, bool> copied;
  final Function(String, String) onCopy;
  final Function(String) onToggleReveal;

  const _CredentialsCard({
    required this.item,
    required this.theme,
    required this.revealed,
    required this.copied,
    required this.onCopy,
    required this.onToggleReveal,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      theme: theme,
      child: Column(
        children: [
          if (item.username.isNotEmpty)
            _FieldRow(
              icon: Icons.person_outline_rounded,
              label: 'Username / Email',
              value: item.username,
              fieldKey: 'username',
              theme: theme,
              revealed: revealed,
              copied: copied,
              onCopy: onCopy,
              onToggleReveal: onToggleReveal,
              isLast: item.password.isEmpty && item.url.isEmpty,
            ),
          if (item.password.isNotEmpty)
            _FieldRow(
              icon: Icons.key_outlined,
              label: 'Password',
              value: item.password,
              fieldKey: 'password',
              theme: theme,
              revealed: revealed,
              copied: copied,
              onCopy: onCopy,
              onToggleReveal: onToggleReveal,
              isSecret: true,
              isLast: item.url.isEmpty,
            ),
          if (item.url.isNotEmpty)
            _FieldRow(
              icon: Icons.language_rounded,
              label: 'Website',
              value: item.url,
              fieldKey: 'url',
              theme: theme,
              revealed: revealed,
              copied: copied,
              onCopy: onCopy,
              onToggleReveal: onToggleReveal,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Reusable field row
// ─────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String fieldKey;
  final NovaTheme theme;
  final Map<String, bool> revealed;
  final Map<String, bool> copied;
  final Function(String, String) onCopy;
  final Function(String) onToggleReveal;
  final bool isSecret;
  final bool isLast;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldKey,
    required this.theme,
    required this.revealed,
    required this.copied,
    required this.onCopy,
    required this.onToggleReveal,
    this.isSecret = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRev = revealed[fieldKey] == true;
    final isCopied = copied[fieldKey] == true;
    final displayValue =
        isSecret && !isRev ? '•' * value.length.clamp(8, 18) : value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.selectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: theme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayValue,
                      style: GoogleFonts.inter(
                        fontSize: isSecret && !isRev ? 16 : 13,
                        fontWeight: FontWeight.w500,
                        color: theme.text,
                        letterSpacing:
                            isSecret && !isRev ? 2 : 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Reveal button
              if (isSecret)
                GestureDetector(
                  onTap: () => onToggleReveal(fieldKey),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.selectedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isRev
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 15,
                      color: theme.muted,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              // Copy button
              GestureDetector(
                onTap: () => onCopy(fieldKey, value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCopied
                        ? const Color(0xFF059669).withOpacity(0.1)
                        : theme.selectedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: isCopied
                        ? Border.all(
                            color: const Color(0xFF059669).withOpacity(0.3),
                            width: 1)
                        : null,
                  ),
                  child: Icon(
                    isCopied ? Icons.check_rounded : Icons.copy_rounded,
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
        if (!isLast)
          Divider(
              height: 1,
              thickness: 1,
              color: theme.isDark
                  ? const Color(0x0FFFFFFF)
                  : const Color(0xFFF1F5F9)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TOTP card
// ─────────────────────────────────────────────────────────
class _TotpCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final Function(String, String) onCopy;

  const _TotpCard(
      {required this.item, required this.theme, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return _Card(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: TotpRingWidget(
        secret: item.totpSecret,
        isDesktop: false,
        showCode: true,
        theme: theme,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Setup 2FA card
// ─────────────────────────────────────────────────────────
class _Setup2FACard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;

  const _Setup2FACard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return _Card(
      theme: theme,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.selectedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield_outlined, size: 16, color: theme.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Two-Factor Authentication',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.text)),
                Text('Not configured',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: theme.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => SetupTotpDialog.show(context, theme, item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: NovaTokens.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Set up',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Server card
// ─────────────────────────────────────────────────────────
class _ServerCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final Map<String, bool> revealed;
  final Map<String, bool> copied;
  final Function(String, String) onCopy;
  final Function(String) onToggleReveal;
  final Function(String) onLaunch;

  const _ServerCard({
    required this.item,
    required this.theme,
    required this.revealed,
    required this.copied,
    required this.onCopy,
    required this.onToggleReveal,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <Map<String, dynamic>>[
      if (item.serverHost.isNotEmpty)
        {'icon': Icons.dns_outlined, 'label': 'Hostname', 'value': item.serverHost, 'key': 'sHost'},
      if (item.serverPublicIp.isNotEmpty)
        {'icon': Icons.wifi_rounded, 'label': 'Public IP', 'value': item.serverPublicIp, 'key': 'sIp'},
      if (item.serverDomain.isNotEmpty)
        {'icon': Icons.language_rounded, 'label': 'Domain', 'value': item.serverDomain, 'key': 'sDomain'},
      if (item.serverSshPort.isNotEmpty)
        {'icon': Icons.settings_ethernet_rounded, 'label': 'SSH Port', 'value': item.serverSshPort, 'key': 'sPort'},
      if (item.serverUsername.isNotEmpty)
        {'icon': Icons.person_outline_rounded, 'label': 'SSH Username', 'value': item.serverUsername, 'key': 'sUser'},
      if (item.serverPassword.isNotEmpty)
        {'icon': Icons.key_outlined, 'label': 'SSH Password', 'value': item.serverPassword, 'key': 'sPass', 'secret': true},
      if (item.panelUrl.isNotEmpty)
        {'icon': Icons.web_rounded, 'label': 'Panel URL', 'value': item.panelUrl, 'key': 'pUrl'},
      if (item.panelUsername.isNotEmpty)
        {'icon': Icons.admin_panel_settings_outlined, 'label': 'Panel Username', 'value': item.panelUsername, 'key': 'pUser'},
      if (item.panelPassword.isNotEmpty)
        {'icon': Icons.lock_outline_rounded, 'label': 'Panel Password', 'value': item.panelPassword, 'key': 'pPass', 'secret': true},
    ];

    if (fields.isEmpty) {
      return _Card(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: Text('No server fields configured.',
            style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
      );
    }

    return _Card(
      theme: theme,
      child: Column(
        children: fields.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          return _FieldRow(
            icon: f['icon'] as IconData,
            label: f['label'] as String,
            value: f['value'] as String,
            fieldKey: f['key'] as String,
            theme: theme,
            revealed: revealed,
            copied: copied,
            onCopy: onCopy,
            onToggleReveal: onToggleReveal,
            isSecret: f['secret'] == true,
            isLast: i == fields.length - 1,
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Card details
// ─────────────────────────────────────────────────────────
class _CardDetailsCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final Map<String, bool> revealed;
  final Map<String, bool> copied;
  final Function(String, String) onCopy;
  final Function(String) onToggleReveal;

  const _CardDetailsCard({
    required this.item,
    required this.theme,
    required this.revealed,
    required this.copied,
    required this.onCopy,
    required this.onToggleReveal,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <Map<String, dynamic>>[
      if (item.cardHolder.isNotEmpty)
        {'icon': Icons.badge_outlined, 'label': 'Card Holder', 'value': item.cardHolder, 'key': 'cHolder'},
      if (item.cardNumber.isNotEmpty)
        {'icon': Icons.credit_card_rounded, 'label': 'Card Number', 'value': item.cardNumber, 'key': 'cNum', 'secret': true},
      if (item.cardExpiry.isNotEmpty)
        {'icon': Icons.date_range_outlined, 'label': 'Expiry', 'value': item.cardExpiry, 'key': 'cExp'},
      if (item.cardCvv.isNotEmpty)
        {'icon': Icons.lock_outline_rounded, 'label': 'CVV', 'value': item.cardCvv, 'key': 'cCvv', 'secret': true},
      if (item.cardPin.isNotEmpty)
        {'icon': Icons.dialpad_rounded, 'label': 'PIN', 'value': item.cardPin, 'key': 'cPin', 'secret': true},
    ];

    return _Card(
      theme: theme,
      child: Column(
        children: fields.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          return _FieldRow(
            icon: f['icon'] as IconData,
            label: f['label'] as String,
            value: f['value'] as String,
            fieldKey: f['key'] as String,
            theme: theme,
            revealed: revealed,
            copied: copied,
            onCopy: onCopy,
            onToggleReveal: onToggleReveal,
            isSecret: f['secret'] == true,
            isLast: i == fields.length - 1,
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Security scorecard
// ─────────────────────────────────────────────────────────
class _SecurityCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;

  const _SecurityCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final score = item.strength;
    final password = item.password;
    if (password.isEmpty) {
      return _Card(
        theme: theme,
        padding: const EdgeInsets.all(14),
        child: Text('No password to analyze.',
            style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
      );
    }

    final checks = <Map<String, dynamic>>[
      {
        'label': 'Uppercase',
        'pass': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'label': 'Lowercase',
        'pass': RegExp(r'[a-z]').hasMatch(password),
      },
      {
        'label': 'Numbers',
        'pass': RegExp(r'[0-9]').hasMatch(password),
      },
      {
        'label': 'Symbols',
        'pass': RegExp(r'[!@#\$%^&*]').hasMatch(password),
      },
      {
        'label': '14+ chars',
        'pass': password.length >= 14,
      },
      {
        'label': '20+ chars',
        'pass': password.length >= 20,
      },
    ];

    final scoreColor = score >= 80
        ? const Color(0xFF059669)
        : score >= 60
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    return _Card(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: theme.isDark
                        ? const Color(0x1FFFFFFF)
                        : const Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$score%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: checks.map((c) {
              final pass = c['pass'] as bool;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pass
                      ? const Color(0xFF059669).withOpacity(0.08)
                      : theme.isDark
                          ? const Color(0x0FFFFFFF)
                          : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: pass
                        ? const Color(0xFF059669).withOpacity(0.25)
                        : theme.isDark
                            ? const Color(0x1AFFFFFF)
                            : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pass
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 11,
                      color: pass
                          ? const Color(0xFF059669)
                          : theme.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            pass ? const Color(0xFF059669) : theme.muted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Notes card
// ─────────────────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  const _NotesCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return _Card(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Text(
        item.notes,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: theme.text,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Metadata card
// ─────────────────────────────────────────────────────────
class _MetaCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  const _MetaCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Category', 'value': item.category},
      if (item.folder.isNotEmpty) {'label': 'Folder', 'value': item.folder},
      {'label': 'Created', 'value': item.createdAt},
      {'label': 'Updated', 'value': item.updatedAt},
      {'label': 'Encryption', 'value': 'AES-256-GCM'},
    ];

    return _Card(
      theme: theme,
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      r['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      r['value']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.isDark
                      ? const Color(0x0AFFFFFF)
                      : const Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Danger zone
// ─────────────────────────────────────────────────────────
class _DangerCard extends StatelessWidget {
  final VaultItem item;
  final NovaTheme theme;
  final VoidCallback onDelete;
  const _DangerCard(
      {required this.item,
      required this.theme,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFDC2626).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline_rounded,
                size: 18, color: const Color(0xFFDC2626)),
            const SizedBox(width: 10),
            Text(
              'Delete item',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC2626),
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: const Color(0xFFDC2626).withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDark ? const Color(0xFF0D1629) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    size: 26, color: Color(0xFFDC2626)),
              ),
              const SizedBox(height: 14),
              Text('Delete "${item.name}"?',
                  style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: theme.text),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('This action cannot be undone.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: theme.muted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: theme.selectedBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: theme.selectedBorder),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        onDelete();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Delete',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
