import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gem.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';

class GemVaultSheet extends ConsumerWidget {
  const GemVaultSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GemVaultSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);

    // Calculate total gems count
    int totalGems = 0;
    player.gemInventory.forEach((k, v) => totalGems += v);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.goldAccent, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KHO BẢO NGỌC',
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                        Text(
                          'Tổng cộng: $totalGems viên • 5 màu × 5 cấp',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                ),

                // Button "Ghép tất cả"
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final count = notifier.fuseAllGems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          count > 0
                              ? '✨ Đã tự động ghép thành công $count viên ngọc cấp cao!'
                              : '⚠️ Không đủ 3 viên cùng loại hoặc không đủ vàng để ghép!',
                        ),
                        backgroundColor: count > 0 ? Colors.green.shade800 : Colors.grey.shade800,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 14, color: Colors.black),
                  label: const Text(
                    'Ghép tất cả',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),

          // Gold info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppTheme.goldAccent),
                    const SizedBox(width: 6),
                    Text(
                      '3 ngọc Cấp N → 1 ngọc Cấp N+1 (Phí: 50 × N Vàng)',
                      style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  '💰 ${player.gold}',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 16),

          // 5x5 Grid Table (Rows: 5 Gem Types, Cols: 5 Levels)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: GemType.values.length,
              itemBuilder: (ctx, typeIdx) {
                final type = GemType.values[typeIdx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: type.color.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(type.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '${type.nameVi} (${type.statLabel})',
                                style: GoogleFonts.cinzel(
                                  color: type.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            type.dropSource,
                            style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 5 Level slots row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (lvlIdx) {
                          final lvl = lvlIdx + 1;
                          final gem = Gem(type: type, level: lvl);
                          final count = player.gemInventory[gem.id] ?? 0;

                          return InkWell(
                            onTap: () {
                              _showGemDetailDialog(context, ref, gem, count);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 64) / 5,
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                              decoration: BoxDecoration(
                                color: count > 0 ? type.color.withOpacity(0.12) : Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: count > 0 ? type.color.withOpacity(0.6) : Colors.white10,
                                  width: count > 0 ? 1.2 : 0.8,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Cấp $lvl',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: count > 0 ? Colors.white : Colors.white38,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    type.emoji,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: count > 0 ? null : Colors.white24,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    gem.bonusDescription,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      color: count > 0 ? type.color : Colors.white38,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: count > 0 ? type.color : Colors.white12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'x$count',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: count > 0 ? Colors.black : Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void _showGemDetailDialog(BuildContext context, WidgetRef ref, Gem gem, int count) {
    showDialog(
      context: context,
      builder: (ctx) {
        final player = ref.watch(playerProvider);
        final notifier = ref.read(playerProvider.notifier);
        final canUpgrade = count >= 3 && gem.level < 5 && player.gold >= gem.upgradeGoldCost;

        return AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: gem.type.color, width: 1.2),
          ),
          title: Row(
            children: [
              Text(gem.type.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  gem.name,
                  style: GoogleFonts.cinzel(
                    color: gem.type.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hiệu ứng: ${gem.bonusDescription}',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Số lượng đang có trong kho: $count viên',
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                'Nguồn rơi: ${gem.type.dropSource}',
                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white54),
              ),
              if (gem.level < 5) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nâng cấp lên Cấp ${gem.level + 1}:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Tiêu hao: 3 viên ${gem.name} (có $count)',
                        style: TextStyle(fontSize: 11, color: count >= 3 ? Colors.greenAccent : Colors.redAccent),
                      ),
                      Text(
                        '• Chi phí: ${gem.upgradeGoldCost} Vàng (có ${player.gold})',
                        style: TextStyle(fontSize: 11, color: player.gold >= gem.upgradeGoldCost ? Colors.greenAccent : Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng', style: TextStyle(color: Colors.white60)),
            ),
            if (gem.level < 5)
              ElevatedButton(
                onPressed: canUpgrade
                    ? () {
                        notifier.upgradeGem(gem);
                        Navigator.pop(ctx);
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✨ Nâng cấp thành công: ${gem.type.nameVi} Cấp ${gem.level + 1}!'),
                            backgroundColor: Colors.green.shade800,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Nâng Cấp'),
              ),
          ],
        );
      },
    );
  }
}
