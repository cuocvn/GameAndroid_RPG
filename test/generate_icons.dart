import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate app icon and splash images', () async {
    final outDir = Directory('assets/icon');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    // 1. Full Icon (1024x1024)
    final fullIconBytes = await _renderIcon(isAdaptiveForeground: false);
    File('assets/icon/app_icon.png').writeAsBytesSync(fullIconBytes);

    // 2. Adaptive Foreground (1024x1024, transparent bg, centered emblem)
    final fgBytes = await _renderIcon(isAdaptiveForeground: true);
    File('assets/icon/app_icon_foreground.png').writeAsBytesSync(fgBytes);

    // 3. Adaptive Background (1024x1024, #0D0B14)
    final bgBytes = await _renderBackground();
    File('assets/icon/app_icon_background.png').writeAsBytesSync(bgBytes);

    // 4. Splash Screen Center Logo (512x512)
    final splashBytes = await _renderSplashLogo();
    File('assets/icon/splash_logo.png').writeAsBytesSync(splashBytes);

    expect(File('assets/icon/app_icon.png').existsSync(), true);
    expect(File('assets/icon/app_icon_foreground.png').existsSync(), true);
    expect(File('assets/icon/app_icon_background.png').existsSync(), true);
    expect(File('assets/icon/splash_logo.png').existsSync(), true);
  });
}

Future<List<int>> _renderIcon({required bool isAdaptiveForeground}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024));
  final center = const Offset(512, 512);

  if (!isAdaptiveForeground) {
    // Background gradient #0D0B14 to #24163E
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        600,
        [const Color(0xFF2C194D), const Color(0xFF140D24), const Color(0xFF0D0B14)],
        [0.0, 0.65, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), bgPaint);

    // Outer Golden Ring Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(1024, 1024),
        [const Color(0xFFFFDF7A), const Color(0xFFFF9900), const Color(0xFF995500), const Color(0xFFFFDF7A)],
        [0.0, 0.35, 0.7, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(40, 40, 944, 944), const Radius.circular(220)),
      borderPaint,
    );

    // Subtle inner corner accents
    final accentPaint = Paint()
      ..color = const Color(0xFFFFB547).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, 400, accentPaint);
  }

  // --- Dragon Eye & Glowing "影" Emblem ---
  // Scale down slightly for adaptive foreground to respect safe zone
  final scale = isAdaptiveForeground ? 0.72 : 0.88;
  canvas.save();
  canvas.translate(512, 512);
  canvas.scale(scale);
  canvas.translate(-512, -512);

  // Outer Dragon Eye Shape (Almond shape)
  final eyePath = Path();
  eyePath.moveTo(180, 512);
  eyePath.quadraticBezierTo(512, 220, 844, 512);
  eyePath.quadraticBezierTo(512, 804, 180, 512);
  eyePath.close();

  // Eye Aura Glow
  final glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 32
    ..color = const Color(0xFFFF8A00).withOpacity(0.5)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
  canvas.drawPath(eyePath, glowPaint);

  // Eye Golden Outline
  final eyeStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 20
    ..shader = ui.Gradient.linear(
      const Offset(180, 220),
      const Offset(844, 804),
      [const Color(0xFFFFE082), const Color(0xFFFF8A00)],
    );
  canvas.drawPath(eyePath, eyeStroke);

  // Dragon Iris / Center Slit
  final irisPath = Path();
  irisPath.moveTo(512, 260);
  irisPath.quadraticBezierTo(560, 512, 512, 764);
  irisPath.quadraticBezierTo(464, 512, 512, 260);
  irisPath.close();

  final irisPaint = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(512, 260),
      const Offset(512, 764),
      [const Color(0xFFFFEA79), const Color(0xFFFF4500)],
    );
  canvas.drawPath(irisPath, irisPaint);

  // Dragon Pupil Vertical Sharp Slit
  final pupilPath = Path();
  pupilPath.moveTo(512, 330);
  pupilPath.quadraticBezierTo(526, 512, 512, 694);
  pupilPath.quadraticBezierTo(498, 512, 512, 330);
  pupilPath.close();

  final pupilPaint = Paint()..color = const Color(0xFF0D0B14);
  canvas.drawPath(pupilPath, pupilPaint);

  // Central Calligraphic "影" (Shadow / Void) Glyph
  final textPainter = TextPainter(
    text: const TextSpan(
      text: '影',
      style: TextStyle(
        fontSize: 340,
        fontWeight: FontWeight.w900,
        fontFamily: 'serif',
        color: Color(0xFFFFE082),
        shadows: [
          Shadow(color: Color(0xFFFF8A00), blurRadius: 40),
          Shadow(color: Colors.black, blurRadius: 20, offset: Offset(6, 8)),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(512 - textPainter.width / 2, 512 - textPainter.height / 2),
  );

  canvas.restore();

  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<List<int>> _renderBackground() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024));

  final paint = Paint()
    ..shader = ui.Gradient.radial(
      const Offset(512, 512),
      700,
      [const Color(0xFF1E1433), const Color(0xFF0D0B14)],
      [0.0, 1.0],
    );
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), paint);

  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<List<int>> _renderSplashLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 768, 768));

  // Center Dragon emblem + Text
  canvas.save();
  canvas.translate(384, 300);
  canvas.scale(0.68);
  canvas.translate(-512, -512);

  // Outer Dragon Eye
  final eyePath = Path();
  eyePath.moveTo(180, 512);
  eyePath.quadraticBezierTo(512, 220, 844, 512);
  eyePath.quadraticBezierTo(512, 804, 180, 512);
  eyePath.close();

  final glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 32
    ..color = const Color(0xFFFF8A00).withOpacity(0.6)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
  canvas.drawPath(eyePath, glowPaint);

  final eyeStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 20
    ..shader = ui.Gradient.linear(
      const Offset(180, 220),
      const Offset(844, 804),
      [const Color(0xFFFFE082), const Color(0xFFFF8A00)],
    );
  canvas.drawPath(eyePath, eyeStroke);

  final textPainter = TextPainter(
    text: const TextSpan(
      text: '影',
      style: TextStyle(
        fontSize: 340,
        fontWeight: FontWeight.w900,
        fontFamily: 'serif',
        color: Color(0xFFFFE082),
        shadows: [
          Shadow(color: Color(0xFFFF8A00), blurRadius: 40),
          Shadow(color: Colors.black, blurRadius: 20, offset: Offset(6, 8)),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(512 - textPainter.width / 2, 512 - textPainter.height / 2),
  );
  canvas.restore();

  // Bottom Title "VÔ ẢNH CHIẾN KÝ"
  final titlePainter = TextPainter(
    text: const TextSpan(
      text: 'VÔ ẢNH CHIẾN KÝ',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        fontFamily: 'serif',
        color: Color(0xFFFFB547),
        letterSpacing: 4.0,
        shadows: [
          Shadow(color: Color(0xFFFF8A00), blurRadius: 24),
          Shadow(color: Colors.black, blurRadius: 12, offset: Offset(2, 3)),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  titlePainter.layout();
  titlePainter.paint(
    canvas,
    Offset(384 - titlePainter.width / 2, 580),
  );

  // Subtitle "TACTICAL IDLE RPG"
  final subPainter = TextPainter(
    text: const TextSpan(
      text: 'TACTICAL IDLE RPG',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
        letterSpacing: 6.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  subPainter.layout();
  subPainter.paint(
    canvas,
    Offset(384 - subPainter.width / 2, 650),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(768, 768);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
