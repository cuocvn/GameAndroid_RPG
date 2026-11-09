import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../data/seed_enemies.dart';
import '../models/battle_state.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../providers/game_providers.dart';
import '../services/battle_service.dart';
import '../widgets/damage_text_widget.dart';
import '../widgets/hp_bar.dart';
import 'build_screen.dart';

class BattleScreen extends ConsumerStatefulWidget {
  final int zoneId;
  final int stage;

  const BattleScreen({
    super.key,
    required this.zoneId,
    required this.stage,
  });

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  late BattleService _battleService;
  BattleState? _currentState;
  late Enemy _enemy;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _startBattle();
  }

  void _startBattle() {
    _dialogShown = false;
    final player = ref.read(playerProvider);
    _enemy = SeedEnemies.getEnemy(widget.zoneId, widget.stage);

    _battleService = BattleService(
      player: player,
      enemy: _enemy,
      onStateChanged: (state) {
        if (mounted) {
          setState(() {
            _currentState = state;
          });
        }
      },
      onBattleEnded: (finalState) {
        if (mounted) {
          setState(() {
            _currentState = finalState;
          });
          _handleBattleEnd(finalState);
        }
      },
    );

    _battleService.start();
  }

  void _handleBattleEnd(BattleState state) {
    if (_dialogShown) return;
    _dialogShown = true;

    if (state.isWon) {
      ref.read(playerProvider.notifier).onBattleVictory(
            exp: state.earnedExp,
            gold: state.earnedGold,
            drops: state.droppedEquipment,
            foughtZone: widget.zoneId,
            foughtStage: widget.stage,
          );
      _showResultDialog(isWon: true, state: state);
    } else if (state.isDefeated) {
      _showResultDialog(isWon: false, state: state);
    }
  }

  @override
  void dispose() {
    _battleService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final state = _currentState;
    final zone = SeedEnemies.zones.firstWhere(
      (z) => z.id == widget.zoneId,
      orElse: () => SeedEnemies.zones.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161520),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _battleService.stop();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${zone.name} - Ải ${widget.stage}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              _enemy.isBoss ? '👑 TRÙM CUỐI VÙNG ĐẤT' : '⚔️ Quái vật thường',
              style: TextStyle(
                fontSize: 11,
                color: _enemy.isBoss ? Colors.amberAccent : Colors.white60,
                fontWeight: _enemy.isBoss ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _battleService.stop();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.flag, color: Colors.orangeAccent, size: 18),
            label: const Text(
              'Dừng',
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: state == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Zone background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: AssetMapping.safeImage(
                      zone.bgAsset,
                      fit: BoxFit.cover,
                      fallbackEmoji: '🌲',
                    ),
                  ),
                ),

                Column(
                  children: [
                    // --- BATTLE ARENA (Hero vs Monster) ---
                    Container(
                      height: 290,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                        border: const Border(
                          bottom: BorderSide(color: Colors.white12, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // HERO SIDE
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Hero Sprite
                                Container(
                                  width: 110,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: AssetMapping.safeImage(
                                    player.battleSpriteAsset,
                                    fit: BoxFit.contain,
                                    fallbackEmoji: '🧙‍♀️',
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Hero HP Bar
                                HpBar(
                                  currentHp: state.heroHp,
                                  maxHp: state.heroMaxHp,
                                  shield: state.heroShield,
                                  height: 16,
                                ),
                                const SizedBox(height: 4),

                                // Hero Mana Bar
                                ManaBar(
                                  currentMana: state.heroMana,
                                  maxMana: state.heroMaxMana,
                                  height: 12,
                                ),
                              ],
                            ),
                          ),

                          // VS BADGE (Center)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.amberAccent, width: 1.5),
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          // MONSTER SIDE
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.enemy.isBoss) const Text('👑 ', style: TextStyle(fontSize: 12)),
                                    Flexible(
                                      child: Text(
                                        state.enemy.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: state.enemy.isBoss ? Colors.amberAccent : Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Monster Image
                                Container(
                                  width: 110,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: state.enemy.isBoss ? Colors.amber : Colors.red.shade900,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: state.enemy.isBoss
                                            ? Colors.amber.withOpacity(0.4)
                                            : Colors.red.withOpacity(0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: AssetMapping.safeImage(
                                      state.enemy.imageAsset,
                                      fit: BoxFit.cover,
                                      fallbackEmoji: state.enemy.fallbackEmoji,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Monster HP Bar
                                HpBar(
                                  currentHp: state.enemy.currentHp,
                                  maxHp: state.enemy.maxHp,
                                  height: 16,
                                ),
                                const SizedBox(height: 4),

                                // Status: Burn Ticks Left
                                if (state.enemy.burnTicksLeft > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.shade900,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🔥 Thiêu đốt (${state.enemy.burnTicksLeft}s)',
                                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- COMBAT LOG (Real-time log) ---
                    Expanded(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.receipt_long, size: 14, color: Colors.amberAccent),
                                SizedBox(width: 6),
                                Text(
                                  'NHẬT KÝ CHIẾN ĐẤU',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.battleLog.length,
                                itemBuilder: (context, index) {
                                  final msg = state.battleLog[index];
                                  Color textColor = Colors.white70;
                                  if (msg.contains('CHIẾN THẮNG')) textColor = Colors.greenAccent;
                                  if (msg.contains('THẤT BẠI')) textColor = Colors.redAccent;
                                  if (msg.contains('CHÍ MẠNG')) textColor = Colors.amberAccent;
                                  if (msg.contains('thiêu đốt')) textColor = Colors.orangeAccent;
                                  if (msg.contains('kích hoạt')) textColor = Colors.cyanAccent;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '• $msg',
                                      style: TextStyle(fontSize: 11.5, color: textColor),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Damage Overlay
                FloatingDamageOverlay(texts: state.floatingTexts),
              ],
            ),
    );
  }

  void _showResultDialog({required bool isWon, required BattleState state}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161520),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: isWon ? Colors.amberAccent : Colors.redAccent, width: 2),
          ),
          title: Center(
            child: Text(
              isWon ? '🎉 CHIẾN THẮNG! 🎉' : '💀 THẤT BẠI... 💀',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isWon ? Colors.amberAccent : Colors.redAccent,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isWon) ...[
                Text(
                  'Bạn đã đánh bại ${_enemy.name}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('EXP NHẬN', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(
                            '+${state.earnedExp}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('VÀNG NHẬN', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(
                            '+${state.earnedGold} 🪙',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.droppedEquipment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '🎁 TRANG BỊ RƠI ĐƯỢC:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 6),
                  ...state.droppedEquipment.map((item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.rarity.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: item.rarity.color.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${item.name} (${item.rarity.label})',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: item.rarity.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ] else ...[
                const Text(
                  'Nhân vật của bạn chưa đủ mạnh để vượt qua ải này.\nHãy nâng cấp chỉ số, trang bị và kỹ năng để quay lại phục thù!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BuildScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.amberAccent),
              ),
              child: const Text('Về Build', style: TextStyle(color: Colors.amberAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Restart battle
                setState(() {
                  _startBattle();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isWon ? Colors.green.shade700 : Colors.red.shade700,
              ),
              child: Text(isWon ? 'Đánh tiếp' : 'Thử lại'),
            ),
          ],
        );
      },
    );
  }
}
