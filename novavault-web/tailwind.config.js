/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        nova: {
          950: 'rgb(5, 16, 38)',
          900: 'rgb(8, 25, 55)',
          800: 'rgb(11, 60, 143)',
          700: 'rgb(18, 85, 190)',
          600: 'rgb(37, 99, 235)',
          500: 'rgb(59, 130, 246)',
          400: 'rgb(96, 165, 250)',
          300: 'rgb(147, 197, 253)',
        },
      },
      backgroundImage: {
        'nova-gradient': 'linear-gradient(135deg, rgb(5,16,38) 0%, rgb(11,60,143) 100%)',
        'nova-gradient-v': 'linear-gradient(180deg, rgb(5,16,38) 0%, rgb(11,60,143) 100%)',
      },
    },
  },
  plugins: [],
}
