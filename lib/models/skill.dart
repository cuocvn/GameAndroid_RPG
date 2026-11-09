enum SkillType {
  basic,
  active,
  passive,
}

enum SkillElement {
  physical,
  fire,
  ice,
  lightning,
  poison,
  holy,
}

class Skill {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final SkillElement element;
  final int manaCost;
  final double baseMultiplier; // e.g. 1.0 = 100% ATK, 3.0 = 300% ATK
  final double cooldown; // In seconds
  final String? iconAsset;
  final String emoji;
  final int level; // Current rank (1 to 5)
  final int maxLevel;

  // Specific passive/status tags
  final double fireDmgBonus; // +15%
  final double burnTargetBonus; // +20%
  final double critRateBonus;
  final double critDmgBonus;
  final double hpBonusPercent;
  final double manaRegenBonus;

  // Active status triggers
  final bool causesBurn;
  final bool grantsShield;
  final bool healsHero;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.element = SkillElement.fire,
    this.manaCost = 0,
    this.baseMultiplier = 1.0,
    this.cooldown = 0.0,
    this.iconAsset,
    this.emoji = '🔥',
    this.level = 1,
    this.maxLevel = 5,
    this.fireDmgBonus = 0.0,
    this.burnTargetBonus = 0.0,
    this.critRateBonus = 0.0,
    this.critDmgBonus = 0.0,
    this.hpBonusPercent = 0.0,
    this.manaRegenBonus = 0.0,
    this.causesBurn = false,
    this.grantsShield = false,
    this.healsHero = false,
  });

  /// Scaling multiplier based on level: +15% per extra level
  double get currentMultiplier => baseMultiplier * (1.0 + (level - 1) * 0.15);

  /// Scaling passive fire damage
  double get currentFireDmgBonus => fireDmgBonus * (1.0 + (level - 1) * 0.2);

  /// Scaling passive burn multiplier
  double get currentBurnTargetBonus => burnTargetBonus * (1.0 + (level - 1) * 0.25);

  Skill copyWith({int? level}) {
    return Skill(
      id: id,
      name: name,
      description: description,
      type: type,
      element: element,
      manaCost: manaCost,
      baseMultiplier: baseMultiplier,
      cooldown: cooldown,
      iconAsset: iconAsset,
      emoji: emoji,
      level: level ?? this.level,
      maxLevel: maxLevel,
      fireDmgBonus: fireDmgBonus,
      burnTargetBonus: burnTargetBonus,
      critRateBonus: critRateBonus,
      critDmgBonus: critDmgBonus,
      hpBonusPercent: hpBonusPercent,
      manaRegenBonus: manaRegenBonus,
      causesBurn: causesBurn,
      grantsShield: grantsShield,
      healsHero: healsHero,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
      };
}
