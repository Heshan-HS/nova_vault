# 🔐 NovaVault — Ultra-Premium Password Manager

Pixel-faithful implementation of the **NovaVault** personal zero-knowledge password manager UI (Desktop + Mobile) adhering strictly to the design specification and reference aesthetic.

## ✨ Features & Architecture

### 1. Unified Design Tokens
- **Navy 900:** `rgb(5, 16, 38)`
- **Royal 700:** `rgb(11, 60, 143)`
- **Mid Blue:** `#2f6fe0`
- **Accent Blue (Dark):** `#8db8ff` | **Rings:** `#6fa8ff`
- **Brand Gradient:** `linear-gradient(135deg, rgb(11,60,143), #2f6fe0)`
- **Hero Gradient:** `linear-gradient(135deg, rgb(5,16,38), rgb(11,60,143))` + `radial-gradient(500px 200px at 90% 0%, rgba(111,168,255,.4), transparent 70%)`
- **Sidebar Gradient:** `linear-gradient(180deg, rgb(5,16,38), rgb(8,30,78))` (Always dark navy in both Light & Dark modes)

### 2. Live Theme Switching (CSS Variables)
- **Dark Theme:** Deep obsidian navy with soft glowing cards and crisp hairlines.
- **Light Theme:** Agency-grade executive contrast (`#f7faff` to `#e8f0fc`) with dark navy persistent sidebar.
- **System Mode:** Automatically tracks `prefers-color-scheme`.

### 3. Screen Suite
- **Desktop (1440x900 fluid):**
  - **Sidebar (264px):** Always dark navy, logo lockup, item counts, Folders (Work, Personal, Servers), Vault health card (score 82), account sync row.
  - **List Pane (372px):** All items, Search input with `Ctrl K`, filter chips (All, Logins, Cards, Weak), 44px avatars, tag + star indicators.
  - **Detail Pane:** Hero card (64px avatar, tags, timestamps), Credentials card with copy/reveal, Authenticator card with live animated countdown TOTP ring (`482 913`), Security card with strength bar & breach check, Password history timeline.
- **Mobile (390x844 responsive):**
  - Synced header pill + logo tile.
  - Interactive Vault Health card with tap navigation to Security Centre.
  - Floating pill tab bar (Vault, Generator, Security, Settings) with 150ms transitions.
  - Gradient header with `0 0 30px 30px` rounded geometry on item detail.
  - 58px floating action button (FAB).
- **Security Centre:**
  - Complete health telemetry breakdown: Weak, Reused, Exposed breach check, and 2FA availability with "Fix" actions.
- **Password Generator:**
  - Random password & passphrase generator with live strength telemetry, length slider (8–64), and character toggles.
- **Unlock / Login Screen:**
  - Master password with show/hide, biometric prompt (Windows Hello / Touch ID), shake animation on failure, "Remember this device" zero-friction unlock.
- **Add / Edit Item Modal:**
  - Multi-category support (Login, Card, Note, Identity), inline password generator, folder selection, and favourite tagging.

---

## 🚀 Running the App

```bash
cd novavault-web
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.
Use the top device switcher to test:
1. **Desktop (3-Pane)**
2. **Mobile (390px)**
3. **Comparison Mockup** (Desktop + Mobile side-by-side)
