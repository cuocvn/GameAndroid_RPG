import 'equipment.dart';

class OfflineProgressResult {
  final int offlineSeconds;
  final int battlesWon;
  final int expGained;
  final int goldGained;
  final int gemsGained;
  final int staminaRegenerated;
  final List<Equipment> droppedItems;
  final Map<String, int> droppedMaterials;
  final Map<String, int> droppedPetFoods;
  final String stageName;
  final bool hadAutoFarm;

  const OfflineProgressResult({
    required this.offlineSeconds,
    this.battlesWon = 0,
    this.expGained = 0,
    this.goldGained = 0,
    this.gemsGained = 0,
    this.staminaRegenerated = 0,
    this.droppedItems = const [],
    this.droppedMaterials = const {},
    this.droppedPetFoods = const {},
    required this.stageName,
    required this.hadAutoFarm,
  });

  String get formattedDuration {
    final hours = offlineSeconds ~/ 3600;
    final minutes = (offlineSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours giờ $minutes phút';
    }
    return '$minutes phút';
  }
}
