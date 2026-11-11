import 'package:flutter_test/flutter_test.dart';
import 'package:game_and/models/equipment.dart';
import 'package:game_and/models/player.dart';
import 'package:game_and/models/stats.dart';
import 'package:game_and/models/skill.dart';
import 'package:game_and/data/seed_equipment.dart';
import 'package:game_and/data/seed_skills.dart';
import 'package:game_and/data/seed_enemies.dart';

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
}
