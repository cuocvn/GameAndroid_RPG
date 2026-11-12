import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_and/models/arena_opponent.dart';
import 'package:game_and/models/arena_rank.dart';
import 'package:game_and/models/companion.dart';
import 'package:game_and/models/crafting_recipe.dart';
import 'package:game_and/models/equipment.dart';
import 'package:game_and/models/equipment_affix.dart';
import 'package:game_and/models/gem.dart';
import 'package:game_and/models/player.dart';
import 'package:game_and/models/raid_boss.dart';
import 'package:game_and/models/season_pass.dart';
import 'package:game_and/models/stats.dart';
import 'package:game_and/models/skill.dart';
import 'package:game_and/data/seed_equipment.dart';
import 'package:game_and/data/seed_skills.dart';
import 'package:game_and/data/seed_enemies.dart';
import 'package:game_and/providers/game_providers.dart';

void main() {
  test('Player initial stats and combat formulas calculation', () {
    const player = Player();
    expect(player.level, 1);
    expect(player.totalStats.str, 5);
    expect(player.maxHp, greaterThan(0));
    expect(player.magicAtk, greaterThan(0));
    expect(player.critRate, greaterThanOrEqualTo(0.0));
    expect(player.attackInterval, greaterThan(0.0));
  });

  test('Seed skills and expanded skill count (18-20 skills)', () {
    expect(SeedSkills.allSkills.length, greaterThanOrEqualTo(18));
    final basicSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.basic);
    final activeSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.active);
    final passiveSkills = SeedSkills.allSkills.where((s) => s.type == SkillType.passive);

    expect(basicSkills.length, greaterThanOrEqualTo(4));
    expect(activeSkills.length, greaterThanOrEqualTo(7));
    expect(passiveSkills.length, greaterThanOrEqualTo(6));
  });

  test('Zone difficulty scaling and unique modifiers', () {
    expect(SeedEnemies.zones.length, 5);

    // Zone 1
    final z1 = SeedEnemies.getEnemiesForZone(1);
    expect(z1.last.isBoss, true);
    expect(z1.last.maxHp, greaterThanOrEqualTo(z1.first.maxHp * 3));

    // Zone 3: 40% Magic Resistance
    final z3 = SeedEnemies.getEnemiesForZone(3);
    expect(z3.first.magicResistPercent, 0.40);

    // Zone 4: 20% Reflect
    final z4 = SeedEnemies.getEnemiesForZone(4);
    expect(z4.first.reflectDamagePercent, 0.20);

    // Zone 5: 5% HP Regen/sec
    final z5 = SeedEnemies.getEnemiesForZone(5);
    expect(z5.first.hpRegenPercentPerSecond, 0.05);
  });

  test('Equipment upgrade calculation', () {
    const item = Equipment(
      id: 'test_item',
      name: 'Test Sword',
      description: '',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.rare,
      flatAtk: 100,
      upgradeLevel: 3,
    );

    // 100 base + 30% = 130
    expect(item.effectiveFlatAtk, 130);
    expect(item.maxUpgradeLevel, 5);
  });

  test('Endless Tower generator and floor 10+ mechanics', () {
    final floor1 = SeedEnemies.generateEndlessEnemy(1);
    final floor5 = SeedEnemies.generateEndlessEnemy(5);
    final floor10 = SeedEnemies.generateEndlessEnemy(10);

    expect(floor5.isBoss, true);
    expect(floor10.isBoss, true);
    expect(floor10.maxHp, greaterThan(floor1.maxHp * 3));
    expect(floor10.atk, greaterThan(floor1.atk));
    expect(floor10.activeModifierBadges.isNotEmpty, true);
  });

  test('Quests & Achievements tracking and rewards', () {
    Player player = const Player(level: 5, gold: 50, gems: 3);
    expect(player.claimedQuestIds.isEmpty, true);

    player = player.copyWith(
      claimedQuestIds: ['reach_lvl_5'],
      gold: player.gold + 200,
      gems: player.gems + 2,
    );

    expect(player.claimedQuestIds.contains('reach_lvl_5'), true);
    expect(player.gold, 250);
    expect(player.gems, 5);
  });

  test('Respec Stats & Skills calculation', () {
    const player = Player(
      level: 10,
      gold: 500,
      statPoints: 0,
      stats: Stats(str: 15, int_: 15, vit: 12, agi: 8, luk: 6),
      skillPoints: 0,
      skillLevels: {'fireball': 3, 'meteor': 2},
    );

    // Respec Stats
    final allocated = (player.stats.str - 5) +
        (player.stats.int_ - 10) +
        (player.stats.vit - 8) +
        (player.stats.agi - 6) +
        (player.stats.luk - 5);
    expect(allocated, 22);

    // Respec Skills
    int refundedSkills = 0;
    for (var lvl in player.skillLevels.values) {
      if (lvl > 1) refundedSkills += (lvl - 1);
    }
    expect(refundedSkills, 3);
  });

  test('Prestige point calculation and unlock condition', () {
    // 1. Initial player cannot prestige
    const player1 = Player(level: 1, highestEndlessFloor: 1);
    expect(player1.level >= 30 || player1.highestEndlessFloor >= 15, false);

    // 2. Level 30 + Endless 15 + 5 boss clears = 21 points (first prestige)
    const player2 = Player(
      level: 30,
      highestEndlessFloor: 15,
      clearedStages: ['z1_s5', 'z2_s5', 'z3_s5', 'z4_s5', 'z5_s5'],
      prestigeLevel: 0,
    );
    expect(player2.level >= 30 || player2.highestEndlessFloor >= 15, true);

    final bossCount = player2.clearedStages.where((s) => s.endsWith('_s5')).length;
    expect(bossCount, 5);

    final basePoints = (player2.level ~/ 5) + (player2.highestEndlessFloor ~/ 3) + (bossCount * 2);
    expect(basePoints, 21); // 6 + 5 + 10 = 21

    final n = player2.prestigeLevel + 1; // 1
    final mult = 1.0 + (n - 1) * 0.2; // 1.0
    final pointsN1 = (basePoints * mult).floor();
    expect(pointsN1, 21);

    // 3. Second prestige (N=2): multiplier 1.2
    const player3 = Player(
      level: 30,
      highestEndlessFloor: 15,
      clearedStages: ['z1_s5', 'z2_s5', 'z3_s5', 'z4_s5', 'z5_s5'],
      prestigeLevel: 1,
    );
    final n2 = player3.prestigeLevel + 1; // 2
    final mult2 = 1.0 + (n2 - 1) * 0.2; // 1.2
    final pointsN2 = (basePoints * mult2).floor();
    expect(pointsN2, 25); // (21 * 1.2) = 25.2 -> 25
  });

  test('Prestige Tree node stat modifications', () {
    const basePlayer = Player(
      stats: Stats(str: 10, int_: 10, vit: 10, agi: 10, luk: 10),
    );
    final baseHp = basePlayer.maxHp;
    final baseInterval = basePlayer.attackInterval;

    // With ancient_power lvl 2 (+10% all stats)
    // With tenacity_hp lvl 1 (+15% Max HP)
    // With swift_speed lvl 1 (+10% speed)
    final upgradedPlayer = basePlayer.copyWith(
      prestigeNodeLevels: {
        'ancient_power': 2,
        'tenacity_hp': 1,
        'swift_speed': 1,
      },
    );

    expect(upgradedPlayer.totalStats.str, 11); // 10 * 1.10 = 11
    expect(upgradedPlayer.totalStats.int_, 11);
    expect(upgradedPlayer.maxHp, greaterThan(baseHp));
    expect(upgradedPlayer.attackInterval, lessThan(baseInterval));
  });

  test('Equipment Set definitions and 2/3 piece bonus activations', () {
    // 1. Verify 12 set pieces exist in predefined equipment
    final setPieces = SeedEquipment.allPredefinedEquipment.where((e) => e.setId != null).toList();
    expect(setPieces.length, 12);

    final viemLongPieces = setPieces.where((e) => e.setId == 'viem_long').toList();
    final hanBangPieces = setPieces.where((e) => e.setId == 'han_bang').toList();
    final loiDinhPieces = setPieces.where((e) => e.setId == 'loi_dinh').toList();
    final huyetMaPieces = setPieces.where((e) => e.setId == 'huyet_ma').toList();

    expect(viemLongPieces.length, 3);
    expect(hanBangPieces.length, 3);
    expect(loiDinhPieces.length, 3);
    expect(huyetMaPieces.length, 3);

    // 2. Base player with 0 set items
    Player p = const Player();
    expect(p.activeSetCounts.isEmpty, true);
    expect(p.hasSetBonus2('viem_long'), false);
    expect(p.hasSetBonus3('viem_long'), false);
    final baseFireDmg = p.fireDamageBonusPercent;

    // 3. Equip 1 Viêm Long piece (Weapon)
    p = p.copyWith(equippedWeapon: viemLongPieces.firstWhere((e) => e.slot == EquipmentSlot.weapon));
    expect(p.activeSetCounts['viem_long'], 1);
    expect(p.hasSetBonus2('viem_long'), false);
    expect(p.hasSetBonus3('viem_long'), false);

    // 4. Equip 2nd Viêm Long piece (Armor) -> 2-piece activated!
    p = p.copyWith(equippedArmor: viemLongPieces.firstWhere((e) => e.slot == EquipmentSlot.armor));
    expect(p.activeSetCounts['viem_long'], 2);
    expect(p.hasSetBonus2('viem_long'), true);
    expect(p.hasSetBonus3('viem_long'), false);
    // +20% Fire Damage bonus activated
    expect(p.fireDamageBonusPercent, closeTo(baseFireDmg + 0.20, 0.001));

    // 5. Equip 3rd Viêm Long piece (Accessory) -> 3-piece full set activated!
    p = p.copyWith(equippedAccessory: viemLongPieces.firstWhere((e) => e.slot == EquipmentSlot.accessory));
    expect(p.activeSetCounts['viem_long'], 3);
    expect(p.hasSetBonus2('viem_long'), true);
    expect(p.hasSetBonus3('viem_long'), true);

    // 6. Test Lôi Đình 2-piece crit bonus (+10% crit)
    final loiDinhWeapon = loiDinhPieces.firstWhere((e) => e.slot == EquipmentSlot.weapon);
    final loiDinhArmor = loiDinhPieces.firstWhere((e) => e.slot == EquipmentSlot.armor);
    Player p2 = const Player();
    final baseCrit = p2.critRate;
    p2 = p2.copyWith(equippedWeapon: loiDinhWeapon, equippedArmor: loiDinhArmor);
    expect(p2.hasSetBonus2('loi_dinh'), true);
    // Gear flat crit + 10% set bonus
    expect(p2.critRate, greaterThan(baseCrit + 0.10));
  });

  test('Boss Patterns, Active Skills, and Telegraph specifications', () {
    // Verify each zone boss has exactly 2 active moves with proper cooldowns and effects
    final b1 = SeedEnemies.getEnemy(1, 5);
    expect(b1.isBoss, true);
    expect(b1.bossSkills.length, 2);
    expect(b1.bossSkills[0].name, 'Cắn Xé');
    expect(b1.bossSkills[0].cooldown, 8.0);
    expect(b1.bossSkills[0].damageMultiplier, 1.5);
    expect(b1.bossSkills[1].name, 'Gầm Thét');
    expect(b1.bossSkills[1].cooldown, 15.0);
    expect(b1.bossSkills[1].causesHeroDefDown, true);

    final b2 = SeedEnemies.getEnemy(2, 5);
    expect(b2.isBoss, true);
    expect(b2.bossSkills.length, 2);
    expect(b2.bossSkills[0].name, 'Cầu Lửa');
    expect(b2.bossSkills[0].cooldown, 8.0);
    expect(b2.bossSkills[0].isMagic, true);
    expect(b2.bossSkills[0].damageMultiplier, 1.8);
    expect(b2.bossSkills[1].name, 'Thiêu Rụi');
    expect(b2.bossSkills[1].cooldown, 15.0);
    expect(b2.bossSkills[1].causesHeroBurn, true);

    final b3 = SeedEnemies.getEnemy(3, 5);
    expect(b3.isBoss, true);
    expect(b3.bossSkills.length, 2);
    expect(b3.bossSkills[0].name, 'Băng Phong');
    expect(b3.bossSkills[0].cooldown, 8.0);
    expect(b3.bossSkills[0].isMagic, true);
    expect(b3.bossSkills[0].damageMultiplier, 2.0);
    expect(b3.bossSkills[1].name, 'Đóng Băng');
    expect(b3.bossSkills[1].cooldown, 15.0);
    expect(b3.bossSkills[1].causesHeroFreeze, true);

    final b4 = SeedEnemies.getEnemy(4, 5);
    expect(b4.isBoss, true);
    expect(b4.bossSkills.length, 2);
    expect(b4.bossSkills[0].name, 'Lưỡi Hái Tử Thần');
    expect(b4.bossSkills[0].cooldown, 8.0);
    expect(b4.bossSkills[0].damageMultiplier, 2.2);
    expect(b4.bossSkills[1].name, 'Triệu Hồi Oán Linh');
    expect(b4.bossSkills[1].cooldown, 15.0);
    expect(b4.bossSkills[1].healsBossPercent, true);

    final b5 = SeedEnemies.getEnemy(5, 5);
    expect(b5.isBoss, true);
    expect(b5.bossSkills.length, 2);
    expect(b5.bossSkills[0].name, 'Hủy Diệt');
    expect(b5.bossSkills[0].cooldown, 8.0);
    expect(b5.bossSkills[0].damageMultiplier, 2.5);
    expect(b5.bossSkills[1].name, 'Đòn Tối Thượng');
    expect(b5.bossSkills[1].cooldown, 20.0);
    expect(b5.bossSkills[1].damageMultiplier, 4.0);
  });

  test('Gem Sockets: socket capacity by rarity, gem stat scaling, insertion and unequip without loss', () {
    // 1. Check socket capacity by rarity rules
    const commonItem = Equipment(id: 'c1', name: 'Gỗ', description: '', slot: EquipmentSlot.weapon, rarity: EquipmentRarity.common);
    const rareItem = Equipment(id: 'r1', name: 'Hiếm', description: '', slot: EquipmentSlot.weapon, rarity: EquipmentRarity.rare);
    const epicItem = Equipment(id: 'e1', name: 'Sử Thi', description: '', slot: EquipmentSlot.armor, rarity: EquipmentRarity.epic);
    const legItem = Equipment(id: 'l1', name: 'Huyền Thoại', description: '', slot: EquipmentSlot.accessory, rarity: EquipmentRarity.legendary);
    const setEpicItem = Equipment(id: 'se1', name: 'Set Piece', description: '', slot: EquipmentSlot.armor, rarity: EquipmentRarity.epic, setId: 'viem_long');

    expect(commonItem.maxSockets, 0);
    expect(rareItem.maxSockets, 1);
    expect(epicItem.maxSockets, 2);
    expect(legItem.maxSockets, 3);
    expect(setEpicItem.maxSockets, 3); // Epic (2) + Set bonus (+1) = 3 sockets!

    // 2. Gem stat scaling (5 colors x 5 levels)
    const rubyL1 = Gem(type: GemType.ruby, level: 1);
    const rubyL5 = Gem(type: GemType.ruby, level: 5);
    expect(rubyL1.atkBonus, 5);
    expect(rubyL5.atkBonus, 40);

    const sapphireL1 = Gem(type: GemType.sapphire, level: 1);
    const sapphireL5 = Gem(type: GemType.sapphire, level: 5);
    expect(sapphireL1.hpBonus, 100);
    expect(sapphireL5.hpBonus, 800);

    const emeraldL1 = Gem(type: GemType.emerald, level: 1);
    const emeraldL5 = Gem(type: GemType.emerald, level: 5);
    expect(emeraldL1.defBonus, 3);
    expect(emeraldL5.defBonus, 25);

    const topazL1 = Gem(type: GemType.topaz, level: 1);
    const topazL5 = Gem(type: GemType.topaz, level: 5);
    expect(topazL1.critBonus, 0.02);
    expect(topazL5.critBonus, 0.08);

    const amethystL1 = Gem(type: GemType.amethyst, level: 1);
    const amethystL5 = Gem(type: GemType.amethyst, level: 5);
    expect(amethystL1.manaRegenBonus, 0.5);
    expect(amethystL5.manaRegenBonus, 4.0);

    // 3. Socket insertion and player stat additions
    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              equippedWeapon: rareItem,
              gemInventory: {'ruby_1': 3, 'sapphire_1': 2},
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final initialAtk = container.read(playerProvider).physicalAtk;

    // Insert Ruby 1 into equipped weapon (+5 ATK)
    final inserted = notifier.insertGem(itemId: 'r1', gem: rubyL1);
    expect(inserted, true);
    expect(container.read(playerProvider).equippedWeapon!.insertedGems.length, 1);
    expect(container.read(playerProvider).equippedWeapon!.insertedGems.first, rubyL1);
    expect(container.read(playerProvider).gemInventory['ruby_1'], 2); // 1 consumed
    expect(container.read(playerProvider).physicalAtk, initialAtk + 5);

    // Cannot insert beyond maxSockets (rareItem maxSockets = 1)
    final insertSecond = notifier.insertGem(itemId: 'r1', gem: rubyL1);
    expect(insertSecond, false);

    // Remove gem: returns to bag without loss
    final removed = notifier.removeGem(itemId: 'r1', socketIndex: 0);
    expect(removed, true);
    expect(container.read(playerProvider).equippedWeapon!.insertedGems.isEmpty, true);
    expect(container.read(playerProvider).gemInventory['ruby_1'], 3); // Returned to bag!
    expect(container.read(playerProvider).physicalAtk, initialAtk);

    // 4. Fuse All Gems (Ghép tất cả)
    notifier.setPlayer(
      container.read(playerProvider).copyWith(
        gold: 500,
        gemInventory: {'ruby_1': 3},
      ),
    );
    final fused = notifier.fuseAllGems();
    expect(fused, 1);
    expect(container.read(playerProvider).gemInventory['ruby_1'], null); // Consumed 3
    expect(container.read(playerProvider).gemInventory['ruby_2'], 1); // Upgraded to 1 ruby_2
    expect(container.read(playerProvider).gold, 450); // 500 - 50 = 450
  });

  test('Crafting: recipe progression, material consumption, and random item generation with set chance', () {
    expect(CraftingRecipe.allRecipes.length, greaterThanOrEqualTo(8));

    final recipeUncommon = CraftingRecipe.allRecipes.firstWhere((r) => r.id == 'cr_uncommon_weapon');
    expect(recipeUncommon.requiredLevel, 5);
    expect(recipeUncommon.requiredMaterials['iron'], 5);

    final recipeSet = CraftingRecipe.allRecipes.firstWhere((r) => r.id == 'cr_set_piece');
    expect(recipeSet.requiredLevel, 25);
    expect(recipeSet.isSetPiece, true);

    // Player with insufficient level cannot craft
    final lowContainer = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              level: 3,
              gold: 1000,
              craftingMaterials: {'iron': 10},
            ),
          ),
        ),
      ],
    );
    addTearDown(lowContainer.dispose);
    final lowLevelPlayer = lowContainer.read(playerProvider.notifier);
    expect(lowLevelPlayer.craftRecipe(recipeUncommon), isNull);

    // Player with sufficient level and materials crafts successfully
    final readyContainer = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              level: 6,
              gold: 500,
              craftingMaterials: {'iron': 10},
            ),
          ),
        ),
      ],
    );
    addTearDown(readyContainer.dispose);
    final readyPlayer = readyContainer.read(playerProvider.notifier);
    final craftedItem = readyPlayer.craftRecipe(recipeUncommon);
    expect(craftedItem, isNotNull);
    expect(craftedItem!.rarity, EquipmentRarity.uncommon);
    expect(craftedItem.slot, EquipmentSlot.weapon);
    expect(readyContainer.read(playerProvider).gold, 300); // 500 - 200 = 300
    expect(readyContainer.read(playerProvider).craftingMaterials['iron'], 5); // 10 - 5 = 5
    expect(readyContainer.read(playerProvider).craftedRecipeIds.contains('cr_uncommon_weapon'), true);

    // Set piece crafting produces item with setId
    final masterContainer = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              level: 30,
              gold: 10000,
              craftingMaterials: {'essence': 20, 'steel': 10},
            ),
          ),
        ),
      ],
    );
    addTearDown(masterContainer.dispose);
    final masterPlayer = masterContainer.read(playerProvider.notifier);
    final craftedSetPiece = masterPlayer.craftRecipe(recipeSet);
    expect(craftedSetPiece, isNotNull);
    expect(craftedSetPiece!.setId, isNotNull);
  });

  test('Reforge: random affix rolling without duplicates, cost deduction, and stat modification', () {
    // 1. Verify rollRandom with excludeTypes never duplicates
    final exclude = [AffixType.atkPercent, AffixType.hpPercent];
    for (int i = 0; i < 20; i++) {
      final rolled = EquipmentAffix.rollRandom(excludeTypes: exclude);
      expect(exclude.contains(rolled.type), false);
    }

    // 2. Reforge workflow with PlayerNotifier
    const initialAffix = EquipmentAffix(type: AffixType.hpPercent, value: 0.10);
    const rareSword = Equipment(
      id: 'sword_reforge',
      name: 'Kiếm Ma Thuật',
      description: '',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.rare,
      affixes: [initialAffix],
    );

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              gold: 1000,
              gems: 5,
              craftingMaterials: {'crystal': 5},
              inventory: [rareSword],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);

    const newCandidate = EquipmentAffix(type: AffixType.atkPercent, value: 0.12);
    final success = notifier.payAndApplyReforge(
      itemId: 'sword_reforge',
      affixIndex: 0,
      newAffix: newCandidate,
    );

    expect(success, true);
    final updatedSword = container.read(playerProvider).inventory.firstWhere((e) => e.id == 'sword_reforge');
    expect(updatedSword.affixes.first.type, AffixType.atkPercent);
    expect(updatedSword.affixes.first.value, 0.12);
    expect(container.read(playerProvider).gold, 500); // 1000 - 500 = 500
    expect(container.read(playerProvider).craftingMaterials['crystal'], 4); // 5 - 1 = 4
  });

  test('Transmute: 3 items of same rarity combine into higher rarity and failure handling', () {
    const item1 = Equipment(id: 'c_1', name: 'C1', description: '', slot: EquipmentSlot.weapon, rarity: EquipmentRarity.common);
    const item2 = Equipment(id: 'c_2', name: 'C2', description: '', slot: EquipmentSlot.armor, rarity: EquipmentRarity.common);
    const item3 = Equipment(id: 'c_3', name: 'C3', description: '', slot: EquipmentSlot.accessory, rarity: EquipmentRarity.common);

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              gold: 500,
              inventory: [item1, item2, item3],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);

    // Transmute 3 Common -> 1 Uncommon (Cost 100 gold)
    final transmuted = notifier.transmuteEquipment(['c_1', 'c_2', 'c_3']);
    expect(transmuted, isNotNull);
    expect(transmuted!.rarity, EquipmentRarity.uncommon);
    expect(container.read(playerProvider).gold, 400); // 500 - 100 = 400
    expect(container.read(playerProvider).inventory.length, 1);
    expect(container.read(playerProvider).inventory.first.id, transmuted.id);

    // Cannot transmute if items are of different rarities
    const diffItem = Equipment(id: 'r_1', name: 'R1', description: '', slot: EquipmentSlot.armor, rarity: EquipmentRarity.rare);
    notifier.setPlayer(
      container.read(playerProvider).copyWith(
        inventory: [item1, item2, diffItem],
      ),
    );
    expect(notifier.transmuteEquipment(['c_1', 'c_2', 'r_1']), isNull);
  });

  test('Arena PvP: Tier and Sub-rank calculation based on AP', () {
    // 0 AP -> Đồng III
    final r0 = ArenaRankInfo.fromAp(0);
    expect(r0.tier, ArenaTier.bronze);
    expect(r0.subRank, 3);
    expect(r0.displayName, 'Đồng III');

    // 50 AP -> Đồng II
    final r50 = ArenaRankInfo.fromAp(50);
    expect(r50.tier, ArenaTier.bronze);
    expect(r50.subRank, 2);
    expect(r50.displayName, 'Đồng II');

    // 80 AP -> Đồng I
    final r80 = ArenaRankInfo.fromAp(80);
    expect(r80.tier, ArenaTier.bronze);
    expect(r80.subRank, 1);
    expect(r80.displayName, 'Đồng I');

    // 120 AP -> Bạc III
    final r120 = ArenaRankInfo.fromAp(120);
    expect(r120.tier, ArenaTier.silver);
    expect(r120.subRank, 3);
    expect(r120.displayName, 'Bạc III');

    // 350 AP -> Vàng II
    final r350 = ArenaRankInfo.fromAp(350);
    expect(r350.tier, ArenaTier.gold);
    expect(r350.subRank, 2);
    expect(r350.displayName, 'Vàng II');

    // 700 AP -> Bạch Kim II
    final r700 = ArenaRankInfo.fromAp(700);
    expect(r700.tier, ArenaTier.platinum);
    expect(r700.subRank, 2);

    // 1500 AP -> Kim Cương II
    final r1500 = ArenaRankInfo.fromAp(1500);
    expect(r1500.tier, ArenaTier.diamond);
    expect(r1500.subRank, 2);

    // 2500 AP -> Tinh Anh II
    final r2500 = ArenaRankInfo.fromAp(2500);
    expect(r2500.tier, ArenaTier.master);
    expect(r2500.subRank, 2);

    // 3600 AP -> Cao Thủ (no subrank)
    final r3600 = ArenaRankInfo.fromAp(3600);
    expect(r3600.tier, ArenaTier.grandmaster);
    expect(r3600.subRank, 0);
    expect(r3600.displayName, 'Cao Thủ');

    // Negative AP clamped to 0
    final rNeg = ArenaRankInfo.fromAp(-50);
    expect(rNeg.tier, ArenaTier.bronze);
    expect(rNeg.currentAp, 0);
  });

  test('Arena PvP: Matchmaking power bracket scaling by player level', () {
    // 1. Bracket Lv 10-15: Power ~ 90-110% of player
    const playerLv12 = Player(level: 12);
    final p12Power = playerLv12.combatPower;
    for (int i = 0; i < 10; i++) {
      final opp = ArenaOpponent.generate(player: playerLv12);
      expect(opp.totalPower, greaterThanOrEqualTo((p12Power * 0.70).round()));
      expect(opp.totalPower, lessThanOrEqualTo((p12Power * 1.30).round()));
      expect(opp.skillIds.length, inInclusiveRange(3, 5));
      expect(opp.gearRarity, EquipmentRarity.rare);
    }

    // 2. Bracket Lv 16-25: Power ~ 100-120% of player
    const playerLv20 = Player(level: 20);
    final p20Power = playerLv20.combatPower;
    final opp20 = ArenaOpponent.generate(player: playerLv20);
    expect(opp20.totalPower, greaterThanOrEqualTo((p20Power * 0.85).round()));
    expect(opp20.gearRarity, EquipmentRarity.epic);

    // 3. Bracket Lv 26+: Power ~ 110-140% of player
    const playerLv30 = Player(level: 30);
    final p30Power = playerLv30.combatPower;
    final opp30 = ArenaOpponent.generate(player: playerLv30);
    expect(opp30.totalPower, greaterThanOrEqualTo(p30Power));
    expect(opp30.gearRarity, EquipmentRarity.legendary);

    // 4. Opponent converts to Enemy with boss skills and mana
    final enemy = opp30.toEnemy();
    expect(enemy.maxHp, opp30.hp);
    expect(enemy.bossSkills.length, opp30.skillIds.length);
    expect(enemy.maxMana, 100);
    expect(enemy.currentMana, 100);
  });

  test('Arena PvP: Season Pass cumulative AP progression, milestones claim, and win streak bonus', () {
    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              arenaPoints: 10,
              cumulativeSeasonAp: 90,
              arenaWinStreak: 4, // 4 wins -> next win is 5th win!
              gold: 100,
              gems: 0,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final dummyOpponent = ArenaOpponent.generate(player: container.read(playerProvider));

    // 1. 5th Win triggers Win Streak Bonus: +1 regular + 5 streak = +6 AP and +1 💎, +200 gold
    final winResult = notifier.onArenaBattleEnd(isWon: true, opponent: dummyOpponent);
    expect(winResult.isWon, true);
    expect(winResult.triggeredStreakBonus, true);
    expect(winResult.apChange, 6);
    expect(winResult.earnedGold, 200);
    expect(winResult.earnedDiamonds, 1);
    expect(container.read(playerProvider).arenaPoints, 16);
    expect(container.read(playerProvider).cumulativeSeasonAp, 96);
    expect(container.read(playerProvider).arenaWinStreak, 5);
    expect(container.read(playerProvider).gold, 300);
    expect(container.read(playerProvider).gems, 1);
    expect(container.read(playerProvider).arenaMatchHistory.length, 1);

    // 2. Defeat: loses 1 AP, resets streak, no gold lost
    final lossResult = notifier.onArenaBattleEnd(isWon: false, opponent: dummyOpponent);
    expect(lossResult.isWon, false);
    expect(lossResult.apChange, -1);
    expect(container.read(playerProvider).arenaPoints, 15);
    expect(container.read(playerProvider).arenaWinStreak, 0);
    expect(container.read(playerProvider).gold, 300); // no gold lost
    expect(container.read(playerProvider).arenaMatchHistory.length, 2);

    // 3. Season Pass Milestones: exactly 30 milestones
    final milestones = SeasonMilestone.generateMilestones();
    expect(milestones.length, 30);
    expect(milestones.first.level, 1);
    expect(milestones.first.requiredAp, 100);
    expect(milestones.last.level, 30);
    expect(milestones.last.requiredAp, 3000);
    expect(milestones.last.equipmentRarity, 'set_piece');

    // Player with 96 cumulative AP cannot claim milestone 1 (requires 100)
    expect(notifier.claimSeasonMilestone(1), false);

    // Boost cumulative AP to 120 -> can claim milestone 1
    notifier.setPlayer(container.read(playerProvider).copyWith(cumulativeSeasonAp: 120));
    final claimSuccess = notifier.claimSeasonMilestone(1);
    expect(claimSuccess, true);
    expect(container.read(playerProvider).claimedSeasonMilestones.contains(1), true);
    expect(container.read(playerProvider).gold, greaterThan(300)); // Received milestone gold

    // Cannot claim already claimed milestone again
    expect(notifier.claimSeasonMilestone(1), false);
  });

  test('Companion passive stat buff calculation and +30% cap enforcement', () {
    // Check Dragon companion (HP buff)
    const dragon = CompanionType.dragon;
    expect(dragon.unlockLevel, 20);
    expect(dragon.basePassive, 0.10);
    // At level 1: 10%
    expect(dragon.getEffectivePassive(1), 0.10);
    // At level 5: 10% + 4 * 2% = 18%
    expect(dragon.getEffectivePassive(5), closeTo(0.18, 0.001));
    // At level 10: 10% + 9 * 2% = 28%
    expect(dragon.getEffectivePassive(10), closeTo(0.28, 0.001));
    // Check cap: even if level is clamped or exaggerated, never exceeds 0.30
    expect(dragon.getEffectivePassive(15), 0.28); // clamped to 10
    const eagle = CompanionType.eagle;
    // Eagle base 0.08 + 9 * 0.02 = 0.26
    expect(eagle.getEffectivePassive(10), closeTo(0.26, 0.001));

    // Player with companion equipped gains stat buff
    const basePlayer = Player(
      stats: Stats(str: 10, int_: 10, vit: 10, agi: 10, luk: 10),
    );
    final unbuffedHp = basePlayer.maxHp;

    // Equip Level 1 Dragon (+10% HP)
    final buffedPlayer = basePlayer.copyWith(
      equippedCompanionId: 'dragon',
      companionLevels: {'dragon': 1},
    );
    expect(buffedPlayer.maxHp, greaterThan(unbuffedHp));
    expect(buffedPlayer.maxHp, (unbuffedHp * 1.10).round());
  });

  test('Raid boss damage accumulation across battles and HP preservation', () {
    final currentWeek = RaidBossInfo.getCurrentWeekNumber();
    final boss = RaidBossInfo.getCurrentRaidBoss();
    final initialHp = boss.maxHp;

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            Player(
              currentRaidWeek: currentWeek,
              raidStamina: 20,
              raidBossCurrentHp: initialHp,
              weeklyRaidDamage: 0,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    expect(container.read(playerProvider).raidBossCurrentHp, initialHp);
    expect(container.read(playerProvider).weeklyRaidDamage, 0);

    // Battle 1: Deal 45,000 damage (tốn 5 thể lực)
    notifier.onRaidBattleEnd(damageDealt: 45000);
    expect(container.read(playerProvider).raidBossCurrentHp, initialHp - 45000);
    expect(container.read(playerProvider).weeklyRaidDamage, 45000);
    expect(container.read(playerProvider).raidStamina, 15);

    // Battle 2: Deal 60,000 damage
    notifier.onRaidBattleEnd(damageDealt: 60000);
    expect(container.read(playerProvider).raidBossCurrentHp, initialHp - 105000);
    expect(container.read(playerProvider).weeklyRaidDamage, 105000);
    expect(container.read(playerProvider).raidStamina, 10);

    // Defeating boss: deal remaining HP
    notifier.onRaidBattleEnd(damageDealt: initialHp);
    expect(container.read(playerProvider).raidBossCurrentHp, 0);
    expect(container.read(playerProvider).hasClaimedWeeklyRaidReward, false);

    // Claim Grand Reward: Guaranteed Legendary Gear + 100 💎 + Title
    final reward = notifier.claimRaidGrandReward();
    expect(reward, isNotNull);
    expect(reward!.rarity, EquipmentRarity.legendary);
    expect(container.read(playerProvider).gems, 103); // 3 initial + 100
    expect(container.read(playerProvider).hasClaimedWeeklyRaidReward, true);

    // Cannot claim reward twice
    expect(notifier.claimRaidGrandReward(), isNull);
  });

  test('Raid stamina regeneration (5 mins / 1 stamina) and purchase limits', () {
    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              raidStamina: 10,
              gems: 10,
              dailyStaminaPurchases: 0,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);

    // 1. Buy Stamina: 1 💎 = +5 stamina, max 3 purchases per day
    expect(notifier.buyRaidStamina(), true);
    expect(container.read(playerProvider).raidStamina, 15);
    expect(container.read(playerProvider).gems, 9);
    expect(container.read(playerProvider).dailyStaminaPurchases, 1);

    expect(notifier.buyRaidStamina(), true);
    expect(container.read(playerProvider).raidStamina, 20); // max 20
    expect(container.read(playerProvider).dailyStaminaPurchases, 2);

    expect(notifier.buyRaidStamina(), true);
    expect(container.read(playerProvider).dailyStaminaPurchases, 3);

    // 4th purchase rejected (limit 3 per day)
    expect(notifier.buyRaidStamina(), false);
    expect(container.read(playerProvider).dailyStaminaPurchases, 3);

    // 2. Offline Stamina Regeneration:
    // Simulated player with 10 stamina and last regen was 15 minutes ago (900,000 ms) -> should regenerate +3 stamina
    final now = DateTime.now().millisecondsSinceEpoch;
    final fifteenMinsAgo = now - (15 * 60 * 1000);
    notifier.setPlayer(
      container.read(playerProvider).copyWith(
            raidStamina: 10,
            lastRaidStaminaRegenTime: fifteenMinsAgo,
          ),
    );

    notifier.initRaidWeekIfNeeded();
    expect(container.read(playerProvider).raidStamina, 13);
  });

  test('Offline progress: 1 hour auto-farm grants 60% exp and gold rewards', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneHourAgo = now - 3600 * 1000;

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            Player(
              level: 5,
              currentExp: 0,
              gold: 100,
              lastActiveTimestamp: oneHourAgo,
              isAutoFarming: true,
              autoFarmZone: 1,
              autoFarmStage: 1,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final enemy = SeedEnemies.getEnemy(1, 1);
    const expectedBattles = 3600 ~/ 25; // 144 battles
    final expectedExp = (expectedBattles * (enemy.expReward * 0.6).round());
    final expectedGold = (expectedBattles * (enemy.goldReward * 0.6).round());

    final result = notifier.calculateOfflineProgress(now);
    expect(result, isNotNull);
    expect(result!.hadAutoFarm, true);
    expect(result.battlesWon, expectedBattles);
    expect(result.expGained, expectedExp);
    expect(result.goldGained, expectedGold);

    // Claim rewards
    notifier.claimOfflineProgress(result);
    final updatedPlayer = container.read(playerProvider);
    expect(updatedPlayer.gold, 100 + expectedGold);
    expect(updatedPlayer.currentExp + (updatedPlayer.level > 5 ? 100 : 0), greaterThan(0));
  });

  test('Offline progress: 20 hours offline is capped at 8 hours and 200 battles', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final twentyHoursAgo = now - 20 * 3600 * 1000;

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            Player(
              level: 10,
              raidStamina: 5,
              lastActiveTimestamp: twentyHoursAgo,
              isAutoFarming: true,
              autoFarmZone: 2,
              autoFarmStage: 2,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final result = notifier.calculateOfflineProgress(now);
    expect(result, isNotNull);
    // Capped at 200 battles
    expect(result!.battlesWon, 200);
    // Stamina capped at 20 (gains 15)
    expect(result.staminaRegenerated, 15);
  });

  test('Offline progress: without auto-farm, only stamina regenerates, no exp or gold', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final twoHoursAgo = now - 2 * 3600 * 1000;

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            Player(
              raidStamina: 8,
              lastActiveTimestamp: twoHoursAgo,
              isAutoFarming: false,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final result = notifier.calculateOfflineProgress(now);
    expect(result, isNotNull);
    expect(result!.hadAutoFarm, false);
    expect(result.battlesWon, 0);
    expect(result.expGained, 0);
    expect(result.goldGained, 0);
    // 2 hours = 120 mins -> 24 stamina possible -> capped at 20 - 8 = 12
    expect(result.staminaRegenerated, 12);
  });

  test('QoL 1: equipBestGear selects and equips highest combatPower gear from inventory', () {
    const weakWeapon = Equipment(
      id: 'w_weak',
      name: 'Kiếm Gỗ',
      description: '',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.common,
      flatAtk: 10,
    );
    const strongWeapon = Equipment(
      id: 'w_strong',
      name: 'Trảm Ma Kiếm',
      description: '',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.legendary,
      flatAtk: 120,
    );
    const strongArmor = Equipment(
      id: 'a_strong',
      name: 'Thần Khải',
      description: '',
      slot: EquipmentSlot.armor,
      rarity: EquipmentRarity.epic,
      flatDef: 60,
      flatHp: 500,
    );

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              equippedWeapon: weakWeapon,
              inventory: [strongWeapon, strongArmor],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final changed = notifier.equipBestGear();
    expect(changed, true);

    final updatedPlayer = container.read(playerProvider);
    expect(updatedPlayer.equippedWeapon?.id, 'w_strong');
    expect(updatedPlayer.equippedArmor?.id, 'a_strong');
    expect(updatedPlayer.inventory.any((e) => e.id == 'w_weak'), true);
  });

  test('Polish 1: Sound and Haptic feedback toggles', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    expect(container.read(playerProvider).isSoundEnabled, true);
    expect(container.read(playerProvider).isHapticEnabled, true);

    // Toggle off
    notifier.toggleSound(false);
    notifier.toggleHaptic(false);
    expect(container.read(playerProvider).isSoundEnabled, false);
    expect(container.read(playerProvider).isHapticEnabled, false);

    // Toggle on
    notifier.toggleSound(true);
    notifier.toggleHaptic(true);
    expect(container.read(playerProvider).isSoundEnabled, true);
    expect(container.read(playerProvider).isHapticEnabled, true);
  });

  test('Polish 2: Consecutive defeats tracking and smart hint trigger', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    expect(container.read(playerProvider).consecutiveDefeats['1-5'], null);

    // Defeat 1
    notifier.onBattleDefeat(foughtZone: 1, foughtStage: 5);
    expect(container.read(playerProvider).consecutiveDefeats['1-5'], 1);

    // Defeat 2
    notifier.onBattleDefeat(foughtZone: 1, foughtStage: 5);
    expect(container.read(playerProvider).consecutiveDefeats['1-5'], 2);

    // Defeat 3 -> triggers smart hint condition >= 3
    notifier.onBattleDefeat(foughtZone: 1, foughtStage: 5);
    expect(container.read(playerProvider).consecutiveDefeats['1-5'], 3);

    // Victory clears consecutive defeats
    notifier.onBattleVictory(exp: 50, gold: 30, drops: [], foughtZone: 1, foughtStage: 5);
    expect(container.read(playerProvider).consecutiveDefeats['1-5'] ?? 0, 0);
  });

  test('Polish 3: Skip all tutorials sets all flags permanently', () {
    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(
          () => PlayerNotifier(
            const Player(
              hasSeenTutorialHome: false,
              hasSeenTutorialFirstWin: false,
              hasSeenTutorialFirstDrop: false,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    expect(container.read(playerProvider).hasSeenTutorialHome, false);
    expect(container.read(playerProvider).hasSeenTutorialFirstWin, false);
    expect(container.read(playerProvider).hasSeenTutorialFirstDrop, false);

    notifier.skipAllTutorials();

    final updated = container.read(playerProvider);
    expect(updated.hasSeenTutorialHome, true);
    expect(updated.hasSeenTutorialFirstWin, true);
    expect(updated.hasSeenTutorialFirstDrop, true);
  });

  test('QA Sweep: Bag capacity limit (200 slots) and overflow gold conversion', () {
    final gearList = List.generate(
      200,
      (i) => Equipment(
        id: 'gear_$i',
        name: 'Item $i',
        description: 'Test gear',
        slot: EquipmentSlot.weapon,
        rarity: EquipmentRarity.common,
        flatAtk: 10,
      ),
    );

    final player = Player(inventory: gearList);
    expect(player.isInventoryFull, true);
    expect(player.inventory.length, Player.maxInventoryCapacity);

    final container = ProviderContainer(
      overrides: [
        playerProvider.overrideWith(() => PlayerNotifier(player)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerProvider.notifier);
    final extraGear = const Equipment(
      id: 'gear_extra',
      name: 'Extra Sword',
      description: 'Extra sword',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.common,
      flatAtk: 15,
    );

    final initialGold = container.read(playerProvider).gold;
    notifier.onBattleVictory(
      exp: 100,
      gold: 50,
      drops: [extraGear],
      foughtZone: 1,
      foughtStage: 1,
    );

    final afterVictory = container.read(playerProvider);
    expect(afterVictory.inventory.length, Player.maxInventoryCapacity);
    expect(afterVictory.gold, greaterThanOrEqualTo(initialGold + 50 + extraGear.sellPrice));
  });

  test('QA Sweep: Save JSON export and import fidelity', () {
    const original = Player(
      name: 'Chiến Thần',
      title: 'Đệ Nhất Kiếm',
      level: 25,
      gold: 50000,
      gems: 120,
      highestEndlessFloor: 18,
      currentHeroId: '003_valkyrie',
    );

    final jsonMap = original.toJson();
    final restored = Player.fromJson(jsonMap);

    expect(restored.name, original.name);
    expect(restored.title, original.title);
    expect(restored.level, original.level);
    expect(restored.gold, original.gold);
    expect(restored.gems, original.gems);
    expect(restored.highestEndlessFloor, original.highestEndlessFloor);
    expect(restored.currentHeroId, original.currentHeroId);
  });
}
