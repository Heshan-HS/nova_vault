import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/tokens.dart';
import '../models/vault_item.dart';
import '../widgets/primary_button.dart';
import '../services/vault_service.dart';

class EditItemDialog extends StatefulWidget {
  final NovaTheme theme;
  final VaultItem item;

  const EditItemDialog({super.key, required this.theme, required this.item});

  static void show(BuildContext context, NovaTheme theme, VaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => EditItemDialog(theme: theme, item: item),
    );
  }

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late String _category;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;
  late String _folder;
  late bool _favourite;
  late bool _hasTotp;
  late final TextEditingController _totpSecretController;

  // Card specific
  late final TextEditingController _cardHolderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  late final TextEditingController _cardPinController;
  late String _cardBrand;

  // Server specific
  late final TextEditingController _serverHostController;
  late final TextEditingController _serverPublicIpController;
  late final TextEditingController _serverDomainController;
  late final TextEditingController _serverSshPortController;
  late final TextEditingController _serverUsernameController;
  late final TextEditingController _serverPasswordController;
  late final TextEditingController _serverSshKeyController;
  late final TextEditingController _panelUrlController;
  late final TextEditingController _panelUsernameController;
  late final TextEditingController _panelPasswordController;
  late final TextEditingController _panelPortController;
  late final TextEditingController _serverOsController;
  late final TextEditingController _serverProviderController;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _category = item.category;
    _nameController = TextEditingController(text: item.name);
    _usernameController = TextEditingController(text: item.username);
    _passwordController = TextEditingController(text: item.password);
    _urlController = TextEditingController(text: item.url);
    _notesController = TextEditingController(text: item.notes);
    _folder = item.folder.isNotEmpty ? item.folder : 'Work';
    _favourite = item.favourite;
    _hasTotp = item.hasTotp;
    _totpSecretController = TextEditingController(text: item.totpSecret);

    _cardHolderController = TextEditingController(text: item.cardHolder);
    _cardNumberController = TextEditingController(text: item.cardNumber);
    _cardExpiryController = TextEditingController(text: item.cardExpiry);
    _cardCvvController = TextEditingController(text: item.cardCvv);
    _cardPinController = TextEditingController(text: item.cardPin);
    _cardBrand = item.cardBrand.isNotEmpty ? item.cardBrand : 'Visa';

    // Server fields — pre-filled from existing item
    _serverHostController = TextEditingController(text: item.serverHost);
    _serverPublicIpController = TextEditingController(text: item.serverPublicIp);
    _serverDomainController = TextEditingController(text: item.serverDomain);
    _serverSshPortController = TextEditingController(text: item.serverSshPort.isNotEmpty ? item.serverSshPort : '22');
    _serverUsernameController = TextEditingController(text: item.serverUsername);
    _serverPasswordController = TextEditingController(text: item.serverPassword);
    _serverSshKeyController = TextEditingController(text: item.serverSshKey);
    _panelUrlController = TextEditingController(text: item.panelUrl);
    _panelUsernameController = TextEditingController(text: item.panelUsername);
    _panelPasswordController = TextEditingController(text: item.panelPassword);
    _panelPortController = TextEditingController(text: item.panelPort);
    _serverOsController = TextEditingController(text: item.serverOs);
    _serverProviderController = TextEditingController(text: item.serverProvider);
  }

  void _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnopqrstuvwxyz23456789!@#\$%^&*()_+~';
    final r = Random.secure();
    final p = List.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
    setState(() => _passwordController.text = p);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name cannot be empty')),
      );
      return;
    }

    final updated = widget.item.copyWith(
      name: name,
      category: _category,
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      url: _urlController.text.trim(),
      notes: _notesController.text.trim(),
      folder: _folder,
      tags: [_folder],
      favourite: _favourite,
      hasTotp: _category == 'login' && _hasTotp && _totpSecretController.text.trim().isNotEmpty,
      totpSecret: _category == 'login' ? _totpSecretController.text.trim().toUpperCase().replaceAll(' ', '') : null,
      cardHolder: _cardHolderController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      cardExpiry: _cardExpiryController.text.trim(),
      cardCvv: _cardCvvController.text.trim(),
      cardPin: _cardPinController.text.trim(),
      cardBrand: _cardBrand,
      serverHost: _serverHostController.text.trim(),
      serverPublicIp: _serverPublicIpController.text.trim(),
      serverDomain: _serverDomainController.text.trim(),
      serverSshPort: _serverSshPortController.text.trim().isEmpty ? '22' : _serverSshPortController.text.trim(),
      serverUsername: _serverUsernameController.text.trim(),
      serverPassword: _serverPasswordController.text.trim(),
      serverSshKey: _serverSshKeyController.text.trim(),
      panelUrl: _panelUrlController.text.trim(),
      panelUsername: _panelUsernameController.text.trim(),
      panelPassword: _panelPasswordController.text.trim(),
      panelPort: _panelPortController.text.trim(),
      serverOs: _serverOsController.text.trim(),
      serverProvider: _serverProviderController.text.trim(),
      updatedAt: 'today',
    );

    await VaultService().updateItem(updated);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$name" updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    // Wider dialog for server (more fields)
    final dialogWidth = _category == 'server' ? 680.0 : 520.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 820),
        padding: const EdgeInsets.all(20),
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
              // ── Header ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: NovaTokens.brandGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Icon(Icons.edit_rounded, color: Colors.white, size: 20)),
                      ),
                      const SizedBox(width: 12),
                      Text('Edit Vault Item',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: theme.text)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.muted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Category Selector ─────────────────────────────────
              Text('TYPE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: theme.muted, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _catChoice('login', 'Login', Icons.lock_outline_rounded, theme),
                  const SizedBox(width: 8),
                  _catChoice('card', 'Card', Icons.credit_card_outlined, theme),
                  const SizedBox(width: 8),
                  _catChoice('note', 'Note', Icons.description_outlined, theme),
                  const SizedBox(width: 8),
                  _catChoice('identity', 'Identity', Icons.person_outline_rounded, theme),
                  const SizedBox(width: 8),
                  _catChoice('server', 'Server', Icons.dns_outlined, theme),
                ],
              ),

              const SizedBox(height: 18),

              // ── Item Name ─────────────────────────────────────────
              _fieldLabel('ITEM NAME *', theme),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                decoration: _inputDeco(
                  _category == 'server' ? 'e.g. VPS Singapore, Contabo DE-01' : 'Item name',
                  Icons.label_outline_rounded, theme,
                ),
              ),

              const SizedBox(height: 14),

              // ── Dynamic Category Forms ────────────────────────────
              if (_category == 'login') ...[
                _fieldLabel('USERNAME / EMAIL', theme),
                TextField(controller: _usernameController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                    decoration: _inputDeco('Username or Email', Icons.person_outline_rounded, theme)),
                const SizedBox(height: 14),
                _fieldLabel('PASSWORD', theme),
                Row(children: [
                  Expanded(child: TextField(controller: _passwordController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                      decoration: _inputDeco('Password', Icons.key_rounded, theme))),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: theme.inputBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.inputBorder)),
                        padding: const EdgeInsets.all(12)),
                    onPressed: _generatePassword,
                    tooltip: 'Generate Strong Password',
                    icon: Icon(Icons.auto_fix_high_rounded, color: theme.accent, size: 20),
                  ),
                ]),
                const SizedBox(height: 14),
                _fieldLabel('WEBSITE URL', theme),
                TextField(controller: _urlController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                    decoration: _inputDeco('https://example.com', Icons.language_rounded, theme)),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Enable 2FA Authenticator Code', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                  Switch(value: _hasTotp, activeThumbColor: theme.accent, onChanged: (v) => setState(() => _hasTotp = v)),
                ]),
                if (_hasTotp) ...[
                  const SizedBox(height: 8),
                  _fieldLabel('2FA SECRET KEY (BASE32)', theme),
                  TextField(controller: _totpSecretController, style: GoogleFonts.robotoMono(fontSize: 13, color: theme.text),
                      decoration: _inputDeco('e.g. JBSWY3DPEHPK3PXP', Icons.timer_outlined, theme)),
                ],
                const SizedBox(height: 14),
              ] else if (_category == 'card') ...[
                _fieldLabel('CARDHOLDER NAME', theme),
                TextField(controller: _cardHolderController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                    decoration: _inputDeco('e.g. HESHAN SATHYANGA', Icons.person_outline_rounded, theme)),
                const SizedBox(height: 14),
                _fieldLabel('CARD NUMBER', theme),
                TextField(controller: _cardNumberController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                    decoration: _inputDeco('4532  8910  2341  4417', Icons.credit_card_rounded, theme)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('EXPIRATION (MM/YY)', theme),
                    TextField(controller: _cardExpiryController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('09/28', Icons.calendar_today_rounded, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('CVV', theme),
                    TextField(controller: _cardCvvController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('829', Icons.shield_outlined, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('CARD PIN', theme),
                    TextField(controller: _cardPinController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('4412', Icons.pin_rounded, theme)),
                  ])),
                ]),
                const SizedBox(height: 14),
              ] else if (_category == 'note') ...[
                _fieldLabel('SECURE ENCRYPTED NOTE CONTENT', theme),
                TextField(controller: _notesController, maxLines: 6,
                  style: GoogleFonts.inter(fontSize: 13, color: theme.text, height: 1.5),
                  decoration: _inputDeco('Type private notes, API keys, recovery phrases...', Icons.note_outlined, theme)),
                const SizedBox(height: 14),
              ] else if (_category == 'server') ...[
                // ══ SERVER FORM ══════════════════════════════════════
                // Row 1: hostname + provider
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('SERVER NAME / HOSTNAME', theme),
                    TextField(controller: _serverHostController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('e.g. vps-sg-01', Icons.computer_rounded, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PROVIDER', theme),
                    TextField(controller: _serverProviderController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('e.g. Contabo, Hetzner', Icons.cloud_outlined, theme)),
                  ])),
                ]),
                const SizedBox(height: 14),
                // Row 2: IP + Domain
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PUBLIC IP ADDRESS', theme),
                    TextField(controller: _serverPublicIpController, style: GoogleFonts.robotoMono(fontSize: 13, color: theme.text),
                        decoration: _inputDeco('e.g. 185.212.xxx.xxx', Icons.router_outlined, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('DOMAIN', theme),
                    TextField(controller: _serverDomainController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('e.g. vpn.example.com', Icons.language_rounded, theme)),
                  ])),
                ]),
                const SizedBox(height: 14),
                // Row 3: SSH user + password + port
                _fieldLabel('SSH ACCESS', theme),
                Row(children: [
                  Expanded(flex: 3, child: TextField(controller: _serverUsernameController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                      decoration: _inputDeco('Username (root)', Icons.person_outline_rounded, theme))),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: TextField(controller: _serverPasswordController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                      decoration: _inputDeco('SSH Password', Icons.key_rounded, theme))),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: TextField(controller: _serverSshPortController, style: GoogleFonts.robotoMono(fontSize: 13, color: theme.text),
                      decoration: _inputDeco('Port (22)', Icons.settings_ethernet_rounded, theme))),
                ]),
                const SizedBox(height: 14),
                // SSH Key
                _fieldLabel('SSH PRIVATE KEY / PASSPHRASE (OPTIONAL)', theme),
                TextField(controller: _serverSshKeyController, maxLines: 3,
                  style: GoogleFonts.robotoMono(fontSize: 11, color: theme.text, height: 1.4),
                  decoration: _inputDeco('Paste SSH private key or passphrase…', Icons.vpn_key_outlined, theme)),
                const SizedBox(height: 14),
                // OS
                _fieldLabel('OPERATING SYSTEM', theme),
                TextField(controller: _serverOsController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                    decoration: _inputDeco('e.g. Ubuntu 22.04 LTS', Icons.terminal_rounded, theme)),
                const SizedBox(height: 18),
                // Panel section divider
                Row(children: [
                  Icon(Icons.dashboard_outlined, size: 13, color: theme.accent),
                  const SizedBox(width: 6),
                  Text('CONTROL PANEL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: theme.muted)),
                  const SizedBox(width: 10),
                  Expanded(child: Divider(color: theme.cardBorder, height: 1)),
                ]),
                const SizedBox(height: 12),
                // Panel URL + port
                Row(children: [
                  Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PANEL URL', theme),
                    TextField(controller: _panelUrlController, style: GoogleFonts.inter(fontSize: 13, color: theme.text),
                        decoration: _inputDeco('https://panel.example.com', Icons.open_in_browser_rounded, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PANEL PORT', theme),
                    TextField(controller: _panelPortController, style: GoogleFonts.robotoMono(fontSize: 13, color: theme.text),
                        decoration: _inputDeco('8006', Icons.settings_ethernet_rounded, theme)),
                  ])),
                ]),
                const SizedBox(height: 14),
                // Panel credentials
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PANEL USERNAME', theme),
                    TextField(controller: _panelUsernameController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('admin / root', Icons.manage_accounts_outlined, theme)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('PANEL PASSWORD', theme),
                    TextField(controller: _panelPasswordController, style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                        decoration: _inputDeco('Panel password', Icons.lock_outline_rounded, theme)),
                  ])),
                ]),
                const SizedBox(height: 14),
              ],

              // ── Folder & Favorite (all categories) ───────────────
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('FOLDER', theme),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _folder,
                          dropdownColor: theme.isDark ? const Color(0xFF0B1F4A) : Colors.white,
                          style: GoogleFonts.inter(fontSize: 14, color: theme.text),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Work', child: Text('Work')),
                            DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                            DropdownMenuItem(value: 'Servers', child: Text('Servers')),
                          ],
                          onChanged: (v) => setState(() => _folder = v ?? 'Work'),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('FAVORITE', theme),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _favourite = !_favourite),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.inputBorder),
                      ),
                      child: Row(children: [
                        Icon(_favourite ? Icons.star_rounded : Icons.star_border_rounded,
                            color: _favourite ? theme.accent : theme.muted, size: 20),
                        const SizedBox(width: 6),
                        Text('Favorite', style: GoogleFonts.inter(fontSize: 13, color: theme.text)),
                      ]),
                    ),
                  ),
                ]),
              ]),

              // ── Notes field (login/card/server) ──────────────────
              if (_category != 'note') ...[
                const SizedBox(height: 14),
                _fieldLabel('NOTES', theme),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: GoogleFonts.inter(fontSize: 13, color: theme.text),
                  decoration: _inputDeco('Additional notes or recovery codes...', Icons.note_outlined, theme),
                ),
              ],

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: theme.muted)),
                ),
                const SizedBox(width: 12),
                NovaPrimaryButton(text: 'Save Changes', icon: Icons.check_rounded, onPressed: _save),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _catChoice(String id, String label, IconData icon, NovaTheme theme) {
    final active = _category == id;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _category = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? NovaTokens.royal700 : theme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? NovaTokens.royal700 : theme.cardBorder),
          ),
          child: Column(children: [
            Icon(icon, size: 16, color: active ? Colors.white : theme.muted),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : theme.muted,
            )),
          ]),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, NovaTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: theme.muted, letterSpacing: 1.1)),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, NovaTheme theme) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: theme.muted),
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: theme.muted.withValues(alpha: 0.6)),
      filled: true,
      fillColor: theme.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.inputBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NovaTokens.midBlue, width: 1.5)),
    );
  }
}
