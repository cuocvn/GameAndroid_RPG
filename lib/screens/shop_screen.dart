import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asset_mapping.dart';
import '../data/seed_equipment.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/stats.dart';
import '../providers/game_providers.dart';
import '../theme/app_theme.dart';

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

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
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
        if (roll < 0.12) {
          rarity = EquipmentRarity.epic;
        } else if (roll < 0.40) {
          rarity = EquipmentRarity.rare;
        } else if (roll < 0.75) {
          rarity = EquipmentRarity.uncommon;
        } else {
          rarity = EquipmentRarity.common;
        }
      } else if (playerLevel >= 5) {
        if (roll < 0.25) {
          rarity = EquipmentRarity.rare;
        } else if (roll < 0.65) {
          rarity = EquipmentRarity.uncommon;
        } else {
          rarity = EquipmentRarity.common;
        }
      }

      final item = _createRandomShopItem(slot, rarity, i, playerLevel);
      list.add(item);
    }
    return list;
  }

  Equipment _createRandomShopItem(
      EquipmentSlot slot, EquipmentRarity rarity, int index, int playerLevel) {
    final matchingPredefined = SeedEquipment.allPredefinedEquipment
        .where((e) => e.slot == slot && e.rarity == rarity)
        .toList();

    if (matchingPredefined.isNotEmpty) {
      return matchingPredefined[_rng.nextInt(matchingPredefined.length)];
    }

    final id = 'shop_${slot.name}_${rarity.name}_$index';
    int baseAtk = 0;
    int baseDef = 0;
    int baseHp = 0;
    String name = '';
    String emoji = '🗡️';

    final mult = 1.0 + (rarity.index * 0.4);

    switch (slot) {
      case EquipmentSlot.weapon:
        baseAtk = (12 * mult + (playerLevel * 1.5)).round();
        emoji = '⚔️';
        name = '${rarity.label} Trảm Kiếm';
        break;
      case EquipmentSlot.armor:
        baseDef = (6 * mult + (playerLevel * 0.8)).round();
        baseHp = (60 * mult + (playerLevel * 10)).round();
        emoji = '🛡️';
        name = '${rarity.label} Giáp Hộ Mệnh';
        break;
      case EquipmentSlot.accessory:
        baseHp = (40 * mult).round();
        emoji = '💍';
        name = '${rarity.label} Linh Thạch Nhẫn';
        break;
    }

    return Equipment(
      id: id,
      name: name,
      description: 'Trang bị bày bán tại Cửa Hàng thương hội.',
      slot: slot,
      rarity: rarity,
      flatAtk: baseAtk,
      flatDef: baseDef,
      flatHp: baseHp,
      bonusStats: Stats(
        str: slot == EquipmentSlot.weapon ? (2 * (rarity.index + 1)) : 0,
        int_: slot == EquipmentSlot.accessory ? (2 * (rarity.index + 1)) : 0,
        vit: slot == EquipmentSlot.armor ? (3 * (rarity.index + 1)) : 0,
        agi: 1,
        luk: 1,
      ),
      emoji: emoji,
      sellPrice: (30 * mult * (1 + playerLevel * 0.05)).round(),
    );
  }

  int _calculateBuyPrice(Equipment item, int playerLevel) {
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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Text(
          '🏪 CỬA HÀNG TRANG BỊ & NGUYÊN LIỆU',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
            color: AppTheme.goldAccent,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (player.gold >= 50) {
                HapticFeedback.mediumImpact();
                ref.read(playerProvider.notifier).buyGems(0, 50);
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
            icon: const Icon(Icons.refresh, color: AppTheme.goldAccent, size: 16),
            label: Text(
              'Làm mới (50🪙)',
              style: GoogleFonts.inter(color: AppTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.goldButtonGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
              tabs: const [
                Tab(text: 'VŨ KHÍ ⚔️'),
                Tab(text: 'GIÁP 🛡️'),
                Tab(text: 'PHỤ KIỆN 💍'),
                Tab(text: 'ĐÁ QUÝ 💎'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Currency Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${player.gold} Vàng',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('💎 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${player.gems} Đá Quý',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tự làm mới mỗi 30p',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
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

  Widget _buildEquipmentGrid(List<Equipment> items, Player player) {
    if (items.isEmpty) {
      return const Center(child: Text('Đang làm mới hàng...'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final buyPrice = _calculateBuyPrice(item, player.level);
        final canAfford = player.gold >= buyPrice;
        final rarityColor = AppTheme.getRarityColor(item.rarity);

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
            statDiff = item.flatHp - equippedInSlot.flatHp;
            compareLabel = statDiff > 0 ? '▲ +$statDiff HP' : (statDiff < 0 ? '▼ $statDiff HP' : '= HP');
          }
        }

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: rarityColor.withOpacity(0.55), width: 1.2),
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
              // Icon container with rarity glow
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0C18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: rarityColor, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AssetMapping.safeImage(
                      item.iconAsset,
                      width: 58,
                      height: 58,
                      fallbackEmoji: item.emoji,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                item.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                item.rarity.label,
                style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Stat compare badge
              if (compareLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: statDiff > 0
                        ? AppTheme.greenAccent.withOpacity(0.15)
                        : (statDiff < 0 ? AppTheme.redAccent.withOpacity(0.15) : Colors.white10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    compareLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statDiff > 0
                          ? AppTheme.greenAccent
                          : (statDiff < 0 ? AppTheme.redAccent : Colors.white70),
                    ),
                  ),
                ),

              const Spacer(),

              // Buy CTA Button
              SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          HapticFeedback.lightImpact();
                          final success = ref.read(playerProvider.notifier).buyShopItem(item, buyPrice);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('⚡ Đã mua thành công [${item.name}]!')),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪙 ', style: TextStyle(fontSize: 11)),
                      Text(
                        '$buyPrice',
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGemsTab(Player player) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _gemPacks.length,
      itemBuilder: (context, index) {
        final pack = _gemPacks[index];
        final canAfford = player.gold >= pack.price;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.surfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.blueAccent.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.blueAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.blueAccent.withOpacity(0.6)),
                ),
                child: const Text('💎', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.description,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        HapticFeedback.lightImpact();
                        final success = ref.read(playerProvider.notifier).buyGems(pack.count, pack.price);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('⚡ Đã mua thành công +${pack.count} Đá Quý!')),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  '${pack.price} 🪙',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
