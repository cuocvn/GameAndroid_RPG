import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 1. Monster Death Burst Particles (8 - 12 particles radiating outward)
class MonsterDeathParticles extends StatefulWidget {
  final Color auraColor;
  final VoidCallback? onComplete;

  const MonsterDeathParticles({
    super.key,
    this.auraColor = const Color(0xFFFFB547),
    this.onComplete,
  });

  @override
  State<MonsterDeathParticles> createState() => _MonsterDeathParticlesState();
}

class _MonsterDeathParticlesState extends State<MonsterDeathParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    final count = 8 + _rng.nextInt(5); // 8 - 12 particles
    for (int i = 0; i < count; i++) {
      final angle = (i * (2 * pi / count)) + (_rng.nextDouble() * 0.4 - 0.2);
      final speed = 40.0 + _rng.nextDouble() * 60.0;
      final radius = 3.0 + _rng.nextDouble() * 3.5;
      _particles.add(_Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        radius: radius,
        color: i.isEven ? widget.auraColor : Colors.white,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward().then((_) {
        widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            painter: _BurstPainter(particles: _particles, progress: progress),
            size: const Size(120, 120),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double radius;
  final Color color;

  _Particle({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
  });
}

class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _BurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final pos = center + Offset(p.dx * progress, p.dy * progress);
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, p.radius * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 2. Level Up Golden Sparkles (20 golden particles rising + subtle light rays)
class LevelUpParticles extends StatefulWidget {
  final VoidCallback? onComplete;

  const LevelUpParticles({super.key, this.onComplete});

  @override
  State<LevelUpParticles> createState() => _LevelUpParticlesState();
}

class _LevelUpParticlesState extends State<LevelUpParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_LevelUpSpark> _sparks = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _sparks.add(_LevelUpSpark(
        startX: -60.0 + _rng.nextDouble() * 120.0,
        startY: 20.0 + _rng.nextDouble() * 30.0,
        floatY: 80.0 + _rng.nextDouble() * 70.0,
        size: 3.0 + _rng.nextDouble() * 3.5,
        speedDelay: _rng.nextDouble() * 0.2,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward().then((_) {
        widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final val = _controller.value;
        return CustomPaint(
          painter: _LevelUpPainter(sparks: _sparks, progress: val),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _LevelUpSpark {
  final double startX;
  final double startY;
  final double floatY;
  final double size;
  final double speedDelay;

  _LevelUpSpark({
    required this.startX,
    required this.startY,
    required this.floatY,
    required this.size,
    required this.speedDelay,
  });
}

class _LevelUpPainter extends CustomPainter {
  final List<_LevelUpSpark> sparks;
  final double progress;

  _LevelUpPainter({required this.sparks, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Subtle golden rotating rays behind character
    final rayPaint = Paint()
      ..color = AppTheme.goldAccent.withOpacity((1.0 - progress) * 0.18)
      ..style = PaintingStyle.fill;
    final rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + (progress * 0.8);
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + cos(angle - 0.1) * 90,
        center.dy + sin(angle - 0.1) * 90,
      );
      path.lineTo(
        center.dx + cos(angle + 0.1) * 90,
        center.dy + sin(angle + 0.1) * 90,
      );
      path.close();
      canvas.drawPath(path, rayPaint);
    }

    // 20 rising golden sparkle dots
    for (final s in sparks) {
      final adjustedP = ((progress - s.speedDelay) / (1.0 - s.speedDelay)).clamp(0.0, 1.0);
      if (adjustedP <= 0.0) continue;

      final y = center.dy + s.startY - (adjustedP * s.floatY);
      final x = center.dx + s.startX + sin(adjustedP * 4 * pi) * 6;
      final opacity = (1.0 - adjustedP).clamp(0.0, 1.0);

      final sparkPaint = Paint()
        ..color = AppTheme.goldAccent.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), s.size * (1.0 - adjustedP * 0.3), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelUpPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 3. Rare+ Loot Card Gleam Sparkles (glittering around card for 1s)
class RareLootGleamOverlay extends StatefulWidget {
  final Widget child;
  final bool isRarePlus;

  const RareLootGleamOverlay({
    super.key,
    required this.child,
    this.isRarePlus = true,
  });

  @override
  State<RareLootGleamOverlay> createState() => _RareLootGleamOverlayState();
}

class _RareLootGleamOverlayState extends State<RareLootGleamOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isRarePlus) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RareLootGleamOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRarePlus && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRarePlus && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRarePlus) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GleamPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GleamPainter extends CustomPainter {
  final double progress;

  _GleamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gleamPositions = [
      Offset(12, 12),
      Offset(size.width - 14, 16),
      Offset(size.width * 0.45, 8),
      Offset(size.width - 18, size.height - 14),
      Offset(16, size.height - 16),
    ];

    for (int i = 0; i < gleamPositions.length; i++) {
      final pos = gleamPositions[i];
      final sparkOpacity = ((sin((progress + i * 0.25) * pi)).abs()).clamp(0.0, 1.0);
      final sizeFactor = 2.5 + sparkOpacity * 2.0;

      final paint = Paint()
        ..color = AppTheme.goldAccent.withOpacity(sparkOpacity * 0.85)
        ..style = PaintingStyle.fill;

      // Draw 4-point sparkle star
      final path = Path();
      path.moveTo(pos.dx, pos.dy - sizeFactor);
      path.lineTo(pos.dx + sizeFactor * 0.35, pos.dy - sizeFactor * 0.35);
      path.lineTo(pos.dx + sizeFactor, pos.dy);
      path.lineTo(pos.dx + sizeFactor * 0.35, pos.dy + sizeFactor * 0.35);
      path.lineTo(pos.dx, pos.dy + sizeFactor);
      path.lineTo(pos.dx - sizeFactor * 0.35, pos.dy + sizeFactor * 0.35);
      path.lineTo(pos.dx - sizeFactor, pos.dy);
      path.lineTo(pos.dx - sizeFactor * 0.35, pos.dy - sizeFactor * 0.35);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GleamPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 4. Battle Button Fire Sparks (5 fiery ember particles scattering on press)
class ButtonFireSparks extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ButtonFireSparks({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<ButtonFireSparks> createState() => _ButtonFireSparksState();
}

class _ButtonFireSparksState extends State<ButtonFireSparks>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;
  final List<_FireEmber> _embers = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  void _triggerSparks() {
    _embers.clear();
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + (_rng.nextDouble() * pi - pi / 2);
      final dist = 25.0 + _rng.nextDouble() * 30.0;
      _embers.add(_FireEmber(
        dx: cos(angle) * dist,
        dy: sin(angle) * dist,
        radius: 2.0 + _rng.nextDouble() * 2.0,
      ));
    }
    _sparkController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerSparks,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_sparkController.isAnimating)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sparkController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _EmberPainter(
                        embers: _embers,
                        progress: _sparkController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FireEmber {
  final double dx;
  final double dy;
  final double radius;

  _FireEmber({required this.dx, required this.dy, required this.radius});
}

class _EmberPainter extends CustomPainter {
  final List<_FireEmber> embers;
  final double progress;

  _EmberPainter({required this.embers, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final e in embers) {
      final pos = center + Offset(e.dx * progress, e.dy * progress);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = (progress < 0.4 ? Colors.amberAccent : Colors.deepOrangeAccent)
            .withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, e.radius * (1.0 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 5. Reusable Skeleton Loader (for smooth list loading)
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2.0, 0),
              end: Alignment(1.0 + _controller.value * 2.0, 0),
              colors: const [
                Color(0xFF1E1A29),
                Color(0xFF2E283E),
                Color(0xFF1E1A29),
              ],
            ),
          ),
        );
      },
    );
  }
}
