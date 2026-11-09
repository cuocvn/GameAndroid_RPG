import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seed_skills.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../widgets/equipment_card.dart';
import '../widgets/skill_card.dart';
import '../widgets/stat_row.dart';

class BuildScreen extends ConsumerStatefulWidget {
  const BuildScreen({super.key});

  @override
  ConsumerState<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends ConsumerState<BuildScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _inventoryFilterIndex = 0; // 0: Tất cả, 1: Vũ khí, 2: Giáp, 3: Phụ kiện

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
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161520),
        title: const Text(
          'TÙY BIẾN CHIẾN THUẬT (BUILD)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('CHỈ SỐ'),
                  if (player.statPoints > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text('${player.statPoints}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isEquipUnlocked) const Text('🔒 ', style: TextStyle(fontSize: 11)),
                  Text(isEquipUnlocked ? 'TRANG BỊ (${player.inventory.length})' : 'TRANG BỊ (Lv.5)'),
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
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text('${player.skillPoints}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

  Widget _buildLockedTab(String title, int requiredLv, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.lock, size: 48, color: Colors.amberAccent),
            ),
            const SizedBox(height: 16),
            Text(
              'TÍNH NĂNG $title ĐANG KHÓA',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Mở khóa ở Cấp độ $requiredLv',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
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
        // Available Points Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade900.withOpacity(0.4), Colors.black45],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm Chỉ Số Tự Do',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    'Nhận được +2 điểm mỗi khi lên cấp',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${player.statPoints}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5 Core Stats
        StatRow(
          label: 'STR',
          fullName: 'Sức Mạnh (Physical ATK)',
          baseValue: player.stats.str,
          totalValue: player.totalStats.str,
          description: 'Tăng sát thương vật lý (+2.5 ATK / điểm)',
          color: Colors.redAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('str'),
        ),
        StatRow(
          label: 'INT',
          fullName: 'Trí Tuệ (Magic ATK & Mana)',
          baseValue: player.stats.int_,
          totalValue: player.totalStats.int_,
          description: 'Tăng sát thương phép (+3.0 ATK / điểm) và +2 Mana tối đa',
          color: Colors.purpleAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('int'),
        ),
        StatRow(
          label: 'VIT',
          fullName: 'Thể Lực (Max HP & DEF)',
          baseValue: player.stats.vit,
          totalValue: player.totalStats.vit,
          description: 'Tăng +10 Máu tối đa và +0.5 Giáp phòng thủ',
          color: Colors.greenAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('vit'),
        ),
        StatRow(
          label: 'AGI',
          fullName: 'Nhanh Nhẹn (Speed & Dodge)',
          baseValue: player.stats.agi,
          totalValue: player.totalStats.agi,
          description: 'Tăng tốc độ ra đòn đánh và +0.3% tỉ lệ né đòn (tối đa 40%)',
          color: Colors.tealAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('agi'),
        ),
        StatRow(
          label: 'LUK',
          fullName: 'May Mắn (Crit & Drop Rate)',
          baseValue: player.stats.luk,
          totalValue: player.totalStats.luk,
          description: 'Tăng +0.5% tỉ lệ bạo kích (tối đa 50%) và tỉ lệ rớt đồ xịn',
          color: Colors.amberAccent,
          canAllocate: player.statPoints > 0,
          onAllocate: () => notifier.allocateStat('luk'),
        ),

        const SizedBox(height: 20),
        const Text(
          'TỔNG HỢP NĂNG LỰC CHIẾN ĐẤU',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _derivedRow('❤️ Máu tối đa (Max HP)', '${player.maxHp}', Colors.greenAccent),
              _derivedRow('💧 Mana tối đa', '${player.maxMana}', Colors.cyanAccent),
              _derivedRow('🌀 Hồi phục Mana', '+${player.manaRegenPerSecond.toStringAsFixed(1)} / giây', Colors.lightBlueAccent),
              _derivedRow('⚔️ Sát thương Vật Lý', '${player.physicalAtk.round()}', Colors.orangeAccent),
              _derivedRow('🔮 Sát thương Phép Thuật', '${player.magicAtk.round()}', Colors.purpleAccent),
              _derivedRow('🛡️ Giáp phòng thủ (DEF)', '${player.physicalDef.toStringAsFixed(1)}', Colors.lightBlueAccent),
              _derivedRow('⏱️ Giãn cách đòn đánh', '${player.attackInterval.toStringAsFixed(2)}s / lần', Colors.tealAccent),
              _derivedRow('💥 Tỉ lệ chí mạng (Crit)', '${(player.critRate * 100).toStringAsFixed(1)}%', Colors.amberAccent),
              _derivedRow('⚡ Sát thương chí mạng', '${(player.critDamageMultiplier * 100).round()}%', Colors.amberAccent),
              _derivedRow('💨 Tỉ lệ né tránh (Dodge)', '${(player.dodgeRate * 100).toStringAsFixed(1)}%', Colors.cyanAccent),
              _derivedRow('🔥 Thưởng sát thương Lửa', '+${(player.fireDamageBonusPercent * 100).round()}%', Colors.redAccent),
              _derivedRow('♨️ Thưởng đòn mục tiêu Cháy', '+${(player.burnTargetBonusPercent * 100).round()}%', Colors.deepOrangeAccent),
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
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- TAB 2: TRANG BỊ (EQUIPMENT) ---
  Widget _buildEquipmentTab(Player player) {
    final notifier = ref.read(playerProvider.notifier);

    // Filter items
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
        const Text(
          'TRANG BỊ ĐANG MẶC (3 SLOTS)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 8),

        // Slot 1: Weapon
        if (player.equippedWeapon != null)
          EquipmentCard(
            item: player.equippedWeapon!,
            isEquipped: true,
            onUnequip: () => notifier.unequipItem(EquipmentSlot.weapon),
            onUpgrade: () => _showUpgradeDialog(player.equippedWeapon!, player),
          )
        else
          _emptySlot('Vũ Khí (Weapon)', 'Chưa trang bị vũ khí. Hãy chọn từ kho đồ.', '⚔️'),

        // Slot 2: Armor
        if (player.equippedArmor != null)
          EquipmentCard(
            item: player.equippedArmor!,
            isEquipped: true,
            onUnequip: () => notifier.unequipItem(EquipmentSlot.armor),
            onUpgrade: () => _showUpgradeDialog(player.equippedArmor!, player),
          )
        else
          _emptySlot('Giáp Hộ Thân (Armor)', 'Chưa mặc áo giáp. Hãy chọn từ kho đồ.', '🥋'),

        // Slot 3: Accessory
        if (player.equippedAccessory != null)
          EquipmentCard(
            item: player.equippedAccessory!,
            isEquipped: true,
            onUnequip: () => notifier.unequipItem(EquipmentSlot.accessory),
            onUpgrade: () => _showUpgradeDialog(player.equippedAccessory!, player),
          )
        else
          _emptySlot('Phụ Kiện (Accessory)', 'Chưa đeo phụ kiện/nhẫn. Hãy chọn từ kho đồ.', '💍'),

        const SizedBox(height: 20),

        // Inventory Header + Sell All Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KHO ĐỒ (${player.inventory.length} MÓN)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
            ),
            Row(
              children: [
                Text(
                  '💎 ${player.gems}  •  🪙 ${player.gold}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                if (player.inventory.any((e) =>
                    e.rarity == EquipmentRarity.common ||
                    e.rarity == EquipmentRarity.uncommon))
                  InkWell(
                    onTap: () {
                      final earned = notifier.sellAllLowRarity();
                      if (earned > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã bán tất cả đồ thường/cao cấp: +$earned 🪙!')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Bán đồ thường', style: TextStyle(fontSize: 10, color: Colors.amberAccent)),
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
        const SizedBox(height: 8),

        if (filteredInventory.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Không có trang bị nào trong mục này.\nHãy vào Cửa Hàng hoặc chiến đấu càn quét quái để thu thập thêm!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12),
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

  Widget _filterChip(String label, int index) {
    final isSelected = _inventoryFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black : Colors.white70)),
        selected: isSelected,
        selectedColor: Colors.amberAccent,
        backgroundColor: Colors.grey.shade900,
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
          backgroundColor: const Color(0xFF161520),
          title: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nâng Cấp: ${item.name}',
                  style: TextStyle(color: item.rarity.color, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cấp hiện tại: ${item.upgradeLevel} / ${item.maxUpgradeLevel}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chỉ số nhận thêm:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        const Text('+10% chỉ số gốc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chi phí Vàng:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        Text('$goldCost 🪙', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: player.gold >= goldCost ? Colors.amberAccent : Colors.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chi phí Đá Quý:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        Text('$gemsCost 💎', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: player.gems >= gemsCost ? Colors.cyanAccent : Colors.redAccent)),
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
                          SnackBar(content: Text('⚡ Nâng cấp thành công [${item.name}] lên Cấp ${item.upgradeLevel + 1}!')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade ? Colors.amber.shade700 : Colors.grey.shade800,
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

  Widget _emptySlot(String title, String subtitle, String icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 3: KỸ NĂNG (SKILLS) ---
  Widget _buildSkillsTab(Player player) {
    final notifier = ref.read(playerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Skill Points Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade900.withOpacity(0.4), Colors.black45],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm Kỹ Năng (Skill Points)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    'Nhận được +1 điểm kỹ năng mỗi khi lên cấp',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${player.skillPoints}',
                  style: const TextStyle(
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
          'KỸ NĂNG KÍCH HOẠT XUẤT TRẬN (Tối đa ${player.unlockedSkillSlots} ô)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(player.unlockedSkillSlots, (index) {
              if (index < player.equippedSkillIds.length) {
                final skillId = player.equippedSkillIds[index];
                final skill = SeedSkills.getById(skillId);
                return InkWell(
                  onTap: () => notifier.toggleEquipSkill(skillId),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: Column(
                      children: [
                        Text(skill.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(
                          skill.name,
                          style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  ),
                  child: const Text('Trống', style: TextStyle(color: Colors.white30, fontSize: 10)),
                );
              }
            }),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'TOÀN BỘ KỸ NĂNG (ĐÁNH THƯỜNG / CHỦ ĐỘNG / BỊ ĐỘNG)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        const SizedBox(height: 8),

        ...SeedSkills.allSkills.map((skill) {
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
        const SizedBox(height: 24),
      ],
    );
  }
}
