import 'package:flutter/material.dart';
import 'enemy.dart';
import 'equipment.dart';

class FloatingText {
  final String id;
  final String text;
  final Color color;
  final bool isCrit;
  final bool isHeroTarget; // true if hero is taking damage, false if enemy
  final double createdAt;

  FloatingText({
    required this.id,
    required this.text,
    required this.color,
    this.isCrit = false,
    this.isHeroTarget = false,
    required this.createdAt,
  });
}

class BattleState {
  final int heroHp;
  final int heroMaxHp;
  final int heroMana;
  final int heroMaxMana;
  final int heroShield;
  final Enemy enemy;
  final List<FloatingText> floatingTexts;
  final List<String> battleLog;
  final bool isFighting;
  final bool isWon;
  final bool isDefeated;
  final int earnedExp;
  final int earnedGold;
  final List<Equipment> droppedEquipment;
  final String? activeSkillCastName;
  final double battleDuration;
  final bool triggeredSpeedrunBonus;
  final int totalDamageDealt;
  final int totalDamageTaken;
  final int totalHealed;
  final int highestCritDamage;
  final double battleSpeed;

  const BattleState({
    required this.heroHp,
    required this.heroMaxHp,
    required this.heroMana,
    required this.heroMaxMana,
    this.heroShield = 0,
    required this.enemy,
    this.floatingTexts = const [],
    this.battleLog = const [],
    this.isFighting = false,
    this.isWon = false,
    this.isDefeated = false,
    this.earnedExp = 0,
    this.earnedGold = 0,
    this.droppedEquipment = const [],
    this.activeSkillCastName,
    this.battleDuration = 0.0,
    this.triggeredSpeedrunBonus = false,
    this.totalDamageDealt = 0,
    this.totalDamageTaken = 0,
    this.totalHealed = 0,
    this.highestCritDamage = 0,
    this.battleSpeed = 1.0,
  });

  double get dps => battleDuration > 0
      ? (totalDamageDealt / battleDuration)
      : totalDamageDealt.toDouble();

  BattleState copyWith({
    int? heroHp,
    int? heroMaxHp,
    int? heroMana,
    int? heroMaxMana,
    int? heroShield,
    Enemy? enemy,
    List<FloatingText>? floatingTexts,
    List<String>? battleLog,
    bool? isFighting,
    bool? isWon,
    bool? isDefeated,
    int? earnedExp,
    int? earnedGold,
    List<Equipment>? droppedEquipment,
    String? activeSkillCastName,
    double? battleDuration,
    bool? triggeredSpeedrunBonus,
    int? totalDamageDealt,
    int? totalDamageTaken,
    int? totalHealed,
    int? highestCritDamage,
    double? battleSpeed,
    bool clearSkillCast = false,
  }) {
    return BattleState(
      heroHp: heroHp ?? this.heroHp,
      heroMaxHp: heroMaxHp ?? this.heroMaxHp,
      heroMana: heroMana ?? this.heroMana,
      heroMaxMana: heroMaxMana ?? this.heroMaxMana,
      heroShield: heroShield ?? this.heroShield,
      enemy: enemy ?? this.enemy,
      floatingTexts: floatingTexts ?? this.floatingTexts,
      battleLog: battleLog ?? this.battleLog,
      isFighting: isFighting ?? this.isFighting,
      isWon: isWon ?? this.isWon,
      isDefeated: isDefeated ?? this.isDefeated,
      earnedExp: earnedExp ?? this.earnedExp,
      earnedGold: earnedGold ?? this.earnedGold,
      droppedEquipment: droppedEquipment ?? this.droppedEquipment,
      activeSkillCastName: clearSkillCast
          ? null
          : (activeSkillCastName ?? this.activeSkillCastName),
      battleDuration: battleDuration ?? this.battleDuration,
      triggeredSpeedrunBonus: triggeredSpeedrunBonus ?? this.triggeredSpeedrunBonus,
      totalDamageDealt: totalDamageDealt ?? this.totalDamageDealt,
      totalDamageTaken: totalDamageTaken ?? this.totalDamageTaken,
      totalHealed: totalHealed ?? this.totalHealed,
      highestCritDamage: highestCritDamage ?? this.highestCritDamage,
      battleSpeed: battleSpeed ?? this.battleSpeed,
    );
  }
}
