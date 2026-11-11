import 'dart:math';
import '../data/seed_equipment.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/equipment_affix.dart';
import '../models/gem.dart';
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
    // Đồ Rare+ chỉ rơi từ boss ải 3 trở đi hoặc Endless tầng 10+!
    final fortuneBonus = (player.prestigeNodeLevels['fortune_luck'] ?? 0) * 0.05;
    EquipmentRarity rarity = _determineRarity(
      isBoss: enemy.isBoss,
      zone: enemy.zone,
      stage: enemy.stage,
      luk: player.totalStats.luk,
      fortuneBonus: fortuneBonus,
    );

    Equipment item = _generateOrPickItem(
      rarity: rarity,
      zone: enemy.zone,
      stage: enemy.stage,
      isBoss: enemy.isBoss,
    );
    drops.add(item);

    return drops;
  }

  static EquipmentRarity _determineRarity({
    required bool isBoss,
    required int zone,
    required int stage,
    required int luk,
    double fortuneBonus = 0.0,
  }) {
    double roll = _rng.nextDouble();
    double luckBonus = (luk * 0.002 + fortuneBonus).clamp(0.0, 0.25);
    roll = (roll - luckBonus).clamp(0.0, 1.0);

    // Endless Mode: Đồ Rare+ CHỈ rơi từ Endless tầng 10+!
    if (zone == 99) {
      if (stage < 10) {
        return (roll < 0.40) ? EquipmentRarity.uncommon : EquipmentRarity.common;
      } else if (stage < 20) {
        if (roll < 0.35) return EquipmentRarity.rare;
        return (roll < 0.70) ? EquipmentRarity.uncommon : EquipmentRarity.common;
      } else if (stage < 30) {
        if (roll < 0.25) return EquipmentRarity.epic;
        if (roll < 0.65) return EquipmentRarity.rare;
        return EquipmentRarity.uncommon;
      } else {
        if (roll < 0.40) return EquipmentRarity.legendary;
        return EquipmentRarity.epic;
      }
    }

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

  static List<EquipmentAffix> rollAffixesForRarity(EquipmentRarity rarity) {
    if (rarity == EquipmentRarity.common || rarity == EquipmentRarity.uncommon) {
      return const [];
    }
    final int count = rarity == EquipmentRarity.rare ? 1 : 2;
    final List<EquipmentAffix> list = [];
    final List<AffixType> exclude = [];
    for (int i = 0; i < count; i++) {
      final a = EquipmentAffix.rollRandom(excludeTypes: exclude);
      list.add(a);
      exclude.add(a.type);
    }
    return list;
  }

  static List<Gem> rollGems({
    required Enemy enemy,
    required Player player,
  }) {
    final List<Gem> gems = [];
    // 1. Zone Bosses: 70% chance to drop Topaz (Crit gem)
    if (enemy.isBoss && enemy.zone != 99) {
      if (_rng.nextDouble() < 0.70) {
        final lvl = enemy.zone >= 4 ? (_rng.nextBool() ? 2 : 1) : 1;
        gems.add(Gem(type: GemType.topaz, level: lvl));
      }
    }

    // 2. Endless mode even floors: 50% chance to drop Amethyst (Mana regen gem)
    if (enemy.zone == 99 && enemy.stage % 2 == 0) {
      if (_rng.nextDouble() < 0.50) {
        final lvl = enemy.stage >= 20 ? (_rng.nextBool() ? 2 : 1) : 1;
        gems.add(Gem(type: GemType.amethyst, level: lvl));
      }
    }

    // 3. Regular monster drops (Ruby, Sapphire, Emerald) - 15% chance
    if (_rng.nextDouble() < 0.15) {
      final pool = [GemType.ruby, GemType.sapphire, GemType.emerald];
      final pickedType = pool[_rng.nextInt(pool.length)];
      int lvl = 1;
      if (enemy.zone == 5 || (enemy.zone == 99 && enemy.stage >= 15)) {
        if (_rng.nextDouble() < 0.20) lvl = 2;
      }
      gems.add(Gem(type: pickedType, level: lvl));
    }

    return gems;
  }

  static Map<String, int> rollCraftingMaterials({
    required Enemy enemy,
    required Player player,
  }) {
    final Map<String, int> mats = {};

    // Sắt Cổ (iron) - Zone 1-2 (45% chance for 1-2)
    if (enemy.zone == 1 || enemy.zone == 2) {
      if (_rng.nextDouble() < 0.45) {
        mats['iron'] = 1 + (_rng.nextBool() ? 1 : 0);
      }
    }

    // Pha Lê Ma Pháp (crystal) - Zone 3-4 (40% chance for 1-2)
    if (enemy.zone == 3 || enemy.zone == 4) {
      if (_rng.nextDouble() < 0.40) {
        mats['crystal'] = 1 + (_rng.nextBool() ? 1 : 0);
      }
    }

    // Hắc Kim (steel) - Zone 5 or Endless 10+ (35% chance for 1-2)
    if (enemy.zone == 5 || (enemy.zone == 99 && enemy.stage >= 10)) {
      if (_rng.nextDouble() < 0.35) {
        mats['steel'] = 1 + (_rng.nextBool() ? 1 : 0);
      }
    }

    // Tinh Hoa Hỗn Mang (essence) - Bosses or Endless 20+ (30% chance for 1)
    if (enemy.isBoss || (enemy.zone == 99 && enemy.stage >= 20)) {
      if (_rng.nextDouble() < 0.30) {
        mats['essence'] = 1;
      }
    }

    return mats;
  }

  static Equipment _generateOrPickItem({
    required EquipmentRarity rarity,
    required int zone,
    required int stage,
    required bool isBoss,
  }) {
    // Set pieces drop condition: Boss from Zone 2+ OR Endless even floors
    String? targetSetId;
    if (isBoss) {
      if (zone == 2) targetSetId = 'viem_long';
      if (zone == 3) targetSetId = 'han_bang';
      if (zone == 4) targetSetId = 'loi_dinh';
      if (zone == 5) targetSetId = 'huyet_ma';
    } else if (zone == 99 && stage % 2 == 0) {
      final sets = ['viem_long', 'han_bang', 'loi_dinh', 'huyet_ma'];
      targetSetId = sets[_rng.nextInt(sets.length)];
    }

    if (targetSetId != null && _rng.nextDouble() < 0.50) {
      final setPieces = SeedEquipment.allPredefinedEquipment
          .where((e) => e.setId == targetSetId)
          .toList();
      if (setPieces.isNotEmpty) {
        final picked = setPieces[_rng.nextInt(setPieces.length)];
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
          upgradeLevel: 0,
          setId: picked.setId,
          affixes: rollAffixesForRarity(picked.rarity),
        );
      }
    }

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
        upgradeLevel: 0,
        setId: picked.setId,
        affixes: rollAffixesForRarity(picked.rarity),
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
      affixes: rollAffixesForRarity(rarity),
    );
  }
}
