import React from 'react';
import {
  Sun,
  Moon,
  Monitor,
  Fingerprint,
  Clock,
  Shield,
  Download,
  Upload,
  Lock,
  RefreshCw,
  Smartphone,
  Laptop,
} from 'lucide-react';
import { useTheme, type ThemeOption } from '../../theme/ThemeProvider';
import { TabBar, type TabKey } from '../../components/TabBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';

interface SettingsScreenProps {
  activeTab?: TabKey;
  onTabChange?: (tab: TabKey) => void;
  onLockVault?: () => void;
  isMobile?: boolean;
}

export function SettingsScreen({
  activeTab = 'settings',
  onTabChange,
  onLockVault,
  isMobile = false,
}: SettingsScreenProps) {
  const { theme, setTheme, resolvedTheme } = useTheme();

  const themes: { key: ThemeOption; label: string; icon: React.ReactNode }[] = [
    { key: 'light', label: 'Light', icon: <Sun size={16} strokeWidth={1.8} /> },
    { key: 'dark', label: 'Dark', icon: <Moon size={16} strokeWidth={1.8} /> },
    { key: 'system', label: 'System', icon: <Monitor size={16} strokeWidth={1.8} /> },
  ];

  const handleExport = () => {
    const data = JSON.stringify({ vault: 'NovaVault Encrypted Export', version: 1, exportedAt: new Date().toISOString() }, null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `novavault-backup-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    showToast('Vault backup exported');
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: 'var(--bg)',
        padding: isMobile ? '28px 20px 100px 20px' : '36px 40px',
        display: 'flex',
        flexDirection: 'column',
        boxSizing: 'border-box',
        overflowY: 'auto',
      }}
    >
      <div style={{ maxWidth: 640, width: '100%', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Header */}
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--text)', margin: 0, letterSpacing: '-0.4px' }}>
            Settings
          </h1>
          <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 4 }}>
            Manage appearance, zero-knowledge encryption, and sync
          </p>
        </div>

        {/* 1. Appearance Section */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: tokens.radii.card,
            padding: 20,
            boxShadow: 'var(--shadow)',
          }}
        >
          <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text)', textTransform: 'uppercase', letterSpacing: '0.8px', marginBottom: 12 }}>
            Appearance
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
            {themes.map((t) => {
              const isActive = theme === t.key;
              return (
                <button
                  key={t.key}
                  type="button"
                  onClick={() => setTheme(t.key)}
                  style={{
                    padding: '12px 10px',
                    borderRadius: 12,
                    background: isActive ? 'var(--selected-bg)' : 'transparent',
                    border: isActive ? '1px solid var(--selected-border)' : '1px solid var(--card-border)',
                    color: isActive ? 'var(--accent)' : 'var(--muted)',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: 6,
                    cursor: 'pointer',
                    fontWeight: isActive ? 600 : 500,
                    fontSize: 13,
                    transition: 'all 150ms ease',
                  }}
                >
                  {t.icon}
                  <span>{t.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* 2. Security & Biometrics */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: tokens.radii.card,
            padding: 20,
            display: 'flex',
            flexDirection: 'column',
            gap: 16,
            boxShadow: 'var(--shadow)',
          }}
        >
          <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text)', textTransform: 'uppercase', letterSpacing: '0.8px' }}>
            Security & Auto-Lock
          </div>

          {/* Biometrics */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--selected-bg)', color: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Fingerprint size={18} strokeWidth={1.8} />
              </div>
              <div>
                <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--text)' }}>
                  Biometric Unlock
                </div>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>
                  Windows Hello / Touch ID / Face ID
                </div>
              </div>
            </div>
            <input type="checkbox" defaultChecked style={{ accentColor: 'var(--accent)', width: 20, height: 20, cursor: 'pointer' }} />
          </div>

          {/* Auto-Lock Timeout */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderTop: '1px solid var(--card-border)', paddingTop: 14 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--selected-bg)', color: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Clock size={18} strokeWidth={1.8} />
              </div>
              <div>
                <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--text)' }}>
                  Auto-Lock Timeout
                </div>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>
                  Lock vault on inactivity
                </div>
              </div>
            </div>
            <select
              defaultValue="15m"
              style={{
                background: 'var(--input-bg)',
                border: '1px solid var(--input-border)',
                color: 'var(--text)',
                padding: '6px 12px',
                borderRadius: 8,
                fontSize: 13,
                outline: 'none',
              }}
            >
              <option value="1m">1 minute</option>
              <option value="5m">5 minutes</option>
              <option value="15m">15 minutes</option>
              <option value="never">Never</option>
            </select>
          </div>

          {/* Clipboard Clear */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderTop: '1px solid var(--card-border)', paddingTop: 14 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--selected-bg)', color: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Shield size={18} strokeWidth={1.8} />
              </div>
              <div>
                <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--text)' }}>
                  Clipboard Auto-Clear
                </div>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>
                  Erase copied passwords after
                </div>
              </div>
            </div>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--accent)' }}>30 seconds</span>
          </div>
        </div>

        {/* 3. Sync & Devices */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: tokens.radii.card,
            padding: 20,
            display: 'flex',
            flexDirection: 'column',
            gap: 14,
            boxShadow: 'var(--shadow)',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text)', textTransform: 'uppercase', letterSpacing: '0.8px' }}>
              Connected Devices
            </div>
            <button
              type="button"
              onClick={() => showToast('Vault synchronized')}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'var(--accent)',
                fontSize: 12,
                fontWeight: 600,
                display: 'flex',
                alignItems: 'center',
                gap: 5,
                cursor: 'pointer',
              }}
            >
              <RefreshCw size={12} strokeWidth={2} />
              <span>Sync Now</span>
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0' }}>
              <Laptop size={18} color="var(--accent)" strokeWidth={1.8} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text)' }}>Windows PC (This device)</div>
                <div style={{ fontSize: 11, color: 'var(--muted)' }}>Synced just now · Active session</div>
              </div>
              <span style={{ fontSize: 11, color: '#2fb67c', fontWeight: 600 }}>Connected</span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0', borderTop: '1px solid var(--card-border)' }}>
              <Smartphone size={18} color="var(--muted)" strokeWidth={1.8} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text)' }}>iPhone 15 Pro</div>
                <div style={{ fontSize: 11, color: 'var(--muted)' }}>Synced 12 mins ago</div>
              </div>
              <span style={{ fontSize: 11, color: '#2fb67c', fontWeight: 600 }}>Connected</span>
            </div>
          </div>
        </div>

        {/* 4. Backup & Lock Buttons */}
        <div style={{ display: 'flex', gap: 12 }}>
          <button
            type="button"
            onClick={handleExport}
            style={{
              flex: 1,
              height: 44,
              borderRadius: 12,
              background: 'var(--card)',
              border: '1px solid var(--card-border)',
              color: 'var(--text)',
              fontSize: 13,
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              cursor: 'pointer',
            }}
          >
            <Download size={16} strokeWidth={1.8} />
            <span>Export Backup</span>
          </button>

          <button
            type="button"
            onClick={onLockVault}
            style={{
              flex: 1,
              height: 44,
              borderRadius: 12,
              background: 'rgba(220, 38, 38, 0.1)',
              border: '1px solid rgba(220, 38, 38, 0.25)',
              color: '#ef4444',
              fontSize: 13,
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              cursor: 'pointer',
            }}
          >
            <Lock size={16} strokeWidth={1.8} />
            <span>Lock Vault</span>
          </button>
        </div>
      </div>

      {isMobile && onTabChange && <TabBar activeTab={activeTab} onChange={onTabChange} />}
    </div>
  );
}

export default SettingsScreen;
