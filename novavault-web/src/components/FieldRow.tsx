import React, { useState } from 'react';
import { Copy, Check, Eye, EyeOff, ExternalLink } from 'lucide-react';
import { IconButton } from './IconButton';
import { showToast } from './Toast';

interface FieldRowProps {
  icon: React.ReactNode;
  label: string;
  value: string;
  masked?: boolean;
  canCopy?: boolean;
  canReveal?: boolean;
  externalUrl?: string;
  isLast?: boolean;
}

export function FieldRow({
  icon,
  label,
  value,
  masked = false,
  canCopy = true,
  canReveal = false,
  externalUrl,
  isLast = false,
}: FieldRowProps) {
  const [revealed, setRevealed] = useState(false);
  const [copied, setCopied] = useState(false);

  const displayValue = masked && !revealed ? '••••••••••••' : value;

  const handleCopy = () => {
    navigator.clipboard.writeText(value);
    setCopied(true);
    showToast('Copied. Clears in 30s');
    setTimeout(() => setCopied(false), 1200);
  };

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        padding: '12px 0',
        gap: 14,
        borderBottom: isLast ? 'none' : '1px solid var(--card-border)',
      }}
    >
      {/* 36x36 icon tile (radius 10, bg = selected-row bg, icon in accent) */}
      <div
        style={{
          width: 36,
          height: 36,
          borderRadius: 10,
          background: 'var(--selected-bg)',
          color: 'var(--accent)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
        }}
      >
        {icon}
      </div>

      {/* Label and Value */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div
          style={{
            fontSize: 12,
            color: 'var(--muted)',
            marginBottom: 2,
            fontWeight: 500,
          }}
        >
          {label}
        </div>
        <div
          style={{
            fontSize: 15,
            fontWeight: 500,
            color: 'var(--text)',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            letterSpacing: masked && !revealed ? '3px' : 'normal',
          }}
        >
          {displayValue}
        </div>
      </div>

      {/* Trailing action buttons */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexShrink: 0 }}>
        {canReveal && (
          <IconButton
            icon={revealed ? <EyeOff size={18} strokeWidth={1.7} /> : <Eye size={18} strokeWidth={1.7} />}
            label={revealed ? 'Hide password' : 'Show password'}
            onClick={() => setRevealed(!revealed)}
          />
        )}
        {canCopy && (
          <IconButton
            icon={copied ? <Check size={18} color="#2fb67c" strokeWidth={2} /> : <Copy size={18} strokeWidth={1.7} />}
            label="Copy to clipboard"
            onClick={handleCopy}
          />
        )}
        {externalUrl && (
          <IconButton
            icon={<ExternalLink size={18} strokeWidth={1.7} />}
            label="Open website"
            onClick={() => {
              const url = externalUrl.startsWith('http') ? externalUrl : `https://${externalUrl}`;
              window.open(url, '_blank', 'noopener,noreferrer');
            }}
          />
        )}
      </div>
    </div>
  );
}

export default FieldRow;
