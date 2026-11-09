import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../data/seed_enemies.dart';
import '../providers/game_providers.dart';
import 'battle_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _selectedZoneId = 1;
  int _selectedStage = 1;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerProvider);
    _selectedZoneId = player.currentZone;
    _selectedStage = player.currentStage;
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final selectedZone = SeedEnemies.zones.firstWhere((z) => z.id == _selectedZoneId);
    final enemiesInZone = SeedEnemies.getEnemiesForZone(_selectedZoneId);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161520),
        title: const Text(
          'BẢN ĐỒ VÙNG ĐẤT CHIẾN TRƯỜNG',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Horizontal Zone Selector
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: SeedEnemies.zones.length,
              itemBuilder: (context, index) {
                final zone = SeedEnemies.zones[index];
                final isUnlocked = zone.id <= player.maxUnlockedZone;
                final isSelected = zone.id == _selectedZoneId;

                return InkWell(
                  onTap: isUnlocked
                      ? () {
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
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.amber.shade900.withOpacity(0.4)
                          : (isUnlocked ? Colors.grey.shade900 : Colors.black87),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.amberAccent
                            : (isUnlocked ? Colors.white24 : Colors.grey.shade800),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isUnlocked ? zone.iconEmoji : '🔒',
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vùng ${zone.id}: ${zone.name}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.amberAccent
                                : (isUnlocked ? Colors.white : Colors.white38),
                          ),
                        ),
                        Text(
                          isUnlocked ? '${zone.stageCount} Ải' : 'Đang Khóa',
                          style: TextStyle(
                            fontSize: 10,
                            color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Zone Banner / Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                          'VÙNG ${_selectedZoneId}: ${selectedZone.name}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedZone.description,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Stage List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CHỌN ẢI KHIÊU CHIẾN',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                Text(
                  'Đang chọn: Ải $_selectedStage',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: enemiesInZone.length,
              itemBuilder: (context, index) {
                final enemy = enemiesInZone[index];
                final stageNum = index + 1;
                final isSelected = _selectedStage == stageNum;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStage = stageNum;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade900.withOpacity(0.35)
                          : Colors.grey.shade900.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.orangeAccent : Colors.white12,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Stage Number Badge
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: enemy.isBoss ? Colors.amber.shade900 : Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: enemy.isBoss ? Colors.amberAccent : Colors.white24,
                            ),
                          ),
                          child: Text(
                            enemy.isBoss ? '👑' : '$stageNum',
                            style: TextStyle(
                              fontSize: enemy.isBoss ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Enemy info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    enemy.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: enemy.isBoss ? Colors.amberAccent : Colors.white,
                                    ),
                                  ),
                                  if (enemy.isBoss) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade900,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('BOSS', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'HP: ${enemy.maxHp}  •  ATK: ${enemy.atk}  •  Thưởng: ${enemy.expReward} EXP, ${enemy.goldReward}g',
                                style: const TextStyle(fontSize: 11, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),

                        // Selection radio indicator
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.amberAccent : Colors.white30,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Start Battle on Selected Stage Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(playerProvider.notifier).selectZoneAndStage(_selectedZoneId, _selectedStage);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BattleScreen(
                        zoneId: _selectedZoneId,
                        stage: _selectedStage,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.black, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'BẮT ĐẦU CÀN QUÉT (VÙNG $_selectedZoneId - ẢI $_selectedStage)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
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
