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
              child: Text('TRANG BỊ (${player.inventory.length})'),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('KỸ NĂNG'),
                  if (player.skillPoints > 0) ...[
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
          _buildEquipmentTab(player),
          _buildSkillsTab(player),
        ],
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
                    'Nhận được +3 điểm mỗi khi lên cấp',
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

        // Derived Battle Stats Breakdown
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
          )
        else
          _emptySlot('Vũ Khí (Weapon)', 'Chưa trang bị vũ khí. Hãy chọn từ kho đồ.', '⚔️'),

        // Slot 2: Armor
        if (player.equippedArmor != null)
          EquipmentCard(
            item: player.equippedArmor!,
            isEquipped: true,
            onUnequip: () => notifier.unequipItem(EquipmentSlot.armor),
          )
        else
          _emptySlot('Giáp Hộ Thân (Armor)', 'Chưa mặc áo giáp. Hãy chọn từ kho đồ.', '🥋'),

        // Slot 3: Accessory
        if (player.equippedAccessory != null)
          EquipmentCard(
            item: player.equippedAccessory!,
            isEquipped: true,
            onUnequip: () => notifier.unequipItem(EquipmentSlot.accessory),
          )
        else
          _emptySlot('Phụ Kiện (Accessory)', 'Chưa đeo phụ kiện/nhẫn. Hãy chọn từ kho đồ.', '💍'),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TÚI ĐỒ / KHO TRANG BỊ (${player.inventory.length} MÓN)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
            ),
            Text(
              '🪙 ${player.gold} Vàng',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (player.inventory.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Kho đồ đang trống.\nHãy vào chiến đấu càn quét quái vật và Boss để nhặt trang bị quý!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          )
        else
          ...player.inventory.map((item) {
            return EquipmentCard(
              item: item,
              isEquipped: false,
              onEquip: () => notifier.equipItem(item),
              onSell: () => notifier.sellItem(item),
            );
          }),
        const SizedBox(height: 24),
      ],
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
        const Text(
          'KỸ NĂNG KÍCH HOẠT TRONG TRẬN ĐẤU (Tối đa 4)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
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
            children: List.generate(4, (index) {
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
                        Text(skill.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 2),
                        Text(
                          skill.name,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
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
          'DANH SÁCH TOÀN BỘ KỸ NĂNG',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
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
