import React, { useEffect, useState } from 'react';

interface TOTPRingProps {
  secondsLeft?: number;
  period?: number;
  code?: string;
  size?: 'desktop' | 'mobile';
  showCode?: boolean;
}

export function TOTPRing({
  secondsLeft: initialSeconds = 18,
  period = 30,
  code = '482 913',
  size = 'desktop',
  showCode = false,
}: TOTPRingProps) {
  const [sec, setSec] = useState(initialSeconds);
  const [currentCode, setCurrentCode] = useState(code);

  useEffect(() => {
    const timer = setInterval(() => {
      setSec((prev) => {
        if (prev <= 1) {
          // generate subtle new code variation on reset
          const part1 = Math.floor(100 + Math.random() * 900);
          const part2 = Math.floor(100 + Math.random() * 900);
          setCurrentCode(`${part1} ${part2}`);
          return period;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [period]);

  const isDesktop = size === 'desktop';
  const boxDim = isDesktop ? 84 : 64;
  const radius = isDesktop ? 36 : 26;
  const stroke = isDesktop ? 6 : 7;
  const circumference = 2 * Math.PI * radius;
  const progress = sec / period;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: isDesktop ? 20 : 16 }}>
      {/* Animated SVG Ring */}
      <div style={{ position: 'relative', width: boxDim, height: boxDim, flexShrink: 0 }}>
        <svg
          width={boxDim}
          height={boxDim}
          viewBox={`0 0 ${boxDim} ${boxDim}`}
          style={{ transform: 'rotate(-90deg)' }}
          aria-hidden="true"
        >
          {/* Background track */}
          <circle
            cx={boxDim / 2}
            cy={boxDim / 2}
            r={radius}
            fill="none"
            stroke="var(--ring-track)"
            strokeWidth={stroke}
          />
          {/* Progress fill */}
          <circle
            cx={boxDim / 2}
            cy={boxDim / 2}
            r={radius}
            fill="none"
            stroke="var(--ring-fill)"
            strokeWidth={stroke}
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            style={{
              transition: 'stroke-dashoffset 0.8s linear, stroke 0.3s ease',
            }}
          />
        </svg>

        {/* Center label */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: isDesktop ? 13 : 11,
            fontWeight: 700,
            color: 'var(--text)',
            fontVariantNumeric: 'tabular-nums',
          }}
        >
          {sec}s
        </div>
      </div>

      {showCode && (
        <div>
          <div
            style={{
              fontSize: isDesktop ? 34 : 30,
              fontWeight: 800,
              letterSpacing: isDesktop ? '5px' : '4px',
              color: 'var(--accent)',
              fontFamily: 'Inter, sans-serif',
              lineHeight: 1,
            }}
          >
            {currentCode}
          </div>
          <div
            style={{
              fontSize: 11,
              color: 'var(--muted)',
              marginTop: 6,
              fontWeight: 500,
            }}
          >
            Refreshes automatically
          </div>
        </div>
      )}
    </div>
  );
}

export default TOTPRing;
