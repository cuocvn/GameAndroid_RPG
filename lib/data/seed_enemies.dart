import 'dart:math';
import '../models/enemy.dart';
import 'asset_mapping.dart';

class ZoneInfo {
  final int id;
  final String name;
  final String description;
  final String iconEmoji;
  final String bgAsset;
  final int stageCount;

  const ZoneInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.bgAsset,
    required this.stageCount,
  });
}

class SeedEnemies {
  static const List<ZoneInfo> zones = [
    ZoneInfo(
      id: 1,
      name: 'Rừng Ma Quái',
      description: 'Khu rừng khởi đầu hiểm trở. Quái vật rình rập, boss khổng lồ đầy uy lực.',
      iconEmoji: '🌲',
      bgAsset: AssetMapping.bgMapDefault,
      stageCount: 5,
    ),
    ZoneInfo(
      id: 2,
      name: 'Dung Nham Rực Lửa',
      description: 'Vùng nham thạch sôi sục, quái vật có lớp vỏ dung nham cứng cáp (HP x1.8, ATK x1.55).',
      iconEmoji: '🌋',
      bgAsset: 'assets/img/characters/013_Cyra_MID.jpg',
      stageCount: 5,
    ),
    ZoneInfo(
      id: 3,
      name: 'Đỉnh Núi Băng Giá',
      description: 'Lớp băng cổ xưa ban tặng quái vật [Kháng Phép 40%] — cần kết hợp build vật lý!',
      iconEmoji: '❄️',
      bgAsset: 'assets/img/characters/009_Aurora_TOP.jpg',
      stageCount: 5,
    ),
    ZoneInfo(
      id: 4,
      name: 'Hầm Ngục Hắc Ám',
      description: 'Tử khí nồng nặc bao phủ, quái vật sở hữu nội tại [Phản Đòn 20%] sát thương phải gánh chịu.',
      iconEmoji: '💀',
      bgAsset: 'assets/img/characters/010_Lucia_JUNG.webp',
      stageCount: 5,
    ),
    ZoneInfo(
      id: 5,
      name: 'Tháp Hủy Diệt',
      description: 'Vực thẳm tuyệt vọng nơi ác ma sở hữu ma lực [Hồi Máu 5%/giây] liên tục!',
      iconEmoji: '👑',
      bgAsset: 'assets/img/characters/005_Carmilla_JUNG.jpg',
      stageCount: 5,
    ),
  ];

  static List<Enemy> getEnemiesForZone(int zoneId) {
    switch (zoneId) {
      case 1:
        return [
          Enemy(
            id: 'z1_m1',
            name: 'Yêu Tinh Rừng Nhỏ',
            zone: 1,
            stage: 1,
            maxHp: 340,
            atk: 32,
            def: 5,
            agi: 4,
            expReward: 30,
            goldReward: 20,
            imageAsset: AssetMapping.monsterZone1,
            fallbackEmoji: '👺',
          ),
          Enemy(
            id: 'z1_m2',
            name: 'Sói Hoang Nanh Nhọn',
            zone: 1,
            stage: 2,
            maxHp: 380,
            atk: 33,
            def: 6,
            agi: 5,
            expReward: 40,
            goldReward: 26,
            imageAsset: AssetMapping.monsterZone1,
            fallbackEmoji: '🐺',
            specialSkill: const EnemySkill(
              name: 'Cắn Xé',
              damageMultiplier: 1.3,
              cooldown: 4,
            ),
          ),
          Enemy(
            id: 'z1_m3',
            name: 'Thụ Tinh Quái Dị',
            zone: 1,
            stage: 3,
            maxHp: 420,
            atk: 36,
            def: 7,
            agi: 4,
            expReward: 50,
            goldReward: 34,
            imageAsset: AssetMapping.monsterZone1,
            fallbackEmoji: '🪵',
          ),
          Enemy(
            id: 'z1_m4',
            name: 'Dị Điểu Mãng Rừng',
            zone: 1,
            stage: 4,
            maxHp: 460,
            atk: 40,
            def: 8,
            agi: 6,
            critRate: 0.08,
            expReward: 65,
            goldReward: 45,
            imageAsset: AssetMapping.monsterZone1,
            fallbackEmoji: '🦅',
            specialSkill: const EnemySkill(
              name: 'Gió Lốc Xé Toạc',
              damageMultiplier: 1.4,
              cooldown: 4,
            ),
          ),
          Enemy(
            id: 'z1_boss',
            name: 'Trùm Rừng: Thú Vương Cuồng Nộ',
            zone: 1,
            stage: 5,
            isBoss: true,
            maxHp: 2040, // 6x quái thường cùng vùng
            atk: 72, // 2.2x quái thường
            def: 10, // +20% DEF
            agi: 5,
            critRate: 0.12,
            expReward: 200,
            goldReward: 160,
            imageAsset: AssetMapping.monsterZone1,
            fallbackEmoji: '👹',
            specialSkill: const EnemySkill(
              name: 'Gầm Thét Cuồng Nộ',
              damageMultiplier: 1.6,
              cooldown: 4,
            ),
          ),
        ];

      case 2: // HP = Z1 * 1.8 (~500 - 720), ATK = Z1 * 1.55 (~39 - 56)
        return [
          Enemy(
            id: 'z2_m1',
            name: 'Ấu Trùng Nham Thạch',
            zone: 2,
            stage: 1,
            maxHp: 500,
            atk: 39,
            def: 10,
            agi: 4,
            expReward: 85,
            goldReward: 60,
            imageAsset: AssetMapping.monsterZone2,
            fallbackEmoji: '🐛',
          ),
          Enemy(
            id: 'z2_m2',
            name: 'Báo Hỏa Ngục',
            zone: 2,
            stage: 2,
            maxHp: 580,
            atk: 43,
            def: 12,
            agi: 7,
            critRate: 0.10,
            expReward: 110,
            goldReward: 78,
            imageAsset: AssetMapping.monsterZone2,
            fallbackEmoji: '🐆',
            specialSkill: const EnemySkill(
              name: 'Vồ Chớp Nhoáng',
              damageMultiplier: 1.4,
              cooldown: 3,
            ),
          ),
          Enemy(
            id: 'z2_m3',
            name: 'Cự Thần Nhựa Sống',
            zone: 2,
            stage: 3,
            maxHp: 650,
            atk: 50,
            def: 14,
            agi: 3,
            expReward: 140,
            goldReward: 100,
            imageAsset: AssetMapping.monsterZone2,
            fallbackEmoji: '🗿',
          ),
          Enemy(
            id: 'z2_m4',
            name: 'Viêm Xà Hỏa Hải',
            zone: 2,
            stage: 4,
            maxHp: 720,
            atk: 56,
            def: 16,
            agi: 6,
            critRate: 0.12,
            expReward: 175,
            goldReward: 125,
            imageAsset: AssetMapping.monsterZone2,
            fallbackEmoji: '🐍',
          ),
          Enemy(
            id: 'z2_boss',
            name: 'Trùm Dung Nham: Hỏa Ma Vương Ifrit',
            zone: 2,
            stage: 5,
            isBoss: true,
            maxHp: 3900, // 6x quái thường
            atk: 123, // 2.2x quái thường
            def: 19, // +20% DEF
            agi: 6,
            critRate: 0.15,
            expReward: 420,
            goldReward: 340,
            imageAsset: AssetMapping.monsterZone2,
            fallbackEmoji: '🔥',
            specialSkill: const EnemySkill(
              name: 'Đại Hỏa Bạo',
              damageMultiplier: 1.7,
              cooldown: 4,
            ),
          ),
        ];

      case 3: // HP = Z2 * 1.8 (~900 - 1300), ATK = Z2 * 1.55 (~60 - 87), Kháng phép 40%
        return [
          Enemy(
            id: 'z3_m1',
            name: 'Tiểu Quỷ Băng Giá',
            zone: 3,
            stage: 1,
            maxHp: 900,
            atk: 60,
            def: 20,
            agi: 5,
            magicResistPercent: 0.40, // 40% kháng phép
            expReward: 230,
            goldReward: 170,
            imageAsset: AssetMapping.monsterZone3,
            fallbackEmoji: '🧊',
          ),
          Enemy(
            id: 'z3_m2',
            name: 'Hùng Băng Khổng Lồ',
            zone: 3,
            stage: 2,
            maxHp: 1050,
            atk: 67,
            def: 22,
            agi: 4,
            magicResistPercent: 0.40,
            expReward: 290,
            goldReward: 220,
            imageAsset: AssetMapping.monsterZone3,
            fallbackEmoji: '🐻',
          ),
          Enemy(
            id: 'z3_m3',
            name: 'Băng Vũ Nữ U Uất',
            zone: 3,
            stage: 3,
            maxHp: 1170,
            atk: 78,
            def: 24,
            agi: 8,
            critRate: 0.15,
            magicResistPercent: 0.40,
            expReward: 360,
            goldReward: 280,
            imageAsset: AssetMapping.monsterZone3,
            fallbackEmoji: '🧚‍♀️',
          ),
          Enemy(
            id: 'z3_m4',
            name: 'Cương Thiết Băng Long',
            zone: 3,
            stage: 4,
            maxHp: 1300,
            atk: 87,
            def: 26,
            agi: 6,
            magicResistPercent: 0.40,
            expReward: 440,
            goldReward: 350,
            imageAsset: AssetMapping.monsterZone3,
            fallbackEmoji: '🐉',
          ),
          Enemy(
            id: 'z3_boss',
            name: 'Trùm Băng Sơn: Cổ Thần Ymir',
            zone: 3,
            stage: 5,
            isBoss: true,
            maxHp: 7020, // 6x quái thường
            atk: 191, // 2.2x quái thường
            def: 31, // +20% DEF
            agi: 6,
            critRate: 0.18,
            magicResistPercent: 0.40,
            expReward: 950,
            goldReward: 780,
            imageAsset: AssetMapping.monsterZone3,
            fallbackEmoji: '❄️',
            specialSkill: const EnemySkill(
              name: 'Đóng Băng Vĩnh Cửu',
              damageMultiplier: 1.8,
              cooldown: 4,
            ),
          ),
        ];

      case 4: // HP = Z3 * 1.8, ATK = Z3 * 1.55, Phản đòn 20%
        return [
          Enemy(
            id: 'z4_m1',
            name: 'Kỵ Sĩ Hư Không',
            zone: 4,
            stage: 1,
            maxHp: 1000,
            atk: 68,
            def: 26,
            agi: 6,
            reflectDamagePercent: 0.20, // 20% phản đòn
            expReward: 560,
            goldReward: 430,
            imageAsset: AssetMapping.monsterZone4,
            fallbackEmoji: '🤺',
          ),
          Enemy(
            id: 'z4_m2',
            name: 'Phù Thủy Hắc Ám',
            zone: 4,
            stage: 2,
            maxHp: 1150,
            atk: 74,
            def: 28,
            agi: 7,
            critRate: 0.16,
            reflectDamagePercent: 0.20,
            expReward: 680,
            goldReward: 520,
            imageAsset: AssetMapping.monsterZone4,
            fallbackEmoji: '🧙‍♂️',
          ),
          Enemy(
            id: 'z4_m3',
            name: 'Oán Hồn Ngàn Năm',
            zone: 4,
            stage: 3,
            maxHp: 1300,
            atk: 82,
            def: 30,
            agi: 8,
            dodgeRate: 0.12,
            reflectDamagePercent: 0.20,
            expReward: 820,
            goldReward: 630,
            imageAsset: AssetMapping.monsterZone4,
            fallbackEmoji: '👻',
          ),
          Enemy(
            id: 'z4_m4',
            name: 'Huyết Ma Thủ Lĩnh',
            zone: 4,
            stage: 4,
            maxHp: 1450,
            atk: 90,
            def: 32,
            agi: 8,
            critRate: 0.18,
            reflectDamagePercent: 0.20,
            expReward: 980,
            goldReward: 760,
            imageAsset: AssetMapping.monsterZone4,
            fallbackEmoji: '🦇',
          ),
          Enemy(
            id: 'z4_boss',
            name: 'Trùm Vực Thẳm: Minh Vương Hades',
            zone: 4,
            stage: 5,
            isBoss: true,
            maxHp: 6000, // 6x quái thường
            atk: 155, // 2.2x quái thường
            def: 34, // +20% DEF
            agi: 6,
            critRate: 0.15,
            reflectDamagePercent: 0.20,
            expReward: 2100,
            goldReward: 1700,
            imageAsset: AssetMapping.monsterZone4,
            fallbackEmoji: '☠️',
            specialSkill: const EnemySkill(
              name: 'Lưỡi Hái Tử Thần',
              damageMultiplier: 1.5,
              cooldown: 4,
            ),
          ),
        ];

      case 5: // HP = Z4 * 1.8 (~2920 - 4200), ATK = Z4 * 1.55 (~144 - 209), Hồi máu 5%/giây
      default:
        return [
          Enemy(
            id: 'z5_m1',
            name: 'Cận Vệ Hỗn Mang',
            zone: 5,
            stage: 1,
            maxHp: 2920,
            atk: 144,
            def: 48,
            agi: 7,
            hpRegenPercentPerSecond: 0.05, // 5% hồi máu/giây
            expReward: 1250,
            goldReward: 980,
            imageAsset: AssetMapping.monsterZone5,
            fallbackEmoji: '🛡️',
          ),
          Enemy(
            id: 'z5_m2',
            name: 'Ác Ma Song Kiếm',
            zone: 5,
            stage: 2,
            maxHp: 3400,
            atk: 161,
            def: 52,
            agi: 9,
            critRate: 0.20,
            hpRegenPercentPerSecond: 0.05,
            expReward: 1520,
            goldReward: 1200,
            imageAsset: AssetMapping.monsterZone5,
            fallbackEmoji: '⚔️',
          ),
          Enemy(
            id: 'z5_m3',
            name: 'Hư Không Long Tộc',
            zone: 5,
            stage: 3,
            maxHp: 3780,
            atk: 188,
            def: 56,
            agi: 8,
            hpRegenPercentPerSecond: 0.05,
            expReward: 1850,
            goldReward: 1480,
            imageAsset: AssetMapping.monsterZone5,
            fallbackEmoji: '🐲',
          ),
          Enemy(
            id: 'z5_m4',
            name: 'Chiêm Tinh Tà Giáo',
            zone: 5,
            stage: 4,
            maxHp: 4200,
            atk: 209,
            def: 60,
            agi: 8,
            critRate: 0.22,
            hpRegenPercentPerSecond: 0.05,
            expReward: 2200,
            goldReward: 1800,
            imageAsset: AssetMapping.monsterZone5,
            fallbackEmoji: '🔮',
          ),
          Enemy(
            id: 'z5_boss',
            name: 'CHÚA TỂ TẬN THẾ: DIABLO MA VƯƠNG',
            zone: 5,
            stage: 5,
            isBoss: true,
            maxHp: 22680, // 6x quái thường
            atk: 460, // 2.2x quái thường
            def: 72, // +20% DEF
            agi: 8,
            critRate: 0.25,
            hpRegenPercentPerSecond: 0.05,
            expReward: 5000,
            goldReward: 4200,
            imageAsset: AssetMapping.monsterZone5,
            fallbackEmoji: '👑',
            specialSkill: const EnemySkill(
              name: 'Hủy Diệt Thế Giới',
              damageMultiplier: 2.2,
              cooldown: 4,
            ),
          ),
        ];
    }
  }

  static Enemy getEnemy(int zoneId, int stage) {
    if (zoneId == 99) {
      return generateEndlessEnemy(stage);
    }
    final list = getEnemiesForZone(zoneId);
    if (stage <= 0 || stage > list.length) {
      return list.first.clone();
    }
    return list[stage - 1].clone();
  }

  /// Endless Mode Generator: 1.25x scaling per floor with modifiers every 5 floors
  static Enemy generateEndlessEnemy(int floor) {
    final baseScale = pow(1.25, floor - 1).toDouble();
    final isBossFloor = (floor % 5 == 0);

    double magicResist = 0.0;
    double reflectDmg = 0.0;
    double hpRegen = 0.0;
    double critReduct = 0.0;
    bool doubleStrike = false;

    if (floor >= 5) {
      final modTier = (floor ~/ 5) % 5;
      switch (modTier) {
        case 1:
          magicResist = 0.35;
          break;
        case 2:
          reflectDmg = 0.20;
          break;
        case 3:
          hpRegen = 0.04;
          break;
        case 4:
          critReduct = 0.30;
          break;
        case 0:
          doubleStrike = true;
          break;
      }
    }

    final hp = (300 * baseScale * (isBossFloor ? 3.0 : 1.0)).round();
    final atk = (25 * baseScale * (isBossFloor ? 1.6 : 1.0)).round();

    return Enemy(
      id: 'endless_f$floor',
      name: isBossFloor ? 'Thủ Vệ Vô Tận Tầng $floor' : 'Bóng Ma Tầng $floor',
      zone: 99,
      stage: floor,
      isBoss: isBossFloor,
      maxHp: hp,
      atk: atk,
      def: 6 * baseScale,
      agi: 6.0,
      magicResistPercent: magicResist,
      reflectDamagePercent: reflectDmg,
      hpRegenPercentPerSecond: hpRegen,
      critReductionPercent: critReduct,
      doubleStrike: doubleStrike,
      expReward: (50 * baseScale).round(),
      goldReward: (35 * baseScale).round(),
      imageAsset: AssetMapping.monsterZone5,
      fallbackEmoji: isBossFloor ? '💀' : '👻',
    );
  }
}
