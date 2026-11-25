import React from 'react';
import {
  ShieldCheck,
  AlertTriangle,
  RefreshCw,
  Clock,
  KeyRound,
  CheckCircle2,
} from 'lucide-react';
import { VaultHealthRing } from '../../components/VaultHealthRing';
import { TabBar, type TabKey } from '../../components/TabBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';
import { HEALTH_SCORE } from '../../data/mockData';

interface SecurityScreenProps {
  activeTab?: TabKey;
  onTabChange?: (tab: TabKey) => void;
  isMobile?: boolean;
}

export function SecurityScreen({
  activeTab = 'security',
  onTabChange,
  isMobile = false,
}: SecurityScreenProps) {
  const issues = [
    { title: 'Weak passwords', count: 3, desc: 'Passwords with low entropy or fewer than 12 characters', severity: 'warning', items: ['Netflix', 'Spotify', 'V2Ray Panel'] },
    { title: 'Reused passwords', count: 2, desc: 'Same password used across multiple accounts', severity: 'warning', items: ['Gmail', 'Netflix'] },
    { title: 'Data breaches check', count: 0, desc: 'Monitored against HaveIBeenPwned database', severity: 'safe', items: [] },
    { title: 'Old passwords', count: 4, desc: 'Unchanged for more than 180 days', severity: 'info', items: ['DigitalOcean', 'Bank Card'] },
    { title: '2FA available', count: 2, desc: 'Accounts supporting authenticator 2FA', severity: 'info', items: ['Spotify', 'DigitalOcean'] },
  ];

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
            Security Centre
          </h1>
          <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 4 }}>
            Continuous zero-knowledge analysis of your vault credentials
          </p>
        </div>

        {/* Big Health Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 24,
            background: tokens.heroGradient,
            position: 'relative',
            overflow: 'hidden',
            boxShadow: '0 20px 50px rgba(5,16,38,.4)',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            gap: 22,
          }}
        >
          {/* Highlight */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              background: 'radial-gradient(400px 200px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
              pointerEvents: 'none',
            }}
          />

          <div style={{ position: 'relative', zIndex: 1, display: 'flex', alignItems: 'center', gap: 20, width: '100%' }}>
            <VaultHealthRing
              score={HEALTH_SCORE}
              size="desktop"
              overrideTrack="rgba(255, 255, 255, 0.2)"
              overrideFill="#7fe0b0"
              overrideText="#ffffff"
            />

            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 18, fontWeight: 800, color: '#ffffff' }}>
                Overall Vault Health: 82 / 100
              </div>
              <div style={{ fontSize: 13, color: '#cfe0ff', marginTop: 4, lineHeight: 1.4 }}>
                Your vault is strongly secured. Resolving 3 weak passwords will bring your score to 96+.
              </div>
            </div>
          </div>
        </div>

        {/* Categories List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {issues.map((issue) => (
            <div
              key={issue.title}
              style={{
                background: 'var(--card)',
                border: '1px solid var(--card-border)',
                borderRadius: tokens.radii.card,
                padding: '16px 20px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
                gap: 16,
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    background:
                      issue.severity === 'safe'
                        ? 'rgba(47, 182, 124, 0.12)'
                        : issue.severity === 'warning'
                        ? 'rgba(245, 196, 81, 0.12)'
                        : 'var(--selected-bg)',
                    color:
                      issue.severity === 'safe'
                        ? '#2fb67c'
                        : issue.severity === 'warning'
                        ? '#f5c451'
                        : 'var(--accent)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}
                >
                  {issue.severity === 'safe' ? (
                    <CheckCircle2 size={20} strokeWidth={2} />
                  ) : (
                    <AlertTriangle size={20} strokeWidth={2} />
                  )}
                </div>

                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 14, fontWeight: 600, color: 'var(--text)' }}>
                      {issue.title}
                    </span>
                    {issue.count > 0 && (
                      <span
                        style={{
                          fontSize: 11,
                          fontWeight: 700,
                          padding: '2px 7px',
                          borderRadius: 6,
                          background: issue.severity === 'warning' ? 'rgba(245, 196, 81, 0.2)' : 'var(--selected-bg)',
                          color: issue.severity === 'warning' ? '#f5c451' : 'var(--accent)',
                        }}
                      >
                        {issue.count}
                      </span>
                    )}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                    {issue.desc}
                  </div>
                </div>
              </div>

              {issue.count > 0 ? (
                <button
                  type="button"
                  onClick={() => showToast(`Viewing items for ${issue.title}`)}
                  style={{
                    padding: '8px 16px',
                    borderRadius: 10,
                    background: 'var(--selected-bg)',
                    border: '1px solid var(--selected-border)',
                    color: 'var(--accent)',
                    fontSize: 12,
                    fontWeight: 600,
                    cursor: 'pointer',
                    whiteSpace: 'nowrap',
                  }}
                >
                  Fix
                </button>
              ) : (
                <span style={{ fontSize: 12, color: '#2fb67c', fontWeight: 600, whiteSpace: 'nowrap' }}>
                  ✓ Secure
                </span>
              )}
            </div>
          ))}
        </div>
      </div>

      {isMobile && onTabChange && <TabBar activeTab={activeTab} onChange={onTabChange} />}
    </div>
  );
}

export default SecurityScreen;
