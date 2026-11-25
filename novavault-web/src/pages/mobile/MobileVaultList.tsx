import React, { useState, useMemo } from 'react';
import { RefreshCw, Copy, Check } from 'lucide-react';
import { Logo } from '../../components/Logo';
import { VaultHealthRing } from '../../components/VaultHealthRing';
import { SearchInput } from '../../components/SearchInput';
import { Chip } from '../../components/Chip';
import { ItemAvatar } from '../../components/ItemAvatar';
import { FAB } from '../../components/FAB';
import { TabBar, type TabKey } from '../../components/TabBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';
import { MOCK_ITEMS, HEALTH_SCORE } from '../../data/mockData';
import type { VaultListItem } from '../desktop/ListPane';

interface MobileVaultListProps {
  onSelectItem: (item: VaultListItem) => void;
  onNewItem?: () => void;
  activeTab: TabKey;
  onTabChange: (tab: TabKey) => void;
}

export function MobileVaultList({
  onSelectItem,
  onNewItem,
  activeTab,
  onTabChange,
}: MobileVaultListProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeChip, setActiveChip] = useState('All');
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const chips = ['All', 'Logins', 'Cards', 'Notes'];

  const filteredItems = useMemo(() => {
    return MOCK_ITEMS.filter((item) => {
      if (activeChip === 'Logins' && item.category !== 'login') return false;
      if (activeChip === 'Cards' && item.category !== 'card') return false;
      if (activeChip === 'Notes' && item.category !== 'note') return false;

      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        return (
          item.name.toLowerCase().includes(q) ||
          item.username?.toLowerCase().includes(q) ||
          item.url?.toLowerCase().includes(q)
        );
      }
      return true;
    });
  }, [activeChip, searchQuery]);

  const handleCopy = (e: React.MouseEvent, item: VaultListItem) => {
    e.stopPropagation();
    navigator.clipboard.writeText(item.password || item.username || item.name);
    setCopiedId(item.id);
    showToast('Copied to clipboard');
    setTimeout(() => setCopiedId(null), 1200);
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: 'var(--bg)',
        padding: '28px 20px 100px 20px',
        display: 'flex',
        flexDirection: 'column',
        gap: 14,
        position: 'relative',
        boxSizing: 'border-box',
        overflowY: 'auto',
      }}
    >
      {/* 1. Top Header */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <Logo size="mobile" showWordmark={true} />

        {/* Synced Pill */}
        <div
          style={{
            background: 'var(--selected-bg)',
            border: '1px solid var(--selected-border)',
            borderRadius: 20,
            padding: '5px 12px',
            display: 'flex',
            alignItems: 'center',
            gap: 6,
            color: 'var(--accent)',
            fontSize: 12,
            fontWeight: 600,
          }}
        >
          <RefreshCw size={13} strokeWidth={2} />
          <span>Synced</span>
        </div>
      </div>

      {/* 2. Vault Health Card */}
      <div
        style={{
          borderRadius: 20,
          padding: 16,
          background: tokens.heroGradient,
          position: 'relative',
          overflow: 'hidden',
          color: '#ffffff',
          boxShadow: '0 12px 30px rgba(5,16,38,.4)',
          cursor: 'pointer',
        }}
        onClick={() => onTabChange('security')}
      >
        {/* Soft radial highlight */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'radial-gradient(300px 150px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
            pointerEvents: 'none',
          }}
        />

        <div style={{ position: 'relative', zIndex: 1, display: 'flex', alignItems: 'center', gap: 14 }}>
          <VaultHealthRing
            score={HEALTH_SCORE}
            size="mobile"
            overrideTrack="rgba(255, 255, 255, 0.20)"
            overrideFill="#ffffff"
            overrideText="#ffffff"
          />
          <div>
            <div style={{ fontSize: 15, fontWeight: 700, color: '#ffffff' }}>
              Vault health
            </div>
            <div style={{ fontSize: 12, color: 'rgba(255, 255, 255, 0.70)', marginTop: 2 }}>
              3 weak passwords to fix
            </div>
          </div>
        </div>
      </div>

      {/* 3. Search Input */}
      <SearchInput
        value={searchQuery}
        onChange={setSearchQuery}
        placeholder="Search your vault"
        showKbd={false}
        size="mobile"
      />

      {/* 4. Filter Chips */}
      <div
        style={{
          display: 'flex',
          gap: 8,
          overflowX: 'auto',
          paddingBottom: 2,
        }}
      >
        {chips.map((chip) => (
          <Chip
            key={chip}
            active={activeChip === chip}
            onClick={() => setActiveChip(chip)}
            size="mobile"
          >
            {chip}
          </Chip>
        ))}
      </div>

      {/* 5. Item Rows */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {filteredItems.map((item) => (
          <div
            key={item.id}
            role="button"
            tabIndex={0}
            onClick={() => onSelectItem(item)}
            style={{
              background: 'var(--card)',
              border: '1px solid var(--card-border)',
              borderRadius: 16,
              padding: '12px 14px',
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              cursor: 'pointer',
              transition: 'transform 150ms ease-out, background 150ms ease',
              boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.99)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
            onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            {/* 42px Avatar */}
            <ItemAvatar name={item.name} size={42} radius={12} />

            {/* Info */}
            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                style={{
                  fontSize: 15,
                  fontWeight: 600,
                  color: 'var(--text)',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {item.name}
              </div>
              <div
                style={{
                  fontSize: 12,
                  color: 'var(--muted)',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  marginTop: 2,
                }}
              >
                {item.username || item.url || item.category}
              </div>
            </div>

            {/* Trailing Copy Button (min 44x44 touch target) */}
            <button
              type="button"
              aria-label={`Copy password for ${item.name}`}
              onClick={(e) => handleCopy(e, item)}
              style={{
                width: 44,
                height: 44,
                borderRadius: 12,
                background: 'transparent',
                border: 'none',
                color: copiedId === item.id ? '#2fb67c' : 'var(--accent)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                flexShrink: 0,
              }}
            >
              {copiedId === item.id ? (
                <Check size={18} strokeWidth={2} />
              ) : (
                <Copy size={18} strokeWidth={1.7} />
              )}
            </button>
          </div>
        ))}
      </div>

      {/* 6. FAB */}
      {onNewItem && <FAB onClick={onNewItem} />}

      {/* 7. Tab Bar */}
      <TabBar activeTab={activeTab} onChange={onTabChange} />
    </div>
  );
}

export default MobileVaultList;
