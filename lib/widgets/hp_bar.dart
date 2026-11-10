import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HpBar extends StatefulWidget {
  final int currentHp;
  final int maxHp;
  final int shield;
  final double height;
  final bool showText;
  final bool isHero;

  const HpBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
    this.shield = 0,
    this.height = 18,
    this.showText = true,
    this.isHero = true,
  });

  @override
  State<HpBar> createState() => _HpBarState();
}

class _HpBarState extends State<HpBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double hpRatio = widget.maxHp > 0
        ? (widget.currentHp / widget.maxHp).clamp(0.0, 1.0)
        : 0.0;
    final double shieldRatio = widget.maxHp > 0
        ? (widget.shield / widget.maxHp).clamp(0.0, 1.0)
        : 0.0;
    final bool isCritical = hpRatio > 0 && hpRatio <= 0.30;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0C18),
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: isCritical
                  ? AppTheme.redAccent.withOpacity(_pulseAnimation.value)
                  : (widget.isHero
                      ? AppTheme.greenAccent.withOpacity(0.4)
                      : AppTheme.redAccent.withOpacity(0.4)),
              width: isCritical ? 1.8 : 1.2,
            ),
            boxShadow: [
              if (isCritical)
                BoxShadow(
                  color: AppTheme.redAccent.withOpacity(_pulseAnimation.value * 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Stack(
              children: [
                // HP Fill Bar
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  widthFactor: hpRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isHero
                            ? [
                                const Color(0xFF2E8B57),
                                AppTheme.greenAccent,
                              ]
                            : [
                                const Color(0xFF8B0000),
                                AppTheme.redAccent,
                                const Color(0xFFFF7A7A),
                              ],
                      ),
                    ),
                  ),
                ),
                // Shield Overlay
                if (widget.shield > 0)
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 250),
                    widthFactor: shieldRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cyanAccent.withOpacity(0.55),
                      ),
                    ),
                  ),
                // Text Overlay
                if (widget.showText)
                  Center(
                    child: Text(
                      '${widget.currentHp} / ${widget.maxHp}${widget.shield > 0 ? ' (+${widget.shield}🛡️)' : ''}',
                      style: TextStyle(
                        fontSize: (widget.height * 0.62).clamp(9.0, 12.0),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
                          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, -1)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
    this.height = 12,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double manaRatio =
        maxMana > 0 ? (currentMana / maxMana).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0C101A),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppTheme.blueAccent.withOpacity(0.4), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              widthFactor: manaRatio,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E3A8A),
                      AppTheme.blueAccent,
                      Color(0xFF93C5FD),
                    ],
                  ),
                ),
              ),
            ),
            if (showText)
              Center(
                child: Text(
                  'MP: $currentMana / $maxMana',
                  style: TextStyle(
                    fontSize: (height * 0.65).clamp(8.0, 10.5),
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
