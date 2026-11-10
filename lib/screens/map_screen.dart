import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../data/seed_enemies.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';
import 'battle_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _isEndlessMode = false;
  int _selectedZoneId = 1;
  int _selectedStage = 1;
  int _selectedEndlessFloor = 1;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerProvider);
    _selectedZoneId = player.currentZone;
    _selectedStage = player.currentStage;
    _selectedEndlessFloor = player.highestEndlessFloor;
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final selectedZone = SeedEnemies.zones.firstWhere((z) => z.id == _selectedZoneId);
    final enemiesInZone = SeedEnemies.getEnemiesForZone(_selectedZoneId);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Text(
          'BẢN ĐỒ VÙNG ĐẤT CHIẾN TRƯỜNG',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.goldAccent,
          ),
        ),
      ),
      body: Column(
        children: [
          // Mode Toggle: CỐT TRUYỆN vs THÁP VÔ TẬN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isEndlessMode = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: !_isEndlessMode ? AppTheme.goldButtonGradient : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '🗺️ CỐT TRUYỆN 5 VÙNG',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_isEndlessMode ? Colors.black : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isEndlessMode = true;
                          _selectedEndlessFloor = player.highestEndlessFloor;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: _isEndlessMode ? AppTheme.goldButtonGradient : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '🌀 THÁP VÔ TẬN',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isEndlessMode ? Colors.black : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!_isEndlessMode) ...[
            // 1. Horizontal Zone Selector
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: SeedEnemies.zones.length,
                itemBuilder: (context, index) {
                  final zone = SeedEnemies.zones[index];
                  final isUnlocked = zone.id <= player.maxUnlockedZone;
                  final isSelected = zone.id == _selectedZoneId;

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isUnlocked
                        ? () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedZoneId = zone.id;
                              _selectedStage = 1;
                            });
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vùng ${zone.id} đang bị khóa! Hãy hạ gục Boss Vùng ${zone.id - 1} để mở khóa.'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppTheme.goldButtonGradient
                            : AppTheme.surfaceGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.goldAccent
                              : (isUnlocked ? Colors.white12 : Colors.white10),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? AppTheme.goldGlow : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isUnlocked ? zone.iconEmoji : '🔒',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vùng ${zone.id}: ${zone.name}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cinzel(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : (isUnlocked ? Colors.white : Colors.white38),
                            ),
                          ),
                          Text(
                            isUnlocked ? '${zone.stageCount} Ải' : 'Đang Khóa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black87 : (isUnlocked ? AppTheme.greenAccent : AppTheme.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Selected Zone Description Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.surfaceGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AssetMapping.safeImage(
                          selectedZone.bgAsset,
                          fit: BoxFit.cover,
                          fallbackEmoji: selectedZone.iconEmoji,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VÙNG $_selectedZoneId: ${selectedZone.name}',
                            style: GoogleFonts.cinzel(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedZone.description,
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 3. Winding Path / Stage Node Trail
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: enemiesInZone.length,
                itemBuilder: (context, index) {
                  final enemy = enemiesInZone[index];
                  final stageNum = index + 1;
                  final isSelected = _selectedStage == stageNum;
                  final isBoss = enemy.isBoss;

                  final stageKey = 'z${_selectedZoneId}_s$stageNum';
                  final isCleared = player.clearedStages.contains(stageKey);

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedStage = stageNum;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppTheme.goldButtonGradient
                            : AppTheme.surfaceGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.goldAccent
                              : (isBoss ? AppTheme.goldAccent.withOpacity(0.5) : Colors.white12),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.goldAccent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Circular Node Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isBoss ? AppTheme.redAccent.withOpacity(0.2) : Colors.black45,
                              border: Border.all(
                                color: isBoss ? AppTheme.goldAccent : Colors.white24,
                                width: isBoss ? 2 : 1,
                              ),
                            ),
                            child: ClipOval(
                              child: AssetMapping.safeImage(
                                enemy.imageAsset,
                                fit: BoxFit.cover,
                                fallbackEmoji: enemy.fallbackEmoji,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Stage Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Ải $stageNum: ${enemy.name}',
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isSelected ? Colors.black : Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isBoss) ...[
                                      const SizedBox(width: 6),
                                      const Text('👑', style: TextStyle(fontSize: 12)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Máu: ${enemy.maxHp}  •  Công: ${enemy.atk}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.black87 : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cleared Status Icon
                          if (isCleared)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black26 : AppTheme.greenAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '✓ ĐÃ QUA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black : AppTheme.greenAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // Endless Tower View
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppTheme.surfaceGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.purpleAccent.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🌀', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'THÁP VÔ TẬN (ENDLESS TOWER)',
                                style: GoogleFonts.cinzel(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.purpleAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tầng cao nhất: ${player.highestEndlessFloor}  •  Đồ Rare+ rơi từ Tầng 10+',
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 Cứ mỗi 5 tầng có Thủ Vệ và ngẫu nhiên nội tại: Kháng Phép, Phản Đòn, Hồi Máu, Giảm Crit hoặc Song Đòn!',
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.goldAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemCount: player.highestEndlessFloor,
                itemBuilder: (context, index) {
                  final floorNum = index + 1;
                  final endlessEnemy = SeedEnemies.generateEndlessEnemy(floorNum);
                  final isSelected = _selectedEndlessFloor == floorNum;
                  final isBossFloor = (floorNum % 5 == 0);

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedEndlessFloor = floorNum;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppTheme.goldButtonGradient
                            : AppTheme.surfaceGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.goldAccent
                              : (isBossFloor ? AppTheme.purpleAccent : Colors.white12),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isBossFloor ? AppTheme.purpleAccent.withOpacity(0.2) : Colors.black45,
                              border: Border.all(
                                color: isBossFloor ? AppTheme.purpleAccent : Colors.white24,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isBossFloor ? '👑' : '💀',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Tầng $floorNum: ${endlessEnemy.name}',
                                      style: GoogleFonts.cinzel(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Máu: ${endlessEnemy.maxHp}  •  Công: ${endlessEnemy.atk}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.black87 : Colors.white60,
                                  ),
                                ),
                                if (endlessEnemy.activeModifierBadges.isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    children: endlessEnemy.activeModifierBadges.map((badge) {
                                      return Text(
                                        badge,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.black : AppTheme.goldAccent,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                          if (floorNum < player.highestEndlessFloor)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black26 : AppTheme.greenAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '✓ ĐÃ QUA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black : AppTheme.greenAccent,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black26 : AppTheme.purpleAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '⚔️ MỚI NHẤT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black : AppTheme.purpleAccent,
                                ),
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

          // Bottom Launch Battle CTA Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => BattleScreen(
                        zoneId: _isEndlessMode ? 99 : _selectedZoneId,
                        stage: _isEndlessMode ? _selectedEndlessFloor : _selectedStage,
                        isEndless: _isEndlessMode,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEndlessMode ? AppTheme.purpleAccent : AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEndlessMode ? Icons.all_inclusive : Icons.sports_martial_arts,
                      color: _isEndlessMode ? Colors.white : Colors.black,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEndlessMode
                          ? 'THÁCH ĐẤU TẦNG $_selectedEndlessFloor'
                          : 'XUẤT TRẬN (ẢI $_selectedZoneId-$_selectedStage)',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _isEndlessMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
