import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/skill.dart';
import '../theme/app_theme.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final int currentLevel;
  final bool isEquippedForBattle;
  final bool canUpgrade;
  final VoidCallback? onUpgrade;
  final VoidCallback? onToggleEquip;

  const SkillCard({
    super.key,
    required this.skill,
    required this.currentLevel,
    this.isEquippedForBattle = false,
    this.canUpgrade = false,
    this.onUpgrade,
    this.onToggleEquip,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    String typeLabel;

    switch (skill.type) {
      case SkillType.basic:
        typeColor = AppTheme.blueAccent;
        typeLabel = 'Đánh thường';
        break;
      case SkillType.active:
        typeColor = AppTheme.goldAccent;
        typeLabel = 'Chủ động';
        break;
      case SkillType.passive:
        typeColor = AppTheme.purpleAccent;
        typeLabel = 'Bị động';
        break;
    }

    final isUnlocked = currentLevel > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEquippedForBattle
              ? AppTheme.goldAccent
              : (isUnlocked ? typeColor.withOpacity(0.5) : Colors.white10),
          width: isEquippedForBattle ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isEquippedForBattle
                ? AppTheme.goldAccent.withOpacity(0.25)
                : Colors.black.withOpacity(0.35),
            blurRadius: isEquippedForBattle ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji / Icon Container
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? typeColor.withOpacity(0.18)
                      : Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isUnlocked ? typeColor.withOpacity(0.7) : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  skill.emoji,
                  style: TextStyle(
                    fontSize: 26,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Tag & Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            skill.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isUnlocked ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: typeColor.withOpacity(0.5), width: 1),
                          ),
                          child: Text(
                            typeLabel,
                            style: GoogleFonts.inter(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          isUnlocked
                              ? 'Cấp $currentLevel / ${skill.maxLevel}'
                              : 'Chưa mở khóa',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? AppTheme.goldAccent : Colors.grey,
                          ),
                        ),
                        if (skill.manaCost > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '💧 ${skill.manaCost} MP',
                            style: const TextStyle(fontSize: 11, color: AppTheme.blueAccent),
                          ),
                        ],
                        if (skill.cooldown > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '⏱️ ${skill.cooldown}s',
                            style: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            skill.description,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: Colors.white70,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUnlocked && skill.type != SkillType.passive && onToggleEquip != null)
                OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onToggleEquip?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isEquippedForBattle ? AppTheme.goldAccent : Colors.white70,
                    side: BorderSide(
                      color: isEquippedForBattle ? AppTheme.goldAccent : Colors.white24,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    isEquippedForBattle ? '✓ Đang Ra Trận' : 'Cài Xuất Trận',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              if (onUpgrade != null && currentLevel < skill.maxLevel)
                ElevatedButton(
                  onPressed: canUpgrade
                      ? () {
                          HapticFeedback.lightImpact();
                          onUpgrade?.call();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    isUnlocked ? 'Nâng Cấp (+1)' : 'Mở Khóa',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
