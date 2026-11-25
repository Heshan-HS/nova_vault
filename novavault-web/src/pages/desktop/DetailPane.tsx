import React, { useState } from 'react';
import {
  Star,
  Edit3,
  MoreHorizontal,
  Plus,
  Lock,
  Briefcase,
  ShieldCheck,
  Globe,
  User,
  KeyRound,
  Clock,
  Copy,
  Check,
} from 'lucide-react';
import { IconButton } from '../../components/IconButton';
import { PrimaryButton } from '../../components/PrimaryButton';
import { ItemAvatar } from '../../components/ItemAvatar';
import { FieldRow } from '../../components/FieldRow';
import { TOTPRing } from '../../components/TOTPRing';
import { StrengthBar } from '../../components/StrengthBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';
import type { VaultListItem } from './ListPane';

interface DetailPaneProps {
  item: VaultListItem | null;
  onFavourite?: (id: string) => void;
  onEdit?: (item: VaultListItem) => void;
  onNewItem?: () => void;
}

export function DetailPane({
  item,
  onFavourite,
  onEdit,
  onNewItem,
}: DetailPaneProps) {
  const [totpCopied, setTotpCopied] = useState(false);

  if (!item) {
    return (
      <div
        style={{
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'var(--muted)',
          fontSize: 14,
        }}
      >
        Select an item to view details
      </div>
    );
  }

  const handleCopyTotp = () => {
    navigator.clipboard.writeText('482913');
    setTotpCopied(true);
    showToast('Authenticator code copied');
    setTimeout(() => setTotpCopied(false), 1200);
  };

  const isFavourite = item.favourite;

  return (
    <div
      style={{
        flex: 1,
        padding: '24px 36px',
        display: 'flex',
        flexDirection: 'column',
        gap: 18,
        overflowY: 'auto',
        minWidth: 0,
      }}
    >
      {/* 1. Top Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexShrink: 0,
        }}
      >
        {/* Breadcrumb */}
        <div style={{ fontSize: 13, display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ color: 'var(--muted)' }}>All items</span>
          <span style={{ color: 'var(--muted)' }}>/</span>
          <span style={{ color: 'var(--text)', fontWeight: 600 }}>{item.name}</span>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <IconButton
            icon={
              <Star
                size={18}
                strokeWidth={1.8}
                fill={isFavourite ? '#f5c451' : 'none'}
                color={isFavourite ? '#f5c451' : 'currentColor'}
              />
            }
            label={isFavourite ? 'Remove from favorites' : 'Add to favorites'}
            onClick={() => onFavourite && onFavourite(item.id)}
            active={isFavourite}
          />
          <IconButton
            icon={<Edit3 size={18} strokeWidth={1.7} />}
            label="Edit item"
            onClick={() => onEdit && onEdit(item)}
          />
          <IconButton
            icon={<MoreHorizontal size={18} strokeWidth={1.7} />}
            label="More actions"
            onClick={() => showToast('More actions menu')}
          />
          <PrimaryButton
            icon={<Plus size={16} strokeWidth={2} />}
            onClick={onNewItem}
          >
            New item
          </PrimaryButton>
        </div>
      </div>

      {/* 2. Hero Card */}
      <div
        style={{
          borderRadius: tokens.radii.hero,
          padding: 26,
          background: tokens.heroGradient,
          position: 'relative',
          overflow: 'hidden',
          boxShadow: tokens.radii.card ? '0 20px 50px rgba(0,0,0,.35)' : undefined,
          color: '#ffffff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexShrink: 0,
        }}
      >
        {/* Soft radial highlight */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: tokens.heroHighlight,
            pointerEvents: 'none',
          }}
        />

        {/* Hero Left: Avatar + Title + Tags */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 20,
            position: 'relative',
            zIndex: 1,
          }}
        >
          {/* 64px avatar with overlay tint */}
          <div
            style={{
              width: 64,
              height: 64,
              borderRadius: tokens.radii.avatarHero,
              background: 'rgba(255, 255, 255, 0.16)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 24,
              fontWeight: 800,
              color: '#ffffff',
              boxShadow: '0 6px 16px rgba(11,60,143,.4)',
              border: '1px solid rgba(255, 255, 255, 0.2)',
            }}
          >
            {item.name.charAt(0).toUpperCase()}
          </div>

          <div>
            <h1
              style={{
                fontSize: 28,
                fontWeight: 800,
                letterSpacing: '-0.5px',
                margin: 0,
                color: '#ffffff',
                lineHeight: 1.1,
              }}
            >
              {item.name}
            </h1>

            {/* Tags row */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 10 }}>
              {/* Login Tag */}
              <div
                style={{
                  fontSize: 12,
                  fontWeight: 600,
                  padding: '5px 10px',
                  borderRadius: 8,
                  background: 'rgba(255, 255, 255, 0.14)',
                  color: '#ffffff',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: 5,
                }}
              >
                <Lock size={13} strokeWidth={1.8} />
                <span>Login</span>
              </div>

              {/* Folder / Work Tag */}
              {item.folder && (
                <div
                  style={{
                    fontSize: 12,
                    fontWeight: 600,
                    padding: '5px 10px',
                    borderRadius: 8,
                    background: 'rgba(255, 255, 255, 0.14)',
                    color: '#ffffff',
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: 5,
                  }}
                >
                  <Briefcase size={13} strokeWidth={1.8} />
                  <span>{item.folder}</span>
                </div>
              )}

              {/* Strong security Tag */}
              <div
                style={{
                  fontSize: 12,
                  fontWeight: 600,
                  padding: '5px 10px',
                  borderRadius: 8,
                  background: 'rgba(80, 200, 140, 0.25)',
                  color: '#7fe0b0',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: 5,
                }}
              >
                <ShieldCheck size={14} strokeWidth={2} />
                <span style={{ color: '#ffffff' }}>Strong</span>
              </div>
            </div>
          </div>
        </div>

        {/* Hero Right: Meta dates */}
        <div
          style={{
            position: 'relative',
            zIndex: 1,
            textAlign: 'right',
            fontSize: 12,
            color: 'rgba(255, 255, 255, 0.72)',
            lineHeight: 1.6,
          }}
        >
          <div>Updated {item.updatedAt || 'today'}</div>
          <div>Created {item.createdAt || '14 Mar 2026'}</div>
        </div>
      </div>

      {/* 3. Two-Column Grid: Credentials (1.25fr) | Authenticator (1fr) */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1.25fr 1fr',
          gap: 18,
        }}
      >
        {/* Credentials Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 20,
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            boxShadow: 'var(--shadow)',
          }}
        >
          <div
            style={{
              fontSize: 14,
              fontWeight: 700,
              color: 'var(--text)',
              marginBottom: 10,
            }}
          >
            Credentials
          </div>

          <div>
            <FieldRow
              icon={<User size={18} strokeWidth={1.7} />}
              label="Username"
              value={item.username || 'dev@example.com'}
              canCopy={true}
            />
            <FieldRow
              icon={<KeyRound size={18} strokeWidth={1.7} />}
              label="Password"
              value={item.password || '••••••••••••'}
              masked={true}
              canReveal={true}
              canCopy={true}
            />
            <FieldRow
              icon={<Globe size={18} strokeWidth={1.7} />}
              label="Website"
              value={item.url || 'github.com'}
              canCopy={true}
              externalUrl={item.url || 'github.com'}
              isLast={true}
            />
          </div>
        </div>

        {/* Authenticator Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 20,
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            boxShadow: 'var(--shadow)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
          }}
        >
          <div>
            <div
              style={{
                fontSize: 14,
                fontWeight: 700,
                color: 'var(--text)',
                marginBottom: 16,
              }}
            >
              Authenticator code
            </div>

            <div style={{ padding: '6px 0' }}>
              <TOTPRing
                secondsLeft={18}
                period={30}
                code="482 913"
                size="desktop"
                showCode={true}
              />
            </div>
          </div>

          {/* Full-width copy icon button */}
          <button
            type="button"
            onClick={handleCopyTotp}
            style={{
              width: '100%',
              height: 42,
              borderRadius: tokens.radii.button,
              border: '1px solid var(--input-border)',
              background: 'var(--input-bg)',
              color: totpCopied ? '#2fb67c' : 'var(--accent)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              fontSize: 13,
              fontWeight: 600,
              cursor: 'pointer',
              marginTop: 14,
              transition: 'all 150ms ease',
            }}
          >
            {totpCopied ? (
              <>
                <Check size={16} strokeWidth={2} />
                <span>Code Copied!</span>
              </>
            ) : (
              <>
                <Copy size={16} strokeWidth={1.7} />
                <span>Copy 6-Digit Code</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* 4. Second Two-Column Grid: Security (1fr) | Password history (1fr) */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: 18,
        }}
      >
        {/* Security Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 20,
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            boxShadow: 'var(--shadow)',
          }}
        >
          <div
            style={{
              fontSize: 14,
              fontWeight: 700,
              color: 'var(--text)',
              marginBottom: 14,
            }}
          >
            Security
          </div>

          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: 8,
            }}
          >
            <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>
              Password strength
            </span>
            <span style={{ fontSize: 12, color: 'var(--accent)', fontWeight: 600 }}>
              Strong · 88%
            </span>
          </div>

          <StrengthBar score={88} />

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              marginTop: 18,
              paddingTop: 14,
              borderTop: '1px solid var(--card-border)',
            }}
          >
            <ShieldCheck size={16} color="#2fb67c" strokeWidth={2} />
            <span style={{ fontSize: 13, color: 'var(--text)', fontWeight: 500 }}>
              No breaches found
            </span>
          </div>
        </div>

        {/* Password History Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 20,
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            boxShadow: 'var(--shadow)',
          }}
        >
          <div
            style={{
              fontSize: 14,
              fontWeight: 700,
              color: 'var(--text)',
              marginBottom: 14,
            }}
          >
            Password history
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
            {[
              { label: 'Changed today' },
              { label: 'Changed 3 months ago' },
              { label: 'Created 14 Mar 2026' },
            ].map((entry, idx, arr) => (
              <div
                key={entry.label}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  padding: '9px 0',
                  borderBottom: idx === arr.length - 1 ? 'none' : '1px solid var(--card-border)',
                }}
              >
                <Clock size={15} color="var(--muted)" strokeWidth={1.7} />
                <span style={{ fontSize: 13, color: 'var(--text)', fontWeight: 500 }}>
                  {entry.label}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default DetailPane;
