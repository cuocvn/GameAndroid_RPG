import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../models/arena_rank.dart';
import '../models/companion.dart';
import '../models/offline_progress.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/particle_effects.dart';
import 'arena_screen.dart';
import 'battle_screen.dart';
import 'build_screen.dart';
import 'crafting_screen.dart';
import 'map_screen.dart';
import 'prestige_screen.dart';
import 'raid_screen.dart';
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _showSavedIndicator = false;
  Timer? _autoSavePeriodicTimer;
  Timer? _hideSavedIndicatorTimer;

  void _triggerAutoSaveIndicator() {
    if (!mounted) return;
    setState(() => _showSavedIndicator = true);
    _hideSavedIndicatorTimer?.cancel();
    _hideSavedIndicatorTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _showSavedIndicator = false);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    // Auto-save periodic indicator every 30s
    _autoSavePeriodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _triggerAutoSaveIndicator();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTutorial();
      _checkOfflineProgress();
      _triggerAutoSaveIndicator();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSavePeriodicTimer?.cancel();
    _hideSavedIndicatorTimer?.cancel();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(playerProvider.notifier).recordLastActiveTimestamp();
    } else if (state == AppLifecycleState.resumed) {
      _checkOfflineProgress();
    }
  }

  void _checkOfflineProgress() {
    final result = ref.read(playerProvider.notifier).calculateOfflineProgress();
    if (result != null && mounted) {
      _showOfflineProgressDialog(result);
    }
  }

  Widget _buildMiniRewardBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.white70),
      ),
    );
  }

  void _showOfflineProgressDialog(OfflineProgressResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF231A2B), Color(0xFF100B17)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.goldAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldAccent.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌙 ', style: TextStyle(fontSize: 24)),
                      Flexible(
                        child: Text(
                          'TRONG LÚC BẠN VẮNG MẶT...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thời gian vắng mặt: ${result.formattedDuration}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (result.hadAutoFarm) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.autorenew, color: AppTheme.goldAccent, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Ải Auto-Farm: ${result.stageName}',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Số trận thắng:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '${result.battlesWon} trận',
                                style: GoogleFonts.cinzel(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.greenAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kinh nghiệm:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '+${result.expGained} EXP',
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Vàng thu được:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '+${result.goldGained} 🪙',
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                            ],
                          ),
                          if (result.gemsGained > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Đá quý:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                                Text(
                                  '+${result.gemsGained} 💎',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Loot & materials badges
                    if (result.droppedItems.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '🎁 Trang bị rơi (${result.droppedItems.length} món):',
                          style: GoogleFonts.cinzel(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: result.droppedItems.map((item) {
                          final rColor = AppTheme.getRarityColor(item.rarity);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: rColor, width: 1),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: rColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Materials & Food
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if ((result.droppedMaterials['iron'] ?? 0) > 0)
                          _buildMiniRewardBadge('🔩 Sắt +${result.droppedMaterials['iron']}'),
                        if ((result.droppedMaterials['crystal'] ?? 0) > 0)
                          _buildMiniRewardBadge('💠 Pha Lê +${result.droppedMaterials['crystal']}'),
                        if ((result.droppedMaterials['steel'] ?? 0) > 0)
                          _buildMiniRewardBadge('🌑 Hắc Kim +${result.droppedMaterials['steel']}'),
                        if ((result.droppedPetFoods['meat'] ?? 0) > 0)
                          _buildMiniRewardBadge('🥩 Thịt +${result.droppedPetFoods['meat']}'),
                        if ((result.droppedPetFoods['herb'] ?? 0) > 0)
                          _buildMiniRewardBadge('🌿 Cỏ +${result.droppedPetFoods['herb']}'),
                        if ((result.droppedPetFoods['beast_stone'] ?? 0) > 0)
                          _buildMiniRewardBadge('💎 Đá Thú +${result.droppedPetFoods['beast_stone']}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bạn chưa kích hoạt tính năng Auto-Farm tại ải nào trên Bản Đồ.\nHãy vào Bản Đồ và bấm "🔄 Auto-Farm" tại ải đã vượt qua để tự động nhận thưởng ngoại tuyến!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (result.staminaRegenerated > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Thể lực Raid hồi phục: +${result.staminaRegenerated} ⚡',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(playerProvider.notifier).claimOfflineProgress(result);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'NHẬN TẤT CẢ PHẦN THƯỞNG',
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                              heroId: hero['id']!,
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

  void _showSettingsDialog() {
    AppTheme.showScaleDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final player = ref.watch(playerProvider);
            return AlertDialog(
              backgroundColor: AppTheme.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
              ),
              title: Row(
                children: [
                  const Text('⚙️ ', style: TextStyle(fontSize: 20)),
                  Text(
                    'CÀI ĐẶT HỆ THỐNG',
                    style: GoogleFonts.cinzel(
                      color: AppTheme.goldAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    activeColor: AppTheme.goldAccent,
                    contentPadding: EdgeInsets.zero,
                    secondary: const Text('🔊', style: TextStyle(fontSize: 20)),
                    title: const Text('Hiệu ứng Âm Thanh', style: TextStyle(fontSize: 13, color: Colors.white)),
                    subtitle: Text(
                      player.isSoundEnabled ? 'Đang bật âm thanh' : '🔇 Đã tắt âm thanh',
                      style: TextStyle(
                        fontSize: 11,
                        color: player.isSoundEnabled ? Colors.white60 : Colors.redAccent,
                      ),
                    ),
                    value: player.isSoundEnabled,
                    onChanged: (val) {
                      ref.read(playerProvider.notifier).toggleSound(val);
                      if (val) SoundService.playClick();
                    },
                  ),
                  const Divider(color: Colors.white10),
                  SwitchListTile(
                    activeColor: AppTheme.goldAccent,
                    contentPadding: EdgeInsets.zero,
                    secondary: const Text('📳', style: TextStyle(fontSize: 20)),
                    title: const Text('Phản hồi Rung (Haptic)', style: TextStyle(fontSize: 13, color: Colors.white)),
                    subtitle: Text(
                      player.isHapticEnabled ? 'Đang bật rung khi đánh' : '📳 Đã tắt rung',
                      style: TextStyle(
                        fontSize: 11,
                        color: player.isHapticEnabled ? Colors.white60 : Colors.redAccent,
                      ),
                    ),
                    value: player.isHapticEnabled,
                    onChanged: (val) {
                      ref.read(playerProvider.notifier).toggleHaptic(val);
                      if (val) SoundService.vibrateMedium();
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎮 Tactical Idle RPG', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                        const SizedBox(height: 2),
                        const Text('• Phiên bản: 1.0.0 (Offline Flutter ARPG)', style: TextStyle(fontSize: 10, color: Colors.white70)),
                        const Text('• Lưu dữ liệu: Hive Local Storage 100% Offline', style: TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Backup & Restore (Save JSON)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final jsonStr = jsonEncode(player.toJson());
                            await Clipboard.setData(ClipboardData(text: jsonStr));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📋 Đã sao chép Save JSON vào bộ nhớ tạm!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy, size: 14, color: AppTheme.goldAccent),
                          label: const Text('Xuất JSON', style: TextStyle(color: AppTheme.goldAccent, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.goldAccent),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text == null || data!.text!.trim().isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Bộ nhớ tạm không có dữ liệu JSON!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              return;
                            }
                            try {
                              final decoded = jsonDecode(data.text!) as Map<String, dynamic>;
                              final imported = Player.fromJson(decoded);
                              ref.read(playerProvider.notifier).setPlayer(imported);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Đã nạp dữ liệu Save JSON thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('❌ Dữ liệu JSON không hợp lệ: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.paste, size: 14, color: Colors.cyanAccent),
                          label: const Text('Nhập JSON', style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.cyanAccent),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmResetProgress();
                      },
                      icon: const Icon(Icons.restart_alt, color: AppTheme.redAccent, size: 16),
                      label: const Text('Khởi Động Lại Từ Đầu', style: TextStyle(color: AppTheme.redAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    SoundService.playClick();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
                  child: const Text('Đóng', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkFirstTimeTutorial() {
    final player = ref.read(playerProvider);
    // If player has progress or has played before, suppress all tutorials
    if (player.level > 1 ||
        player.inventory.isNotEmpty ||
        player.gold > 100 ||
        player.highestEndlessFloor > 0) {
      ref.read(playerProvider.notifier).skipAllTutorials();
      return;
    }

    if (!player.hasSeenTutorialHome) {
      AppTheme.showScaleDialog(
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
            TextButton(
              onPressed: () {
                SoundService.playClick();
                ref.read(playerProvider.notifier).skipAllTutorials();
                Navigator.pop(ctx);
              },
              child: const Text('Bỏ qua tất cả', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                SoundService.playClick();
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

  String _formatAfkTime(int totalMinutes) {
    if (totalMinutes < 1) return 'Vừa mới bắt đầu';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return '$hours giờ $mins phút';
    }
    return '$mins phút';
  }

  void _showAfkRewardsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final notifier = ref.read(playerProvider.notifier);
          final afk = notifier.previewAfkRewards();
          final minutes = afk['minutes'] as int;

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
                    const Text('🌾 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'KHO BÁU TREO MÁY AFK',
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Khi bạn rời game, dũng sĩ vẫn liên tục tu luyện và chiến đấu tại các ải cao nhất!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thời gian tích lũy:', style: TextStyle(fontSize: 11.5, color: Colors.white60)),
                          Text(
                            _formatAfkTime(minutes),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (minutes / 480).clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          color: AppTheme.goldAccent,
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tối đa 8 giờ tích lũy',
                          style: TextStyle(fontSize: 9.5, color: Colors.white38),
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Vàng tích lũy:', style: TextStyle(fontSize: 11.5, color: Colors.white60)),
                          Text('+${afk['gold']} 🪙', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kinh nghiệm:', style: TextStyle(fontSize: 11.5, color: Colors.white60)),
                          Text('+${afk['exp']} EXP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.purpleAccent)),
                        ],
                      ),
                      if ((afk['gems'] as int) > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Đá Cường Hóa:', style: TextStyle(fontSize: 11.5, color: Colors.white60)),
                            Text('+${afk['gems']} 💎', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.blueAccent)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Để Sau', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: minutes >= 1
                    ? () {
                        HapticFeedback.mediumImpact();
                        final claimed = notifier.claimAfkRewards();
                        Navigator.pop(ctx);
                        if (claimed != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Thu hoạch thành công: +${claimed['gold']} Vàng, +${claimed['exp']} EXP!'),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Thu Hoạch', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final quests = _getQuestDefinitions(player);
    final hasClaimableQuests = quests.any((q) => q.isCompleted && !q.isClaimed);

    final afkPreview = ref.read(playerProvider.notifier).previewAfkRewards();
    final afkMinutes = afkPreview['minutes'] as int;

    final reqExp = player.expToNextLevel;
    final expRatio = reqExp > 0 ? (player.currentExp / reqExp).clamp(0.0, 1.0) : 0.0;

    final isShopUnlocked = player.level >= 5;
    final isMapUnlocked = player.level >= 6;
    final isPrestigeUnlocked = player.level >= 30 || player.highestEndlessFloor >= 15 || player.prestigeLevel > 0;
    final canPrestigeNow = player.level >= 30 || player.highestEndlessFloor >= 15;

    final hasPendingPoints = player.statPoints > 0 || player.skillPoints > 0;
    final hasUnequippedNewGear = player.lastInventoryAcquiredTime > 0 &&
        (DateTime.now().millisecondsSinceEpoch - player.lastInventoryAcquiredTime) > 60000 &&
        player.inventory.isNotEmpty;

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
                              if (player.prestigeLevel > 0) ...[
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: 'Chuyển sinh lần ${player.prestigeLevel + 1} — nhận ${ref.read(playerProvider.notifier).calculatePrestigePoints()} điểm Ngộ Đạo nếu chuyển bây giờ',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade900,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.purpleAccent, width: 1),
                                    ),
                                    child: Text(
                                      '🌟 Cấp ${player.prestigeLevel}',
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9.5,
                                        color: AppTheme.goldAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              // Arena Tier Badge
                              Builder(
                                builder: (ctx) {
                                  final rankInfo = ArenaRankInfo.fromAp(player.arenaPoints);
                                  return Tooltip(
                                    message: 'Đấu Trường PvP: ${rankInfo.displayName} (${player.arenaPoints} AP)',
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: rankInfo.tier.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: rankInfo.tier.color, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(rankInfo.tier.icon, style: const TextStyle(fontSize: 10)),
                                          const SizedBox(width: 2),
                                          Text(
                                            rankInfo.displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9.5,
                                              color: rankInfo.tier.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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

                      // Currency Chip: Ngộ Đạo if prestigeLevel > 0, otherwise Gold
                      if (player.prestigeLevel > 0)
                        _buildCurrencyChip(
                          icon: '🔮',
                          amount: '${player.enlightenmentPoints}',
                          color: Colors.purpleAccent,
                        )
                      else
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

                      // Auto-Save Indicator (Item 3.5)
                      AnimatedOpacity(
                        opacity: _showSavedIndicator ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 350),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.6), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('💾 ', style: TextStyle(fontSize: 10)),
                              Text(
                                'Đã lưu',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                  if (player.equippedCompanionId != null &&
                                      CompanionType.getById(player.equippedCompanionId!) != null)
                                    Positioned(
                                      top: 8,
                                      left: 14,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1A12),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.goldAccent, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.goldAccent.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Tooltip(
                                          message:
                                              'Thú cưng: ${CompanionType.getById(player.equippedCompanionId!)!.name}',
                                          child: Text(
                                            CompanionType.getById(player.equippedCompanionId!)!.icon,
                                            style: const TextStyle(fontSize: 18),
                                          ),
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

                const SizedBox(height: 10),

                // AFK Idle Harvest Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAfkRewardsDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: afkMinutes >= 1
                              ? AppTheme.goldAccent.withValues(alpha: 0.6)
                              : Colors.white12,
                          width: afkMinutes >= 1 ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🌾', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu Luyện Treo Máy (AFK Rewards)',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Tích lũy: ${_formatAfkTime(afkMinutes)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    color: afkMinutes >= 1
                                        ? AppTheme.goldAccent
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: afkMinutes >= 1
                                  ? AppTheme.goldButtonGradient
                                  : null,
                              color: afkMinutes < 1 ? Colors.white10 : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Thu Hoạch',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: afkMinutes >= 1 ? Colors.black : Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (canPrestigeNow) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const PrestigeScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurpleAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('🌟', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ĐỦ ĐIỀU KIỆN CHUYỂN SINH! (+${ref.read(playerProvider.notifier).calculatePrestigePoints()} 🔮)',
                                style: GoogleFonts.cinzel(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.goldAccent),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                if (player.isAutoFarming) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const MapScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2210),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.goldAccent, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldAccent.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.autorenew, color: AppTheme.goldAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '🔄 Đang farm: Ải ${player.autoFarmZone}-${player.autoFarmStage}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 11, color: AppTheme.goldAccent),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 4. PULSING "CHIẾN ĐẤU" CTA BUTTON WITH FIRE SPARKS
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: ButtonFireSparks(
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
                          SoundService.vibrateMedium(isHapticEnabled: player.isHapticEnabled);
                          SoundService.playClick(isSoundEnabled: player.isSoundEnabled);
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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

                        // Crafting & Forge Icon
                        _buildBottomNavButton(
                          icon: Icons.hardware,
                          label: 'Lò Rèn',
                          isUnlocked: isShopUnlocked,
                          unlockReqText: 'Mở khóa ở Lv.5',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const CraftingScreen()),
                            );
                          },
                        ),

                        // Arena PvP Icon
                        _buildBottomNavButton(
                          icon: Icons.sports_kabaddi,
                          label: 'Đấu Trường',
                          isUnlocked: player.level >= 10 || player.highestEndlessFloor >= 5,
                          unlockReqText: 'Mở khóa ở Lv.10 hoặc Tháp F5',
                          hasBadge: player.hasUnclaimedSeasonMilestones,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const ArenaScreen()),
                            );
                          },
                        ),

                        // Săn Boss Thế Giới (Raid Boss)
                        _buildBottomNavButton(
                          icon: Icons.whatshot,
                          label: 'Săn Boss',
                          isUnlocked: player.level >= 15 || player.highestEndlessFloor >= 10,
                          unlockReqText: 'Mở Lv.15 hoặc Tháp F10',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const RaidScreen()),
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
                          hasBadge: hasPendingPoints || hasUnequippedNewGear,
                          badgeCount: (player.statPoints + player.skillPoints) > 0
                              ? (player.statPoints + player.skillPoints)
                              : (hasUnequippedNewGear ? 1 : 0),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const BuildScreen()),
                            );
                          },
                        ),

                        // Prestige / Chuyển Sinh Icon
                        _buildBottomNavButton(
                          icon: Icons.auto_awesome,
                          label: 'Chuyển Sinh',
                          isUnlocked: isPrestigeUnlocked,
                          unlockReqText: 'Mở Lv.30/F15',
                          hasBadge: canPrestigeNow,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const PrestigeScreen()),
                            );
                          },
                        ),
                      ],
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
