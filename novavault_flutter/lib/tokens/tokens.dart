import 'package:flutter/material.dart';

class NovaTokens {
  // Brand Colours - Unified strictly to Sidebar Navy & Royal Blue
  static const Color navy900 = Color(0xFF051026); // rgb(5, 16, 38)
  static const Color royal700 = Color(0xFF0B3C8F); // rgb(11, 60, 143)
  static const Color midBlue = Color(0xFF0B3C8F); // Unified to sidebar royal blue
  static const Color accentBlueDark = Color(0xFF6FA8FF);
  static const Color accentBlueRing = Color(0xFF0B3C8F);

  // Semantic (Disciplined Single-Accent Brand Blue, no rainbow)
  static const Color successGreen = Color(0xFF0B3C8F);
  static const Color successGreenHero = Color(0xFF6FA8FF);
  static const Color starYellow = Color(0xFF0B3C8F);
  static const Color dangerRed = Color(0xFF0B3C8F);

  // Gradients (Unified to sidebar royal blue)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royal700, Color(0xFF0E3E8C)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy900, royal700],
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy900, Color(0xFF081E4E)],
  );

  // Dark Theme Tokens
  static const Color darkBgStart = Color(0xFF051026);
  static const Color darkBgMid = Color(0xFF07183E);
  static const Color darkBgEnd = Color(0xFF092864);
  static const Color darkCard = Color(0x0EFFFFFF); // rgba(255,255,255, 0.055)
  static const Color darkCardBorder = Color(0x1AFFFFFF); // rgba(255,255,255, 0.10)
  static const Color darkListTint = Color(0x06FFFFFF); // rgba(255,255,255, 0.025)
  static const Color darkSelectedBg = Color(0x246FA8FF); // rgba(111,168,255, 0.14)
  static const Color darkSelectedBorder = Color(0x668CB9FF); // rgba(140,185,255, 0.40)
  static const Color darkInputBg = Color(0x0FFFFFFF); // rgba(255,255,255, 0.06)
  static const Color darkInputBorder = Color(0x1FFFFFFF); // rgba(255,255,255, 0.12)
  static const Color darkRingTrack = Color(0x1FFFFFFF);
  static const Color darkText = Colors.white;
  static const Color darkMuted = Color(0xA3FFFFFF); // rgba(255,255,255, 0.64)

  // Light Theme Tokens
  static const Color lightBgStart = Color(0xFFF7FAFF);
  static const Color lightBgEnd = Color(0xFFE8F0FC);
  static const Color lightCard = Colors.white;
  static const Color lightCardBorder = Color(0xFFDBE4F3);
  static const Color lightListTint = Color(0x8CFFFFFF); // rgba(255,255,255, 0.55)
  static const Color lightSelectedBg = Color(0xFFE3EDFC);
  static const Color lightSelectedBorder = Color(0xFFA9C4F0);
  static const Color lightInputBg = Colors.white;
  static const Color lightInputBorder = Color(0xFFCFDAEE);
  static const Color lightRingTrack = Color(0xFFE0E8F6);
  static const Color lightText = Color(0xFF051026);
  static const Color lightMuted = Color(0xFF4A5878);

  // Radii
  static const double radiusCard = 18.0;
  static const double radiusHero = 22.0;
  static const double radiusListRow = 14.0;
  static const double radiusListRowMobile = 16.0;
  static const double radiusInput = 14.0;
  static const double radiusInputMobile = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusAvatar = 12.0;
  static const double radiusAvatarHero = 18.0;
  static const double radiusChip = 20.0;
  static const double radiusTabBar = 20.0;
  static const double radiusFab = 20.0;
}

class NovaTheme {
  final bool isDark;

  NovaTheme({required this.isDark});

  Color get text => isDark ? NovaTokens.darkText : NovaTokens.lightText;
  Color get muted => isDark ? NovaTokens.darkMuted : NovaTokens.lightMuted;
  Color get card => isDark ? NovaTokens.darkCard : NovaTokens.lightCard;
  Color get cardBorder => isDark ? NovaTokens.darkCardBorder : NovaTokens.lightCardBorder;
  Color get listTint => isDark ? NovaTokens.darkListTint : NovaTokens.lightListTint;
  Color get selectedBg => isDark ? NovaTokens.darkSelectedBg : NovaTokens.lightSelectedBg;
  Color get selectedBorder => isDark ? NovaTokens.darkSelectedBorder : NovaTokens.lightSelectedBorder;
  Color get inputBg => isDark ? NovaTokens.darkInputBg : NovaTokens.lightInputBg;
  Color get inputBorder => isDark ? NovaTokens.darkInputBorder : NovaTokens.lightInputBorder;
  Color get ringTrack => isDark ? NovaTokens.darkRingTrack : NovaTokens.lightRingTrack;
  Color get ringFill => isDark ? NovaTokens.accentBlueRing : NovaTokens.royal700;
  Color get accent => isDark ? NovaTokens.accentBlueDark : NovaTokens.royal700;

  Gradient get backgroundGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NovaTokens.darkBgStart, NovaTokens.darkBgMid, NovaTokens.darkBgEnd],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NovaTokens.lightBgStart, NovaTokens.lightBgEnd],
        );
}
