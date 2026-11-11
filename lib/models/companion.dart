import 'dart:math';

enum CompanionType {
  wolf('wolf', 'Sói Con', '🐺', 10, 'Tăng tốc độ đánh cơ bản', 0.05),
  eagle('eagle', 'Đại Bàng Lửa', '🦅', 15, 'Tăng sát thương kỹ năng Lửa', 0.08),
  dragon('dragon', 'Long Nhi', '🐉', 20, 'Tăng Máu tối đa (Max HP)', 0.10),
  fox('fox', 'Hồ Ly Tinh', '🦊', 25, 'Tăng tỉ lệ đánh chí mạng', 0.05),
  spirit('spirit', 'Oán Linh Nhỏ', '👻', 30, 'Tăng tỉ lệ hút máu khi tấn công', 0.05);

  final String id;
  final String name;
  final String icon;
  final int unlockLevel;
  final String description;
  final double basePassive;

  const CompanionType(
    this.id,
    this.name,
    this.icon,
    this.unlockLevel,
    this.description,
    this.basePassive,
  );

  /// Calculates effective passive bonus at a given companion level (Level 1..10)
  /// Guaranteed capped at max +30% (+0.30)
  double getEffectivePassive(int level) {
    final clampedLevel = level.clamp(1, 10);
    // Base + 2% per level above level 1
    final total = basePassive + (clampedLevel - 1) * 0.02;
    return min(0.30, total);
  }

  /// Required pet foods to upgrade to next level
  Map<String, int> getUpgradeCost(int currentLevel) {
    if (currentLevel >= 10) return const {};
    return {
      'meat': 10 * currentLevel,
      'herb': 5 * currentLevel,
      'beast_stone': 2 * currentLevel,
    };
  }

  static CompanionType? getById(String id) {
    for (final c in CompanionType.values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

class CompanionData {
  final CompanionType type;
  final int level;
  final bool isEquipped;

  const CompanionData({
    required this.type,
    this.level = 1,
    this.isEquipped = false,
  });

  double get passiveBonus => type.getEffectivePassive(level);

  String get passiveDisplayPercent =>
      '+${(passiveBonus * 100).toStringAsFixed(1)}%';
}
