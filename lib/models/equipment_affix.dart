import 'dart:math';

enum AffixType {
  atkPercent, // +X% ATK
  hpPercent, // +X% HP
  critDmgPercent, // +X% Crit DMG
  attackSpeedPercent, // +X% Tốc Đánh
  elementalResistPercent, // +X% Kháng Nguyên Tố
  lifestealPercent, // +X% Hút Máu
}

extension AffixTypeExtension on AffixType {
  String get label {
    switch (this) {
      case AffixType.atkPercent:
        return 'Sát Thương ATK';
      case AffixType.hpPercent:
        return 'Máu Tối Đa HP';
      case AffixType.critDmgPercent:
        return 'Sát Thương Chí Mạng';
      case AffixType.attackSpeedPercent:
        return 'Tốc Độ Đánh';
      case AffixType.elementalResistPercent:
        return 'Kháng Nguyên Tố';
      case AffixType.lifestealPercent:
        return 'Hút Máu';
    }
  }

  String get emoji {
    switch (this) {
      case AffixType.atkPercent:
        return '⚔️';
      case AffixType.hpPercent:
        return '❤️';
      case AffixType.critDmgPercent:
        return '💥';
      case AffixType.attackSpeedPercent:
        return '⚡';
      case AffixType.elementalResistPercent:
        return '🛡️';
      case AffixType.lifestealPercent:
        return '🩸';
    }
  }
}

class EquipmentAffix {
  final AffixType type;
  final double value; // e.g. 0.12 for +12%

  const EquipmentAffix({
    required this.type,
    required this.value,
  });

  String get description {
    final pct = (value * 100).toStringAsFixed(value * 100 == (value * 100).roundToDouble() ? 0 : 1);
    return '${type.emoji} +$pct% ${type.label}';
  }

  static EquipmentAffix rollRandom({List<AffixType> excludeTypes = const []}) {
    final rng = Random();
    final available = AffixType.values.where((t) => !excludeTypes.contains(t)).toList();
    final type = available.isEmpty
        ? AffixType.values[rng.nextInt(AffixType.values.length)]
        : available[rng.nextInt(available.length)];

    double val;
    switch (type) {
      case AffixType.atkPercent:
        val = 0.03 + rng.nextInt(13) * 0.01; // 3% - 15%
        break;
      case AffixType.hpPercent:
        val = 0.05 + rng.nextInt(16) * 0.01; // 5% - 20%
        break;
      case AffixType.critDmgPercent:
        val = 0.10 + rng.nextInt(26) * 0.01; // 10% - 35%
        break;
      case AffixType.attackSpeedPercent:
        val = 0.05 + rng.nextInt(11) * 0.01; // 5% - 15%
        break;
      case AffixType.elementalResistPercent:
        val = 0.05 + rng.nextInt(16) * 0.01; // 5% - 20%
        break;
      case AffixType.lifestealPercent:
        val = 0.02 + rng.nextInt(7) * 0.01; // 2% - 8%
        break;
    }

    return EquipmentAffix(type: type, value: double.parse(val.toStringAsFixed(2)));
  }

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'value': value,
      };

  factory EquipmentAffix.fromJson(Map<String, dynamic> json) => EquipmentAffix(
        type: AffixType.values[json['type'] as int? ?? 0],
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAffix && runtimeType == other.runtimeType && type == other.type && value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}
