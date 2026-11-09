import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seed_enemies.dart';
import '../data/seed_skills.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/skill.dart';
import '../models/stats.dart';
import '../services/save_service.dart';

class PlayerNotifier extends Notifier<Player> {
  final Player? _initial;
  PlayerNotifier([this._initial]);

  @override
  Player build() {
    return _initial ?? const Player();
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
      if (newEquipped.length < 4) {
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
    if (skill.type == SkillType.passive) return; // Passives are always active

    final list = List<String>.from(state.equippedSkillIds);
    if (list.contains(skillId)) {
      if (list.length > 1) {
        // Must keep at least 1 skill equipped
        list.remove(skillId);
      }
    } else {
      if (list.length < 4) {
        list.add(skillId);
      } else {
        // Replace last
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

  /// Receives battle victory rewards: EXP, Gold, and dropped items
  void onBattleVictory({
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
        addedStatPoints += 3; // +3 stat points per level
        addedSkillPoints += 1; // +1 skill point per level
      } else {
        break;
      }
    }

    final newInventory = List<Equipment>.from(state.inventory)..addAll(drops);

    // Map progression
    int newMaxZone = state.maxUnlockedZone;
    final zoneStages = SeedEnemies.getEnemiesForZone(foughtZone);
    if (foughtStage >= zoneStages.length) {
      // Defeated boss!
      if (foughtZone < 5 && foughtZone >= state.maxUnlockedZone) {
        newMaxZone = min(5, foughtZone + 1);
      }
    }

    state = state.copyWith(
      level: newLevel,
      currentExp: newExp,
      gold: state.gold + gold,
      statPoints: state.statPoints + addedStatPoints,
      skillPoints: state.skillPoints + addedSkillPoints,
      inventory: newInventory,
      maxUnlockedZone: newMaxZone,
    );

    _save();
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
