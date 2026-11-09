import 'dart:math';
import '../data/seed_equipment.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/stats.dart';

class LootService {
  static final Random _rng = Random();

  /// Rolls for drops after defeating an enemy
  static List<Equipment> rollLoot({
    required Enemy enemy,
    required Player player,
  }) {
    List<Equipment> drops = [];

    // Base drop chance:
    // Normal = 18%, Boss = 100% (only 1 low-to-mid rarity item)
    // Tỉ lệ rơi cộng thêm theo LUK nhưng cap tổng ở 50% cho quái thường.
    double dropChance;
    if (enemy.isBoss) {
      dropChance = 1.0;
    } else {
      double baseChance = 0.18;
      double lukBonus = player.totalStats.luk * 0.003;
      dropChance = min(0.50, baseChance + lukBonus);
    }

    if (_rng.nextDouble() > dropChance) {
      return drops;
    }

    // Determine rarity:
    // Đồ Rare+ chỉ rơi từ boss ải 3 trở đi!
    EquipmentRarity rarity = _determineRarity(
      isBoss: enemy.isBoss,
      zone: enemy.zone,
      luk: player.totalStats.luk,
    );

    Equipment item = _generateOrPickItem(
      rarity: rarity,
      zone: enemy.zone,
      isBoss: enemy.isBoss,
    );
    drops.add(item);

    return drops;
  }

  static EquipmentRarity _determineRarity({
    required bool isBoss,
    required int zone,
    required int luk,
  }) {
    double roll = _rng.nextDouble();
    double luckBonus = (luk * 0.002).clamp(0.0, 0.10);
    roll = (roll - luckBonus).clamp(0.0, 1.0);

    if (isBoss) {
      // Boss ải 1 & 2: chỉ rơi Common hoặc Uncommon (thấp-trung bình)
      if (zone == 1) {
        return (roll < 0.35) ? EquipmentRarity.uncommon : EquipmentRarity.common;
      } else if (zone == 2) {
        return (roll < 0.50) ? EquipmentRarity.uncommon : EquipmentRarity.common;
      }
      // Đồ Rare+ CHỈ rơi từ boss ải 3 trở đi
      else if (zone == 3) {
        if (roll < 0.40) return EquipmentRarity.rare;
        return EquipmentRarity.uncommon;
      } else if (zone == 4) {
        if (roll < 0.25) return EquipmentRarity.epic;
        if (roll < 0.65) return EquipmentRarity.rare;
        return EquipmentRarity.uncommon;
      } else {
        // Zone 5 Boss (Diablo)
        if (roll < 0.35) return EquipmentRarity.legendary;
        if (roll < 0.70) return EquipmentRarity.epic;
        return EquipmentRarity.rare;
      }
    } else {
      // Quái thường: hầu hết là Common, một ít Uncommon ở zone cao. Không rơi Rare+.
      if (zone >= 4 && roll < 0.25) return EquipmentRarity.uncommon;
      if (zone >= 2 && roll < 0.15) return EquipmentRarity.uncommon;
      return EquipmentRarity.common;
    }
  }

  static Equipment _generateOrPickItem({
    required EquipmentRarity rarity,
    required int zone,
    required bool isBoss,
  }) {
    // Check predefined
    final matchingPredefined = SeedEquipment.allPredefinedEquipment
        .where((e) => e.rarity == rarity)
        .toList();

    if (matchingPredefined.isNotEmpty && _rng.nextBool()) {
      final picked = matchingPredefined[_rng.nextInt(matchingPredefined.length)];
      return Equipment(
        id: '${picked.id}_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}',
        name: picked.name,
        description: picked.description,
        slot: picked.slot,
        rarity: picked.rarity,
        flatAtk: picked.flatAtk,
        flatDef: picked.flatDef,
        flatHp: picked.flatHp,
        critRate: picked.critRate,
        fireDmgPercent: picked.fireDmgPercent,
        manaRegen: picked.manaRegen,
        bonusStats: picked.bonusStats,
        iconAsset: picked.iconAsset,
        emoji: picked.emoji,
        sellPrice: picked.sellPrice,
      );
    }

    return _generateDynamicItem(rarity: rarity, zone: zone);
  }

  static Equipment _generateDynamicItem({
    required EquipmentRarity rarity,
    required int zone,
  }) {
    final slot = EquipmentSlot.values[_rng.nextInt(EquipmentSlot.values.length)];
    final multiplier = (zone * 1.2) + (rarity.index * 1.4);

    String namePrefix = '';
    switch (rarity) {
      case EquipmentRarity.common:
        namePrefix = 'Đơn Sơ';
        break;
      case EquipmentRarity.uncommon:
        namePrefix = 'Tinh Chế';
        break;
      case EquipmentRarity.rare:
        namePrefix = 'Ma Thuật';
        break;
      case EquipmentRarity.epic:
        namePrefix = 'Thần Thánh';
        break;
      case EquipmentRarity.legendary:
        namePrefix = 'Tối Thượng';
        break;
    }

    String itemName = '';
    String emoji = '🛡️';
    int flatAtk = 0;
    int flatDef = 0;
    int flatHp = 0;
    double fireDmgPercent = 0.0;
    double critRate = 0.0;
    double manaRegen = 0.0;
    Stats bonusStats = const Stats(str: 0, int_: 0, vit: 0, agi: 0, luk: 0);

    if (slot == EquipmentSlot.weapon) {
      emoji = '⚔️';
      itemName = '$namePrefix Ma Trượng Vùng $zone';
      flatAtk = (12 * multiplier).round();
      critRate = (0.015 * rarity.index).clamp(0.0, 0.15);
      if (rarity.index >= 3) {
        fireDmgPercent = 0.08 + (rarity.index * 0.04);
      }
      bonusStats = Stats(
        str: (1 * multiplier).round(),
        int_: (2 * multiplier).round(),
        luk: rarity.index,
      );
    } else if (slot == EquipmentSlot.armor) {
      emoji = '🥋';
      itemName = '$namePrefix Giáp Hộ Thân Vùng $zone';
      flatHp = (40 * multiplier).round();
      flatDef = (4 * multiplier).round();
      bonusStats = Stats(
        vit: (2 * multiplier).round(),
        agi: (1 * multiplier).round(),
      );
    } else {
      emoji = '💍';
      itemName = '$namePrefix Nhẫn Cổ Ngữ Vùng $zone';
      manaRegen = 0.8 + (rarity.index * 0.6);
      critRate = (0.02 * rarity.index).clamp(0.0, 0.12);
      if (rarity.index >= 2) {
        fireDmgPercent = 0.05 + (rarity.index * 0.04);
      }
      bonusStats = Stats(
        int_: (1 * multiplier).round(),
        luk: (2 * multiplier).round(),
      );
    }

    return Equipment(
      id: 'item_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}',
      name: itemName,
      description: 'Trang bị quý rơi từ quái vật Vùng $zone. Mang sức mạnh nguyên tố ẩn tàng.',
      slot: slot,
      rarity: rarity,
      flatAtk: flatAtk,
      flatDef: flatDef,
      flatHp: flatHp,
      critRate: critRate,
      fireDmgPercent: fireDmgPercent,
      manaRegen: manaRegen,
      bonusStats: bonusStats,
      emoji: emoji,
      sellPrice: (25 * multiplier).round(),
    );
  }
}
