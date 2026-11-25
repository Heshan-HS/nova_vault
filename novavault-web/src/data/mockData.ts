export const MOCK_ITEMS = [
  { id: '1', name: 'GitHub', category: 'login', username: 'dev@example.com', password: '••••••••••••', url: 'github.com', tags: ['Work'], favourite: true, folder: 'Work', strength: 88, hasTotp: true, updatedAt: 'today', createdAt: '14 Mar 2026' },
  { id: '2', name: 'DigitalOcean', category: 'login', username: 'admin@example.com', password: '••••••••••••', url: 'digitalocean.com', tags: ['Server'], favourite: false, folder: 'Servers', strength: 92, hasTotp: false, updatedAt: '2 days ago', createdAt: '10 Jan 2026' },
  { id: '3', name: 'Gmail', category: 'login', username: 'family@example.com', password: '••••••••••••', url: 'gmail.com', tags: ['Personal'], favourite: false, folder: 'Personal', strength: 71, hasTotp: true, updatedAt: '1 week ago', createdAt: '5 Feb 2026' },
  { id: '4', name: 'Netflix', category: 'login', username: 'family@example.com', password: '••••••••••••', url: 'netflix.com', tags: ['Personal'], favourite: false, folder: 'Personal', strength: 55, hasTotp: false, updatedAt: '2 weeks ago', createdAt: '20 Nov 2025' },
  { id: '5', name: 'Bank Card', category: 'card', username: 'Visa ···· 4417', password: '', url: '', tags: ['Finance'], favourite: false, folder: 'Personal', strength: 0, hasTotp: false, updatedAt: '1 month ago', createdAt: '1 Oct 2025' },
  { id: '6', name: 'V2Ray Panel', category: 'login', username: 'root@vp-xp', password: '••••••••••••', url: '', tags: ['Server'], favourite: false, folder: 'Servers', strength: 81, hasTotp: false, updatedAt: '3 days ago', createdAt: '15 Mar 2026' },
  { id: '7', name: 'Spotify', category: 'login', username: 'me@example.com', password: '••••••••••••', url: 'spotify.com', tags: ['Personal'], favourite: false, folder: 'Personal', strength: 63, hasTotp: false, updatedAt: '5 days ago', createdAt: '1 Jan 2026' },
];

export const VAULT_STATS = { total: 128, favourites: 12, logins: 86, cards: 7, notes: 19, identities: 4 };
export const FOLDERS = [{ name: 'Work', count: 34 }, { name: 'Personal', count: 41 }, { name: 'Servers', count: 22 }];
export const HEALTH_SCORE = 82;
export const MOCK_TOTP = { code: '482 913', secondsLeft: 18, period: 30 };
