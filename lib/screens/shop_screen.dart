import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asset_mapping.dart';
import '../data/seed_equipment.dart';
import '../models/equipment.dart';
import '../models/stats.dart';
import '../providers/game_providers.dart';

class GemPack {
  final int count;
  final int price;
  final String title;
  final String description;
  const GemPack({
    required this.count,
    required this.price,
    required this.title,
    required this.description,
  });
}

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Random _rng = Random();

  List<Equipment> _weaponShop = [];
  List<Equipment> _armorShop = [];
  List<Equipment> _accessoryShop = [];
  static DateTime? _lastRefreshTime;

  final List<GemPack> _gemPacks = const [
    GemPack(
      count: 1,
      price: 100,
      title: '1x Đá Quý Cường Hóa',
      description: 'Dùng để nâng cấp chỉ số trang bị lên cấp cao hơn.',
    ),
    GemPack(
      count: 3,
      price: 280,
      title: '3x Túi Đá Quý',
      description: 'Gói ưu đãi tiết kiệm 20 vàng cho thợ rèn.',
    ),
    GemPack(
      count: 5,
      price: 450,
      title: '5x Hòm Đá Quý',
      description: 'Lượng lớn tinh thể cường hóa trang bị sử thi.',
    ),
    GemPack(
      count: 10,
      price: 850,
      title: '10x Rương Đá Quý',
      description: 'Rương đầy ắp đá quý ma pháp cao cấp.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkOrRefreshShop();
  }

  void _checkOrRefreshShop({bool force = false}) {
    final now = DateTime.now();
    if (force ||
        _lastRefreshTime == null ||
        now.difference(_lastRefreshTime!).inMinutes >= 30 ||
        _weaponShop.isEmpty) {
      _lastRefreshTime = now;
      final player = ref.read(playerProvider);
      setState(() {
        _weaponShop = _generateCategoryItems(EquipmentSlot.weapon, player.level);
        _armorShop = _generateCategoryItems(EquipmentSlot.armor, player.level);
        _accessoryShop = _generateCategoryItems(EquipmentSlot.accessory, player.level);
      });
    }
  }

  List<Equipment> _generateCategoryItems(EquipmentSlot slot, int playerLevel) {
    List<Equipment> list = [];
    for (int i = 0; i < 6; i++) {
      EquipmentRarity rarity = EquipmentRarity.common;
      double roll = _rng.nextDouble();

      if (playerLevel >= 21) {
        if (roll < 0.20) {
          rarity = EquipmentRarity.epic;
        } else if (roll < 0.55) {
          rarity = EquipmentRarity.rare;
        } else {
          rarity = EquipmentRarity.uncommon;
        }
      } else if (playerLevel >= 11) {
        if (roll < 0.40) {
          rarity = EquipmentRarity.rare;
        } else if (roll < 0.80) {
          rarity = EquipmentRarity.uncommon;
        } else {
          rarity = EquipmentRarity.common;
        }
      } else {
        // Level 5 - 10: Chỉ Common / Uncommon
        rarity = (roll < 0.50) ? EquipmentRarity.uncommon : EquipmentRarity.common;
      }

      // Pick predefined matching slot & rarity if available
      final matching = SeedEquipment.allPredefinedEquipment
          .where((e) => e.slot == slot && e.rarity == rarity)
          .toList();

      if (matching.isNotEmpty && _rng.nextBool()) {
        final base = matching[_rng.nextInt(matching.length)];
        list.add(Equipment(
          id: 'shop_${base.id}_${DateTime.now().microsecondsSinceEpoch}_$i',
          name: base.name,
          description: base.description,
          slot: base.slot,
          rarity: base.rarity,
          flatAtk: base.flatAtk,
          flatDef: base.flatDef,
          flatHp: base.flatHp,
          critRate: base.critRate,
          fireDmgPercent: base.fireDmgPercent,
          manaRegen: base.manaRegen,
          bonusStats: base.bonusStats,
          iconAsset: base.iconAsset,
          emoji: base.emoji,
          sellPrice: base.sellPrice,
        ));
      } else {
        list.add(_generateProceduralItem(slot, rarity, playerLevel, i));
      }
    }
    return list;
  }

  Equipment _generateProceduralItem(
      EquipmentSlot slot, EquipmentRarity rarity, int level, int index) {
    final multiplier = 1.0 + (level * 0.08) + (rarity.index * 1.2);
    String name = '';
    String emoji = '🛡️';
    int flatAtk = 0;
    int flatDef = 0;
    int flatHp = 0;
    double fireDmg = 0.0;
    double crit = 0.0;
    Stats stats = const Stats(str: 0, int_: 0, vit: 0, agi: 0, luk: 0);

    if (slot == EquipmentSlot.weapon) {
      emoji = '⚔️';
      name = '${rarity.label} Trượng Thép #$index';
      flatAtk = (14 * multiplier).round();
      crit = (0.02 * rarity.index).clamp(0.0, 0.15);
      if (rarity.index >= 3) fireDmg = 0.10 + (rarity.index * 0.05);
      stats = Stats(int_: (2 * multiplier).round(), luk: rarity.index);
    } else if (slot == EquipmentSlot.armor) {
      emoji = '🛡️';
      name = '${rarity.label} Giáp Vệ Quốc #$index';
      flatHp = (50 * multiplier).round();
      flatDef = (5 * multiplier).round();
      stats = Stats(vit: (2 * multiplier).round(), agi: 1);
    } else {
      emoji = '💍';
      name = '${rarity.label} Nhẫn Bí Thuật #$index';
      crit = (0.02 * rarity.index).clamp(0.0, 0.12);
      if (rarity.index >= 2) fireDmg = 0.08 + (rarity.index * 0.04);
      stats = Stats(int_: (2 * multiplier).round(), luk: (2 * rarity.index));
    }

    final price = (35 * multiplier).round();

    return Equipment(
      id: 'shop_gen_${DateTime.now().microsecondsSinceEpoch}_$index',
      name: name,
      description: 'Trang bị thương gia rèn bán tại khu chợ thị trấn.',
      slot: slot,
      rarity: rarity,
      flatAtk: flatAtk,
      flatDef: flatDef,
      flatHp: flatHp,
      critRate: crit,
      fireDmgPercent: fireDmg,
      bonusStats: stats,
      emoji: emoji,
      sellPrice: price,
    );
  }

  int _calculateBuyPrice(Equipment item, int playerLevel) {
    // Giá = base price * rarity multiplier * (1 + level * 0.05)
    double rarityFactor = 1.0 + (item.rarity.index * 0.8);
    double levelFactor = 1.0 + (playerLevel * 0.05);
    return max(40, (item.sellPrice * 2.2 * rarityFactor * levelFactor).round());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161520),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏪 ', style: TextStyle(fontSize: 18)),
            Text(
              'CỬA HÀNG TRANG BỊ & NGUYÊN LIỆU',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        actions: [
          // Refresh Button (Costs 50 gold)
          TextButton.icon(
            onPressed: () {
              if (player.gold >= 50) {
                ref.read(playerProvider.notifier).buyGems(0, 50); // deduct 50 gold
                _checkOrRefreshShop(force: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã làm mới Cửa Hàng (-50 🪙)!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không đủ 50 Vàng để làm mới hàng!')),
                );
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.amberAccent, size: 18),
            label: const Text('Làm mới (50🪙)', style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'VŨ KHÍ ⚔️'),
            Tab(text: 'GIÁP 🛡️'),
            Tab(text: 'PHỤ KIỆN 💍'),
            Tab(text: 'ĐÁ QUÝ 💎'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Currency Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${player.gold} Vàng',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('💎 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${player.gems} Đá Quý',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tự làm mới mỗi 30p',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEquipmentGrid(_weaponShop, player),
                _buildEquipmentGrid(_armorShop, player),
                _buildEquipmentGrid(_accessoryShop, player),
                _buildGemsTab(player),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid(List<Equipment> items, player) {
    if (items.isEmpty) {
      return const Center(child: Text('Đang làm mới hàng...'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final buyPrice = _calculateBuyPrice(item, player.level);
        final canAfford = player.gold >= buyPrice;

        // Stat comparison with currently equipped in that slot
        Equipment? equippedInSlot;
        if (item.slot == EquipmentSlot.weapon) equippedInSlot = player.equippedWeapon;
        if (item.slot == EquipmentSlot.armor) equippedInSlot = player.equippedArmor;
        if (item.slot == EquipmentSlot.accessory) equippedInSlot = player.equippedAccessory;

        int statDiff = 0;
        String compareLabel = '';
        if (equippedInSlot != null) {
          if (item.slot == EquipmentSlot.weapon) {
            statDiff = item.flatAtk - equippedInSlot.flatAtk;
            compareLabel = statDiff > 0 ? '▲ +$statDiff ATK' : (statDiff < 0 ? '▼ $statDiff ATK' : '= ATK');
          } else if (item.slot == EquipmentSlot.armor) {
            statDiff = item.flatDef - equippedInSlot.flatDef;
            compareLabel = statDiff > 0 ? '▲ +$statDiff DEF' : (statDiff < 0 ? '▼ $statDiff DEF' : '= DEF');
          } else {
            statDiff = (item.fireDmgPercent * 100 - equippedInSlot.fireDmgPercent * 100).round();
            compareLabel = statDiff > 0 ? '▲ +$statDiff% Lửa' : (statDiff < 0 ? '▼ $statDiff% Lửa' : '=');
          }
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.rarity.color.withOpacity(0.7), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Rarity Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: item.rarity.color.withOpacity(0.5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: AssetMapping.safeImage(
                        item.iconAsset,
                        width: 44,
                        height: 44,
                        fallbackEmoji: item.emoji,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.rarity.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.rarity.label,
                      style: TextStyle(
                        color: item.rarity.color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Name
              Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: item.rarity.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.flatAtk > 0)
                      Text('⚔️ +${item.flatAtk} ATK', style: const TextStyle(fontSize: 10, color: Colors.orangeAccent)),
                    if (item.flatDef > 0)
                      Text('🛡️ +${item.flatDef} DEF', style: const TextStyle(fontSize: 10, color: Colors.lightBlueAccent)),
                    if (item.flatHp > 0)
                      Text('❤️ +${item.flatHp} HP', style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
                    if (item.fireDmgPercent > 0)
                      Text('🔥 +${(item.fireDmgPercent * 100).round()}% Lửa', style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
                    if (compareLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        compareLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: statDiff > 0 ? Colors.greenAccent : (statDiff < 0 ? Colors.redAccent : Colors.white60),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Buy Button
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          final success = ref.read(playerProvider.notifier).buyShopItem(item, buyPrice);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã mua [${item.name}]! Đã chuyển vào Kho đồ.')),
                            );
                            setState(() {
                              items.removeAt(index);
                            });
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? Colors.amber.shade700 : Colors.grey.shade800,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    canAfford ? 'Mua ($buyPrice🪙)' : 'Thiếu ${buyPrice - player.gold}🪙',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.black : Colors.white38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGemsTab(player) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _gemPacks.length,
      itemBuilder: (context, index) {
        final pack = _gemPacks[index];
        final canAfford = player.gold >= pack.price;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.cyan.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyanAccent),
                ),
                child: const Text('💎', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.description,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        final ok = ref.read(playerProvider.notifier).buyGems(pack.count, pack.price);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã mua thành công +${pack.count} Đá Quý!')),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? Colors.cyan.shade700 : Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: Text(
                  canAfford ? '${pack.price} 🪙' : 'Thiếu Vàng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
