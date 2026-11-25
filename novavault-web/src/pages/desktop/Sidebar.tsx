import React from 'react';
import {
  Shield,
  Star,
  Lock,
  CreditCard,
  FileText,
  User,
  Wand2,
  Folder,
  RefreshCw,
  Settings,
} from 'lucide-react';
import { Logo } from '../../components/Logo';
import { VaultHealthRing } from '../../components/VaultHealthRing';
import { tokens } from '../../tokens';
import { VAULT_STATS, FOLDERS, HEALTH_SCORE } from '../../data/mockData';

export type NavItemKey =
  | 'all'
  | 'favorites'
  | 'logins'
  | 'cards'
  | 'notes'
  | 'identities'
  | 'generator'
  | 'settings';

interface SidebarProps {
  activeNav: NavItemKey;
  onNavChange: (nav: NavItemKey) => void;
  selectedFolder?: string | null;
  onFolderSelect?: (folder: string | null) => void;
  isCollapsed?: boolean;
}

export function Sidebar({
  activeNav,
  onNavChange,
  selectedFolder,
  onFolderSelect,
  isCollapsed = false,
}: SidebarProps) {
  const navItems = [
    { key: 'all' as NavItemKey, label: 'All items', count: VAULT_STATS.total, icon: <Shield size={18} strokeWidth={1.7} /> },
    { key: 'favorites' as NavItemKey, label: 'Favorites', count: VAULT_STATS.favourites, icon: <Star size={18} strokeWidth={1.7} /> },
    { key: 'logins' as NavItemKey, label: 'Logins', count: VAULT_STATS.logins, icon: <Lock size={18} strokeWidth={1.7} /> },
    { key: 'cards' as NavItemKey, label: 'Cards', count: VAULT_STATS.cards, icon: <CreditCard size={18} strokeWidth={1.7} /> },
    { key: 'notes' as NavItemKey, label: 'Secure notes', count: VAULT_STATS.notes, icon: <FileText size={18} strokeWidth={1.7} /> },
    { key: 'identities' as NavItemKey, label: 'Identities', count: VAULT_STATS.identities, icon: <User size={18} strokeWidth={1.7} /> },
    { key: 'generator' as NavItemKey, label: 'Generator', count: null, icon: <Wand2 size={18} strokeWidth={1.7} /> },
  ];

  return (
    <aside
      style={{
        width: isCollapsed ? 72 : 264,
        background: tokens.sidebarGradient,
        borderRight: '1px solid rgba(255, 255, 255, 0.08)',
        padding: isCollapsed ? '24px 10px' : '24px 16px',
        display: 'flex',
        flexDirection: 'column',
        flexShrink: 0,
        height: '100%',
        userSelect: 'none',
        transition: 'width 200ms ease',
      }}
    >
      {/* Top Logo */}
      <div style={{ paddingBottom: 22, display: 'flex', justifyContent: isCollapsed ? 'center' : 'flex-start' }}>
        <Logo size="desktop" showWordmark={!isCollapsed} />
      </div>

      {/* Main Nav Items */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        {navItems.map((item) => {
          const isActive = activeNav === item.key && !selectedFolder;
          return (
            <button
              key={item.key}
              type="button"
              onClick={() => {
                onNavChange(item.key);
                if (onFolderSelect) onFolderSelect(null);
              }}
              title={isCollapsed ? item.label : undefined}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: isCollapsed ? '10px 0' : '10px 14px',
                justifyContent: isCollapsed ? 'center' : 'flex-start',
                borderRadius: 12,
                fontSize: 14,
                fontWeight: isActive ? 600 : 500,
                color: isActive ? '#ffffff' : 'rgba(255, 255, 255, 0.72)',
                background: isActive ? 'rgba(255, 255, 255, 0.10)' : 'transparent',
                boxShadow: isActive ? 'inset 0 0 0 1px rgba(255, 255, 255, 0.12)' : 'none',
                border: 'none',
                cursor: 'pointer',
                transition: 'all 150ms ease-out',
                width: '100%',
              }}
              onMouseEnter={(e) => {
                if (!isActive) e.currentTarget.style.background = 'rgba(255, 255, 255, 0.06)';
              }}
              onMouseLeave={(e) => {
                if (!isActive) e.currentTarget.style.background = 'transparent';
              }}
            >
              <span style={{ display: 'flex', alignItems: 'center', opacity: isActive ? 1 : 0.85 }}>
                {item.icon}
              </span>
              {!isCollapsed && (
                <>
                  <span style={{ flex: 1, textAlign: 'left' }}>{item.label}</span>
                  {item.count !== null && (
                    <span
                      style={{
                        fontSize: 11,
                        fontWeight: 600,
                        color: 'rgba(255, 255, 255, 0.55)',
                        padding: '1px 6px',
                        borderRadius: 6,
                        background: 'rgba(255, 255, 255, 0.06)',
                      }}
                    >
                      {item.count}
                    </span>
                  )}
                </>
              )}
            </button>
          );
        })}
      </div>

      {/* Folders Section */}
      {!isCollapsed && (
        <div style={{ marginTop: 20 }}>
          <div
            style={{
              fontSize: 11,
              fontWeight: 700,
              letterSpacing: '1.2px',
              color: 'rgba(255, 255, 255, 0.60)',
              padding: '0 14px 8px',
              textTransform: 'uppercase',
            }}
          >
            FOLDERS
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            {FOLDERS.map((f) => {
              const isSelected = selectedFolder === f.name;
              return (
                <button
                  key={f.name}
                  type="button"
                  onClick={() => onFolderSelect && onFolderSelect(f.name)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 10,
                    padding: '8px 14px',
                    borderRadius: 10,
                    fontSize: 13,
                    fontWeight: isSelected ? 600 : 500,
                    color: isSelected ? '#ffffff' : 'rgba(255, 255, 255, 0.72)',
                    background: isSelected ? 'rgba(255, 255, 255, 0.08)' : 'transparent',
                    border: 'none',
                    cursor: 'pointer',
                    width: '100%',
                    transition: 'all 150ms ease-out',
                  }}
                  onMouseEnter={(e) => {
                    if (!isSelected) e.currentTarget.style.background = 'rgba(255, 255, 255, 0.04)';
                  }}
                  onMouseLeave={(e) => {
                    if (!isSelected) e.currentTarget.style.background = 'transparent';
                  }}
                >
                  <Folder size={16} strokeWidth={1.7} style={{ opacity: 0.7 }} />
                  <span style={{ flex: 1, textAlign: 'left' }}>{f.name}</span>
                  <span style={{ fontSize: 11, color: 'rgba(255, 255, 255, 0.50)' }}>
                    {f.count}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      )}

      {/* Spacer */}
      <div style={{ flex: 1 }} />

      {/* Vault Health Card */}
      {!isCollapsed ? (
        <div
          style={{
            borderRadius: 16,
            background: 'rgba(255, 255, 255, 0.07)',
            border: '1px solid rgba(255, 255, 255, 0.10)',
            padding: 14,
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            marginBottom: 14,
          }}
        >
          <VaultHealthRing
            score={HEALTH_SCORE}
            size="desktop"
            overrideTrack="rgba(255, 255, 255, 0.15)"
            overrideFill="#6fa8ff"
            overrideText="#ffffff"
          />
          <div>
            <div style={{ fontSize: 13, fontWeight: 600, color: '#ffffff' }}>
              Vault health
            </div>
            <div style={{ fontSize: 11, color: 'rgba(255, 255, 255, 0.64)', marginTop: 2 }}>
              3 weak passwords
            </div>
          </div>
        </div>
      ) : (
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 14 }}>
          <VaultHealthRing
            score={HEALTH_SCORE}
            size="desktop"
            overrideTrack="rgba(255, 255, 255, 0.15)"
            overrideFill="#6fa8ff"
            overrideText="#ffffff"
          />
        </div>
      )}

      {/* Bottom Account Row */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          padding: '8px 4px',
          borderTop: '1px solid rgba(255, 255, 255, 0.08)',
          paddingTop: 14,
        }}
      >
        <div
          style={{
            width: 36,
            height: 36,
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.12)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#ffffff',
            flexShrink: 0,
          }}
        >
          <User size={18} strokeWidth={1.7} />
        </div>

        {!isCollapsed && (
          <>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 600, color: '#ffffff', lineHeight: 1.2 }}>
                My Vault
              </div>
              <div
                style={{
                  fontSize: 11,
                  color: 'rgba(255, 255, 255, 0.60)',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 4,
                  marginTop: 2,
                }}
              >
                <RefreshCw size={11} color="#6fa8ff" strokeWidth={2} />
                <span>Synced just now</span>
              </div>
            </div>

            <button
              type="button"
              aria-label="Settings"
              onClick={() => onNavChange('settings')}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'rgba(255, 255, 255, 0.60)',
                cursor: 'pointer',
                padding: 6,
                borderRadius: 8,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.color = '#ffffff')}
              onMouseLeave={(e) => (e.currentTarget.style.color = 'rgba(255, 255, 255, 0.60)')}
            >
              <Settings size={18} strokeWidth={1.7} />
            </button>
          </>
        )}
      </div>
    </aside>
  );
}

export default Sidebar;
