// lib/services/audio_service.dart
// Plays notification sounds using Web Audio API on Web and SystemSound/Haptics on Mobile
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/web_js.dart';

class AudioService {
  /// Call this once on first user interaction to unlock audio context
  static void unlock() {
    if (!kIsWeb) return;
    try {
      WebJs.callMethod('goChefPlayMessage', []);
    } catch (_) {}
  }

  /// Play loud chime when chef receives an incoming order (Ding-Dong-Ding! 🛎️)
  static void playOrder() {
    if (kIsWeb) {
      try {
        WebJs.callMethod('goChefPlayOrder', []);
      } catch (_) {}
    } else {
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Play a short ding for new notifications
  static void playNotification() {
    if (kIsWeb) {
      try {
        WebJs.callMethod('goChefPlayNotification', []);
      } catch (_) {}
    } else {
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// Play a crisp "Ding-Ding / Doorbell" chime for incoming chat messages 🔔
  static void playMessage() {
    if (kIsWeb) {
      try {
        WebJs.callMethod('goChefPlayMessage', []);
      } catch (_) {}
    } else {
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }
}
