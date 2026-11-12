import 'package:flutter/services.dart';

/// Sound & Haptic Centralized Service
/// Handles SystemSound clicks/alerts and HapticFeedback intensities with settings checks.
class SoundService {
  static void playClick({bool isSoundEnabled = true}) {
    if (!isSoundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playAlert({bool isSoundEnabled = true}) {
    if (!isSoundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static void vibrateLight({bool isHapticEnabled = true}) {
    if (!isHapticEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void vibrateMedium({bool isHapticEnabled = true}) {
    if (!isHapticEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void vibrateHeavy({bool isHapticEnabled = true}) {
    if (!isHapticEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static void vibrateSelect({bool isHapticEnabled = true}) {
    if (!isHapticEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
