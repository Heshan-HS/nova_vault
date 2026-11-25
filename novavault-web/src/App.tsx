import React, { useState } from 'react';
import { ThemeProvider, useTheme } from './theme/ThemeProvider';
import { DesktopLayout } from './pages/desktop/DesktopLayout';
import { MobileLayout } from './pages/mobile/MobileLayout';
import { UnlockScreen } from './pages/screens/UnlockScreen';
import { AddItemModal } from './pages/screens/AddItemModal';
import { GeneratorScreen } from './pages/screens/GeneratorScreen';
import { SettingsScreen } from './pages/screens/SettingsScreen';
import { ToastContainer } from './components/Toast';
import { Monitor, Smartphone, Columns, Moon, Sun, Lock, Plus } from 'lucide-react';
import type { VaultListItem } from './pages/desktop/ListPane';
import { MOCK_ITEMS } from './data/mockData';

type ViewMode = 'desktop' | 'mobile' | 'comparison';

function NovaVaultRoot() {
  const { theme, setTheme, resolvedTheme } = useTheme();
  const [isLocked, setIsLocked] = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>('desktop');
  const [showAddModal, setShowAddModal] = useState(false);
  const [activeModalScreen, setActiveModalScreen] = useState<'generator' | 'settings' | null>(null);
  const [items, setItems] = useState<VaultListItem[]>(MOCK_ITEMS);

  const handleAddItem = (newItem: VaultListItem) => {
    setItems((prev) => [newItem, ...prev]);
  };

  if (isLocked) {
    return <UnlockScreen onUnlock={() => setIsLocked(false)} />;
  }

  return (
    <div
      style={{
        width: '100vw',
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        background: 'var(--bg)',
      }}
    >
      {/* Top Preview Control Bar (Executive Switcher) */}
      <header
        style={{
          height: 44,
          background: 'rgba(5, 16, 38, 0.95)',
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 16px',
          zIndex: 999,
          flexShrink: 0,
          userSelect: 'none',
        }}
      >
        {/* Left: View Modes */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ fontSize: 11, fontWeight: 700, color: 'rgba(255,255,255,0.45)', textTransform: 'uppercase', letterSpacing: '0.8px', marginRight: 4 }}>
            DEVICE VIEW:
          </span>

          {[
            { mode: 'desktop' as const, label: 'Desktop (3-Pane)', icon: <Monitor size={14} /> },
            { mode: 'mobile' as const, label: 'Mobile (390px)', icon: <Smartphone size={14} /> },
            { mode: 'comparison' as const, label: 'Desktop + Mobile Mockup', icon: <Columns size={14} /> },
          ].map((btn) => (
            <button
              key={btn.mode}
              type="button"
              onClick={() => setViewMode(btn.mode)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 6,
                padding: '4px 10px',
                borderRadius: 8,
                fontSize: 12,
                fontWeight: viewMode === btn.mode ? 600 : 500,
                background: viewMode === btn.mode ? 'rgba(47, 111, 224, 0.3)' : 'transparent',
                border: viewMode === btn.mode ? '1px solid rgba(111, 168, 255, 0.4)' : '1px solid transparent',
                color: viewMode === btn.mode ? '#8db8ff' : 'rgba(255,255,255,0.6)',
                cursor: 'pointer',
                transition: 'all 120ms ease',
              }}
            >
              {btn.icon}
              <span>{btn.label}</span>
            </button>
          ))}
        </div>

        {/* Right: Theme Switcher & Actions */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          {/* Quick theme toggler */}
          <div
            style={{
              display: 'flex',
              background: 'rgba(255, 255, 255, 0.06)',
              borderRadius: 8,
              padding: 2,
              border: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            <button
              type="button"
              aria-label="Light mode"
              title="Light theme"
              onClick={() => setTheme('light')}
              style={{
                padding: '4px 8px',
                borderRadius: 6,
                background: resolvedTheme === 'light' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                color: resolvedTheme === 'light' ? '#ffffff' : 'rgba(255, 255, 255, 0.5)',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
              }}
            >
              <Sun size={13} />
            </button>
            <button
              type="button"
              aria-label="Dark mode"
              title="Dark theme"
              onClick={() => setTheme('dark')}
              style={{
                padding: '4px 8px',
                borderRadius: 6,
                background: resolvedTheme === 'dark' ? 'rgba(47, 111, 224, 0.4)' : 'transparent',
                color: resolvedTheme === 'dark' ? '#8db8ff' : 'rgba(255, 255, 255, 0.5)',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
              }}
            >
              <Moon size={13} />
            </button>
          </div>

          {/* New Item Quick Button */}
          <button
            type="button"
            onClick={() => setShowAddModal(true)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 5,
              padding: '4px 10px',
              borderRadius: 8,
              background: 'linear-gradient(135deg, rgb(11,60,143), #2f6fe0)',
              color: '#ffffff',
              fontSize: 12,
              fontWeight: 600,
              border: 'none',
              cursor: 'pointer',
            }}
          >
            <Plus size={13} strokeWidth={2.5} />
            <span>New</span>
          </button>

          {/* Lock Vault */}
          <button
            type="button"
            onClick={() => setIsLocked(true)}
            title="Lock Vault"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 5,
              padding: '4px 8px',
              borderRadius: 8,
              background: 'rgba(220, 38, 38, 0.15)',
              border: '1px solid rgba(220, 38, 38, 0.3)',
              color: '#f87171',
              fontSize: 12,
              fontWeight: 500,
              cursor: 'pointer',
            }}
          >
            <Lock size={12} />
            <span>Lock</span>
          </button>
        </div>
      </header>

      {/* Main View Area */}
      <main style={{ flex: 1, overflow: 'hidden', display: 'flex', position: 'relative' }}>
        {viewMode === 'desktop' ? (
          <DesktopLayout
            onNewItem={() => setShowAddModal(true)}
            onOpenGenerator={() => setActiveModalScreen('generator')}
            onOpenSettings={() => setActiveModalScreen('settings')}
          />
        ) : viewMode === 'mobile' ? (
          <div
            style={{
              flex: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '20px 0',
              background: resolvedTheme === 'dark' ? '#030712' : '#e2e8f0',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                width: 390,
                height: 844,
                borderRadius: 44,
                overflow: 'hidden',
                boxShadow: '0 25px 80px rgba(0,0,0,0.6)',
                border: '8px solid #1e293b',
                display: 'flex',
                flexDirection: 'column',
                position: 'relative',
              }}
            >
              {/* Phone Dynamic Island */}
              <div
                style={{
                  position: 'absolute',
                  top: 10,
                  left: '50%',
                  transform: 'translateX(-50%)',
                  width: 100,
                  height: 24,
                  borderRadius: 20,
                  background: '#000000',
                  zIndex: 9999,
                }}
              />
              <MobileLayout
                onNewItem={() => setShowAddModal(true)}
                onLockVault={() => setIsLocked(true)}
              />
            </div>
          </div>
        ) : (
          /* Comparison View: Desktop + Mobile side by side */
          <div
            style={{
              flex: 1,
              display: 'flex',
              gap: 24,
              padding: 24,
              overflowX: 'auto',
              background: resolvedTheme === 'dark' ? '#030712' : '#cbd5e1',
            }}
          >
            {/* Desktop Mockup Card */}
            <div
              style={{
                flex: 1,
                minWidth: 900,
                height: '100%',
                borderRadius: 18,
                overflow: 'hidden',
                boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
                border: '1px solid rgba(255,255,255,0.1)',
                display: 'flex',
                flexDirection: 'column',
              }}
            >
              <div style={{ background: '#0f172a', padding: '8px 14px', fontSize: 11, fontWeight: 600, color: '#94a3b8', display: 'flex', gap: 6, alignItems: 'center' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#ef4444' }} />
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#f59e0b' }} />
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#10b981' }} />
                <span style={{ marginLeft: 8 }}>NovaVault Desktop — {resolvedTheme === 'dark' ? 'Dark Mode' : 'Light Mode'}</span>
              </div>
              <div style={{ flex: 1, overflow: 'hidden' }}>
                <DesktopLayout
                  onNewItem={() => setShowAddModal(true)}
                  onOpenGenerator={() => setActiveModalScreen('generator')}
                  onOpenSettings={() => setActiveModalScreen('settings')}
                />
              </div>
            </div>

            {/* Mobile Phone Mockup */}
            <div
              style={{
                width: 390,
                height: '100%',
                maxHeight: 844,
                borderRadius: 44,
                overflow: 'hidden',
                boxShadow: '0 25px 80px rgba(0,0,0,0.6)',
                border: '8px solid #1e293b',
                display: 'flex',
                flexDirection: 'column',
                position: 'relative',
                flexShrink: 0,
              }}
            >
              <div
                style={{
                  position: 'absolute',
                  top: 10,
                  left: '50%',
                  transform: 'translateX(-50%)',
                  width: 100,
                  height: 24,
                  borderRadius: 20,
                  background: '#000000',
                  zIndex: 9999,
                }}
              />
              <MobileLayout
                onNewItem={() => setShowAddModal(true)}
                onLockVault={() => setIsLocked(true)}
              />
            </div>
          </div>
        )}
      </main>

      {/* Add Item Modal */}
      {showAddModal && (
        <AddItemModal
          onClose={() => setShowAddModal(false)}
          onSave={handleAddItem}
        />
      )}

      {/* Generator Screen Full Modal */}
      {activeModalScreen === 'generator' && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 9999,
            background: 'rgba(5, 16, 38, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 24,
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) setActiveModalScreen(null);
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: 680,
              maxHeight: '90vh',
              borderRadius: 20,
              overflow: 'hidden',
              background: 'var(--bg)',
              border: '1px solid var(--card-border)',
              display: 'flex',
              flexDirection: 'column',
              boxShadow: 'var(--shadow)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '12px 16px 0' }}>
              <button
                type="button"
                onClick={() => setActiveModalScreen(null)}
                style={{
                  padding: '6px 14px',
                  borderRadius: 8,
                  background: 'var(--card)',
                  border: '1px solid var(--card-border)',
                  color: 'var(--text)',
                  fontSize: 12,
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Close
              </button>
            </div>
            <div style={{ flex: 1, overflowY: 'auto' }}>
              <GeneratorScreen isMobile={false} />
            </div>
          </div>
        </div>
      )}

      {/* Settings Screen Full Modal */}
      {activeModalScreen === 'settings' && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 9999,
            background: 'rgba(5, 16, 38, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 24,
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) setActiveModalScreen(null);
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: 680,
              maxHeight: '90vh',
              borderRadius: 20,
              overflow: 'hidden',
              background: 'var(--bg)',
              border: '1px solid var(--card-border)',
              display: 'flex',
              flexDirection: 'column',
              boxShadow: 'var(--shadow)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '12px 16px 0' }}>
              <button
                type="button"
                onClick={() => setActiveModalScreen(null)}
                style={{
                  padding: '6px 14px',
                  borderRadius: 8,
                  background: 'var(--card)',
                  border: '1px solid var(--card-border)',
                  color: 'var(--text)',
                  fontSize: 12,
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Close
              </button>
            </div>
            <div style={{ flex: 1, overflowY: 'auto' }}>
              <SettingsScreen
                isMobile={false}
                onLockVault={() => {
                  setActiveModalScreen(null);
                  setIsLocked(true);
                }}
              />
            </div>
          </div>
        </div>
      )}

      {/* Global Toast Container */}
      <ToastContainer />
    </div>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <NovaVaultRoot />
    </ThemeProvider>
  );
}
