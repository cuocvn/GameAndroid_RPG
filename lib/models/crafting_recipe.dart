import 'equipment.dart';

class CraftingRecipe {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final int goldCost;
  final int gemsCost;
  final Map<String, int> requiredMaterials; // 'iron', 'crystal', 'steel', 'essence'
  final EquipmentRarity targetRarity;
  final EquipmentSlot? targetSlot; // null means random slot
  final bool isSetPiece;
  final String emoji;

  const CraftingRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.goldCost,
    this.gemsCost = 0,
    required this.requiredMaterials,
    required this.targetRarity,
    this.targetSlot,
    this.isSetPiece = false,
    this.emoji = '⚒️',
  });

  static const List<CraftingRecipe> allRecipes = [
    CraftingRecipe(
      id: 'cr_uncommon_weapon',
      name: 'Vũ Khí Cao Cấp',
      description: 'Đúc vũ khí cơ bản từ Sắt Cổ bền bỉ.',
      requiredLevel: 5,
      goldCost: 200,
      requiredMaterials: {'iron': 5},
      targetRarity: EquipmentRarity.uncommon,
      targetSlot: EquipmentSlot.weapon,
      emoji: '⚔️',
    ),
    CraftingRecipe(
      id: 'cr_uncommon_armor',
      name: 'Giáp Cao Cấp',
      description: 'Rèn áo giáp chống đỡ đòn đánh quái vật.',
      requiredLevel: 8,
      goldCost: 300,
      requiredMaterials: {'iron': 7},
      targetRarity: EquipmentRarity.uncommon,
      targetSlot: EquipmentSlot.armor,
      emoji: '🥋',
    ),
    CraftingRecipe(
      id: 'cr_rare_armor',
      name: 'Giáp Hiếm Tinh Xảo',
      description: 'Giáp hộ thân tẩm tinh thể Pha Lê Ma Pháp.',
      requiredLevel: 10,
      goldCost: 500,
      requiredMaterials: {'iron': 10, 'crystal': 3},
      targetRarity: EquipmentRarity.rare,
      targetSlot: EquipmentSlot.armor,
      emoji: '🛡️',
    ),
    CraftingRecipe(
      id: 'cr_rare_weapon',
      name: 'Vũ Khí Hiếm Tinh Xảo',
      description: 'Vũ khí khắc phù chú ma pháp tăng uy lực sát thương.',
      requiredLevel: 12,
      goldCost: 700,
      requiredMaterials: {'iron': 12, 'crystal': 4},
      targetRarity: EquipmentRarity.rare,
      targetSlot: EquipmentSlot.weapon,
      emoji: '🗡️',
    ),
    CraftingRecipe(
      id: 'cr_epic_accessory',
      name: 'Phụ Kiện Sử Thi',
      description: 'Trang sức phong ấn kết tinh ma pháp và Hắc Kim.',
      requiredLevel: 15,
      goldCost: 1500,
      requiredMaterials: {'crystal': 15, 'steel': 2},
      targetRarity: EquipmentRarity.epic,
      targetSlot: EquipmentSlot.accessory,
      emoji: '💍',
    ),
    CraftingRecipe(
      id: 'cr_epic_weapon',
      name: 'Vũ Khí Sử Thi Cổ Ngữ',
      description: 'Tuyệt tác vũ khí rèn từ Hắc Kim ngàn năm.',
      requiredLevel: 20,
      goldCost: 3000,
      requiredMaterials: {'steel': 20, 'essence': 5},
      targetRarity: EquipmentRarity.epic,
      targetSlot: EquipmentSlot.weapon,
      emoji: '⚡',
    ),
    CraftingRecipe(
      id: 'cr_set_piece',
      name: 'Mảnh Trang Bị Bộ (Set)',
      description: 'Chế tạo ngẫu nhiên 1 món trang bị thuộc 4 Đại Thần Bộ (Viêm Long, Hàn Băng, Lôi Đình, Huyết Ma).',
      requiredLevel: 25,
      goldCost: 5000,
      requiredMaterials: {'essence': 10, 'steel': 2},
      targetRarity: EquipmentRarity.epic,
      isSetPiece: true,
      emoji: '🔮',
    ),
    CraftingRecipe(
      id: 'cr_legendary_random',
      name: 'Trang Bị Huyền Thoại',
      description: 'Bảo vật tối thượng chứa đựng sức mạnh vô biên của Ma Thần.',
      requiredLevel: 30,
      goldCost: 10000,
      gemsCost: 5,
      requiredMaterials: {'essence': 30},
      targetRarity: EquipmentRarity.legendary,
      emoji: '👑',
    ),
  ];
}
