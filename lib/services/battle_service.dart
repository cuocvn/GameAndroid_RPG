import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/seed_skills.dart';
import '../models/battle_state.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/player.dart';
import '../models/skill.dart';
import 'loot_service.dart';

class BattleService {
  final Player player;
  final Enemy enemy;
  final void Function(BattleState state) onStateChanged;
  final void Function(BattleState finalState) onBattleEnded;

  Timer? _timer;
  final Random _rng = Random();

  late int _heroHp;
  late int _heroMaxHp;
  late int _heroMana;
  late int _heroMaxMana;
  int _heroShield = 0;

  double _heroAttackTimer = 0.0;
  double _enemyAttackTimer = 0.0;
  double _manaRegenAccumulator = 0.0;
  double _burnTickAccumulator = 0.0;

  // Active skill cooldowns: skillId -> remaining seconds
  final Map<String, double> _cooldowns = {};

  final List<FloatingText> _floatingTexts = [];
  final List<String> _battleLog = [];
  bool _isFinished = false;

  BattleService({
    required this.player,
    required this.enemy,
    required this.onStateChanged,
    required this.onBattleEnded,
  }) {
    _heroMaxHp = player.maxHp;
    _heroHp = _heroMaxHp;
    _heroMaxMana = player.maxMana;
    _heroMana = 20; // Start battle with a little initial mana

    _addLog('Bắt đầu giao chiến với ${enemy.name}!');
    _emitState(isFighting: true);
  }

  void start() {
    // Battle tick every 100 milliseconds
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isFinished) {
        timer.cancel();
        return;
      }
      _update(0.10);
    });
  }

  void stop() {
    _isFinished = true;
    _timer?.cancel();
    _addLog('Bạn đã rút lui khỏi trận đấu.');
    final finalState = _currentState(isFighting: false);
    onBattleEnded(finalState);
  }

  void _update(double dt) {
    // 1. Update Cooldowns
    _cooldowns.forEach((key, val) {
      if (val > 0) {
        _cooldowns[key] = max(0.0, val - dt);
      }
    });

    // 2. Clean up old floating texts
    _floatingTexts.removeWhere((t) => (DateTime.now().millisecondsSinceEpoch / 1000) - t.createdAt > 1.2);

    // 3. Mana Regeneration over time
    _manaRegenAccumulator += dt;
    if (_manaRegenAccumulator >= 0.5) {
      final manaGained = (player.manaRegenPerSecond * _manaRegenAccumulator).round();
      _heroMana = min(_heroMaxMana, _heroMana + manaGained);
      _manaRegenAccumulator = 0.0;
    }

    // 4. Burn Dot on Enemy
    if (enemy.burnTicksLeft > 0) {
      _burnTickAccumulator += dt;
      if (_burnTickAccumulator >= 1.0) {
        _burnTickAccumulator = 0.0;
        enemy.burnTicksLeft--;
        final burnDmg = enemy.burnDamagePerTick;
        enemy.currentHp = max(0, enemy.currentHp - burnDmg);
        _addFloatingText('$burnDmg ♨️', Colors.deepOrangeAccent, isHeroTarget: false);
        _addLog('${enemy.name} chịu $burnDmg sát thương thiêu đốt.');

        if (enemy.isDead) {
          _handleVictory();
          return;
        }
      }
    }

    // 5. Hero Action Loop
    _heroAttackTimer += dt;
    final heroInterval = player.attackInterval;
    if (_heroAttackTimer >= heroInterval) {
      _heroAttackTimer = 0.0;
      _executeHeroAction();
      if (enemy.isDead) {
        _handleVictory();
        return;
      }
    }

    // 6. Enemy Action Loop
    _enemyAttackTimer += dt;
    final enemyInterval = enemy.attackInterval;
    if (_enemyAttackTimer >= enemyInterval) {
      _enemyAttackTimer = 0.0;
      _executeEnemyAction();
      if (_heroHp <= 0) {
        _handleDefeat();
        return;
      }
    }

    _emitState(isFighting: true);
  }

  void _executeHeroAction() {
    // Determine skill to cast:
    // Check equipped skills in order of priority:
    Skill? chosenSkill;

    for (final skillId in player.equippedSkillIds) {
      final skill = SeedSkills.getById(skillId);
      final cd = _cooldowns[skillId] ?? 0.0;

      if (skill.type == SkillType.active) {
        if (_heroMana >= skill.manaCost && cd <= 0.0) {
          chosenSkill = skill;
          break;
        }
      } else if (skill.type == SkillType.basic && chosenSkill == null) {
        // Fallback basic skill
        chosenSkill = skill;
      }
    }

    // Fallback if none picked
    chosenSkill ??= SeedSkills.getById('fireball');

    // Deduct mana & set cooldown if active
    if (chosenSkill.type == SkillType.active) {
      _heroMana = max(0, _heroMana - chosenSkill.manaCost);
      _cooldowns[chosenSkill.id] = chosenSkill.cooldown;
      _addLog('Bạn kích hoạt ${chosenSkill.name} (${chosenSkill.emoji})!');
    }

    // Handle defensive / shield skills
    if (chosenSkill.grantsShield) {
      final shieldVal = (_heroMaxHp * 0.30).round();
      _heroShield = shieldVal;
      _addFloatingText('+$shieldVal Giáp 🛡️', Colors.cyanAccent, isHeroTarget: true);
      _addLog('Tạo khiên bảo vệ hấp thụ $shieldVal sát thương.');
      return;
    }

    // Check Dodge
    if (_rng.nextDouble() < enemy.dodgeRate) {
      _addFloatingText('NÉ!', Colors.grey, isHeroTarget: false);
      _addLog('${enemy.name} đã né tránh đòn đánh!');
      return;
    }

    // Calculate Base Damage
    double rawAtk = (chosenSkill.element == SkillElement.physical)
        ? player.physicalAtk
        : player.magicAtk;

    double multiplier = chosenSkill.currentMultiplier;
    double rawDamage = rawAtk * multiplier;

    // Elemental Fire Synergy
    if (chosenSkill.element == SkillElement.fire) {
      rawDamage *= (1.0 + player.fireDamageBonusPercent);
    }

    // Combo Synergy: Target is burning + Flame Ignite passive
    if (enemy.burnTicksLeft > 0) {
      rawDamage *= (1.0 + player.burnTargetBonusPercent);
    }

    // Crit calculation
    double critChance = player.critRate + chosenSkill.critRateBonus;
    bool isCrit = _rng.nextDouble() < critChance;
    if (isCrit) {
      rawDamage *= player.critDamageMultiplier;
    }

    // Defense mitigation
    int netDamage = max(1, (rawDamage - enemy.def).round());
    enemy.currentHp = max(0, enemy.currentHp - netDamage);

    // Apply Burn status effect if skill causes burn
    if (chosenSkill.causesBurn) {
      enemy.burnTicksLeft = 3;
      enemy.burnDamagePerTick = max(10, (player.magicAtk * 0.25).round());
      _addLog('${enemy.name} bị thiêu đốt!');
    }

    // Display floating damage
    _addFloatingText(
      '$netDamage${isCrit ? ' 💥' : ''}',
      isCrit ? Colors.amberAccent : Colors.orangeAccent,
      isCrit: isCrit,
      isHeroTarget: false,
    );

    _addLog(
      '${player.name} dùng ${chosenSkill.name} gây $netDamage ${isCrit ? '(CHÍ MẠNG!)' : ''} lên ${enemy.name}.',
    );
  }

  void _executeEnemyAction() {
    // Check Dodge from player
    if (_rng.nextDouble() < player.dodgeRate) {
      _addFloatingText('NÉ!', Colors.grey, isHeroTarget: true);
      _addLog('${player.name} lanh lẹ né tránh đòn tấn công!');
      return;
    }

    // Enemy attack damage
    double rawDmg = enemy.atk.toDouble();
    bool isSpecial = false;
    if (enemy.specialSkill != null && _rng.nextDouble() < 0.35) {
      isSpecial = true;
      rawDmg *= enemy.specialSkill!.damageMultiplier;
      _addLog('${enemy.name} tung chiêu [${enemy.specialSkill!.name}]!');
    }

    bool isCrit = _rng.nextDouble() < enemy.critRate;
    if (isCrit) {
      rawDmg *= 1.5;
    }

    int netDmg = max(1, (rawDmg - player.physicalDef).round());

    // Shield absorb
    if (_heroShield > 0) {
      if (_heroShield >= netDmg) {
        _heroShield -= netDmg;
        _addFloatingText('-$netDmg Giáp 🛡️', Colors.cyanAccent, isHeroTarget: true);
        return;
      } else {
        netDmg -= _heroShield;
        _heroShield = 0;
      }
    }

    _heroHp = max(0, _heroHp - netDmg);

    _addFloatingText(
      '-$netDmg${isCrit ? ' 💥' : ''}',
      isCrit ? Colors.redAccent : Colors.red,
      isCrit: isCrit,
      isHeroTarget: true,
    );

    _addLog(
      '${enemy.name} tấn công gây $netDmg sát thương ${isCrit ? '(CHÍ MẠNG!)' : ''}.',
    );
  }

  void _handleVictory() {
    _isFinished = true;
    _timer?.cancel();

    final drops = LootService.rollLoot(enemy: enemy, player: player);
    _addLog('CHIẾN THẮNG! Nhận ${enemy.expReward} EXP và ${enemy.goldReward} Vàng!');

    if (drops.isNotEmpty) {
      for (var item in drops) {
        _addLog('🎁 Rơi trang bị: [${item.name}] (${item.rarity.label})!');
      }
    }

    final finalState = _currentState(
      isFighting: false,
      isWon: true,
      earnedExp: enemy.expReward,
      earnedGold: enemy.goldReward,
      droppedEquipment: drops,
    );

    _emitDirect(finalState);
    onBattleEnded(finalState);
  }

  void _handleDefeat() {
    _isFinished = true;
    _timer?.cancel();
    _addLog('THẤT BẠI! Bạn đã gục ngã trước ${enemy.name}...');

    final finalState = _currentState(
      isFighting: false,
      isDefeated: true,
    );

    _emitDirect(finalState);
    onBattleEnded(finalState);
  }

  void _addFloatingText(String text, Color color, {bool isCrit = false, bool isHeroTarget = false}) {
    _floatingTexts.add(FloatingText(
      id: '${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(1000)}',
      text: text,
      color: color,
      isCrit: isCrit,
      isHeroTarget: isHeroTarget,
      createdAt: DateTime.now().millisecondsSinceEpoch / 1000,
    ));
  }

  void _addLog(String msg) {
    _battleLog.insert(0, msg);
    if (_battleLog.length > 50) {
      _battleLog.removeLast();
    }
  }

  BattleState _currentState({
    bool isFighting = true,
    bool isWon = false,
    bool isDefeated = false,
    int earnedExp = 0,
    int earnedGold = 0,
    List<Equipment> droppedEquipment = const [],
  }) {
    return BattleState(
      heroHp: _heroHp,
      heroMaxHp: _heroMaxHp,
      heroMana: _heroMana,
      heroMaxMana: _heroMaxMana,
      heroShield: _heroShield,
      enemy: enemy,
      floatingTexts: List.from(_floatingTexts),
      battleLog: List.from(_battleLog),
      isFighting: isFighting,
      isWon: isWon,
      isDefeated: isDefeated,
      earnedExp: earnedExp,
      earnedGold: earnedGold,
      droppedEquipment: droppedEquipment,
    );
  }

  void _emitState({bool isFighting = true}) {
    onStateChanged(_currentState(isFighting: isFighting));
  }

  void _emitDirect(BattleState state) {
    onStateChanged(state);
  }
}
