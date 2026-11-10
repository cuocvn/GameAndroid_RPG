import 'package:flutter_test/flutter_test.dart';
import 'package:game_and/data/seed_enemies.dart';
import 'package:game_and/data/seed_equipment.dart';
import 'package:game_and/models/enemy.dart';
import 'package:game_and/models/player.dart';
import 'package:game_and/models/stats.dart';
import 'package:game_and/services/battle_service.dart';

bool runSimulation(Player player, Enemy enemy, {int maxTicks = 1200}) {
  bool? isWon;
  final service = BattleService(
    player: player,
    enemy: enemy,
    onStateChanged: (state) {
      if (state.isWon) isWon = true;
      if (state.isDefeated) isWon = false;
    },
    onBattleEnded: (state) {
      if (state.isWon) isWon = true;
      if (state.isDefeated) isWon = false;
    },
  );

  for (int i = 0; i < maxTicks; i++) {
    if (isWon != null) break;
    service.simulateTick(0.10);
  }

  return isWon == true;
}

void main() {
  group('Kiểm tra cân bằng độ khó game (Balance Tests)', () {
    test('1. Baseline Vùng 1: Quái thường khiến build kém mất ít nhất 40% HP', () {
      // Player build kém: không nâng điểm chỉ số, không trang bị, điểm phân tán sai
      const subOptimalPlayer = Player(
        level: 1,
        stats: Stats(str: 5, int_: 6, vit: 6, agi: 4, luk: 5), // Máu = 190
        equippedSkillIds: ['fireball'],
      );

      final enemy = SeedEnemies.getEnemy(1, 1); // Yêu Tinh Rừng Nhỏ (HP 300, ATK 28)
      int lowestHeroHp = subOptimalPlayer.maxHp;

      final service = BattleService(
        player: subOptimalPlayer,
        enemy: enemy,
        onStateChanged: (state) {
          if (state.heroHp < lowestHeroHp) {
            lowestHeroHp = state.heroHp;
          }
        },
        onBattleEnded: (_) {},
      );

      for (int i = 0; i < 400; i++) {
        service.simulateTick(0.10);
      }

      final hpLostRatio = (subOptimalPlayer.maxHp - lowestHeroHp) / subOptimalPlayer.maxHp;
      // Phải mất ít nhất 40% HP
      expect(hpLostRatio >= 0.40, isTrue,
          reason: 'Người chơi phải mất ít nhất 40% HP (thực tế mất ${(hpLostRatio * 100).toStringAsFixed(1)}%)');
    });

    test('2. Baseline Vùng 1: Boss Vùng 1 đánh bại người chơi chưa nâng cấp', () {
      const unupgradedPlayer = Player(
        level: 2,
        stats: Stats(str: 6, int_: 10, vit: 8, agi: 6, luk: 5), // Base stats
        equippedSkillIds: ['fireball', 'meteor'],
      );

      final boss1 = SeedEnemies.getEnemy(1, 5); // Thú Vương Cuồng Nộ (HP 2100, ATK 79)
      final won = runSimulation(unupgradedPlayer, boss1);

      expect(won, isFalse, reason: 'Boss Vùng 1 phải đánh bại người chơi chưa có trang bị nâng cấp!');
    });

    test('3. Build full INT + Thiên Thạch KHÔNG THỂ qua Vùng 3 do Kháng Phép 40%', () {
      // Build thuần phép: All-in INT, máu giấy (VIT 8, HP ~ 220)
      const pureIntMage = Player(
        level: 12,
        stats: Stats(str: 5, int_: 40, vit: 8, agi: 7, luk: 5),
        skillLevels: {
          'meteor': 3,
          'fireball': 3,
        },
        equippedSkillIds: ['fireball', 'meteor'],
      );

      final zone3Boss = SeedEnemies.getEnemy(3, 5); // Cổ Thần Ymir: HP 7020, Kháng phép 40%, ATK 191
      final won = runSimulation(pureIntMage, zone3Boss);

      expect(won, isFalse, reason: 'Build full INT phải thất bại ở Vùng 3 do bị giảm 40% sát thương phép!');
    });

    test('4. Build full STR + Trảm Thép KHÔNG THỂ thắng Boss Vùng 5 (Diablo) do Hồi Máu 5%/giây', () {
      // Build thuần vật lý, không có hồi phục hay hiệu ứng đốt kéo máu
      const pureStrWarrior = Player(
        level: 22,
        stats: Stats(str: 60, int_: 5, vit: 18, agi: 8, luk: 5),
        skillLevels: {
          'flame_slash': 4,
        },
        equippedSkillIds: ['flame_slash'],
      );

      final diablo = SeedEnemies.getEnemy(5, 5); // Diablo HP 22680, hồi 1134 HP/s, ATK 460
      final won = runSimulation(pureStrWarrior, diablo);

      expect(won, isFalse,
          reason: 'Build thuần STR không thể thắng Diablo vì tốc độ hồi máu 5%/giây và đòn đánh cực khủng!');
    });

    test('5. Build full VIT (Tank) PHẢI THẮNG Boss Vùng 4 (Minh Vương Hades)', () {
      // Tanker Lv20 trang bị đồ phòng thủ và khiên bảo vệ, chịu đựng phản đòn 20%
      final weapon = SeedEquipment.getById('flame_blade'); // Kiếm Viêm Long (+65 ATK, +16 STR)
      final armor = SeedEquipment.getById('flame_robe'); // Áo choàng Viêm Ma (+300 HP, +22 DEF, +14 VIT)
      final accessory = SeedEquipment.getById('amulet_rune'); // Dây chuyền Cổ Ngữ

      final vitTanker = Player(
        level: 20,
        stats: const Stats(str: 25, int_: 5, vit: 55, agi: 8, luk: 5),
        equippedWeapon: weapon,
        equippedArmor: armor,
        equippedAccessory: accessory,
        skillLevels: const {
          'flame_slash': 5,
          'vital_body': 5,
          'fire_shield': 4,
          'holy_heal': 4,
        },
        equippedSkillIds: const ['flame_slash', 'fire_shield', 'holy_heal'],
      );

      final zone4Boss = SeedEnemies.getEnemy(4, 5); // Hades HP 6000, Phản đòn 20%
      final won = runSimulation(vitTanker, zone4Boss, maxTicks: 2500);

      expect(won, isTrue, reason: 'Tanker full VIT với giáp và khiên phải chịu được phản đòn để hạ Hades!');
    });
  });
}
