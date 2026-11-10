import 'package:flutter_test/flutter_test.dart';
import 'package:game_and/models/equipment.dart';
import 'package:game_and/models/player.dart';
import 'package:game_and/models/stats.dart';
import 'package:game_and/models/skill.dart';
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
}
