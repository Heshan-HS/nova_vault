import { useState } from 'react';
import { Shield, Eye, EyeOff, Lock, AlertCircle } from 'lucide-react';
import { useVaultStore } from '../store/vault';

export function UnlockPage() {
  const { unlock } = useVaultStore();
  const [master, setMaster] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [attempts, setAttempts] = useState(0);

  async function handleUnlock(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const ok = await unlock(master);
      if (!ok) {
        setAttempts(a => a + 1);
        setError(`Invalid master password${attempts >= 2 ? ` — ${attempts + 1} failed attempts` : ''}`);
      }
    } catch {
      setError('Unlock failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[rgb(5,16,38)] to-[rgb(11,60,143)] p-4">
      <div className="absolute inset-0 opacity-[0.03]"
        style={{ backgroundImage: 'linear-gradient(rgba(255,255,255,0.5) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.5) 1px, transparent 1px)', backgroundSize: '40px 40px' }} />

      <div className="relative w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-4"
            style={{ background: 'linear-gradient(135deg, rgba(37,99,235,0.3), rgba(11,60,143,0.5))', border: '1px solid rgba(96,165,250,0.3)' }}>
            <Shield size={28} className="text-blue-300" />
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">NovaVault</h1>
          <p className="text-xs text-blue-300/60 mt-1 uppercase tracking-widest font-medium">Vault Locked</p>
        </div>

        <div className="rounded-xl p-6" style={{
          background: 'rgba(8,25,55,0.7)',
          border: '1px solid rgba(37,99,235,0.25)',
          backdropFilter: 'blur(20px)',
        }}>
          <div className="flex items-center justify-center mb-5">
            <div className="p-3 rounded-full" style={{ background: 'rgba(37,99,235,0.1)', border: '1px solid rgba(37,99,235,0.2)' }}>
              <Lock size={20} className="text-blue-400" />
            </div>
          </div>
          <h2 className="text-base font-semibold text-white text-center mb-1">Unlock Your Vault</h2>
          <p className="text-xs text-slate-400 text-center mb-5">Enter your master password to continue</p>

          <form onSubmit={handleUnlock} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-400 uppercase tracking-widest mb-1.5">
                Master Password
              </label>
              <div className="relative">
                <input
                  type={showPwd ? 'text' : 'password'}
                  value={master}
                  onChange={e => { setMaster(e.target.value); setError(''); }}
                  placeholder="Enter master password…"
                  className="w-full px-3 py-2.5 pr-10 rounded-lg text-sm text-white placeholder-slate-500 font-mono outline-none transition-all"
                  style={{
                    background: 'rgba(5,16,38,0.6)',
                    border: `1px solid ${error ? 'rgba(220,38,38,0.4)' : 'rgba(37,99,235,0.3)'}`,
                  }}
                  onFocus={e => (e.target.style.borderColor = error ? 'rgba(220,38,38,0.6)' : 'rgba(37,99,235,0.7)')}
                  onBlur={e => (e.target.style.borderColor = error ? 'rgba(220,38,38,0.4)' : 'rgba(37,99,235,0.3)')}
                  autoComplete="current-password"
                  autoFocus
                  required
                />
                <button type="button" onClick={() => setShowPwd(v => !v)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300 transition-colors">
                  {showPwd ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
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
              disabled={loading || !master}
              className="w-full py-2.5 rounded-lg text-sm font-semibold text-white flex items-center justify-center gap-2 transition-all duration-200 disabled:opacity-50"
              style={{ color: '#ffffff', background: 'linear-gradient(135deg, rgb(11,60,143) 0%, rgb(37,99,235) 100%)', border: '1px solid rgba(96,165,250,0.2)' }}
            >
              <Lock size={14} />
              {loading ? 'Unlocking…' : 'Unlock Vault'}
            </button>
          </form>
        </div>

        <p className="text-center text-xs text-slate-600 mt-4">
          NovaVault · Zero-Knowledge · AES-256-GCM
        </p>
      </div>
    </div>
  );
}
