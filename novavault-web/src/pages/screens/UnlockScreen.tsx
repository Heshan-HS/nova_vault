import React, { useState } from 'react';
import { Lock, Eye, EyeOff, Fingerprint, Shield, AlertCircle } from 'lucide-react';
import { Logo } from '../../components/Logo';
import { PrimaryButton } from '../../components/PrimaryButton';
import { tokens } from '../../tokens';

interface UnlockScreenProps {
  onUnlock: () => void;
}

export function UnlockScreen({ onUnlock }: UnlockScreenProps) {
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberDevice, setRememberDevice] = useState(true);
  const [error, setError] = useState('');
  const [isShaking, setIsShaking] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!password.trim()) {
      setError('Please enter your master password');
      triggerShake();
      return;
    }
    // Success unlock
    setError('');
    onUnlock();
  };

  const handleBiometric = () => {
    // Simulate instant biometric check
    onUnlock();
  };

  const triggerShake = () => {
    setIsShaking(true);
    setTimeout(() => setIsShaking(false), 500);
  };

  return (
    <div
      style={{
        width: '100vw',
        height: '100vh',
        background: tokens.bgDark,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
        boxSizing: 'border-box',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      {/* Background ambient lighting */}
      <div
        style={{
          position: 'absolute',
          width: 600,
          height: 600,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(47,111,224,0.18) 0%, transparent 70%)',
          pointerEvents: 'none',
        }}
      />

      <div
        style={{
          width: '100%',
          maxWidth: 400,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 28,
          zIndex: 1,
        }}
      >
        {/* Centered Logo Lockup */}
        <Logo size="desktop" showWordmark={true} />

        {/* Unlock Card */}
        <div
          style={{
            width: '100%',
            background: 'rgba(255, 255, 255, 0.055)',
            border: '1px solid rgba(255, 255, 255, 0.12)',
            borderRadius: tokens.radii.card,
            padding: '28px 26px',
            boxShadow: '0 20px 50px rgba(0,0,0,0.5)',
            backdropFilter: 'blur(20px)',
            transform: isShaking ? 'translateX(-8px)' : 'none',
            transition: 'transform 80ms ease-in-out',
            boxSizing: 'border-box',
          }}
        >
          <div style={{ textAlign: 'center', marginBottom: 20 }}>
            <h2 style={{ fontSize: 18, fontWeight: 700, color: '#ffffff', margin: 0 }}>
              Unlock your vault
            </h2>
            <p style={{ fontSize: 13, color: 'rgba(255, 255, 255, 0.64)', marginTop: 4 }}>
              Enter your master password to decrypt
            </p>
          </div>

          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Master password input */}
            <div>
              <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Master password"
                  autoFocus
                  style={{
                    width: '100%',
                    height: 46,
                    borderRadius: tokens.radii.input,
                    background: 'rgba(255, 255, 255, 0.06)',
                    border: error ? '1px solid #ef4444' : '1px solid rgba(255, 255, 255, 0.12)',
                    color: '#ffffff',
                    fontSize: 14,
                    padding: '0 44px 0 16px',
                    outline: 'none',
                    letterSpacing: showPassword ? 'normal' : '2px',
                    boxSizing: 'border-box',
                  }}
                  onFocus={(e) => {
                    if (!error) e.currentTarget.style.borderColor = tokens.midBlue;
                  }}
                  onBlur={(e) => {
                    if (!error) e.currentTarget.style.borderColor = 'rgba(255, 255, 255, 0.12)';
                  }}
                />

                <button
                  type="button"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                  onClick={() => setShowPassword(!showPassword)}
                  style={{
                    position: 'absolute',
                    right: 8,
                    width: 32,
                    height: 32,
                    background: 'transparent',
                    border: 'none',
                    color: 'rgba(255, 255, 255, 0.6)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>

              {error && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: '#ef4444', fontSize: 12, marginTop: 6 }}>
                  <AlertCircle size={13} />
                  <span>{error}</span>
                </div>
              )}
            </div>

            {/* Remember Device Checkbox */}
            <label
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 8,
                fontSize: 13,
                color: 'rgba(255, 255, 255, 0.7)',
                cursor: 'pointer',
                userSelect: 'none',
              }}
            >
              <input
                type="checkbox"
                checked={rememberDevice}
                onChange={(e) => setRememberDevice(e.target.checked)}
                style={{ accentColor: tokens.midBlue, width: 16, height: 16, cursor: 'pointer' }}
              />
              <span>Remember this device</span>
            </label>

            {/* Action buttons */}
            <div style={{ display: 'flex', gap: 10, marginTop: 4 }}>
              <PrimaryButton style={{ flex: 1 }} onClick={() => handleSubmit({ preventDefault: () => {} } as any)}>
                Unlock Vault
              </PrimaryButton>

              <button
                type="button"
                aria-label="Unlock with biometrics"
                title="Unlock with Windows Hello / Touch ID"
                onClick={handleBiometric}
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: tokens.radii.iconButton,
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.15)',
                  color: '#8db8ff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  flexShrink: 0,
                  transition: 'background 150ms ease',
                }}
              >
                <Fingerprint size={22} strokeWidth={1.8} />
              </button>
            </div>
          </form>
        </div>

        {/* Security badge footer */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: 'rgba(255, 255, 255, 0.45)' }}>
          <Shield size={14} />
          <span>Zero-Knowledge AES-256-GCM Architecture</span>
        </div>
      </div>
    </div>
  );
}

export default UnlockScreen;
