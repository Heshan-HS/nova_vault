import { create } from 'zustand';
import { encrypt, decrypt, hashMasterPassword, generatePassword } from '../lib/crypto';

export type ItemCategory = 'login' | 'email' | 'card' | 'note' | 'identity';

export interface VaultItem {
  id: string;
  name: string;
  category: ItemCategory;
  username?: string;
  email?: string;
  password?: string;        // stored encrypted
  url?: string;
  notes?: string;           // stored encrypted
  totpSecret?: string;      // stored encrypted
  cardNumber?: string;      // stored encrypted
  cardExpiry?: string;
  cardCVV?: string;         // stored encrypted
  createdAt: number;
  updatedAt: number;
  favourite: boolean;
  tags: string[];
  strength?: number;
}

export interface VaultItemDecrypted extends Omit<VaultItem, 'password' | 'notes' | 'totpSecret' | 'cardNumber' | 'cardCVV'> {
  password?: string;
  notes?: string;
  totpSecret?: string;
  cardNumber?: string;
  cardCVV?: string;
}

type Theme = 'dark' | 'light';

interface VaultState {
  // Auth
  isUnlocked: boolean;
  masterPasswordHash: string | null;
  masterSalt: string | null;

  // Items — stored encrypted in localStorage
  items: VaultItem[];

  // UI State
  theme: Theme;
  searchQuery: string;
  selectedCategory: ItemCategory | 'all' | 'favourites';
  selectedItemId: string | null;
  view: 'vault' | 'generator' | 'settings';

  // Actions
  unlock: (masterPassword: string) => Promise<boolean>;
  lock: () => void;
  setupMaster: (masterPassword: string) => Promise<void>;
  isSetupComplete: () => boolean;

  addItem: (item: Omit<VaultItem, 'id' | 'createdAt' | 'updatedAt'>, masterPassword: string) => Promise<void>;
  updateItem: (id: string, updates: Partial<VaultItem>, masterPassword: string) => Promise<void>;
  deleteItem: (id: string) => void;
  decryptItem: (item: VaultItem, masterPassword: string) => Promise<VaultItemDecrypted>;

  setTheme: (theme: Theme) => void;
  setSearchQuery: (q: string) => void;
  setSelectedCategory: (cat: VaultState['selectedCategory']) => void;
  setSelectedItemId: (id: string | null) => void;
  setView: (view: VaultState['view']) => void;

  // Computed
  filteredItems: () => VaultItem[];
  stats: () => { total: number; logins: number; weak: number; reused: number };
}

const STORAGE_KEY = 'novavault_v1';

function loadFromStorage(): { items: VaultItem[]; hash: string | null; salt: string | null } {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { items: [], hash: null, salt: null };
    return JSON.parse(raw);
  } catch {
    return { items: [], hash: null, salt: null };
  }
}

function saveToStorage(items: VaultItem[], hash: string | null, salt: string | null) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify({ items, hash, salt }));
}

// Keep master password in memory session only (never persisted)
let _sessionMasterPassword: string | null = null;

export function getSessionMasterPassword() { return _sessionMasterPassword; }

export const useVaultStore = create<VaultState>((set, get) => {
  const stored = loadFromStorage();

  return {
    isUnlocked: false,
    masterPasswordHash: stored.hash,
    masterSalt: stored.salt,
    items: stored.items,
    theme: (localStorage.getItem('nova_theme') as Theme) ?? 'dark',
    searchQuery: '',
    selectedCategory: 'all',
    selectedItemId: null,
    view: 'vault',

    isSetupComplete: () => !!get().masterPasswordHash,

    setupMaster: async (masterPassword) => {
      const salt = btoa(String.fromCharCode(...crypto.getRandomValues(new Uint8Array(16))));
      const hash = await hashMasterPassword(masterPassword, salt);
      _sessionMasterPassword = masterPassword;
      saveToStorage(get().items, hash, salt);
      set({ masterPasswordHash: hash, masterSalt: salt, isUnlocked: true });
    },

    unlock: async (masterPassword) => {
      const { masterPasswordHash, masterSalt } = get();
      if (!masterPasswordHash || !masterSalt) return false;
      const hash = await hashMasterPassword(masterPassword, masterSalt);
      if (hash !== masterPasswordHash) return false;
      _sessionMasterPassword = masterPassword;
      set({ isUnlocked: true });
      return true;
    },

    lock: () => {
      _sessionMasterPassword = null;
      set({ isUnlocked: false, selectedItemId: null });
    },

    addItem: async (itemData, masterPassword) => {
      const encPwd  = itemData.password  ? await encrypt(itemData.password, masterPassword)  : undefined;
      const encNote = itemData.notes     ? await encrypt(itemData.notes, masterPassword)     : undefined;
      const encTotp = itemData.totpSecret ? await encrypt(itemData.totpSecret, masterPassword) : undefined;
      const encCard = itemData.cardNumber ? await encrypt(itemData.cardNumber, masterPassword)  : undefined;
      const encCVV  = itemData.cardCVV    ? await encrypt(itemData.cardCVV, masterPassword)    : undefined;

      const newItem: VaultItem = {
        ...itemData,
        id: crypto.randomUUID(),
        password: encPwd,
        notes: encNote,
        totpSecret: encTotp,
        cardNumber: encCard,
        cardCVV: encCVV,
        createdAt: Date.now(),
        updatedAt: Date.now(),
      };

      const items = [...get().items, newItem];
      saveToStorage(items, get().masterPasswordHash, get().masterSalt);
      set({ items });
    },

    updateItem: async (id, updates, masterPassword) => {
      const encPwd  = updates.password  ? await encrypt(updates.password, masterPassword)  : updates.password;
      const encNote = updates.notes     ? await encrypt(updates.notes, masterPassword)     : updates.notes;

      const items = get().items.map(it =>
        it.id === id ? { ...it, ...updates, password: encPwd, notes: encNote, updatedAt: Date.now() } : it
      );
      saveToStorage(items, get().masterPasswordHash, get().masterSalt);
      set({ items });
    },

    deleteItem: (id) => {
      const items = get().items.filter(it => it.id !== id);
      saveToStorage(items, get().masterPasswordHash, get().masterSalt);
      set({ items, selectedItemId: get().selectedItemId === id ? null : get().selectedItemId });
    },

    decryptItem: async (item, masterPassword) => {
      const pwd  = item.password  ? await decrypt(item.password, masterPassword)  : undefined;
      const note = item.notes     ? await decrypt(item.notes, masterPassword)     : undefined;
      const totp = item.totpSecret ? await decrypt(item.totpSecret, masterPassword) : undefined;
      const card = item.cardNumber ? await decrypt(item.cardNumber, masterPassword)  : undefined;
      const cvv  = item.cardCVV    ? await decrypt(item.cardCVV, masterPassword)    : undefined;
      return { ...item, password: pwd, notes: note, totpSecret: totp, cardNumber: card, cardCVV: cvv };
    },

    setTheme: (theme) => {
      localStorage.setItem('nova_theme', theme);
      set({ theme });
    },
    setSearchQuery: (searchQuery) => set({ searchQuery }),
    setSelectedCategory: (selectedCategory) => set({ selectedCategory, selectedItemId: null }),
    setSelectedItemId: (selectedItemId) => set({ selectedItemId }),
    setView: (view) => set({ view }),

    filteredItems: () => {
      const { items, searchQuery, selectedCategory } = get();
      let filtered = items;
      if (selectedCategory === 'favourites') {
        filtered = filtered.filter(i => i.favourite);
      } else if (selectedCategory !== 'all') {
        filtered = filtered.filter(i => i.category === selectedCategory);
      }
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        filtered = filtered.filter(i =>
          i.name.toLowerCase().includes(q) ||
          (i.username?.toLowerCase().includes(q)) ||
          (i.email?.toLowerCase().includes(q)) ||
          (i.url?.toLowerCase().includes(q))
        );
      }
      return filtered.sort((a, b) => b.updatedAt - a.updatedAt);
    },

    stats: () => {
      const { items } = get();
      return {
        total: items.length,
        logins: items.filter(i => i.category === 'login').length,
        weak: items.filter(i => (i.strength ?? 5) < 3).length,
        reused: 0,
      };
    },
  };
});
