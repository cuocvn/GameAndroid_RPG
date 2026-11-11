import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prestige_node.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';

class PrestigeScreen extends ConsumerStatefulWidget {
  const PrestigeScreen({super.key});

  @override
  ConsumerState<PrestigeScreen> createState() => _PrestigeScreenState();
}

class _PrestigeScreenState extends ConsumerState<PrestigeScreen> {
  void _confirmPrestige(int ptsToGain) {
    final player = ref.read(playerProvider);
    final bossCount = player.clearedStages.where((s) => s.endsWith('_s5')).length;
    final nextPrestige = player.prestigeLevel + 1;
    final multiplier = 1.0 + (nextPrestige - 1) * 0.2;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
        ),
        title: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'XÁC NHẬN CHUYỂN SINH',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chuyển sinh sang Cấp $nextPrestige (Hệ số x${multiplier.toStringAsFixed(1)})',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔮 Nhận ngay: +$ptsToGain Điểm Ngộ Đạo',
                    style: GoogleFonts.cinzel(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Chi tiết: Lv.${player.level} (${player.level ~/ 5}) + Tháp F${player.highestEndlessFloor} (${player.highestEndlessFloor ~/ 3}) + $bossCount Boss (${bossCount * 2})',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ THAY ĐỔI KHI CHUYỂN SINH:\n'
              '• Reset: Cấp độ về 1, Điểm chỉ số, Trang bị & Vàng về 0, Kỹ năng về khởi đầu.\n'
              '• Giữ lại: Toàn bộ Cây Ngộ Đạo, Điểm Ngộ Đạo tích lũy, Đá Quý (💎), Kỷ lục Tháp Vô Tận & Thành tựu.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'HỦY BỎ',
              style: GoogleFonts.cinzel(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final success = ref.read(playerProvider.notifier).doPrestige();
              if (success) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.purple.shade900,
                    content: Text(
                      '🎉 CHUYỂN SINH THÀNH CÔNG! Nhận +$ptsToGain Điểm Ngộ Đạo!',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'TIẾN HÀNH',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetTree() {
    final player = ref.read(playerProvider);
    if (player.gems < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.redAccent,
          content: Text('Không đủ Đá Quý! Cần 5 💎 để tẩy Cây Ngộ Đạo.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
        ),
        title: Text(
          'TẨY CÂY NGỘ ĐẠO?',
          style: GoogleFonts.cinzel(
            color: AppTheme.goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tiêu tốn 5 💎 để thu hồi lại toàn bộ 100% Điểm Ngộ Đạo đã đầu tư vào các nhánh buff vĩnh viễn. Bạn có thể tự do phân phối lại!',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('HỦY', style: GoogleFonts.cinzel(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playerProvider.notifier).resetPrestigeTree();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.bgSurface,
                  content: Text('Đã tẩy Cây Ngộ Đạo thành công! Hoàn trả toàn bộ điểm.'),
                ),
              );
            },
            child: Text('ĐỒNG Ý (5 💎)', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);
    final ptsToGain = notifier.calculatePrestigePoints();
    final canPrestigeNow = notifier.canPrestige;
    final bossCount = player.clearedStages.where((s) => s.endsWith('_s5')).length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        title: Text(
          'CÂY NGỘ ĐẠO',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.goldAccent,
          ),
        ),
        actions: [
          // Reset tree button (5 gems)
          TextButton.icon(
            onPressed: _confirmResetTree,
            icon: const Text('💎', style: TextStyle(fontSize: 13)),
            label: Text(
              'Tẩy Cây (5)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Overview Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade900.withOpacity(0.5),
                    AppTheme.bgSurface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.shade900,
                      border: Border.all(color: Colors.purpleAccent, width: 2),
                    ),
                    child: const Text('🔮', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${player.enlightenmentPoints}',
                              style: GoogleFonts.cinzel(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ĐIỂM NGỘ ĐẠO',
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cấp Chuyển Sinh: ${player.prestigeLevel} • Thưởng tích lũy: x${(1.0 + player.prestigeLevel * 0.2).toStringAsFixed(1)}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppTheme.goldAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Header
            Row(
              children: [
                const Icon(Icons.account_tree, color: AppTheme.goldAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'NHÁNH TU LUYỆN VĨNH VIỄN',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2-column Grid of 10 Nodes
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: PrestigeNodeData.allNodes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final node = PrestigeNodeData.allNodes[index];
                final currentLvl = player.prestigeNodeLevels[node.id] ?? 0;
                final isMax = currentLvl >= node.maxLevel;
                final canAfford = player.enlightenmentPoints >= node.costPerLevel;
                final isHighlight = isMax || canAfford;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isMax
                          ? AppTheme.goldAccent
                          : (canAfford
                              ? Colors.purpleAccent
                              : Colors.white12),
                      width: isHighlight ? 1.5 : 1,
                    ),
                    boxShadow: canAfford && !isMax
                        ? [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(node.icon, style: const TextStyle(fontSize: 22)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMax
                                  ? AppTheme.goldAccent.withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isMax ? AppTheme.goldAccent : Colors.white24,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isMax ? 'MAX' : '$currentLvl/${node.maxLevel}',
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isMax ? AppTheme.goldAccent : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        node.name,
                        style: GoogleFonts.cinzel(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isMax ? AppTheme.goldAccent : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: Text(
                          node.description,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white60,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: (!isMax && canAfford)
                              ? () {
                                  HapticFeedback.lightImpact();
                                  notifier.upgradePrestigeNode(node.id);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford
                                ? Colors.purple.shade800
                                : Colors.white10,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withOpacity(0.04),
                            disabledForegroundColor: Colors.white30,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: canAfford && !isMax
                                    ? Colors.purpleAccent
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            isMax
                                ? 'ĐÃ MAX'
                                : (canAfford
                                    ? '+1 Cấp (${node.costPerLevel} 🔮)'
                                    : 'Cần ${node.costPerLevel} 🔮'),
                            style: GoogleFonts.cinzel(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isMax
                                  ? AppTheme.goldAccent
                                  : (canAfford ? Colors.white : Colors.white30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Bottom Prestige Trigger Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: canPrestigeNow
                    ? LinearGradient(
                        colors: [
                          AppTheme.goldAccent.withOpacity(0.2),
                          AppTheme.bgSurface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: canPrestigeNow ? null : AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: canPrestigeNow
                      ? AppTheme.goldAccent
                      : Colors.white12,
                  width: canPrestigeNow ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        canPrestigeNow
                            ? 'ĐÃ ĐỦ ĐIỀU KIỆN CHUYỂN SINH'
                            : 'ĐIỀU KIỆN MỞ KHÓA CHUYỂN SINH',
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canPrestigeNow ? AppTheme.goldAccent : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Điều kiện: Đạt Level 30 HOẶC Vượt Tháp Vô Tận Tầng 15.\n'
                    'Hiện tại: Level ${player.level}/30 • Tháp Vô Tận F${player.highestEndlessFloor}/15 • Đã hạ $bossCount Boss',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (canPrestigeNow) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Điểm Ngộ Đạo dự kiến:',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            '+$ptsToGain 🔮',
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _confirmPrestige(ptsToGain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              'TIẾN HÀNH CHUYỂN SINH (LẦN ${player.prestigeLevel + 1})',
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔒 Chưa đủ điều kiện. Hãy tiếp tục vượt ải hoặc leo Tháp Vô Tận để đạt mốc Chuyển Sinh!',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
