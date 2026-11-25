import React, { useState, useMemo, useEffect } from 'react';
import { Sidebar, type NavItemKey } from './Sidebar';
import { ListPane, type VaultListItem } from './ListPane';
import { DetailPane } from './DetailPane';
import { MOCK_ITEMS } from '../../data/mockData';

interface DesktopLayoutProps {
  onNewItem?: () => void;
  onOpenGenerator?: () => void;
  onOpenSettings?: () => void;
}

export function DesktopLayout({
  onNewItem,
  onOpenGenerator,
  onOpenSettings,
}: DesktopLayoutProps) {
  const [windowWidth, setWindowWidth] = useState(
    typeof window !== 'undefined' ? window.innerWidth : 1200
  );

  useEffect(() => {
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const isCollapsed = windowWidth < 1100;

  const [activeNav, setActiveNav] = useState<NavItemKey>('all');
  const [selectedFolder, setSelectedFolder] = useState<string | null>(null);
  const [selectedItemId, setSelectedItemId] = useState<string | null>('1'); // '1' is GitHub
  const [searchQuery, setSearchQuery] = useState('');
  const [activeChip, setActiveChip] = useState('All');
  const [items, setItems] = useState<VaultListItem[]>(MOCK_ITEMS);

  // Filter items
  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      // Nav filter
      if (selectedFolder) {
        if (item.folder.toLowerCase() !== selectedFolder.toLowerCase()) return false;
      } else if (activeNav === 'favorites') {
        if (!item.favourite) return false;
      } else if (activeNav === 'logins') {
        if (item.category !== 'login') return false;
      } else if (activeNav === 'cards') {
        if (item.category !== 'card') return false;
      } else if (activeNav === 'notes') {
        if (item.category !== 'note') return false;
      } else if (activeNav === 'identities') {
        if (item.category !== 'identity') return false;
      }

      // Chip filter
      if (activeChip === 'Logins' && item.category !== 'login') return false;
      if (activeChip === 'Cards' && item.category !== 'card') return false;
      if (activeChip === 'Weak' && (item.strength || 0) > 60) return false;

      // Search filter
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const matchesName = item.name.toLowerCase().includes(q);
        const matchesUser = item.username?.toLowerCase().includes(q);
        const matchesUrl = item.url?.toLowerCase().includes(q);
        if (!matchesName && !matchesUser && !matchesUrl) return false;
      }

      return true;
    });
  }, [items, activeNav, selectedFolder, activeChip, searchQuery]);

  const selectedItem = useMemo(() => {
    return items.find((i) => i.id === selectedItemId) || filteredItems[0] || null;
  }, [items, selectedItemId, filteredItems]);

  const handleFavouriteToggle = (id: string) => {
    setItems((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, favourite: !item.favourite } : item
      )
    );
  };

  const handleNavChange = (nav: NavItemKey) => {
    if (nav === 'generator' && onOpenGenerator) {
      onOpenGenerator();
      return;
    }
    if (nav === 'settings' && onOpenSettings) {
      onOpenSettings();
      return;
    }
    setActiveNav(nav);
  };

  return (
    <div
      style={{
        display: 'flex',
        width: '100vw',
        height: '100%',
        overflow: 'hidden',
        background: 'var(--bg)',
      }}
    >
      {/* 1. Sidebar (always dark navy) */}
      <Sidebar
        activeNav={activeNav}
        onNavChange={handleNavChange}
        selectedFolder={selectedFolder}
        onFolderSelect={setSelectedFolder}
        isCollapsed={isCollapsed}
      />

      {/* 2. List Pane */}
      <ListPane
        items={filteredItems}
        selectedId={selectedItem ? selectedItem.id : null}
        onSelect={setSelectedItemId}
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        activeChip={activeChip}
        onChipChange={setActiveChip}
        title={
          selectedFolder
            ? `${selectedFolder} Folder`
            : activeNav === 'favorites'
            ? 'Favorites'
            : activeNav === 'logins'
            ? 'Logins'
            : activeNav === 'cards'
            ? 'Cards'
            : 'All items'
        }
        totalCount={filteredItems.length}
      />

      {/* 3. Detail Pane */}
      <DetailPane
        item={selectedItem}
        onFavourite={handleFavouriteToggle}
        onNewItem={onNewItem}
      />
    </div>
  );
}

export default DesktopLayout;
