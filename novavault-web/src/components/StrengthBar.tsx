import React from 'react';
import { tokens } from '../tokens';

interface StrengthBarProps {
  score?: number; // 0-100
}

export function StrengthBar({ score = 88 }: StrengthBarProps) {
  const clamped = Math.min(100, Math.max(0, score));

  return (
    <div
      style={{
        width: '100%',
        height: 8,
        borderRadius: 8,
        background: 'var(--ring-track)',
        overflow: 'hidden',
        position: 'relative',
      }}
      role="progressbar"
      aria-valuenow={clamped}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <div
        style={{
          height: '100%',
          width: `${clamped}%`,
          borderRadius: 8,
          background: tokens.brandGradient,
          transition: 'width 0.4s ease-out',
        }}
      />
    </div>
  );
}

export default StrengthBar;
