class EnemySkill {
  final String name;
  final double damageMultiplier;
  final int cooldown; // In seconds or attack count
  final String description;

  const EnemySkill({
    required this.name,
    this.damageMultiplier = 1.5,
    this.cooldown = 4,
    this.description = '',
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

  // Status effects during combat
  int burnTicksLeft;
  int burnDamagePerTick;

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
    this.burnTicksLeft = 0,
    this.burnDamagePerTick = 0,
  }) : currentHp = currentHp ?? maxHp;

  /// Attack interval in seconds for the enemy
  double get attackInterval => (2.0 / (1.0 + (agi * 0.03))).clamp(0.8, 3.0);

  bool get isDead => currentHp <= 0;

  Enemy clone() {
    return Enemy(
      id: id,
      name: name,
      zone: zone,
      stage: stage,
      isBoss: isBoss,
      maxHp: maxHp,
      currentHp: maxHp,
      atk: atk,
      def: def,
      agi: agi,
      critRate: critRate,
      dodgeRate: dodgeRate,
      expReward: expReward,
      goldReward: goldReward,
      imageAsset: imageAsset,
      fallbackEmoji: fallbackEmoji,
      specialSkill: specialSkill,
      burnTicksLeft: 0,
      burnDamagePerTick: 0,
    );
  }
}
