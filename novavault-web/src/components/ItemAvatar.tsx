import React from 'react';
import { tokens } from '../tokens';

interface ItemAvatarProps {
  name: string;
  size?: number;
  radius?: number;
}

export function ItemAvatar({ name, size = 56, radius = 12 }: ItemAvatarProps) {
  const letter = name ? name.charAt(0).toUpperCase() : '?';
  const fontSize = Math.round(size * 0.38);

  return (
    <div
      aria-hidden="true"
      style={{
        width: size,
        height: size,
        borderRadius: radius,
        background: tokens.brandGradient,
        boxShadow: '0 6px 16px rgba(11,60,143,.4)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexShrink: 0,
        userSelect: 'none',
      }}
    >
      <span
        style={{
          color: '#ffffff',
          fontWeight: 700,
          fontSize,
          lineHeight: 1,
        }}
      >
        {letter}
      </span>
    </div>
  );
}

export default ItemAvatar;
