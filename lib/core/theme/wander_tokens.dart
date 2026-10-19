import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'wander_typography.dart';

/// Named colors from DESIGN.md §2 (core + supporting).
@immutable
class WanderColors {
  const WanderColors({
    required this.paper,
    required this.card,
    required this.peach,
    required this.apricot,
    required this.slate,
    required this.mist,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.line,
    required this.tape,
    required this.polaroid,
    required this.success,
    required this.error,
    required this.shadowTint,
  });

  final Color paper;
  final Color card;
  final Color peach;
  final Color apricot;
  final Color slate;
  final Color mist;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color line;
  final Color tape;
  final Color polaroid;
  final Color success;
  final Color error;
  final Color shadowTint;
}

/// Misty atmosphere gradients (DESIGN.md §2).
@immutable
class WanderGradients {
  const WanderGradients({
    required this.mistDawn,
    required this.mistLake,
    required this.photoScrim,
  });

  final LinearGradient mistDawn;
  final LinearGradient mistLake;
  final LinearGradient photoScrim;
}

/// 4-pt spacing grid (DESIGN.md §4).
@immutable
class WanderSpacing {
  const WanderSpacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 24;
  final double xxl = 32;
  final double xxxl = 48;

  /// Screen side padding.
  double get screen => lg;

  /// Masonry grid gap.
  double get grid => md;
}

/// Corner radii (DESIGN.md §4).
@immutable
class WanderRadii {
  const WanderRadii();

  final double sm = 12;
  final double md = 20;
  final double lg = 28;
  final double pill = 999;
  final double polaroid = 6;
}

/// Component sizes (DESIGN.md §5–6).
@immutable
class WanderSizes {
  const WanderSizes();

  final double buttonHeight = 52;
  final double inputHeight = 52;
  final double chipHeight = 32;
  final double ratingCircle = 36;
  final double statCircle = 56;
  final double navAddButton = 56;
  final double icon = 24;
  final double ghostBorder = 1.5;
  final double focusBorder = 2;
  final Size washiTape = const Size(64, 20);
  final Size grabHandle = const Size(40, 4);
  final double polaroidSide = 8;
  final double polaroidBottom = 28;
  final double frostedBlur = 16;
  final double frostedOpacity = 0.8;
  final double navOpacity = 0.9;
  final double chipFillOpacity = 0.45;
  final double coverHeroHeight = 300;
  final double galleryHeight = 380;
  final double mapHeight = 160;
  final double avatar = 88;
}

/// Motion tokens (DESIGN.md §7).
@immutable
class WanderMotion {
  const WanderMotion();

  final Duration fast = const Duration(milliseconds: 150);
  final Duration base = const Duration(milliseconds: 250);
  final Duration slow = const Duration(milliseconds: 400);
  final Curve curve = Curves.easeOutCubic;
  final double pressScale = 0.97;
  final double dropOffset = 12;

  /// Extra rotation (degrees) a dropped polaroid starts with before settling.
  final double dropSpinDegrees = 6;

  /// Allowed tilt steps in degrees for grid items.
  final List<int> tiltSteps = const [-2, -1, 0, 1, 2];
  final double washiAngleDegrees = 8;

  double radians(num degrees) => degrees * math.pi / 180;
}

/// Wanderboard design tokens exposed through [ThemeData.extensions].
@immutable
class WanderTokens extends ThemeExtension<WanderTokens> {
  const WanderTokens({
    required this.colors,
    required this.gradients,
    required this.shadowSoft,
    required this.shadowLift,
    required this.text,
    this.spacing = const WanderSpacing(),
    this.radii = const WanderRadii(),
    this.sizes = const WanderSizes(),
    this.motion = const WanderMotion(),
  });

  final WanderColors colors;
  final WanderGradients gradients;
  final List<BoxShadow> shadowSoft;
  final List<BoxShadow> shadowLift;
  final WanderTypeScale text;
  final WanderSpacing spacing;
  final WanderRadii radii;
  final WanderSizes sizes;
  final WanderMotion motion;

  /// Convenience for the Caveat accent style.
  TextStyle get handNote => text.handNote;

  @override
  WanderTokens copyWith({
    WanderColors? colors,
    WanderGradients? gradients,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowLift,
    WanderTypeScale? text,
  }) {
    return WanderTokens(
      colors: colors ?? this.colors,
      gradients: gradients ?? this.gradients,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowLift: shadowLift ?? this.shadowLift,
      text: text ?? this.text,
      spacing: spacing,
      radii: radii,
      sizes: sizes,
      motion: motion,
    );
  }

  /// The mockup ships a single light theme, so tokens switch discretely.
  @override
  WanderTokens lerp(covariant WanderTokens? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension WanderThemeContext on BuildContext {
  WanderTokens get wander => Theme.of(this).extension<WanderTokens>()!;
}
