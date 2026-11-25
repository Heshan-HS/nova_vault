# 🛡️ NovaVault — Pure Flutter (Desktop & Mobile)

Cross-platform, agency-grade, zero-knowledge password manager built natively with **Flutter & Dart**.

Runs on:
- 🖥️ **Windows Native C++ Desktop** (`.exe`)
- 📱 **Android Mobile** (`.apk` / `.aab`)
- 🍏 **iOS Mobile**
- 🌐 **Web**

---

## 🎨 Design Tokens & Spec Fidelity
- **Navy 900:** `Color(0xFF051026)` (`rgb(5, 16, 38)`)
- **Royal 700:** `Color(0xFF0B3C8F)` (`rgb(11, 60, 143)`)
- **Mid Blue:** `Color(0xFF2F6FE0)`
- **Accent Blue (Dark):** `Color(0xFF8DB8FF)` | **Rings:** `Color(0xFF6FA8FF)`
- **Brand Gradient:** `LinearGradient(colors: [Color(0xFF0B3C8F), Color(0xFF2F6FE0)])`
- **Hero Gradient:** `LinearGradient(colors: [Color(0xFF051026), Color(0xFF0B3C8F)])`
- **Sidebar Gradient (Always Dark Navy):** `LinearGradient(colors: [Color(0xFF051026), Color(0xFF081E4E)])`
- **Semantic:** Success Green `Color(0xFF2FB67C)` / on hero `Color(0xFF7FE0B0)`, Star/Favourite `Color(0xFFF5C451)`.

---

## 🚀 How to Run

### 1. Web Preview (Already running live)
```bash
http://localhost:8080
```

### 2. Windows Native Desktop App (`.exe`)
To launch the native Windows desktop application:
```bash
cd novavault_flutter
flutter run -d windows
```

To build a standalone production release `.exe`:
```bash
flutter build windows --release
```
The output `.exe` will be located in:
`build\windows\x64\runner\Release\novavault_flutter.exe`

### 3. Android Mobile App (`.apk`)
To run on a connected Android phone or emulator:
```bash
flutter run -d android
```

To build a release APK for your phone:
```bash
flutter build apk --release
```
The installable `.apk` file will be generated at:
`build\app\outputs\flutter-apk\app-release.apk`

---

## 📂 Project Architecture

```
novavault_flutter/
├── lib/
│   ├── main.dart                      # Master entrypoint with responsive breakpoint & preview controller
│   ├── tokens/
│   │   └── tokens.dart                # Design tokens, gradients, theme definitions
│   ├── models/
│   │   └── vault_item.dart            # Data structures & mock vault dataset
│   ├── widgets/
│   │   ├── logo_tile.dart             # 38x38 glowing logo tile with CustomPainter shield keyhole
│   │   ├── item_avatar.dart           # Brand gradient letter avatars
│   │   ├── totp_ring.dart             # CustomPainter animated 30s countdown ring + TOTP digits
│   │   ├── vault_health_ring.dart     # CustomPainter score 82 health ring
│   │   ├── strength_bar.dart          # Password strength progress bar
│   │   ├── field_row.dart             # Field row with copy, reveal, external link
│   │   └── primary_button.dart        # Brand gradient CTA button
│   └── screens/
│       ├── desktop/
│       │   ├── desktop_sidebar.dart   # 264px persistent dark navy sidebar
│       │   ├── desktop_list_pane.dart # 372px list pane with chips & search
│       │   ├── desktop_detail_pane.dart# Hero card, credentials, authenticator, security & history
│       │   └── desktop_layout.dart    # 3-pane responsive desktop shell
│       ├── mobile/
│       │   ├── mobile_vault_list.dart # Mobile list, hero health card, search, FAB, chips
│       │   ├── mobile_item_detail.dart# Curved gradient header (0 0 30px 30px) & fields
│       │   └── mobile_layout.dart     # Mobile shell with floating pill tab bar
│       ├── generator_screen.dart      # Password & passphrase generator
│       ├── security_screen.dart       # Security centre with audit lists & fix actions
│       ├── settings_screen.dart       # Appearance, auto-lock timeout, biometrics, sync
│       ├── unlock_screen.dart         # Master password entry, shake animation, biometrics
│       └── add_item_dialog.dart       # Modal to create new vault entries
```
