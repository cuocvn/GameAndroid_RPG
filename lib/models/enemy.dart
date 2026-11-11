class EnemySkill {
  final String id;
  final String name;
  final double damageMultiplier;
  final double cooldown; // In seconds
  final String description;
  final String icon;
  final bool isMagic;
  final bool causesHeroFreeze; // Ymir skill 2: hero cannot attack for 2s
  final bool causesHeroDefDown; // Thú vương skill 2: reduces hero def by 20% for 5s
  final bool causesHeroBurn; // Ifrit skill 2: burns hero for 5s (10% max HP/s)
  final bool healsBossPercent; // Hades skill 2: heals 15% HP

  const EnemySkill({
    this.id = '',
    required this.name,
    this.damageMultiplier = 1.5,
    this.cooldown = 8.0,
    this.description = '',
    this.icon = '⚡',
    this.isMagic = false,
    this.causesHeroFreeze = false,
    this.causesHeroDefDown = false,
    this.causesHeroBurn = false,
    this.healsBossPercent = false,
  });
}

class Enemy {
  final String id;
  final String name;
  final int zone; // 1 to 5
  final int stage; // 1 to N
  final bool isBoss;
  final int maxHp;
  int currentHp;
  final int atk;
  final double def;
  final double agi; // Influences attack speed
  final double critRate;
  final double dodgeRate;
  final int expReward;
  final int goldReward;
  final String imageAsset;
  final String fallbackEmoji;
  final EnemySkill? specialSkill;
  final List<EnemySkill> bossSkills;

  // Zone special modifiers
  final double magicResistPercent; // Vùng 3: Kháng phép 40% (0.40)
  final double reflectDamagePercent; // Vùng 4: Phản đòn 20% (0.20)
  final double hpRegenPercentPerSecond; // Vùng 5: Hồi máu 5%/giây (0.05)
  final double critReductionPercent; // Endless modifier: Giảm Crit
  final bool doubleStrike; // Endless modifier: Song Đòn

  // Combat runtime state
  bool isEnraged; // Boss Vùng 5 Diablo Cuồng Nộ khi HP < 30%
  int burnTicksLeft;
  int burnDamagePerTick;
  final int maxMana;
  int currentMana;

  Enemy({
    required this.id,
    required this.name,
    required this.zone,
    required this.stage,
    this.isBoss = false,
    required this.maxHp,
    int? currentHp,
    required this.atk,
    this.def = 0.0,
    this.agi = 5.0,
    this.critRate = 0.05,
    this.dodgeRate = 0.05,
    required this.expReward,
    required this.goldReward,
    required this.imageAsset,
    this.fallbackEmoji = '👾',
    this.specialSkill,
    this.bossSkills = const [],
    this.magicResistPercent = 0.0,
    this.reflectDamagePercent = 0.0,
    this.hpRegenPercentPerSecond = 0.0,
    this.critReductionPercent = 0.0,
    this.doubleStrike = false,
    this.isEnraged = false,
    this.burnTicksLeft = 0,
    this.burnDamagePerTick = 0,
    this.maxMana = 0,
    int? currentMana,
  })  : currentHp = currentHp ?? maxHp,
        currentMana = currentMana ?? maxMana;

  /// Effective ATK including Enrage (+50%)
  int get effectiveAtk => isEnraged ? (atk * 1.5).round() : atk;

  /// Attack interval in seconds for the enemy (Enrage accelerates by 30%)
  double get attackInterval {
    final baseInterval = (2.0 / (1.0 + (agi * 0.03))).clamp(0.8, 3.0);
    return isEnraged ? (baseInterval / 1.3).clamp(0.6, 2.5) : baseInterval;
  }

  bool get isDead => currentHp <= 0;

  List<String> get activeModifierBadges {
    final badges = <String>[];
    if (magicResistPercent > 0) {
      badges.add('🛡️ Kháng Phép ${(magicResistPercent * 100).round()}%');
    }
    if (reflectDamagePercent > 0) {
      badges.add('⚡ Phản Đòn ${(reflectDamagePercent * 100).round()}%');
    }
    if (hpRegenPercentPerSecond > 0) {
      badges.add('💚 Hồi Máu ${(hpRegenPercentPerSecond * 100).round()}%/s');
    }
    if (isEnraged) {
      badges.add('🔥 Cuồng Nộ');
    }
    if (critReductionPercent > 0) {
      badges.add('🛡️ Giảm Crit');
    }
    if (doubleStrike) {
      badges.add('⚔️ Song Đòn');
    }
    return badges;
  }

  Enemy clone({double statMultiplier = 1.0}) {
    final newHp = (maxHp * statMultiplier).round();
    final newAtk = (atk * statMultiplier).round();
    return Enemy(
      id: id,
      name: name,
      zone: zone,
      stage: stage,
      isBoss: isBoss,
      maxHp: newHp,
      currentHp: newHp,
      atk: newAtk,
      def: def * statMultiplier,
      agi: agi,
      critRate: critRate,
      dodgeRate: dodgeRate,
      expReward: (expReward * statMultiplier).round(),
      goldReward: (goldReward * statMultiplier).round(),
      imageAsset: imageAsset,
      fallbackEmoji: fallbackEmoji,
      specialSkill: specialSkill,
      bossSkills: bossSkills,
      magicResistPercent: magicResistPercent,
      reflectDamagePercent: reflectDamagePercent,
      hpRegenPercentPerSecond: hpRegenPercentPerSecond,
      critReductionPercent: critReductionPercent,
      doubleStrike: doubleStrike,
      isEnraged: false,
      burnTicksLeft: 0,
      burnDamagePerTick: 0,
      maxMana: maxMana,
      currentMana: maxMana,
    );
  }
}
