import 'dart:math';
import '../data/asset_mapping.dart';
import 'equipment.dart';
import 'stats.dart';

class Player {
  final String name;
  final String title;
  final String portraitAsset;
  final String battleSpriteAsset;
  final int level;
  final int currentExp;
  final int gold;
  final int statPoints;
  final int skillPoints;
  final Stats stats;

  final Equipment? equippedWeapon;
  final Equipment? equippedArmor;
  final Equipment? equippedAccessory;
  final List<Equipment> inventory;

  // skillId -> current rank (level)
  final Map<String, int> skillLevels;
  // List of active/basic skill IDs set for battle
  final List<String> equippedSkillIds;

  final int maxUnlockedZone;
  final int currentZone;
  final int currentStage;

  const Player({
    this.name = 'Cyra',
    this.title = 'Hỏa Thuật Sư',
    this.portraitAsset = AssetMapping.heroMainPortrait,
    this.battleSpriteAsset = AssetMapping.heroBattleSprite,
    this.level = 1,
    this.currentExp = 0,
    this.gold = 100,
    this.statPoints = 5,
    this.skillPoints = 1,
    this.stats = const Stats(str: 5, int_: 12, vit: 8, agi: 6, luk: 5),
    this.equippedWeapon,
    this.equippedArmor,
    this.equippedAccessory,
    this.inventory = const [],
    this.skillLevels = const {
      'fireball': 1,
      'meteor': 1,
      'fire_heart': 1,
    },
    this.equippedSkillIds = const [
      'fireball',
      'meteor',
    ],
    this.maxUnlockedZone = 1,
    this.currentZone = 1,
    this.currentStage = 1,
  });

  /// Required EXP to level up
  int get expToNextLevel => level * 100 + (level * level * 20);

  /// Combined raw stats including equipment bonuses
  Stats get totalStats {
    Stats res = stats;
    if (equippedWeapon != null) res = res + equippedWeapon!.bonusStats;
    if (equippedArmor != null) res = res + equippedArmor!.bonusStats;
    if (equippedAccessory != null) res = res + equippedAccessory!.bonusStats;
    return res;
  }

  // --- Derived combat numbers ---

  int get maxHp {
    final base = totalStats.maxHp + (equippedArmor?.flatHp ?? 0);
    final hpBonus = (skillLevels['vital_body'] ?? 0) * 0.10; // +10% per level
    return (base * (1.0 + hpBonus)).round();
  }

  double get physicalDef {
    final base = totalStats.physicalDef + (equippedArmor?.flatDef ?? 0);
    final defBonus = (skillLevels['vital_body'] ?? 0) * 3.0;
    return base + defBonus;
  }

  int get maxMana => totalStats.maxMana;

  double get manaRegenPerSecond {
    double regen = 5.0; // Base 5 mana/sec
    if (equippedAccessory != null) regen += equippedAccessory!.manaRegen;
    final manaBonusRank = skillLevels['arcane_flow'] ?? 0;
    regen += manaBonusRank * 2.0; // +2 mana/sec per rank
    return regen;
  }

  /// Damage formulas:
  /// Physical ATK = STR * 2.5 + Weapon
  double get physicalAtk =>
      (totalStats.str * 2.5) + (equippedWeapon?.flatAtk ?? 0);

  /// Magic ATK = INT * 3.0 + Weapon
  double get magicAtk =>
      (totalStats.int_ * 3.0) + (equippedWeapon?.flatAtk ?? 0);

  /// Crit Rate: LUK * 0.5% + Equipment + Passives (capped at 50%)
  double get critRate {
    double rate = totalStats.critRate;
    if (equippedWeapon != null) rate += equippedWeapon!.critRate;
    if (equippedAccessory != null) rate += equippedAccessory!.critRate;
    final frenzyRank = skillLevels['frenzy'] ?? 0;
    rate += frenzyRank * 0.05; // +5% per rank
    return min(0.50, rate);
  }

  /// Crit Damage: Base 150% + Frenzy bonus
  double get critDamageMultiplier {
    final frenzyRank = skillLevels['frenzy'] ?? 0;
    return 1.50 + (frenzyRank * 0.15);
  }

  /// Dodge chance: AGI * 0.3% (capped at 40%)
  double get dodgeRate => totalStats.dodgeRate;

  /// Attack interval in seconds (AGI driven)
  double get attackInterval => totalStats.attackInterval;

  /// Total Fire Damage bonus percent (e.g. 0.45 = +45%)
  double get fireDamageBonusPercent {
    double bonus = 0.0;
    if (equippedAccessory != null) bonus += equippedAccessory!.fireDmgPercent;
    // Fire Heart passive
    final fireHeartRank = skillLevels['fire_heart'] ?? 0;
    if (fireHeartRank > 0) {
      bonus += 0.15 + (fireHeartRank - 1) * 0.05; // 15%, 20%, 25%...
    }
    return bonus;
  }

  /// Bonus damage multiplier when target is inflicted with Burn
  double get burnTargetBonusPercent {
    final igniteRank = skillLevels['flame_ignite'] ?? 0;
    if (igniteRank > 0) {
      return 0.20 + (igniteRank - 1) * 0.05; // 20%, 25%, 30%...
    }
    return 0.0;
  }

  Player copyWith({
    String? name,
    String? title,
    String? portraitAsset,
    String? battleSpriteAsset,
    int? level,
    int? currentExp,
    int? gold,
    int? statPoints,
    int? skillPoints,
    Stats? stats,
    Equipment? equippedWeapon,
    bool clearWeapon = false,
    Equipment? equippedArmor,
    bool clearArmor = false,
    Equipment? equippedAccessory,
    bool clearAccessory = false,
    List<Equipment>? inventory,
    Map<String, int>? skillLevels,
    List<String>? equippedSkillIds,
    int? maxUnlockedZone,
    int? currentZone,
    int? currentStage,
  }) {
    return Player(
      name: name ?? this.name,
      title: title ?? this.title,
      portraitAsset: portraitAsset ?? this.portraitAsset,
      battleSpriteAsset: battleSpriteAsset ?? this.battleSpriteAsset,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      gold: gold ?? this.gold,
      statPoints: statPoints ?? this.statPoints,
      skillPoints: skillPoints ?? this.skillPoints,
      stats: stats ?? this.stats,
      equippedWeapon: clearWeapon ? null : (equippedWeapon ?? this.equippedWeapon),
      equippedArmor: clearArmor ? null : (equippedArmor ?? this.equippedArmor),
      equippedAccessory: clearAccessory ? null : (equippedAccessory ?? this.equippedAccessory),
      inventory: inventory ?? this.inventory,
      skillLevels: skillLevels ?? this.skillLevels,
      equippedSkillIds: equippedSkillIds ?? this.equippedSkillIds,
      maxUnlockedZone: maxUnlockedZone ?? this.maxUnlockedZone,
      currentZone: currentZone ?? this.currentZone,
      currentStage: currentStage ?? this.currentStage,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'portraitAsset': portraitAsset,
        'battleSpriteAsset': battleSpriteAsset,
        'level': level,
        'currentExp': currentExp,
        'gold': gold,
        'statPoints': statPoints,
        'skillPoints': skillPoints,
        'stats': stats.toJson(),
        'equippedWeapon': equippedWeapon?.toJson(),
        'equippedArmor': equippedArmor?.toJson(),
        'equippedAccessory': equippedAccessory?.toJson(),
        'inventory': inventory.map((e) => e.toJson()).toList(),
        'skillLevels': skillLevels,
        'equippedSkillIds': equippedSkillIds,
        'maxUnlockedZone': maxUnlockedZone,
        'currentZone': currentZone,
        'currentStage': currentStage,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String? ?? 'Cyra',
        title: json['title'] as String? ?? 'Hỏa Thuật Sư',
        portraitAsset: json['portraitAsset'] as String? ?? AssetMapping.heroMainPortrait,
        battleSpriteAsset: json['battleSpriteAsset'] as String? ?? AssetMapping.heroBattleSprite,
        level: json['level'] as int? ?? 1,
        currentExp: json['currentExp'] as int? ?? 0,
        gold: json['gold'] as int? ?? 100,
        statPoints: json['statPoints'] as int? ?? 5,
        skillPoints: json['skillPoints'] as int? ?? 1,
        stats: json['stats'] != null
            ? Stats.fromJson(json['stats'] as Map<String, dynamic>)
            : const Stats(str: 5, int_: 12, vit: 8, agi: 6, luk: 5),
        equippedWeapon: json['equippedWeapon'] != null
            ? Equipment.fromJson(json['equippedWeapon'] as Map<String, dynamic>)
            : null,
        equippedArmor: json['equippedArmor'] != null
            ? Equipment.fromJson(json['equippedArmor'] as Map<String, dynamic>)
            : null,
        equippedAccessory: json['equippedAccessory'] != null
            ? Equipment.fromJson(json['equippedAccessory'] as Map<String, dynamic>)
            : null,
        inventory: (json['inventory'] as List<dynamic>?)
                ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        skillLevels: (json['skillLevels'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {'fireball': 1, 'meteor': 1, 'fire_heart': 1},
        equippedSkillIds: (json['equippedSkillIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['fireball', 'meteor'],
        maxUnlockedZone: json['maxUnlockedZone'] as int? ?? 1,
        currentZone: json['currentZone'] as int? ?? 1,
        currentStage: json['currentStage'] as int? ?? 1,
      );
}
