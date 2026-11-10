import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        // Slight arc float
        final yOffset = -progress * 65.0;
        final scale = ft.isCrit ? (1.0 + (1.0 - progress) * 0.3) : 1.0;

        return Positioned(
          left: ft.isHeroTarget ? 60 : null,
          right: ft.isHeroTarget ? null : 60,
          top: 130 + yOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Black Stroke Layer
                  Text(
                    ft.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: ft.isCrit ? 22 : 16,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3.5
                        ..color = Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Inner Colored Fill Layer
                  Text(
                    ft.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: ft.isCrit ? 22 : 16,
                      fontWeight: FontWeight.w900,
                      color: ft.color,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: ft.isCrit ? ft.color.withOpacity(0.8) : Colors.black,
                          blurRadius: ft.isCrit ? 8 : 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
