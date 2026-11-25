import React, {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
} from 'react';

export type ThemeOption = 'dark' | 'light' | 'system';
export type ResolvedTheme = 'dark' | 'light';

const STORAGE_KEY = 'novavault_theme';

const darkVars: Record<string, string> = {
  '--bg': 'radial-gradient(900px 500px at 85% -10%, rgba(47,111,224,.35), transparent 60%), linear-gradient(160deg, rgb(5,16,38), rgb(7,24,62) 60%, rgb(9,40,100))',
  '--text': '#ffffff',
  '--muted': 'rgba(255,255,255,.64)',
  '--card': 'rgba(255,255,255,.055)',
  '--card-border': 'rgba(255,255,255,.10)',
  '--list-tint': 'rgba(255,255,255,.025)',
  '--selected-bg': 'rgba(111,168,255,.14)',
  '--selected-border': 'rgba(140,185,255,.40)',
  '--input-bg': 'rgba(255,255,255,.06)',
  '--input-border': 'rgba(255,255,255,.12)',
  '--ring-track': 'rgba(255,255,255,.12)',
  '--ring-fill': '#6fa8ff',
  '--accent': '#8db8ff',
  '--shadow': '0 20px 50px rgba(0,0,0,.35)',
};

const lightVars: Record<string, string> = {
  '--bg': 'radial-gradient(900px 500px at 85% -10%, rgba(47,111,224,.14), transparent 60%), linear-gradient(160deg, #f7faff, #e8f0fc)',
  '--text': 'rgb(5,16,38)',
  '--muted': '#4a5878',
  '--card': '#ffffff',
  '--card-border': '#dbe4f3',
  '--list-tint': 'rgba(255,255,255,.55)',
  '--selected-bg': '#e3edfc',
  '--selected-border': '#a9c4f0',
  '--input-bg': '#ffffff',
  '--input-border': '#cfdaee',
  '--ring-track': '#e0e8f6',
  '--ring-fill': 'rgb(11,60,143)',
  '--accent': 'rgb(11,60,143)',
  '--shadow': '0 14px 40px rgba(11,60,143,.12)',
};

function applyVars(vars: Record<string, string>) {
  const root = document.documentElement;
  Object.entries(vars).forEach(([k, v]) => root.style.setProperty(k, v));
}

function getSystemTheme(): ResolvedTheme {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

interface ThemeContextValue {
  theme: ThemeOption;
  setTheme: (t: ThemeOption) => void;
  resolvedTheme: ResolvedTheme;
}

const ThemeContext = createContext<ThemeContextValue>({
  theme: 'system',
  setTheme: () => {},
  resolvedTheme: 'dark',
});

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setThemeState] = useState<ThemeOption>(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored === 'dark' || stored === 'light' || stored === 'system') return stored;
    } catch {}
    return 'system';
  });

  const [resolvedTheme, setResolvedTheme] = useState<ResolvedTheme>(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored === 'dark') return 'dark';
      if (stored === 'light') return 'light';
    } catch {}
    return getSystemTheme();
  });

  const applyTheme = useCallback((resolved: ResolvedTheme) => {
    const html = document.documentElement;
    html.classList.remove('dark', 'light');
    html.classList.add(resolved);
    applyVars(resolved === 'dark' ? darkVars : lightVars);
    setResolvedTheme(resolved);
  }, []);

  useEffect(() => {
    if (theme === 'system') {
      const resolved = getSystemTheme();
      applyTheme(resolved);

      const mq = window.matchMedia('(prefers-color-scheme: dark)');
      const handler = (e: MediaQueryListEvent) => applyTheme(e.matches ? 'dark' : 'light');
      mq.addEventListener('change', handler);
      return () => mq.removeEventListener('change', handler);
    } else {
      applyTheme(theme);
    }
  }, [theme, applyTheme]);

  const setTheme = useCallback((t: ThemeOption) => {
    try {
      localStorage.setItem(STORAGE_KEY, t);
    } catch {}
    setThemeState(t);
  }, []);

  return (
    <ThemeContext.Provider value={{ theme, setTheme, resolvedTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme(): ThemeContextValue {
  return useContext(ThemeContext);
}
