import 'package:flutter/material.dart';
import '../models/skill.dart';

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
        typeColor = Colors.lightBlueAccent;
        typeLabel = 'Đánh thường';
        break;
      case SkillType.active:
        typeColor = Colors.orangeAccent;
        typeLabel = 'Chủ động';
        break;
      case SkillType.passive:
        typeColor = Colors.purpleAccent;
        typeLabel = 'Bị động';
        break;
    }

    final isUnlocked = currentLevel > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.grey.shade900.withOpacity(0.9)
            : Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquippedForBattle
              ? Colors.amberAccent
              : (isUnlocked ? typeColor.withOpacity(0.6) : Colors.grey.shade700),
          width: isEquippedForBattle ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji/Icon
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: typeColor.withOpacity(0.6), width: 1.5),
            ),
            child: Text(
              skill.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),

          // Skill Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        skill.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isUnlocked ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  skill.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 6),

                // Tags: Cost, CD, Level
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(
                      'Cấp: $currentLevel/${skill.maxLevel}',
                      isUnlocked ? Colors.greenAccent : Colors.grey,
                    ),
                    if (skill.manaCost > 0)
                      _tag('💧 ${skill.manaCost} Mana', Colors.cyanAccent),
                    if (skill.cooldown > 0)
                      _tag('⏱️ ${skill.cooldown.toStringAsFixed(1)}s CD', Colors.tealAccent),
                    if (skill.causesBurn)
                      _tag('🔥 Gây Thiêu Đốt', Colors.deepOrangeAccent),
                    if (skill.grantsShield)
                      _tag('🛡️ Tạo Khiên Hộ Thân', Colors.amberAccent),
                    if (skill.fireDmgBonus > 0)
                      _tag('+${(skill.currentFireDmgBonus * 100).round()}% Lửa', Colors.redAccent),
                    if (skill.burnTargetBonus > 0)
                      _tag('+${(skill.currentBurnTargetBonus * 100).round()}% lên mục tiêu Cháy', Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action buttons
          Column(
            children: [
              if (canUpgrade && currentLevel < skill.maxLevel)
                ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 30),
                  ),
                  child: const Text('Nâng +1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              if (isUnlocked && skill.type != SkillType.passive) ...[
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: onToggleEquip,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isEquippedForBattle ? Colors.amberAccent : Colors.grey,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 28),
                  ),
                  child: Text(
                    isEquippedForBattle ? 'Đang bật' : 'Trang bị',
                    style: TextStyle(
                      fontSize: 10,
                      color: isEquippedForBattle ? Colors.amberAccent : Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
