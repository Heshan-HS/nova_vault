import React from 'react';
import { tokens } from '../tokens';

interface SearchInputProps {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  showKbd?: boolean;
  size?: 'desktop' | 'mobile';
  style?: React.CSSProperties;
}

export function SearchInput({
  value,
  onChange,
  placeholder = 'Search vault',
  showKbd = true,
  size = 'desktop',
  style,
}: SearchInputProps) {
  const isDesktop = size === 'desktop';
  const height = isDesktop ? 46 : 48;
  const radius = isDesktop ? tokens.radii.input : tokens.radii.inputMobile;

  return (
    <div
      style={{
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        width: '100%',
        ...style,
      }}
    >
      <label htmlFor="vault-search-input" className="sr-only">
        Search vault
      </label>

      {/* Leading search icon */}
      <div
        style={{
          position: 'absolute',
          left: 14,
          color: 'var(--muted)',
          display: 'flex',
          alignItems: 'center',
          pointerEvents: 'none',
        }}
      >
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.7"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </div>

      <input
        id="vault-search-input"
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        style={{
          width: '100%',
          height,
          borderRadius: radius,
          background: 'var(--input-bg)',
          border: '1px solid var(--input-border)',
          color: 'var(--text)',
          fontSize: 14,
          paddingLeft: 42,
          paddingRight: showKbd ? 70 : 16,
          outline: 'none',
          transition: 'border-color 150ms ease, box-shadow 150ms ease',
        }}
        onFocus={(e) => {
          e.currentTarget.style.borderColor = 'var(--accent)';
          e.currentTarget.style.boxShadow = '0 0 0 2px var(--selected-bg)';
        }}
        onBlur={(e) => {
          e.currentTarget.style.borderColor = 'var(--input-border)';
          e.currentTarget.style.boxShadow = 'none';
        }}
      />

      {showKbd && (
        <div
          style={{
            position: 'absolute',
            right: 12,
            padding: '3px 7px',
            borderRadius: 6,
            border: '1px solid var(--input-border)',
            fontSize: 11,
            fontWeight: 500,
            color: 'var(--muted)',
            pointerEvents: 'none',
            userSelect: 'none',
            background: 'var(--card)',
          }}
        >
          Ctrl K
        </div>
      )}
    </div>
  );
}

export default SearchInput;
