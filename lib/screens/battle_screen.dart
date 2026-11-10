import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../theme/app_theme.dart';
import '../widgets/damage_text_widget.dart';
import '../widgets/hp_bar.dart';

class BattleScreen extends ConsumerStatefulWidget {
  final int zoneId;
  final int stage;
  final bool isEndless;

  const BattleScreen({
    super.key,
    required this.zoneId,
    required this.stage,
    this.isEndless = false,
  });

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with SingleTickerProviderStateMixin {
  late BattleService _battleService;
  BattleState? _currentState;
  late Enemy _enemy;
  bool _dialogShown = false;
  MilestoneRewardResult? _milestoneResult;
  bool _showCombatLogOverlay = false;

  double _battleSpeed = 1.0;
  bool _autoNext = false;
  late int _currentZoneId;
  late int _currentStage;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _currentZoneId = widget.zoneId;
    _currentStage = widget.stage;

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _startBattle();
  }

  void _startBattle() {
    _dialogShown = false;
    _milestoneResult = null;
    final player = ref.read(playerProvider);
    if (widget.isEndless || _currentZoneId == 99) {
      _enemy = SeedEnemies.generateEndlessEnemy(_currentStage);
    } else {
      _enemy = SeedEnemies.getEnemy(_currentZoneId, _currentStage);
    }

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
    _battleService.setBattleSpeed(_battleSpeed);
    _battleService.start();
  }

  void _handleBattleEnd(BattleState state) async {
    if (_dialogShown) return;
    _dialogShown = true;

    final player = ref.read(playerProvider);

    if (state.isWon) {
      _milestoneResult = ref.read(playerProvider.notifier).onBattleVictory(
            exp: state.earnedExp,
            gold: state.earnedGold,
            drops: state.droppedEquipment,
            foughtZone: _currentZoneId,
            foughtStage: _currentStage,
            triggeredSpeedrun: state.triggeredSpeedrunBonus,
          );

      await _showResultDialog(isWon: true, state: state, previousPlayer: player);
    } else if (state.isDefeated) {
      await _showResultDialog(isWon: false, state: state, previousPlayer: player);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _battleService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final state = _currentState;
    final zone = (widget.isEndless || _currentZoneId == 99)
        ? const ZoneInfo(
            id: 99,
            name: 'Tháp Vô Tận',
            description: 'Vực thẳm vô tận khiêu chiến cực hạn sức mạnh.',
            iconEmoji: '🌀',
            bgAsset: 'assets/img/characters/012_Seraphina_JUNG.jpg',
            stageCount: 100,
          )
        : SeedEnemies.zones.firstWhere(
            (z) => z.id == _currentZoneId,
            orElse: () => SeedEnemies.zones.first,
          );

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: state == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : Stack(
              children: [
                // 1. ZONE BACKGROUND WITH AMBIENT DARK VIGNETTE
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.28,
                    child: AssetMapping.safeImage(
                      zone.bgAsset,
                      fit: BoxFit.cover,
                      fallbackEmoji: '🌲',
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFA0D0B14),
                          Color(0x990D0B14),
                          Color(0xFA0D0B14),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. MAIN BATTLE INTERFACE
                SafeArea(
                  child: Column(
                    children: [
                      // Top Bar: Zone info & small Retreat button
                      _buildTopNavigationHeader(zone),

                      // Symmetric Top Combatant Status Bars (Hero VS Monster)
                      _buildTopCombatStatus(player, state),

                      // Monster Active Modifiers Chips Row
                      if (state.enemy.activeModifierBadges.isNotEmpty)
                        _buildModifierBadgesRow(state.enemy),

                      // Middle Combat Arena (Hero vs Monster with pedestals & breathing animation)
                      Expanded(
                        child: _buildCombatArena(player, state),
                      ),

                      // Bottom Equipped Skill Bar with Cooldown Sweep
                      _buildBottomSkillBar(player, state),
                    ],
                  ),
                ),

                // Floating Damage Overlay with black stroke
                FloatingDamageOverlay(texts: state.floatingTexts),

                // Active Skill Banner or Diablo Enrage Banner
                if (state.activeSkillCastName != null)
                  _buildCenterSkillBanner(state.activeSkillCastName!),

                // Floating Combat Log Icon & Collapsible Drawer
                Positioned(
                  bottom: 72,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'combat_log_fab',
                    backgroundColor: AppTheme.bgSurface,
                    shape: const CircleBorder(
                      side: BorderSide(color: AppTheme.goldAccent, width: 1.2),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _showCombatLogOverlay = !_showCombatLogOverlay;
                      });
                    },
                    child: const Text('📜', style: TextStyle(fontSize: 18)),
                  ),
                ),

                // Combat Log Overlay Slide-in Panel
                if (_showCombatLogOverlay)
                  _buildCombatLogDrawer(state),
              ],
            ),
    );
  }

  Widget _buildTopNavigationHeader(ZoneInfo zone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),
                onPressed: () {
                  _battleService.stop();
                  Navigator.pop(context);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.isEndless || _currentZoneId == 99)
                        ? 'Tháp Vô Tận • Tầng $_currentStage'
                        : '${zone.name} • Ải $_currentStage',
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _enemy.isBoss ? '👑 TRÙM CUỐI VÙNG ĐẤT' : '⚔️ Quái vật nguy hiểm',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _enemy.isBoss ? AppTheme.goldAccent : Colors.white60,
                      fontWeight: _enemy.isBoss ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // 1. Speed multiplier toggle pill
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (_battleSpeed == 1.0) {
                      _battleSpeed = 1.5;
                    } else if (_battleSpeed == 1.5) {
                      _battleSpeed = 2.0;
                    } else if (_battleSpeed == 2.0) {
                      _battleSpeed = 3.0;
                    } else {
                      _battleSpeed = 1.0;
                    }
                  });
                  _battleService.setBattleSpeed(_battleSpeed);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _battleSpeed > 1.0
                        ? AppTheme.goldAccent.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _battleSpeed > 1.0
                          ? AppTheme.goldAccent
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 13,
                        color: _battleSpeed > 1.0 ? AppTheme.goldAccent : Colors.white70,
                      ),
                      Text(
                        ' ${_battleSpeed == 1.0 ? "1x" : "${_battleSpeed}x"}',
                        style: GoogleFonts.cinzel(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: _battleSpeed > 1.0 ? AppTheme.goldAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 2. Auto-Next toggle pill
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _autoNext = !_autoNext;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _autoNext
                        ? AppTheme.greenAccent.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _autoNext ? AppTheme.greenAccent : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.autorenew,
                        size: 13,
                        color: _autoNext ? AppTheme.greenAccent : Colors.white60,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'AUTO',
                        style: GoogleFonts.cinzel(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _autoNext ? AppTheme.greenAccent : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 3. Retreat button
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _battleService.stop();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Rút lui',
                    style: GoogleFonts.cinzel(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCombatStatus(Player player, BattleState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hero Mini Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.goldAccent, width: 1.5),
            ),
            child: ClipOval(
              child: AssetMapping.safeImage(
                player.portraitAsset,
                width: 38,
                height: 38,
                fallbackEmoji: '🧙‍♀️',
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Hero Health & Mana
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                HpBar(
                  currentHp: state.heroHp,
                  maxHp: state.heroMaxHp,
                  shield: state.heroShield,
                  height: 13,
                  isHero: true,
                ),
                const SizedBox(height: 3),
                ManaBar(
                  currentMana: state.heroMana,
                  maxMana: state.heroMaxMana,
                  height: 9,
                  showText: false,
                ),
              ],
            ),
          ),

          // VS Center Marker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.redAccent.withOpacity(0.5), width: 1),
              ),
              child: Text(
                'VS',
                style: GoogleFonts.cinzel(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Monster Health & Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  state.enemy.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: state.enemy.isBoss ? AppTheme.goldAccent : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                HpBar(
                  currentHp: state.enemy.currentHp,
                  maxHp: state.enemy.maxHp,
                  height: 13,
                  isHero: false,
                ),
                const SizedBox(height: 3),
                // Status burn tag or spacer
                if (state.enemy.burnTicksLeft > 0)
                  Text(
                    '🔥 Thiêu đốt (${state.enemy.burnTicksLeft}s)',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const SizedBox(height: 9),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Monster Mini Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: state.enemy.isBoss ? AppTheme.goldAccent : AppTheme.redAccent,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: AssetMapping.safeImage(
                state.enemy.imageAsset,
                width: 38,
                height: 38,
                fallbackEmoji: state.enemy.fallbackEmoji,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierBadgesRow(Enemy enemy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 6,
        children: enemy.activeModifierBadges.map((badge) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5), width: 1),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCombatArena(Player player, BattleState state) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // HERO SPRITE ON PEDESTAL
          _buildCombatantColumn(
            name: player.name,
            assetPath: player.battleSpriteAsset,
            fallbackEmoji: '🧙‍♀️',
            isBoss: false,
            isHero: true,
          ),

          // MONSTER SPRITE ON PEDESTAL
          _buildCombatantColumn(
            name: state.enemy.name,
            assetPath: state.enemy.imageAsset,
            fallbackEmoji: state.enemy.fallbackEmoji,
            isBoss: state.enemy.isBoss,
            isHero: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCombatantColumn({
    required String name,
    required String assetPath,
    required String fallbackEmoji,
    required bool isBoss,
    required bool isHero,
  }) {
    final auraColor = isHero
        ? AppTheme.goldAccent
        : (isBoss ? AppTheme.goldAccent : AppTheme.redAccent);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Breathing Combatant Sprite
        ScaleTransition(
          scale: _breathingAnimation,
          child: Container(
            width: isBoss ? 135 : 115,
            height: isBoss ? 145 : 125,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.28),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AssetMapping.safeImage(
                assetPath,
                fit: BoxFit.contain,
                fallbackEmoji: fallbackEmoji,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Stone Pedestal / Magical Seal
        Container(
          width: isBoss ? 130 : 110,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.elliptical(isBoss ? 130 : 110, 18)),
            gradient: RadialGradient(
              colors: [
                auraColor.withOpacity(0.55),
                auraColor.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: auraColor.withOpacity(0.25),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSkillBar(Player player, BattleState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
        children: player.equippedSkillIds.map((skillId) {
          final skill = SeedSkills.getById(skillId);
          final bool isReady =
              skill.type == SkillType.active && state.heroMana >= skill.manaCost;

          return Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isReady
                  ? AppTheme.goldAccent.withOpacity(0.18)
                  : const Color(0xFF13101E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isReady ? AppTheme.goldAccent : Colors.white12,
                width: isReady ? 1.8 : 1.0,
              ),
              boxShadow: isReady ? AppTheme.goldGlow : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(skill.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 1),
                Text(
                  skill.name,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isReady ? AppTheme.goldAccent : Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCenterSkillBanner(String bannerText) {
    final isDiablo = bannerText.contains('DIABLO');

    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDiablo
                  ? [const Color(0xFF8B0000), AppTheme.redAccent]
                  : [const Color(0xFFD97706), AppTheme.goldAccent],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isDiablo ? Colors.red : Colors.amber).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            bannerText,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCombatLogDrawer(BattleState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 260,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 16, color: AppTheme.goldAccent),
                    const SizedBox(width: 8),
                    Text(
                      'NHẬT KÝ CHIẾN ĐẤU',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                  onPressed: () => setState(() => _showCombatLogOverlay = false),
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                itemCount: state.battleLog.length,
                itemBuilder: (context, index) {
                  final msg = state.battleLog[index];
                  Color textColor = Colors.white70;
                  if (msg.contains('CHIẾN THẮNG')) textColor = AppTheme.greenAccent;
                  if (msg.contains('THẤT BẠI')) textColor = AppTheme.redAccent;
                  if (msg.contains('CHÍ MẠNG') || msg.contains('CRIT')) textColor = AppTheme.goldAccent;
                  if (msg.contains('phản đòn')) textColor = AppTheme.redAccent;
                  if (msg.contains('Hồi Máu') || msg.contains('hồi phục')) textColor = AppTheme.greenAccent;
                  if (msg.contains('CUỒNG NỘ')) textColor = Colors.deepOrangeAccent;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• $msg',
                      style: GoogleFonts.inter(fontSize: 11, color: textColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResultDialog({
    required bool isWon,
    required BattleState state,
    required Player previousPlayer,
  }) async {
    final canAdvance = (widget.isEndless || _currentZoneId == 99) ||
        (_currentStage < 5 || _currentZoneId < 5);

    Timer? autoTimer;
    if (_autoNext && isWon && canAdvance) {
      autoTimer = Timer(const Duration(milliseconds: 1800), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop('next');
        }
      });
    }

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isWon ? AppTheme.goldAccent : AppTheme.redAccent,
              width: 1.8,
            ),
          ),
          title: Center(
            child: Text(
              isWon ? '🎉 CHIẾN THẮNG! 🎉' : '💀 THẤT BẠI... 💀',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isWon ? AppTheme.goldAccent : AppTheme.redAccent,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWon) ...[
                  Text(
                    'Bạn đã xuất sắc đánh bại ${_enemy.name}!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  // EXP & Gold Rewards
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kinh nghiệm:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            Text('+${state.earnedExp} EXP', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.purpleAccent, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Vàng kiếm được:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            Text('+${state.earnedGold} 🪙', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Combat Analytics Card
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('⚔️ Sát thương (DPS):', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            Text('${state.totalDamageDealt} (${state.dps.toStringAsFixed(1)}/s)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('💥 Chí mạng lớn nhất:', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            Text('${state.highestCritDamage}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🛡️ Sát thương gánh chịu:', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            Text('${state.totalDamageTaken}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.blueAccent)),
                          ],
                        ),
                        if (state.totalHealed > 0) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('💚 Lượng máu hồi phục:', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                              Text('+${state.totalHealed} HP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.greenAccent)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state.droppedEquipment.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '🎁 RƠI TRANG BỊ:',
                      style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                    ),
                    ...state.droppedEquipment.map((item) {
                      final color = AppTheme.getRarityColor(item.rarity);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${item.emoji} ${item.name} (${item.rarity.label})',
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ],
                  if (_milestoneResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.goldAccent),
                      ),
                      child: Text(
                        '${_milestoneResult!.message}\n${_milestoneResult!.unlockedSkillName ?? ""}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                      ),
                    ),
                  ],
                  if (_autoNext && canAdvance) ...[
                    const SizedBox(height: 8),
                    Text(
                      '⚡ Đang tự động sang ải kế tiếp...',
                      style: GoogleFonts.inter(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppTheme.greenAccent),
                    ),
                  ],
                ] else ...[
                  Text(
                    'Bạn đã gục ngã trước ${_enemy.name}.\nHãy nâng cấp trang bị, tinh chỉnh phân bổ điểm chỉ số hoặc trang bị kỹ năng phù hợp hơn!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70, height: 1.4),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('⚔️ Đã gây ra (DPS):', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            Text('${state.totalDamageDealt} (${state.dps.toStringAsFixed(1)}/s)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🛡️ Sát thương đã nhận:', style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                            Text('${state.totalDamageTaken}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.blueAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                autoTimer?.cancel();
                Navigator.pop(ctx, 'home');
              },
              child: const Text('Về Trang Chủ', style: TextStyle(color: Colors.white60)),
            ),
            if (isWon && canAdvance)
              ElevatedButton(
                onPressed: () {
                  autoTimer?.cancel();
                  Navigator.pop(ctx, 'next');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenAccent,
                ),
                child: Text(
                  widget.isEndless || _currentZoneId == 99 ? 'Tầng Kế ⏩' : 'Ải Kế Tiếp ⏩',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  autoTimer?.cancel();
                  Navigator.pop(ctx, 'retry');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWon ? AppTheme.goldAccent : AppTheme.redAccent,
                ),
                child: Text(
                  isWon ? 'Đánh Lại' : 'Thử Lại',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
    autoTimer?.cancel();

    if (action != null) {
      await _checkPostBattleTutorials(isWon, state.droppedEquipment.isNotEmpty);
      if (!mounted) return;
      if (action == 'next') {
        if (widget.isEndless || _currentZoneId == 99) {
          _currentStage++;
        } else {
          if (_currentStage < 5) {
            _currentStage++;
          } else if (_currentZoneId < 5) {
            _currentZoneId++;
            _currentStage = 1;
          }
        }
        _startBattle();
      } else if (action == 'retry') {
        _startBattle();
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _checkPostBattleTutorials(bool isWon, bool hasDrops) async {
    final player = ref.read(playerProvider);
    if (isWon && !player.hasSeenTutorialFirstWin) {
      ref.read(playerProvider.notifier).markTutorialFirstWinSeen();
      if (!mounted) return;
      await showDialog(
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
              const Text('✨ ', style: TextStyle(fontSize: 22)),
              Text(
                'Chiến Thắng Đầu Tiên!',
                style: GoogleFonts.cinzel(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn nhận được điểm chỉ số — vào tab Chỉ số để cộng.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
              child: const Text('Đã hiểu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final updatedPlayer = ref.read(playerProvider);
    if (hasDrops && !updatedPlayer.hasSeenTutorialFirstDrop) {
      ref.read(playerProvider.notifier).markTutorialFirstDropSeen();
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppTheme.blueAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🎁 ', style: TextStyle(fontSize: 22)),
              Text(
                'Nhặt Được Trang Bị!',
                style: GoogleFonts.cinzel(
                  color: AppTheme.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            'Vào tab Trang bị để xem.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blueAccent),
              child: const Text('Đã hiểu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
