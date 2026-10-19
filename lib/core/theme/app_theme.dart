import 'package:flutter/material.dart';

import 'wander_palette.dart';
import 'wander_tokens.dart';
import 'wander_typography.dart';

/// Builds the Wanderboard [ThemeData] (DESIGN.md §10).
abstract final class AppTheme {
  static WanderTokens tokens({
    FontResolver fonts = const GoogleFontResolver(),
  }) {
    const colors = WanderColors(
      paper: WanderPalette.paper,
      card: WanderPalette.card,
      peach: WanderPalette.peach,
      apricot: WanderPalette.apricot,
      slate: WanderPalette.slate,
      mist: WanderPalette.mist,
      ink: WanderPalette.ink,
      inkMuted: WanderPalette.inkMuted,
      inkFaint: WanderPalette.inkFaint,
      line: WanderPalette.line,
      tape: WanderPalette.tape,
      polaroid: WanderPalette.polaroid,
      success: WanderPalette.success,
      error: WanderPalette.error,
      shadowTint: WanderPalette.shadowTint,
    );

    final gradients = WanderGradients(
      mistDawn: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [WanderPalette.dawnTop, WanderPalette.paper],
      ),
      mistLake: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [WanderPalette.mist, WanderPalette.slate],
      ),
      photoScrim: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          WanderPalette.ink.withValues(alpha: 0),
          WanderPalette.ink.withValues(alpha: 0.55),
        ],
      ),
    );

    return WanderTokens(
      colors: colors,
      gradients: gradients,
      shadowSoft: [
        BoxShadow(
          color: WanderPalette.shadowTint.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      shadowLift: [
        BoxShadow(
          color: WanderPalette.shadowTint.withValues(alpha: 0.16),
          blurRadius: 32,
          offset: const Offset(0, 14),
        ),
      ],
      text: WanderTypeScale.build(fonts, colors.ink),
    );
  }

  static ThemeData light({FontResolver fonts = const GoogleFontResolver()}) {
    final t = tokens(fonts: fonts);
    final c = t.colors;

    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: c.apricot,
      onPrimary: c.ink,
      primaryContainer: c.peach,
      onPrimaryContainer: c.ink,
      secondary: c.slate,
      onSecondary: c.card,
      tertiary: c.mist,
      onTertiary: c.ink,
      surface: c.card,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      outline: c.line,
      outlineVariant: c.line,
      error: c.error,
      onError: c.card,
      shadow: c.shadowTint,
    );

    OutlineInputBorder inputBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radii.sm),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.paper,
      canvasColor: c.paper,
      textTheme: t.text.toTextTheme(),
      splashFactory: NoSplash.splashFactory,
      extensions: [t],
      iconTheme: IconThemeData(color: c.ink, size: t.sizes.icon),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: t.text.titleL,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        hintStyle: t.text.body.copyWith(color: c.inkFaint),
        labelStyle: t.text.caption.copyWith(color: c.inkMuted),
        contentPadding: EdgeInsets.symmetric(
          horizontal: t.spacing.lg,
          vertical: t.spacing.md + t.spacing.xs,
        ),
        border: inputBorder(c.line, 1),
        enabledBorder: inputBorder(c.line, 1),
        focusedBorder: inputBorder(c.apricot, t.sizes.focusBorder),
        errorBorder: inputBorder(c.error, 1),
        focusedErrorBorder: inputBorder(c.error, t.sizes.focusBorder),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.ink,
        selectionColor: c.peach,
        selectionHandleColor: c.apricot,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.slate,
        contentTextStyle: t.text.bodyStrong.copyWith(color: c.card),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radii.sm),
        ),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        modalBackgroundColor: c.card,
        elevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radii.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radii.lg),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.card : c.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.apricot : c.line,
        ),
        trackOutlineColor: WidgetStatePropertyAll(c.line),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.ink,
        textColor: c.ink,
        titleTextStyle: t.text.body,
        subtitleTextStyle: t.text.caption.copyWith(color: c.inkMuted),
        contentPadding: EdgeInsets.symmetric(horizontal: t.spacing.lg),
      ),
    );
  }
}
