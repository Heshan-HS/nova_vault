import React, { useState, useCallback } from 'react';
import { Copy, RefreshCw, Wand2, ShieldCheck, Check } from 'lucide-react';
import { StrengthBar } from '../../components/StrengthBar';
import { TabBar, type TabKey } from '../../components/TabBar';
import { showToast } from '../../components/Toast';
import { tokens } from '../../tokens';

interface GeneratorScreenProps {
  activeTab?: TabKey;
  onTabChange?: (tab: TabKey) => void;
  isMobile?: boolean;
}

export function GeneratorScreen({
  activeTab = 'generator',
  onTabChange,
  isMobile = false,
}: GeneratorScreenProps) {
  const [mode, setMode] = useState<'password' | 'passphrase'>('password');
  const [length, setLength] = useState(20);
  const [wordCount, setWordCount] = useState(4);
  const [separator, setSeparator] = useState('-');
  const [uppercase, setUppercase] = useState(true);
  const [lowercase, setLowercase] = useState(true);
  const [numbers, setNumbers] = useState(true);
  const [symbols, setSymbols] = useState(true);
  const [copied, setCopied] = useState(false);

  const wordsList = ['vault', 'solar', 'cipher', 'hyper', 'pulse', 'falcon', 'matrix', 'orbital', 'stellar', 'quantum', 'titan', 'delta', 'prism', 'zenith'];

  const generate = useCallback(() => {
    if (mode === 'passphrase') {
      const selected: string[] = [];
      for (let i = 0; i < wordCount; i++) {
        selected.push(wordsList[Math.floor(Math.random() * wordsList.length)]);
      }
      return selected.join(separator);
    }
    let chars = '';
    if (uppercase) chars += 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    if (lowercase) chars += 'abcdefghijkmnopqrstuvwxyz';
    if (numbers) chars += '23456789';
    if (symbols) chars += '!@#$%^&*()_+-=~';
    if (!chars) chars = 'abcdefghjkmnpqrstuvwxyz';

    const arr = new Uint8Array(length);
    crypto.getRandomValues(arr);
    return Array.from(arr, (b) => chars[b % chars.length]).join('');
  }, [mode, length, wordCount, separator, uppercase, lowercase, numbers, symbols]);

  const [password, setPassword] = useState(generate);

  const handleRegenerate = () => {
    setPassword(generate());
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(password);
    setCopied(true);
    showToast('Copied to clipboard. Clears in 30s');
    setTimeout(() => setCopied(false), 1200);
  };

  const strengthScore = mode === 'passphrase' ? 95 : Math.min(100, Math.round((length / 24) * 100));

  return (
    <div
      style={{
        minHeight: '100%',
        background: 'var(--bg)',
        padding: isMobile ? '28px 20px 100px 20px' : '36px 40px',
        display: 'flex',
        flexDirection: 'column',
        boxSizing: 'border-box',
        overflowY: 'auto',
      }}
    >
      <div style={{ maxWidth: 640, width: '100%', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Header */}
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--text)', margin: 0, letterSpacing: '-0.4px' }}>
            Password Generator
          </h1>
          <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 4 }}>
            Generate cryptographically secure passwords and passphrases
          </p>
        </div>

        {/* Mode Toggle */}
        <div
          style={{
            display: 'flex',
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: 14,
            padding: 4,
            gap: 4,
          }}
        >
          {(['password', 'passphrase'] as const).map((m) => (
            <button
              key={m}
              type="button"
              onClick={() => {
                setMode(m);
                setPassword(generate());
              }}
              style={{
                flex: 1,
                padding: '9px 0',
                borderRadius: 10,
                fontSize: 13,
                fontWeight: mode === m ? 600 : 500,
                background: mode === m ? tokens.brandGradient : 'transparent',
                color: mode === m ? '#ffffff' : 'var(--muted)',
                border: 'none',
                cursor: 'pointer',
                transition: 'all 150ms ease',
                textTransform: 'capitalize',
              }}
            >
              {m}
            </button>
          ))}
        </div>

        {/* Generated Display Card */}
        <div
          style={{
            borderRadius: tokens.radii.card,
            padding: 24,
            background: tokens.heroGradient,
            position: 'relative',
            overflow: 'hidden',
            boxShadow: '0 20px 50px rgba(5,16,38,.4)',
            color: '#ffffff',
          }}
        >
          {/* Highlight */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              background: 'radial-gradient(400px 200px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
              pointerEvents: 'none',
            }}
          />

          <div style={{ position: 'relative', zIndex: 1 }}>
            <div
              style={{
                fontSize: 22,
                fontWeight: 700,
                fontFamily: 'JetBrains Mono, monospace',
                letterSpacing: '1px',
                wordBreak: 'break-all',
                minHeight: 64,
                display: 'flex',
                alignItems: 'center',
                color: '#ffffff',
              }}
            >
              {password}
            </div>

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 16 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: '#7fe0b0' }}>
                <ShieldCheck size={16} strokeWidth={2.2} />
                <span style={{ fontWeight: 600 }}>Strong · {strengthScore}%</span>
              </div>

              <div style={{ display: 'flex', gap: 8 }}>
                <button
                  type="button"
                  aria-label="Regenerate"
                  onClick={handleRegenerate}
                  style={{
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    background: 'rgba(255, 255, 255, 0.15)',
                    border: 'none',
                    color: '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  <RefreshCw size={18} strokeWidth={2} />
                </button>
                <button
                  type="button"
                  aria-label="Copy"
                  onClick={handleCopy}
                  style={{
                    padding: '0 18px',
                    height: 44,
                    borderRadius: 12,
                    background: '#ffffff',
                    border: 'none',
                    color: tokens.navy900,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                    fontSize: 13,
                    fontWeight: 700,
                    cursor: 'pointer',
                  }}
                >
                  {copied ? <Check size={16} strokeWidth={2.2} /> : <Copy size={16} strokeWidth={2} />}
                  <span>{copied ? 'Copied' : 'Copy'}</span>
                </button>
              </div>
            </div>

            <div style={{ marginTop: 16 }}>
              <StrengthBar score={strengthScore} />
            </div>
          </div>
        </div>

        {/* Options Card */}
        <div
          style={{
            background: 'var(--card)',
            border: '1px solid var(--card-border)',
            borderRadius: tokens.radii.card,
            padding: 22,
            display: 'flex',
            flexDirection: 'column',
            gap: 16,
            boxShadow: 'var(--shadow)',
          }}
        >
          <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text)', textTransform: 'uppercase', letterSpacing: '0.8px' }}>
            Customization
          </div>

          {mode === 'password' ? (
            <>
              {/* Length Slider */}
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8, fontSize: 13, fontWeight: 500, color: 'var(--text)' }}>
                  <span>Length</span>
                  <span style={{ fontWeight: 700, color: 'var(--accent)' }}>{length} characters</span>
                </div>
                <input
                  type="range"
                  min="8"
                  max="64"
                  value={length}
                  onChange={(e) => {
                    setLength(Number(e.target.value));
                    setPassword(generate());
                  }}
                  style={{ width: '100%', accentColor: 'var(--accent)', cursor: 'pointer' }}
                />
              </div>

              {/* Toggles */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                {[
                  { label: 'Uppercase (A-Z)', val: uppercase, set: setUppercase },
                  { label: 'Lowercase (a-z)', val: lowercase, set: setLowercase },
                  { label: 'Numbers (0-9)', val: numbers, set: setNumbers },
                  { label: 'Symbols (!@#$)', val: symbols, set: setSymbols },
                ].map((t) => (
                  <label
                    key={t.label}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 10,
                      fontSize: 13,
                      color: 'var(--text)',
                      cursor: 'pointer',
                      userSelect: 'none',
                    }}
                  >
                    <input
                      type="checkbox"
                      checked={t.val}
                      onChange={(e) => {
                        t.set(e.target.checked);
                        setPassword(generate());
                      }}
                      style={{ accentColor: 'var(--accent)', width: 18, height: 18, cursor: 'pointer' }}
                    />
                    <span>{t.label}</span>
                  </label>
                ))}
              </div>
            </>
          ) : (
            <>
              {/* Passphrase Word count */}
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8, fontSize: 13, fontWeight: 500, color: 'var(--text)' }}>
                  <span>Words</span>
                  <span style={{ fontWeight: 700, color: 'var(--accent)' }}>{wordCount} words</span>
                </div>
                <input
                  type="range"
                  min="3"
                  max="8"
                  value={wordCount}
                  onChange={(e) => {
                    setWordCount(Number(e.target.value));
                    setPassword(generate());
                  }}
                  style={{ width: '100%', accentColor: 'var(--accent)', cursor: 'pointer' }}
                />
              </div>

              {/* Separator choice */}
              <div style={{ display: 'flex', gap: 8 }}>
                {['-', '.', '_', ' '].map((sep) => (
                  <button
                    key={sep}
                    type="button"
                    onClick={() => {
                      setSeparator(sep);
                      setPassword(generate());
                    }}
                    style={{
                      padding: '6px 14px',
                      borderRadius: 10,
                      background: separator === sep ? 'var(--selected-bg)' : 'var(--card)',
                      border: separator === sep ? '1px solid var(--selected-border)' : '1px solid var(--card-border)',
                      color: separator === sep ? 'var(--accent)' : 'var(--muted)',
                      fontSize: 14,
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                  >
                    {sep === ' ' ? 'Space' : sep}
                  </button>
                ))}
              </div>
            </>
          )}
        </div>
      </div>

      {isMobile && onTabChange && <TabBar activeTab={activeTab} onChange={onTabChange} />}
    </div>
  );
}

export default GeneratorScreen;
