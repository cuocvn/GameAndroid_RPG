import 'package:flutter/material.dart';

enum ArenaTier {
  bronze('Đồng', Color(0xFFCD7F32), '🥉'),
  silver('Bạc', Color(0xFFB0BEC5), '🥈'),
  gold('Vàng', Color(0xFFFFD700), '🥇'),
  platinum('Bạch Kim', Color(0xFF00E5FF), '💎'),
  diamond('Kim Cương', Color(0xFF9C27B0), '💠'),
  master('Tinh Anh', Color(0xFFE040FB), '🔮'),
  grandmaster('Cao Thủ', Color(0xFFFF1744), '👑');

  final String label;
  final Color color;
  final String icon;
  const ArenaTier(this.label, this.color, this.icon);
}

class ArenaRankInfo {
  final ArenaTier tier;
  final int subRank; // 1, 2, 3 (1 is I, 2 is II, 3 is III) or 0 for grandmaster
  final int minAp;
  final int maxAp;
  final int currentAp;

  const ArenaRankInfo({
    required this.tier,
    required this.subRank,
    required this.minAp,
    required this.maxAp,
    required this.currentAp,
  });

  String get subRankRoman {
    if (tier == ArenaTier.grandmaster) return '';
    if (subRank == 1) return ' I';
    if (subRank == 2) return ' II';
    return ' III';
  }

  String get displayName => '${tier.label}$subRankRoman';

  /// Ratio within current tier (0.0 to 1.0)
  double get progressInTier {
    if (tier == ArenaTier.grandmaster) return 1.0;
    final span = maxAp - minAp + 1;
    if (span <= 0) return 1.0;
    return ((currentAp - minAp) / span).clamp(0.0, 1.0);
  }

  static ArenaRankInfo fromAp(int ap) {
    final clampedAp = ap < 0 ? 0 : ap;
    if (clampedAp >= 3500) {
      return ArenaRankInfo(
        tier: ArenaTier.grandmaster,
        subRank: 0,
        minAp: 3500,
        maxAp: 999999,
        currentAp: clampedAp,
      );
    }
    if (clampedAp >= 2000) {
      // 2000 - 3499 (span 1500 -> 500 each)
      final offset = clampedAp - 2000;
      final sub = offset < 500 ? 3 : (offset < 1000 ? 2 : 1);
      return ArenaRankInfo(
        tier: ArenaTier.master,
        subRank: sub,
        minAp: 2000,
        maxAp: 3499,
        currentAp: clampedAp,
      );
    }
    if (clampedAp >= 1000) {
      // 1000 - 1999 (span 1000 -> 333 each)
      final offset = clampedAp - 1000;
      final sub = offset < 333 ? 3 : (offset < 666 ? 2 : 1);
      return ArenaRankInfo(
        tier: ArenaTier.diamond,
        subRank: sub,
        minAp: 1000,
        maxAp: 1999,
        currentAp: clampedAp,
      );
    }
    if (clampedAp >= 500) {
      // 500 - 999 (span 500 -> 166 each)
      final offset = clampedAp - 500;
      final sub = offset < 166 ? 3 : (offset < 333 ? 2 : 1);
      return ArenaRankInfo(
        tier: ArenaTier.platinum,
        subRank: sub,
        minAp: 500,
        maxAp: 999,
        currentAp: clampedAp,
      );
    }
    if (clampedAp >= 250) {
      // 250 - 499 (span 250 -> 83 each)
      final offset = clampedAp - 250;
      final sub = offset < 83 ? 3 : (offset < 166 ? 2 : 1);
      return ArenaRankInfo(
        tier: ArenaTier.gold,
        subRank: sub,
        minAp: 250,
        maxAp: 499,
        currentAp: clampedAp,
      );
    }
    if (clampedAp >= 100) {
      // 100 - 249 (span 150 -> 50 each)
      final offset = clampedAp - 100;
      final sub = offset < 50 ? 3 : (offset < 100 ? 2 : 1);
      return ArenaRankInfo(
        tier: ArenaTier.silver,
        subRank: sub,
        minAp: 100,
        maxAp: 249,
        currentAp: clampedAp,
      );
    }
    // 0 - 99 (span 100 -> 33 each)
    final sub = clampedAp < 33 ? 3 : (clampedAp < 66 ? 2 : 1);
    return ArenaRankInfo(
      tier: ArenaTier.bronze,
      subRank: sub,
      minAp: 0,
      maxAp: 99,
      currentAp: clampedAp,
    );
  }
}

class TierReward {
  final int gold;
  final int gems;
  final String? gemReward;
  final String? title;

  const TierReward({
    this.gold = 0,
    this.gems = 0,
    this.gemReward,
    this.title,
  });

  static TierReward forTier(ArenaTier tier) {
    switch (tier) {
      case ArenaTier.bronze:
        return const TierReward(gold: 500);
      case ArenaTier.silver:
        return const TierReward(gold: 1000, gems: 2);
      case ArenaTier.gold:
        return const TierReward(gold: 2500, gems: 5, gemReward: 'ruby_2');
      case ArenaTier.platinum:
        return const TierReward(gold: 5000, gems: 10, gemReward: 'ruby_3');
      case ArenaTier.diamond:
      case ArenaTier.master:
        return const TierReward(gold: 10000, gems: 20, gemReward: 'ruby_4');
      case ArenaTier.grandmaster:
        return const TierReward(
          gold: 20000,
          gems: 50,
          gemReward: 'ruby_5',
          title: 'Cao Thủ Vô Song',
        );
    }
  }
}
