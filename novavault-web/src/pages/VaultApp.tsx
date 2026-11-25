import { Sidebar } from '../components/Sidebar';
import { ItemList } from '../components/ItemList';
import { ItemDetail } from '../components/ItemDetail';
import { AddItemModal } from '../components/AddItemModal';
import { GeneratorView } from '../components/GeneratorView';
import { SettingsView } from '../components/SettingsView';
import { TopBar } from '../components/TopBar';
import { useVaultStore } from '../store/vault';
import { useState } from 'react';

export function VaultApp() {
  const { view, theme } = useVaultStore();
  const [showAdd, setShowAdd] = useState(false);

  const isDark = theme === 'dark';

  return (
    <div className={`flex h-screen overflow-hidden ${isDark ? 'dark' : ''}`}
      style={{ background: isDark ? 'rgb(5,16,38)' : '#f4f6f9' }}>

      {/* Sidebar */}
      <Sidebar onAddNew={() => setShowAdd(true)} />

      {/* Main area */}
      <div className="flex flex-1 overflow-hidden flex-col">
        <TopBar />

        <div className="flex flex-1 overflow-hidden">
          {view === 'vault' && (
            <>
              <ItemList onAddNew={() => setShowAdd(true)} />
              <ItemDetail />
            </>
          )}
          {view === 'generator' && <GeneratorView />}
          {view === 'settings' && <SettingsView />}
        </div>
      </div>

      {showAdd && <AddItemModal onClose={() => setShowAdd(false)} />}
    </div>
  );
}
