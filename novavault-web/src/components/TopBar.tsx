import { Search, Sun, Moon, Bell } from 'lucide-react';
import { useVaultStore } from '../store/vault';

export function TopBar() {
  const { searchQuery, setSearchQuery, theme, setTheme, selectedCategory, view } = useVaultStore();
  const isDark = theme === 'dark';

  const title = view === 'generator' ? 'Password Generator'
    : view === 'settings' ? 'Settings'
    : selectedCategory === 'all' ? 'All Items'
    : selectedCategory === 'favourites' ? 'Favourites'
    : selectedCategory.charAt(0).toUpperCase() + selectedCategory.slice(1) + 's';

  return (
    <header className="h-12 flex items-center px-4 gap-3 flex-shrink-0"
      style={{
        background: isDark ? 'rgba(5,16,38,0.95)' : '#ffffff',
        borderBottom: isDark ? '1px solid rgba(37,99,235,0.15)' : '1px solid #e2e8f0',
        backdropFilter: 'blur(8px)',
      }}>

      {/* Title */}
      <h2 className="text-sm font-semibold tracking-tight flex-shrink-0"
        style={{ color: isDark ? '#f8fafc' : '#0f172a' }}>
        {title}
      </h2>

      <div className="w-px h-4 mx-1" style={{ background: isDark ? 'rgba(37,99,235,0.2)' : '#e2e8f0' }} />

      {/* Search */}
      {view === 'vault' && (
        <div className="flex-1 relative max-w-xs">
          <Search size={13} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-500" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search vault…"
            className="w-full pl-8 pr-3 py-1.5 rounded-lg text-xs outline-none transition-all"
            style={{
              background: isDark ? 'rgba(11,60,143,0.1)' : '#f8fafc',
              border: isDark ? '1px solid rgba(37,99,235,0.2)' : '1px solid #e2e8f0',
              color: isDark ? '#f8fafc' : '#0f172a',
            }}
          />
        </div>
      )}

      <div className="ml-auto flex items-center gap-2">
        {/* Security badge */}
        <div className="flex items-center gap-1.5 px-2 py-1 rounded-md"
          style={{ background: 'rgba(5,150,105,0.08)', border: '1px solid rgba(5,150,105,0.2)' }}>
          <div className="w-1.5 h-1.5 rounded-full bg-emerald-400" style={{ boxShadow: '0 0 4px rgba(52,211,153,0.6)' }} />
          <span className="text-[10px] font-semibold text-emerald-400 uppercase tracking-wide">Encrypted</span>
        </div>

        {/* Notifications */}
        <button className="p-1.5 rounded-lg transition-colors hover:bg-white/5"
          style={{ color: isDark ? '#64748b' : '#94a3b8' }}>
          <Bell size={14} />
        </button>

        {/* Theme toggle */}
        <button
          onClick={() => setTheme(isDark ? 'light' : 'dark')}
          className="p-1.5 rounded-lg transition-all duration-200"
          style={{
            background: isDark ? 'rgba(37,99,235,0.1)' : 'rgba(11,60,143,0.08)',
            border: isDark ? '1px solid rgba(37,99,235,0.2)' : '1px solid rgba(11,60,143,0.15)',
            color: isDark ? '#60a5fa' : '#0b3c8f',
          }}>
          {isDark ? <Sun size={13} /> : <Moon size={13} />}
        </button>
      </div>
    </header>
  );
}
