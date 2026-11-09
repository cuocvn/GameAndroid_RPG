import 'package:flutter/material.dart';
import '../data/asset_mapping.dart';
import '../models/equipment.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment item;
  final bool isEquipped;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;
  final VoidCallback? onUpgrade;
  final VoidCallback? onSell;

  const EquipmentCard({
    super.key,
    required this.item,
    this.isEquipped = false,
    this.onEquip,
    this.onUnequip,
    this.onUpgrade,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.rarity.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon / Image
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: AssetMapping.safeImage(
                item.iconAsset,
                width: 58,
                height: 58,
                fallbackEmoji: item.emoji,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.rarity.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Upgrade Level tag
                Row(
                  children: [
                    Text(
                      'Cấp ${item.upgradeLevel}/${item.maxUpgradeLevel} (+${item.upgradeLevel * 10}%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.upgradeLevel > 0 ? Colors.amberAccent : Colors.white60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Stat Bonuses Row (effective with upgrade bonuses)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.flatAtk > 0)
                      _statTag('⚔️ +${item.effectiveFlatAtk} ATK', Colors.orangeAccent),
                    if (item.flatDef > 0)
                      _statTag('🛡️ +${item.effectiveFlatDef} DEF', Colors.lightBlueAccent),
                    if (item.flatHp > 0)
                      _statTag('❤️ +${item.effectiveFlatHp} HP', Colors.greenAccent),
                    if (item.fireDmgPercent > 0)
                      _statTag('🔥 +${(item.fireDmgPercent * 100).round()}% Lửa', Colors.redAccent),
                    if (item.critRate > 0)
                      _statTag('💥 +${(item.critRate * 100).round()}% Crit', Colors.amberAccent),
                    if (item.manaRegen > 0)
                      _statTag('🌀 +${item.manaRegen.toStringAsFixed(1)} Mana/s', Colors.cyanAccent),
                    if (item.bonusStats.str > 0)
                      _statTag('+${item.bonusStats.str} STR', Colors.red.shade300),
                    if (item.bonusStats.int_ > 0)
                      _statTag('+${item.bonusStats.int_} INT', Colors.purple.shade300),
                    if (item.bonusStats.vit > 0)
                      _statTag('+${item.bonusStats.vit} VIT', Colors.green.shade300),
                    if (item.bonusStats.agi > 0)
                      _statTag('+${item.bonusStats.agi} AGI', Colors.teal.shade300),
                    if (item.bonusStats.luk > 0)
                      _statTag('+${item.bonusStats.luk} LUK', Colors.amber.shade300),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          Column(
            children: [
              if (isEquipped)
                ElevatedButton(
                  onPressed: onUnequip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 28),
                  ),
                  child: const Text('Tháo', style: TextStyle(fontSize: 11, color: Colors.white70)),
                )
              else
                ElevatedButton(
                  onPressed: onEquip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 28),
                  ),
                  child: const Text('Mặc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),

              // Upgrade Button
              if (onUpgrade != null && item.upgradeLevel < item.maxUpgradeLevel) ...[
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: onUpgrade,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amberAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: const Size(60, 26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡ ', style: TextStyle(fontSize: 10)),
                      Text('${item.upgradeGoldCost}🪙', style: const TextStyle(fontSize: 9.5, color: Colors.amberAccent)),
                    ],
                  ),
                ),
              ],

              if (!isEquipped && onSell != null) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: onSell,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Bán (${item.sellPrice}🪙)',
                      style: const TextStyle(fontSize: 9.5, color: Colors.amberAccent),
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

  Widget _statTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
