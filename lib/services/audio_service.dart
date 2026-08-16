// lib/services/audio_service.dart
// Plays notification sounds using Web Audio API (synthesized, no audio files needed)
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class AudioService {
  static bool _unlocked = false;

  /// Call this once on first user interaction to unlock audio context
  static void unlock() {
    if (!kIsWeb) return;
    _unlocked = true;
  }

  /// Play a short ding for new notifications
  static void playNotification() {
    if (!kIsWeb || !_unlocked) return;
    try {
      js.context.callMethod('goChefPlayNotification', []);
    } catch (_) {}
  }

  /// Play a lighter ping for incoming chat messages
  static void playMessage() {
    if (!kIsWeb || !_unlocked) return;
    try {
      js.context.callMethod('goChefPlayMessage', []);
    } catch (_) {}
  }
}
