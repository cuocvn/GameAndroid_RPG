class SeasonMilestone {
  final int level; // 1 to 30
  final int requiredAp; // level * 100
  final String title;
  final String rewardDescription;
  final String icon;
  final int goldReward;
  final int diamondReward;
  final String? gemReward; // e.g. 'ruby_2', 'topaz_3', 'ruby_4', 'sapphire_5'
  final String? equipmentRarity; // 'rare', 'epic', 'set_piece'

  const SeasonMilestone({
    required this.level,
    required this.requiredAp,
    required this.title,
    required this.rewardDescription,
    required this.icon,
    this.goldReward = 0,
    this.diamondReward = 0,
    this.gemReward,
    this.equipmentRarity,
  });

  static List<SeasonMilestone> generateMilestones() {
    final list = <SeasonMilestone>[];

    for (int i = 1; i <= 30; i++) {
      final reqAp = i * 100;

      if (i <= 10) {
        // Milestones 1-10: Vàng + Kim Cương nhỏ
        final isDiamondMilestone = i % 2 == 0;
        final gold = 500 + i * 150;
        final gems = isDiamondMilestone ? (i ~/ 2) + 2 : 0;
        list.add(SeasonMilestone(
          level: i,
          requiredAp: reqAp,
          title: 'Mốc $i',
          rewardDescription: isDiamondMilestone ? '$gold Vàng + $gems 💎' : '$gold Vàng',
          icon: isDiamondMilestone ? '💎' : '💰',
          goldReward: gold,
          diamondReward: gems,
        ));
      } else if (i <= 20) {
        // Milestones 11-20: Gem cấp 2-3 + Đồ Rare
        final isEquipment = i == 15 || i == 20;
        final gemLvl = i <= 15 ? 2 : 3;
        final gemType = (i % 2 == 0) ? 'ruby_$gemLvl' : 'sapphire_$gemLvl';
        list.add(SeasonMilestone(
          level: i,
          requiredAp: reqAp,
          title: 'Mốc $i',
          rewardDescription: isEquipment
              ? 'Trang Bị Rare + 1000 Vàng'
              : 'Ngọc Cấp $gemLvl + 800 Vàng',
          icon: isEquipment ? '🛡️' : '🔮',
          goldReward: isEquipment ? 1000 : 800,
          diamondReward: isEquipment ? 5 : 2,
          gemReward: isEquipment ? null : gemType,
          equipmentRarity: isEquipment ? 'rare' : null,
        ));
      } else if (i <= 29) {
        // Milestones 21-29: Gem cấp 4 + Đồ Epic
        final isEquipment = i == 25 || i == 28;
        final gemType = (i % 3 == 0) ? 'ruby_4' : (i % 3 == 1 ? 'emerald_4' : 'topaz_4');
        list.add(SeasonMilestone(
          level: i,
          requiredAp: reqAp,
          title: 'Mốc $i',
          rewardDescription: isEquipment
              ? 'Trang Bị Epic + 2500 Vàng + 10 💎'
              : 'Ngọc Cấp 4 + 1500 Vàng',
          icon: isEquipment ? '⚔️' : '💠',
          goldReward: isEquipment ? 2500 : 1500,
          diamondReward: isEquipment ? 10 : 5,
          gemReward: isEquipment ? null : gemType,
          equipmentRarity: isEquipment ? 'epic' : null,
        ));
      } else {
        // Milestone 30: 1 Gem Legendary + 50 💎 + 1 trang bị Set piece ngẫu nhiên
        list.add(const SeasonMilestone(
          level: 30,
          requiredAp: 3000,
          title: 'Đỉnh Phong Mùa',
          rewardDescription: '1 Ngọc Cấp 5 + 50 💎 + 1 Set Piece Hoàng Kim!',
          icon: '👑',
          goldReward: 10000,
          diamondReward: 50,
          gemReward: 'ruby_5',
          equipmentRarity: 'set_piece',
        ));
      }
    }

    return list;
  }
}
