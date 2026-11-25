import { useState } from 'react';
import { X, Lock, Mail, CreditCard, FileText, User, Eye, EyeOff, AlertCircle } from 'lucide-react';
import { useVaultStore, type ItemCategory } from '../store/vault';
import { getSessionMasterPassword } from '../store/vault';
import { checkPasswordStrength, generatePassword } from '../lib/crypto';
import clsx from 'clsx';

const CATEGORIES: { id: ItemCategory; label: string; icon: React.ElementType }[] = [
  { id: 'login',    label: 'Login',    icon: Lock },
  { id: 'email',    label: 'Email',    icon: Mail },
  { id: 'card',     label: 'Card',     icon: CreditCard },
  { id: 'note',     label: 'Note',     icon: FileText },
  { id: 'identity', label: 'Identity', icon: User },
];

export function AddItemModal({ onClose }: { onClose: () => void }) {
  const { addItem, theme } = useVaultStore();
  const isDark = theme === 'dark';

  const [category, setCategory] = useState<ItemCategory>('login');
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [url, setUrl] = useState('');
  const [notes, setNotes] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const strength = password ? checkPasswordStrength(password) : null;

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) { setError('Name is required'); return; }
    const mp = getSessionMasterPassword();
    if (!mp) { setError('Session expired — please re-lock and unlock the vault'); return; }

    setLoading(true);
    setError('');
    try {
      await addItem({
        name: name.trim(),
        category,
        username: username || undefined,
        email: email || undefined,
        password: password || undefined,
        url: url || undefined,
        notes: notes || undefined,
        favourite: false,
        tags: [],
        strength: strength?.score,
      }, mp);
      onClose();
    } catch {
      setError('Failed to save item');
    } finally {
      setLoading(false);
    }
  }

  const inputStyle = {
    background: isDark ? 'rgba(5,16,38,0.6)' : '#f8fafc',
    border: isDark ? '1px solid rgba(37,99,235,0.25)' : '1px solid #e2e8f0',
    color: isDark ? '#f1f5f9' : '#0f172a',
  };

  function Input({ label, value, onChange, type = 'text', placeholder, children }: {
    label: string; value: string; onChange: (v: string) => void;
    type?: string; placeholder?: string; children?: React.ReactNode;
  }) {
    return (
      <div>
        <label className="block text-[10px] font-semibold uppercase tracking-widest mb-1.5"
          style={{ color: isDark ? '#64748b' : '#94a3b8' }}>
          {label}
        </label>
        <div className="relative">
          <input type={type} value={value} onChange={e => onChange(e.target.value)}
            placeholder={placeholder}
            className="w-full px-3 py-2 rounded-lg text-xs outline-none transition-all"
            style={{ ...inputStyle, paddingRight: children ? '2rem' : undefined, fontFamily: type === 'password' ? 'JetBrains Mono, monospace' : undefined }}
            onFocus={e => (e.currentTarget.style.borderColor = 'rgba(37,99,235,0.6)')}
            onBlur={e => (e.currentTarget.style.borderColor = isDark ? 'rgba(37,99,235,0.25)' : '#e2e8f0')}
          />
          {children && <div className="absolute right-2.5 top-1/2 -translate-y-1/2">{children}</div>}
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: 'rgba(5,16,38,0.8)', backdropFilter: 'blur(8px)' }}
      onClick={e => e.target === e.currentTarget && onClose()}>

      <div className="w-full max-w-md rounded-xl overflow-hidden"
        style={{
          background: isDark ? 'rgb(8,25,55)' : '#ffffff',
          border: isDark ? '1px solid rgba(37,99,235,0.3)' : '1px solid #e2e8f0',
          boxShadow: '0 20px 60px rgba(5,16,38,0.6)',
        }}>

        {/* Modal header */}
        <div className="flex items-center justify-between px-5 py-3.5"
          style={{ borderBottom: isDark ? '1px solid rgba(37,99,235,0.15)' : '1px solid #f1f5f9' }}>
          <h2 className="text-sm font-bold" style={{ color: isDark ? '#f8fafc' : '#0f172a' }}>Add New Item</h2>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-white/5 transition-colors"
            style={{ color: isDark ? '#475569' : '#94a3b8' }}>
            <X size={16} />
          </button>
        </div>

        <form onSubmit={handleSave} className="p-5 space-y-4">
          {/* Category selector */}
          <div>
            <label className="block text-[10px] font-semibold uppercase tracking-widest mb-2"
              style={{ color: isDark ? '#64748b' : '#94a3b8' }}>Category</label>
            <div className="flex gap-1.5">
              {CATEGORIES.map(({ id, label, icon: Icon }) => (
                <button key={id} type="button"
                  onClick={() => setCategory(id)}
                  className={clsx('flex-1 flex flex-col items-center gap-1 py-2 rounded-lg text-[10px] font-semibold transition-all')}
                  style={category === id ? {
                    background: 'rgba(37,99,235,0.2)',
                    border: '1px solid rgba(37,99,235,0.4)',
                    color: '#60a5fa',
                  } : {
                    background: isDark ? 'rgba(37,99,235,0.05)' : '#f8fafc',
                    border: isDark ? '1px solid rgba(37,99,235,0.1)' : '1px solid #e2e8f0',
                    color: isDark ? '#475569' : '#94a3b8',
                  }}>
                  <Icon size={13} />
                  {label}
                </button>
              ))}
            </div>
          </div>

          {/* Name */}
          <Input label="Name *" value={name} onChange={setName} placeholder="e.g. Gmail, Netflix…" />

          {/* Category-specific fields */}
          {(category === 'login' || category === 'email') && (
            <>
              {category === 'login' && (
                <Input label="Username" value={username} onChange={setUsername} placeholder="username or handle" />
              )}
              <Input label="Email" value={email} onChange={setEmail} type="email" placeholder="email@example.com" />
              <Input label="Website URL" value={url} onChange={setUrl} placeholder="https://example.com" />
              <div>
                <label className="block text-[10px] font-semibold uppercase tracking-widest mb-1.5"
                  style={{ color: isDark ? '#64748b' : '#94a3b8' }}>Password</label>
                <div className="relative">
                  <input
                    type={showPwd ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="Enter or generate password…"
                    className="w-full px-3 py-2 pr-20 rounded-lg text-xs outline-none transition-all font-mono"
                    style={inputStyle}
                    onFocus={e => (e.currentTarget.style.borderColor = 'rgba(37,99,235,0.6)')}
                    onBlur={e => (e.currentTarget.style.borderColor = isDark ? 'rgba(37,99,235,0.25)' : '#e2e8f0')}
                  />
                  <div className="absolute right-2 top-1/2 -translate-y-1/2 flex gap-1">
                    <button type="button"
                      onClick={() => setPassword(generatePassword(20))}
                      className="text-[9px] font-bold px-1.5 py-0.5 rounded transition-colors"
                      style={{ background: 'rgba(37,99,235,0.2)', color: '#60a5fa' }}>
                      GEN
                    </button>
                    <button type="button" onClick={() => setShowPwd(v => !v)}
                      style={{ color: isDark ? '#475569' : '#94a3b8' }}>
                      {showPwd ? <EyeOff size={12} /> : <Eye size={12} />}
                    </button>
                  </div>
                </div>
                {strength && password && (
                  <div className="mt-1.5 flex items-center gap-2">
                    <div className="flex gap-1 flex-1">
                      {[0,1,2,3,4].map(i => (
                        <div key={i} className="h-1 rounded-full flex-1 transition-all"
                          style={{ background: i < strength.score ? strength.color : 'rgba(148,163,184,0.15)' }} />
                      ))}
                    </div>
                    <span className="text-[10px] font-semibold" style={{ color: strength.color }}>{strength.label}</span>
                  </div>
                )}
              </div>
            </>
          )}

          {category === 'card' && (
            <>
              <Input label="Card Number" value={username} onChange={setUsername} placeholder="**** **** **** ****" />
              <div className="grid grid-cols-2 gap-3">
                <Input label="Expiry" value={email} onChange={setEmail} placeholder="MM/YY" />
                <Input label="CVV" value={password} onChange={setPassword} type="password" placeholder="***" />
              </div>
            </>
          )}

          {/* Notes */}
          <div>
            <label className="block text-[10px] font-semibold uppercase tracking-widest mb-1.5"
              style={{ color: isDark ? '#64748b' : '#94a3b8' }}>Secure Notes</label>
            <textarea
              value={notes}
              onChange={e => setNotes(e.target.value)}
              placeholder="Optional notes…"
              rows={3}
              className="w-full px-3 py-2 rounded-lg text-xs outline-none transition-all resize-none"
              style={{ ...inputStyle, fontFamily: 'Inter, sans-serif', lineHeight: '1.5' }}
              onFocus={e => (e.currentTarget.style.borderColor = 'rgba(37,99,235,0.6)')}
              onBlur={e => (e.currentTarget.style.borderColor = isDark ? 'rgba(37,99,235,0.25)' : '#e2e8f0')}
            />
          </div>

          {error && (
            <div className="flex items-center gap-2 p-2.5 rounded-lg"
              style={{ background: 'rgba(220,38,38,0.08)', border: '1px solid rgba(220,38,38,0.2)' }}>
              <AlertCircle size={12} className="text-red-400 flex-shrink-0" />
              <p className="text-xs text-red-400">{error}</p>
            </div>
          )}

          {/* Actions */}
          <div className="flex gap-2 pt-1">
            <button type="button" onClick={onClose}
              className="flex-1 py-2 rounded-lg text-xs font-semibold transition-all"
              style={{ background: isDark ? 'rgba(37,99,235,0.08)' : '#f1f5f9', color: isDark ? '#94a3b8' : '#475569', border: isDark ? '1px solid rgba(37,99,235,0.15)' : '1px solid #e2e8f0' }}>
              Cancel
            </button>
            <button type="submit" disabled={loading}
              className="flex-1 py-2 rounded-lg text-xs font-semibold transition-all disabled:opacity-50"
              style={{ color: '#ffffff', background: 'linear-gradient(135deg, rgb(11,60,143), rgb(37,99,235))', border: '1px solid rgba(96,165,250,0.2)' }}>
              {loading ? 'Saving…' : 'Save Item'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
