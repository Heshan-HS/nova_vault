import React from 'react';
import { tokens } from '../tokens';

interface ChipProps {
  children: React.ReactNode;
  active?: boolean;
  onClick?: () => void;
  size?: 'desktop' | 'mobile';
  style?: React.CSSProperties;
}

export function Chip({
  children,
  active = false,
  onClick,
  size = 'desktop',
  style,
}: ChipProps) {
  const isDesktop = size === 'desktop';
  const padding = isDesktop ? '7px 14px' : '8px 16px';

  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        padding,
        borderRadius: tokens.radii.chip,
        fontSize: 12,
        fontWeight: active ? 600 : 500,
        background: active ? tokens.royal700 : 'var(--card)',
        border: active ? 'none' : '1px solid var(--card-border)',
        color: active ? '#ffffff' : 'var(--muted)',
        cursor: 'pointer',
        transition: 'all 150ms ease-out',
        userSelect: 'none',
        display: 'inline-flex',
        alignItems: 'center',
        gap: 6,
        whiteSpace: 'nowrap',
        ...style,
      }}
      onMouseDown={(e) => {
        e.currentTarget.style.transform = 'scale(0.97)';
      }}
      onMouseUp={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
    >
      {children}
    </button>
  );
}

export default Chip;
