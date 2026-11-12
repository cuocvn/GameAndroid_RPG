import 'dart:math' as math;
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

        final isDodge = ft.text.toLowerCase().contains('né') ||
            ft.text.toLowerCase().contains('miss');

        double scale;
        double xOffset = 0.0;
        final yOffset = -progress * 40.0; // Bay lên 40px

        if (isDodge) {
          scale = 1.0; // Né: không scale bounce
        } else if (ft.isCrit) {
          scale = 1.5; // Crit: scale to 1.5
          xOffset = math.sin(progress * 30) * (1.0 - progress) * 2.5; // Shake nhẹ
        } else {
          // Damage thường: scale 0.8 -> 1.2 -> 1.0 (bounce trong 0.3s)
          if (age < 0.3) {
            final t = age / 0.3;
            if (t < 0.5) {
              scale = 0.8 + (1.2 - 0.8) * (t / 0.5);
            } else {
              scale = 1.2 - (1.2 - 1.0) * ((t - 0.5) / 0.5);
            }
          } else {
            scale = 1.0;
          }
        }

        final displayText = isDodge
            ? 'NÉ!'
            : (ft.isCrit && !ft.text.contains('⭐') ? '⭐ ${ft.text}' : ft.text);
        final displayColor = isDodge
            ? Colors.grey.shade400
            : (ft.isCrit ? Colors.amberAccent : ft.color);

        return Positioned(
          left: ft.isHeroTarget ? 60 + xOffset : null,
          right: ft.isHeroTarget ? null : 60 + xOffset,
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
                    displayText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: ft.isCrit ? 22 : 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: isDodge ? FontStyle.italic : FontStyle.normal,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = ft.isCrit ? 4.5 : 3.0
                        ..color = Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Inner Colored Fill Layer
                  Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: ft.isCrit ? 22 : 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: isDodge ? FontStyle.italic : FontStyle.normal,
                      color: displayColor,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: ft.isCrit
                              ? Colors.amber.withOpacity(0.9)
                              : Colors.black,
                          blurRadius: ft.isCrit ? 10 : 4,
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
