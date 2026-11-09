import 'package:flutter/material.dart';
import 'stats.dart';

enum EquipmentSlot {
  weapon,
  armor,
  accessory,
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
  });

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
      );
}
