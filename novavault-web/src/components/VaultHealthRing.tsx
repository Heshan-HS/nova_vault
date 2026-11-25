import React from 'react';

interface VaultHealthRingProps {
  score?: number;
  size?: 'desktop' | 'mobile';
  overrideTrack?: string;
  overrideFill?: string;
  overrideText?: string;
}

export function VaultHealthRing({
  score = 82,
  size = 'desktop',
  overrideTrack,
  overrideFill,
  overrideText,
}: VaultHealthRingProps) {
  const boxDim = 56;
  const radius = 22;
  const stroke = 5;
  const circumference = 2 * Math.PI * radius;
  const progress = Math.min(100, Math.max(0, score)) / 100;
  const strokeDashoffset = circumference * (1 - progress);

  const trackColor = overrideTrack || 'var(--ring-track)';
  const fillColor = overrideFill || 'var(--ring-fill)';
  const textColor = overrideText || 'var(--text)';

  return (
    <div style={{ position: 'relative', width: boxDim, height: boxDim, flexShrink: 0 }}>
      <svg
        width={boxDim}
        height={boxDim}
        viewBox={`0 0 ${boxDim} ${boxDim}`}
        style={{ transform: 'rotate(-90deg)' }}
        aria-hidden="true"
      >
        {/* Track */}
        <circle
          cx={boxDim / 2}
          cy={boxDim / 2}
          r={radius}
          fill="none"
          stroke={trackColor}
          strokeWidth={stroke}
        />
        {/* Fill */}
        <circle
          cx={boxDim / 2}
          cy={boxDim / 2}
          r={radius}
          fill="none"
          stroke={fillColor}
          strokeWidth={stroke}
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 0.6s ease-out' }}
        />
      </svg>
      {/* Centered Score */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: 14,
          fontWeight: 700,
          color: textColor,
          fontVariantNumeric: 'tabular-nums',
        }}
      >
        {score}
      </div>
    </div>
  );
}

export default VaultHealthRing;
