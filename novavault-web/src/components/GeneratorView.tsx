import { useState, useCallback } from 'react';
import { Copy, RefreshCw, Zap } from 'lucide-react';
import { generatePassword, checkPasswordStrength } from '../lib/crypto';
import { useVaultStore } from '../store/vault';

export function GeneratorView() {
  const { theme } = useVaultStore();
  const isDark = theme === 'dark';

  const [length, setLength] = useState(20);
  const [uppercase, setUppercase] = useState(true);
  const [lowercase, setLowercase] = useState(true);
  const [numbers, setNumbers] = useState(true);
  const [symbols, setSymbols] = useState(true);
  const [password, setPassword] = useState(() => generatePassword(20));
  const [copied, setCopied] = useState(false);
  const [history, setHistory] = useState<string[]>([]);

  const generate = useCallback(() => {
    const p = generatePassword(length, { uppercase, lowercase, numbers, symbols });
    setPassword(p);
    setHistory(h => [p, ...h.slice(0, 9)]);
    setCopied(false);
  }, [length, uppercase, lowercase, numbers, symbols]);

  const strength = checkPasswordStrength(password);

  function copy() {
    navigator.clipboard.writeText(password);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  const surface = isDark ? 'rgba(8,25,55,0.6)' : '#ffffff';
  const border  = isDark ? '1px solid rgba(37,99,235,0.18)' : '1px solid #e2e8f0';
  const textColor = isDark ? '#f1f5f9' : '#0f172a';
  const mutedColor = isDark ? '#64748b' : '#94a3b8';

  function Toggle({ label, value, onChange }: { label: string; value: boolean; onChange: (v: boolean) => void }) {
    return (
      <div className="flex items-center justify-between py-2.5"
        style={{ borderBottom: isDark ? '1px solid rgba(37,99,235,0.1)' : '1px solid #f1f5f9' }}>
        <span className="text-xs font-medium" style={{ color: textColor }}>{label}</span>
        <button onClick={() => onChange(!value)}
          className="relative w-9 h-5 rounded-full transition-all duration-200 flex-shrink-0"
          style={{ background: value ? 'linear-gradient(135deg, rgb(11,60,143), rgb(37,99,235))' : (isDark ? 'rgba(255,255,255,0.08)' : '#e2e8f0') }}>
          <span className="absolute top-0.5 h-4 w-4 rounded-full bg-white transition-all duration-200"
            style={{ left: value ? 'calc(100% - 18px)' : '2px', boxShadow: '0 1px 3px rgba(0,0,0,0.3)' }} />
        </button>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto p-6" style={{ background: isDark ? 'rgba(5,16,38,0.4)' : '#f4f6f9' }}>
      <div className="max-w-lg mx-auto space-y-4">

        {/* Header */}
        <div className="flex items-center gap-2 mb-2">
          <div className="p-2 rounded-lg" style={{ background: 'rgba(37,99,235,0.15)', border: '1px solid rgba(37,99,235,0.2)' }}>
            <Zap size={16} className="text-blue-400" />
          </div>
          <div>
            <h2 className="text-sm font-bold" style={{ color: textColor }}>Password Generator</h2>
            <p className="text-xs" style={{ color: mutedColor }}>Cryptographically secure random passwords</p>
          </div>
        </div>

        {/* Generated password display */}
        <div className="rounded-xl p-4" style={{ background: surface, border }}>
          <div className="flex items-center gap-2 mb-3">
            <code className="flex-1 text-sm font-mono break-all leading-relaxed"
              style={{ color: isDark ? '#93c5fd' : '#0b3c8f' }}>
              {password}
            </code>
          </div>

          {/* Strength */}
          <div className="flex items-center gap-2 mb-3">
            <div className="flex gap-1 flex-1">
              {[0,1,2,3,4].map(i => (
                <div key={i} className="h-1.5 rounded-full flex-1 transition-all"
                  style={{ background: i < strength.score ? strength.color : 'rgba(148,163,184,0.15)' }} />
              ))}
            </div>
            <span className="text-xs font-semibold" style={{ color: strength.color }}>{strength.label}</span>
          </div>

          <div className="flex gap-2">
            <button onClick={generate}
              className="flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-xs font-semibold transition-all"
              style={{ background: 'rgba(37,99,235,0.15)', color: '#60a5fa', border: '1px solid rgba(37,99,235,0.2)' }}>
              <RefreshCw size={12} /> Regenerate
            </button>
            <button onClick={copy}
              className="flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-xs font-semibold transition-all"
              style={{ color: '#ffffff', background: copied ? '#059669' : 'linear-gradient(135deg, rgb(11,60,143), rgb(37,99,235))', border: '1px solid rgba(96,165,250,0.2)' }}>
              <Copy size={12} /> {copied ? 'Copied!' : 'Copy'}
            </button>
          </div>
        </div>

        {/* Options */}
        <div className="rounded-xl p-4" style={{ background: surface, border }}>
          <h3 className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: mutedColor }}>Options</h3>

          {/* Length slider */}
          <div className="mb-3">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-medium" style={{ color: textColor }}>Password Length</span>
              <span className="text-sm font-bold tabular" style={{ color: '#60a5fa' }}>{length}</span>
            </div>
            <input type="range" min="8" max="64" value={length}
              onChange={e => setLength(Number(e.target.value))}
              className="w-full h-1.5 rounded-full appearance-none cursor-pointer"
              style={{ background: `linear-gradient(to right, rgb(37,99,235) ${((length-8)/56)*100}%, rgba(37,99,235,0.15) ${((length-8)/56)*100}%)` }} />
            <div className="flex justify-between mt-1">
              <span className="text-[9px]" style={{ color: mutedColor }}>8</span>
              <span className="text-[9px]" style={{ color: mutedColor }}>64</span>
            </div>
          </div>

          <Toggle label="Uppercase (A–Z)" value={uppercase} onChange={setUppercase} />
          <Toggle label="Lowercase (a–z)" value={lowercase} onChange={setLowercase} />
          <Toggle label="Numbers (0–9)" value={numbers} onChange={setNumbers} />
          <Toggle label="Symbols (!@#$…)" value={symbols} onChange={setSymbols} />
        </div>

        {/* History */}
        {history.length > 0 && (
          <div className="rounded-xl p-4" style={{ background: surface, border }}>
            <h3 className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: mutedColor }}>Recent (Session Only)</h3>
            <div className="space-y-2">
              {history.map((p, i) => (
                <div key={i} className="flex items-center gap-2 py-1.5 px-2 rounded-lg"
                  style={{ background: isDark ? 'rgba(37,99,235,0.05)' : '#f8fafc', border: isDark ? '1px solid rgba(37,99,235,0.08)' : '1px solid #f1f5f9' }}>
                  <code className="flex-1 text-xs font-mono truncate"
                    style={{ color: isDark ? '#64748b' : '#94a3b8' }}>{p}</code>
                  <button onClick={() => { navigator.clipboard.writeText(p); }}
                    className="p-1 transition-colors" style={{ color: isDark ? '#475569' : '#cbd5e1' }}>
                    <Copy size={11} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
