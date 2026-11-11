import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../models/equipment.dart';
import '../models/gem.dart';
import '../theme/app_theme.dart';
import 'socket_row_widget.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment item;
  final bool isEquipped;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;
  final VoidCallback? onUpgrade;
  final VoidCallback? onSell;
  final VoidCallback? onReforge;
  final Function(int socketIndex, Gem? gem)? onTapSocket;

  const EquipmentCard({
    super.key,
    required this.item,
    this.isEquipped = false,
    this.onEquip,
    this.onUnequip,
    this.onUpgrade,
    this.onSell,
    this.onReforge,
    this.onTapSocket,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppTheme.getRarityColor(item.rarity);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rarityColor.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.12),
            blurRadius: 8,
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
              // Icon / Artwork with rarity border glow
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0C18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rarityColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withOpacity(0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AssetMapping.safeImage(
                    item.iconAsset,
                    width: 60,
                    height: 60,
                    fallbackEmoji: item.emoji,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: rarityColor.withOpacity(0.6), width: 1),
                          ),
                          child: Text(
                            item.rarity.label,
                            style: GoogleFonts.inter(
                              color: rarityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.slot.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.goldAccent.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Stat summary chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.effectiveFlatAtk > 0)
                          _buildStatChip('⚔️ +${item.effectiveFlatAtk} Công', AppTheme.redAccent),
                        if (item.effectiveFlatDef > 0)
                          _buildStatChip('🛡️ +${item.effectiveFlatDef} Giáp', AppTheme.blueAccent),
                        if (item.effectiveFlatHp > 0)
                          _buildStatChip('❤️ +${item.effectiveFlatHp} HP', AppTheme.greenAccent),
                        if (item.critRate > 0)
                          _buildStatChip('💥 +${(item.critRate * 100).round()}% Crit', AppTheme.goldAccent),
                        if (item.fireDmgPercent > 0)
                          _buildStatChip('🔥 +${(item.fireDmgPercent * 100).round()}% Hỏa', Colors.deepOrangeAccent),
                        if (item.bonusStats.str > 0)
                          _buildStatChip('STR +${item.bonusStats.str}', Colors.red.shade300),
                        if (item.bonusStats.int_ > 0)
                          _buildStatChip('INT +${item.bonusStats.int_}', Colors.blue.shade300),
                        if (item.bonusStats.vit > 0)
                          _buildStatChip('VIT +${item.bonusStats.vit}', Colors.green.shade300),
                      ],
                    ),
                    if (item.affixes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.affixes
                            .map((a) => _buildStatChip(a.description, Colors.purpleAccent))
                            .toList(),
                      ),
                    ],
                    if (item.insertedGems.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.insertedGems
                            .map((g) => _buildStatChip('${g.type.emoji} ${g.bonusDescription}', g.type.color))
                            .toList(),
                      ),
                    ],
                    if (item.maxSockets > 0)
                      SocketRowWidget(
                        item: item,
                        onTapSocket: onTapSocket,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Action Buttons (Equip, Unequip, Upgrade, Sell, Reforge)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onReforge != null && item.rarity.index >= EquipmentRarity.rare.index)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onReforge?.call();
                  },
                  icon: const Icon(Icons.casino, size: 14, color: Colors.purpleAccent),
                  label: const Text('Reforge', style: TextStyle(fontSize: 11, color: Colors.purpleAccent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              if (onSell != null && !isEquipped)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSell?.call();
                  },
                  icon: const Icon(Icons.monetization_on, size: 14, color: AppTheme.goldAccent),
                  label: Text('Bán (${item.sellPrice})', style: const TextStyle(fontSize: 11, color: AppTheme.goldAccent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              if (onUpgrade != null)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onUpgrade?.call();
                  },
                  icon: const Icon(Icons.arrow_upward, size: 14, color: AppTheme.blueAccent),
                  label: Text(
                    item.upgradeLevel < item.maxUpgradeLevel
                        ? 'Cường hóa (+${item.upgradeLevel + 1})'
                        : 'Tối đa',
                    style: const TextStyle(fontSize: 11, color: AppTheme.blueAccent),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              const SizedBox(width: 4),
              if (isEquipped && onUnequip != null)
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onUnequip?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Tháo', style: TextStyle(fontSize: 12)),
                )
              else if (!isEquipped && onEquip != null)
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEquip?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Trang Bị', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
