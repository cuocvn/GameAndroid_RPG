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
  double _enemyRegenAccumulator = 0.0;
  double _bannerTimer = 0.0;
  String? _activeBanner;

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
    if (enemy.magicResistPercent > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [Kháng Phép ${(enemy.magicResistPercent * 100).round()}%]!');
    }
    if (enemy.reflectDamagePercent > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [Phản Đòn ${(enemy.reflectDamagePercent * 100).round()}%]!');
    }
    if (enemy.hpRegenPercentPerSecond > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [Hồi Máu ${(enemy.hpRegenPercentPerSecond * 100).round()}%/giây]!');
    }

    _emitState(isFighting: true);
  }

  void start() {
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

    // 2. Banner timer for Active Skills (0.8s)
    if (_activeBanner != null) {
      _bannerTimer -= dt;
      if (_bannerTimer <= 0) {
        _activeBanner = null;
      }
    }

    // 3. Clean up old floating texts
    _floatingTexts.removeWhere(
        (t) => (DateTime.now().millisecondsSinceEpoch / 1000) - t.createdAt > 1.2);

    // 4. Mana Regeneration over time
    _manaRegenAccumulator += dt;
    if (_manaRegenAccumulator >= 0.5) {
      final manaGained =
          (player.manaRegenPerSecond * _manaRegenAccumulator).round();
      _heroMana = min(_heroMaxMana, _heroMana + manaGained);
      _manaRegenAccumulator = 0.0;
    }

    // 5. Burn Dot on Enemy
    if (enemy.burnTicksLeft > 0) {
      _burnTickAccumulator += dt;
      if (_burnTickAccumulator >= 1.0) {
        _burnTickAccumulator = 0.0;
        enemy.burnTicksLeft--;
        final burnDmg = enemy.burnDamagePerTick;
        enemy.currentHp = max(0, enemy.currentHp - burnDmg);
        _addFloatingText('$burnDmg ♨️', Colors.deepOrangeAccent,
            isHeroTarget: false);
        _addLog('${enemy.name} chịu $burnDmg sát thương thiêu đốt.');

        if (enemy.isDead) {
          _handleVictory();
          return;
        }
      }
    }

    // 6. Zone 5 Monster HP Regeneration (5%/second)
    if (enemy.hpRegenPercentPerSecond > 0 &&
        enemy.currentHp < enemy.maxHp &&
        !enemy.isDead) {
      _enemyRegenAccumulator += dt;
      if (_enemyRegenAccumulator >= 1.0) {
        _enemyRegenAccumulator = 0.0;
        final healVal =
            max(5, (enemy.maxHp * enemy.hpRegenPercentPerSecond).round());
        enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healVal);
        _addFloatingText('+$healVal 💚', Colors.greenAccent, isHeroTarget: false);
        _addLog('${enemy.name} kích hoạt Hồi Máu +$healVal HP.');
      }
    }

    // 7. Hero Action Loop
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

    // 8. Enemy Action Loop
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
        chosenSkill = skill;
      }
    }

    chosenSkill ??= SeedSkills.getById('fireball');

    // Handle Active Skill trigger & Banner
    if (chosenSkill.type == SkillType.active) {
      _heroMana = max(0, _heroMana - chosenSkill.manaCost);
      _cooldowns[chosenSkill.id] = chosenSkill.cooldown;
      _activeBanner = '${chosenSkill.emoji} ${chosenSkill.name.toUpperCase()}!';
      _bannerTimer = 0.8;
      _addLog('Bạn kích hoạt ${chosenSkill.name} (${chosenSkill.emoji})!');
    }

    // Defensive / Shield skill
    if (chosenSkill.grantsShield) {
      final shieldVal = (_heroMaxHp * 0.30).round();
      _heroShield = shieldVal;
      _addFloatingText('+$shieldVal Giáp 🛡️', Colors.cyanAccent, isHeroTarget: true);
      _addLog('Tạo khiên bảo vệ hấp thụ $shieldVal sát thương.');
      return;
    }

    // Healing skill
    if (chosenSkill.healsHero) {
      final healVal = (_heroMaxHp * 0.35).round();
      _heroHp = min(_heroMaxHp, _heroHp + healVal);
      _addFloatingText('+$healVal HP 💚', Colors.greenAccent, isHeroTarget: true);
      _addLog('Bạn hồi phục $healVal HP bằng ${chosenSkill.name}.');
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

    // Zone 3: Magic Resistance (Kháng phép 40%)
    if (enemy.magicResistPercent > 0 &&
        chosenSkill.element != SkillElement.physical) {
      rawDamage *= (1.0 - enemy.magicResistPercent);
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

    // Floating text: Show skill name on basic attack or active
    String dmgText = '$netDamage';
    if (isCrit) {
      dmgText = 'CRIT! $netDamage 💥';
    } else if (chosenSkill.type == SkillType.basic) {
      dmgText = '${chosenSkill.name}\n$netDamage';
    }

    _addFloatingText(
      dmgText,
      isCrit
          ? Colors.amberAccent
          : (chosenSkill.element == SkillElement.fire
              ? Colors.orangeAccent
              : (chosenSkill.element == SkillElement.ice
                  ? Colors.cyanAccent
                  : Colors.white)),
      isCrit: isCrit,
      isHeroTarget: false,
    );

    _addLog(
      '${player.name} dùng ${chosenSkill.name} gây $netDamage ${isCrit ? '(CHÍ MẠNG!)' : ''} lên ${enemy.name}.',
    );

    // Zone 4: Reflect Damage (Phản đòn 20%)
    if (enemy.reflectDamagePercent > 0 && netDamage > 0) {
      int reflectDmg = max(1, (netDamage * enemy.reflectDamagePercent).round());
      if (_heroShield > 0) {
        if (_heroShield >= reflectDmg) {
          _heroShield -= reflectDmg;
        } else {
          reflectDmg -= _heroShield;
          _heroShield = 0;
          _heroHp = max(0, _heroHp - reflectDmg);
        }
      } else {
        _heroHp = max(0, _heroHp - reflectDmg);
      }

      _addFloatingText('-$reflectDmg 🔄', Colors.purpleAccent, isHeroTarget: true);
      _addLog('${player.name} chịu $reflectDmg sát thương phản đòn từ ${enemy.name}!');

      if (_heroHp <= 0) {
        _handleDefeat();
        return;
      }
    }
  }

  void _executeEnemyAction() {
    // Check Dodge from player
    if (_rng.nextDouble() < player.dodgeRate) {
      _addFloatingText('NÉ!', Colors.grey, isHeroTarget: true);
      _addLog('${player.name} lanh lẹ né tránh đòn tấn công!');
      return;
    }

    double rawDmg = enemy.atk.toDouble();
    bool isSpecial = false;
    String attackName = 'Đòn Đánh';
    if (enemy.specialSkill != null && _rng.nextDouble() < 0.35) {
      isSpecial = true;
      rawDmg *= enemy.specialSkill!.damageMultiplier;
      attackName = enemy.specialSkill!.name;
      _addLog('${enemy.name} tung chiêu [$attackName]!');
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

    String enemyHitText = isSpecial ? '$attackName\n-$netDmg' : '-$netDmg';
    if (isCrit) enemyHitText = 'CRIT! -$netDmg 💥';

    _addFloatingText(
      enemyHitText,
      isCrit ? Colors.redAccent : Colors.red,
      isCrit: isCrit,
      isHeroTarget: true,
    );

    _addLog(
      '${enemy.name} dùng [$attackName] gây $netDmg sát thương ${isCrit ? '(CHÍ MẠNG!)' : ''}.',
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

  void _addFloatingText(String text, Color color,
      {bool isCrit = false, bool isHeroTarget = false}) {
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
      activeSkillCastName: _activeBanner,
    );
  }

  void _emitState({bool isFighting = true}) {
    onStateChanged(_currentState(isFighting: isFighting));
  }

  void _emitDirect(BattleState state) {
    onStateChanged(state);
  }
}
