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
  final onPrimary = brightness == Brightness.dark ? mantle : Colors.white;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onPrimary,
    error: error,
    onError: onPrimary,
    surface: base,
    onSurface: text,
    surfaceContainerHighest: surface0,
    outline: surface1,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: base,
    cardTheme: CardThemeData(color: mantle, elevation: 0),
    appBarTheme: AppBarTheme(backgroundColor: mantle, foregroundColor: text),
    dividerColor: surface1,
    listTileTheme: ListTileThemeData(iconColor: subtext),
  );
}
