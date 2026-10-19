import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font families from DESIGN.md §3.
abstract final class WanderFontFamily {
  static const display = 'Fraunces';
  static const body = 'DM Sans';
  static const hand = 'Caveat';
}

/// Applies a font family to a base style.
///
/// Production uses [GoogleFontResolver]; tests use [PlainFontResolver] so no
/// network fetch is ever attempted.
abstract interface class FontResolver {
  TextStyle resolve(String family, TextStyle base);
}

final class GoogleFontResolver implements FontResolver {
  const GoogleFontResolver();

  @override
  TextStyle resolve(String family, TextStyle base) =>
      GoogleFonts.getFont(family, textStyle: base);
}

final class PlainFontResolver implements FontResolver {
  const PlainFontResolver();

  @override
  TextStyle resolve(String family, TextStyle base) =>
      base.copyWith(fontFamily: family);
}

/// The named type scale from DESIGN.md §3.
@immutable
class WanderTypeScale {
  const WanderTypeScale({
    required this.displayL,
    required this.displayM,
    required this.titleL,
    required this.titleM,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.overline,
    required this.handNote,
  });

  factory WanderTypeScale.build(FontResolver fonts, Color ink) {
    TextStyle style(
      String family,
      double size,
      double line,
      FontWeight weight, {
      double? letterSpacing,
    }) {
      return fonts.resolve(
        family,
        TextStyle(
          fontSize: size,
          height: line / size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          color: ink,
        ),
      );
    }

    const display = WanderFontFamily.display;
    const body = WanderFontFamily.body;
    return WanderTypeScale(
      displayL: style(display, 34, 40, FontWeight.w600),
      displayM: style(display, 28, 34, FontWeight.w600),
      titleL: style(display, 22, 28, FontWeight.w600),
      titleM: style(body, 17, 24, FontWeight.w600),
      body: style(body, 15, 22, FontWeight.w400),
      bodyStrong: style(body, 15, 22, FontWeight.w600),
      caption: style(body, 13, 18, FontWeight.w500),
      overline: style(body, 11, 16, FontWeight.w700, letterSpacing: 1.2),
      handNote: style(WanderFontFamily.hand, 20, 24, FontWeight.w500),
    );
  }

  final TextStyle displayL;
  final TextStyle displayM;
  final TextStyle titleL;
  final TextStyle titleM;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;

  /// Render with uppercase text; letter-spacing is already applied.
  final TextStyle overline;

  /// Caveat accent: visit dates, short personal notes, empty states only.
  final TextStyle handNote;

  /// Maps the scale onto Material roles so stock widgets inherit it.
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayL,
      displayMedium: displayM,
      headlineSmall: titleL,
      titleLarge: titleL,
      titleMedium: titleM,
      titleSmall: bodyStrong,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: bodyStrong,
      labelMedium: caption,
      labelSmall: overline,
    );
  }
}
