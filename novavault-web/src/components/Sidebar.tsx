import {
  Shield, Lock, Star, CreditCard, FileText, User,
  Zap, Settings, Plus, LogOut, ChevronRight, Mail
} from 'lucide-react';
import { useVaultStore } from '../store/vault';
import clsx from 'clsx';

const NAV_CATEGORIES = [
  { id: 'all',        label: 'All Items',   icon: Shield },
  { id: 'favourites', label: 'Favourites',  icon: Star },
  { id: 'login',      label: 'Logins',      icon: Lock },
  { id: 'email',      label: 'Email',       icon: Mail },
  { id: 'card',       label: 'Cards',       icon: CreditCard },
  { id: 'note',       label: 'Secure Notes',icon: FileText },
  { id: 'identity',   label: 'Identities',  icon: User },
] as const;

interface SidebarProps { onAddNew: () => void }

export function Sidebar({ onAddNew }: SidebarProps) {
  const { selectedCategory, setSelectedCategory, view, setView, lock, stats, theme, items } = useVaultStore();
  const s = stats();
  const isDark = theme === 'dark';

  const counts: Record<string, number> = {
    all: items.length,
    favourites: items.filter(i => i.favourite).length,
    login: items.filter(i => i.category === 'login').length,
    email: items.filter(i => i.category === 'email').length,
    card: items.filter(i => i.category === 'card').length,
    note: items.filter(i => i.category === 'note').length,
    identity: items.filter(i => i.category === 'identity').length,
  };

  return (
    <aside className="w-56 flex-shrink-0 flex flex-col h-full"
      style={{
        background: isDark
          ? 'linear-gradient(180deg, rgb(5,16,38) 0%, rgb(8,22,50) 100%)'
          : 'linear-gradient(180deg, rgb(5,16,38) 0%, rgb(11,60,143) 100%)',
        borderRight: '1px solid rgba(37,99,235,0.2)',
      }}>

      {/* Logo */}
      <div className="px-4 py-4 flex items-center gap-2.5" style={{ borderBottom: '1px solid rgba(37,99,235,0.15)' }}>
        <div className="w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ background: 'linear-gradient(135deg, rgba(37,99,235,0.6), rgba(11,60,143,0.8))', border: '1px solid rgba(96,165,250,0.3)' }}>
          <Shield size={14} className="text-blue-200" />
        </div>
        <span className="font-bold text-white text-sm tracking-tight">NovaVault</span>
        <div className="ml-auto">
          <div className="w-1.5 h-1.5 rounded-full bg-emerald-400" style={{ boxShadow: '0 0 6px rgba(52,211,153,0.6)' }} />
        </div>
      </div>

      {/* Quick Stats */}
      <div className="px-3 py-3" style={{ borderBottom: '1px solid rgba(37,99,235,0.1)' }}>
        <div className="grid grid-cols-3 gap-1.5">
          {[
            { label: 'TOTAL', value: s.total },
            { label: 'LOGINS', value: s.logins },
            { label: 'WEAK', value: s.weak, alert: s.weak > 0 },
          ].map(stat => (
            <div key={stat.label} className="rounded-md p-2 text-center"
              style={{ background: 'rgba(37,99,235,0.08)', border: '1px solid rgba(37,99,235,0.12)' }}>
              <div className={clsx('text-base font-bold tabular', stat.alert ? 'text-amber-400' : 'text-blue-200')}>
                {stat.value}
              </div>
              <div className="text-[9px] text-slate-500 font-semibold uppercase tracking-widest mt-0.5">
                {stat.label}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Add New Button */}
      <div className="px-3 pt-3">
        <button onClick={onAddNew}
          className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold transition-all duration-150"
          style={{ background: 'linear-gradient(135deg, rgb(11,60,143), rgb(37,99,235))', color: '#ffffff', border: '1px solid rgba(96,165,250,0.2)' }}>
          <Plus size={13} />
          Add New Item
        </button>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-2 py-3 overflow-y-auto space-y-0.5">
        <p className="text-[9px] font-bold text-slate-600 uppercase tracking-[0.1em] px-2 mb-2">Vault</p>
        {NAV_CATEGORIES.map(({ id, label, icon: Icon }) => {
          const active = view === 'vault' && selectedCategory === id;
          return (
            <button key={id}
              onClick={() => { setView('vault'); setSelectedCategory(id as any); }}
              className={clsx(
                'w-full flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-xs font-medium transition-all duration-150 group',
                active
                  ? 'text-white'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-white/5'
              )}
              style={active ? { background: 'rgba(37,99,235,0.25)', border: '1px solid rgba(37,99,235,0.3)' } : { border: '1px solid transparent' }}>
              <Icon size={13} className={active ? 'text-blue-300' : 'text-slate-600 group-hover:text-slate-400'} />
              <span className="flex-1 text-left">{label}</span>
              {counts[id] > 0 && (
                <span className={clsx('text-[10px] tabular font-semibold px-1.5 py-0.5 rounded',
                  active ? 'bg-blue-500/30 text-blue-200' : 'bg-white/5 text-slate-500')}>
                  {counts[id]}
                </span>
              )}
              {active && <ChevronRight size={11} className="text-blue-400" />}
            </button>
          );
        })}

        <div className="pt-3 pb-1">
          <p className="text-[9px] font-bold text-slate-600 uppercase tracking-[0.1em] px-2 mb-2">Tools</p>
        </div>

        {[
          { id: 'generator', label: 'Password Generator', icon: Zap },
          { id: 'settings',  label: 'Settings',           icon: Settings },
        ].map(({ id, label, icon: Icon }) => {
          const active = view === id;
          return (
            <button key={id}
              onClick={() => setView(id as any)}
              className={clsx(
                'w-full flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-xs font-medium transition-all duration-150 group',
                active ? 'text-white' : 'text-slate-400 hover:text-slate-200 hover:bg-white/5'
              )}
              style={active ? { background: 'rgba(37,99,235,0.25)', border: '1px solid rgba(37,99,235,0.3)' } : { border: '1px solid transparent' }}>
              <Icon size={13} className={active ? 'text-blue-300' : 'text-slate-600 group-hover:text-slate-400'} />
              <span>{label}</span>
            </button>
          );
        })}
      </nav>

      {/* Lock button */}
      <div className="px-3 py-3" style={{ borderTop: '1px solid rgba(37,99,235,0.15)' }}>
        <button onClick={lock}
          className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-medium text-slate-400 hover:text-red-400 hover:bg-red-500/5 transition-all duration-150"
          style={{ border: '1px solid transparent' }}>
          <LogOut size={13} />
          Lock Vault
        </button>
      </div>
    </aside>
  );
}
