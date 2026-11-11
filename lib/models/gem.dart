import 'package:flutter/material.dart';

enum GemType {
  ruby, // 🔴 Hồng Ngọc (+ATK)
  sapphire, // 🔵 Lam Ngọc (+Max HP)
  emerald, // 🟢 Lục Ngọc (+DEF)
  topaz, // 🟡 Hoàng Ngọc (+Crit rate)
  amethyst, // 🟣 Tím Ngọc (+Mana regen)
}

extension GemTypeExtension on GemType {
  String get nameVi {
    switch (this) {
      case GemType.ruby:
        return 'Hồng Ngọc';
      case GemType.sapphire:
        return 'Lam Ngọc';
      case GemType.emerald:
        return 'Lục Ngọc';
      case GemType.topaz:
        return 'Hoàng Ngọc';
      case GemType.amethyst:
        return 'Tím Ngọc';
    }
  }

  String get emoji {
    switch (this) {
      case GemType.ruby:
        return '🔴';
      case GemType.sapphire:
        return '🔵';
      case GemType.emerald:
        return '🟢';
      case GemType.topaz:
        return '🟡';
      case GemType.amethyst:
        return '🟣';
    }
  }

  Color get color {
    switch (this) {
      case GemType.ruby:
        return const Color(0xFFFF4B4B);
      case GemType.sapphire:
        return const Color(0xFF3B82F6);
      case GemType.emerald:
        return const Color(0xFF10B981);
      case GemType.topaz:
        return const Color(0xFFFBBF24);
      case GemType.amethyst:
        return const Color(0xFFA855F7);
    }
  }

  String get statLabel {
    switch (this) {
      case GemType.ruby:
        return 'ATK';
      case GemType.sapphire:
        return 'Max HP';
      case GemType.emerald:
        return 'DEF';
      case GemType.topaz:
        return 'Chí Mạng';
      case GemType.amethyst:
        return 'Hồi Mana';
    }
  }

  String get dropSource {
    switch (this) {
      case GemType.ruby:
        return 'Rơi từ quái, Shop';
      case GemType.sapphire:
        return 'Rơi từ quái, Tháp Vô Tận';
      case GemType.emerald:
        return 'Rơi từ quái, Shop';
      case GemType.topaz:
        return 'Boss Ải các Vùng';
      case GemType.amethyst:
        return 'Tháp Vô Tận tầng chẵn';
    }
  }
}

class Gem {
  final GemType type;
  final int level; // 1 to 5

  const Gem({
    required this.type,
    required this.level,
  }) : assert(level >= 1 && level <= 5, 'Gem level must be between 1 and 5');

  String get id => '${type.name}_$level';

  String get name => '${type.nameVi} Cấp $level';

  static const List<int> _rubyAtk = [5, 10, 15, 25, 40];
  static const List<int> _sapphireHp = [100, 200, 350, 550, 800];
  static const List<int> _emeraldDef = [3, 6, 10, 15, 25];
  static const List<double> _topazCrit = [0.02, 0.03, 0.04, 0.06, 0.08];
  static const List<double> _amethystManaRegen = [0.5, 1.0, 1.5, 2.5, 4.0];

  int get atkBonus => type == GemType.ruby ? _rubyAtk[level - 1] : 0;
  int get hpBonus => type == GemType.sapphire ? _sapphireHp[level - 1] : 0;
  int get defBonus => type == GemType.emerald ? _emeraldDef[level - 1] : 0;
  double get critBonus => type == GemType.topaz ? _topazCrit[level - 1] : 0.0;
  double get manaRegenBonus => type == GemType.amethyst ? _amethystManaRegen[level - 1] : 0.0;

  String get bonusDescription {
    switch (type) {
      case GemType.ruby:
        return '+$atkBonus ATK';
      case GemType.sapphire:
        return '+$hpBonus Max HP';
      case GemType.emerald:
        return '+$defBonus DEF';
      case GemType.topaz:
        return '+${(critBonus * 100).round()}% Crit';
      case GemType.amethyst:
        return '+${manaRegenBonus.toStringAsFixed(1)} Mana/s';
    }
  }

  int get upgradeGoldCost => 50 * level;

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'level': level,
      };

  factory Gem.fromJson(Map<String, dynamic> json) => Gem(
        type: GemType.values[json['type'] as int? ?? 0],
        level: json['level'] as int? ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gem && runtimeType == other.runtimeType && type == other.type && level == other.level;

  @override
  int get hashCode => type.hashCode ^ level.hashCode;
}
