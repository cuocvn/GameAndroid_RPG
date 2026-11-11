import 'package:flutter/material.dart';
import 'equipment_affix.dart';
import 'gem.dart';
import 'stats.dart';

enum EquipmentSlot {
  weapon,
  armor,
  accessory,
}

extension EquipmentSlotExtension on EquipmentSlot {
  String get label {
    switch (this) {
      case EquipmentSlot.weapon:
        return 'Vũ Khí';
      case EquipmentSlot.armor:
        return 'Giáp';
      case EquipmentSlot.accessory:
        return 'Phụ Kiện';
    }
  }
}

enum EquipmentRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension RarityColor on EquipmentRarity {
  Color get color {
    switch (this) {
      case EquipmentRarity.common:
        return Colors.white70;
      case EquipmentRarity.uncommon:
        return Colors.greenAccent;
      case EquipmentRarity.rare:
        return Colors.lightBlueAccent;
      case EquipmentRarity.epic:
        return Colors.purpleAccent;
      case EquipmentRarity.legendary:
        return Colors.amberAccent;
    }
  }

  String get label {
    switch (this) {
      case EquipmentRarity.common:
        return 'Thường';
      case EquipmentRarity.uncommon:
        return 'Cao Cấp';
      case EquipmentRarity.rare:
        return 'Hiếm';
      case EquipmentRarity.epic:
        return 'Sử Thi';
      case EquipmentRarity.legendary:
        return 'Huyền Thoại';
    }
  }
}

class Equipment {
  final String id;
  final String name;
  final String description;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final int flatAtk;
  final int flatDef;
  final int flatHp;
  final double critRate;
  final double fireDmgPercent; // e.g. 0.30 = +30% Sát thương Lửa
  final double manaRegen;
  final Stats bonusStats;
  final String? iconAsset;
  final String emoji;
  final int sellPrice;
  final int upgradeLevel; // 0 to maxUpgradeLevel
  final String? setId; // Set bonus ID (viem_long, han_bang, loi_dinh, huyet_ma)
  final int? bonusSockets; // Bonus sockets (e.g. from crafting)
  final List<Gem> insertedGems;
  final List<EquipmentAffix> affixes;
  final int? lockedAffixIndex; // Index of locked affix during reforge

  const Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.slot,
    required this.rarity,
    this.flatAtk = 0,
    this.flatDef = 0,
    this.flatHp = 0,
    this.critRate = 0.0,
    this.fireDmgPercent = 0.0,
    this.manaRegen = 0.0,
    this.bonusStats = const Stats(str: 0, int_: 0, vit: 0, agi: 0, luk: 0),
    this.iconAsset,
    this.emoji = '🛡️',
    this.sellPrice = 50,
    this.upgradeLevel = 0,
    this.setId,
    this.bonusSockets,
    this.insertedGems = const [],
    this.affixes = const [],
    this.lockedAffixIndex,
  });

  /// Socket system rules:
  /// Common/Uncommon: 0
  /// Rare: 1
  /// Epic: 2
  /// Legendary/Mythic: 3
  /// Set items: +1 socket
  int get maxSockets {
    int base = 0;
    switch (rarity) {
      case EquipmentRarity.common:
      case EquipmentRarity.uncommon:
        base = 0;
        break;
      case EquipmentRarity.rare:
        base = 1;
        break;
      case EquipmentRarity.epic:
        base = 2;
        break;
      case EquipmentRarity.legendary:
        base = 3;
        break;
    }
    if (setId != null) base += 1;
    if (bonusSockets != null) base += bonusSockets!;
    return base;
  }

  // Socket Gem stat additions
  int get socketAtkBonus => insertedGems.fold(0, (acc, g) => acc + g.atkBonus);
  int get socketHpBonus => insertedGems.fold(0, (acc, g) => acc + g.hpBonus);
  int get socketDefBonus => insertedGems.fold(0, (acc, g) => acc + g.defBonus);
  double get socketCritBonus => insertedGems.fold(0.0, (acc, g) => acc + g.critBonus);
  double get socketManaRegenBonus => insertedGems.fold(0.0, (acc, g) => acc + g.manaRegenBonus);

  // Affix stat additions
  double get affixAtkPercent =>
      affixes.where((a) => a.type == AffixType.atkPercent).fold(0.0, (acc, a) => acc + a.value);
  double get affixHpPercent =>
      affixes.where((a) => a.type == AffixType.hpPercent).fold(0.0, (acc, a) => acc + a.value);
  double get affixCritDmgPercent =>
      affixes.where((a) => a.type == AffixType.critDmgPercent).fold(0.0, (acc, a) => acc + a.value);
  double get affixAttackSpeedPercent =>
      affixes.where((a) => a.type == AffixType.attackSpeedPercent).fold(0.0, (acc, a) => acc + a.value);
  double get affixElementalResistPercent =>
      affixes.where((a) => a.type == AffixType.elementalResistPercent).fold(0.0, (acc, a) => acc + a.value);
  double get affixLifestealPercent =>
      affixes.where((a) => a.type == AffixType.lifestealPercent).fold(0.0, (acc, a) => acc + a.value);

  int get maxUpgradeLevel =>
      (rarity == EquipmentRarity.epic || rarity == EquipmentRarity.legendary) ? 10 : 5;

  double get upgradeMultiplier => 1.0 + (upgradeLevel * 0.10);

  int get effectiveFlatAtk => (flatAtk * upgradeMultiplier).round() + socketAtkBonus;
  int get effectiveFlatDef => (flatDef * upgradeMultiplier).round() + socketDefBonus;
  int get effectiveFlatHp => (flatHp * upgradeMultiplier).round() + socketHpBonus;

  // Upgrade costs
  int get upgradeGoldCost => (sellPrice * 0.8 * (upgradeLevel + 1)).round() + 40;
  int get upgradeGemsCost => 1 + (upgradeLevel ~/ 2);

  Equipment copyWith({
    int? upgradeLevel,
    String? setId,
    int? bonusSockets,
    List<Gem>? insertedGems,
    List<EquipmentAffix>? affixes,
    int? lockedAffixIndex,
    bool clearLockedAffix = false,
  }) {
    return Equipment(
      id: id,
      name: name,
      description: description,
      slot: slot,
      rarity: rarity,
      flatAtk: flatAtk,
      flatDef: flatDef,
      flatHp: flatHp,
      critRate: critRate,
      fireDmgPercent: fireDmgPercent,
      manaRegen: manaRegen,
      bonusStats: bonusStats,
      iconAsset: iconAsset,
      emoji: emoji,
      sellPrice: sellPrice,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      setId: setId ?? this.setId,
      bonusSockets: bonusSockets ?? this.bonusSockets,
      insertedGems: insertedGems ?? this.insertedGems,
      affixes: affixes ?? this.affixes,
      lockedAffixIndex: clearLockedAffix ? null : (lockedAffixIndex ?? this.lockedAffixIndex),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'slot': slot.index,
        'rarity': rarity.index,
        'flatAtk': flatAtk,
        'flatDef': flatDef,
        'flatHp': flatHp,
        'critRate': critRate,
        'fireDmgPercent': fireDmgPercent,
        'manaRegen': manaRegen,
        'bonusStats': bonusStats.toJson(),
        'iconAsset': iconAsset,
        'emoji': emoji,
        'sellPrice': sellPrice,
        'upgradeLevel': upgradeLevel,
        'setId': setId,
        'bonusSockets': bonusSockets,
        'insertedGems': insertedGems.map((g) => g.toJson()).toList(),
        'affixes': affixes.map((a) => a.toJson()).toList(),
        'lockedAffixIndex': lockedAffixIndex,
      };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        slot: EquipmentSlot.values[json['slot'] as int? ?? 0],
        rarity: EquipmentRarity.values[json['rarity'] as int? ?? 0],
        flatAtk: json['flatAtk'] as int? ?? 0,
        flatDef: json['flatDef'] as int? ?? 0,
        flatHp: json['flatHp'] as int? ?? 0,
        critRate: (json['critRate'] as num?)?.toDouble() ?? 0.0,
        fireDmgPercent: (json['fireDmgPercent'] as num?)?.toDouble() ?? 0.0,
        manaRegen: (json['manaRegen'] as num?)?.toDouble() ?? 0.0,
        bonusStats: json['bonusStats'] != null
            ? Stats.fromJson(json['bonusStats'] as Map<String, dynamic>)
            : const Stats(str: 0, int_: 0, vit: 0, agi: 0, luk: 0),
        iconAsset: json['iconAsset'] as String?,
        emoji: json['emoji'] as String? ?? '🛡️',
        sellPrice: json['sellPrice'] as int? ?? 50,
        upgradeLevel: json['upgradeLevel'] as int? ?? 0,
        setId: json['setId'] as String?,
        bonusSockets: json['bonusSockets'] as int?,
        insertedGems: (json['insertedGems'] as List<dynamic>?)
                ?.map((e) => Gem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        affixes: (json['affixes'] as List<dynamic>?)
                ?.map((e) => EquipmentAffix.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        lockedAffixIndex: json['lockedAffixIndex'] as int?,
      );
}
