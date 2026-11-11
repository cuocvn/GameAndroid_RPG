import 'dart:math';
import '../data/asset_mapping.dart';
import '../data/seed_skills.dart';
import 'enemy.dart';
import 'equipment.dart';
import 'player.dart';
import 'skill.dart';

class ArenaOpponent {
  final String id;
  final String name;
  final String avatarAsset;
  final int level;
  final int totalPower;
  final int hp;
  final int mana;
  final int atk;
  final double def;
  final double agi;
  final double critRate;
  final double dodgeRate;
  final List<String> skillIds;
  final EquipmentRarity gearRarity;
  final String buildTheme;

  const ArenaOpponent({
    required this.id,
    required this.name,
    required this.avatarAsset,
    required this.level,
    required this.totalPower,
    required this.hp,
    this.mana = 100,
    required this.atk,
    required this.def,
    required this.agi,
    required this.critRate,
    required this.dodgeRate,
    required this.skillIds,
    required this.gearRarity,
    required this.buildTheme,
  });

  static const List<String> opponentNames = [
    'Hắc Long Tử',
    'Huyết Ảnh',
    'Băng Nữ',
    'Lôi Thần Quân',
    'Kiếm Thánh Tiêu Dao',
    'Dạ Xoa Vương',
    'Ma Đế Trọng Lâu',
    'Thiên Tôn Diệp Phàm',
    'Thần Thương Triệu Vân',
    'Cửu Vĩ Linh Hồ',
    'Bạch Y Kiếm Khách',
    'Viêm Đế Tiêu Viêm',
    'Cuồng Đao Bá Thiên',
    'Huyễn Kiếm Khách',
    'U Hồn Lãnh Chúa',
    'Vô Thượng Ma Tôn',
    'Bất Diệt Kiếm Tông',
    'Thánh Kiếm Sĩ',
  ];

  static const List<String> themes = [
    'Chiến Binh Cuồng Nộ',
    'Pháp Sư Băng Hỏa',
    'Sát Thủ Vô Ảnh',
    'Hộ Vệ Hoàng Gia',
    'Lôi Đình Kiếm Khách',
  ];

  /// Generates a balanced simulated AI opponent based on the player's level and combat power
  static ArenaOpponent generate({required Player player, Random? rng}) {
    final rand = rng ?? Random();
    final name = opponentNames[rand.nextInt(opponentNames.length)];
    final portraits = AssetMapping.characterPortraits.values.toList();
    final avatar = portraits[rand.nextInt(portraits.length)];
    final theme = themes[rand.nextInt(themes.length)];

    // Level matchmaking bracket
    double minMult;
    double maxMult;
    if (player.level >= 26) {
      minMult = 1.10;
      maxMult = 1.40;
    } else if (player.level >= 16) {
      minMult = 1.00;
      maxMult = 1.20;
    } else if (player.level >= 10) {
      minMult = 0.90;
      maxMult = 1.10;
    } else {
      minMult = 0.85;
      maxMult = 1.05;
    }

    final mult = minMult + rand.nextDouble() * (maxMult - minMult);
    final opponentLevel = max(1, (player.level * (0.95 + rand.nextDouble() * 0.15)).round());

    // Determine gear rarity matching bracket
    EquipmentRarity rarity;
    if (opponentLevel >= 26) {
      rarity = EquipmentRarity.legendary;
    } else if (opponentLevel >= 16) {
      rarity = EquipmentRarity.epic;
    } else if (opponentLevel >= 10) {
      rarity = EquipmentRarity.rare;
    } else if (opponentLevel >= 5) {
      rarity = EquipmentRarity.uncommon;
    } else {
      rarity = EquipmentRarity.common;
    }

    // Pick 3 to 5 active skills
    final activeSkills = SeedSkills.allSkills
        .where((s) => s.type == SkillType.active)
        .map((s) => s.id)
        .toList();
    activeSkills.shuffle(rand);
    final skillCount = (3 + rand.nextInt(3)).clamp(3, 5);
    final chosenSkillIds = activeSkills.take(skillCount).toList();

    // Scale attributes from player's base combat stats with bracket multiplier
    final baseHp = max(100, player.maxHp);
    final baseAtk = max(20.0, max(player.physicalAtk, player.magicAtk));
    final baseDef = max(5.0, player.physicalDef);

    int opponentHp;
    int opponentAtk;
    double opponentDef;
    double opponentAgi;
    double opponentCrit;
    double opponentDodge;

    switch (theme) {
      case 'Chiến Binh Cuồng Nộ':
        opponentHp = (baseHp * mult * 1.15).round();
        opponentAtk = (baseAtk * mult * 1.10).round();
        opponentDef = baseDef * mult * 0.95;
        opponentAgi = 8.0;
        opponentCrit = 0.15;
        opponentDodge = 0.05;
        break;
      case 'Pháp Sư Băng Hỏa':
        opponentHp = (baseHp * mult * 0.90).round();
        opponentAtk = (baseAtk * mult * 1.25).round();
        opponentDef = baseDef * mult * 0.80;
        opponentAgi = 7.0;
        opponentCrit = 0.20;
        opponentDodge = 0.06;
        break;
      case 'Sát Thủ Vô Ảnh':
        opponentHp = (baseHp * mult * 0.85).round();
        opponentAtk = (baseAtk * mult * 1.20).round();
        opponentDef = baseDef * mult * 0.75;
        opponentAgi = 14.0;
        opponentCrit = 0.28;
        opponentDodge = 0.15;
        break;
      case 'Hộ Vệ Hoàng Gia':
        opponentHp = (baseHp * mult * 1.40).round();
        opponentAtk = (baseAtk * mult * 0.85).round();
        opponentDef = baseDef * mult * 1.35;
        opponentAgi = 6.0;
        opponentCrit = 0.08;
        opponentDodge = 0.04;
        break;
      default: // Lôi Đình Kiếm Khách & others
        opponentHp = (baseHp * mult).round();
        opponentAtk = (baseAtk * mult).round();
        opponentDef = baseDef * mult;
        opponentAgi = 10.0;
        opponentCrit = 0.18;
        opponentDodge = 0.08;
    }

    final calculatedPower = (opponentHp ~/ 5) + (opponentAtk * 2) + (opponentDef * 3).round();

    return ArenaOpponent(
      id: 'arena_${DateTime.now().microsecondsSinceEpoch}_${rand.nextInt(9999)}',
      name: name,
      avatarAsset: avatar,
      level: opponentLevel,
      totalPower: calculatedPower,
      hp: opponentHp,
      mana: 100,
      atk: opponentAtk,
      def: opponentDef,
      agi: opponentAgi,
      critRate: opponentCrit,
      dodgeRate: opponentDodge,
      skillIds: chosenSkillIds,
      gearRarity: rarity,
      buildTheme: theme,
    );
  }

  /// Converts this AI hero into an Enemy structure for the battle engine
  Enemy toEnemy() {
    final enemySkills = skillIds.map((sid) {
      final s = SeedSkills.getById(sid);
      return EnemySkill(
        id: s.id,
        name: s.name,
        damageMultiplier: s.baseMultiplier > 0 ? s.baseMultiplier : 1.5,
        cooldown: s.cooldown > 0 ? s.cooldown : 6.0,
        description: s.description,
        icon: s.emoji,
        isMagic: s.element != SkillElement.physical,
        causesHeroBurn: s.causesBurn,
        causesHeroFreeze: s.element == SkillElement.ice,
      );
    }).toList();

    return Enemy(
      id: id,
      name: name,
      zone: 98, // Arena indicator zone
      stage: 1,
      isBoss: false,
      maxHp: hp,
      currentHp: hp,
      atk: atk,
      def: def,
      agi: agi,
      critRate: critRate,
      dodgeRate: dodgeRate,
      expReward: 0,
      goldReward: 200,
      imageAsset: avatarAsset,
      fallbackEmoji: '⚔️',
      bossSkills: enemySkills,
      maxMana: mana,
      currentMana: mana,
    );
  }
}
