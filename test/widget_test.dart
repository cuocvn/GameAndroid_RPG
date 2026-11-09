import 'package:flutter_test/flutter_test.dart';
import 'package:game_and/models/equipment.dart';
import 'package:game_and/models/player.dart';
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
}
