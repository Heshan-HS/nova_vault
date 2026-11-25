import React from 'react';
import { Shield, Wand2, ShieldCheck, Settings } from 'lucide-react';
import { tokens } from '../tokens';

export type TabKey = 'vault' | 'generator' | 'security' | 'settings';

interface TabBarProps {
  activeTab: TabKey;
  onChange: (tab: TabKey) => void;
}

export function TabBar({ activeTab, onChange }: TabBarProps) {
  const tabs = [
    { key: 'vault' as TabKey, label: 'Vault', icon: <Shield size={20} strokeWidth={1.7} /> },
    { key: 'generator' as TabKey, label: 'Generator', icon: <Wand2 size={20} strokeWidth={1.7} /> },
    { key: 'security' as TabKey, label: 'Security', icon: <ShieldCheck size={20} strokeWidth={1.7} /> },
    { key: 'settings' as TabKey, label: 'Settings', icon: <Settings size={20} strokeWidth={1.7} /> },
  ];

  return (
    <div
      style={{
        position: 'fixed',
        bottom: 'calc(16px + env(safe-area-inset-bottom, 0px))',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 100,
        background: 'var(--card)',
        border: '1px solid var(--card-border)',
        borderRadius: tokens.radii.tabBar,
        padding: 6,
        display: 'flex',
        gap: 4,
        boxShadow: 'var(--shadow)',
      }}
    >
      {tabs.map((tab) => {
        const isActive = activeTab === tab.key;
        return (
          <button
            key={tab.key}
            type="button"
            onClick={() => onChange(tab.key)}
            style={{
              minHeight: 48,
              minWidth: 72,
              borderRadius: 14,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 3,
              background: isActive ? 'var(--selected-bg)' : 'transparent',
              color: isActive ? 'var(--accent)' : 'var(--muted)',
              border: 'none',
              cursor: 'pointer',
              fontWeight: isActive ? 600 : 500,
              transition: 'all 150ms ease-out',
            }}
          >
            {tab.icon}
            <span style={{ fontSize: 11 }}>{tab.label}</span>
          </button>
        );
      })}
    </div>
  );
}

export default TabBar;
