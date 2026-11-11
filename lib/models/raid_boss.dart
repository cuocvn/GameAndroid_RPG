import 'dart:math';
import '../data/asset_mapping.dart';
import 'enemy.dart';

class RaidBossInfo {
  final int weekIndex; // 0, 1, 2
  final String id;
  final String name;
  final String title;
  final String icon;
  final int maxHp;
  final int atk;
  final double def;
  final double magicResist;
  final double lifestealPercent;
  final String imageAsset;
  final String grandTitle;
  final List<EnemySkill> skills;

  const RaidBossInfo({
    required this.weekIndex,
    required this.id,
    required this.name,
    required this.title,
    required this.icon,
    required this.maxHp,
    required this.atk,
    required this.def,
    this.magicResist = 0.0,
    this.lifestealPercent = 0.0,
    required this.imageAsset,
    required this.grandTitle,
    required this.skills,
  });

  static const List<RaidBossInfo> allBosses = [
    RaidBossInfo(
      weekIndex: 0,
      id: 'raid_ragnarok',
      name: 'Rồng Hỗn Mang Ragnarok',
      title: 'Hắc Long Diệt Thế',
      icon: '🐲',
      maxHp: 500000,
      atk: 450,
      def: 80.0,
      imageAsset: AssetMapping.monsterZone5,
      grandTitle: 'Kẻ Diệt Rồng',
      skills: [
        EnemySkill(
          id: 'rag_breath',
          name: 'Hơi Thở Hắc Long',
          damageMultiplier: 2.2,
          cooldown: 8.0,
          description: 'Phun trào luồng hỏa ngục thiêu rụi toàn bộ sàn đấu.',
          icon: '🔥',
          isMagic: true,
          causesHeroBurn: true,
        ),
        EnemySkill(
          id: 'rag_tail',
          name: 'Long Vĩ Quét Sạch',
          damageMultiplier: 2.8,
          cooldown: 14.0,
          description: 'Đuôi rồng giáng xuống như thiên thạch xé rách không gian.',
          icon: '💥',
        ),
      ],
    ),
    RaidBossInfo(
      weekIndex: 1,
      id: 'raid_azathoth',
      name: 'Nhãn Thần Azathoth',
      title: 'Cổ Thần Hỗn Độn',
      icon: '👁️',
      maxHp: 800000,
      atk: 380,
      def: 60.0,
      magicResist: 0.50, // 50% Kháng phép
      imageAsset: AssetMapping.monsterZone3,
      grandTitle: 'Kẻ Trảm Ma',
      skills: [
        EnemySkill(
          id: 'aza_gaze',
          name: 'Tà Nhãn Hỗn Độn',
          damageMultiplier: 2.0,
          cooldown: 8.0,
          description: 'Ánh nhìn ma quỷ làm đông kết tâm trí và giảm phòng ngự.',
          icon: '👁️',
          causesHeroDefDown: true,
        ),
        EnemySkill(
          id: 'aza_mind_crush',
          name: 'Hư Không Nghiền Nát',
          damageMultiplier: 2.5,
          cooldown: 15.0,
          description: 'Sóng xung kích hư không bóp nghẹt nhịp thở dũng sĩ.',
          icon: '🌀',
          isMagic: true,
          causesHeroFreeze: true,
        ),
      ],
    ),
    RaidBossInfo(
      weekIndex: 2,
      id: 'raid_thanatos',
      name: 'Tử Thần Thanatos',
      title: 'Lãnh Chúa Cõi Chết',
      icon: '💀',
      maxHp: 1000000,
      atk: 400,
      def: 90.0,
      lifestealPercent: 0.30, // 30% Hút máu
      imageAsset: AssetMapping.monsterZone4,
      grandTitle: 'Kẻ Nghịch Thần',
      skills: [
        EnemySkill(
          id: 'tha_scythe',
          name: 'Lưỡi Hái Tuyệt Vọng',
          damageMultiplier: 2.4,
          cooldown: 8.0,
          description: 'Trảm hồn đoạt phách, hấp thu sinh lực chuyển hóa thành máu cho boss.',
          icon: '💀',
          healsBossPercent: true,
        ),
        EnemySkill(
          id: 'tha_judgement',
          name: 'Khúc Ca Hắc Ám',
          damageMultiplier: 3.2,
          cooldown: 18.0,
          description: 'Đòn trừng phạt chí mạng đoạt mạng kẻ địch yếu đuối.',
          icon: '⚡',
        ),
      ],
    ),
  ];

  /// Get currently active Raid Boss based on timestamp week
  static RaidBossInfo getCurrentRaidBoss({int? timestampMs}) {
    final now = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    // 7 days in milliseconds
    const weekDuration = 7 * 24 * 60 * 60 * 1000;
    final weekNumber = (now ~/ weekDuration);
    final index = weekNumber % allBosses.length;
    return allBosses[index];
  }

  /// Current week cycle identifier
  static int getCurrentWeekNumber({int? timestampMs}) {
    final now = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    const weekDuration = 7 * 24 * 60 * 60 * 1000;
    return now ~/ weekDuration;
  }

  /// Milliseconds until next week reset
  static int getMsUntilNextReset({int? timestampMs}) {
    final now = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    const weekDuration = 7 * 24 * 60 * 60 * 1000;
    final nextReset = ((now ~/ weekDuration) + 1) * weekDuration;
    return max(0, nextReset - now);
  }

  /// Converts this raid boss into an Enemy structure for the battle engine
  Enemy toEnemy({required int currentHp}) {
    return Enemy(
      id: id,
      name: name,
      zone: 97, // Zone 97: Raid Boss
      stage: 1,
      isBoss: true,
      maxHp: maxHp,
      currentHp: currentHp.clamp(1, maxHp),
      atk: atk,
      def: def,
      agi: 7.0,
      critRate: 0.12,
      dodgeRate: 0.05,
      expReward: 0,
      goldReward: 1000,
      imageAsset: imageAsset,
      fallbackEmoji: icon,
      bossSkills: skills,
      magicResistPercent: magicResist,
    );
  }
}
