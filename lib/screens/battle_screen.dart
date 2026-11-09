import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../data/seed_enemies.dart';
import '../data/seed_skills.dart';
import '../models/battle_state.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/skill.dart';
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
  MilestoneRewardResult? _milestoneResult;

  @override
  void initState() {
    super.initState();
    _startBattle();
  }

  void _startBattle() {
    _dialogShown = false;
    _milestoneResult = null;
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

    final player = ref.read(playerProvider);

    if (state.isWon) {
      _milestoneResult = ref.read(playerProvider.notifier).onBattleVictory(
            exp: state.earnedExp,
            gold: state.earnedGold,
            drops: state.droppedEquipment,
            foughtZone: widget.zoneId,
            foughtStage: widget.stage,
          );

      _showResultDialog(isWon: true, state: state, previousPlayer: player);
    } else if (state.isDefeated) {
      _showResultDialog(isWon: false, state: state, previousPlayer: player);
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
                      height: 270,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.85),
                          ],
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
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Hero Sprite
                                Container(
                                  width: 100,
                                  height: 110,
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
                                const SizedBox(height: 6),

                                // Hero HP Bar
                                HpBar(
                                  currentHp: state.heroHp,
                                  maxHp: state.heroMaxHp,
                                  shield: state.heroShield,
                                  height: 15,
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
                              padding: const EdgeInsets.all(7),
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
                                  fontSize: 11,
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
                                          fontSize: 12.5,
                                          color: state.enemy.isBoss ? Colors.amberAccent : Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Monster Image
                                Container(
                                  width: 100,
                                  height: 110,
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
                                const SizedBox(height: 6),

                                // Monster HP Bar
                                HpBar(
                                  currentHp: state.enemy.currentHp,
                                  maxHp: state.enemy.maxHp,
                                  height: 15,
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
                                      style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- ACTIVE SKILL BAR (Issue 4: Icon, Mana, Ready Glow) ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        border: const Border(
                          top: BorderSide(color: Colors.white12),
                          bottom: BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: player.equippedSkillIds.map((skillId) {
                          final skill = SeedSkills.getById(skillId);
                          final isReady = skill.type == SkillType.active && state.heroMana >= skill.manaCost;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isReady ? Colors.orange.shade900.withOpacity(0.4) : Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isReady ? Colors.amberAccent : Colors.white24,
                                width: isReady ? 1.8 : 1,
                              ),
                              boxShadow: isReady
                                  ? [
                                      BoxShadow(
                                        color: Colors.amberAccent.withOpacity(0.4),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(skill.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skill.name,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isReady ? Colors.amberAccent : Colors.white70,
                                      ),
                                    ),
                                    if (skill.manaCost > 0)
                                      Text(
                                        '💧 ${skill.manaCost}',
                                        style: const TextStyle(fontSize: 8.5, color: Colors.cyanAccent),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
                            const Divider(color: Colors.white24, height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.battleLog.length,
                                itemBuilder: (context, index) {
                                  final msg = state.battleLog[index];
                                  Color textColor = Colors.white70;
                                  if (msg.contains('CHIẾN THẮNG')) textColor = Colors.greenAccent;
                                  if (msg.contains('THẤT BẠI')) textColor = Colors.redAccent;
                                  if (msg.contains('CHÍ MẠNG') || msg.contains('CRIT')) textColor = Colors.amberAccent;
                                  if (msg.contains('thiêu đốt')) textColor = Colors.orangeAccent;
                                  if (msg.contains('kích hoạt')) textColor = Colors.cyanAccent;
                                  if (msg.contains('phản đòn')) textColor = Colors.purpleAccent;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                                    child: Text(
                                      '• $msg',
                                      style: TextStyle(fontSize: 11, color: textColor),
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

                // Active Skill Banner (Issue 4 item 1: Center Banner for 0.8s)
                if (state.activeSkillCastName != null)
                  Positioned(
                    top: 130,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amberAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.6),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          state.activeSkillCastName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showResultDialog({
    required bool isWon,
    required BattleState state,
    required Player previousPlayer,
  }) {
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
                fontSize: 19,
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
                const SizedBox(height: 10),

                // Milestone Celebration Banner if triggered
                if (_milestoneResult != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade900.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _milestoneResult!.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                        ),
                        if (_milestoneResult!.unlockedSkillName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+ [${_milestoneResult!.unlockedSkillName}]',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                          ),
                        ],
                      ],
                    ),
                  ),

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
                          const Text('EXP', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(
                            '+${state.earnedExp}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('VÀNG', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          const SizedBox(height: 2),
                          Text(
                            '+${state.earnedGold} 🪙',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.droppedEquipment.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    '🎁 TRANG BỊ RƠI ĐƯỢC:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 4),
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

                // Tutorial 1st Win Popup trigger
                if (!previousPlayer.hasSeenTutorialFirstWin) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amberAccent),
                    ),
                    child: const Text(
                      '💡 Hướng dẫn: Bạn nhận được điểm chỉ số — Hãy vào tab Chỉ số trong Build để nâng cấp!',
                      style: TextStyle(fontSize: 11, color: Colors.amberAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                // Tutorial 1st Drop Popup trigger
                if (state.droppedEquipment.isNotEmpty && !previousPlayer.hasSeenTutorialFirstDrop) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: const Text(
                      '💡 Hướng dẫn: Trang bị đã rơi vào Túi đồ — Vào tab Trang bị để mặc hoặc nâng cấp!',
                      style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ] else ...[
                const Text(
                  'Nhân vật của bạn chưa đủ mạnh để vượt qua ải này.\nHãy nâng cấp chỉ số, mua đồ trong Cửa Hàng và nâng cấp trang bị để quay lại phục thù!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            OutlinedButton(
              onPressed: () {
                if (!previousPlayer.hasSeenTutorialFirstWin) {
                  ref.read(playerProvider.notifier).markTutorialFirstWinSeen();
                }
                if (state.droppedEquipment.isNotEmpty && !previousPlayer.hasSeenTutorialFirstDrop) {
                  ref.read(playerProvider.notifier).markTutorialFirstDropSeen();
                }
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
                if (!previousPlayer.hasSeenTutorialFirstWin) {
                  ref.read(playerProvider.notifier).markTutorialFirstWinSeen();
                }
                if (state.droppedEquipment.isNotEmpty && !previousPlayer.hasSeenTutorialFirstDrop) {
                  ref.read(playerProvider.notifier).markTutorialFirstDropSeen();
                }
                Navigator.pop(ctx);
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
