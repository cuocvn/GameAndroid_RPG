import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_equipment.dart';
import '../models/player.dart';

class SaveService {
  static const String _saveKey = 'player_offline_save_v1';
  static Box? _box;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox('game_save');
    } catch (e) {
      // SharedPreferences acts as fallback
    }
  }

  /// Saves player state to Hive and SharedPreferences
  static Future<void> savePlayer(Player player) async {
    final jsonStr = jsonEncode(player.toJson());
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.put(_saveKey, jsonStr);
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_saveKey, jsonStr);
    } catch (_) {}
  }

  /// Loads player state, or creates fresh beginner player with starter kit
  static Future<Player> loadPlayer() async {
    String? rawData;
    try {
      if (_box != null && _box!.isOpen) {
        rawData = _box!.get(_saveKey) as String?;
      }
    } catch (_) {}

    if (rawData == null || rawData.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        rawData = prefs.getString(_saveKey);
      } catch (_) {}
    }

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(rawData);
        return Player.fromJson(jsonMap);
      } catch (_) {}
    }

    // Default starter player with humble starter gear (no free legendaries in bag)
    final starterWeapon = SeedEquipment.getById('wooden_staff');
    final starterArmor = SeedEquipment.getById('cloth_armor');
    final starterRing = SeedEquipment.getById('apprentice_ring');

    return Player(
      equippedWeapon: starterWeapon,
      equippedArmor: starterArmor,
      equippedAccessory: starterRing,
      inventory: const [], // Túi đồ khởi đầu trống, người chơi phải chiến đấu và cày cuốc
      gold: 50,
      gems: 3,
      statPoints: 2, // 2 điểm cộng khởi đầu
      skillPoints: 1,
    );
  }

  /// Resets game progress to fresh state
  static Future<void> clearSave() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.delete(_saveKey);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
    } catch (_) {}
  }
}
