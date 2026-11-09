import 'package:flutter_test/flutter_test.dart';
import 'package:game_and/models/player.dart';
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

  test('Seed skills and enemies validation', () {
    expect(SeedSkills.allSkills.length, greaterThanOrEqualTo(9));
    expect(SeedEnemies.zones.length, 5);
    final zone1Enemies = SeedEnemies.getEnemiesForZone(1);
    expect(zone1Enemies.isNotEmpty, true);
    expect(zone1Enemies.last.isBoss, true);
  });
}
