import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seed_enemies.dart';
import '../data/seed_skills.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/skill.dart';
import '../models/stats.dart';
import '../services/save_service.dart';

class MilestoneRewardResult {
  final String message;
  final String? unlockedSkillName;
  MilestoneRewardResult({required this.message, this.unlockedSkillName});
}

class PlayerNotifier extends Notifier<Player> {
  final Player? _initial;
  PlayerNotifier([this._initial]);

  @override
  Player build() {
    return _initial ?? const Player();
  }

  // --- Tutorial Markers ---
  void markTutorialHomeSeen() {
    if (!state.hasSeenTutorialHome) {
      state = state.copyWith(hasSeenTutorialHome: true);
      _save();
    }
  }

  void markTutorialFirstWinSeen() {
    if (!state.hasSeenTutorialFirstWin) {
      state = state.copyWith(hasSeenTutorialFirstWin: true);
      _save();
    }
  }

  void markTutorialFirstDropSeen() {
    if (!state.hasSeenTutorialFirstDrop) {
      state = state.copyWith(hasSeenTutorialFirstDrop: true);
      _save();
    }
  }

  /// Allocates 1 point into a chosen stat attribute
  void allocateStat(String statName) {
    if (state.statPoints <= 0) return;

    Stats newStats = state.stats;
    switch (statName.toLowerCase()) {
      case 'str':
        newStats = newStats.copyWith(str: newStats.str + 1);
        break;
      case 'int':
        newStats = newStats.copyWith(int_: newStats.int_ + 1);
        break;
      case 'vit':
        newStats = newStats.copyWith(vit: newStats.vit + 1);
        break;
      case 'agi':
        newStats = newStats.copyWith(agi: newStats.agi + 1);
        break;
      case 'luk':
        newStats = newStats.copyWith(luk: newStats.luk + 1);
        break;
      default:
        return;
    }

    state = state.copyWith(
      statPoints: state.statPoints - 1,
      stats: newStats,
    );
    _save();
  }

  /// Upgrades or unlocks a skill with 1 skill point
  void upgradeSkill(String skillId) {
    if (state.skillPoints <= 0) return;

    final currentLevel = state.skillLevels[skillId] ?? 0;
    final skill = SeedSkills.getById(skillId);
    if (currentLevel >= skill.maxLevel) return;

    final updatedMap = Map<String, int>.from(state.skillLevels);
    updatedMap[skillId] = currentLevel + 1;

    // Auto-equip if first time unlocking an active or basic skill and slots have room
    List<String> newEquipped = List.from(state.equippedSkillIds);
    if (skill.type != SkillType.passive && !newEquipped.contains(skillId)) {
      if (newEquipped.length < state.unlockedSkillSlots) {
        newEquipped.add(skillId);
      }
    }

    state = state.copyWith(
      skillPoints: state.skillPoints - 1,
      skillLevels: updatedMap,
      equippedSkillIds: newEquipped,
    );
    _save();
  }

  /// Toggles equipping an active or basic skill in battle bar
  void toggleEquipSkill(String skillId) {
    final skill = SeedSkills.getById(skillId);
    if (skill.type == SkillType.passive) return;

    final list = List<String>.from(state.equippedSkillIds);
    if (list.contains(skillId)) {
      if (list.length > 1) {
        list.remove(skillId);
      }
    } else {
      if (list.length < state.unlockedSkillSlots) {
        list.add(skillId);
      } else {
        list[list.length - 1] = skillId;
      }
    }

    state = state.copyWith(equippedSkillIds: list);
    _save();
  }

  /// Equips an item from inventory to its slot
  void equipItem(Equipment item) {
    final newInventory = List<Equipment>.from(state.inventory);
    newInventory.removeWhere((e) => e.id == item.id);

    Equipment? oldItem;
    switch (item.slot) {
      case EquipmentSlot.weapon:
        oldItem = state.equippedWeapon;
        state = state.copyWith(
          equippedWeapon: item,
          inventory: newInventory,
        );
        break;
      case EquipmentSlot.armor:
        oldItem = state.equippedArmor;
        state = state.copyWith(
          equippedArmor: item,
          inventory: newInventory,
        );
        break;
      case EquipmentSlot.accessory:
        oldItem = state.equippedAccessory;
        state = state.copyWith(
          equippedAccessory: item,
          inventory: newInventory,
        );
        break;
    }

    if (oldItem != null) {
      newInventory.add(oldItem);
      state = state.copyWith(inventory: newInventory);
    }

    _save();
  }

  /// Unequips an item from the given slot
  void unequipItem(EquipmentSlot slot) {
    final newInventory = List<Equipment>.from(state.inventory);
    switch (slot) {
      case EquipmentSlot.weapon:
        if (state.equippedWeapon != null) {
          newInventory.add(state.equippedWeapon!);
          state = state.copyWith(clearWeapon: true, inventory: newInventory);
        }
        break;
      case EquipmentSlot.armor:
        if (state.equippedArmor != null) {
          newInventory.add(state.equippedArmor!);
          state = state.copyWith(clearArmor: true, inventory: newInventory);
        }
        break;
      case EquipmentSlot.accessory:
        if (state.equippedAccessory != null) {
          newInventory.add(state.equippedAccessory!);
          state = state.copyWith(clearAccessory: true, inventory: newInventory);
        }
        break;
    }
    _save();
  }

  /// Sells an item from inventory for Gold
  void sellItem(Equipment item) {
    final newInventory = List<Equipment>.from(state.inventory);
    newInventory.removeWhere((e) => e.id == item.id);
    state = state.copyWith(
      gold: state.gold + item.sellPrice,
      inventory: newInventory,
    );
    _save();
  }

  /// Sells all Common & Uncommon items from inventory (QoL)
  int sellAllLowRarity() {
    final toSell = state.inventory
        .where((e) =>
            e.rarity == EquipmentRarity.common ||
            e.rarity == EquipmentRarity.uncommon)
        .toList();

    if (toSell.isEmpty) return 0;

    int totalEarned = 0;
    for (var item in toSell) {
      totalEarned += item.sellPrice;
    }

    final remaining = state.inventory
        .where((e) =>
            e.rarity != EquipmentRarity.common &&
            e.rarity != EquipmentRarity.uncommon)
        .toList();

    state = state.copyWith(
      gold: state.gold + totalEarned,
      inventory: remaining,
    );
    _save();
    return totalEarned;
  }

  /// Buys an item from the Shop
  bool buyShopItem(Equipment item, int price) {
    if (state.gold < price) return false;

    final newInventory = List<Equipment>.from(state.inventory)..add(item);
    state = state.copyWith(
      gold: state.gold - price,
      inventory: newInventory,
    );
    _save();
    return true;
  }

  /// Buys gems with Gold
  bool buyGems(int gemCount, int goldCost) {
    if (state.gold < goldCost) return false;

    state = state.copyWith(
      gold: state.gold - goldCost,
      gems: state.gems + gemCount,
    );
    _save();
    return true;
  }

  /// Upgrades an item in inventory or equipped slots
  bool upgradeEquipment(String itemId) {
    // Find item
    bool inEquippedWeapon = state.equippedWeapon?.id == itemId;
    bool inEquippedArmor = state.equippedArmor?.id == itemId;
    bool inEquippedAccessory = state.equippedAccessory?.id == itemId;

    Equipment? targetItem;
    if (inEquippedWeapon) targetItem = state.equippedWeapon;
    if (inEquippedArmor) targetItem = state.equippedArmor;
    if (inEquippedAccessory) targetItem = state.equippedAccessory;

    if (targetItem == null) {
      final idx = state.inventory.indexWhere((e) => e.id == itemId);
      if (idx != -1) targetItem = state.inventory[idx];
    }

    if (targetItem == null) return false;
    if (targetItem.upgradeLevel >= targetItem.maxUpgradeLevel) return false;

    final goldCost = targetItem.upgradeGoldCost;
    final gemsCost = targetItem.upgradeGemsCost;

    if (state.gold < goldCost || state.gems < gemsCost) return false;

    final upgraded = targetItem.copyWith(upgradeLevel: targetItem.upgradeLevel + 1);

    if (inEquippedWeapon) {
      state = state.copyWith(
        equippedWeapon: upgraded,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
      );
    } else if (inEquippedArmor) {
      state = state.copyWith(
        equippedArmor: upgraded,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
      );
    } else if (inEquippedAccessory) {
      state = state.copyWith(
        equippedAccessory: upgraded,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
      );
    } else {
      final newInv = List<Equipment>.from(state.inventory);
      final idx = newInv.indexWhere((e) => e.id == itemId);
      if (idx != -1) {
        newInv[idx] = upgraded;
        state = state.copyWith(
          inventory: newInv,
          gold: state.gold - goldCost,
          gems: state.gems - gemsCost,
        );
      }
    }

    _save();
    return true;
  }

  /// Receives battle victory rewards: EXP, Gold, dropped items & Milestone checks
  MilestoneRewardResult? onBattleVictory({
    required int exp,
    required int gold,
    required List<Equipment> drops,
    required int foughtZone,
    required int foughtStage,
  }) {
    int newExp = state.currentExp + exp;
    int newLevel = state.level;
    int addedStatPoints = 0;
    int addedSkillPoints = 0;

    // Level up check loop
    while (true) {
      final reqExp = newLevel * 100 + (newLevel * newLevel * 20);
      if (newExp >= reqExp) {
        newExp -= reqExp;
        newLevel++;
        addedStatPoints += 2; // +2 stat points per level (giới hạn sức mạnh người chơi)
        addedSkillPoints += 1; // +1 skill point per level
      } else {
        break;
      }
    }

    // Gem drop chance (100% on boss, 25% on normal)
    int gainedGems = 0;
    final isBoss = foughtStage >= SeedEnemies.getEnemiesForZone(foughtZone).length;
    if (isBoss) {
      gainedGems = 1 + (foughtZone ~/ 2);
    } else if (Random().nextDouble() < 0.25) {
      gainedGems = 1;
    }

    final newInventory = List<Equipment>.from(state.inventory)..addAll(drops);

    // Map progression
    int newMaxZone = state.maxUnlockedZone;
    final zoneStages = SeedEnemies.getEnemiesForZone(foughtZone);
    if (foughtStage >= zoneStages.length) {
      if (foughtZone < 5 && foughtZone >= state.maxUnlockedZone) {
        newMaxZone = min(5, foughtZone + 1);
      }
    }

    // Milestone tracking (first clear only)
    final stageKey = 'z${foughtZone}_s$foughtStage';
    final clearedList = List<String>.from(state.clearedStages);
    MilestoneRewardResult? milestoneResult;

    if (!clearedList.contains(stageKey)) {
      clearedList.add(stageKey);
      final uniqueClearedCount = clearedList.length;

      // Milestone 5: Unlock 1 random unowned active skill
      if (uniqueClearedCount == 5) {
        final unownedActive = SeedSkills.allSkills
            .where((s) => s.type == SkillType.active && (state.skillLevels[s.id] ?? 0) == 0)
            .toList();
        if (unownedActive.isNotEmpty) {
          final unlocked = unownedActive[Random().nextInt(unownedActive.length)];
          final updatedLevels = Map<String, int>.from(state.skillLevels);
          updatedLevels[unlocked.id] = 1;
          state = state.copyWith(skillLevels: updatedLevels);
          milestoneResult = MilestoneRewardResult(
            message: '⭐ MỐC 5 ẢI: Mở khóa kỹ năng chủ động mới!',
            unlockedSkillName: unlocked.name,
          );
        }
      }
      // Milestone 10: Unlock 1 random unowned passive skill
      else if (uniqueClearedCount == 10) {
        final unownedPassive = SeedSkills.allSkills
            .where((s) => s.type == SkillType.passive && (state.skillLevels[s.id] ?? 0) == 0)
            .toList();
        if (unownedPassive.isNotEmpty) {
          final unlocked = unownedPassive[Random().nextInt(unownedPassive.length)];
          final updatedLevels = Map<String, int>.from(state.skillLevels);
          updatedLevels[unlocked.id] = 1;
          state = state.copyWith(skillLevels: updatedLevels);
          milestoneResult = MilestoneRewardResult(
            message: '⭐ MỐC 10 ẢI: Mở khóa kỹ năng bị động mới!',
            unlockedSkillName: unlocked.name,
          );
        }
      }
      // Milestone 15: Unlock +1 Skill Slot (up to 5!)
      else if (uniqueClearedCount == 15) {
        state = state.copyWith(unlockedSkillSlots: 5);
        milestoneResult = MilestoneRewardResult(
          message: '⭐ MỐC 15 ẢI: Mở rộng thanh kỹ năng xuất trận lên 5 ô!',
          unlockedSkillName: '+1 Ô Kỹ Năng Xuất Trận',
        );
      }
      // Milestone 20: Unlock Ultimate Skill
      else if (uniqueClearedCount == 20) {
        final ultSkill = SeedSkills.getById('inferno_storm');
        final updatedLevels = Map<String, int>.from(state.skillLevels);
        updatedLevels[ultSkill.id] = 1;
        state = state.copyWith(skillLevels: updatedLevels);
        milestoneResult = MilestoneRewardResult(
          message: '⭐ MỐC 20 ẢI: Mở khóa Tuyệt Kỹ Tối Thượng!',
          unlockedSkillName: ultSkill.name,
        );
      }
    }

    state = state.copyWith(
      level: newLevel,
      currentExp: newExp,
      gold: state.gold + gold,
      gems: state.gems + gainedGems,
      statPoints: state.statPoints + addedStatPoints,
      skillPoints: state.skillPoints + addedSkillPoints,
      inventory: newInventory,
      maxUnlockedZone: newMaxZone,
      clearedStages: clearedList,
    );

    _save();
    return milestoneResult;
  }

  /// Selects zone and stage to challenge
  void selectZoneAndStage(int zone, int stage) {
    state = state.copyWith(
      currentZone: zone,
      currentStage: stage,
    );
    _save();
  }

  /// Changes hero portrait / appearance
  void changePortrait(String portraitAsset, {String? title}) {
    state = state.copyWith(
      portraitAsset: portraitAsset,
      title: title ?? state.title,
    );
    _save();
  }

  void resetProgress() async {
    await SaveService.clearSave();
    final fresh = await SaveService.loadPlayer();
    state = fresh;
  }

  void _save() {
    SaveService.savePlayer(state);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, Player>(() {
  return PlayerNotifier();
});
