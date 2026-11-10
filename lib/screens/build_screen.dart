import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../data/seed_skills.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/skill.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/equipment_card.dart';
import '../widgets/skill_card.dart';
import '../widgets/stat_row.dart';

class BuildScreen extends ConsumerStatefulWidget {
  const BuildScreen({super.key});

  @override
  ConsumerState<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends ConsumerState<BuildScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _inventoryFilterIndex = 0; // 0: All, 1: Weapon, 2: Armor, 3: Accessory

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final isEquipUnlocked = player.level >= 5;
    final isSkillUnlocked = player.level >= 4;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Text(
          'PHÁT TRIỂN NHÂN VẬT (BUILD)',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.goldAccent,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.goldButtonGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldAccent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('CHỈ SỐ'),
                      if (player.statPoints > 0) ...[
                        const SizedBox(width: 4),
                        _buildBadge('${player.statPoints}', AppTheme.redAccent),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isEquipUnlocked) const Text('🔒 ', style: TextStyle(fontSize: 11)),
                      Text(isEquipUnlocked ? 'TRANG BỊ' : 'TRANG BỊ (Lv.5)'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isSkillUnlocked) const Text('🔒 ', style: TextStyle(fontSize: 11)),
                      Text(isSkillUnlocked ? 'KỸ NĂNG' : 'KỸ NĂNG (Lv.4)'),
                      if (isSkillUnlocked && player.skillPoints > 0) ...[
                        const SizedBox(width: 4),
                        _buildBadge('${player.skillPoints}', AppTheme.redAccent),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(player),
          isEquipUnlocked
              ? _buildEquipmentTab(player)
              : _buildLockedTab('TRANG BỊ', 5, 'Chiến đấu vượt ải để lên Cấp 5 và mở khóa Trang bị + Cửa Hàng'),
          isSkillUnlocked
              ? _buildSkillsTab(player)
              : _buildLockedTab('KỸ NĂNG', 4, 'Chiến đấu vượt ải để lên Cấp 4 và mở khóa Bảng Kỹ Năng & Lựa chọn Build'),
        ],
      ),
    );
  }

  Widget _buildBadge(String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        count,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLockedTab(String title, int requiredLv, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.lock, size: 48, color: AppTheme.goldAccent),
            ),
            const SizedBox(height: 18),
            Text(
              'TÍNH NĂNG $title ĐANG KHÓA',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mở khóa ở Cấp độ $requiredLv',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: CHỈ SỐ (STATS) ---
  Widget _buildStatsTab(Player player) {
    final notifier = ref.read(playerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Available Points Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: player.statPoints > 0
                  ? AppTheme.goldAccent.withOpacity(0.6)
                  : Colors.white10,
              width: 1.2,
            ),
            boxShadow: [
              if (player.statPoints > 0)
                BoxShadow(
                  color: AppTheme.goldAccent.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm Chỉ Số Tự Do',
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nhận được +2 điểm mỗi khi lên cấp',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldButtonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '${player.statPoints}',
                  style: GoogleFonts.cinzel(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 5 Core Stats
        StatRow(
          label: 'STR',
          fullName: 'Sức Mạnh (Physical ATK)',
          baseValue: player.stats.str,
          totalValue: player.totalStats.str,
          description: 'Tăng sát thương vật lý (+2.5 ATK / điểm)',
          color: AppTheme.redAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('str'),
        ),
        StatRow(
          label: 'INT',
          fullName: 'Trí Tuệ (Magic ATK & Mana)',
          baseValue: player.stats.int_,
          totalValue: player.totalStats.int_,
          description: 'Tăng sát thương phép (+3.0 ATK / điểm) và Mana',
          color: AppTheme.purpleAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('int'),
        ),
        StatRow(
          label: 'VIT',
          fullName: 'Thể Lực (Max HP & DEF)',
          baseValue: player.stats.vit,
          totalValue: player.totalStats.vit,
          description: 'Tăng +15 Máu tối đa và +0.8 Giáp phòng thủ',
          color: AppTheme.greenAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('vit'),
        ),
        StatRow(
          label: 'AGI',
          fullName: 'Nhanh Nhẹn (Speed & Dodge)',
          baseValue: player.stats.agi,
          totalValue: player.totalStats.agi,
          description: 'Tăng tốc độ ra đòn đánh và +0.3% né đòn (max 40%)',
          color: AppTheme.cyanAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('agi'),
        ),
        StatRow(
          label: 'LUK',
          fullName: 'May Mắn (Crit & Drop Rate)',
          baseValue: player.stats.luk,
          totalValue: player.totalStats.luk,
          description: 'Tăng +0.5% tỉ lệ bạo kích (max 50%) và tỉ lệ rớt đồ xịn',
          color: AppTheme.goldAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('luk'),
        ),

        const SizedBox(height: 18),
        Text(
          'TỔNG HỢP NĂNG LỰC CHIẾN ĐẤU',
          style: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              _derivedRow('❤️ Máu tối đa (Max HP)', '${player.maxHp}', AppTheme.greenAccent),
              _derivedRow('💧 Mana tối đa', '${player.maxMana}', AppTheme.blueAccent),
              _derivedRow('🌀 Hồi phục Mana', '+${player.manaRegenPerSecond.toStringAsFixed(1)} / giây', Colors.lightBlueAccent),
              _derivedRow('⚔️ Sát thương Vật Lý', '${player.physicalAtk.round()}', AppTheme.redAccent),
              _derivedRow('🔮 Sát thương Phép Thuật', '${player.magicAtk.round()}', AppTheme.purpleAccent),
              _derivedRow('🛡️ Giáp phòng thủ (DEF)', player.physicalDef.toStringAsFixed(1), AppTheme.blueAccent),
              _derivedRow('⏱️ Giãn cách đòn đánh', '${player.attackInterval.toStringAsFixed(2)}s / lần', AppTheme.cyanAccent),
              _derivedRow('💥 Tỉ lệ chí mạng (Crit)', '${(player.critRate * 100).toStringAsFixed(1)}%', AppTheme.goldAccent),
              _derivedRow('⚡ Sát thương chí mạng', '${(player.critDamageMultiplier * 100).round()}% (Max 250%)', AppTheme.goldAccent),
              _derivedRow('💨 Tỉ lệ né tránh (Dodge)', '${(player.dodgeRate * 100).toStringAsFixed(1)}%', Colors.tealAccent),
              _derivedRow('🔥 Thưởng sát thương Lửa', '+${(player.fireDamageBonusPercent * 100).round()}%', Colors.deepOrangeAccent),
              _derivedRow('♨️ Thưởng đòn mục tiêu Cháy', '+${(player.burnTargetBonusPercent * 100).round()}%', Colors.orangeAccent),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _derivedRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- TAB 2: TRANG BỊ (EQUIPMENT) ---
  Widget _buildEquipmentTab(Player player) {
    final notifier = ref.read(playerProvider.notifier);

    List<Equipment> filteredInventory = player.inventory;
    if (_inventoryFilterIndex == 1) {
      filteredInventory = player.inventory.where((e) => e.slot == EquipmentSlot.weapon).toList();
    } else if (_inventoryFilterIndex == 2) {
      filteredInventory = player.inventory.where((e) => e.slot == EquipmentSlot.armor).toList();
    } else if (_inventoryFilterIndex == 3) {
      filteredInventory = player.inventory.where((e) => e.slot == EquipmentSlot.accessory).toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'TRANG BỊ ĐANG MẶC (3 Ô)',
          style: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
          ),
        ),
        const SizedBox(height: 8),

        // 3 Square Slot Visual Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSquareSlot(
              slotName: 'Vũ Khí',
              item: player.equippedWeapon,
              fallbackIcon: '⚔️',
              onTap: () {
                if (player.equippedWeapon != null) {
                  _showItemDetailSheet(player.equippedWeapon!, isEquipped: true);
                }
              },
            ),
            _buildSquareSlot(
              slotName: 'Giáp',
              item: player.equippedArmor,
              fallbackIcon: '🛡️',
              onTap: () {
                if (player.equippedArmor != null) {
                  _showItemDetailSheet(player.equippedArmor!, isEquipped: true);
                }
              },
            ),
            _buildSquareSlot(
              slotName: 'Phụ Kiện',
              item: player.equippedAccessory,
              fallbackIcon: '💍',
              onTap: () {
                if (player.equippedAccessory != null) {
                  _showItemDetailSheet(player.equippedAccessory!, isEquipped: true);
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Inventory Header & Quick Sell Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KHO ĐỒ (${player.inventory.length} MÓN)',
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
              ),
            ),
            Row(
              children: [
                Text(
                  '💎 ${player.gems}  •  🪙 ${player.gold}',
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                if (player.inventory.any((e) =>
                    e.rarity == EquipmentRarity.common ||
                    e.rarity == EquipmentRarity.uncommon))
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final earned = notifier.sellAllLowRarity();
                      if (earned > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã bán tất cả đồ thường: +$earned 🪙!')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.redAccent.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.redAccent.withOpacity(0.6), width: 1),
                      ),
                      child: const Text('Bán Đồ Thường', style: TextStyle(fontSize: 10, color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Inventory Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('Tất cả (${player.inventory.length})', 0),
              _filterChip('Vũ khí ⚔️', 1),
              _filterChip('Giáp 🛡️', 2),
              _filterChip('Phụ kiện 💍', 3),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (filteredInventory.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppTheme.surfaceGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Không có trang bị nào trong mục này.\nHãy vào Cửa Hàng hoặc chiến đấu càn quét quái để thu thập thêm!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, height: 1.4),
            ),
          )
        else
          ...filteredInventory.map((item) {
            return EquipmentCard(
              item: item,
              isEquipped: false,
              onEquip: () => notifier.equipItem(item),
              onUpgrade: () => _showUpgradeDialog(item, player),
              onSell: () => notifier.sellItem(item),
            );
          }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSquareSlot({
    required String slotName,
    required Equipment? item,
    required String fallbackIcon,
    required VoidCallback onTap,
  }) {
    final hasItem = item != null;
    final rarityColor = hasItem ? AppTheme.getRarityColor(item.rarity) : Colors.white24;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              gradient: AppTheme.surfaceGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasItem ? rarityColor : Colors.white12,
                width: hasItem ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (hasItem)
                  BoxShadow(
                    color: rarityColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasItem
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AssetMapping.safeImage(
                          item.iconAsset,
                          width: 82,
                          height: 82,
                          fallbackEmoji: item.emoji,
                        ),
                        Positioned(
                          bottom: 2,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${item.upgradeLevel}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        fallbackIcon,
                        style: const TextStyle(fontSize: 30, color: Colors.white24),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasItem ? item.name : slotName,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasItem ? rarityColor : Colors.white38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showItemDetailSheet(Equipment item, {required bool isEquipped}) {
    final notifier = ref.read(playerProvider.notifier);
    final rarityColor = AppTheme.getRarityColor(item.rarity);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0C18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: rarityColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${item.rarity.label} • ${item.slot.label}',
                          style: TextStyle(color: rarityColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isEquipped)
                    ElevatedButton(
                      onPressed: () {
                        notifier.unequipItem(item.slot);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
                      child: const Text('Tháo Ra', style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, int index) {
    final isSelected = _inventoryFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black : Colors.white70)),
        selected: isSelected,
        selectedColor: AppTheme.goldAccent,
        backgroundColor: AppTheme.bgSurface,
        onSelected: (val) {
          if (val) setState(() => _inventoryFilterIndex = index);
        },
      ),
    );
  }

  void _showUpgradeDialog(Equipment item, Player player) {
    final goldCost = item.upgradeGoldCost;
    final gemsCost = item.upgradeGemsCost;
    final canUpgrade = player.gold >= goldCost && player.gems >= gemsCost;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.2),
          ),
          title: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cường Hóa: ${item.name}',
                  style: GoogleFonts.cinzel(color: AppTheme.goldAccent, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cấp hiện tại: +${item.upgradeLevel} / +${item.maxUpgradeLevel}',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gia tăng sức mạnh:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        const Text('+10% chỉ số gốc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.greenAccent)),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chi phí Vàng:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        Text('$goldCost 🪙', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: player.gold >= goldCost ? AppTheme.goldAccent : AppTheme.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chi phí Đá Quý:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        Text('$gemsCost 💎', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: player.gems >= gemsCost ? AppTheme.blueAccent : AppTheme.redAccent)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: canUpgrade
                  ? () {
                      final success = ref.read(playerProvider.notifier).upgradeEquipment(item.id);
                      Navigator.pop(ctx);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('⚡ Cường hóa thành công [${item.name}] lên Cấp +${item.upgradeLevel + 1}!')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade ? AppTheme.goldAccent : Colors.grey.shade800,
              ),
              child: Text(
                canUpgrade ? 'Xác Nhận Nâng Cấp' : 'Không Đủ Tài Nguyên',
                style: TextStyle(
                  color: canUpgrade ? Colors.black : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 3: KỸ NĂNG (SKILLS) ---
  Widget _buildSkillsTab(Player player) {
    final notifier = ref.read(playerProvider.notifier);

    final basicSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.basic).toList();
    final activeSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.active).toList();
    final passiveSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.passive).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Skill Points Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: player.skillPoints > 0 ? AppTheme.purpleAccent.withOpacity(0.6) : Colors.white10,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm Kỹ Năng (Skill Points)',
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nhận được +1 điểm kỹ năng mỗi khi lên cấp',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), AppTheme.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${player.skillPoints}',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Equipped Combat Skills Bar
        Text(
          'KỸ NĂNG KÍCH HOẠT XUẤT TRẬN (${player.equippedSkillIds.length}/${player.unlockedSkillSlots})',
          style: GoogleFonts.cinzel(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(player.unlockedSkillSlots, (index) {
              if (index < player.equippedSkillIds.length) {
                final skillId = player.equippedSkillIds[index];
                final skill = SeedSkills.getById(skillId);
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.toggleEquipSkill(skillId);
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(skill.emoji, style: const TextStyle(fontSize: 22)),
                        Text(
                          skill.name,
                          style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Text('Trống', style: TextStyle(color: Colors.white30, fontSize: 10)),
                );
              }
            }),
          ),
        ),

        const SizedBox(height: 20),

        // SECTION 1: BASIC SKILLS
        _buildSkillSection('⚔️ KỸ NĂNG ĐÁNH THƯỜNG', basicSkills, player, notifier),

        const SizedBox(height: 16),
        // SECTION 2: ACTIVE SKILLS
        _buildSkillSection('🔥 KỸ NĂNG CHỦ ĐỘNG', activeSkills, player, notifier),

        const SizedBox(height: 16),
        // SECTION 3: PASSIVE SKILLS
        _buildSkillSection('✨ KỸ NĂNG BỊ ĐỘNG', passiveSkills, player, notifier),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSkillSection(
    String sectionTitle,
    List<Skill> skills,
    Player player,
    PlayerNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
          ),
        ),
        const SizedBox(height: 6),
        ...skills.map((skill) {
          final level = player.skillLevels[skill.id] ?? 0;
          final isEquipped = player.equippedSkillIds.contains(skill.id);

          return SkillCard(
            skill: skill,
            currentLevel: level,
            isEquippedForBattle: isEquipped,
            canUpgrade: player.skillPoints > 0,
            onUpgrade: () => notifier.upgradeSkill(skill.id),
            onToggleEquip: () => notifier.toggleEquipSkill(skill.id),
          );
        }),
      ],
    );
  }
}
