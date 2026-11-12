import 'dart:math';
import '../data/asset_mapping.dart';
import 'arena_match_record.dart';
import 'companion.dart';
import 'equipment.dart';
import 'season_pass.dart';
import 'stats.dart';

class Player {
  final String name;
  final String title;
  final String portraitAsset;
  final String battleSpriteAsset;
  final int level;
  final int currentExp;
  final int gold;
  final int gems; // Đá quý nâng cấp trang bị
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
  final int unlockedSkillSlots; // Default 4, can expand to 5

  final int maxUnlockedZone;
  final int currentZone;
  final int currentStage;

  // Track unique beaten stages (e.g. ['z1_s1', 'z1_s2']) for milestone rewards
  final List<String> clearedStages;

  // Tutorial tracking (shown once)
  final bool hasSeenTutorialHome;
  final bool hasSeenTutorialFirstWin;
  final bool hasSeenTutorialFirstDrop;

  // Anti-trivialize: Cleared under 8s buffs next stage difficulty by +15%
  final double nextStageDifficultyBonus;

  // Endless Mode: Highest floor reached
  final int highestEndlessFloor;

  // Claimed Quests & Achievement IDs
  final List<String> claimedQuestIds;

  // Offline Idle AFK progress: timestamp of last claim (ms)
  final int lastAfkClaimTime;

  // Prestige / Chuyển Sinh system
  final int prestigeLevel;
  final int enlightenmentPoints;
  final int totalEnlightenmentEarned;
  final Map<String, int> prestigeNodeLevels;

  // Systems: Gems, Crafting Materials, Reforge
  final Map<String, int> gemInventory; // gemId ('ruby_1', 'topaz_3') -> count
  final Map<String, int> craftingMaterials; // 'iron', 'crystal', 'steel', 'essence' -> count
  final List<String> craftedRecipeIds; // list of recipe IDs that have been crafted

  // Arena & PvP System
  final int arenaPoints;
  final int cumulativeSeasonAp;
  final String highestArenaTier;
  final int arenaWinStreak;
  final List<ArenaMatchRecord> arenaMatchHistory;
  final List<int> claimedSeasonMilestones;
  final int seasonStartTimestamp;
  final int lastSeasonResetTimestamp;
  final List<Map<String, dynamic>> virtualLeaderboardData;
  final int lastLeaderboardSimTime;

  // Story & Hero Lore System
  final String currentHeroId;
  final Map<String, int> heroLevelProgress;
  final Map<String, List<int>> claimedHeroStoryChapters;

  // Companion System
  final String? equippedCompanionId;
  final Map<String, int> companionLevels;
  final Map<String, int> petFoods;

  // Raid Boss System
  final int raidStamina;
  final int lastRaidStaminaRegenTime;
  final int raidBossCurrentHp;
  final int currentRaidWeek;
  final int weeklyRaidDamage;
  final bool hasClaimedWeeklyRaidReward;
  final int dailyStaminaPurchases;
  final String lastStaminaPurchaseDate;

  // Offline Progress & Auto-Farm System
  final int lastActiveTimestamp;
  final bool isAutoFarming;
  final int autoFarmZone;
  final int autoFarmStage;

  // Sound, Haptics & Hint Settings
  final bool isSoundEnabled;
  final bool isHapticEnabled;
  final Map<String, int> consecutiveDefeats;
  final int lastInventoryAcquiredTime;

  const Player({
    this.name = 'Cyra',
    this.title = 'Hỏa Thuật Sư',
    this.portraitAsset = AssetMapping.heroMainPortrait,
    this.battleSpriteAsset = AssetMapping.heroBattleSprite,
    this.level = 1,
    this.currentExp = 0,
    this.gold = 50,
    this.gems = 3,
    this.statPoints = 2, // Giảm còn 2 điểm chỉ số ban đầu
    this.skillPoints = 1,
    this.stats = const Stats(str: 5, int_: 10, vit: 8, agi: 6, luk: 5),
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
    this.unlockedSkillSlots = 4,
    this.maxUnlockedZone = 1,
    this.currentZone = 1,
    this.currentStage = 1,
    this.clearedStages = const [],
    this.hasSeenTutorialHome = false,
    this.hasSeenTutorialFirstWin = false,
    this.hasSeenTutorialFirstDrop = false,
    this.nextStageDifficultyBonus = 0.0,
    this.highestEndlessFloor = 1,
    this.claimedQuestIds = const [],
    this.lastAfkClaimTime = 0,
    this.prestigeLevel = 0,
    this.enlightenmentPoints = 0,
    this.totalEnlightenmentEarned = 0,
    this.prestigeNodeLevels = const {},
    this.gemInventory = const {},
    this.craftingMaterials = const {
      'iron': 0,
      'crystal': 0,
      'steel': 0,
      'essence': 0,
    },
    this.craftedRecipeIds = const [],
    this.arenaPoints = 0,
    this.cumulativeSeasonAp = 0,
    this.highestArenaTier = 'Đồng III',
    this.arenaWinStreak = 0,
    this.arenaMatchHistory = const [],
    this.claimedSeasonMilestones = const [],
    this.seasonStartTimestamp = 0,
    this.lastSeasonResetTimestamp = 0,
    this.virtualLeaderboardData = const [],
    this.lastLeaderboardSimTime = 0,
    this.currentHeroId = 'cyra',
    this.heroLevelProgress = const {'cyra': 1},
    this.claimedHeroStoryChapters = const {},
    this.equippedCompanionId,
    this.companionLevels = const {},
    this.petFoods = const {
      'meat': 0,
      'herb': 0,
      'beast_stone': 0,
    },
    this.raidStamina = 20,
    this.lastRaidStaminaRegenTime = 0,
    this.raidBossCurrentHp = 500000,
    this.currentRaidWeek = 0,
    this.weeklyRaidDamage = 0,
    this.hasClaimedWeeklyRaidReward = false,
    this.dailyStaminaPurchases = 0,
    this.lastStaminaPurchaseDate = '',
    this.lastActiveTimestamp = 0,
    this.isAutoFarming = false,
    this.autoFarmZone = 1,
    this.autoFarmStage = 1,
    this.isSoundEnabled = true,
    this.isHapticEnabled = true,
    this.consecutiveDefeats = const {},
    this.lastInventoryAcquiredTime = 0,
  });

  /// Required EXP to level up
  int get expToNextLevel => level * 100 + (level * level * 20);

  /// Combined raw stats with gear bonuses capped at +150% of base
  Stats get totalStats {
    Stats gearBonus = const Stats(str: 0, int_: 0, vit: 0, agi: 0, luk: 0);
    if (equippedWeapon != null) gearBonus = gearBonus + equippedWeapon!.bonusStats;
    if (equippedArmor != null) gearBonus = gearBonus + equippedArmor!.bonusStats;
    if (equippedAccessory != null) gearBonus = gearBonus + equippedAccessory!.bonusStats;

    final maxBonusStr = max(5, (stats.str * 1.5).round());
    final maxBonusInt = max(5, (stats.int_ * 1.5).round());
    final maxBonusVit = max(5, (stats.vit * 1.5).round());
    final maxBonusAgi = max(5, (stats.agi * 1.5).round());
    final maxBonusLuk = max(5, (stats.luk * 1.5).round());

    final clampedBonus = Stats(
      str: gearBonus.str.clamp(0, maxBonusStr),
      int_: gearBonus.int_.clamp(0, maxBonusInt),
      vit: gearBonus.vit.clamp(0, maxBonusVit),
      agi: gearBonus.agi.clamp(0, maxBonusAgi),
      luk: gearBonus.luk.clamp(0, maxBonusLuk),
    );

    final baseTotal = stats + clampedBonus;
    double mult = storyStatMultiplier;
    final ancientLvl = prestigeNodeLevels['ancient_power'] ?? 0;
    if (ancientLvl > 0) {
      mult += (ancientLvl * 0.05);
    }
    if (mult != 1.0) {
      return Stats(
        str: (baseTotal.str * mult).round(),
        int_: (baseTotal.int_ * mult).round(),
        vit: (baseTotal.vit * mult).round(),
        agi: (baseTotal.agi * mult).round(),
        luk: (baseTotal.luk * mult).round(),
      );
    }

    return baseTotal;
  }

  // --- Derived combat numbers & Gem Socket / Affix helpers ---

  int get allEquippedSocketAtk =>
      (equippedWeapon?.socketAtkBonus ?? 0) +
      (equippedArmor?.socketAtkBonus ?? 0) +
      (equippedAccessory?.socketAtkBonus ?? 0);

  int get allEquippedSocketHp =>
      (equippedWeapon?.socketHpBonus ?? 0) +
      (equippedArmor?.socketHpBonus ?? 0) +
      (equippedAccessory?.socketHpBonus ?? 0);

  int get allEquippedSocketDef =>
      (equippedWeapon?.socketDefBonus ?? 0) +
      (equippedArmor?.socketDefBonus ?? 0) +
      (equippedAccessory?.socketDefBonus ?? 0);

  double get allEquippedSocketCrit =>
      (equippedWeapon?.socketCritBonus ?? 0.0) +
      (equippedArmor?.socketCritBonus ?? 0.0) +
      (equippedAccessory?.socketCritBonus ?? 0.0);

  double get allEquippedSocketManaRegen =>
      (equippedWeapon?.socketManaRegenBonus ?? 0.0) +
      (equippedArmor?.socketManaRegenBonus ?? 0.0) +
      (equippedAccessory?.socketManaRegenBonus ?? 0.0);

  double get allAffixAtkPercent =>
      (equippedWeapon?.affixAtkPercent ?? 0.0) +
      (equippedArmor?.affixAtkPercent ?? 0.0) +
      (equippedAccessory?.affixAtkPercent ?? 0.0);

  double get allAffixHpPercent =>
      (equippedWeapon?.affixHpPercent ?? 0.0) +
      (equippedArmor?.affixHpPercent ?? 0.0) +
      (equippedAccessory?.affixHpPercent ?? 0.0);

  double get allAffixCritDmgPercent =>
      (equippedWeapon?.affixCritDmgPercent ?? 0.0) +
      (equippedArmor?.affixCritDmgPercent ?? 0.0) +
      (equippedAccessory?.affixCritDmgPercent ?? 0.0);

  double get allAffixAttackSpeedPercent =>
      (equippedWeapon?.affixAttackSpeedPercent ?? 0.0) +
      (equippedArmor?.affixAttackSpeedPercent ?? 0.0) +
      (equippedAccessory?.affixAttackSpeedPercent ?? 0.0);

  double get allAffixElementalResistPercent =>
      (equippedWeapon?.affixElementalResistPercent ?? 0.0) +
      (equippedArmor?.affixElementalResistPercent ?? 0.0) +
      (equippedAccessory?.affixElementalResistPercent ?? 0.0);

  double get allAffixLifestealPercent {
    final compLifesteal = (equippedCompanionId == 'spirit') ? companionPassiveBonus : 0.0;
    return (equippedWeapon?.affixLifestealPercent ?? 0.0) +
        (equippedArmor?.affixLifestealPercent ?? 0.0) +
        (equippedAccessory?.affixLifestealPercent ?? 0.0) +
        compLifesteal;
  }

  int get maxHp {
    final base = totalStats.maxHp +
        (equippedArmor?.effectiveFlatHp ?? 0) +
        (equippedWeapon?.socketHpBonus ?? 0) +
        (equippedAccessory?.socketHpBonus ?? 0);
    final hpBonus = (skillLevels['vital_body'] ?? 0) * 0.10; // +10% per level
    final tenacityBonus = (prestigeNodeLevels['tenacity_hp'] ?? 0) * 0.15; // +15% per level
    final compHp = (equippedCompanionId == 'dragon') ? companionPassiveBonus : 0.0;
    return (base * (1.0 + hpBonus + tenacityBonus + allAffixHpPercent + compHp)).round();
  }

  double get physicalDef {
    final base = totalStats.physicalDef +
        (equippedArmor?.effectiveFlatDef ?? 0) +
        (equippedWeapon?.socketDefBonus ?? 0) +
        (equippedAccessory?.socketDefBonus ?? 0);
    final defBonus = (skillLevels['vital_body'] ?? 0) * 3.0;
    return base + defBonus;
  }

  int get maxMana => totalStats.maxMana;

  double get manaRegenPerSecond {
    double regen = 5.0; // Base 5 mana/sec
    if (equippedAccessory != null) regen += equippedAccessory!.manaRegen;
    regen += allEquippedSocketManaRegen;
    final manaBonusRank = skillLevels['arcane_flow'] ?? 0;
    regen += manaBonusRank * 2.0; // +2 mana/sec per rank
    return regen;
  }

  /// Damage formulas:
  /// Physical ATK = (STR * 2.5 + Weapon + SocketATK) * (1 + AffixATK)
  double get physicalAtk {
    final baseAtk = (totalStats.str * 2.5) +
        (equippedWeapon?.effectiveFlatAtk ?? 0) +
        (equippedArmor?.socketAtkBonus ?? 0) +
        (equippedAccessory?.socketAtkBonus ?? 0);
    return baseAtk * (1.0 + allAffixAtkPercent);
  }

  /// Magic ATK = (INT * 3.0 + Weapon + SocketATK) * (1 + AffixATK)
  double get magicAtk {
    final baseAtk = (totalStats.int_ * 3.0) +
        (equippedWeapon?.effectiveFlatAtk ?? 0) +
        (equippedArmor?.socketAtkBonus ?? 0) +
        (equippedAccessory?.socketAtkBonus ?? 0);
    return baseAtk * (1.0 + allAffixAtkPercent);
  }

  /// Crit Rate: LUK * 0.5% + Equipment + Passives + Set Bonus + Sockets + Companion (capped at 60%)
  double get critRate {
    double rate = totalStats.critRate;
    if (equippedWeapon != null) rate += equippedWeapon!.critRate;
    if (equippedAccessory != null) rate += equippedAccessory!.critRate;
    rate += allEquippedSocketCrit;
    final frenzyRank = skillLevels['frenzy'] ?? 0;
    rate += frenzyRank * 0.05; // +5% per rank
    if (hasSetBonus2('loi_dinh')) {
      rate += 0.10; // +10% Crit rate from Lôi Đình 2-piece set bonus
    }
    if (equippedCompanionId == 'fox') {
      rate += companionPassiveBonus;
    }
    return min(0.60, rate);
  }

  /// Crit Damage: Base 150% + Frenzy bonus + Affixes (Capped at 300%)
  double get critDamageMultiplier {
    final frenzyRank = skillLevels['frenzy'] ?? 0;
    final mult = 1.50 + (frenzyRank * 0.15) + allAffixCritDmgPercent;
    return min(3.00, mult);
  }

  /// Dodge chance: AGI * 0.3% (capped at 40%)
  double get dodgeRate => totalStats.dodgeRate;

  /// Attack interval in seconds (AGI driven + prestige speed + affixes + companion)
  double get attackInterval {
    final base = totalStats.attackInterval;
    final speedLvl = prestigeNodeLevels['swift_speed'] ?? 0;
    final compSpeed = (equippedCompanionId == 'wolf') ? companionPassiveBonus : 0.0;
    final speedMult = (1.0 + speedLvl * 0.10 + compSpeed) * (1.0 + allAffixAttackSpeedPercent);
    return max(0.35, base / speedMult);
  }

  /// Max active skill slots considering divine_aura prestige node
  int get effectiveSkillSlots {
    int slots = unlockedSkillSlots;
    if ((prestigeNodeLevels['divine_aura'] ?? 0) > 0) {
      slots = max(slots, 5) + 1;
    }
    return min(6, slots);
  }

  /// Maximum inventory capacity (QA Sweep standard)
  static const int maxInventoryCapacity = 200;

  /// Check if the inventory is at or above capacity
  bool get isInventoryFull => inventory.length >= maxInventoryCapacity;

  /// Total combat power rating
  int get combatPower =>
      (maxHp ~/ 5) + ((physicalAtk + magicAtk) * 1.8).round() + (physicalDef * 3).round();

  /// Active equipment set counts: setId -> count of equipped items (0 to 3)
  Map<String, int> get activeSetCounts {
    final counts = <String, int>{};
    if (equippedWeapon?.setId != null) {
      counts[equippedWeapon!.setId!] = (counts[equippedWeapon!.setId!] ?? 0) + 1;
    }
    if (equippedArmor?.setId != null) {
      counts[equippedArmor!.setId!] = (counts[equippedArmor!.setId!] ?? 0) + 1;
    }
    if (equippedAccessory?.setId != null) {
      counts[equippedAccessory!.setId!] = (counts[equippedAccessory!.setId!] ?? 0) + 1;
    }
    return counts;
  }

  bool hasSetBonus2(String setId) => (activeSetCounts[setId] ?? 0) >= 2;
  bool hasSetBonus3(String setId) => (activeSetCounts[setId] ?? 0) >= 3;

  /// Total Fire Damage bonus percent (e.g. 0.45 = +45%)
  double get fireDamageBonusPercent {
    double bonus = 0.0;
    if (equippedAccessory != null) bonus += equippedAccessory!.fireDmgPercent;
    // Fire Heart passive
    final fireHeartRank = skillLevels['fire_heart'] ?? 0;
    if (fireHeartRank > 0) {
      bonus += 0.15 + (fireHeartRank - 1) * 0.05; // 15%, 20%, 25%...
    }
    // Set Viêm Long 2-piece bonus (+20% fire damage)
    if (hasSetBonus2('viem_long')) {
      bonus += 0.20;
    }
    if (equippedCompanionId == 'eagle') {
      bonus += companionPassiveBonus;
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

  /// Check if player has unlocked Chapter 3 on ALL 16 heroes
  bool get hasHistorianTitle {
    const allHeroes = [
      'cyra', 'inari', 'violetta', 'valeria', 'kaelen', 'carmilla', 'elysia',
      'sylvia', 'selene', 'aurora', 'lucia', 'marina', 'seraphina', 'giselle',
      'freya', 'mai'
    ];
    for (final heroId in allHeroes) {
      final claimed = claimedHeroStoryChapters[heroId] ?? const [];
      if (!claimed.contains(3)) return false;
    }
    return true;
  }

  /// QoL: Check if there are unclaimed Season milestones available
  bool get hasUnclaimedSeasonMilestones {
    final milestones = SeasonMilestone.generateMilestones();
    return milestones.any((m) => cumulativeSeasonAp >= m.requiredAp && !claimedSeasonMilestones.contains(m.level));
  }

  /// Stat multiplier from story progress (+1% current hero, +5% if historian)
  double get storyStatMultiplier {
    double mult = 1.0;
    final heroClaimed = claimedHeroStoryChapters[currentHeroId] ?? const [];
    if (heroClaimed.contains(3)) {
      mult += 0.01;
    }
    if (hasHistorianTitle) {
      mult += 0.05;
    }
    return mult;
  }

  /// Effective passive bonus from equipped companion (strictly capped at +30%)
  double get companionPassiveBonus {
    if (equippedCompanionId == null) return 0.0;
    final comp = CompanionType.getById(equippedCompanionId!);
    if (comp == null) return 0.0;
    final lvl = companionLevels[equippedCompanionId!] ?? 1;
    return comp.getEffectivePassive(lvl);
  }

  /// Current calculated raid stamina with offline regeneration (1 point per 5 mins, max 20)
  int get calculatedRaidStamina {
    if (raidStamina >= 20 || lastRaidStaminaRegenTime == 0) {
      return raidStamina.clamp(0, 20);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMs = now - lastRaidStaminaRegenTime;
    const regenIntervalMs = 5 * 60 * 1000;
    final recovered = diffMs ~/ regenIntervalMs;
    return min(20, raidStamina + recovered);
  }

  Player copyWith({
    String? name,
    String? title,
    String? portraitAsset,
    String? battleSpriteAsset,
    int? level,
    int? currentExp,
    int? gold,
    int? gems,
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
    int? unlockedSkillSlots,
    int? maxUnlockedZone,
    int? currentZone,
    int? currentStage,
    List<String>? clearedStages,
    bool? hasSeenTutorialHome,
    bool? hasSeenTutorialFirstWin,
    bool? hasSeenTutorialFirstDrop,
    double? nextStageDifficultyBonus,
    int? highestEndlessFloor,
    List<String>? claimedQuestIds,
    int? lastAfkClaimTime,
    int? prestigeLevel,
    int? enlightenmentPoints,
    int? totalEnlightenmentEarned,
    Map<String, int>? prestigeNodeLevels,
    Map<String, int>? gemInventory,
    Map<String, int>? craftingMaterials,
    List<String>? craftedRecipeIds,
    int? arenaPoints,
    int? cumulativeSeasonAp,
    String? highestArenaTier,
    int? arenaWinStreak,
    List<ArenaMatchRecord>? arenaMatchHistory,
    List<int>? claimedSeasonMilestones,
    int? seasonStartTimestamp,
    int? lastSeasonResetTimestamp,
    List<Map<String, dynamic>>? virtualLeaderboardData,
    int? lastLeaderboardSimTime,
    String? currentHeroId,
    Map<String, int>? heroLevelProgress,
    Map<String, List<int>>? claimedHeroStoryChapters,
    String? equippedCompanionId,
    bool clearCompanion = false,
    Map<String, int>? companionLevels,
    Map<String, int>? petFoods,
    int? raidStamina,
    int? lastRaidStaminaRegenTime,
    int? raidBossCurrentHp,
    int? currentRaidWeek,
    int? weeklyRaidDamage,
    bool? hasClaimedWeeklyRaidReward,
    int? dailyStaminaPurchases,
    String? lastStaminaPurchaseDate,
    int? lastActiveTimestamp,
    bool? isAutoFarming,
    int? autoFarmZone,
    int? autoFarmStage,
    bool? isSoundEnabled,
    bool? isHapticEnabled,
    Map<String, int>? consecutiveDefeats,
    int? lastInventoryAcquiredTime,
  }) {
    return Player(
      name: name ?? this.name,
      title: title ?? this.title,
      portraitAsset: portraitAsset ?? this.portraitAsset,
      battleSpriteAsset: battleSpriteAsset ?? this.battleSpriteAsset,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      statPoints: statPoints ?? this.statPoints,
      skillPoints: skillPoints ?? this.skillPoints,
      stats: stats ?? this.stats,
      equippedWeapon: clearWeapon ? null : (equippedWeapon ?? this.equippedWeapon),
      equippedArmor: clearArmor ? null : (equippedArmor ?? this.equippedArmor),
      equippedAccessory: clearAccessory ? null : (equippedAccessory ?? this.equippedAccessory),
      inventory: inventory ?? this.inventory,
      skillLevels: skillLevels ?? this.skillLevels,
      equippedSkillIds: equippedSkillIds ?? this.equippedSkillIds,
      unlockedSkillSlots: unlockedSkillSlots ?? this.unlockedSkillSlots,
      maxUnlockedZone: maxUnlockedZone ?? this.maxUnlockedZone,
      currentZone: currentZone ?? this.currentZone,
      currentStage: currentStage ?? this.currentStage,
      clearedStages: clearedStages ?? this.clearedStages,
      hasSeenTutorialHome: hasSeenTutorialHome ?? this.hasSeenTutorialHome,
      hasSeenTutorialFirstWin: hasSeenTutorialFirstWin ?? this.hasSeenTutorialFirstWin,
      hasSeenTutorialFirstDrop: hasSeenTutorialFirstDrop ?? this.hasSeenTutorialFirstDrop,
      nextStageDifficultyBonus: nextStageDifficultyBonus ?? this.nextStageDifficultyBonus,
      highestEndlessFloor: highestEndlessFloor ?? this.highestEndlessFloor,
      claimedQuestIds: claimedQuestIds ?? this.claimedQuestIds,
      lastAfkClaimTime: lastAfkClaimTime ?? this.lastAfkClaimTime,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      enlightenmentPoints: enlightenmentPoints ?? this.enlightenmentPoints,
      totalEnlightenmentEarned: totalEnlightenmentEarned ?? this.totalEnlightenmentEarned,
      prestigeNodeLevels: prestigeNodeLevels ?? this.prestigeNodeLevels,
      gemInventory: gemInventory ?? this.gemInventory,
      craftingMaterials: craftingMaterials ?? this.craftingMaterials,
      craftedRecipeIds: craftedRecipeIds ?? this.craftedRecipeIds,
      arenaPoints: arenaPoints ?? this.arenaPoints,
      cumulativeSeasonAp: cumulativeSeasonAp ?? this.cumulativeSeasonAp,
      highestArenaTier: highestArenaTier ?? this.highestArenaTier,
      arenaWinStreak: arenaWinStreak ?? this.arenaWinStreak,
      arenaMatchHistory: arenaMatchHistory ?? this.arenaMatchHistory,
      claimedSeasonMilestones: claimedSeasonMilestones ?? this.claimedSeasonMilestones,
      seasonStartTimestamp: seasonStartTimestamp ?? this.seasonStartTimestamp,
      lastSeasonResetTimestamp: lastSeasonResetTimestamp ?? this.lastSeasonResetTimestamp,
      virtualLeaderboardData: virtualLeaderboardData ?? this.virtualLeaderboardData,
      lastLeaderboardSimTime: lastLeaderboardSimTime ?? this.lastLeaderboardSimTime,
      currentHeroId: currentHeroId ?? this.currentHeroId,
      heroLevelProgress: heroLevelProgress ?? this.heroLevelProgress,
      claimedHeroStoryChapters: claimedHeroStoryChapters ?? this.claimedHeroStoryChapters,
      equippedCompanionId: clearCompanion ? null : (equippedCompanionId ?? this.equippedCompanionId),
      companionLevels: companionLevels ?? this.companionLevels,
      petFoods: petFoods ?? this.petFoods,
      raidStamina: raidStamina ?? this.raidStamina,
      lastRaidStaminaRegenTime: lastRaidStaminaRegenTime ?? this.lastRaidStaminaRegenTime,
      raidBossCurrentHp: raidBossCurrentHp ?? this.raidBossCurrentHp,
      currentRaidWeek: currentRaidWeek ?? this.currentRaidWeek,
      weeklyRaidDamage: weeklyRaidDamage ?? this.weeklyRaidDamage,
      hasClaimedWeeklyRaidReward: hasClaimedWeeklyRaidReward ?? this.hasClaimedWeeklyRaidReward,
      dailyStaminaPurchases: dailyStaminaPurchases ?? this.dailyStaminaPurchases,
      lastStaminaPurchaseDate: lastStaminaPurchaseDate ?? this.lastStaminaPurchaseDate,
      lastActiveTimestamp: lastActiveTimestamp ?? this.lastActiveTimestamp,
      isAutoFarming: isAutoFarming ?? this.isAutoFarming,
      autoFarmZone: autoFarmZone ?? this.autoFarmZone,
      autoFarmStage: autoFarmStage ?? this.autoFarmStage,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
      consecutiveDefeats: consecutiveDefeats ?? this.consecutiveDefeats,
      lastInventoryAcquiredTime: lastInventoryAcquiredTime ?? this.lastInventoryAcquiredTime,
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
        'gems': gems,
        'statPoints': statPoints,
        'skillPoints': skillPoints,
        'stats': stats.toJson(),
        'equippedWeapon': equippedWeapon?.toJson(),
        'equippedArmor': equippedArmor?.toJson(),
        'equippedAccessory': equippedAccessory?.toJson(),
        'inventory': inventory.map((e) => e.toJson()).toList(),
        'skillLevels': skillLevels,
        'equippedSkillIds': equippedSkillIds,
        'unlockedSkillSlots': unlockedSkillSlots,
        'maxUnlockedZone': maxUnlockedZone,
        'currentZone': currentZone,
        'currentStage': currentStage,
        'clearedStages': clearedStages,
        'hasSeenTutorialHome': hasSeenTutorialHome,
        'hasSeenTutorialFirstWin': hasSeenTutorialFirstWin,
        'hasSeenTutorialFirstDrop': hasSeenTutorialFirstDrop,
        'highestEndlessFloor': highestEndlessFloor,
        'claimedQuestIds': claimedQuestIds,
        'lastAfkClaimTime': lastAfkClaimTime,
        'prestigeLevel': prestigeLevel,
        'enlightenmentPoints': enlightenmentPoints,
        'totalEnlightenmentEarned': totalEnlightenmentEarned,
        'prestigeNodeLevels': prestigeNodeLevels,
        'gemInventory': gemInventory,
        'craftingMaterials': craftingMaterials,
        'craftedRecipeIds': craftedRecipeIds,
        'arenaPoints': arenaPoints,
        'cumulativeSeasonAp': cumulativeSeasonAp,
        'highestArenaTier': highestArenaTier,
        'arenaWinStreak': arenaWinStreak,
        'arenaMatchHistory': arenaMatchHistory.map((e) => e.toJson()).toList(),
        'claimedSeasonMilestones': claimedSeasonMilestones,
        'seasonStartTimestamp': seasonStartTimestamp,
        'lastSeasonResetTimestamp': lastSeasonResetTimestamp,
        'virtualLeaderboardData': virtualLeaderboardData,
        'lastLeaderboardSimTime': lastLeaderboardSimTime,
        'currentHeroId': currentHeroId,
        'heroLevelProgress': heroLevelProgress,
        'claimedHeroStoryChapters': claimedHeroStoryChapters,
        'equippedCompanionId': equippedCompanionId,
        'companionLevels': companionLevels,
        'petFoods': petFoods,
        'raidStamina': raidStamina,
        'lastRaidStaminaRegenTime': lastRaidStaminaRegenTime,
        'raidBossCurrentHp': raidBossCurrentHp,
        'currentRaidWeek': currentRaidWeek,
        'weeklyRaidDamage': weeklyRaidDamage,
        'hasClaimedWeeklyRaidReward': hasClaimedWeeklyRaidReward,
        'dailyStaminaPurchases': dailyStaminaPurchases,
        'lastStaminaPurchaseDate': lastStaminaPurchaseDate,
        'lastActiveTimestamp': lastActiveTimestamp,
        'isAutoFarming': isAutoFarming,
        'autoFarmZone': autoFarmZone,
        'autoFarmStage': autoFarmStage,
        'isSoundEnabled': isSoundEnabled,
        'isHapticEnabled': isHapticEnabled,
        'consecutiveDefeats': consecutiveDefeats,
        'lastInventoryAcquiredTime': lastInventoryAcquiredTime,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String? ?? 'Cyra',
        title: json['title'] as String? ?? 'Hỏa Thuật Sư',
        portraitAsset: json['portraitAsset'] as String? ?? AssetMapping.heroMainPortrait,
        battleSpriteAsset: json['battleSpriteAsset'] as String? ?? AssetMapping.heroBattleSprite,
        level: json['level'] as int? ?? 1,
        currentExp: json['currentExp'] as int? ?? 0,
        gold: json['gold'] as int? ?? 50,
        gems: json['gems'] as int? ?? 3,
        statPoints: json['statPoints'] as int? ?? 2,
        skillPoints: json['skillPoints'] as int? ?? 1,
        stats: json['stats'] != null
            ? Stats.fromJson(json['stats'] as Map<String, dynamic>)
            : const Stats(str: 5, int_: 10, vit: 8, agi: 6, luk: 5),
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
        unlockedSkillSlots: json['unlockedSkillSlots'] as int? ?? 4,
        maxUnlockedZone: json['maxUnlockedZone'] as int? ?? 1,
        currentZone: json['currentZone'] as int? ?? 1,
        currentStage: json['currentStage'] as int? ?? 1,
        clearedStages: (json['clearedStages'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        hasSeenTutorialHome: json['hasSeenTutorialHome'] as bool? ?? false,
        hasSeenTutorialFirstWin: json['hasSeenTutorialFirstWin'] as bool? ?? false,
        hasSeenTutorialFirstDrop: json['hasSeenTutorialFirstDrop'] as bool? ?? false,
        highestEndlessFloor: json['highestEndlessFloor'] as int? ?? 1,
        claimedQuestIds: (json['claimedQuestIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        lastAfkClaimTime: json['lastAfkClaimTime'] as int? ?? 0,
        prestigeLevel: json['prestigeLevel'] as int? ?? 0,
        enlightenmentPoints: json['enlightenmentPoints'] as int? ?? 0,
        totalEnlightenmentEarned: json['totalEnlightenmentEarned'] as int? ?? 0,
        prestigeNodeLevels: (json['prestigeNodeLevels'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {},
        gemInventory: (json['gemInventory'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {},
        craftingMaterials: (json['craftingMaterials'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {
              'iron': 0,
              'crystal': 0,
              'steel': 0,
              'essence': 0,
            },
        craftedRecipeIds: (json['craftedRecipeIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        arenaPoints: json['arenaPoints'] as int? ?? 0,
        cumulativeSeasonAp: json['cumulativeSeasonAp'] as int? ?? 0,
        highestArenaTier: json['highestArenaTier'] as String? ?? 'Đồng III',
        arenaWinStreak: json['arenaWinStreak'] as int? ?? 0,
        arenaMatchHistory: (json['arenaMatchHistory'] as List<dynamic>?)
                ?.map((e) => ArenaMatchRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        claimedSeasonMilestones: (json['claimedSeasonMilestones'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        seasonStartTimestamp: json['seasonStartTimestamp'] as int? ?? 0,
        lastSeasonResetTimestamp: json['lastSeasonResetTimestamp'] as int? ?? 0,
        virtualLeaderboardData: (json['virtualLeaderboardData'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        lastLeaderboardSimTime: json['lastLeaderboardSimTime'] as int? ?? 0,
        currentHeroId: json['currentHeroId'] as String? ?? 'cyra',
        heroLevelProgress: (json['heroLevelProgress'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {'cyra': 1},
        claimedHeroStoryChapters: (json['claimedHeroStoryChapters'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                k,
                (v as List<dynamic>).map((e) => e as int).toList(),
              ),
            ) ??
            const {},
        equippedCompanionId: json['equippedCompanionId'] as String?,
        companionLevels: (json['companionLevels'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {},
        petFoods: (json['petFoods'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {
              'meat': 0,
              'herb': 0,
              'beast_stone': 0,
            },
        raidStamina: json['raidStamina'] as int? ?? 20,
        lastRaidStaminaRegenTime: json['lastRaidStaminaRegenTime'] as int? ?? 0,
        raidBossCurrentHp: json['raidBossCurrentHp'] as int? ?? 500000,
        currentRaidWeek: json['currentRaidWeek'] as int? ?? 0,
        weeklyRaidDamage: json['weeklyRaidDamage'] as int? ?? 0,
        hasClaimedWeeklyRaidReward: json['hasClaimedWeeklyRaidReward'] as bool? ?? false,
        dailyStaminaPurchases: json['dailyStaminaPurchases'] as int? ?? 0,
        lastStaminaPurchaseDate: json['lastStaminaPurchaseDate'] as String? ?? '',
        lastActiveTimestamp: json['lastActiveTimestamp'] as int? ?? 0,
        isAutoFarming: json['isAutoFarming'] as bool? ?? false,
        autoFarmZone: json['autoFarmZone'] as int? ?? 1,
        autoFarmStage: json['autoFarmStage'] as int? ?? 1,
        isSoundEnabled: json['isSoundEnabled'] as bool? ?? true,
        isHapticEnabled: json['isHapticEnabled'] as bool? ?? true,
        consecutiveDefeats: (json['consecutiveDefeats'] as Map<dynamic, dynamic>?)
                ?.map((k, v) => MapEntry(k.toString(), v as int)) ??
            const {},
        lastInventoryAcquiredTime: json['lastInventoryAcquiredTime'] as int? ?? 0,
      );
}
