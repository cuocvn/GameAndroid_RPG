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

    // Base drop chance: Normal = 35%, Boss = 100% guaranteed
    double dropChance = enemy.isBoss ? 1.0 : 0.35 + (player.totalStats.luk * 0.005);
    if (_rng.nextDouble() > dropChance) {
      return drops;
    }

    // Determine rarity based on enemy zone, boss status, and player LUK
    EquipmentRarity rarity = _determineRarity(
      isBoss: enemy.isBoss,
      zone: enemy.zone,
      luk: player.totalStats.luk,
    );

    // Pick or generate equipment
    Equipment item = _generateOrPickItem(
      rarity: rarity,
      zone: enemy.zone,
      isBoss: enemy.isBoss,
    );
    drops.add(item);

    // If high zone boss, chance for a secondary drop!
    if (enemy.isBoss && enemy.zone >= 2 && _rng.nextDouble() < 0.45) {
      drops.add(_generateOrPickItem(
        rarity: EquipmentRarity.rare,
        zone: enemy.zone,
        isBoss: false,
      ));
    }

    return drops;
  }

  static EquipmentRarity _determineRarity({
    required bool isBoss,
    required int zone,
    required int luk,
  }) {
    double roll = _rng.nextDouble();
    // Bonus roll luck modifier (up to 0.15)
    double luckBonus = (luk * 0.003).clamp(0.0, 0.15);
    roll = (roll - luckBonus).clamp(0.0, 1.0);

    if (isBoss) {
      if (zone >= 4 && roll < 0.30) return EquipmentRarity.legendary;
      if (zone >= 2 && roll < 0.55) return EquipmentRarity.epic;
      if (roll < 0.85) return EquipmentRarity.rare;
      return EquipmentRarity.uncommon;
    } else {
      if (zone >= 4 && roll < 0.05) return EquipmentRarity.legendary;
      if (zone >= 3 && roll < 0.18) return EquipmentRarity.epic;
      if (zone >= 2 && roll < 0.40) return EquipmentRarity.rare;
      if (roll < 0.70) return EquipmentRarity.uncommon;
      return EquipmentRarity.common;
    }
  }

  static Equipment _generateOrPickItem({
    required EquipmentRarity rarity,
    required int zone,
    required bool isBoss,
  }) {
    // Check if we can pick from pre-defined list first
    final matchingPredefined = SeedEquipment.allPredefinedEquipment
        .where((e) => e.rarity == rarity)
        .toList();

    if (matchingPredefined.isNotEmpty && _rng.nextBool()) {
      final picked = matchingPredefined[_rng.nextInt(matchingPredefined.length)];
      // Give unique ID so duplicate drops can be held separately
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

    // Otherwise generate dynamic procedural equipment scaled to zone
    return _generateDynamicItem(rarity: rarity, zone: zone);
  }

  static Equipment _generateDynamicItem({
    required EquipmentRarity rarity,
    required int zone,
  }) {
    final slot = EquipmentSlot.values[_rng.nextInt(EquipmentSlot.values.length)];
    final multiplier = (zone * 1.5) + (rarity.index * 1.8);

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
      flatAtk = (20 * multiplier).round();
      critRate = (0.02 * rarity.index).clamp(0.0, 0.20);
      if (rarity.index >= 3) {
        fireDmgPercent = 0.10 + (rarity.index * 0.05);
      }
      bonusStats = Stats(
        str: (2 * multiplier).round(),
        int_: (3 * multiplier).round(),
        luk: (2 * rarity.index),
      );
    } else if (slot == EquipmentSlot.armor) {
      emoji = '🥋';
      itemName = '$namePrefix Giáp Hộ Thân Vùng $zone';
      flatHp = (60 * multiplier).round();
      flatDef = (6 * multiplier).round();
      bonusStats = Stats(
        vit: (3 * multiplier).round(),
        agi: (1 * multiplier).round(),
      );
    } else {
      emoji = '💍';
      itemName = '$namePrefix Nhẫn Cổ Ngữ Vùng $zone';
      manaRegen = 1.0 + (rarity.index * 0.8);
      critRate = (0.03 * rarity.index).clamp(0.0, 0.15);
      if (rarity.index >= 2) {
        fireDmgPercent = 0.08 + (rarity.index * 0.05);
      }
      bonusStats = Stats(
        int_: (2 * multiplier).round(),
        luk: (3 * multiplier).round(),
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
      sellPrice: (30 * multiplier).round(),
    );
  }
}
