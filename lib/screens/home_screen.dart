import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';
import 'battle_screen.dart';
import 'build_screen.dart';
import 'map_screen.dart';
import 'shop_screen.dart';

class QuestItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int goldReward;
  final int gemsReward;
  final bool isCompleted;
  final bool isClaimed;

  const QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.goldReward,
    required this.gemsReward,
    required this.isCompleted,
    required this.isClaimed,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Floating hero animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Pulsing CTA button animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTutorial();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showSelectHeroSheet() {
    final player = ref.read(playerProvider);
    final heroList = [
      {'id': 'cyra', 'name': 'Cyra', 'title': 'Hỏa Thuật Sư', 'asset': 'assets/img/characters/013_Cyra_MID.jpg'},
      {'id': 'inari', 'name': 'Inari', 'title': 'Hồ Ly Pháp Sư', 'asset': 'assets/img/characters/001_Inari_MID.jpg'},
      {'id': 'violetta', 'name': 'Violetta', 'title': 'Bóng Ma Rừng Sâu', 'asset': 'assets/img/characters/002_Violetta_JUNG.webp'},
      {'id': 'valeria', 'name': 'Valeria', 'title': 'Sát Thủ Bóng Tối', 'asset': 'assets/img/characters/003_Valeria_JUNG.webp'},
      {'id': 'kaelen', 'name': 'Kaelen', 'title': 'Thiết Huyết Chiến Binh', 'asset': 'assets/img/characters/004_Kaelen_TOP.jpg'},
      {'id': 'carmilla', 'name': 'Carmilla', 'title': 'Huyết Ma Nữ Vương', 'asset': 'assets/img/characters/005_Carmilla_JUNG.jpg'},
      {'id': 'elysia', 'name': 'Elysia', 'title': 'Thánh Nữ Ánh Sáng', 'asset': 'assets/img/characters/006_Elysia_SP.jpg'},
      {'id': 'sylvia', 'name': 'Sylvia', 'title': 'Xạ Thủ Thần Tiễn', 'asset': 'assets/img/characters/007_Sylvia_AD.webp'},
      {'id': 'selene', 'name': 'Selene', 'title': 'Nguyệt Quang Nữ Thần', 'asset': 'assets/img/characters/008_Selene_SP.webp'},
      {'id': 'aurora', 'name': 'Aurora', 'title': 'Băng Tuyết Nữ Vương', 'asset': 'assets/img/characters/009_Aurora_TOP.jpg'},
      {'id': 'lucia', 'name': 'Lucia', 'title': 'Thợ Săn Hắc Ám', 'asset': 'assets/img/characters/010_Lucia_JUNG.webp'},
      {'id': 'marina', 'name': 'Marina', 'title': 'Hải Dương Hộ Vệ', 'asset': 'assets/img/characters/011_Marina_SP.jpg'},
      {'id': 'seraphina', 'name': 'Seraphina', 'title': 'Chiến Tướng Thiên Giới', 'asset': 'assets/img/characters/012_Seraphina_JUNG.jpg'},
      {'id': 'giselle', 'name': 'Giselle', 'title': 'Hỏa Pháo Xạ Thủ', 'asset': 'assets/img/characters/014_Giselle_AD.jpg'},
      {'id': 'freya', 'name': 'Freya', 'title': 'Thần Nữ Valkyrie', 'asset': 'assets/img/characters/015_Freya_TOP.jpg'},
      {'id': 'mai', 'name': 'Mai', 'title': 'Nữ Kiếm Tôn', 'asset': 'assets/img/characters/016_Mai_TOP.jpg'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHỌN CHÂN DUNG DANH TƯỚNG',
                    style: GoogleFonts.cinzel(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: heroList.length,
                  itemBuilder: (context, index) {
                    final hero = heroList[index];
                    final isSelected = player.portraitAsset == hero['asset'];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(playerProvider.notifier).changePortrait(
                              hero['asset']!,
                              name: hero['name']!,
                              title: hero['title']!,
                            );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.goldAccent.withOpacity(0.2)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.goldAccent : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AssetMapping.safeImage(
                                  hero['asset']!,
                                  fit: BoxFit.cover,
                                  fallbackEmoji: '🧙‍♀️',
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hero['name']!,
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.goldAccent : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkFirstTimeTutorial() {
    final player = ref.read(playerProvider);
    if (!player.hasSeenTutorialHome) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🧙‍♀️ ', style: TextStyle(fontSize: 22)),
              Text(
                'Chào Mừng Dũng Sĩ!',
                style: GoogleFonts.cinzel(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            'Chào mừng bạn đến với thế giới Tactical RPG!\n\nNhấn nút "⚔️ CHIẾN ĐẤU" bên dưới để bước vào trận đánh đầu tiên của bạn!',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(playerProvider.notifier).markTutorialHomeSeen();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
              child: const Text('Đã hiểu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  List<QuestItem> _getQuestDefinitions(Player player) {
    bool hasUpgradedGear = player.inventory.any((e) => e.upgradeLevel > 0) ||
        (player.equippedWeapon?.upgradeLevel ?? 0) > 0 ||
        (player.equippedArmor?.upgradeLevel ?? 0) > 0 ||
        (player.equippedAccessory?.upgradeLevel ?? 0) > 0;

    return [
      QuestItem(
        id: 'first_blood',
        title: 'Tân Binh Xuất Trận',
        description: 'Vượt qua ải chiến đấu đầu tiên trong game.',
        icon: '🌟',
        goldReward: 100,
        gemsReward: 1,
        isCompleted: player.clearedStages.isNotEmpty,
        isClaimed: player.claimedQuestIds.contains('first_blood'),
      ),
      QuestItem(
        id: 'reach_lvl_5',
        title: 'Dũng Sĩ Tập Sự',
        description: 'Đạt cấp độ 5 để mở khóa Trang Bị & Shop.',
        icon: '⚔️',
        goldReward: 200,
        gemsReward: 2,
        isCompleted: player.level >= 5,
        isClaimed: player.claimedQuestIds.contains('reach_lvl_5'),
      ),
      QuestItem(
        id: 'reach_lvl_10',
        title: 'Bậc Thầy Chiến Binh',
        description: 'Đạt cấp độ 10 và phát triển sức mạnh nhân vật.',
        icon: '👑',
        goldReward: 500,
        gemsReward: 5,
        isCompleted: player.level >= 10,
        isClaimed: player.claimedQuestIds.contains('reach_lvl_10'),
      ),
      QuestItem(
        id: 'clear_zone_1',
        title: 'Chinh Phục Rừng Sâu',
        description: 'Đánh bại Trùm Cuối Vùng 1 (Rừng Ma Quái).',
        icon: '🌲',
        goldReward: 250,
        gemsReward: 3,
        isCompleted: player.clearedStages.contains('z1_s5'),
        isClaimed: player.claimedQuestIds.contains('clear_zone_1'),
      ),
      QuestItem(
        id: 'clear_zone_2',
        title: 'Vượt Qua Nham Thạch',
        description: 'Đánh bại Trùm Cuối Vùng 2 (Dung Nham Rực Lửa).',
        icon: '🌋',
        goldReward: 400,
        gemsReward: 4,
        isCompleted: player.clearedStages.contains('z2_s5'),
        isClaimed: player.claimedQuestIds.contains('clear_zone_2'),
      ),
      QuestItem(
        id: 'clear_zone_3',
        title: 'Phá Vỡ Băng Giá',
        description: 'Vượt qua quái Kháng Phép & đánh bại Boss Vùng 3.',
        icon: '❄️',
        goldReward: 600,
        gemsReward: 5,
        isCompleted: player.clearedStages.contains('z3_s5'),
        isClaimed: player.claimedQuestIds.contains('clear_zone_3'),
      ),
      QuestItem(
        id: 'clear_zone_4',
        title: 'Khuất Phục Minh Vương',
        description: 'Đánh bại Boss Minh Vương Hades Vùng 4 (Phản Đòn 20%).',
        icon: '💀',
        goldReward: 800,
        gemsReward: 6,
        isCompleted: player.clearedStages.contains('z4_s5'),
        isClaimed: player.claimedQuestIds.contains('clear_zone_4'),
      ),
      QuestItem(
        id: 'clear_zone_5',
        title: 'Hạ Gục Diablo',
        description: 'Đánh bại Trùm Cuối Diablo Vùng 5 (Hồi Máu 5%/s).',
        icon: '🔥',
        goldReward: 1500,
        gemsReward: 10,
        isCompleted: player.clearedStages.contains('z5_s5'),
        isClaimed: player.claimedQuestIds.contains('clear_zone_5'),
      ),
      QuestItem(
        id: 'endless_floor_5',
        title: 'Vực Thẳm Tầng 5',
        description: 'Chinh phục Tầng 5 của Tháp Vô Tận.',
        icon: '🌀',
        goldReward: 300,
        gemsReward: 3,
        isCompleted: player.highestEndlessFloor > 5,
        isClaimed: player.claimedQuestIds.contains('endless_floor_5'),
      ),
      QuestItem(
        id: 'endless_floor_10',
        title: 'Vực Thẳm Tầng 10',
        description: 'Chinh phục Tầng 10 của Tháp Vô Tận (Mở rơi đồ Rare+).',
        icon: '🌀',
        goldReward: 600,
        gemsReward: 6,
        isCompleted: player.highestEndlessFloor > 10,
        isClaimed: player.claimedQuestIds.contains('endless_floor_10'),
      ),
      QuestItem(
        id: 'upgrade_gear',
        title: 'Bậc Thầy Rèn Đúc',
        description: 'Nâng cấp ít nhất 1 món trang bị bằng Đá Cường Hóa.',
        icon: '💎',
        goldReward: 150,
        gemsReward: 2,
        isCompleted: hasUpgradedGear,
        isClaimed: player.claimedQuestIds.contains('upgrade_gear'),
      ),
    ];
  }

  void _showQuestsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final player = ref.watch(playerProvider);
            final quests = _getQuestDefinitions(player);

            return AlertDialog(
              backgroundColor: AppTheme.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🏆 ', style: TextStyle(fontSize: 20)),
                      Text(
                        'NHIỆM VỤ & THÀNH TỰU',
                        style: GoogleFonts.cinzel(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: quests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final q = quests[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: q.isClaimed
                            ? Colors.black26
                            : (q.isCompleted
                                ? AppTheme.goldAccent.withValues(alpha: 0.12)
                                : Colors.black38),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: q.isCompleted && !q.isClaimed
                              ? AppTheme.goldAccent
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(q.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.title,
                                  style: GoogleFonts.cinzel(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: q.isCompleted ? AppTheme.goldAccent : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  q.description,
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white60),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('+${q.goldReward} 🪙', style: const TextStyle(fontSize: 10, color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text('+${q.gemsReward} 💎', style: const TextStyle(fontSize: 10, color: AppTheme.blueAccent, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (q.isClaimed)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.greenAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✓ Đã nhận',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.greenAccent),
                              ),
                            )
                          else if (q.isCompleted)
                            ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ref.read(playerProvider.notifier).claimQuest(
                                      q.id,
                                      goldReward: q.goldReward,
                                      gemsReward: q.gemsReward,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.goldAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text(
                                'Nhận',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Chưa đạt',
                                style: TextStyle(fontSize: 10, color: Colors.white38),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 1.5),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'CÀI ĐẶT & THÔNG TIN',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎮 Tactical Idle RPG (Android Offline)', style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                  const SizedBox(height: 4),
                  const Text('• Phiên bản: 1.0.0 (Flutter + Dart)', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const Text('• Lưu dữ liệu: Hive Local Storage 100% Offline', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const Text('• Rung phản hồi: Tự động kích hoạt khi đánh & chí mạng', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmResetProgress();
                },
                icon: const Icon(Icons.restart_alt, color: AppTheme.redAccent, size: 18),
                label: const Text('Khởi Động Lại Từ Đầu', style: TextStyle(color: AppTheme.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppTheme.redAccent, width: 1.5),
        ),
        title: Text(
          '⚠️ XÁC NHẬN XÓA TIẾN TRÌNH',
          style: GoogleFonts.cinzel(
            color: AppTheme.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
          ),
        ),
        content: const Text(
          'Toàn bộ cấp độ nhân vật, điểm chỉ số, trang bị và tiến trình vượt ải sẽ bị xóa hoàn toàn để bắt đầu lại từ đầu.\n\nBạn có chắc chắn không?',
          style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playerProvider.notifier).resetProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đặt lại tiến trình dũng sĩ!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redAccent),
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final quests = _getQuestDefinitions(player);
    final hasClaimableQuests = quests.any((q) => q.isCompleted && !q.isClaimed);

    final reqExp = player.expToNextLevel;
    final expRatio = reqExp > 0 ? (player.currentExp / reqExp).clamp(0.0, 1.0) : 0.0;

    final isShopUnlocked = player.level >= 5;
    final isMapUnlocked = player.level >= 6;

    final hasPendingPoints = player.statPoints > 0 || player.skillPoints > 0;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background artwork with subtle ambient vignette
          Positioned.fill(
            child: Opacity(
              opacity: 0.22,
              child: AssetMapping.safeImage(
                AssetMapping.bgHomeDefault,
                fit: BoxFit.cover,
                fallbackEmoji: '🏰',
              ),
            ),
          ),
          // Gradient dark vignette overlays
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xEE0D0B14),
                    Color(0x770D0B14),
                    Color(0xEE0D0B14),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. TOP HEADER: Level, Hero Title, Currencies
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Hero Avatar & Level pill (Tap to change hero portrait)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showSelectHeroSheet();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.surfaceGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldButtonGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Lv.${player.level}',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        player.name,
                                        style: GoogleFonts.cinzel(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 11, color: AppTheme.goldAccent),
                                    ],
                                  ),
                                  Text(
                                    player.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.goldAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Gold Currency Chip
                      _buildCurrencyChip(
                        icon: '🪙',
                        amount: '${player.gold}',
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(width: 8),

                      // Gem Currency Chip
                      _buildCurrencyChip(
                        icon: '💎',
                        amount: '${player.gems}',
                        color: AppTheme.blueAccent,
                      ),
                      const SizedBox(width: 8),

                      // Achievements / Quests Button
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showQuestsDialog();
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: hasClaimableQuests
                                      ? AppTheme.goldAccent
                                      : Colors.white24,
                                  width: hasClaimableQuests ? 1.5 : 1,
                                ),
                              ),
                              child: const Text('🏆', style: TextStyle(fontSize: 14)),
                            ),
                            if (hasClaimableQuests)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Settings Button
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showSettingsDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.settings, size: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                // EXP Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 5,
                      color: Colors.white12,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: expRatio,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), AppTheme.purpleAccent],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. HERO SHOWCASE WITH FLOATING ANIMATION & PEDESTAL
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Magical glowing stone pedestal under hero
                        Positioned(
                          bottom: 15,
                          child: Container(
                            width: 170,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(Radius.elliptical(170, 24)),
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.goldAccent.withOpacity(0.45),
                                  AppTheme.purpleAccent.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.goldAccent.withOpacity(0.25),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Hero floating animation
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: child,
                            );
                          },
                          child: Hero(
                            tag: 'hero_portrait',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(95),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showSelectHeroSheet();
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: 190,
                                    height: 190,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.goldAccent.withOpacity(0.6),
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.goldAccent.withOpacity(0.25),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: AssetMapping.safeImage(
                                        player.portraitAsset,
                                        width: 190,
                                        height: 190,
                                        fit: BoxFit.cover,
                                        fallbackEmoji: '🧙‍♀️',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 18,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.goldAccent, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.palette, size: 12, color: AppTheme.goldAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Đổi Tướng',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. 2x2 STAT SUMMARY CARDS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              label: 'MÁU (HP)',
                              value: '${player.maxHp}',
                              icon: Icons.favorite,
                              color: AppTheme.redAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              label: 'GIÁP (DEF)',
                              value: player.physicalDef.toStringAsFixed(1),
                              icon: Icons.shield,
                              color: AppTheme.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              label: 'CÔNG PHÉP',
                              value: '${player.magicAtk.round()}',
                              icon: Icons.local_fire_department,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              label: 'BẠO KÍCH',
                              value: '${(player.critRate * 100).round()}%',
                              icon: Icons.flash_on,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. PULSING "CHIẾN ĐẤU" CTA BUTTON
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldButtonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldAccent.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => BattleScreen(
                              zoneId: player.currentZone,
                              stage: player.currentStage,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sports_martial_arts, color: Colors.black, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'CHIẾN ĐẤU (ẢI ${player.currentZone}-${player.currentStage})',
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 5. BOTTOM ACTION NAVIGATION (Shop, Map, Build)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.surfaceGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Shop Icon
                      _buildBottomNavButton(
                        icon: Icons.storefront,
                        label: 'Cửa Hàng',
                        isUnlocked: isShopUnlocked,
                        unlockReqText: 'Mở khóa ở Lv.5',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const ShopScreen()),
                          );
                        },
                      ),

                      // Map Icon
                      _buildBottomNavButton(
                        icon: Icons.map,
                        label: 'Bản Đồ',
                        isUnlocked: isMapUnlocked,
                        unlockReqText: 'Mở khóa ở Lv.6',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const MapScreen()),
                          );
                        },
                      ),

                      // Character / Build Icon (with pending point badge)
                      _buildBottomNavButton(
                        icon: Icons.tune,
                        label: 'Nhân Vật',
                        isUnlocked: true,
                        hasBadge: hasPendingPoints,
                        badgeCount: player.statPoints + player.skillPoints,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const BuildScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip({
    required String icon,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            amount,
            style: GoogleFonts.cinzel(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton({
    required IconData icon,
    required String label,
    required bool isUnlocked,
    String? unlockReqText,
    bool hasBadge = false,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isUnlocked
          ? onTap
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(unlockReqText ?? 'Chưa mở khóa!'),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppTheme.goldAccent.withOpacity(0.12)
                        : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnlocked
                          ? AppTheme.goldAccent.withOpacity(0.4)
                          : Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? icon : Icons.lock,
                    color: isUnlocked ? AppTheme.goldAccent : Colors.grey,
                    size: 20,
                  ),
                ),
                if (hasBadge && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isUnlocked ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
