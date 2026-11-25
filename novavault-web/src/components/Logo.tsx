import React from 'react';

interface LogoProps {
  size?: 'desktop' | 'mobile';
  showWordmark?: boolean;
}

export function Logo({ size = 'desktop', showWordmark = true }: LogoProps) {
  const dim = size === 'desktop' ? 40 : 36;

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      {/* 3D NovaVault Logo */}
      <div
        style={{
          width: dim,
          height: dim,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          filter: 'drop-shadow(0 4px 12px rgba(47, 111, 224, 0.6))',
        }}
      >
        <img
          src="/logo.png"
          alt="NovaVault Logo"
          style={{
            width: '100%',
            height: '100%',
            objectFit: 'contain',
          }}
        />
      </div>

      {/* Wordmark */}
      {showWordmark && (
        <span
          style={{
            fontSize: 20,
            fontWeight: 800,
            letterSpacing: '-0.4px',
            color: '#ffffff',
            lineHeight: 1,
            userSelect: 'none',
          }}
        >
          NovaVault
        </span>
      )}
    </div>
  );
}

export default Logo;
