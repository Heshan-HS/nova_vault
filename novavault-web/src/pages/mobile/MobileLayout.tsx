import React, { useState } from 'react';
import { MobileVaultList } from './MobileVaultList';
import { MobileItemDetail } from './MobileItemDetail';
import { GeneratorScreen } from '../screens/GeneratorScreen';
import { SecurityScreen } from '../screens/SecurityScreen';
import { SettingsScreen } from '../screens/SettingsScreen';
import type { TabKey } from '../../components/TabBar';
import type { VaultListItem } from '../desktop/ListPane';
import { MOCK_ITEMS } from '../../data/mockData';

interface MobileLayoutProps {
  onNewItem?: () => void;
  onLockVault?: () => void;
}

export function MobileLayout({ onNewItem, onLockVault }: MobileLayoutProps) {
  const [activeTab, setActiveTab] = useState<TabKey>('vault');
  const [selectedItem, setSelectedItem] = useState<VaultListItem | null>(null);

  const handleSelect = (item: VaultListItem) => {
    setSelectedItem(item);
  };

  const handleBack = () => {
    setSelectedItem(null);
  };

  return (
    <div
      style={{
        width: '100%',
        maxWidth: 430,
        height: '100%',
        margin: '0 auto',
        position: 'relative',
        overflow: 'hidden',
        background: 'var(--bg)',
        boxShadow: '0 20px 60px rgba(0,0,0,0.3)',
      }}
    >
      {activeTab === 'vault' ? (
        selectedItem ? (
          <MobileItemDetail
            item={selectedItem}
            onBack={handleBack}
            activeTab={activeTab}
            onTabChange={(tab) => {
              setSelectedItem(null);
              setActiveTab(tab);
            }}
          />
        ) : (
          <MobileVaultList
            onSelectItem={handleSelect}
            onNewItem={onNewItem}
            activeTab={activeTab}
            onTabChange={setActiveTab}
          />
        )
      ) : activeTab === 'generator' ? (
        <GeneratorScreen
          activeTab={activeTab}
          onTabChange={setActiveTab}
          isMobile={true}
        />
      ) : activeTab === 'security' ? (
        <SecurityScreen
          activeTab={activeTab}
          onTabChange={setActiveTab}
          isMobile={true}
        />
      ) : (
        <SettingsScreen
          activeTab={activeTab}
          onTabChange={setActiveTab}
          onLockVault={onLockVault}
          isMobile={true}
        />
      )}
    </div>
  );
}

export default MobileLayout;
