import React from 'react';
import { tokens } from '../tokens';

interface PrimaryButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  icon?: React.ReactNode;
  disabled?: boolean;
  style?: React.CSSProperties;
}

export function PrimaryButton({
  children,
  onClick,
  icon,
  disabled = false,
  style,
}: PrimaryButtonProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      style={{
        height: 44,
        padding: '0 20px',
        borderRadius: tokens.radii.button,
        background: tokens.brandGradient,
        color: '#ffffff',
        fontSize: 14,
        fontWeight: 600,
        boxShadow: '0 10px 26px rgba(11,60,143,.45)',
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        border: 'none',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.5 : 1,
        transition: 'transform 150ms ease-out, opacity 150ms ease',
        userSelect: 'none',
        ...style,
      }}
      onMouseDown={(e) => {
        if (!disabled) e.currentTarget.style.transform = 'scale(0.98)';
      }}
      onMouseUp={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'scale(1)';
      }}
    >
      {icon && <span style={{ display: 'inline-flex', flexShrink: 0 }}>{icon}</span>}
      <span>{children}</span>
    </button>
  );
}

export default PrimaryButton;
