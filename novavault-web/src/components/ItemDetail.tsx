import { useState } from 'react';
import {
  Copy, Eye, EyeOff, Star, Trash2, Edit3, ExternalLink,
  Lock, Mail, CreditCard, FileText, User, Shield, Clock
} from 'lucide-react';
import { useVaultStore, type VaultItemDecrypted, type ItemCategory } from '../store/vault';
import { getSessionMasterPassword } from '../store/vault';
import { checkPasswordStrength } from '../lib/crypto';
import clsx from 'clsx';

function copyToClipboard(text: string) {
  navigator.clipboard.writeText(text);
}

export function ItemDetail() {
  const { items, selectedItemId, deleteItem, theme } = useVaultStore();
  const { decryptItem } = useVaultStore();
  const [decrypted, setDecrypted] = useState<VaultItemDecrypted | null>(null);
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);

  const isDark = theme === 'dark';
  const item = items.find(i => i.id === selectedItemId);

  async function loadDecrypted() {
    if (!item) return;
    setLoading(true);
    const mp = getSessionMasterPassword();
    if (mp) {
      const d = await decryptItem(item, mp);
      setDecrypted(d);
    }
    setLoading(false);
  }

  // Load when selection changes
  if (item && (!decrypted || decrypted.id !== item.id)) {
    loadDecrypted();
    setRevealed({});
  }

  function handleCopy(key: string, value?: string) {
    if (!value) return;
    copyToClipboard(value);
    setCopied(key);
    setTimeout(() => setCopied(null), 2000);
  }

  function toggleReveal(key: string) {
    setRevealed(r => ({ ...r, [key]: !r[key] }));
  }

  if (!item) {
    return (
      <div className="flex-1 flex items-center justify-center"
        style={{ background: isDark ? 'rgba(5,16,38,0.4)' : '#f4f6f9' }}>
        <div className="text-center opacity-30">
          <Shield size={40} style={{ color: isDark ? '#1e3a6b' : '#cbd5e1', margin: '0 auto 12px' }} />
          <p className="text-sm font-medium" style={{ color: isDark ? '#475569' : '#94a3b8' }}>
            Select an item to view details
          </p>
        </div>
      </div>
    );
  }

  const strength = decrypted?.password ? checkPasswordStrength(decrypted.password) : null;
  const updatedDate = new Date(item.updatedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });

  const CategoryIcon = {
    login: Lock, email: Mail, card: CreditCard, note: FileText, identity: User
  }[item.category] || Shield;

  return (
    <div className="flex-1 flex flex-col h-full overflow-hidden"
      style={{ background: isDark ? 'rgba(5,16,38,0.4)' : '#f4f6f9' }}>

      {/* Item header */}
      <div className="px-5 py-4 flex items-start gap-3 flex-shrink-0"
        style={{ borderBottom: isDark ? '1px solid rgba(37,99,235,0.12)' : '1px solid #e2e8f0' }}>

        <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{ background: 'linear-gradient(135deg, rgba(11,60,143,0.5), rgba(37,99,235,0.3))', border: '1px solid rgba(37,99,235,0.3)' }}>
          <CategoryIcon size={16} className="text-blue-300" />
        </div>

        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-bold truncate" style={{ color: isDark ? '#f8fafc' : '#0f172a' }}>
            {item.name}
          </h3>
          <div className="flex items-center gap-2 mt-0.5">
            <span className="text-xs capitalize px-1.5 py-0.5 rounded"
              style={{ background: isDark ? 'rgba(37,99,235,0.15)' : 'rgba(11,60,143,0.08)', color: '#60a5fa', fontSize: '10px', fontWeight: 600 }}>
              {item.category}
            </span>
            <span className="flex items-center gap-1 text-[10px]" style={{ color: isDark ? '#475569' : '#94a3b8' }}>
              <Clock size={9} /> {updatedDate}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-1.5">
          <button onClick={() => { /* edit */ }}
            className="p-1.5 rounded-lg transition-colors hover:bg-blue-500/10"
            style={{ color: isDark ? '#475569' : '#94a3b8' }}>
            <Edit3 size={14} />
          </button>
          <button onClick={() => { if (window.confirm('Delete this item?')) deleteItem(item.id); }}
            className="p-1.5 rounded-lg transition-colors hover:bg-red-500/10"
            style={{ color: isDark ? '#475569' : '#94a3b8' }}>
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      {/* Fields */}
      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3">
        {loading && (
          <div className="text-center py-4 text-xs text-slate-500">Decrypting…</div>
        )}

        {/* URL */}
        {item.url && (
          <FieldRow isDark={isDark} label="Website" value={item.url} copyKey="url" copied={copied} onCopy={handleCopy}>
            <a href={item.url} target="_blank" rel="noopener noreferrer"
              className="p-1 hover:text-blue-400 transition-colors" style={{ color: isDark ? '#475569' : '#94a3b8' }}>
              <ExternalLink size={12} />
            </a>
          </FieldRow>
        )}

        {/* Username */}
        {item.username && (
          <FieldRow isDark={isDark} label="Username" value={item.username} copyKey="username" copied={copied} onCopy={handleCopy} />
        )}

        {/* Email */}
        {item.email && (
          <FieldRow isDark={isDark} label="Email" value={item.email} copyKey="email" copied={copied} onCopy={handleCopy} />
        )}

        {/* Password */}
        {decrypted?.password && (
          <div>
            <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">
              Password
            </label>
            <div className="flex items-center gap-2 px-3 py-2.5 rounded-lg"
              style={{ background: isDark ? 'rgba(8,25,55,0.6)' : '#ffffff', border: isDark ? '1px solid rgba(37,99,235,0.18)' : '1px solid #e2e8f0' }}>
              <code className="flex-1 text-xs font-mono truncate"
                style={{ color: isDark ? '#93c5fd' : '#0b3c8f' }}>
                {revealed.password ? decrypted.password : '••••••••••••••••'}
              </code>
              <button onClick={() => toggleReveal('password')}
                className="p-1 transition-colors" style={{ color: isDark ? '#475569' : '#94a3b8' }}>
                {revealed.password ? <EyeOff size={12} /> : <Eye size={12} />}
              </button>
              <button onClick={() => handleCopy('password', decrypted.password)}
                className="p-1 transition-colors"
                style={{ color: copied === 'password' ? '#059669' : isDark ? '#475569' : '#94a3b8' }}>
                <Copy size={12} />
              </button>
            </div>
            {/* Strength */}
            {strength && (
              <div className="mt-1.5 flex items-center gap-2">
                <div className="flex gap-1 flex-1">
                  {[0,1,2,3,4].map(i => (
                    <div key={i} className="h-1 rounded-full flex-1"
                      style={{ background: i < strength.score ? strength.color : 'rgba(148,163,184,0.15)' }} />
                  ))}
                </div>
                <span className="text-[10px] font-semibold" style={{ color: strength.color }}>{strength.label}</span>
              </div>
            )}
          </div>
        )}

        {/* Notes */}
        {decrypted?.notes && (
          <div>
            <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">
              Notes
            </label>
            <div className="px-3 py-2.5 rounded-lg"
              style={{ background: isDark ? 'rgba(8,25,55,0.6)' : '#ffffff', border: isDark ? '1px solid rgba(37,99,235,0.18)' : '1px solid #e2e8f0' }}>
              <p className="text-xs leading-relaxed whitespace-pre-wrap"
                style={{ color: isDark ? '#94a3b8' : '#475569' }}>
                {decrypted.notes}
              </p>
            </div>
          </div>
        )}

        {/* Tags */}
        {item.tags.length > 0 && (
          <div>
            <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Tags</label>
            <div className="flex flex-wrap gap-1.5">
              {item.tags.map(tag => (
                <span key={tag} className="px-2 py-0.5 rounded text-[10px] font-medium"
                  style={{ background: isDark ? 'rgba(37,99,235,0.1)' : 'rgba(11,60,143,0.06)', color: '#60a5fa', border: '1px solid rgba(37,99,235,0.2)' }}>
                  {tag}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function FieldRow({ isDark, label, value, copyKey, copied, onCopy, children }: {
  isDark: boolean; label: string; value: string; copyKey: string;
  copied: string | null; onCopy: (k: string, v: string) => void;
  children?: React.ReactNode;
}) {
  return (
    <div>
      <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">
        {label}
      </label>
      <div className="flex items-center gap-2 px-3 py-2.5 rounded-lg"
        style={{ background: isDark ? 'rgba(8,25,55,0.6)' : '#ffffff', border: isDark ? '1px solid rgba(37,99,235,0.18)' : '1px solid #e2e8f0' }}>
        <span className="flex-1 text-xs truncate" style={{ color: isDark ? '#e2e8f0' : '#0f172a' }}>
          {value}
        </span>
        {children}
        <button onClick={() => onCopy(copyKey, value)}
          className="p-1 transition-colors"
          style={{ color: copied === copyKey ? '#059669' : isDark ? '#475569' : '#94a3b8' }}>
          <Copy size={12} />
        </button>
      </div>
    </div>
  );
}
