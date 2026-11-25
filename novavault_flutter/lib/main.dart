import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokens/tokens.dart';
import 'screens/desktop/desktop_layout.dart';
import 'screens/mobile/mobile_layout.dart';
import 'screens/unlock_screen.dart';
import 'screens/security_setup_screen.dart';
import 'screens/add_item_dialog.dart';
import 'screens/generator_screen.dart';
import 'screens/settings_screen.dart';
import 'services/vault_service.dart';
import 'services/auth_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VaultService().init();
  await AuthSyncService().init();
  runApp(const NovaVaultApp());
}

class NovaVaultApp extends StatefulWidget {
  const NovaVaultApp({super.key});

  @override
  State<NovaVaultApp> createState() => _NovaVaultAppState();
}

class _NovaVaultAppState extends State<NovaVaultApp> {
  bool _isDark = false; // Default Light Mode as requested

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted && prefs.containsKey('nv_theme_is_dark')) {
      setState(() {
        _isDark = prefs.getBool('nv_theme_is_dark') ?? false;
      });
    }
  }

  void _toggleTheme(bool val) async {
    setState(() => _isDark = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nv_theme_is_dark', val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _isDark ? NovaTokens.navy900 : NovaTokens.lightBgStart,
        textTheme: GoogleFonts.interTextTheme(
          _isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        ),
      ),
      home: NovaVaultRoot(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class NovaVaultRoot extends StatefulWidget {
  final bool isDark;
  final Function(bool) onToggleTheme;

  const NovaVaultRoot({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<NovaVaultRoot> createState() => _NovaVaultRootState();
}

class _NovaVaultRootState extends State<NovaVaultRoot> {
  final _vaultService = VaultService();

  void _openGeneratorModal(NovaTheme theme) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
          child: Container(
            decoration: BoxDecoration(
              gradient: theme.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.cardBorder),
            ),
            child: GeneratorScreen(theme: theme),
          ),
        ),
      ),
    );
  }

  void _openSettingsModal(NovaTheme theme) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
          child: Container(
            decoration: BoxDecoration(
              gradient: theme.backgroundGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.cardBorder),
            ),
            child: SettingsScreen(
              theme: theme,
              isDark: widget.isDark,
              onToggleTheme: widget.onToggleTheme,
              onLockVault: () {
                Navigator.of(context).pop();
                _vaultService.lock();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vaultService,
      builder: (context, _) {
        if (!_vaultService.securitySetupDone) {
          return const SecuritySetupScreen();
        }
        if (_vaultService.lockEnabled && _vaultService.isLocked) {
          return UnlockScreen(onUnlock: () {});
        }

        final theme = NovaTheme(isDark: widget.isDark);

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return DesktopLayout(
                  onNewItem: () => AddItemDialog.show(context, theme),
                  onOpenGenerator: () => _openGeneratorModal(theme),
                  onOpenSettings: () => _openSettingsModal(theme),
                  onLockVault: () => _vaultService.lock(),
                  isDark: widget.isDark,
                  onToggleTheme: widget.onToggleTheme,
                  theme: theme,
                );
              } else {
                return MobileLayout(
                  items: _vaultService.items,
                  onNewItem: () => AddItemDialog.show(context, theme),
                  theme: theme,
                  isDark: widget.isDark,
                  onToggleTheme: widget.onToggleTheme,
                  onLockVault: () => _vaultService.lock(),
                );
              }
            },
          ),
        );
      },
    );
  }
}
