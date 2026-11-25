import React from 'react';
import { tokens } from '../tokens';

interface IconButtonProps {
  icon: React.ReactNode;
  label: string;
  onClick?: () => void;
  active?: boolean;
  style?: React.CSSProperties;
  className?: string;
}

export function IconButton({
  icon,
  label,
  onClick,
  active = false,
  style,
  className,
}: IconButtonProps) {
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      onClick={onClick}
      className={className}
      style={{
        width: 44,
        height: 44,
        borderRadius: tokens.radii.iconButton,
        border: '1px solid var(--input-border)',
        background: active ? 'var(--selected-bg)' : 'var(--input-bg)',
        color: active ? '#f5c451' : 'var(--accent)',
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        cursor: 'pointer',
        transition: 'transform 150ms ease-out, background 150ms ease, border-color 150ms ease',
        flexShrink: 0,
        ...style,
      }}
      onMouseDown={(e) => {
        e.currentTarget.style.transform = 'scale(0.98)';
      }}
      onMouseUp={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
    >
      {icon}
    </button>
  );
}

export default IconButton;
