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

  /// Change character portrait / appearance and name
  void changePortrait(String portraitAsset, {String? name, String? title}) {
    state = state.copyWith(
      portraitAsset: portraitAsset,
      name: name ?? state.name,
      title: title ?? state.title,
    );
    _save();
  }

  /// Claim Quest / Achievement reward
  bool claimQuest(String questId, {int goldReward = 0, int gemsReward = 0}) {
    if (state.claimedQuestIds.contains(questId)) return false;
    final updated = List<String>.from(state.claimedQuestIds)..add(questId);
    state = state.copyWith(
      claimedQuestIds: updated,
      gold: state.gold + goldReward,
      gems: state.gems + gemsReward,
    );
    _save();
    return true;
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

  /// Resets all allocated stat points back to statPoints pool (Tẩy điểm chỉ số)
  bool respecStats({int goldCost = 50}) {
    if (state.gold < goldCost) return false;

    // Initial base stats: (str: 5, int_: 10, vit: 8, agi: 6, luk: 5)
    final allocatedStr = max(0, state.stats.str - 5);
    final allocatedInt = max(0, state.stats.int_ - 10);
    final allocatedVit = max(0, state.stats.vit - 8);
    final allocatedAgi = max(0, state.stats.agi - 6);
    final allocatedLuk = max(0, state.stats.luk - 5);

    final totalRefund = allocatedStr + allocatedInt + allocatedVit + allocatedAgi + allocatedLuk;
    if (totalRefund == 0 && state.statPoints > 0) return false;

    state = state.copyWith(
      gold: state.gold - goldCost,
      statPoints: state.statPoints + totalRefund,
      stats: const Stats(str: 5, int_: 10, vit: 8, agi: 6, luk: 5),
    );
    _save();
    return true;
  }

  /// Resets all upgraded skill points back to skillPoints pool (Tẩy điểm kỹ năng)
  bool respecSkills({int goldCost = 50}) {
    if (state.gold < goldCost) return false;

    int refundedPoints = 0;
    final updatedMap = <String, int>{};

    for (final entry in state.skillLevels.entries) {
      if (entry.value > 1) {
        refundedPoints += (entry.value - 1);
        updatedMap[entry.key] = 1;
      } else {
        updatedMap[entry.key] = entry.value;
      }
    }

    if (refundedPoints == 0) return false;

    state = state.copyWith(
      gold: state.gold - goldCost,
      skillPoints: state.skillPoints + refundedPoints,
      skillLevels: updatedMap,
    );
    _save();
    return true;
  }

  /// Calculates accumulated AFK rewards without claiming
  Map<String, dynamic> previewAfkRewards() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastClaim = state.lastAfkClaimTime > 0 ? state.lastAfkClaimTime : now;
    final diffMs = max(0, now - lastClaim);
    final elapsedMinutes = (diffMs / 60000).floor().clamp(0, 480); // max 8 hours

    final goldRate = 12 * state.maxUnlockedZone;
    final expRate = 20 * state.maxUnlockedZone;

    final earnedGold = elapsedMinutes * goldRate;
    final earnedExp = elapsedMinutes * expRate;
    final earnedGems = (elapsedMinutes / 120).floor().clamp(0, 4); // 1 gem per 2 hours

    return {
      'minutes': elapsedMinutes,
      'gold': earnedGold,
      'exp': earnedExp,
      'gems': earnedGems,
    };
  }

  /// Claims accumulated AFK rewards
  Map<String, dynamic>? claimAfkRewards() {
    final preview = previewAfkRewards();
    final minutes = preview['minutes'] as int;
    if (minutes < 1) return null;

    final gold = preview['gold'] as int;
    final exp = preview['exp'] as int;
    final gems = preview['gems'] as int;

    int newExp = state.currentExp + exp;
    int newLevel = state.level;
    int addedStatPoints = 0;
    int addedSkillPoints = 0;

    while (true) {
      final reqExp = newLevel * 100 + (newLevel * newLevel * 20);
      if (newExp >= reqExp) {
        newExp -= reqExp;
        newLevel++;
        addedStatPoints += 2;
        addedSkillPoints += 1;
      } else {
        break;
      }
    }

    state = state.copyWith(
      lastAfkClaimTime: DateTime.now().millisecondsSinceEpoch,
      gold: state.gold + gold,
      gems: state.gems + gems,
      level: newLevel,
      currentExp: newExp,
      statPoints: state.statPoints + addedStatPoints,
      skillPoints: state.skillPoints + addedSkillPoints,
    );
    _save();

    return preview;
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
    bool triggeredSpeedrun = false,
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

    // Map progression & Endless progression
    int newMaxZone = state.maxUnlockedZone;
    int newHighestEndless = state.highestEndlessFloor;

    if (foughtZone == 99) {
      if (foughtStage >= state.highestEndlessFloor) {
        newHighestEndless = foughtStage + 1;
      }
      // Endless mode bonus gems
      if (foughtStage % 5 == 0) {
        gainedGems += 2;
      } else {
        gainedGems = max(1, gainedGems);
      }
    } else {
      final zoneStages = SeedEnemies.getEnemiesForZone(foughtZone);
      if (foughtStage >= zoneStages.length) {
        if (foughtZone < 5 && foughtZone >= state.maxUnlockedZone) {
          newMaxZone = min(5, foughtZone + 1);
        }
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
      nextStageDifficultyBonus: triggeredSpeedrun ? 0.15 : 0.0,
      highestEndlessFloor: newHighestEndless,
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
