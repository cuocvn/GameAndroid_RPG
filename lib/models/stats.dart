import 'dart:math';

/// Character 5 core attributes: STR, INT, VIT, AGI, LUK
class Stats {
  final int str; // Sát thương vật lý
  final int int_; // Sát thương phép & Mana max
  final int vit; // HP & DEF
  final int agi; // Tốc độ đánh & Né tránh
  final int luk; // Chí mạng & May mắn

  const Stats({
    this.str = 5,
    this.int_ = 10,
    this.vit = 8,
    this.agi = 6,
    this.luk = 5,
  });

  Stats copyWith({
    int? str,
    int? int_,
    int? vit,
    int? agi,
    int? luk,
  }) {
    return Stats(
      str: str ?? this.str,
      int_: int_ ?? this.int_,
      vit: vit ?? this.vit,
      agi: agi ?? this.agi,
      luk: luk ?? this.luk,
    );
  }

  Stats operator +(Stats other) {
    return Stats(
      str: str + other.str,
      int_: int_ + other.int_,
      vit: vit + other.vit,
      agi: agi + other.agi,
      luk: luk + other.luk,
    );
  }

  // --- Derived combat calculations ---

  /// Base Max HP: VIT * 10 + 100
  int get maxHp => vit * 10 + 100;

  /// Physical defense: VIT * 0.5
  double get physicalDef => vit * 0.5;

  /// Max Mana: 100 + INT * 2
  int get maxMana => 100 + int_ * 2;

  /// Crit chance: LUK * 0.5%, capped at 50% (0.50)
  double get critRate => min(0.50, luk * 0.005);

  /// Dodge chance: AGI * 0.3%, capped at 40% (0.40)
  double get dodgeRate => min(0.40, agi * 0.003);

  /// Attack interval in seconds: based on AGI. Higher AGI = faster attacks.
  /// Base is 1.6s, down to min 0.5s.
  double get attackInterval => max(0.5, 1.6 / (1.0 + (agi * 0.035)));

  Map<String, dynamic> toJson() => {
        'str': str,
        'int': int_,
        'vit': vit,
        'agi': agi,
        'luk': luk,
      };

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        str: json['str'] as int? ?? 5,
        int_: json['int'] as int? ?? 10,
        vit: json['vit'] as int? ?? 8,
        agi: json['agi'] as int? ?? 6,
        luk: json['luk'] as int? ?? 5,
      );
}
