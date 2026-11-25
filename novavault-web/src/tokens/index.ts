export const tokens = {
  // Brand colours
  navy900: 'rgb(5, 16, 38)',
  royal700: 'rgb(11, 60, 143)',
  midBlue: '#2f6fe0',
  accentBlueDark: '#8db8ff',
  accentBlueRing: '#6fa8ff',

  // Gradients
  brandGradient: 'linear-gradient(135deg, rgb(11,60,143), #2f6fe0)',
  heroGradient: 'linear-gradient(135deg, rgb(5,16,38), rgb(11,60,143))',
  heroHighlight: 'radial-gradient(500px 200px at 90% 0%, rgba(111,168,255,.4), transparent 70%)',
  sidebarGradient: 'linear-gradient(180deg, rgb(5,16,38), rgb(8,30,78))',
  bgDark: 'radial-gradient(900px 500px at 85% -10%, rgba(47,111,224,.35), transparent 60%), linear-gradient(160deg, rgb(5,16,38), rgb(7,24,62) 60%, rgb(9,40,100))',
  bgLight: 'radial-gradient(900px 500px at 85% -10%, rgba(47,111,224,.14), transparent 60%), linear-gradient(160deg, #f7faff, #e8f0fc)',

  // Semantic
  successGreen: '#2fb67c',
  successGreenDark: '#7fe0b0',
  starColor: '#f5c451',

  // Spacing scale
  spacing: { 4: '4px', 6: '6px', 8: '8px', 10: '10px', 12: '12px', 14: '14px', 16: '16px', 18: '18px', 20: '20px', 24: '24px', 36: '36px' },

  // Radii
  radii: { card: '18px', hero: '22px', listRow: '14px', listRowMobile: '16px', input: '14px', inputMobile: '16px', button: '12px', iconButton: '12px', avatar: '12px', avatarHero: '18px', chip: '20px', tabBar: '20px', fab: '20px' },
} as const;
