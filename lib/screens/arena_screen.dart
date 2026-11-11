import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../data/seed_skills.dart';
import '../models/arena_opponent.dart';
import '../models/arena_rank.dart';
import '../models/player.dart';
import '../models/season_pass.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';
import 'battle_screen.dart';

class ArenaScreen extends ConsumerStatefulWidget {
  const ArenaScreen({super.key});

  @override
  ConsumerState<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends ConsumerState<ArenaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ArenaOpponent? _currentOpponent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).initArenaIfNeeded();
      _generateNextOpponent();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateNextOpponent() {
    final player = ref.read(playerProvider);
    setState(() {
      _currentOpponent = ArenaOpponent.generate(player: player);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final rankInfo = ArenaRankInfo.fromAp(player.arenaPoints);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF130E20),
        elevation: 0,
        title: Text(
          'ĐẤU TRƯỜNG ĐỈNH PHONG',
          style: GoogleFonts.cinzel(
            color: AppTheme.goldAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.redAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.sports_kabaddi, size: 20), text: 'Đấu Trường'),
            Tab(icon: Icon(Icons.emoji_events, size: 20), text: 'Xếp Hạng'),
            Tab(icon: Icon(Icons.confirmation_number, size: 20), text: 'Vé Mùa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArenaCombatTab(player, rankInfo),
          _buildLeaderboardTab(player),
          _buildSeasonPassTab(player),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: ARENA COMBAT
  // =========================================================================
  Widget _buildArenaCombatTab(Player player, ArenaRankInfo rankInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Player Rank & Tier Summary Card
          _buildPlayerRankSummaryCard(player, rankInfo),
          const SizedBox(height: 16),

          // 2. Next Opponent Card
          if (_currentOpponent != null)
            _buildOpponentCard(player, _currentOpponent!)
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppTheme.goldAccent),
              ),
            ),
          const SizedBox(height: 20),

          // 3. Match History Section
          _buildMatchHistorySection(player),
        ],
      ),
    );
  }

  Widget _buildPlayerRankSummaryCard(Player player, ArenaRankInfo rankInfo) {
    final nextMilestone = rankInfo.tier == ArenaTier.grandmaster
        ? 'Tối Thượng'
        : '${rankInfo.maxAp + 1} AP';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rankInfo.tier.color.withOpacity(0.25),
            const Color(0xFF171224),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankInfo.tier.color.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: rankInfo.tier.color.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Tier Icon Badge
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankInfo.tier.color.withOpacity(0.18),
              border: Border.all(color: rankInfo.tier.color, width: 2),
            ),
            child: Center(
              child: Text(
                rankInfo.tier.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Tier Text & AP Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rankInfo.displayName,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: rankInfo.tier.color,
                      ),
                    ),
                    Text(
                      '${player.arenaPoints} AP',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Progress Bar in Tier
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rankInfo.progressInTier,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(rankInfo.tier.color),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bậc kế: $nextMilestone',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
                    ),
                    if (player.arenaWinStreak > 0)
                      Row(
                        children: [
                          const Text('🔥 ', style: TextStyle(fontSize: 11)),
                          Text(
                            'Chuỗi thắng: ${player.arenaWinStreak}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentCard(Player player, ArenaOpponent opponent) {
    final playerPower = player.combatPower;
    final diff = opponent.totalPower - playerPower;
    final diffPercent = ((diff.abs() / max(1, playerPower)) * 100).round();
    final isHarder = opponent.totalPower > playerPower;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181226),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.redAccent.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.redAccent.withOpacity(0.18),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: "ĐỐI THỦ TIẾP THEO" + Refresh Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF231735),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ĐỐI THỦ TIẾP THEO',
                      style: GoogleFonts.cinzel(
                        color: Colors.amber,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _generateNextOpponent();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Đổi đối thủ',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar, Name, Level, Theme
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.redAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.redAccent.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AssetMapping.safeImage(
                          opponent.avatarAsset,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          fallbackEmoji: '⚔️',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opponent.name,
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${opponent.buildTheme} • Lv.${opponent.level}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Power comparison badge
                          Row(
                            children: [
                              Text(
                                'Lực chiến: ${opponent.totalPower}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isHarder
                                      ? Colors.redAccent.withOpacity(0.2)
                                      : Colors.greenAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isHarder ? Colors.redAccent : Colors.greenAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isHarder ? '▲ +$diffPercent%' : '▼ -$diffPercent%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isHarder ? Colors.redAccent : Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Skill Preview Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kỹ năng xuất trận:',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                      ),
                      Row(
                        children: [
                          for (final sId in opponent.skillIds)
                            Tooltip(
                              message: '${SeedSkills.getById(sId).name}: ${SeedSkills.getById(sId).description}',
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF261D36),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    SeedSkills.getById(sId).emoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Big Red Challenge Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.heavyImpact();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => BattleScreen(
                            zoneId: 98,
                            stage: 1,
                            isArena: true,
                            arenaOpponent: opponent,
                          ),
                        ),
                      );
                      // After battle returns, roll a fresh opponent
                      _generateNextOpponent();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '⚔️ KHIÊU CHIẾN ĐỐI THỦ',
                          style: GoogleFonts.cinzel(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistorySection(Player player) {
    final history = player.arenaMatchHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppTheme.goldAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              'LỊCH SỬ ĐẤU (10 TRẬN GẦN NHẤT)',
              style: GoogleFonts.cinzel(
                color: AppTheme.goldAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(
                'Chưa có trận đấu nào. Hãy khiêu chiến ngay!',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final rec = history[index];
              final isWin = rec.isWin;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161222),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWin ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Win / Loss Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWin ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isWin ? Colors.greenAccent : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isWin ? 'THẮNG' : 'THUA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isWin ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Opponent Avatar
                    ClipOval(
                      child: AssetMapping.safeImage(
                        rec.opponentAvatar,
                        width: 32,
                        height: 32,
                        fallbackEmoji: '🤺',
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Opponent Name
                    Expanded(
                      child: Text(
                        'vs ${rec.opponentName}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // AP delta
                    Text(
                      rec.apChange > 0 ? '+${rec.apChange} AP' : '${rec.apChange} AP',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isWin ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // =========================================================================
  // TAB 2: VIRTUAL LEADERBOARD
  // =========================================================================
  Widget _buildLeaderboardTab(Player player) {
    final entries = ref.read(playerProvider.notifier).getLeaderboardEntries();
    final playerRankIndex = entries.indexWhere((e) => e.isPlayer);
    final isPlayerInTop10 = playerRankIndex >= 0 && playerRankIndex < 10;

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(14, 14, 14, isPlayerInTop10 ? 20 : 80),
          itemCount: entries.length,
          itemBuilder: (ctx, index) {
            final entry = entries[index];
            final rank = index + 1;
            final isPlayer = entry.isPlayer;

            Color borderColor = Colors.white10;
            Color? rankBgColor;
            String? rankCrown;

            if (rank == 1) {
              borderColor = const Color(0xFFFFD700);
              rankBgColor = const Color(0x33FFD700);
              rankCrown = '👑';
            } else if (rank == 2) {
              borderColor = const Color(0xFFC0C0C0);
              rankBgColor = const Color(0x33C0C0C0);
              rankCrown = '🥈';
            } else if (rank == 3) {
              borderColor = const Color(0xFFCD7F32);
              rankBgColor = const Color(0x33CD7F32);
              rankCrown = '🥉';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: isPlayer
                    ? const LinearGradient(
                        colors: [Color(0xFF382A10), Color(0xFF1E1728)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isPlayer ? null : const Color(0xFF151022),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPlayer ? AppTheme.goldAccent : borderColor,
                  width: isPlayer ? 1.8 : 1.0,
                ),
                boxShadow: isPlayer
                    ? [
                        BoxShadow(
                          color: AppTheme.goldAccent.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Rank # Badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: rankBgColor ?? Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: rankCrown != null
                          ? Text(rankCrown, style: const TextStyle(fontSize: 16))
                          : Text(
                              '#$rank',
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Avatar
                  ClipOval(
                    child: AssetMapping.safeImage(
                      entry.avatarAsset,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      fallbackEmoji: '👤',
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.name,
                              style: GoogleFonts.cinzel(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPlayer ? AppTheme.goldAccent : Colors.white,
                              ),
                            ),
                            if (isPlayer) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BẠN',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.title} • ${entry.rankInfo.displayName}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: entry.rankInfo.tier.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AP Badge
                  Text(
                    '${entry.ap} AP',
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Pinned Bottom Card if player is not in top 10
        if (!isPlayerInTop10)
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF382A10), Color(0xFF1E1728)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('📍 ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vị trí của bạn: #${playerRankIndex + 1} — ${player.name}',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                        Text(
                          '${ArenaRankInfo.fromAp(player.arenaPoints).displayName} • ${player.arenaPoints} AP',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${player.arenaPoints} AP',
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // TAB 3: SEASON PASS (30 MILESTONES)
  // =========================================================================
  Widget _buildSeasonPassTab(Player player) {
    final milestones = SeasonMilestone.generateMilestones();
    final cumulativeAp = player.cumulativeSeasonAp;

    // Calculate days passed in 30-day season
    final now = DateTime.now().millisecondsSinceEpoch;
    final seasonStart = player.seasonStartTimestamp > 0 ? player.seasonStartTimestamp : now;
    final daysPassed = min(30, max(1, ((now - seasonStart) / (1000 * 60 * 60 * 24)).floor() + 1));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Season Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1C4D), Color(0xFF161026)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎫 MÙA 1: ĐẠI CHIẾN PHONG VÂN',
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    Text(
                      'Ngày $daysPassed / 30',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Điểm AP Tích Lũy Mùa:',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                    ),
                    Text(
                      '$cumulativeAp / 3000 AP',
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (cumulativeAp / 3000).clamp(0.0, 1.0),
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                    minHeight: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 30 Milestones Grid (5 cols x 6 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemCount: milestones.length,
            itemBuilder: (ctx, index) {
              final m = milestones[index];
              final isClaimed = player.claimedSeasonMilestones.contains(m.level);
              final isUnlocked = cumulativeAp >= m.requiredAp;

              Color borderColor = Colors.white12;
              Color bgColor = const Color(0xFF140F20);

              if (isClaimed) {
                borderColor = Colors.greenAccent.withOpacity(0.6);
                bgColor = const Color(0xFF112215);
              } else if (isUnlocked) {
                borderColor = AppTheme.goldAccent;
                bgColor = const Color(0xFF2C220E);
              }

              return InkWell(
                onTap: isUnlocked && !isClaimed
                    ? () {
                        HapticFeedback.heavyImpact();
                        final success = ref
                            .read(playerProvider.notifier)
                            .claimSeasonMilestone(m.level);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 Đã nhận phần thưởng ${m.title}: ${m.rewardDescription}!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isClaimed
                                  ? '${m.title}: Đã nhận thưởng!'
                                  : '${m.title}: Yêu cầu ${m.requiredAp} AP (${m.rewardDescription})',
                            ),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: isUnlocked && !isClaimed ? 1.6 : 1),
                    boxShadow: isUnlocked && !isClaimed
                        ? [
                            BoxShadow(
                              color: AppTheme.goldAccent.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${m.level}',
                        style: GoogleFonts.cinzel(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppTheme.goldAccent : Colors.white54,
                        ),
                      ),
                      Text(
                        m.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                      if (isClaimed)
                        const Text(
                          '✅ ĐÃ NHẬN',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        )
                      else if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NHẬN',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        )
                      else
                        Text(
                          '${m.requiredAp} AP',
                          style: const TextStyle(fontSize: 8, color: Colors.white38),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
