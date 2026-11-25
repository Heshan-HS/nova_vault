import React, { useState } from 'react';
import {
  ChevronLeft,
  Star,
  Edit3,
  ShieldCheck,
  User,
  KeyRound,
  Globe,
  Clock,
  MoreHorizontal,
  Copy,
  Check,
} from 'lucide-react';
import { FieldRow } from '../../components/FieldRow';
import { TOTPRing } from '../../components/TOTPRing';
import { TabBar, type TabKey } from '../../components/TabBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';
import type { VaultListItem } from '../desktop/ListPane';

interface MobileItemDetailProps {
  item: VaultListItem;
  onBack: () => void;
  activeTab: TabKey;
  onTabChange: (tab: TabKey) => void;
  onEdit?: (item: VaultListItem) => void;
}

export function MobileItemDetail({
  item,
  onBack,
  activeTab,
  onTabChange,
  onEdit,
}: MobileItemDetailProps) {
  const [isFav, setIsFav] = useState(item.favourite);
  const [totpCopied, setTotpCopied] = useState(false);

  const handleCopyTotp = () => {
    navigator.clipboard.writeText('482913');
    setTotpCopied(true);
    showToast('Authenticator code copied');
    setTimeout(() => setTotpCopied(false), 1200);
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: 'var(--bg)',
        paddingBottom: 90,
        display: 'flex',
        flexDirection: 'column',
        boxSizing: 'border-box',
        overflowY: 'auto',
      }}
    >
      {/* 1. Gradient Header (radius 0 0 30px 30px) */}
      <div
        style={{
          borderRadius: '0 0 30px 30px',
          padding: '24px 20px 24px',
          background: tokens.heroGradient,
          position: 'relative',
          overflow: 'hidden',
          color: '#ffffff',
          boxShadow: '0 10px 30px rgba(5,16,38,.4)',
          flexShrink: 0,
        }}
      >
        {/* Soft radial highlight */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'radial-gradient(350px 180px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
            pointerEvents: 'none',
          }}
        />

        <div style={{ position: 'relative', zIndex: 1 }}>
          {/* Top action row */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <button
              type="button"
              aria-label="Back to vault list"
              onClick={onBack}
              style={{
                width: 44,
                height: 44,
                borderRadius: 12,
                background: 'rgba(255, 255, 255, 0.1)',
                border: 'none',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <ChevronLeft size={22} strokeWidth={2} />
            </button>

            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <button
                type="button"
                aria-label="Favorite item"
                onClick={() => setIsFav(!isFav)}
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 12,
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: 'none',
                  color: isFav ? '#f5c451' : '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <Star size={20} strokeWidth={1.8} fill={isFav ? '#f5c451' : 'none'} />
              </button>
              <button
                type="button"
                aria-label="Edit item"
                onClick={() => onEdit && onEdit(item)}
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 12,
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: 'none',
                  color: '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <Edit3 size={19} strokeWidth={1.8} />
              </button>
            </div>
          </div>

          {/* Avatar + Title + Subline */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 16,
              marginTop: 18,
            }}
          >
            <div
              style={{
                width: 60,
                height: 60,
                borderRadius: 18,
                background: 'rgba(255, 255, 255, 0.16)',
                border: '1px solid rgba(255, 255, 255, 0.25)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 22,
                fontWeight: 800,
                color: '#ffffff',
                boxShadow: '0 6px 16px rgba(11,60,143,.4)',
              }}
            >
              {item.name.charAt(0).toUpperCase()}
            </div>

            <div>
              <h1
                style={{
                  fontSize: 24,
                  fontWeight: 800,
                  letterSpacing: '-0.4px',
                  margin: 0,
                  color: '#ffffff',
                  lineHeight: 1.1,
                }}
              >
                {item.name}
              </h1>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 6,
                  marginTop: 6,
                  fontSize: 13,
                  color: '#cfe0ff',
                  fontWeight: 500,
                }}
              >
                <ShieldCheck size={14} color="#7fe0b0" strokeWidth={2.2} />
                <span>Strong · {item.folder || 'Work'}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 2. Body Fields */}
      <div
        style={{
          padding: '16px 20px 0',
          display: 'flex',
          flexDirection: 'column',
          gap: 12,
        }}
      >
        {/* Username */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: 16,
            padding: '4px 16px',
            boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
          }}
        >
          <FieldRow
            icon={<User size={18} strokeWidth={1.7} />}
            label="Username"
            value={item.username || 'dev@example.com'}
            canCopy={true}
            isLast={true}
          />
        </div>

        {/* Password */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: 16,
            padding: '4px 16px',
            boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
          }}
        >
          <FieldRow
            icon={<KeyRound size={18} strokeWidth={1.7} />}
            label="Password"
            value={item.password || '••••••••••••'}
            masked={true}
            canReveal={true}
            canCopy={true}
            isLast={true}
          />
        </div>

        {/* TOTP Card */}
        <div
          style={{
            borderRadius: 18,
            padding: 16,
            background: tokens.heroGradient,
            position: 'relative',
            overflow: 'hidden',
            color: '#ffffff',
            boxShadow: '0 10px 26px rgba(5,16,38,.45)',
          }}
        >
          {/* Radial overlay */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              background: 'radial-gradient(300px 150px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
              pointerEvents: 'none',
            }}
          />

          <div style={{ position: 'relative', zIndex: 1 }}>
            <div
              style={{
                fontSize: 12,
                fontWeight: 600,
                color: '#cfe0ff',
                marginBottom: 10,
              }}
            >
              Authenticator code
            </div>

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
                <TOTPRing
                  secondsLeft={18}
                  period={30}
                  code="482 913"
                  size="mobile"
                  showCode={false}
                />
                <div
                  style={{
                    fontSize: 30,
                    fontWeight: 800,
                    letterSpacing: '4px',
                    color: '#ffffff',
                    fontFamily: 'Inter, sans-serif',
                  }}
                >
                  482 913
                </div>
              </div>

              <button
                type="button"
                aria-label="Copy code"
                onClick={handleCopyTotp}
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 12,
                  background: 'rgba(255, 255, 255, 0.15)',
                  border: 'none',
                  color: totpCopied ? '#7fe0b0' : '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                {totpCopied ? (
                  <Check size={20} strokeWidth={2.2} />
                ) : (
                  <Copy size={20} strokeWidth={1.8} />
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Website */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: 16,
            padding: '4px 16px',
            boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
          }}
        >
          <FieldRow
            icon={<Globe size={18} strokeWidth={1.7} />}
            label="Website"
            value={item.url || 'github.com'}
            canCopy={true}
            externalUrl={item.url || 'github.com'}
            isLast={true}
          />
        </div>

        {/* Last Changed */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: 16,
            padding: '14px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div
              style={{
                width: 36,
                height: 36,
                borderRadius: 10,
                background: 'var(--selected-bg)',
                color: 'var(--accent)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Clock size={18} strokeWidth={1.7} />
            </div>
            <div>
              <div style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>
                Last changed
              </div>
              <div style={{ fontSize: 14, fontWeight: 500, color: 'var(--text)' }}>
                Today
              </div>
            </div>
          </div>

          <button
            type="button"
            aria-label="More options"
            onClick={() => showToast('History details')}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'var(--muted)',
              cursor: 'pointer',
              padding: 6,
            }}
          >
            <MoreHorizontal size={20} strokeWidth={1.7} />
          </button>
        </div>
      </div>

      {/* 3. Floating Tab Bar */}
      <TabBar activeTab={activeTab} onChange={onTabChange} />
    </div>
  );
}

export default MobileItemDetail;
