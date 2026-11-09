import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../providers/game_providers.dart';
import 'battle_screen.dart';
import 'build_screen.dart';
import 'map_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTutorial();
    });
  }

  void _checkFirstTimeTutorial() {
    final player = ref.read(playerProvider);
    if (!player.hasSeenTutorialHome) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF161520),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.amberAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Text('🧙‍♀️ ', style: TextStyle(fontSize: 22)),
              Text('Chào Mừng Dũng Sĩ!', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text(
            'Chào mừng bạn đến với thế giới Tactical RPG!\n\nNhấn nút "CHIẾN ĐẤU" bên dưới để bước vào trận đánh đầu tiên của bạn!',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(playerProvider.notifier).markTutorialHomeSeen();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
              child: const Text('Đã hiểu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final reqExp = player.expToNextLevel;
    final expRatio = reqExp > 0 ? (player.currentExp / reqExp).clamp(0.0, 1.0) : 0.0;

    final isShopUnlocked = player.level >= 5;
    final isMapUnlocked = player.level >= 6;

    // Milestone calculation
    final clearedCount = player.clearedStages.length;
    String milestoneText;
    if (clearedCount < 5) {
      milestoneText = '⭐ Còn ${5 - clearedCount} ải nữa mở khóa Kỹ Năng Chủ Động mới';
    } else if (clearedCount < 10) {
      milestoneText = '⭐ Còn ${10 - clearedCount} ải nữa mở khóa Kỹ Năng Bị Động mới';
    } else if (clearedCount < 15) {
      milestoneText = '⭐ Còn ${15 - clearedCount} ải nữa mở thêm Ô Kỹ Năng Thứ 5';
    } else if (clearedCount < 20) {
      milestoneText = '⭐ Còn ${20 - clearedCount} ải nữa mở khóa Tuyệt Kỹ Tối Thượng';
    } else {
      milestoneText = '👑 Đã hoàn thành toàn bộ mốc thử thách danh dự!';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Stack(
        children: [
          // Background with dark gradient overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: AssetMapping.safeImage(
                AssetMapping.bgHomeDefault,
                fit: BoxFit.cover,
                fallbackEmoji: '🏰',
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    const Color(0xFF0F0E17).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header: Currencies, Shop & Level
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade800, Colors.amber.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          'Lv. ${player.level}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Player Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              player.title,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amberAccent.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Gems (Đá Quý)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.7), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💎 ', style: TextStyle(fontSize: 12)),
                            Text(
                              '${player.gems}',
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Gold Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 12)),
                            Text(
                              '${player.gold}',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Shop Icon (Opens ShopScreen if level >= 5)
                      InkWell(
                        onTap: isShopUnlocked
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🏪 Cửa Hàng mở khóa ở Cấp độ 5!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isShopUnlocked ? Colors.amber.shade900 : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isShopUnlocked ? Colors.amberAccent : Colors.grey.shade700,
                            ),
                          ),
                          child: Icon(
                            isShopUnlocked ? Icons.storefront : Icons.lock,
                            size: 18,
                            color: isShopUnlocked ? Colors.amberAccent : Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // EXP Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kinh nghiệm (EXP)',
                            style: TextStyle(fontSize: 10.5, color: Colors.white70),
                          ),
                          Text(
                            '${player.currentExp} / $reqExp (${(expRatio * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 10.5, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: expRatio,
                          backgroundColor: Colors.grey.shade900,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Milestone Progress Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            milestoneText,
                            style: const TextStyle(fontSize: 10.5, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${clearedCount}/20',
                          style: const TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Hero Portrait Display Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.15),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: AssetMapping.safeImage(
                              player.portraitAsset,
                              fit: BoxFit.cover,
                              fallbackEmoji: '🧙‍♀️',
                            ),
                          ),
                        ),

                        // Change Avatar Button
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () => _showAvatarPicker(context, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.amberAccent, width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.style, size: 12, color: Colors.amberAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đổi Tướng',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Notification Badge if has unspent Stat / Skill points
                        if (player.statPoints > 0 || player.skillPoints > 0)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.redAccent, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.upgrade, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${player.statPoints + player.skillPoints} Điểm!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Streamlined Home Stats: Chỉ hiện Level, HP, ATK, DEF, MANA (Gọn gàng)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(19),
                                bottomRight: Radius.circular(19),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.95),
                                  Colors.black.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _quickStat('❤️ MÁU (HP)', '${player.maxHp}', Colors.greenAccent),
                                _quickStat('⚔️ CÔNG (ATK)', '${player.magicAtk.round()}', Colors.orangeAccent),
                                _quickStat('🛡️ GIÁP (DEF)', '${player.physicalDef.round()}', Colors.lightBlueAccent),
                                _quickStat('💧 MANA', '${player.maxMana}', Colors.cyanAccent),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Action Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Build Button (Directly opens Build Screen)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BuildScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: (player.statPoints > 0 || player.skillPoints > 0)
                                  ? Colors.redAccent
                                  : Colors.amberAccent,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.handyman, color: Colors.amberAccent, size: 18),
                              const SizedBox(width: 6),
                              const Text(
                                'TÙY BIẾN BUILD',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (player.statPoints > 0 || player.skillPoints > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${player.statPoints + player.skillPoints}',
                                    style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Map Button (Unlocks at Level 6)
                      OutlinedButton(
                        onPressed: isMapUnlocked
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const MapScreen()),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🗺️ Bản Đồ mở khóa ở Cấp độ 6!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isMapUnlocked ? Colors.purpleAccent : Colors.grey.shade700,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isMapUnlocked ? Icons.map : Icons.lock,
                              color: isMapUnlocked ? Colors.purpleAccent : Colors.white38,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMapUnlocked ? 'BẢN ĐỒ' : 'BẢN ĐỒ (Lv.6)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isMapUnlocked ? Colors.white : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Primary BATTLE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BattleScreen(
                              zoneId: player.currentZone,
                              stage: player.currentStage,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: Colors.red.withOpacity(0.5),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53935), Color(0xFFFF8A65), Color(0xFFFFB74D)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⚔️ ', style: TextStyle(fontSize: 20)),
                              Text(
                                'VÀO CHIẾN ĐẤU (VÙNG ${player.currentZone} - ẢI ${player.currentStage})',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStat(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn Tướng / Ngoại Hình',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn ảnh đại diện nhân vật từ bộ sưu tập có sẵn trong game',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: AssetMapping.characterPortraits.length,
                  itemBuilder: (context, index) {
                    final key = AssetMapping.characterPortraits.keys.elementAt(index);
                    final assetPath = AssetMapping.characterPortraits[key]!;
                    final heroName = key[0].toUpperCase() + key.substring(1);

                    return InkWell(
                      onTap: () {
                        ref.read(playerProvider.notifier).changePortrait(
                              assetPath,
                              title: '$heroName - Dũng Sĩ Hỏa Hệ',
                            );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                                child: AssetMapping.safeImage(
                                  assetPath,
                                  fit: BoxFit.cover,
                                  fallbackEmoji: '🧙‍♀️',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              color: Colors.black54,
                              width: double.infinity,
                              child: Text(
                                heroName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
}
