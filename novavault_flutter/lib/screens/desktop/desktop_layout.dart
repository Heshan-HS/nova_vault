import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../models/vault_item.dart';
import '../../services/vault_service.dart';
import '../add_item_dialog.dart';
import 'desktop_sidebar.dart';
import 'desktop_list_pane.dart';
import 'desktop_detail_pane.dart';

class DesktopLayout extends StatefulWidget {
  final List<VaultItem>? items;
  final VoidCallback? onNewItem;
  final VoidCallback? onOpenGenerator;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onLockVault;
  final bool isDark;
  final Function(bool)? onToggleTheme;
  final NovaTheme theme;

  const DesktopLayout({
    super.key,
    this.items,
    this.onNewItem,
    this.onOpenGenerator,
    this.onOpenSettings,
    this.onLockVault,
    this.isDark = true,
    this.onToggleTheme,
    required this.theme,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final _vaultService = VaultService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = _vaultService.filteredItems;
      if (list.isNotEmpty) {
        _vaultService.selectItem(list.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vaultService,
      builder: (context, _) {
        final filtered = _vaultService.filteredItems;
        final selected = (_vaultService.selectedItem != null &&
                filtered.any((i) => i.id == _vaultService.selectedItem!.id))
            ? _vaultService.selectedItem
            : (filtered.isNotEmpty ? filtered.first : null);

        final title = _vaultService.selectedFolder != null
            ? '${_vaultService.selectedFolder} Folder'
            : _vaultService.activeNav == 'favorites'
                ? 'Favorites'
                : _vaultService.activeNav == 'logins'
                    ? 'Logins'
                    : _vaultService.activeNav == 'cards'
                        ? 'Cards'
                        : _vaultService.activeNav == 'notes'
                            ? 'Secure notes'
                            : _vaultService.activeNav == 'identities'
                                ? 'Identities'
                                : _vaultService.activeNav == 'servers'
                                    ? 'Servers'
                                    : 'All items';

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
            child: Row(
              children: [
                // 1. Sidebar (always dark)
                DesktopSidebar(
                  activeNav: _vaultService.activeNav,
                  onNavChange: (nav) => _vaultService.setActiveNav(nav),
                  selectedFolder: _vaultService.selectedFolder,
                  onFolderSelect: (folder) => _vaultService.setSelectedFolder(folder),
                  onOpenGenerator: widget.onOpenGenerator,
                  onOpenSettings: widget.onOpenSettings,
                  theme: widget.theme,
                ),

                // 2. List Pane
                DesktopListPane(
                  items: filtered,
                  selectedId: selected?.id,
                  onSelect: (id) {
                    final found = _vaultService.items.firstWhere((i) => i.id == id, orElse: () => selected!);
                    _vaultService.selectItem(found);
                  },
                  searchQuery: _vaultService.searchQuery,
                  onSearchChange: (q) => _vaultService.setSearchQuery(q),
                  activeChip: _vaultService.selectedFilterChip,
                  onChipChange: (chip) => _vaultService.setFilterChip(chip),
                  onToggleFavourite: (id) => _vaultService.toggleFavourite(id),
                  theme: widget.theme,
                  title: title,
                ),

                // 3. Detail Pane
                Expanded(
                  child: DesktopDetailPane(
                    item: selected,
                    onFavouriteToggle: selected != null ? () => _vaultService.toggleFavourite(selected.id) : null,
                    onNewItem: widget.onNewItem ?? () => AddItemDialog.show(context, widget.theme),
                    onLockVault: widget.onLockVault,
                    isDark: widget.isDark,
                    onToggleTheme: widget.onToggleTheme,
                    theme: widget.theme,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
