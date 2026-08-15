import 'package:flutter/material.dart';

/// Catppuccin palettes — Mocha (dark, default) and Latte (light toggle).
/// Colors from https://catppuccin.com/palette
class Mocha {
  static const base = Color(0xFF1E1E2E);
  static const mantle = Color(0xFF181825);
  static const crust = Color(0xFF11111B);
  static const surface0 = Color(0xFF313244);
  static const surface1 = Color(0xFF45475A);
  static const text = Color(0xFFCDD6F4);
  static const subtext0 = Color(0xFFA6ADC8);
  static const mauve = Color(0xFFCBA6F7);
  static const blue = Color(0xFF89B4FA);
  static const green = Color(0xFFA6E3A1);
  static const red = Color(0xFFF38BA8);
  static const peach = Color(0xFFFAB387);
  static const yellow = Color(0xFFF9E2AF);
  static const teal = Color(0xFF94E2D5);
  static const lavender = Color(0xFFB4BEFE);
}

class Latte {
  static const base = Color(0xFFEFF1F5);
  static const mantle = Color(0xFFE6E9EF);
  static const crust = Color(0xFFDCE0E8);
  static const surface0 = Color(0xFFCCD0DA);
  static const surface1 = Color(0xFFBCC0CC);
  static const text = Color(0xFF4C4F69);
  static const subtext0 = Color(0xFF6C6F85);
  static const mauve = Color(0xFF8839EF);
  static const blue = Color(0xFF1E66F5);
  static const green = Color(0xFF40A02B);
  static const red = Color(0xFFD20F39);
  static const peach = Color(0xFFFE640B);
  static const yellow = Color(0xFFDF8E1D);
  static const teal = Color(0xFF179299);
  static const lavender = Color(0xFF7287FD);
}

ThemeData mochaTheme() => _theme(
      brightness: Brightness.dark,
      base: Mocha.base,
      mantle: Mocha.mantle,
      surface0: Mocha.surface0,
      surface1: Mocha.surface1,
      text: Mocha.text,
      subtext: Mocha.subtext0,
      primary: Mocha.mauve,
      secondary: Mocha.blue,
      error: Mocha.red,
    );

ThemeData latteTheme() => _theme(
      brightness: Brightness.light,
      base: Latte.base,
      mantle: Latte.mantle,
      surface0: Latte.surface0,
      surface1: Latte.surface1,
      text: Latte.text,
      subtext: Latte.subtext0,
      primary: Latte.mauve,
      secondary: Latte.blue,
      error: Latte.red,
    );

ThemeData _theme({
  required Brightness brightness,
  required Color base,
  required Color mantle,
  required Color surface0,
  required Color surface1,
  required Color text,
  required Color subtext,
  required Color primary,
  required Color secondary,
  required Color error,
}) {
  final dark = brightness == Brightness.dark;
  final onPrimary = dark ? mantle : Colors.white;

  // Cards need to read as raised. In Catppuccin the palette runs from crust
  // (darkest) up through surface1, so "raised" means a lighter colour in
  // Mocha and a lighter one in Latte too — which lands on opposite sides of
  // `base`. Using base as the page in dark mode and mantle in light mode
  // keeps a real step between the page and the things sitting on it,
  // without inventing any colours outside the palette.
  final pageColor = dark ? base : mantle;
  final cardColor = dark ? surface0 : base;
  final borderColor = dark ? surface1 : surface0;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: dark ? surface1 : surface0,
    onPrimaryContainer: text,
    secondary: secondary,
    onSecondary: onPrimary,
    secondaryContainer: dark ? surface1 : surface0,
    onSecondaryContainer: text,
    error: error,
    onError: onPrimary,
    errorContainer: error.withValues(alpha: dark ? 0.22 : 0.16),
    onErrorContainer: error,
    surface: pageColor,
    onSurface: text,
    surfaceContainerLowest: dark ? mantle : mantle,
    surfaceContainerLow: dark ? base : base,
    surfaceContainer: cardColor,
    surfaceContainerHigh: dark ? surface0 : base,
    surfaceContainerHighest: surface1,
    onSurfaceVariant: subtext,
    outline: borderColor,
    outlineVariant: borderColor.withValues(alpha: 0.5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: pageColor,
    // A hairline border does most of the work of separating a card from the
    // page, and reads clearly in both themes without a drop shadow.
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor.withValues(alpha: 0.9)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? mantle : base,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: borderColor)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? mantle : base,
      indicatorColor: primary.withValues(alpha: 0.22),
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: subtext),
      selectedLabelTextStyle:
          TextStyle(color: primary, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: subtext),
    ),
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
    dividerColor: borderColor,
    listTileTheme: ListTileThemeData(iconColor: subtext),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? base : mantle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      helperMaxLines: 3,
    ),
    // Progress bars were washing out against the card behind them.
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: dark ? mantle : surface0.withValues(alpha: 0.5),
      linearMinHeight: 6,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? surface1 : surface0,
      contentTextStyle: TextStyle(color: text),
      behavior: SnackBarBehavior.floating,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: dark ? surface1 : surface0,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: text, fontSize: 12),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: primary,
      collapsedIconColor: subtext,
      textColor: text,
      collapsedTextColor: text,
    ),
  );
}
