import { Settings, Shield, Moon, Sun, Download, Upload, Trash2, Info } from 'lucide-react';
import { useVaultStore } from '../store/vault';

export function SettingsView() {
  const { theme, setTheme, items, lock } = useVaultStore();
  const isDark = theme === 'dark';

  const surface  = isDark ? 'rgba(8,25,55,0.6)' : '#ffffff';
  const border   = isDark ? '1px solid rgba(37,99,235,0.18)' : '1px solid #e2e8f0';
  const text     = isDark ? '#f1f5f9' : '#0f172a';
  const muted    = isDark ? '#64748b' : '#94a3b8';

  function exportVault() {
    const data = localStorage.getItem('novavault_v1');
    if (!data) return;
    const blob = new Blob([data], { type: 'application/json' });
    const url  = URL.createObjectURL(blob);
    const a    = document.createElement('a');
    a.href = url;
    a.download = `novavault-backup-${new Date().toISOString().slice(0,10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
  }

  function Section({ title, children }: { title: string; children: React.ReactNode }) {
    return (
      <div className="rounded-xl overflow-hidden" style={{ background: surface, border }}>
        <div className="px-4 py-2.5" style={{ borderBottom: isDark ? '1px solid rgba(37,99,235,0.1)' : '1px solid #f1f5f9' }}>
          <h3 className="text-[10px] font-bold uppercase tracking-widest" style={{ color: muted }}>{title}</h3>
        </div>
        <div className="divide-y" style={{ borderColor: isDark ? 'rgba(37,99,235,0.08)' : '#f8fafc' }}>
          {children}
        </div>
      </div>
    );
  }

  function Row({ label, description, children }: { label: string; description?: string; children: React.ReactNode }) {
    return (
      <div className="flex items-center justify-between px-4 py-3">
        <div>
          <p className="text-xs font-medium" style={{ color: text }}>{label}</p>
          {description && <p className="text-[11px] mt-0.5" style={{ color: muted }}>{description}</p>}
        </div>
        {children}
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto p-6" style={{ background: isDark ? 'rgba(5,16,38,0.4)' : '#f4f6f9' }}>
      <div className="max-w-lg mx-auto space-y-4">

        <div className="flex items-center gap-2 mb-2">
          <div className="p-2 rounded-lg" style={{ background: 'rgba(37,99,235,0.15)', border: '1px solid rgba(37,99,235,0.2)' }}>
            <Settings size={16} className="text-blue-400" />
          </div>
          <div>
            <h2 className="text-sm font-bold" style={{ color: text }}>Settings</h2>
            <p className="text-xs" style={{ color: muted }}>Manage your NovaVault preferences</p>
          </div>
        </div>

        <Section title="Appearance">
          <Row label="Theme" description="Choose light or dark mode">
            <div className="flex gap-1.5">
              {(['light', 'dark'] as const).map(t => (
                <button key={t}
                  onClick={() => setTheme(t)}
                  className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-semibold transition-all"
                  style={theme === t ? {
                    background: 'linear-gradient(135deg, rgb(11,60,143), rgb(37,99,235))',
                    color: '#ffffff', border: '1px solid rgba(96,165,250,0.2)',
                  } : {
                    background: isDark ? 'rgba(37,99,235,0.08)' : '#f1f5f9',
                    color: muted,
                    border: isDark ? '1px solid rgba(37,99,235,0.15)' : '1px solid #e2e8f0',
                  }}>
                  {t === 'light' ? <Sun size={11} /> : <Moon size={11} />}
                  {t.charAt(0).toUpperCase() + t.slice(1)}
                </button>
              ))}
            </div>
          </Row>
        </Section>

        <Section title="Security">
          <Row label="Encryption" description="AES-256-GCM with PBKDF2 (310,000 iterations)">
            <div className="flex items-center gap-1.5 px-2 py-1 rounded-md"
              style={{ background: 'rgba(5,150,105,0.08)', border: '1px solid rgba(5,150,105,0.2)' }}>
              <Shield size={11} className="text-emerald-400" />
              <span className="text-[10px] font-bold text-emerald-400">ACTIVE</span>
            </div>
          </Row>
          <Row label="Zero-Knowledge Architecture" description="Your master password never leaves this device">
            <span className="text-[10px] font-semibold text-emerald-400">✓ Enabled</span>
          </Row>
          <Row label="Lock Vault" description="Requires master password to re-access">
            <button onClick={lock}
              className="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
              style={{ background: 'rgba(220,38,38,0.1)', color: '#f87171', border: '1px solid rgba(220,38,38,0.2)' }}>
              Lock Now
            </button>
          </Row>
        </Section>

        <Section title="Data">
          <Row label="Total Items" description="Stored securely in this browser">
            <span className="text-sm font-bold tabular" style={{ color: '#60a5fa' }}>{items.length}</span>
          </Row>
          <Row label="Export Backup" description="Download an encrypted JSON backup">
            <button onClick={exportVault}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
              style={{ background: 'rgba(37,99,235,0.1)', color: '#60a5fa', border: '1px solid rgba(37,99,235,0.2)' }}>
              <Download size={11} /> Export
            </button>
          </Row>
          <Row label="Import Backup" description="Restore from a previous backup file">
            <button
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
              style={{ background: 'rgba(37,99,235,0.1)', color: '#60a5fa', border: '1px solid rgba(37,99,235,0.2)' }}>
              <Upload size={11} /> Import
            </button>
          </Row>
        </Section>

        <Section title="About">
          <Row label="NovaVault" description="Ultra-Secure Personal Password Manager">
            <div className="flex items-center gap-1.5">
              <Info size={12} style={{ color: muted }} />
              <span className="text-xs font-mono" style={{ color: muted }}>v1.0.0</span>
            </div>
          </Row>
          <Row label="Encryption Standard" description="NIST-approved AES-256-GCM">
            <span className="text-[10px] font-semibold" style={{ color: '#60a5fa' }}>AES-256-GCM</span>
          </Row>
        </Section>

      </div>
    </div>
  );
}
