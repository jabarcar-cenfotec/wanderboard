import 'package:flutter/painting.dart';

/// Raw color values from DESIGN.md §2.
///
/// This is the only file allowed to contain hex literals. Widgets must read
/// colors through [ColorScheme] or `WanderTokens`, never from here directly.
abstract final class WanderPalette {
  // Core palette.
  static const paper = Color(0xFFF7F1E8);
  static const card = Color(0xFFFBF7F1);
  static const peach = Color(0xFFF2C6A8);
  static const apricot = Color(0xFFE8A07E);
  static const slate = Color(0xFF3E5A6B);
  static const mist = Color(0xFFA9BCC4);
  static const ink = Color(0xFF2E2A27);

  // Supporting tones.
  static const inkMuted = Color(0xFF6F6660);
  static const inkFaint = Color(0xFFA39A92);
  static const line = Color(0xFFE9DFD2);
  static const tape = Color(0xB3F2C6A8); // peach @ 70%
  static const polaroid = Color(0xFFFFFDF9);
  static const success = Color(0xFF7F9C7A);
  static const error = Color(0xFFC46A5A);

  // Gradient stops and shadow tint.
  static const dawnTop = Color(0xFFFBE3D3);
  static const shadowTint = Color(0xFF8A6A55);
}
