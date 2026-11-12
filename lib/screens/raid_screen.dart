import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../models/player.dart';
import '../models/raid_boss.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';
import 'battle_screen.dart';

class RaidScreen extends ConsumerStatefulWidget {
  const RaidScreen({super.key});

  @override
  ConsumerState<RaidScreen> createState() => _RaidScreenState();
}

class _RaidScreenState extends ConsumerState<RaidScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).initRaidWeekIfNeeded();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimeUntilReset() {
    final ms = RaidBossInfo.getMsUntilNextReset();
    final totalSec = ms ~/ 1000;
    final days = totalSec ~/ 86400;
    final hours = (totalSec % 86400) ~/ 3600;
    final mins = (totalSec % 3600) ~/ 60;
    final secs = totalSec % 60;
    return '${days}d ${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final boss = RaidBossInfo.getCurrentRaidBoss();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F0D16),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text('🐲 ', style: TextStyle(fontSize: 22)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SĂN BOSS THẾ GIỚI',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.goldAccent,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Endgame Raid • Luân phiên tuần',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Stamina badge
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.amberAccent),
                const SizedBox(width: 4),
                Text(
                  '${player.raidStamina}/20',
                  style: GoogleFonts.cinzel(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B1E3F), Color(0xFF5A1027)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'SĂN MA VƯƠNG'),
                Tab(text: 'BẢNG XẾP HẠNG'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRaidBossTab(player, boss),
          _buildLeaderboardTab(player, boss),
        ],
      ),
    );
  }

  Widget _buildRaidBossTab(Player player, RaidBossInfo boss) {
    final currentHp = player.raidBossCurrentHp;
    final maxHp = boss.maxHp;
    final hpRatio = (currentHp / maxHp).clamp(0.0, 1.0);
    final isBossDead = currentHp <= 0;
    final hasEnoughStamina = player.raidStamina >= 5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Countdown banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF23101C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Làm mới sau:',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Text(
                _formatTimeUntilReset(),
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Giant Boss Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1322), Color(0xFF14070F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBossDead ? AppTheme.goldAccent : Colors.redAccent.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Boss Avatar & Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isBossDead ? AppTheme.goldAccent : AppTheme.redAccent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isBossDead ? AppTheme.goldAccent : Colors.redAccent).withOpacity(0.5),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AssetMapping.safeImage(
                        boss.imageAsset,
                        width: 130,
                        height: 130,
                        fallbackEmoji: boss.icon,
                      ),
                    ),
                  ),
                  if (isBossDead)
                    Positioned(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                        ),
                        child: Text(
                          'ĐÃ TIÊU DIỆT',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                boss.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${boss.title} • Tuần ${(boss.weekIndex + 1)}/3',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 14),

              // Boss Stats & Special traits
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBossStatBadge('⚔️ Công', '${boss.atk}'),
                  _buildBossStatBadge('🛡️ Giáp', '${boss.def.round()}'),
                  if (boss.magicResist > 0)
                    _buildBossStatBadge('🌀 Kháng Phép', '+${(boss.magicResist * 100).round()}%'),
                  if (boss.lifestealPercent > 0)
                    _buildBossStatBadge('🩸 Hút Máu', '+${(boss.lifestealPercent * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal HP Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sinh Mệnh Cổ Thần:',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                      Text(
                        '$currentHp / $maxHp (${(hpRatio * 100).toStringAsFixed(1)}%)',
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isBossDead ? AppTheme.goldAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Container(
                          height: 18,
                          width: double.infinity,
                          color: Colors.black54,
                        ),
                        FractionallySizedBox(
                          widthFactor: hpRatio,
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade900,
                                  Colors.redAccent,
                                  Colors.orangeAccent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Damage done this week
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng sát thương tuần này:',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${player.weeklyRaidDamage}',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Thể lực: ${player.raidStamina}/20',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hồi 1 sau mỗi 5 phút',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.amberAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grand Reward CTA if slain
        if (isBossDead) ...[
          if (!player.hasClaimedWeeklyRaidReward)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                final reward = ref.read(playerProvider.notifier).claimRaidGrandReward();
                if (reward != null) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.bgSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.goldAccent, width: 2),
                      ),
                      title: Text(
                        '🎉 CHIẾN LỢI PHẨM THẦN THOẠI!',
                        style: GoogleFonts.cinzel(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bạn nhận được: 100 💎 Kim Cương!'),
                          Text('Danh hiệu mới: [${boss.grandTitle}]!'),
                          const SizedBox(height: 8),
                          Text('Vũ khí Huyền Thoại: ${reward.name} (ATK +${reward.flatAtk})!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('TUYỆT VỜI'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text(
                '🎁 NHẬN THẦN BINH HUYỀN THOẠI & 100 💎',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w900, fontSize: 13.5),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent),
              ),
              alignment: Alignment.center,
              child: Text(
                '✅ ĐÃ NHẬN CHIẾN LỢI PHẨM TUẦN NÀY',
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],

        // Attack Button
        if (!isBossDead)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasEnoughStamina ? const Color(0xFF9E1D2D) : Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: hasEnoughStamina ? 6 : 0,
            ),
            onPressed: hasEnoughStamina
                ? () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BattleScreen(
                          zoneId: 97,
                          stage: 1,
                          isRaid: true,
                          raidBoss: boss,
                        ),
                      ),
                    );
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  hasEnoughStamina ? '⚔️ TẤN CÔNG (Tốn 5 Thể Lực)' : 'KHÔNG ĐỦ THỂ LỰC (Cần 5)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),

        // Buy Stamina Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.6)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: player.dailyStaminaPurchases < 3 && player.gems >= 1
              ? () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: AppTheme.bgSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
                      ),
                      title: Text(
                        'XÁC NHẬN MUA THỂ LỰC',
                        style: GoogleFonts.cinzel(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      content: const Text(
                        'Xác nhận tốn 1 💎 để mua 5 vé khiêu chiến?',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Hủy', style: TextStyle(color: Colors.white60)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldAccent,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            final success = ref.read(playerProvider.notifier).buyRaidStamina();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã mua +5 Thể Lực Raid thành công!')),
                              );
                            }
                          },
                          child: const Text('Xác nhận (1 💎)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
              : null,
          child: Text(
            '⚡ Hồi +5 Thể Lực (1 💎) [${player.dailyStaminaPurchases}/3 lần hôm nay]',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: player.dailyStaminaPurchases < 3 && player.gems >= 1
                  ? AppTheme.goldAccent
                  : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBossStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.cinzel(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(Player player, RaidBossInfo boss) {
    // Generate 9 local AI rivals seeded by week
    final baseNames = [
      'Bá Chủ Hư Không',
      'Đao Vương Cuồng Bạo',
      'Kiếm Tiên Tiêu Dao',
      'Ma Đạo Tổ Sư',
      'Lôi Đình Chiến Thần',
      'Thần Thương Vô Địch',
      'Huyết Vũ Cuồng Ma',
      'Băng Nguyệt Nữ Đế',
      'Bất Bại Chiến Tướng',
    ];

    final weekSeed = boss.weekIndex * 100;
    final entries = <Map<String, dynamic>>[];

    for (int i = 0; i < baseNames.length; i++) {
      final dmg = (boss.maxHp * (0.60 - i * 0.05)).round() + ((weekSeed + i * 37) % 15000);
      entries.add({
        'name': baseNames[i],
        'damage': dmg,
        'isPlayer': false,
      });
    }

    // Add player
    entries.add({
      'name': player.name.isNotEmpty ? player.name : 'Bạn',
      'damage': player.weeklyRaidDamage,
      'isPlayer': true,
    });

    entries.sort((a, b) => (b['damage'] as int).compareTo(a['damage'] as int));
    final top10 = entries.take(10).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF241525),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏆 TOP 10 SÁT THƯƠNG TUẦN NÀY',
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Top 1 tổng kết cuối tuần nhận danh hiệu [Sát Thần] và 5000 🪙 Vàng!',
                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(top10.length, (index) {
          final item = top10[index];
          final rank = index + 1;
          final isPlayer = item['isPlayer'] as bool;
          final dmg = item['damage'] as int;

          Color rankColor = Colors.white70;
          if (rank == 1) rankColor = AppTheme.goldAccent;
          if (rank == 2) rankColor = const Color(0xFFC0C0C0);
          if (rank == 3) rankColor = const Color(0xFFCD7F32);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isPlayer
                  ? const LinearGradient(colors: [Color(0xFF2C2210), Color(0xFF141006)])
                  : AppTheme.surfaceGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlayer
                    ? AppTheme.goldAccent
                    : (rank <= 3 ? rankColor.withOpacity(0.5) : Colors.white10),
                width: isPlayer ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '#$rank',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        item['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                          color: isPlayer ? AppTheme.goldAccent : Colors.white,
                        ),
                      ),
                      if (isPlayer) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BẠN',
                            style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '$dmg DMG',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldAccent,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
