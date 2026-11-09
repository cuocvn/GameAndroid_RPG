import 'package:flutter/material.dart';

/// AssetMapping manages all local asset paths in the game,
/// providing typed constants, category groupings, and safe fallback widgets.
class AssetMapping {
  // --- Hero / Character Sprites & Portraits ---
  static const String heroMainPortrait = 'assets/img/characters/013_Cyra_MID.jpg'; // Cyra - Hỏa Thuật Sư
  static const String heroBattleSprite = 'assets/img/equipment/mid1-removebg-preview.png'; // In-battle transparent sprite
  static const String heroWalkSprite = 'assets/img/equipment/mid1-walk.png'; // Walking pose

  // Selectable / Alternate Hero Portraits
  static const Map<String, String> characterPortraits = {
    'cyra': 'assets/img/characters/013_Cyra_MID.jpg',
    'inari': 'assets/img/characters/001_Inari_MID.jpg',
    'violetta': 'assets/img/characters/002_Violetta_JUNG.webp',
    'valeria': 'assets/img/characters/003_Valeria_JUNG.webp',
    'kaelen': 'assets/img/characters/004_Kaelen_TOP.jpg',
    'carmilla': 'assets/img/characters/005_Carmilla_JUNG.jpg',
    'elysia': 'assets/img/characters/006_Elysia_SP.jpg',
    'sylvia': 'assets/img/characters/007_Sylvia_AD.webp',
    'selene': 'assets/img/characters/008_Selene_SP.webp',
    'aurora': 'assets/img/characters/009_Aurora_TOP.jpg',
    'lucia': 'assets/img/characters/010_Lucia_JUNG.webp',
    'marina': 'assets/img/characters/011_Marina_SP.jpg',
    'seraphina': 'assets/img/characters/012_Seraphina_JUNG.jpg',
    'giselle': 'assets/img/characters/014_Giselle_AD.jpg',
    'freya': 'assets/img/characters/015_Freya_TOP.jpg',
    'mai': 'assets/img/characters/016_Mai_TOP.jpg',
  };

  // --- Equipment Assets ---
  static const String itemRingSacred = 'assets/img/sacred_soul_ring.png';
  static const String itemArmorRobe = 'assets/img/equipment/ao1.jpg';
  static const String itemBootsSpeed = 'assets/img/equipment/giay1.jpg';
  static const String itemHelmCrown = 'assets/img/equipment/non1.jpg';
  static const String itemPantsGuard = 'assets/img/equipment/quan1.jpg';
  static const String itemAmuletRune = 'assets/img/equipment/trangsuc1.jpg';
  static const String itemBangleMagic = 'assets/img/equipment/vongtay1.jpg';

  // --- Zone Monsters & Bosses ---
  static const String monsterZone1 = 'assets/img/monsters/monster1.jpg'; // Forest beast / Goblin
  static const String monsterZone2 = 'assets/img/monsters/monster2.jpg'; // Molten Fiend
  static const String monsterZone3 = 'assets/img/monsters/monster3.jpg'; // Frost Titan
  static const String monsterZone4 = 'assets/img/monsters/monster4.jpg'; // Abyssal Reaper
  static const String monsterZone5 = 'assets/img/monsters/monster5.jpg'; // Chaos Overlord (Boss)

  // --- Background Splash Screens ---
  static const String bgBattleDefault = 'assets/img/characters/009_Aurora_TOP.jpg';
  static const String bgHomeDefault = 'assets/img/characters/010_Lucia_JUNG.webp';
  static const String bgMapDefault = 'assets/img/characters/top2.jpg';

  /// Safe Image builder with fallback emoji/icon to prevent crashes if an asset is missing
  static Widget safeImage(
    String? path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String fallbackEmoji = '⚔️',
    BorderRadius? borderRadius,
  }) {
    Widget fallbackWidget = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Text(
        fallbackEmoji,
        style: TextStyle(fontSize: (width != null && width < 40) ? 16 : 24),
      ),
    );

    if (path == null || path.isEmpty) {
      return fallbackWidget;
    }

    Widget imgWidget = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to secondary path variant if needed
        if (path.startsWith('assets/')) {
          final altPath = path.replaceFirst('assets/', 'asset/');
          return Image.asset(
            altPath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => fallbackWidget,
          );
        }
        return fallbackWidget;
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imgWidget,
      );
    }
    return imgWidget;
  }
}
