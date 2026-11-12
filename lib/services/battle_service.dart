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
  late Enemy enemy;
  final double? maxDuration;
  final void Function(BattleState state) onStateChanged;
  final void Function(BattleState finalState) onBattleEnded;

  Timer? _timer;
  final Random _rng = Random();

  late int _heroHp;
  late int _heroMaxHp;
  late int _heroMana;
  late int _heroMaxMana;
  int _heroShield = 0;

  double _battleDuration = 0.0;
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
  bool _hasRevived = false;
  double _enemySlowTimer = 0.0;

  // Boss Skill & Telegraph State
  final Map<String, double> _bossSkillCooldowns = {};
  bool _isTelegraphing = false;
  double _telegraphTimer = 0.0;
  EnemySkill? _currentTelegraphSkill;

  // Hero Debuff Timers
  double _heroFreezeTimer = 0.0;
  double _heroDefDownTimer = 0.0;
  int _heroBurnTicks = 0;
  double _heroBurnAccumulator = 0.0;

  // Combat damage analytics breakdown
  final Map<String, int> _heroDamageBreakdown = {};
  final Map<String, int> _enemyDamageBreakdown = {};

  double battleSpeed = 1.0;
  int _totalDamageDealt = 0;
  int _totalDamageTaken = 0;
  int _totalHealed = 0;
  int _highestCrit = 0;

  void setBattleSpeed(double speed) {
    battleSpeed = speed;
  }

  BattleService({
    required this.player,
    required Enemy enemy,
    this.maxDuration,
    required this.onStateChanged,
    required this.onBattleEnded,
  }) {
    if (player.nextStageDifficultyBonus > 0) {
      this.enemy = enemy.clone(statMultiplier: 1.0 + player.nextStageDifficultyBonus);
    } else {
      this.enemy = enemy;
    }

    _heroMaxHp = player.maxHp;
    _heroHp = _heroMaxHp;
    _heroMaxMana = player.maxMana;
    _heroMana = 20; // Start battle with some initial mana

    _addLog('Bắt đầu giao chiến với ${this.enemy.name}!');
    if (player.nextStageDifficultyBonus > 0) {
      _addLog('⚡ Áp dụng độ khó +${(player.nextStageDifficultyBonus * 100).round()}% do vượt ải thần tốc!');
    }
    if (this.enemy.magicResistPercent > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [🛡️ Kháng Phép ${(this.enemy.magicResistPercent * 100).round()}%]!');
    }
    if (this.enemy.reflectDamagePercent > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [⚡ Phản Đòn ${(this.enemy.reflectDamagePercent * 100).round()}%]!');
    }
    if (this.enemy.hpRegenPercentPerSecond > 0) {
      _addLog('⚠️ Kẻ địch có nội tại [💚 Hồi Máu ${(this.enemy.hpRegenPercentPerSecond * 100).round()}%/giây]!');
    }

    if (this.enemy.isBoss && this.enemy.bossSkills.isNotEmpty) {
      for (int i = 0; i < this.enemy.bossSkills.length; i++) {
        final skill = this.enemy.bossSkills[i];
        _bossSkillCooldowns[skill.id] = 4.0 + (i * 5.0);
      }
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
      _update(0.10 * battleSpeed);
    });
  }

  void stop() {
    _isFinished = true;
    _timer?.cancel();
    _addLog('Bạn đã rút lui khỏi trận đấu.');
    final finalState = _currentState(isFighting: false);
    onBattleEnded(finalState);
  }

  /// Helper for automated fast balance testing / headless simulation
  void simulateTick(double dt) {
    if (_isFinished) return;
    _update(dt);
  }

  void _update(double dt) {
    _battleDuration += dt;

    if (maxDuration != null && _battleDuration >= maxDuration! && !_isFinished) {
      _isFinished = true;
      _timer?.cancel();
      _addLog('Hết thời gian khiêu chiến (${maxDuration!.round()}s)!');
      final finalState = _currentState(
        isFighting: false,
        isDefeated: enemy.currentHp > 0,
        isWon: enemy.currentHp <= 0,
        battleDuration: _battleDuration,
      );
      _emitDirect(finalState);
      onBattleEnded(finalState);
      return;
    }

    // 1. Update Cooldowns
    _cooldowns.forEach((key, val) {
      if (val > 0) {
        _cooldowns[key] = max(0.0, val - dt);
      }
    });

    // 2. Banner timer for Active Skills (0.8s - 1.2s)
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

    // 5. Boss Vùng 5 (Diablo) Cuồng Nộ dưới 30% HP
    if (!enemy.isEnraged &&
        (enemy.id.contains('z5_boss') || enemy.name.toUpperCase().contains('DIABLO')) &&
        enemy.currentHp <= (enemy.maxHp * 0.30) &&
        !enemy.isDead) {
      enemy.isEnraged = true;
      _activeBanner = '🔥 DIABLO NỔI GIẬN!';
      _bannerTimer = 1.2;
      _addFloatingText('🔥 CUỒNG NỘ!', Colors.deepOrangeAccent, isHeroTarget: false);
      _addLog('🔥 DIABLO BẮT ĐẦU CUỒNG NỘ! Tăng 50% Công và 30% Tốc đánh!');
    }

    // 6. Burn Dot on Enemy
    if (enemy.burnTicksLeft > 0) {
      _burnTickAccumulator += dt;
      if (_burnTickAccumulator >= 1.0) {
        _burnTickAccumulator = 0.0;
        enemy.burnTicksLeft--;
        final burnDmg = enemy.burnDamagePerTick;
        enemy.currentHp = max(0, enemy.currentHp - burnDmg);
        _totalDamageDealt += burnDmg;
        _addFloatingText('$burnDmg ♨️', Colors.deepOrangeAccent,
            isHeroTarget: false);
        _addLog('${enemy.name} chịu $burnDmg sát thương thiêu đốt.');

        if (enemy.isDead) {
          _handleVictory();
          return;
        }
      }
    }

    // 7. Zone 5 Monster HP Regeneration (5%/second)
    if (enemy.hpRegenPercentPerSecond > 0 &&
        enemy.currentHp < enemy.maxHp &&
        !enemy.isDead) {
      _enemyRegenAccumulator += dt;
      if (_enemyRegenAccumulator >= 1.0) {
        _enemyRegenAccumulator = 0.0;
        final healVal =
            max(5, (enemy.maxHp * enemy.hpRegenPercentPerSecond).round());
        enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healVal);
        _addFloatingText('+$healVal HP', Colors.greenAccent, isHeroTarget: false);
        _addLog('${enemy.name} hồi sinh lực +$healVal HP.');
      }
    }

    // Hero Freeze & Def Down timer countdowns
    if (_heroFreezeTimer > 0) {
      _heroFreezeTimer = max(0.0, _heroFreezeTimer - dt);
    }
    if (_heroDefDownTimer > 0) {
      _heroDefDownTimer = max(0.0, _heroDefDownTimer - dt);
    }

    // Hero Burn Ticks (Ifrit skill 2: 10% max HP/s for 5s)
    if (_heroBurnTicks > 0) {
      _heroBurnAccumulator += dt;
      if (_heroBurnAccumulator >= 1.0) {
        _heroBurnAccumulator = 0.0;
        _heroBurnTicks--;
        final burnDmg = max(5, (player.maxHp * 0.10).round());
        _heroHp = max(0, _heroHp - burnDmg);
        _totalDamageTaken += burnDmg;
        _enemyDamageBreakdown['Thiêu Rụi (Burn)'] =
            (_enemyDamageBreakdown['Thiêu Rụi (Burn)'] ?? 0) + burnDmg;
        _addFloatingText('-$burnDmg 🔥', Colors.orangeAccent, isHeroTarget: true);
        _addLog('${player.name} chịu $burnDmg sát thương Thiêu Rụi từ ${enemy.name}!');
        if (_heroHp <= 0) {
          _handleDefeat();
          return;
        }
      }
    }

    // Boss Skills & 1.2s Telegraph Cooldown handling
    if (enemy.isBoss && enemy.bossSkills.isNotEmpty && !_isTelegraphing) {
      for (final skill in enemy.bossSkills) {
        final currentCd = _bossSkillCooldowns[skill.id] ?? 0.0;
        if (currentCd > 0) {
          _bossSkillCooldowns[skill.id] = max(0.0, currentCd - dt);
        }
      }

      for (final skill in enemy.bossSkills) {
        final currentCd = _bossSkillCooldowns[skill.id] ?? 0.0;
        if (currentCd <= 0.0) {
          _isTelegraphing = true;
          _telegraphTimer = 1.2; // 1.2s warning
          _currentTelegraphSkill = skill;
          _addLog('⚠️ CẢNH BÁO: ${enemy.name} chuẩn bị tung [${skill.name}]!');
          break;
        }
      }
    }

    // Process Telegraphing countdown
    if (_isTelegraphing && _currentTelegraphSkill != null) {
      _telegraphTimer -= dt;
      if (_telegraphTimer <= 0) {
        final skillToCast = _currentTelegraphSkill!;
        _bossSkillCooldowns[skillToCast.id] = skillToCast.cooldown;
        _isTelegraphing = false;
        _currentTelegraphSkill = null;
        _executeBossTelegraphedSkill(skillToCast);
        if (_heroHp <= 0) return;
      }
    }

    // 8. Hero Action Loop (Frozen hero cannot act)
    if (_heroFreezeTimer <= 0) {
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
    }

    // 9. Enemy Action Loop (Slowed down by 30% if under Hàn Băng set effect)
    // While telegraphing a major telegraphed skill, boss does not perform basic attacks
    if (!_isTelegraphing) {
      if (_enemySlowTimer > 0) {
        _enemySlowTimer = max(0.0, _enemySlowTimer - dt);
      }
      _enemyAttackTimer += (_enemySlowTimer > 0 ? dt * 0.70 : dt);
      final enemyInterval = enemy.attackInterval;
      if (_enemyAttackTimer >= enemyInterval) {
        _enemyAttackTimer = 0.0;
        _executeEnemyAction();
        if (_heroHp <= 0) {
          _handleDefeat();
          return;
        }
      }
    }

    _emitState(isFighting: true);
  }

  void _executeHeroAction() {
    Skill? chosenSkill;

    // Tactical AI Priority: If Hero HP < 70% and a healing skill is off cooldown, prioritize healing!
    if (_heroHp < _heroMaxHp * 0.70) {
      for (final skillId in player.equippedSkillIds) {
        final rawSkill = SeedSkills.getById(skillId);
        final skill = rawSkill.copyWith(level: player.skillLevels[skillId] ?? 1);
        final cd = _cooldowns[skillId] ?? 0.0;
        if (skill.healsHero && _heroMana >= skill.manaCost && cd <= 0.0) {
          chosenSkill = skill;
          break;
        }
      }
    }

    if (chosenSkill == null) {
      for (final skillId in player.equippedSkillIds) {
        final rawSkill = SeedSkills.getById(skillId);
        final skill = rawSkill.copyWith(level: player.skillLevels[skillId] ?? 1);
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
    }

    chosenSkill ??= SeedSkills.getById('fireball').copyWith(level: player.skillLevels['fireball'] ?? 1);

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

    // Healing skill (Max 25% Max HP, 15s cooldown)
    if (chosenSkill.healsHero) {
      final healVal = (_heroMaxHp * 0.25).round();
      _heroHp = min(_heroMaxHp, _heroHp + healVal);
      _totalHealed += healVal;
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

    // Crit calculation (includes enemy crit reduction modifier)
    double critChance = max(
      0.0,
      player.critRate + chosenSkill.critRateBonus - enemy.critReductionPercent,
    );
    bool isCrit = _rng.nextDouble() < critChance;
    if (isCrit) {
      rawDamage *= player.critDamageMultiplier;
    }

    // Defense mitigation
    // Huyết Ma 3-piece: Below 30% HP, +20% ATK
    if (player.hasSetBonus3('huyet_ma') && _heroHp < (_heroMaxHp * 0.30)) {
      rawDamage *= 1.20;
    }

    int netDamage = max(1, (rawDamage - enemy.def).round());
    enemy.currentHp = max(0, enemy.currentHp - netDamage);
    _totalDamageDealt += netDamage;
    if (isCrit && netDamage > _highestCrit) {
      _highestCrit = netDamage;
    }

    // Set Viêm Long 3-piece: Basic attack inflicts 1 extra stack of Burn (3s)
    if (chosenSkill.type == SkillType.basic && player.hasSetBonus3('viem_long')) {
      enemy.burnTicksLeft = max(enemy.burnTicksLeft, 3);
      enemy.burnDamagePerTick = max(enemy.burnDamagePerTick, max(15, (player.magicAtk * 0.20).round()));
      _addLog('🔥 [Set Viêm Long 3/3]: Đòn đánh thường gây thêm 1 tầng Thiêu Đốt!');
    }

    // Set Hàn Băng 3-piece: 20% chance to slow enemy by 30% (2s)
    if (player.hasSetBonus3('han_bang') && _rng.nextDouble() < 0.20) {
      _enemySlowTimer = 2.0;
      _addFloatingText('❄️ LÀM CHẬM 30%!', Colors.cyanAccent, isHeroTarget: false);
      _addLog('❄️ [Set Hàn Băng 3/3]: Đòn đánh làm chậm tốc đánh ${enemy.name} 30% trong 2s!');
    }

    // Set Lôi Đình 3-piece: Crit strikes extra 1 lightning bolt (50% damage, non-crit)
    if (isCrit && player.hasSetBonus3('loi_dinh')) {
      final lightningDmg = max(1, (netDamage * 0.50).round());
      enemy.currentHp = max(0, enemy.currentHp - lightningDmg);
      _totalDamageDealt += lightningDmg;
      _addFloatingText('⚡ LÔI PHẠT!\n+$lightningDmg', Colors.amberAccent, isHeroTarget: false);
      _addLog('⚡ [Set Lôi Đình 3/3]: Bạo kích giáng sấm sét gây thêm $lightningDmg sát thương!');
    }

    // Set Huyết Ma 2 & 3-piece + Affix Lifesteal:
    double lifestealRatio = player.allAffixLifestealPercent;
    if (player.hasSetBonus2('huyet_ma')) {
      lifestealRatio += 0.10;
    }
    if (player.hasSetBonus3('huyet_ma') && _heroHp < (_heroMaxHp * 0.30)) {
      lifestealRatio += 0.50;
    }
    if (lifestealRatio > 0 && netDamage > 0) {
      final healAmt = max(1, (netDamage * lifestealRatio).round());
      final actualHeal = min(healAmt, _heroMaxHp - _heroHp);
      if (actualHeal > 0) {
        _heroHp += actualHeal;
        _totalHealed += actualHeal;
        _addFloatingText('+$actualHeal 🩸', Colors.greenAccent, isHeroTarget: true);
        _addLog('🩸 Hút máu hồi phục $actualHeal HP!');
      }
    }

    // Apply Burn status effect if skill causes burn
    if (chosenSkill.causesBurn) {
      enemy.burnTicksLeft = 3;
      enemy.burnDamagePerTick = max(10, (player.magicAtk * 0.25).round());
      _addLog('${enemy.name} bị thiêu đốt!');
    }

    // Floating text
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
      '${player.name} dùng [${chosenSkill.name}] — gây $netDamage ${isCrit ? '(CHÍ MẠNG!)' : ''} lên ${enemy.name}.',
    );
    _heroDamageBreakdown[chosenSkill.name] =
        (_heroDamageBreakdown[chosenSkill.name] ?? 0) + netDamage;

    // Zone 4: Reflect Damage (Phản đòn 20%)
    if (enemy.reflectDamagePercent > 0 && netDamage > 0) {
      int reflectDmg = max(1, (netDamage * enemy.reflectDamagePercent).round());
      _totalDamageTaken += reflectDmg;
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

      // Red floating text "-X (phản đòn)"
      _addFloatingText('-$reflectDmg (phản đòn)', Colors.redAccent, isHeroTarget: true);
      _addLog('${player.name} chịu $reflectDmg sát thương phản đòn từ ${enemy.name}!');

      if (_heroHp <= 0) {
        _handleDefeat();
        return;
      }
    }
  }

  void _executeEnemyAction() {
    void performSingleStrike() {
      // Check Dodge from player
      if (_rng.nextDouble() < player.dodgeRate) {
        _addFloatingText('NÉ!', Colors.grey, isHeroTarget: true);
        _addLog('${player.name} lanh lẹ né tránh đòn tấn công!');
        return;
      }

      double rawDmg = enemy.effectiveAtk.toDouble();
      bool isSpecial = false;
      String attackName = 'Đòn Đánh';
      if (enemy.specialSkill != null && enemy.bossSkills.isEmpty && _rng.nextDouble() < 0.35) {
        isSpecial = true;
        rawDmg *= enemy.specialSkill!.damageMultiplier;
        attackName = enemy.specialSkill!.name;
        _addLog('${enemy.name} tung chiêu [$attackName]!');
        // Set Hàn Băng 2-piece: +15% magic resistance
        if (player.hasSetBonus2('han_bang')) {
          rawDmg *= 0.85;
        }
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
      _totalDamageTaken += netDmg;
      _enemyDamageBreakdown[attackName] =
          (_enemyDamageBreakdown[attackName] ?? 0) + netDmg;

      String enemyHitText = isSpecial ? '$attackName\n-$netDmg' : '-$netDmg';
      if (isCrit) enemyHitText = 'CRIT! -$netDmg 💥';

      _addFloatingText(
        enemyHitText,
        isCrit ? Colors.redAccent : Colors.red,
        isCrit: isCrit,
        isHeroTarget: true,
      );

      _addLog(
        '${enemy.name} dùng [$attackName] — gây $netDmg sát thương ${isCrit ? '(CHÍ MẠNG!)' : ''} lên ${player.name}.',
      );
    }

    performSingleStrike();
    // Endless Modifier: Double Strike
    if (enemy.doubleStrike && _heroHp > 0) {
      performSingleStrike();
    }
  }

  void _executeBossTelegraphedSkill(EnemySkill skill) {
    if (_isFinished) return;

    // 1. Debuff and utility effects
    if (skill.causesHeroFreeze) {
      _heroFreezeTimer = 2.0;
      _addFloatingText('🧊 ĐÓNG BĂNG 2s!', Colors.cyanAccent, isHeroTarget: true);
      _addLog('🧊 [Đóng Băng]: ${player.name} bị đóng băng không thể ra đòn trong 2 giây!');
    }
    if (skill.causesHeroDefDown) {
      _heroDefDownTimer = 5.0;
      _addFloatingText('🦁 GIẢM 20% GIÁP (5s)!', Colors.amberAccent, isHeroTarget: true);
      _addLog('🦁 [Gầm Thét]: ${player.name} bị giảm 20% DEF trong 5 giây!');
    }
    if (skill.causesHeroBurn) {
      _heroBurnTicks = 5;
      _addFloatingText('🌋 THIÊU RỤI 5s!', Colors.deepOrangeAccent, isHeroTarget: true);
      _addLog('🌋 [Thiêu Rụi]: ${player.name} bị thiêu đốt dữ dội (10% HP/s)!');
    }
    if (skill.healsBossPercent) {
      int healAmt = (enemy.maxHp * 0.15).round();
      enemy.currentHp = min(enemy.maxHp, enemy.currentHp + healAmt);
      _addFloatingText('+$healAmt HP 👻', Colors.greenAccent, isHeroTarget: false);
      _addLog('👻 [Triệu Hồi Oán Linh]: ${enemy.name} hồi phục $healAmt HP!');
    }

    // 2. Damage execution (only if skill has damageMultiplier > 0)
    if (skill.damageMultiplier > 0) {
      double rawDmg = enemy.effectiveAtk * skill.damageMultiplier;
      // Hàn Băng 2-piece magic resistance
      if (skill.isMagic && player.hasSetBonus2('han_bang')) {
        rawDmg *= 0.85;
      }

      double heroDef = _heroDefDownTimer > 0 ? player.physicalDef * 0.80 : player.physicalDef;
      int netDmg = max(1, (rawDmg - heroDef).round());

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
      _totalDamageTaken += netDmg;
      _enemyDamageBreakdown[skill.name] = (_enemyDamageBreakdown[skill.name] ?? 0) + netDmg;

      _addFloatingText(
        '${skill.name}\n-$netDmg 💥',
        Colors.redAccent,
        isCrit: true,
        isHeroTarget: true,
      );

      _addLog(
        '${enemy.name} dùng [${skill.name}] — gây $netDmg sát thương lên ${player.name}.',
      );

      if (_heroHp <= 0) {
        _handleDefeat();
      }
    }
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

    // Anti-trivialize: Clear under 8s buffs next stage difficulty by +15%
    final triggeredSpeedrun = _battleDuration < 8.0;
    if (triggeredSpeedrun) {
      _addLog('⚡ Vượt ải thần tốc (< 8s)! Độ khó ải kế tiếp tăng +15%!');
    }

    final finalState = _currentState(
      isFighting: false,
      isWon: true,
      earnedExp: enemy.expReward,
      earnedGold: enemy.goldReward,
      droppedEquipment: drops,
      battleDuration: _battleDuration,
      triggeredSpeedrunBonus: triggeredSpeedrun,
    );

    _emitDirect(finalState);
    onBattleEnded(finalState);
  }

  void _handleDefeat() {
    // Immortality node check: Revive once per battle with 50% HP
    if (!_hasRevived && (player.prestigeNodeLevels['immortality'] ?? 0) > 0) {
      _hasRevived = true;
      _heroHp = (_heroMaxHp * 0.50).round();
      _addFloatingText('✨ BẤT TỬ HỒI SINH! ✨', Colors.amberAccent, isCrit: true, isHeroTarget: true);
      _addLog('✨ BẤT TỬ: ${player.name} bùng nổ linh lực, hồi sinh thần kỳ với 50% HP!');
      _emitState(isFighting: true);
      return;
    }

    _isFinished = true;
    _timer?.cancel();
    _addLog('THẤT BẠI! Bạn đã gục ngã trước ${enemy.name}...');

    final finalState = _currentState(
      isFighting: false,
      isDefeated: true,
      battleDuration: _battleDuration,
    );

    _emitDirect(finalState);
    onBattleEnded(finalState);
  }

  void _addFloatingText(String text, Color color,
      {bool isCrit = false, bool isHeroTarget = false}) {
    if (_floatingTexts.length >= 20) {
      _floatingTexts.removeAt(0);
    }
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
    double? battleDuration,
    bool triggeredSpeedrunBonus = false,
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
      battleDuration: battleDuration ?? _battleDuration,
      triggeredSpeedrunBonus: triggeredSpeedrunBonus,
      totalDamageDealt: _totalDamageDealt,
      totalDamageTaken: _totalDamageTaken,
      totalHealed: _totalHealed,
      highestCritDamage: _highestCrit,
      battleSpeed: battleSpeed,
      telegraphSkillName: _isTelegraphing ? _currentTelegraphSkill?.name : null,
      telegraphSkillIcon: _isTelegraphing ? _currentTelegraphSkill?.icon : null,
      isTelegraphing: _isTelegraphing,
      heroDamageBreakdown: Map.from(_heroDamageBreakdown),
      enemyDamageBreakdown: Map.from(_enemyDamageBreakdown),
    );
  }

  void _emitState({bool isFighting = true}) {
    onStateChanged(_currentState(isFighting: isFighting));
  }

  void _emitDirect(BattleState state) {
    onStateChanged(state);
  }
}
