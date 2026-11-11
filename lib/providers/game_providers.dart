import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/seed_enemies.dart';
import '../data/seed_equipment.dart';
import '../data/seed_skills.dart';
import '../models/arena_match_record.dart';
import '../models/arena_opponent.dart';
import '../models/arena_rank.dart';
import '../models/companion.dart';
import '../models/crafting_recipe.dart';
import '../models/equipment.dart';
import '../models/equipment_affix.dart';
import '../models/gem.dart';
import '../models/hero_story.dart';
import '../models/player.dart';
import '../models/prestige_node.dart';
import '../models/raid_boss.dart';
import '../models/season_pass.dart';
import '../models/skill.dart';
import '../models/stats.dart';
import '../models/virtual_leaderboard.dart';
import '../services/loot_service.dart';
import '../services/save_service.dart';

class MilestoneRewardResult {
  final String message;
  final String? unlockedSkillName;
  MilestoneRewardResult({required this.message, this.unlockedSkillName});
}

class ArenaBattleEndResult {
  final bool isWon;
  final int apChange;
  final int newAp;
  final int earnedGold;
  final int earnedDiamonds;
  final String? droppedGem;
  final bool triggeredStreakBonus;
  final int currentStreak;

  const ArenaBattleEndResult({
    required this.isWon,
    required this.apChange,
    required this.newAp,
    required this.earnedGold,
    this.earnedDiamonds = 0,
    this.droppedGem,
    this.triggeredStreakBonus = false,
    this.currentStreak = 0,
  });
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
  void changePortrait(String portraitAsset, {String? name, String? title, String? heroId}) {
    String resolvedHeroId = heroId ?? state.currentHeroId;
    if (heroId == null) {
      for (final story in HeroStory.allStories) {
        if (story.avatarAsset == portraitAsset) {
          resolvedHeroId = story.heroId;
          break;
        }
      }
    }

    final updatedHeroProgress = Map<String, int>.from(state.heroLevelProgress);
    if (!updatedHeroProgress.containsKey(resolvedHeroId)) {
      updatedHeroProgress[resolvedHeroId] = state.level;
    }

    state = state.copyWith(
      portraitAsset: portraitAsset,
      name: name ?? state.name,
      title: title ?? state.title,
      currentHeroId: resolvedHeroId,
      heroLevelProgress: updatedHeroProgress,
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

  /// Buys a socket gem (e.g. Ruby, Emerald) from Shop with Gold
  bool buyGem(Gem gem, int price) {
    if (state.gold < price) return false;
    final newGemInv = Map<String, int>.from(state.gemInventory);
    newGemInv[gem.id] = (newGemInv[gem.id] ?? 0) + 1;
    state = state.copyWith(
      gold: state.gold - price,
      gemInventory: newGemInv,
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
    final expMultiplier = 1.0 + (state.prestigeNodeLevels['enlighten_exp'] ?? 0) * 0.10;
    final goldMultiplier = 1.0 + (state.prestigeNodeLevels['enlighten_gold'] ?? 0) * 0.10;
    final effectiveExp = (exp * expMultiplier).round();
    final effectiveGold = (gold * goldMultiplier).round();

    int newExp = state.currentExp + effectiveExp;
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

    final droppedGems = LootService.rollGems(
      enemy: SeedEnemies.getEnemy(foughtZone, foughtStage),
      player: state,
    );
    final droppedMaterials = LootService.rollCraftingMaterials(
      enemy: SeedEnemies.getEnemy(foughtZone, foughtStage),
      player: state,
    );

    final updatedGemInv = Map<String, int>.from(state.gemInventory);
    for (final gem in droppedGems) {
      updatedGemInv[gem.id] = (updatedGemInv[gem.id] ?? 0) + 1;
    }

    final updatedMaterials = Map<String, int>.from(state.craftingMaterials);
    for (final entry in droppedMaterials.entries) {
      updatedMaterials[entry.key] = (updatedMaterials[entry.key] ?? 0) + entry.value;
    }

    // Companion Food Drops (35% meat, 25% herb, 30% beast_stone if boss or zone >= 3)
    final updatedPetFoods = Map<String, int>.from(state.petFoods);
    final rng = Random();
    if (rng.nextDouble() < 0.35) {
      final meatCount = 1 + rng.nextInt(2);
      updatedPetFoods['meat'] = (updatedPetFoods['meat'] ?? 0) + meatCount;
    }
    if (rng.nextDouble() < 0.25) {
      final herbCount = 1 + rng.nextInt(2);
      updatedPetFoods['herb'] = (updatedPetFoods['herb'] ?? 0) + herbCount;
    }
    if ((isBoss || foughtZone >= 3) && rng.nextDouble() < 0.30) {
      updatedPetFoods['beast_stone'] = (updatedPetFoods['beast_stone'] ?? 0) + 1;
    }

    // Update hero story progress level
    final updatedHeroProgress = Map<String, int>.from(state.heroLevelProgress);
    if (newLevel > (updatedHeroProgress[state.currentHeroId] ?? 0)) {
      updatedHeroProgress[state.currentHeroId] = newLevel;
    }

    state = state.copyWith(
      level: newLevel,
      currentExp: newExp,
      gold: state.gold + effectiveGold,
      gems: state.gems + gainedGems,
      statPoints: state.statPoints + addedStatPoints,
      skillPoints: state.skillPoints + addedSkillPoints,
      inventory: newInventory,
      maxUnlockedZone: newMaxZone,
      clearedStages: clearedList,
      nextStageDifficultyBonus: triggeredSpeedrun ? 0.15 : 0.0,
      highestEndlessFloor: newHighestEndless,
      gemInventory: updatedGemInv,
      craftingMaterials: updatedMaterials,
      petFoods: updatedPetFoods,
      heroLevelProgress: updatedHeroProgress,
    );

    _save();
    return milestoneResult;
  }

  // --- Prestige / Chuyển Sinh System ---

  /// Calculates enlightenment points gained if prestiging with given or current player state
  int calculatePrestigePoints([Player? p]) {
    final current = p ?? state;
    final bossCount = current.clearedStages.where((s) => s.endsWith('_s5')).length;
    final basePoints = (current.level ~/ 5) + (current.highestEndlessFloor ~/ 3) + (bossCount * 2);
    final n = current.prestigeLevel + 1;
    final multiplier = 1.0 + (n - 1) * 0.2;
    return (basePoints * multiplier).floor();
  }

  /// Prestige unlocks when reaching Level >= 30 OR Endless Floor >= 15
  bool get canPrestige => state.level >= 30 || state.highestEndlessFloor >= 15;

  /// Perform Prestige / Chuyển Sinh
  bool doPrestige() {
    if (!canPrestige) return false;
    final pointsGained = calculatePrestigePoints();
    final newPrestigeLevel = state.prestigeLevel + 1;
    final startingBonusStats = (state.prestigeNodeLevels['fresh_start'] ?? 0) * 5;
    final hasAura = (state.prestigeNodeLevels['divine_aura'] ?? 0) > 0;

    state = state.copyWith(
      prestigeLevel: newPrestigeLevel,
      enlightenmentPoints: state.enlightenmentPoints + pointsGained,
      totalEnlightenmentEarned: state.totalEnlightenmentEarned + pointsGained,
      level: 1,
      currentExp: 0,
      gold: 0,
      gems: state.gems,
      statPoints: 2 + startingBonusStats,
      skillPoints: 1,
      stats: const Stats(str: 5, int_: 10, vit: 8, agi: 6, luk: 5),
      equippedWeapon: null,
      clearWeapon: true,
      equippedArmor: null,
      clearArmor: true,
      equippedAccessory: null,
      clearAccessory: true,
      inventory: const [],
      skillLevels: const {
        'fireball': 1,
        'meteor': 1,
        'fire_heart': 1,
      },
      equippedSkillIds: const [
        'fireball',
        'meteor',
      ],
      unlockedSkillSlots: hasAura ? 5 : 4,
      maxUnlockedZone: 1,
      currentZone: 1,
      currentStage: 1,
      clearedStages: const [],
      nextStageDifficultyBonus: 0.0,
    );
    _save();
    return true;
  }

  /// Upgrades a node in the Prestige Tree
  bool upgradePrestigeNode(String nodeId) {
    final node = PrestigeNodeData.getById(nodeId);
    if (node == null) return false;
    final currentLvl = state.prestigeNodeLevels[nodeId] ?? 0;
    if (currentLvl >= node.maxLevel) return false;
    if (state.enlightenmentPoints < node.costPerLevel) return false;

    final updatedLevels = Map<String, int>.from(state.prestigeNodeLevels);
    updatedLevels[nodeId] = currentLvl + 1;

    int newSlots = state.unlockedSkillSlots;
    if (nodeId == 'divine_aura') {
      newSlots = min(6, state.unlockedSkillSlots + 1);
    }
    int extraStatPoints = state.statPoints;
    if (nodeId == 'fresh_start') {
      extraStatPoints += 5;
    }

    state = state.copyWith(
      enlightenmentPoints: state.enlightenmentPoints - node.costPerLevel,
      prestigeNodeLevels: updatedLevels,
      unlockedSkillSlots: newSlots,
      statPoints: extraStatPoints,
    );
    _save();
    return true;
  }

  /// Resets the Prestige Tree for 5 Gems and refunds all spent points
  bool resetPrestigeTree() {
    if (state.gems < 5) return false;

    int refundedPoints = 0;
    for (final entry in state.prestigeNodeLevels.entries) {
      final node = PrestigeNodeData.getById(entry.key);
      if (node != null) {
        refundedPoints += entry.value * node.costPerLevel;
      }
    }

    state = state.copyWith(
      gems: state.gems - 5,
      enlightenmentPoints: state.enlightenmentPoints + refundedPoints,
      prestigeNodeLevels: const {},
      unlockedSkillSlots: min(5, state.unlockedSkillSlots),
    );
    _save();
    return true;
  }

  // --- GEM SOCKET SYSTEM ---

  /// Inserts a gem into an equipment item's next available socket
  bool insertGem({required String itemId, required Gem gem}) {
    final gemId = gem.id;
    final ownedCount = state.gemInventory[gemId] ?? 0;
    if (ownedCount <= 0) return false;

    Equipment? item;
    bool inWeapon = state.equippedWeapon?.id == itemId;
    bool inArmor = state.equippedArmor?.id == itemId;
    bool inAccessory = state.equippedAccessory?.id == itemId;

    if (inWeapon) {
      item = state.equippedWeapon;
    } else if (inArmor) {
      item = state.equippedArmor;
    } else if (inAccessory) {
      item = state.equippedAccessory;
    } else {
      final idx = state.inventory.indexWhere((e) => e.id == itemId);
      if (idx != -1) item = state.inventory[idx];
    }

    if (item == null) return false;
    if (item.insertedGems.length >= item.maxSockets) return false;

    final updatedGems = List<Gem>.from(item.insertedGems)..add(gem);
    final updatedItem = item.copyWith(insertedGems: updatedGems);

    final newGemInv = Map<String, int>.from(state.gemInventory);
    newGemInv[gemId] = ownedCount - 1;
    if (newGemInv[gemId]! <= 0) newGemInv.remove(gemId);

    if (inWeapon) {
      state = state.copyWith(equippedWeapon: updatedItem, gemInventory: newGemInv);
    } else if (inArmor) {
      state = state.copyWith(equippedArmor: updatedItem, gemInventory: newGemInv);
    } else if (inAccessory) {
      state = state.copyWith(equippedAccessory: updatedItem, gemInventory: newGemInv);
    } else {
      final newInv = List<Equipment>.from(state.inventory);
      final idx = newInv.indexWhere((e) => e.id == itemId);
      if (idx != -1) {
        newInv[idx] = updatedItem;
        state = state.copyWith(inventory: newInv, gemInventory: newGemInv);
      }
    }
    _save();
    return true;
  }

  /// Removes a gem from socket at socketIndex without losing it (returns to gem inventory)
  bool removeGem({required String itemId, required int socketIndex}) {
    Equipment? item;
    bool inWeapon = state.equippedWeapon?.id == itemId;
    bool inArmor = state.equippedArmor?.id == itemId;
    bool inAccessory = state.equippedAccessory?.id == itemId;

    if (inWeapon) {
      item = state.equippedWeapon;
    } else if (inArmor) {
      item = state.equippedArmor;
    } else if (inAccessory) {
      item = state.equippedAccessory;
    } else {
      final idx = state.inventory.indexWhere((e) => e.id == itemId);
      if (idx != -1) item = state.inventory[idx];
    }

    if (item == null) return false;
    if (socketIndex < 0 || socketIndex >= item.insertedGems.length) return false;

    final removedGem = item.insertedGems[socketIndex];
    final updatedGems = List<Gem>.from(item.insertedGems)..removeAt(socketIndex);
    final updatedItem = item.copyWith(insertedGems: updatedGems);

    final newGemInv = Map<String, int>.from(state.gemInventory);
    newGemInv[removedGem.id] = (newGemInv[removedGem.id] ?? 0) + 1;

    if (inWeapon) {
      state = state.copyWith(equippedWeapon: updatedItem, gemInventory: newGemInv);
    } else if (inArmor) {
      state = state.copyWith(equippedArmor: updatedItem, gemInventory: newGemInv);
    } else if (inAccessory) {
      state = state.copyWith(equippedAccessory: updatedItem, gemInventory: newGemInv);
    } else {
      final newInv = List<Equipment>.from(state.inventory);
      final idx = newInv.indexWhere((e) => e.id == itemId);
      if (idx != -1) {
        newInv[idx] = updatedItem;
        state = state.copyWith(inventory: newInv, gemInventory: newGemInv);
      }
    }
    _save();
    return true;
  }

  /// Upgrades a gem in socket from level N to N+1: consumes 2 same-level gems from bag + 50*N gold
  bool upgradeGemInSocket({required String itemId, required int socketIndex}) {
    Equipment? item;
    bool inWeapon = state.equippedWeapon?.id == itemId;
    bool inArmor = state.equippedArmor?.id == itemId;
    bool inAccessory = state.equippedAccessory?.id == itemId;

    if (inWeapon) {
      item = state.equippedWeapon;
    } else if (inArmor) {
      item = state.equippedArmor;
    } else if (inAccessory) {
      item = state.equippedAccessory;
    } else {
      final idx = state.inventory.indexWhere((e) => e.id == itemId);
      if (idx != -1) item = state.inventory[idx];
    }

    if (item == null) return false;
    if (socketIndex < 0 || socketIndex >= item.insertedGems.length) return false;

    final gem = item.insertedGems[socketIndex];
    if (gem.level >= 5) return false;

    final cost = gem.upgradeGoldCost;
    if (state.gold < cost) return false;

    final bagCount = state.gemInventory[gem.id] ?? 0;
    if (bagCount < 2) return false;

    final newGemInv = Map<String, int>.from(state.gemInventory);
    newGemInv[gem.id] = bagCount - 2;
    if (newGemInv[gem.id]! <= 0) newGemInv.remove(gem.id);

    final nextLevelGem = Gem(type: gem.type, level: gem.level + 1);
    final updatedGems = List<Gem>.from(item.insertedGems);
    updatedGems[socketIndex] = nextLevelGem;
    final updatedItem = item.copyWith(insertedGems: updatedGems);

    if (inWeapon) {
      state = state.copyWith(equippedWeapon: updatedItem, gemInventory: newGemInv, gold: state.gold - cost);
    } else if (inArmor) {
      state = state.copyWith(equippedArmor: updatedItem, gemInventory: newGemInv, gold: state.gold - cost);
    } else if (inAccessory) {
      state = state.copyWith(equippedAccessory: updatedItem, gemInventory: newGemInv, gold: state.gold - cost);
    } else {
      final newInv = List<Equipment>.from(state.inventory);
      final idx = newInv.indexWhere((e) => e.id == itemId);
      if (idx != -1) {
        newInv[idx] = updatedItem;
        state = state.copyWith(inventory: newInv, gemInventory: newGemInv, gold: state.gold - cost);
      }
    }
    _save();
    return true;
  }

  /// Fuse All (Ghép tất cả): auto upgrades gems in bag when having >= 3 of the same color & level
  int fuseAllGems() {
    int totalFused = 0;
    final newGemInv = Map<String, int>.from(state.gemInventory);
    int currentGold = state.gold;

    for (final type in GemType.values) {
      for (int lvl = 1; lvl < 5; lvl++) {
        final gemId = '${type.name}_$lvl';
        final count = newGemInv[gemId] ?? 0;
        final costPerFuse = 50 * lvl;

        int possibleFuses = count ~/ 3;
        while (possibleFuses > 0 && currentGold >= costPerFuse) {
          newGemInv[gemId] = (newGemInv[gemId] ?? 0) - 3;
          if (newGemInv[gemId]! <= 0) newGemInv.remove(gemId);

          final nextGemId = '${type.name}_${lvl + 1}';
          newGemInv[nextGemId] = (newGemInv[nextGemId] ?? 0) + 1;

          currentGold -= costPerFuse;
          totalFused++;
          possibleFuses--;
        }
      }
    }

    if (totalFused > 0) {
      state = state.copyWith(
        gemInventory: newGemInv,
        gold: currentGold,
      );
      _save();
    }
    return totalFused;
  }

  /// Upgrades 1 gem of type & level in bag: consumes 3 gems + 50*level gold, gives 1 gem of level+1
  bool upgradeGem(Gem gem) {
    if (gem.level >= 5) return false;
    final count = state.gemInventory[gem.id] ?? 0;
    final cost = gem.upgradeGoldCost;
    if (count < 3 || state.gold < cost) return false;

    final newGemInv = Map<String, int>.from(state.gemInventory);
    newGemInv[gem.id] = count - 3;
    if (newGemInv[gem.id]! <= 0) newGemInv.remove(gem.id);

    final nextId = '${gem.type.name}_${gem.level + 1}';
    newGemInv[nextId] = (newGemInv[nextId] ?? 0) + 1;

    state = state.copyWith(
      gemInventory: newGemInv,
      gold: state.gold - cost,
    );
    _save();
    return true;
  }

  // --- CRAFTING SYSTEM ---

  /// Crafts an equipment item according to recipe
  Equipment? craftRecipe(CraftingRecipe recipe) {
    if (state.level < recipe.requiredLevel) return null;
    if (state.gold < recipe.goldCost) return null;
    if (state.gems < recipe.gemsCost) return null;

    for (final entry in recipe.requiredMaterials.entries) {
      final owned = state.craftingMaterials[entry.key] ?? 0;
      if (owned < entry.value) return null;
    }

    final newMats = Map<String, int>.from(state.craftingMaterials);
    for (final entry in recipe.requiredMaterials.entries) {
      newMats[entry.key] = (newMats[entry.key] ?? 0) - entry.value;
    }

    Equipment outputItem;
    final rng = Random();

    if (recipe.isSetPiece) {
      final setPieces = SeedEquipment.allPredefinedEquipment.where((e) => e.setId != null).toList();
      final picked = setPieces[rng.nextInt(setPieces.length)];
      outputItem = Equipment(
        id: 'crafted_${picked.id}_${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(1000)}',
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
        affixes: LootService.rollAffixesForRarity(picked.rarity),
        bonusSockets: rng.nextDouble() < 0.20 ? 1 : null,
      );
    } else {
      final slot = recipe.targetSlot ?? EquipmentSlot.values[rng.nextInt(EquipmentSlot.values.length)];
      final matchingPredefined = SeedEquipment.allPredefinedEquipment
          .where((e) => e.rarity == recipe.targetRarity && (recipe.targetSlot == null || e.slot == slot))
          .toList();

      if (matchingPredefined.isNotEmpty && rng.nextBool()) {
        final picked = matchingPredefined[rng.nextInt(matchingPredefined.length)];
        outputItem = Equipment(
          id: 'crafted_${picked.id}_${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(1000)}',
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
          affixes: LootService.rollAffixesForRarity(picked.rarity),
          bonusSockets: rng.nextDouble() < 0.15 ? 1 : null,
        );
      } else {
        outputItem = Equipment(
          id: 'crafted_${DateTime.now().microsecondsSinceEpoch}_${rng.nextInt(9999)}',
          name: '${recipe.name} Thần Khí',
          description: 'Trang bị do chính tay bạn tôi luyện và chế tác.',
          slot: slot,
          rarity: recipe.targetRarity,
          flatAtk: slot == EquipmentSlot.weapon ? 25 + (recipe.requiredLevel * 2) : 0,
          flatDef: slot == EquipmentSlot.armor ? 12 + recipe.requiredLevel : 0,
          flatHp: slot == EquipmentSlot.armor ? 150 + (recipe.requiredLevel * 10) : 0,
          critRate: slot == EquipmentSlot.accessory ? 0.05 : 0.0,
          manaRegen: slot == EquipmentSlot.accessory ? 1.5 : 0.0,
          emoji: recipe.emoji,
          sellPrice: recipe.goldCost ~/ 2,
          affixes: LootService.rollAffixesForRarity(recipe.targetRarity),
          bonusSockets: rng.nextDouble() < 0.15 ? 1 : null,
        );
      }
    }

    final newInv = List<Equipment>.from(state.inventory)..add(outputItem);
    final newCraftedIds = List<String>.from(state.craftedRecipeIds);
    if (!newCraftedIds.contains(recipe.id)) {
      newCraftedIds.add(recipe.id);
    }

    state = state.copyWith(
      gold: state.gold - recipe.goldCost,
      gems: state.gems - recipe.gemsCost,
      craftingMaterials: newMats,
      inventory: newInv,
      craftedRecipeIds: newCraftedIds,
    );
    _save();
    return outputItem;
  }

  // --- REFORGE SYSTEM ---

  /// Rolls a candidate new affix for reforge (never duplicates existing affix types)
  EquipmentAffix? rollReforgeCandidate({required Equipment item, required int affixIndex}) {
    if (affixIndex < 0 || affixIndex >= item.affixes.length) return null;
    final currentTypes = item.affixes.map((a) => a.type).toList();
    return EquipmentAffix.rollRandom(excludeTypes: currentTypes);
  }

  /// Reforges an affix on equipment item: deducts cost, generates candidate or applies
  bool payAndApplyReforge({
    required String itemId,
    required int affixIndex,
    required EquipmentAffix newAffix,
    bool lockOtherAffix = false,
  }) {
    Equipment? item;
    bool inWeapon = state.equippedWeapon?.id == itemId;
    bool inArmor = state.equippedArmor?.id == itemId;
    bool inAccessory = state.equippedAccessory?.id == itemId;

    if (inWeapon) {
      item = state.equippedWeapon;
    } else if (inArmor) {
      item = state.equippedArmor;
    } else if (inAccessory) {
      item = state.equippedAccessory;
    } else {
      final idx = state.inventory.indexWhere((e) => e.id == itemId);
      if (idx != -1) item = state.inventory[idx];
    }

    if (item == null) return false;
    if (affixIndex < 0 || affixIndex >= item.affixes.length) return false;

    int goldCost = 500;
    String matKey = 'crystal';
    int matCount = 1;
    if (item.rarity == EquipmentRarity.epic) {
      goldCost = 1500;
      matKey = 'steel';
      matCount = 2;
    } else if (item.rarity == EquipmentRarity.legendary) {
      goldCost = 5000;
      matKey = 'essence';
      matCount = 5;
    }

    int gemsCost = lockOtherAffix ? 1 : 0;

    if (state.gold < goldCost) return false;
    if (state.gems < gemsCost) return false;
    if ((state.craftingMaterials[matKey] ?? 0) < matCount) return false;

    final newMats = Map<String, int>.from(state.craftingMaterials);
    newMats[matKey] = newMats[matKey]! - matCount;

    final updatedAffixes = List<EquipmentAffix>.from(item.affixes);
    updatedAffixes[affixIndex] = newAffix;
    final updatedItem = item.copyWith(affixes: updatedAffixes);

    if (inWeapon) {
      state = state.copyWith(
        equippedWeapon: updatedItem,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
        craftingMaterials: newMats,
      );
    } else if (inArmor) {
      state = state.copyWith(
        equippedArmor: updatedItem,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
        craftingMaterials: newMats,
      );
    } else if (inAccessory) {
      state = state.copyWith(
        equippedAccessory: updatedItem,
        gold: state.gold - goldCost,
        gems: state.gems - gemsCost,
        craftingMaterials: newMats,
      );
    } else {
      final newInv = List<Equipment>.from(state.inventory);
      final idx = newInv.indexWhere((e) => e.id == itemId);
      if (idx != -1) {
        newInv[idx] = updatedItem;
        state = state.copyWith(
          inventory: newInv,
          gold: state.gold - goldCost,
          gems: state.gems - gemsCost,
          craftingMaterials: newMats,
        );
      }
    }
    _save();
    return true;
  }

  /// Pay reforge fee without applying (when user chooses "Giữ" old stat)
  bool payReforgeFee({required Equipment item, bool lockOtherAffix = false}) {
    int goldCost = 500;
    String matKey = 'crystal';
    int matCount = 1;
    if (item.rarity == EquipmentRarity.epic) {
      goldCost = 1500;
      matKey = 'steel';
      matCount = 2;
    } else if (item.rarity == EquipmentRarity.legendary) {
      goldCost = 5000;
      matKey = 'essence';
      matCount = 5;
    }
    int gemsCost = lockOtherAffix ? 1 : 0;
    if (state.gold < goldCost || state.gems < gemsCost || (state.craftingMaterials[matKey] ?? 0) < matCount) {
      return false;
    }
    final newMats = Map<String, int>.from(state.craftingMaterials);
    newMats[matKey] = newMats[matKey]! - matCount;
    state = state.copyWith(
      gold: state.gold - goldCost,
      gems: state.gems - gemsCost,
      craftingMaterials: newMats,
    );
    _save();
    return true;
  }

  // --- TRANSMUTE SYSTEM ---

  /// Transmutes 3 items of the same rarity into 1 item of the next higher rarity
  Equipment? transmuteEquipment(List<String> itemIds) {
    if (itemIds.length != 3) return null;

    final itemsToSacrifice = state.inventory.where((e) => itemIds.contains(e.id)).toList();
    if (itemsToSacrifice.length != 3) return null;

    final targetRarity = itemsToSacrifice.first.rarity;
    if (!itemsToSacrifice.every((e) => e.rarity == targetRarity)) return null;

    int goldCost = 100;
    EquipmentRarity nextRarity;
    switch (targetRarity) {
      case EquipmentRarity.common:
        nextRarity = EquipmentRarity.uncommon;
        goldCost = 100;
        break;
      case EquipmentRarity.uncommon:
        nextRarity = EquipmentRarity.rare;
        goldCost = 300;
        break;
      case EquipmentRarity.rare:
        nextRarity = EquipmentRarity.epic;
        goldCost = 1000;
        break;
      case EquipmentRarity.epic:
        nextRarity = EquipmentRarity.legendary;
        goldCost = 3000;
        break;
      case EquipmentRarity.legendary:
        return null;
    }

    if (state.gold < goldCost) return null;

    final newInv = List<Equipment>.from(state.inventory);
    final rng = Random();

    // Epic -> Legendary has 30% success rate
    if (targetRarity == EquipmentRarity.epic && rng.nextDouble() > 0.30) {
      newInv.removeWhere((e) => e.id == itemsToSacrifice[0].id || e.id == itemsToSacrifice[1].id);
      state = state.copyWith(
        inventory: newInv,
        gold: state.gold - goldCost,
      );
      _save();
      return null;
    }

    newInv.removeWhere((e) => itemIds.contains(e.id));

    final randomSlot = EquipmentSlot.values[rng.nextInt(EquipmentSlot.values.length)];
    final matchingPredefined = SeedEquipment.allPredefinedEquipment
        .where((e) => e.rarity == nextRarity)
        .toList();

    Equipment newItem;
    if (matchingPredefined.isNotEmpty && rng.nextBool()) {
      final picked = matchingPredefined[rng.nextInt(matchingPredefined.length)];
      newItem = Equipment(
        id: 'transmuted_${picked.id}_${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(1000)}',
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
        affixes: LootService.rollAffixesForRarity(picked.rarity),
      );
    } else {
      newItem = Equipment(
        id: 'transmuted_${DateTime.now().microsecondsSinceEpoch}_${rng.nextInt(9999)}',
        name: 'Biến Hoàn ${nextRarity.label} Bảo Khí',
        description: 'Trang bị sinh ra từ lò luyện biến đổi trang bị huyền bí.',
        slot: randomSlot,
        rarity: nextRarity,
        flatAtk: randomSlot == EquipmentSlot.weapon ? 20 + nextRarity.index * 15 : 0,
        flatDef: randomSlot == EquipmentSlot.armor ? 8 + nextRarity.index * 6 : 0,
        flatHp: randomSlot == EquipmentSlot.armor ? 100 + nextRarity.index * 120 : 0,
        critRate: randomSlot == EquipmentSlot.accessory ? 0.04 * nextRarity.index : 0.0,
        manaRegen: randomSlot == EquipmentSlot.accessory ? 1.0 + nextRarity.index * 0.5 : 0.0,
        sellPrice: goldCost,
        affixes: LootService.rollAffixesForRarity(nextRarity),
      );
    }

    newInv.add(newItem);
    state = state.copyWith(
      inventory: newInv,
      gold: state.gold - goldCost,
    );
    _save();
    return newItem;
  }

  /// Initialize Arena season & virtual leaderboard if first time
  void initArenaIfNeeded() {
    bool changed = false;
    int seasonStart = state.seasonStartTimestamp;
    int lastReset = state.lastSeasonResetTimestamp;
    List<Map<String, dynamic>> lbData = state.virtualLeaderboardData;
    int lastSimTime = state.lastLeaderboardSimTime;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (seasonStart == 0) {
      seasonStart = now;
      lastReset = now;
      changed = true;
    }

    if (lbData.isEmpty) {
      lbData = VirtualLeaderboard.generateInitialAiEntries()
          .map((e) => e.toJson())
          .toList();
      lastSimTime = now;
      changed = true;
    } else {
      // Simulate daily climbing if more than 24h passed
      final daysPassed = ((now - lastSimTime) / (1000 * 60 * 60 * 24)).floor();
      if (daysPassed >= 1) {
        final currentEntries = lbData.map((e) => LeaderboardEntry.fromJson(e)).toList();
        final updatedEntries = VirtualLeaderboard.simulateDailyClimbing(currentEntries, daysPassed: daysPassed);
        lbData = updatedEntries.map((e) => e.toJson()).toList();
        lastSimTime = now;
        changed = true;
      }
    }

    if (changed) {
      state = state.copyWith(
        seasonStartTimestamp: seasonStart,
        lastSeasonResetTimestamp: lastReset,
        virtualLeaderboardData: lbData,
        lastLeaderboardSimTime: lastSimTime,
      );
      _save();
    }
  }

  /// Process end of Arena match
  ArenaBattleEndResult onArenaBattleEnd({
    required bool isWon,
    required ArenaOpponent opponent,
  }) {
    initArenaIfNeeded();

    int apChange = 0;
    int earnedGold = 0;
    int earnedDiamonds = 0;
    String? droppedGemKey;
    bool streakBonus = false;
    int newStreak = state.arenaWinStreak;
    int newAp = state.arenaPoints;
    int newSeasonAp = state.cumulativeSeasonAp;

    final rng = Random();

    if (isWon) {
      newStreak += 1;
      apChange = 1;
      earnedGold = 200;

      // 5-win streak bonus: +5 AP + 1 Diamond
      if (newStreak % 5 == 0) {
        apChange += 5;
        earnedDiamonds += 1;
        streakBonus = true;
      }

      newAp += apChange;
      newSeasonAp += apChange;

      // 10% chance to drop 1 random gem (Ruby, Sapphire, Emerald, Topaz, Amethyst lv 1)
      if (rng.nextDouble() < 0.10) {
        final gemTypes = ['ruby_1', 'sapphire_1', 'emerald_1', 'topaz_1', 'amethyst_1'];
        droppedGemKey = gemTypes[rng.nextInt(gemTypes.length)];
      }
    } else {
      newStreak = 0;
      if (state.arenaPoints > 0) {
        apChange = -1;
        newAp = max(0, state.arenaPoints - 1);
      } else {
        apChange = 0;
      }
    }

    // Update match history (keep last 10)
    final newRecord = ArenaMatchRecord(
      id: 'match_${DateTime.now().microsecondsSinceEpoch}',
      opponentName: opponent.name,
      opponentAvatar: opponent.avatarAsset,
      isWin: isWon,
      apChange: apChange,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedHistory = [newRecord, ...state.arenaMatchHistory];
    if (updatedHistory.length > 10) {
      updatedHistory.removeRange(10, updatedHistory.length);
    }

    // Update highest arena tier
    final currentTier = ArenaRankInfo.fromAp(newAp);
    String highestTier = state.highestArenaTier;
    if (currentTier.tier.index >=
        (ArenaTier.values.firstWhere(
            (t) => t.label == highestTier.split(' ').first,
            orElse: () => ArenaTier.bronze).index)) {
      highestTier = currentTier.displayName;
    }

    // Update gem inventory if gem dropped
    Map<String, int> updatedGems = Map<String, int>.from(state.gemInventory);
    if (droppedGemKey != null) {
      updatedGems[droppedGemKey] = (updatedGems[droppedGemKey] ?? 0) + 1;
    }

    state = state.copyWith(
      arenaPoints: newAp,
      cumulativeSeasonAp: newSeasonAp,
      arenaWinStreak: newStreak,
      highestArenaTier: highestTier,
      arenaMatchHistory: updatedHistory,
      gold: state.gold + earnedGold,
      gems: state.gems + earnedDiamonds,
      gemInventory: updatedGems,
    );
    _save();

    return ArenaBattleEndResult(
      isWon: isWon,
      apChange: apChange,
      newAp: newAp,
      earnedGold: earnedGold,
      earnedDiamonds: earnedDiamonds,
      droppedGem: droppedGemKey,
      triggeredStreakBonus: streakBonus,
      currentStreak: newStreak,
    );
  }

  /// Claim a Season Pass milestone (1-30)
  bool claimSeasonMilestone(int level) {
    if (state.claimedSeasonMilestones.contains(level)) return false;

    final allMilestones = SeasonMilestone.generateMilestones();
    final milestone = allMilestones.firstWhere(
      (m) => m.level == level,
      orElse: () => allMilestones.first,
    );

    if (state.cumulativeSeasonAp < milestone.requiredAp) {
      return false;
    }

    final updatedClaimed = List<int>.from(state.claimedSeasonMilestones)..add(level);
    int newGold = state.gold + milestone.goldReward;
    int newGems = state.gems + milestone.diamondReward;

    Map<String, int> updatedGemInv = Map<String, int>.from(state.gemInventory);
    if (milestone.gemReward != null) {
      updatedGemInv[milestone.gemReward!] = (updatedGemInv[milestone.gemReward!] ?? 0) + 1;
    }

    List<Equipment> newInv = List<Equipment>.from(state.inventory);
    if (milestone.equipmentRarity != null) {
      final rng = Random();
      final slots = [EquipmentSlot.weapon, EquipmentSlot.armor, EquipmentSlot.accessory];
      final slot = slots[rng.nextInt(slots.length)];

      if (milestone.equipmentRarity == 'set_piece') {
        final setIds = ['viem_long', 'han_bang', 'loi_dinh', 'huyet_ma'];
        final setId = setIds[rng.nextInt(setIds.length)];
        final setNames = {
          'viem_long': 'Viêm Long',
          'han_bang': 'Hàn Băng',
          'loi_dinh': 'Lôi Đình',
          'huyet_ma': 'Huyết Ma',
        };
        final slotNames = {
          EquipmentSlot.weapon: 'Thần Kiếm',
          EquipmentSlot.armor: 'Chiến Giáp',
          EquipmentSlot.accessory: 'Hộ Phù',
        };
        newInv.add(Equipment(
          id: 'season_set_${DateTime.now().microsecondsSinceEpoch}',
          name: '${setNames[setId]} ${slotNames[slot]}',
          description: 'Trang bị Bộ Hoàng Kim ban thưởng từ Đỉnh Phong Mùa Đấu Trường.',
          slot: slot,
          rarity: EquipmentRarity.legendary,
          setId: setId,
          flatAtk: slot == EquipmentSlot.weapon ? 90 : 0,
          flatDef: slot == EquipmentSlot.armor ? 35 : 0,
          flatHp: slot == EquipmentSlot.armor ? 650 : 0,
          critRate: slot == EquipmentSlot.accessory ? 0.12 : 0.0,
          manaRegen: slot == EquipmentSlot.accessory ? 3.0 : 0.0,
          affixes: LootService.rollAffixesForRarity(EquipmentRarity.legendary),
          bonusSockets: 1,
        ));
      } else {
        final rarity = milestone.equipmentRarity == 'epic'
            ? EquipmentRarity.epic
            : EquipmentRarity.rare;
        newInv.add(Equipment(
          id: 'season_gear_${DateTime.now().microsecondsSinceEpoch}',
          name:
              'Vinh Quang Mùa ${slot == EquipmentSlot.weapon ? "Kiếm" : (slot == EquipmentSlot.armor ? "Giáp" : "Nhẫn")}',
          description: 'Phần thưởng vinh dự từ Đấu Trường Season Pass.',
          slot: slot,
          rarity: rarity,
          flatAtk: slot == EquipmentSlot.weapon ? 45 : 0,
          flatDef: slot == EquipmentSlot.armor ? 20 : 0,
          flatHp: slot == EquipmentSlot.armor ? 300 : 0,
          critRate: slot == EquipmentSlot.accessory ? 0.08 : 0.0,
          manaRegen: slot == EquipmentSlot.accessory ? 2.0 : 0.0,
          affixes: LootService.rollAffixesForRarity(rarity),
        ));
      }
    }

    state = state.copyWith(
      claimedSeasonMilestones: updatedClaimed,
      gold: newGold,
      gems: newGems,
      gemInventory: updatedGemInv,
      inventory: newInv,
    );
    _save();
    return true;
  }

  /// Claim weekly rank tier rewards and reset AP
  TierReward? claimWeeklyRankReward() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sevenDays = 7 * 24 * 60 * 60 * 1000;
    if (state.lastSeasonResetTimestamp > 0 && now - state.lastSeasonResetTimestamp < sevenDays) {
      return null;
    }

    final currentRank = ArenaRankInfo.fromAp(state.arenaPoints);
    final reward = TierReward.forTier(currentRank.tier);

    Map<String, int> updatedGems = Map<String, int>.from(state.gemInventory);
    if (reward.gemReward != null) {
      updatedGems[reward.gemReward!] = (updatedGems[reward.gemReward!] ?? 0) + 1;
    }

    state = state.copyWith(
      gold: state.gold + reward.gold,
      gems: state.gems + reward.gems,
      gemInventory: updatedGems,
      arenaPoints: 0,
      lastSeasonResetTimestamp: now,
      title: reward.title ?? state.title,
    );
    _save();
    return reward;
  }

  /// Retrieves combined sorted leaderboard entries
  List<LeaderboardEntry> getLeaderboardEntries() {
    initArenaIfNeeded();

    final aiEntries = state.virtualLeaderboardData
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();

    final playerEntry = LeaderboardEntry(
      id: 'player_me',
      name: state.name.isNotEmpty ? state.name : 'Bạn',
      title: state.title,
      avatarAsset: state.portraitAsset,
      ap: state.arenaPoints,
      isPlayer: true,
    );

    final combined = [...aiEntries, playerEntry];
    combined.sort((a, b) => b.ap.compareTo(a.ap));
    return combined;
  }

  // --- Hero Story & Lore System ---

  /// Claim a story chapter reward for a hero
  bool claimHeroStoryChapter(String heroId, int chapterNumber) {
    final story = HeroStory.getById(heroId);
    if (story == null) return false;

    final chapter = story.chapters.firstWhere(
      (c) => c.chapterNumber == chapterNumber,
      orElse: () => story.chapters.first,
    );

    final heroLvl = state.heroLevelProgress[heroId] ?? (state.currentHeroId == heroId ? state.level : 0);
    if (heroLvl < chapter.requiredLevel) return false;

    final claimed = Map<String, List<int>>.from(state.claimedHeroStoryChapters);
    final heroClaimed = List<int>.from(claimed[heroId] ?? []);
    if (heroClaimed.contains(chapterNumber)) return false;

    heroClaimed.add(chapterNumber);
    claimed[heroId] = heroClaimed;

    int bonusGold = 200 * chapterNumber;
    int bonusGems = chapterNumber == 3 ? 5 : 2;
    String newTitle = state.title;

    // Check if player has unlocked Chapter 3 for all 16 heroes
    bool all16Done = true;
    for (final s in HeroStory.allStories) {
      final cList = claimed[s.heroId] ?? [];
      if (!cList.contains(3)) {
        all16Done = false;
        break;
      }
    }
    if (all16Done) {
      newTitle = 'Nhà Sử Học';
    }

    state = state.copyWith(
      claimedHeroStoryChapters: claimed,
      gold: state.gold + bonusGold,
      gems: state.gems + bonusGems,
      title: newTitle,
    );
    _save();
    return true;
  }

  // --- Companion System ---

  /// Equip or unequip a companion
  void equipCompanion(String? companionId) {
    if (companionId == null || state.equippedCompanionId == companionId) {
      state = state.copyWith(clearCompanion: true);
    } else {
      state = state.copyWith(equippedCompanionId: companionId);
    }
    _save();
  }

  /// Upgrades companion with pet food
  bool upgradeCompanion(String companionId) {
    final type = CompanionType.getById(companionId);
    if (type == null) return false;

    final currentLevel = state.companionLevels[companionId] ?? 1;
    if (currentLevel >= 10) return false;

    final cost = type.getUpgradeCost(currentLevel);
    for (final entry in cost.entries) {
      if ((state.petFoods[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }

    final newPetFoods = Map<String, int>.from(state.petFoods);
    for (final entry in cost.entries) {
      newPetFoods[entry.key] = (newPetFoods[entry.key] ?? 0) - entry.value;
    }

    final newLevels = Map<String, int>.from(state.companionLevels);
    newLevels[companionId] = currentLevel + 1;

    state = state.copyWith(
      petFoods: newPetFoods,
      companionLevels: newLevels,
    );
    _save();
    return true;
  }

  /// Add pet foods directly
  void addPetFoods({int meat = 0, int herb = 0, int beastStone = 0}) {
    final updated = Map<String, int>.from(state.petFoods);
    updated['meat'] = (updated['meat'] ?? 0) + meat;
    updated['herb'] = (updated['herb'] ?? 0) + herb;
    updated['beast_stone'] = (updated['beast_stone'] ?? 0) + beastStone;
    state = state.copyWith(petFoods: updated);
    _save();
  }

  // --- Raid Boss System ---

  /// Synchronizes and updates Raid Boss state, weekly rotation and stamina regen
  void initRaidWeekIfNeeded() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentWeek = RaidBossInfo.getCurrentWeekNumber(timestampMs: now);
    final boss = RaidBossInfo.getCurrentRaidBoss(timestampMs: now);

    int newRaidWeek = state.currentRaidWeek;
    int newBossHp = state.raidBossCurrentHp;
    int newWeeklyDmg = state.weeklyRaidDamage;
    bool newClaimedReward = state.hasClaimedWeeklyRaidReward;

    // Weekly reset check
    if (state.currentRaidWeek != currentWeek || (state.raidBossCurrentHp <= 0 && state.currentRaidWeek == 0)) {
      newRaidWeek = currentWeek;
      newBossHp = boss.maxHp;
      newWeeklyDmg = 0;
      newClaimedReward = false;
    }

    // Stamina regeneration: 1 stamina per 5 mins (300,000 ms), max 20
    int currentStamina = state.raidStamina;
    int lastRegen = state.lastRaidStaminaRegenTime;
    if (lastRegen == 0) {
      lastRegen = now;
    } else {
      final elapsedMs = now - lastRegen;
      const regenInterval = 5 * 60 * 1000;
      if (elapsedMs >= regenInterval && currentStamina < 20) {
        final gained = elapsedMs ~/ regenInterval;
        currentStamina = min(20, currentStamina + gained);
        lastRegen = now - (elapsedMs % regenInterval);
      }
    }

    // Daily stamina purchase reset check
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int purchases = state.dailyStaminaPurchases;
    if (state.lastStaminaPurchaseDate != todayStr) {
      purchases = 0;
    }

    state = state.copyWith(
      currentRaidWeek: newRaidWeek,
      raidBossCurrentHp: newBossHp,
      weeklyRaidDamage: newWeeklyDmg,
      hasClaimedWeeklyRaidReward: newClaimedReward,
      raidStamina: currentStamina,
      lastRaidStaminaRegenTime: lastRegen,
      dailyStaminaPurchases: purchases,
      lastStaminaPurchaseDate: todayStr,
    );
    _save();
  }

  /// Purchase 5 stamina for 1 gem (max 3 times/day)
  bool buyRaidStamina() {
    initRaidWeekIfNeeded();
    if (state.dailyStaminaPurchases >= 3 || state.gems < 1) return false;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    state = state.copyWith(
      gems: state.gems - 1,
      raidStamina: min(20, state.raidStamina + 5),
      dailyStaminaPurchases: state.dailyStaminaPurchases + 1,
      lastStaminaPurchaseDate: todayStr,
    );
    _save();
    return true;
  }

  /// Resolves the end of a raid battle attempt
  void onRaidBattleEnd({required int damageDealt}) {
    initRaidWeekIfNeeded();
    final newHp = max(0, state.raidBossCurrentHp - damageDealt);
    final newWeeklyDmg = state.weeklyRaidDamage + damageDealt;
    final newStamina = max(0, state.raidStamina - 5);

    state = state.copyWith(
      raidBossCurrentHp: newHp,
      weeklyRaidDamage: newWeeklyDmg,
      raidStamina: newStamina,
    );
    _save();
  }

  /// Claim grand raid reward when boss is slain (HP == 0)
  Equipment? claimRaidGrandReward() {
    if (state.raidBossCurrentHp > 0 || state.hasClaimedWeeklyRaidReward) {
      return null;
    }

    final boss = RaidBossInfo.getCurrentRaidBoss();
    final legendaryGear = Equipment(
      id: 'raid_legendary_${DateTime.now().microsecondsSinceEpoch}',
      name: 'Thần Binh ${boss.name.split(" ").last}',
      description: 'Tuyệt thế bảo vật thu được sau khi tiêu diệt ${boss.name}.',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.legendary,
      flatAtk: 85,
      critRate: 0.12,
      affixes: LootService.rollAffixesForRarity(EquipmentRarity.legendary),
    );

    final newInv = List<Equipment>.from(state.inventory)..add(legendaryGear);
    state = state.copyWith(
      inventory: newInv,
      gems: state.gems + 100,
      title: boss.grandTitle,
      hasClaimedWeeklyRaidReward: true,
    );
    _save();
    return legendaryGear;
  }

  /// Selects zone and stage to challenge
  void selectZoneAndStage(int zone, int stage) {
    state = state.copyWith(
      currentZone: zone,
      currentStage: stage,
    );
    _save();
  }

  void setPlayer(Player newPlayer) {
    state = newPlayer;
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
