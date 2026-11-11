class PrestigeNode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int costPerLevel;
  final int maxLevel;

  const PrestigeNode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.costPerLevel,
    required this.maxLevel,
  });
}

class PrestigeNodeData {
  static const List<PrestigeNode> allNodes = [
    PrestigeNode(
      id: 'enlighten_exp',
      name: 'Khai Sáng',
      description: '+10% EXP nhận được sau trận',
      icon: '✨',
      costPerLevel: 2,
      maxLevel: 5,
    ),
    PrestigeNode(
      id: 'enlighten_gold',
      name: 'Tài Lộc',
      description: '+10% Vàng nhận được sau trận',
      icon: '💰',
      costPerLevel: 2,
      maxLevel: 5,
    ),
    PrestigeNode(
      id: 'ancient_power',
      name: 'Sức Mạnh Cổ Đại',
      description: '+5% tất cả chỉ số (STR/INT/VIT/AGI/LUK)',
      icon: '⚡',
      costPerLevel: 3,
      maxLevel: 10,
    ),
    PrestigeNode(
      id: 'treasure_slot',
      name: 'Kho Báu',
      description: '+1 slot trang bị bán trong cửa hàng',
      icon: '🎁',
      costPerLevel: 5,
      maxLevel: 1,
    ),
    PrestigeNode(
      id: 'swift_speed',
      name: 'Tốc Độ',
      description: '+10% tốc độ đánh cơ bản',
      icon: '💨',
      costPerLevel: 4,
      maxLevel: 5,
    ),
    PrestigeNode(
      id: 'fortune_luck',
      name: 'May Mắn',
      description: '+5% tỉ lệ rơi trang bị phẩm Rare trở lên',
      icon: '🍀',
      costPerLevel: 3,
      maxLevel: 5,
    ),
    PrestigeNode(
      id: 'tenacity_hp',
      name: 'Bền Bỉ',
      description: '+15% Máu tối đa (Max HP)',
      icon: '🛡️',
      costPerLevel: 3,
      maxLevel: 5,
    ),
    PrestigeNode(
      id: 'fresh_start',
      name: 'Khởi Đầu',
      description: 'Bắt đầu chuyển sinh với +5 điểm chỉ số',
      icon: '🌱',
      costPerLevel: 4,
      maxLevel: 3,
    ),
    PrestigeNode(
      id: 'divine_aura',
      name: 'Hào Quang',
      description: '+1 ô kỹ năng xuất trận (tối đa 6 ô)',
      icon: '☀️',
      costPerLevel: 8,
      maxLevel: 1,
    ),
    PrestigeNode(
      id: 'immortality',
      name: 'Bất Tử',
      description: 'Hồi sinh 1 lần mỗi trận đấu với 50% HP',
      icon: '💖',
      costPerLevel: 15,
      maxLevel: 1,
    ),
  ];

  static PrestigeNode? getById(String id) {
    try {
      return allNodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
