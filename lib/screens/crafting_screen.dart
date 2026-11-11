import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crafting_recipe.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';

class CraftingScreen extends ConsumerStatefulWidget {
  const CraftingScreen({super.key});

  @override
  ConsumerState<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends ConsumerState<CraftingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _selectedTransmuteItemIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LÒ RÈN & CHẾ TẠO',
          style: GoogleFonts.cinzel(
            color: AppTheme.goldAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.goldAccent,
          indicatorWeight: 2.5,
          labelColor: AppTheme.goldAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.handyman, size: 18), text: 'CHẾ TẠO'),
            Tab(icon: Icon(Icons.local_fire_department, size: 18), text: 'BIẾN ĐỔI (LÒ RÈN)'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Materials top bar
          _buildMaterialsBar(player),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCraftingTab(player, notifier),
                _buildTransmuteTab(player, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsBar(Player player) {
    final iron = player.craftingMaterials['iron'] ?? 0;
    final crystal = player.craftingMaterials['crystal'] ?? 0;
    final steel = player.craftingMaterials['steel'] ?? 0;
    final essence = player.craftingMaterials['essence'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppTheme.bgSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _matChip('🔩 Sắt', iron, Colors.grey.shade300),
          _matChip('💠 Pha Lê', crystal, Colors.cyanAccent),
          _matChip('🌑 Hắc Kim', steel, Colors.purpleAccent),
          _matChip('✨ Tinh Hoa', essence, AppTheme.goldAccent),
        ],
      ),
    );
  }

  Widget _matChip(String label, int count, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  // --- TAB 1: CRAFTING ---
  Widget _buildCraftingTab(Player player, PlayerNotifier notifier) {
    final recipes = CraftingRecipe.allRecipes;

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: recipes.length,
      itemBuilder: (ctx, idx) {
        final r = recipes[idx];
        final isUnlocked = player.level >= r.requiredLevel;
        final isCrafted = player.craftedRecipeIds.contains(r.id);

        bool hasMats = true;
        r.requiredMaterials.forEach((k, v) {
          if ((player.craftingMaterials[k] ?? 0) < v) hasMats = false;
        });
        final hasGold = player.gold >= r.goldCost;
        final hasGems = player.gems >= r.gemsCost;
        final canCraft = isUnlocked && hasMats && hasGold && hasGems;

        final rarityColor = AppTheme.getRarityColor(r.targetRarity);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnlocked ? AppTheme.bgSurface : Colors.black38,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked ? rarityColor.withOpacity(0.6) : Colors.white10,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isUnlocked ? rarityColor.withOpacity(0.15) : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isUnlocked ? rarityColor : Colors.white24),
                    ),
                    child: Center(
                      child: Text(r.emoji, style: TextStyle(fontSize: 26, color: isUnlocked ? null : Colors.white24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.name,
                                style: GoogleFonts.cinzel(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.white : Colors.white38,
                                ),
                              ),
                            ),
                            if (isCrafted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.greenAccent, width: 0.8),
                                ),
                                child: const Text('Đã chế tác', style: TextStyle(fontSize: 9.5, color: Colors.greenAccent)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          r.description,
                          style: TextStyle(fontSize: 11, color: isUnlocked ? Colors.white70 : Colors.white30),
                        ),
                        if (!isUnlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '🔒 Mở khóa khi đạt Level ${r.requiredLevel}',
                              style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 8),

              // Requirements Row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...r.requiredMaterials.entries.map((m) {
                    final owned = player.craftingMaterials[m.key] ?? 0;
                    final ok = owned >= m.value;
                    String matName = m.key;
                    if (m.key == 'iron') matName = 'Sắt Cổ';
                    if (m.key == 'crystal') matName = 'Pha Lê';
                    if (m.key == 'steel') matName = 'Hắc Kim';
                    if (m.key == 'essence') matName = 'Tinh Hoa';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ok ? Colors.white10 : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ok ? Colors.white24 : Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        '$matName: $owned/${m.value}',
                        style: TextStyle(fontSize: 10.5, color: ok ? Colors.white70 : Colors.redAccent),
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasGold ? Colors.white10 : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: hasGold ? Colors.white24 : Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      '💰 ${r.goldCost}',
                      style: TextStyle(fontSize: 10.5, color: hasGold ? AppTheme.goldAccent : Colors.redAccent),
                    ),
                  ),
                  if (r.gemsCost > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasGems ? Colors.white10 : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '💎 ${r.gemsCost}',
                        style: TextStyle(fontSize: 10.5, color: hasGems ? Colors.cyanAccent : Colors.redAccent),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Craft Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: canCraft
                      ? () {
                          HapticFeedback.heavyImpact();
                          final crafted = notifier.craftRecipe(r);
                          if (crafted != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Chế tạo thành công: [${crafted.name}] (${crafted.rarity.label})!'),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.hardware, size: 14),
                  label: const Text('Chế Tạo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: TRANSMUTE ---
  Widget _buildTransmuteTab(Player player, PlayerNotifier notifier) {
    final unequippedItems = List<Equipment>.from(player.inventory);

    // Group items by rarity
    final selectedItems = player.inventory.where((e) => _selectedTransmuteItemIds.contains(e.id)).toList();
    EquipmentRarity? activeRarity;
    if (selectedItems.isNotEmpty) {
      activeRarity = selectedItems.first.rarity;
    }

    int goldCost = 100;
    EquipmentRarity? targetRarity;
    if (activeRarity != null) {
      switch (activeRarity) {
        case EquipmentRarity.common:
          goldCost = 100;
          targetRarity = EquipmentRarity.uncommon;
          break;
        case EquipmentRarity.uncommon:
          goldCost = 300;
          targetRarity = EquipmentRarity.rare;
          break;
        case EquipmentRarity.rare:
          goldCost = 1000;
          targetRarity = EquipmentRarity.epic;
          break;
        case EquipmentRarity.epic:
          goldCost = 3000;
          targetRarity = EquipmentRarity.legendary;
          break;
        case EquipmentRarity.legendary:
          break;
      }
    }

    final canTransmute = selectedItems.length == 3 &&
        activeRarity != null &&
        activeRarity != EquipmentRarity.legendary &&
        player.gold >= goldCost;

    return Column(
      children: [
        // Top Transmute Pedestal
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5), width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LÒ LUYỆN BIẾN ĐỔI (3 MÓN CÙNG BẬC)',
                    style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _autoSelectLowestTrash(unequippedItems);
                    },
                    icon: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.goldAccent),
                    label: const Text('Tự động chọn 3 rác', style: TextStyle(fontSize: 10.5, color: AppTheme.goldAccent)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3 Slots row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (idx) {
                  final item = idx < selectedItems.length ? selectedItems[idx] : null;
                  return InkWell(
                    onTap: item != null
                        ? () {
                            setState(() {
                              _selectedTransmuteItemIds.remove(item.id);
                            });
                          }
                        : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item != null ? AppTheme.getRarityColor(item.rarity) : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: item != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 9, color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          : const Center(
                              child: Icon(Icons.add, color: Colors.white24, size: 28),
                            ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),
              if (targetRarity != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_downward, color: AppTheme.goldAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Sản phẩm dự kiến: 1 món ${targetRarity.label} ${activeRarity == EquipmentRarity.epic ? "(Tỉ lệ 30%)" : ""}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getRarityColor(targetRarity),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Chi phí: $goldCost Vàng',
                  style: TextStyle(
                    fontSize: 11,
                    color: player.gold >= goldCost ? AppTheme.goldAccent : Colors.redAccent,
                  ),
                ),
              ],

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: canTransmute
                    ? () {
                        HapticFeedback.heavyImpact();
                        final result = notifier.transmuteEquipment(_selectedTransmuteItemIds);
                        setState(() {
                          _selectedTransmuteItemIds.clear();
                        });

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 Biến đổi thành công: [${result.name}] (${result.rarity.label})!'),
                              backgroundColor: Colors.green.shade800,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('💥 Biến đổi thất bại! Đã hoàn trả lại 1 món Epic.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.local_fire_department, size: 16),
                label: const Text('BIẾN ĐỔI TRANG BỊ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 38),
                ),
              ),
            ],
          ),
        ),

        // Inventory Selector List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHỌN TỪ KHO ĐỒ (${unequippedItems.length} MÓN)',
                style: GoogleFonts.cinzel(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              if (_selectedTransmuteItemIds.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedTransmuteItemIds.clear()),
                  child: const Text('Bỏ chọn tất cả', style: TextStyle(fontSize: 10.5, color: Colors.redAccent)),
                ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: unequippedItems.length,
            itemBuilder: (ctx, idx) {
              final item = unequippedItems[idx];
              final isSelected = _selectedTransmuteItemIds.contains(item.id);
              final isRarityMatch = activeRarity == null || activeRarity == item.rarity;
              final canSelect = isSelected || (selectedItems.length < 3 && isRarityMatch);

              final color = AppTheme.getRarityColor(item.rarity);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.18) : AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.white12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: canSelect ? Colors.white : Colors.white30,
                    ),
                  ),
                  subtitle: Text(
                    '${item.rarity.label} • ${item.slot.label}',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: AppTheme.goldAccent,
                    checkColor: Colors.black,
                    onChanged: canSelect
                        ? (val) {
                            setState(() {
                              if (val == true) {
                                if (_selectedTransmuteItemIds.length < 3) {
                                  _selectedTransmuteItemIds.add(item.id);
                                }
                              } else {
                                _selectedTransmuteItemIds.remove(item.id);
                              }
                            });
                          }
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _autoSelectLowestTrash(List<Equipment> items) {
    if (items.isEmpty) return;
    // Sort items by rarity index ascending
    final sorted = List<Equipment>.from(items)..sort((a, b) => a.rarity.index.compareTo(b.rarity.index));

    // Find the first rarity that has at least 3 items
    for (final rarity in [EquipmentRarity.common, EquipmentRarity.uncommon, EquipmentRarity.rare, EquipmentRarity.epic]) {
      final matching = sorted.where((e) => e.rarity == rarity).take(3).toList();
      if (matching.length == 3) {
        setState(() {
          _selectedTransmuteItemIds.clear();
          _selectedTransmuteItemIds.addAll(matching.map((e) => e.id));
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Không đủ 3 món cùng phẩm cấp trong kho để tự động chọn!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
