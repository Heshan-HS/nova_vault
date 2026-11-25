import { Plus, Lock, Star, CreditCard, FileText, User, Mail, Shield } from 'lucide-react';
import { useVaultStore, type ItemCategory } from '../store/vault';
import clsx from 'clsx';

const CATEGORY_ICONS: Record<ItemCategory, React.ElementType> = {
  login: Lock, email: Mail, card: CreditCard, note: FileText, identity: User,
};

const CATEGORY_COLORS: Record<ItemCategory, string> = {
  login:    'text-blue-400 bg-blue-400/10',
  email:    'text-violet-400 bg-violet-400/10',
  card:     'text-amber-400 bg-amber-400/10',
  note:     'text-emerald-400 bg-emerald-400/10',
  identity: 'text-cyan-400 bg-cyan-400/10',
};

interface ItemListProps { onAddNew: () => void }

export function ItemList({ onAddNew }: ItemListProps) {
  const { filteredItems, selectedItemId, setSelectedItemId, theme, selectedCategory } = useVaultStore();
  const items = filteredItems();
  const isDark = theme === 'dark';

  return (
    <div className="w-72 flex-shrink-0 flex flex-col h-full overflow-hidden"
      style={{
        background: isDark ? 'rgba(5,16,38,0.6)' : '#f8fafc',
        borderRight: isDark ? '1px solid rgba(37,99,235,0.12)' : '1px solid #e2e8f0',
      }}>

      {/* List header */}
      <div className="px-4 py-3 flex items-center justify-between flex-shrink-0"
        style={{ borderBottom: isDark ? '1px solid rgba(37,99,235,0.1)' : '1px solid #e2e8f0' }}>
        <span className="text-xs font-semibold uppercase tracking-widest"
          style={{ color: isDark ? '#64748b' : '#94a3b8' }}>
          {items.length} {items.length === 1 ? 'item' : 'items'}
        </span>
        <button onClick={onAddNew}
          className="flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium transition-all"
          style={{ background: 'rgba(37,99,235,0.15)', color: '#60a5fa', border: '1px solid rgba(37,99,235,0.2)' }}>
          <Plus size={11} />
          Add
        </button>
      </div>

      {/* Items */}
      <div className="flex-1 overflow-y-auto py-1.5 px-2 space-y-0.5">
        {items.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full pb-16 opacity-50">
            <Shield size={32} className="mb-3" style={{ color: isDark ? '#1e3a6b' : '#cbd5e1' }} />
            <p className="text-xs font-medium" style={{ color: isDark ? '#475569' : '#94a3b8' }}>No items found</p>
            <button onClick={onAddNew} className="mt-3 text-xs text-blue-400 hover:text-blue-300 font-medium">
              + Add your first item
            </button>
          </div>
        ) : (
          items.map(item => {
            const Icon = CATEGORY_ICONS[item.category];
            const colorClass = CATEGORY_COLORS[item.category];
            const isSelected = selectedItemId === item.id;
            const domain = item.url ? (() => { try { return new URL(item.url).hostname; } catch { return item.url; } })() : null;

            return (
              <button key={item.id}
                onClick={() => setSelectedItemId(item.id)}
                className={clsx(
                  'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-all duration-150 group',
                )}
                style={isSelected ? {
                  background: isDark ? 'rgba(37,99,235,0.2)' : 'rgba(11,60,143,0.08)',
                  border: isDark ? '1px solid rgba(37,99,235,0.35)' : '1px solid rgba(11,60,143,0.2)',
                } : {
                  background: 'transparent',
                  border: '1px solid transparent',
                }}>

                {/* Icon */}
                <div className={clsx('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 text-xs', colorClass)}>
                  <Icon size={14} />
                </div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5">
                    <p className="text-xs font-semibold truncate"
                      style={{ color: isDark ? '#f1f5f9' : '#0f172a' }}>
                      {item.name}
                    </p>
                    {item.favourite && <Star size={9} className="text-amber-400 fill-current flex-shrink-0" />}
                  </div>
                  <p className="text-[11px] truncate mt-0.5"
                    style={{ color: isDark ? '#475569' : '#94a3b8' }}>
                    {item.username || item.email || domain || item.category}
                  </p>
                </div>

                {/* Strength dot */}
                {item.password && (
                  <div className="w-1.5 h-1.5 rounded-full flex-shrink-0"
                    style={{ background: (item.strength ?? 3) >= 3 ? '#059669' : (item.strength ?? 3) >= 2 ? '#d97706' : '#dc2626' }} />
                )}
              </button>
            );
          })
        )}
      </div>
    </div>
  );
}
