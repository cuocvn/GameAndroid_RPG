import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/equipment.dart';

class SlideFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.25, 0.0), // Slide từ phải
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }
}

class AppTheme {
  // --- Core Dark Fantasy Palette ---
  static const Color bgDark = Color(0xFF0D0B14); // Ultra-dark purple black
  static const Color bgSurface = Color(0xFF161224); // Surface base
  static const Color bgSurfaceGradientStart = Color(0xFF1A1626);
  static const Color bgSurfaceGradientEnd = Color(0xFF252036);
  static const Color bgCard = Color(0xFF1D182B);

  // --- Primary Accents ---
  static const Color goldAccent = Color(0xFFFFB547); // Main CTA, highlight, boss
  static const Color goldAccentDark = Color(0xFFFF8A00);
  static const Color redAccent = Color(0xFFE85D5D); // HP, ATK, Danger, Boss
  static const Color blueAccent = Color(0xFF5DA9E8); // Mana, DEF, Magic
  static const Color greenAccent = Color(0xFF7FE85D); // Heal, Success, Buff
  static const Color purpleAccent = Color(0xFFA85DE8); // Skill, Void, Mystery
  static const Color cyanAccent = Color(0xFF4AE8D8); // Shield, Ice

  // --- Rarity Palette ---
  static const Color rarityCommon = Color(0xFF8E8A9F); // Silver Grey
  static const Color rarityUncommon = Color(0xFF4AE88A); // Emerald
  static const Color rarityRare = Color(0xFF4ABCE8); // Cyan Sapphire
  static const Color rarityEpic = Color(0xFFB04AE8); // Magic Amethyst
  static const Color rarityLegendary = Color(0xFFFFB547); // Royal Gold

  static Color getRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.common:
        return rarityCommon;
      case EquipmentRarity.uncommon:
        return rarityUncommon;
      case EquipmentRarity.rare:
        return rarityRare;
      case EquipmentRarity.epic:
        return rarityEpic;
      case EquipmentRarity.legendary:
        return rarityLegendary;
    }
  }

  // --- Common Gradients ---
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgSurfaceGradientStart, bgSurfaceGradientEnd],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldAccent, goldAccentDark],
  );

  static const LinearGradient battleHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xDD0D0B14), Color(0x660D0B14), Colors.transparent],
  );

  // --- Borders ---
  static Border cardBorder({Color? color, double width = 1.0}) {
    return Border.all(
      color: color ?? Colors.white.withOpacity(0.08),
      width: width,
    );
  }

  static Border rarityBorder(EquipmentRarity rarity, {double width = 1.5}) {
    return Border.all(
      color: getRarityColor(rarity).withOpacity(0.7),
      width: width,
    );
  }

  // --- Box Shadows ---
  static List<BoxShadow> cardShadow({Color? glowColor, double blur = 8.0}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: blur,
        offset: const Offset(0, 4),
      ),
      if (glowColor != null)
        BoxShadow(
          color: glowColor.withOpacity(0.25),
          blurRadius: blur * 1.5,
          spreadRadius: 1,
        ),
    ];
  }

  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: goldAccent.withOpacity(0.35),
      blurRadius: 16,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];

  // --- Text Styles (GoogleFonts) ---
  static TextStyle titleFantasy({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
    double letterSpacing = 0.5,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white70,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle numberFantasy({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w900,
    Color color = Colors.white,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // --- Theme Data ---
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: goldAccent,
      canvasColor: bgSurface,
      cardColor: bgCard,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: blueAccent,
        surface: bgSurface,
        background: bgDark,
        error: redAccent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SlideFadePageTransitionsBuilder(),
          TargetPlatform.iOS: SlideFadePageTransitionsBuilder(),
          TargetPlatform.windows: SlideFadePageTransitionsBuilder(),
          TargetPlatform.linux: SlideFadePageTransitionsBuilder(),
          TargetPlatform.macOS: SlideFadePageTransitionsBuilder(),
        },
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleFantasy(fontSize: 18, color: goldAccent),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          elevation: 4,
        ),
      ),
    );
  }

  // --- Smooth Modal Dialog Transition (Scale 0.9 -> 1.0 + Fade in 0.2s) ---
  static Future<T?> showScaleDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => builder(ctx),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOut);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }
}
