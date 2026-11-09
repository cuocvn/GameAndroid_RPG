import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final int shield;
  final double height;
  final bool showText;

  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.shield = 0,
    this.height = 18,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double hpRatio = maxHp > 0 ? (currentHp / maxHp).clamp(0.0, 1.0) : 0.0;
    final double shieldRatio = maxHp > 0 ? (shield / maxHp).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.red.shade900, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            // HP Fill
            FractionallySizedBox(
              widthFactor: hpRatio,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade800,
                      Colors.redAccent.shade400,
                      Colors.orangeAccent.shade400,
                    ],
                  ),
                ),
              ),
            ),
            // Shield Fill Overlay
            if (shield > 0)
              FractionallySizedBox(
                widthFactor: shieldRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.5),
                  ),
                ),
              ),
            // Text
            if (showText)
              Center(
                child: Text(
                  '$currentHp / $maxHp ${shield > 0 ? '(+$shield🛡️)' : ''}',
                  style: TextStyle(
                    fontSize: height * 0.65,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 3),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ManaBar extends StatelessWidget {
  final int currentMana;
  final int maxMana;
  final double height;
  final bool showText;

  const ManaBar({
    super.key,
    required this.currentMana,
    required this.maxMana,
    this.height = 14,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double manaRatio = maxMana > 0 ? (currentMana / maxMana).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.blue.shade900, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: manaRatio,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade900,
                      Colors.blueAccent,
                      Colors.cyanAccent,
                    ],
                  ),
                ),
              ),
            ),
            if (showText)
              Center(
                child: Text(
                  '$currentMana / $maxMana',
                  style: TextStyle(
                    fontSize: height * 0.7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 2),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
