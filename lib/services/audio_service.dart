// lib/services/audio_service.dart
// Plays notification sounds using Web Audio API (synthesized, no audio files needed)
import 'package:flutter/foundation.dart';
import '../utils/web_js.dart';

class AudioService {
  static bool _unlocked = false;

  /// Call this once on first user interaction to unlock audio context
  static void unlock() {
    if (!kIsWeb) return;
    _unlocked = true;
  }

  /// Play loud chime when chef receives an incoming order (Ding-Dong-Ding! 🛎️)
  static void playOrder() {
    if (!kIsWeb) return;
    try {
      WebJs.callMethod('goChefPlayOrder', []);
    } catch (_) {}
  }

  /// Play a short ding for new notifications
  static void playNotification() {
    if (!kIsWeb) return;
    try {
      WebJs.callMethod('goChefPlayNotification', []);
    } catch (_) {}
  }

  /// Play a lighter ping for incoming chat messages
  static void playMessage() {
    if (!kIsWeb) return;
    try {
      WebJs.callMethod('goChefPlayMessage', []);
    } catch (_) {}
  }
}
