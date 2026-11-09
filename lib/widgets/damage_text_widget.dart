import 'package:flutter/material.dart';
import '../models/battle_state.dart';

class FloatingDamageOverlay extends StatelessWidget {
  final List<FloatingText> texts;

  const FloatingDamageOverlay({super.key, required this.texts});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    return Stack(
      children: texts.map((ft) {
        final age = (now - ft.createdAt).clamp(0.0, 1.2);
        final progress = age / 1.2;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        final yOffset = -progress * 60.0;

        return Positioned(
          left: ft.isHeroTarget ? 60 : null,
          right: ft.isHeroTarget ? null : 60,
          top: 130 + yOffset,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ft.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ft.isCrit ? 22 : 16,
                  fontWeight: FontWeight.w900,
                  color: ft.color,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
