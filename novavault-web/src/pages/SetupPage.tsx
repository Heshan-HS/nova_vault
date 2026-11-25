import { useState } from 'react';
import { Shield, Eye, EyeOff, Lock, AlertCircle, CheckCircle } from 'lucide-react';
import { useVaultStore } from '../store/vault';
import { checkPasswordStrength } from '../lib/crypto';

export function SetupPage() {
  const { setupMaster } = useVaultStore();
  const [master, setMaster] = useState('');
  const [confirm, setConfirm] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const strength = checkPasswordStrength(master);

  async function handleSetup(e: React.FormEvent) {
    e.preventDefault();
    if (master !== confirm) { setError('Passwords do not match'); return; }
    if (master.length < 10) { setError('Master password must be at least 10 characters'); return; }
    setLoading(true);
    setError('');
    try {
      await setupMaster(master);
    } catch {
      setError('Setup failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  const strengthBar = [0,1,2,3,4].map(i => (
    <div
      key={i}
      className="h-1 rounded-full flex-1 transition-all duration-300"
      style={{ background: i < strength.score ? strength.color : 'rgba(148,163,184,0.2)' }}
    />
  ));

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[rgb(5,16,38)] to-[rgb(11,60,143)] p-4">
      {/* Background grid */}
      <div className="absolute inset-0 opacity-[0.03]"
        style={{ backgroundImage: 'linear-gradient(rgba(255,255,255,0.5) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.5) 1px, transparent 1px)', backgroundSize: '40px 40px' }} />

      <div className="relative w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-4"
            style={{ background: 'linear-gradient(135deg, rgba(37,99,235,0.3), rgba(11,60,143,0.5))', border: '1px solid rgba(96,165,250,0.3)' }}>
            <Shield size={28} className="text-blue-300" />
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">NovaVault</h1>
          <p className="text-sm text-blue-300/70 mt-1 tracking-wide uppercase font-medium" style={{ letterSpacing: '0.08em' }}>
            Ultra-Secure Password Manager
          </p>
        </div>

        {/* Card */}
        <div className="rounded-xl p-6" style={{
          background: 'rgba(8,25,55,0.7)',
          border: '1px solid rgba(37,99,235,0.25)',
          backdropFilter: 'blur(20px)',
        }}>
          <div className="mb-5">
            <h2 className="text-base font-semibold text-white">Create Master Password</h2>
            <p className="text-xs text-slate-400 mt-1 leading-relaxed">
              This is your vault key. It's never stored or transmitted — only you know it.
              <span className="text-amber-400 font-medium"> Cannot be recovered if forgotten.</span>
            </p>
          </div>

          <form onSubmit={handleSetup} className="space-y-4">
            {/* Master Password */}
            <div>
              <label className="block text-xs font-semibold text-slate-400 uppercase tracking-widest mb-1.5">
                Master Password
              </label>
              <div className="relative">
                <input
                  type={showPwd ? 'text' : 'password'}
                  value={master}
                  onChange={e => setMaster(e.target.value)}
                  placeholder="Enter a strong master password…"
                  className="w-full px-3 py-2.5 pr-10 rounded-lg text-sm text-white placeholder-slate-500 font-mono outline-none transition-all"
                  style={{
                    background: 'rgba(5,16,38,0.6)',
                    border: '1px solid rgba(37,99,235,0.3)',
                  }}
                  onFocus={e => (e.target.style.borderColor = 'rgba(37,99,235,0.7)')}
                  onBlur={e => (e.target.style.borderColor = 'rgba(37,99,235,0.3)')}
                  autoComplete="new-password"
                  required
                />
                <button type="button" onClick={() => setShowPwd(v => !v)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300 transition-colors">
                  {showPwd ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>

              {/* Strength bar */}
              {master && (
                <div className="mt-2">
                  <div className="flex gap-1">{strengthBar}</div>
                  <p className="text-xs mt-1 font-medium" style={{ color: strength.color }}>
                    {strength.label}
                  </p>
                </div>
              )}
            </div>

            {/* Confirm */}
            <div>
              <label className="block text-xs font-semibold text-slate-400 uppercase tracking-widest mb-1.5">
                Confirm Password
              </label>
              <div className="relative">
                <input
                  type={showPwd ? 'text' : 'password'}
                  value={confirm}
                  onChange={e => setConfirm(e.target.value)}
                  placeholder="Re-enter master password…"
                  className="w-full px-3 py-2.5 pr-10 rounded-lg text-sm text-white placeholder-slate-500 font-mono outline-none transition-all"
                  style={{
                    background: 'rgba(5,16,38,0.6)',
                    border: `1px solid ${confirm && confirm === master ? 'rgba(5,150,105,0.5)' : 'rgba(37,99,235,0.3)'}`,
                  }}
                  onFocus={e => (e.target.style.borderColor = 'rgba(37,99,235,0.7)')}
                  onBlur={e => (e.target.style.borderColor = confirm && confirm === master ? 'rgba(5,150,105,0.5)' : 'rgba(37,99,235,0.3)')}
                  autoComplete="new-password"
                  required
                />
                {confirm && (
                  <div className="absolute right-3 top-1/2 -translate-y-1/2">
                    {confirm === master
                      ? <CheckCircle size={15} className="text-emerald-400" />
                      : <AlertCircle size={15} className="text-red-400" />}
                  </div>
                )}
              </div>
            </div>

            {error && (
              <div className="flex items-center gap-2 p-2.5 rounded-lg" style={{ background: 'rgba(220,38,38,0.1)', border: '1px solid rgba(220,38,38,0.2)' }}>
                <AlertCircle size={13} className="text-red-400 flex-shrink-0" />
                <p className="text-xs text-red-400">{error}</p>
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2.5 rounded-lg text-sm font-semibold text-white flex items-center justify-center gap-2 transition-all duration-200 disabled:opacity-50"
              style={{
                background: loading ? 'rgba(37,99,235,0.5)' : 'linear-gradient(135deg, rgb(11,60,143) 0%, rgb(37,99,235) 100%)',
                border: '1px solid rgba(96,165,250,0.2)',
              }}
            >
              <Lock size={14} />
              {loading ? 'Creating Vault…' : 'Create Secure Vault'}
            </button>
          </form>

          {/* Security notice */}
          <div className="mt-4 flex items-start gap-2 p-2.5 rounded-lg" style={{ background: 'rgba(37,99,235,0.08)', border: '1px solid rgba(37,99,235,0.15)' }}>
            <Shield size={12} className="text-blue-400 flex-shrink-0 mt-0.5" />
            <p className="text-xs text-slate-400 leading-relaxed">
              AES-256-GCM encryption · Zero-knowledge architecture · 310,000 PBKDF2 iterations
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
