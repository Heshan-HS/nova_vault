import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import 'mobile_vault_list.dart';
import 'mobile_item_detail.dart';
import '../generator_screen.dart';
import '../security_screen.dart';
import '../settings_screen.dart';

class MobileLayout extends StatefulWidget {
  final List<VaultItem> items;
  final VoidCallback? onNewItem;
  final NovaTheme theme;
  final bool isDark;
  final Function(bool) onToggleTheme;
  final VoidCallback? onLockVault;

  const MobileLayout({
    super.key,
    required this.items,
    this.onNewItem,
    required this.theme,
    required this.isDark,
    required this.onToggleTheme,
    this.onLockVault,
  });

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout>
    with TickerProviderStateMixin {
  int _tabIndex = 0;
  VaultItem? _selectedItem;

  late final AnimationController _navController;
  late final List<AnimationController> _tabControllers;

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();

    _tabControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
        value: i == 0 ? 1.0 : 0.0,
      ),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    for (final c in _tabControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectTab(int index) {
    if (_tabIndex == index) return;
    HapticFeedback.selectionClick();
    _tabControllers[_tabIndex].reverse();
    _tabControllers[index].forward();
    setState(() {
      _selectedItem = null;
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(
                _tabIndex == 0 ? 'vault-${_selectedItem?.id}' : 'tab-$_tabIndex'),
            child: _buildCurrentTab(bottomPadding),
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(bottomPadding),
    );
  }

  Widget _buildCurrentTab(double bottomPadding) {
    if (_tabIndex == 0) {
      if (_selectedItem != null) {
        return MobileItemDetail(
          item: _selectedItem!,
          onBack: () => setState(() => _selectedItem = null),
          theme: widget.theme,
          bottomPadding: bottomPadding + 72,
        );
      }
      return MobileVaultList(
        items: widget.items,
        onSelectItem: (item) {
          HapticFeedback.lightImpact();
          setState(() => _selectedItem = item);
        },
        onNewItem: widget.onNewItem,
        onOpenSecurity: () => _selectTab(2),
        theme: widget.theme,
        bottomPadding: bottomPadding + 72,
      );
    } else if (_tabIndex == 1) {
      return GeneratorScreen(theme: widget.theme);
    } else if (_tabIndex == 2) {
      return SecurityScreen(theme: widget.theme);
    } else {
      return SettingsScreen(
        theme: widget.theme,
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onLockVault: widget.onLockVault,
      );
    }
  }

  Widget _buildNavBar(double bottomPadding) {
    final isDark = widget.theme.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF060E22).withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0x26FFFFFF)
                : const Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF000000).withOpacity(0.5)
                : const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _navItem(0, 'Vault', Icons.shield_rounded, Icons.shield_outlined),
              _navItem(1, 'Generator', Icons.auto_fix_high_rounded,
                  Icons.auto_fix_high_outlined),
              _navItem(2, 'Security', Icons.verified_user_rounded,
                  Icons.verified_user_outlined),
              _navItem(3, 'Settings', Icons.settings_rounded,
                  Icons.settings_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, String label, IconData activeIcon, IconData inactiveIcon) {
    final isActive = _tabIndex == index;
    final isDark = widget.theme.isDark;
    final accent = isDark ? const Color(0xFF6FA8FF) : NovaTokens.royal700;
    final muted = isDark ? const Color(0xFF5A6B8A) : const Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectTab(index),
        child: AnimatedBuilder(
          animation: _tabControllers[index],
          builder: (context, _) {
            final t = _tabControllers[index].value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isActive ? 24 : 0,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  size: 22,
                  color: Color.lerp(muted, accent, t),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: Color.lerp(muted, accent, t),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
