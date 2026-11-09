import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../providers/game_providers.dart';
import 'battle_screen.dart';
import 'build_screen.dart';
import 'map_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final reqExp = player.expToNextLevel;
    final expRatio = reqExp > 0 ? (player.currentExp / reqExp).clamp(0.0, 1.0) : 0.0;

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
                // Top Header: Currency & Level
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade800, Colors.amber.shade600],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'Lv. ${player.level}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Player Name & Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              player.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amberAccent.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Gold Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 14)),
                            Text(
                              '${player.gold}',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
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
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                          Text(
                            '${player.currentExp} / $reqExp (${(expRatio * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: expRatio,
                          backgroundColor: Colors.grey.shade900,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

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
                          top: 12,
                          right: 12,
                          child: InkWell(
                            onTap: () => _showAvatarPicker(context, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amberAccent, width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.style, size: 14, color: Colors.amberAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đổi Tướng',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 11,
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
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.redAccent, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.upgrade, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${player.statPoints + player.skillPoints} Điểm nâng cấp!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Stats Summary Overlay on Bottom of Card
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
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
                                _quickStat('HP', '${player.maxHp}', Colors.greenAccent),
                                _quickStat('MANA', '${player.maxMana}', Colors.cyanAccent),
                                _quickStat('S.THƯƠNG', '${player.magicAtk.round()}', Colors.orangeAccent),
                                _quickStat('GIÁP', '${player.physicalDef.round()}', Colors.lightBlueAccent),
                                _quickStat('BẠO KÍCH', '${(player.critRate * 100).round()}%', Colors.amberAccent),
                                _quickStat('HỎA CÔNG', '+${(player.fireDamageBonusPercent * 100).round()}%', Colors.redAccent),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Build Button
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.handyman, color: Colors.amberAccent, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'TÙY BIẾN BUILD',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (player.statPoints > 0 || player.skillPoints > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${player.statPoints + player.skillPoints}',
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Map Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MapScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.map, color: Colors.purpleAccent, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'BẢN ĐỒ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Primary BATTLE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.red.withOpacity(0.5),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53935), Color(0xFFFF8A65), Color(0xFFFFB74D)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⚔️ ', style: TextStyle(fontSize: 22)),
                              Text(
                                'VÀO CHIẾN ĐẤU (VÙNG ${player.currentZone} - ẢI ${player.currentStage})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
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
                const SizedBox(height: 12),
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
            fontSize: 13,
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
