import React from 'react';
import { Star, Shield } from 'lucide-react';
import { SearchInput } from '../../components/SearchInput';
import { Chip } from '../../components/Chip';
import { ItemAvatar } from '../../components/ItemAvatar';
import { tokens } from '../../tokens';

export interface VaultListItem {
  id: string;
  name: string;
  category: string;
  username: string;
  password?: string;
  url?: string;
  tags: string[];
  favourite: boolean;
  folder: string;
  strength?: number;
  hasTotp?: boolean;
  updatedAt?: string;
  createdAt?: string;
}

interface ListPaneProps {
  items: VaultListItem[];
  selectedId: string | null;
  onSelect: (id: string) => void;
  searchQuery: string;
  onSearchChange: (q: string) => void;
  activeChip: string;
  onChipChange: (chip: string) => void;
  title?: string;
  totalCount?: number;
}

export function ListPane({
  items,
  selectedId,
  onSelect,
  searchQuery,
  onSearchChange,
  activeChip,
  onChipChange,
  title = 'All items',
  totalCount = 128,
}: ListPaneProps) {
  const chips = ['All', 'Logins', 'Cards', 'Weak'];

  return (
    <div
      style={{
        width: 372,
        background: 'var(--list-tint)',
        borderRight: '1px solid var(--card-border)',
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        flexShrink: 0,
      }}
    >
      {/* Top Header */}
      <div
        style={{
          padding: '24px 20px 14px',
          display: 'flex',
          alignItems: 'baseline',
          justifyContent: 'space-between',
        }}
      >
        <h1
          style={{
            fontSize: 20,
            fontWeight: 700,
            color: 'var(--text)',
            letterSpacing: '-0.3px',
            margin: 0,
          }}
        >
          {title}
        </h1>
        <span
          style={{
            fontSize: 12,
            color: 'var(--muted)',
            fontWeight: 500,
          }}
        >
          {totalCount} items
        </span>
      </div>

      {/* Search Input */}
      <div style={{ padding: '0 16px 12px' }}>
        <SearchInput
          value={searchQuery}
          onChange={onSearchChange}
          placeholder="Search vault"
          showKbd={true}
          size="desktop"
        />
      </div>

      {/* Filter Chips */}
      <div
        style={{
          display: 'flex',
          gap: 8,
          padding: '0 16px 16px',
          overflowX: 'auto',
          flexShrink: 0,
        }}
      >
        {chips.map((chip) => (
          <Chip
            key={chip}
            active={activeChip === chip}
            onClick={() => onChipChange(chip)}
            size="desktop"
          >
            {chip}
          </Chip>
        ))}
      </div>

      {/* Item List */}
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '0 12px 16px',
          display: 'flex',
          flexDirection: 'column',
          gap: 4,
        }}
      >
        {items.length === 0 ? (
          <div
            style={{
              padding: '60px 20px',
              textAlign: 'center',
              color: 'var(--muted)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 12,
            }}
          >
            <Shield size={32} strokeWidth={1.5} style={{ opacity: 0.5 }} />
            <div style={{ fontSize: 13, fontWeight: 500 }}>No items match your search</div>
          </div>
        ) : (
          items.map((item) => {
            const isSelected = selectedId === item.id;
            const primaryTag = item.tags && item.tags[0];

            return (
              <div
                key={item.id}
                role="button"
                tabIndex={0}
                onClick={() => onSelect(item.id)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    onSelect(item.id);
                  }
                }}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '10px 14px',
                  borderRadius: tokens.radii.listRow,
                  background: isSelected ? 'var(--selected-bg)' : 'transparent',
                  border: isSelected ? '1px solid var(--selected-border)' : '1px solid transparent',
                  cursor: 'pointer',
                  gap: 12,
                  transition: 'all 150ms ease-out',
                  userSelect: 'none',
                  outline: 'none',
                }}
                onMouseEnter={(e) => {
                  if (!isSelected) {
                    e.currentTarget.style.background = 'var(--selected-bg)';
                    e.currentTarget.style.opacity = '0.9';
                  }
                }}
                onMouseLeave={(e) => {
                  if (!isSelected) {
                    e.currentTarget.style.background = 'transparent';
                    e.currentTarget.style.opacity = '1';
                  }
                }}
              >
                {/* 44px Avatar */}
                <ItemAvatar name={item.name} size={44} radius={12} />

                {/* Info */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div
                    style={{
                      fontSize: 14,
                      fontWeight: 600,
                      color: 'var(--text)',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                      lineHeight: 1.25,
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
                      marginTop: 3,
                    }}
                  >
                    {item.username || item.url || item.category}
                  </div>
                </div>

                {/* Right Meta: Tag + Star */}
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                    flexShrink: 0,
                  }}
                >
                  {primaryTag && (
                    <span
                      style={{
                        fontSize: 11,
                        color: 'var(--muted)',
                        fontWeight: 500,
                      }}
                    >
                      {primaryTag}
                    </span>
                  )}

                  <Star
                    size={15}
                    strokeWidth={1.8}
                    fill={item.favourite ? '#f5c451' : 'none'}
                    color={item.favourite ? '#f5c451' : 'var(--muted)'}
                    style={{ opacity: item.favourite ? 1 : 0.4 }}
                  />
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}

export default ListPane;
