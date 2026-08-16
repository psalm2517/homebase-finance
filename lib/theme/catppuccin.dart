import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

/// The four Catppuccin flavors, in the order the project lists them:
/// lightest to darkest.
enum CatppuccinFlavor { latte, frappe, macchiato, mocha }

extension CatppuccinFlavorInfo on CatppuccinFlavor {
  /// Palette from the official package, so a palette update is a version
  /// bump rather than a hunt for hex codes.
  Flavor get palette => switch (this) {
        CatppuccinFlavor.latte => catppuccin.latte,
        CatppuccinFlavor.frappe => catppuccin.frappe,
        CatppuccinFlavor.macchiato => catppuccin.macchiato,
        CatppuccinFlavor.mocha => catppuccin.mocha,
      };

  String get label => switch (this) {
        CatppuccinFlavor.latte => 'Latte',
        CatppuccinFlavor.frappe => 'Frappé',
        CatppuccinFlavor.macchiato => 'Macchiato',
        CatppuccinFlavor.mocha => 'Mocha',
      };

  String get description => switch (this) {
        CatppuccinFlavor.latte => 'Light',
        CatppuccinFlavor.frappe => 'Dark, warm and muted',
        CatppuccinFlavor.macchiato => 'Dark, medium contrast',
        CatppuccinFlavor.mocha => 'Dark, highest contrast',
      };

  /// Latte is the only light flavor; the rest are dark. This decides text
  /// and icon contrast throughout Material.
  bool get isDark => this != CatppuccinFlavor.latte;

  /// A few accent colours for the swatch preview in Settings.
  List<Color> get swatch => [
        palette.mauve,
        palette.blue,
        palette.green,
        palette.peach,
        palette.red,
      ];

  /// Stable key for persistence — the enum name, so reordering the enum
  /// cannot silently change what a saved preference means.
  String get storageKey => name;

  static CatppuccinFlavor fromStorage(String? key) =>
      CatppuccinFlavor.values.firstWhere(
        (f) => f.name == key,
        orElse: () => CatppuccinFlavor.mocha, // default for new installs
      );
}

/// Builds the app theme for a flavor. Every colour comes from the palette,
/// so screens never need to know which flavor is active.
ThemeData themeFor(CatppuccinFlavor flavor) {
  final c = flavor.palette;
  final dark = flavor.isDark;

  // Cards must read as raised. In Catppuccin the ramp runs crust -> mantle
  // -> base -> surface0 -> surface1, so "raised" is a lighter step in a dark
  // flavor and the reverse in Latte. Using base as the page in dark flavors
  // and mantle in Latte keeps a real step between the page and what sits on
  // it, without going outside the palette.
  final pageColor = dark ? c.base : c.mantle;
  final cardColor = dark ? c.surface0 : c.base;
  final borderColor = dark ? c.surface1 : c.surface0;
  final onAccent = dark ? c.mantle : c.base;

  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: c.mauve,
    onPrimary: onAccent,
    primaryContainer: dark ? c.surface1 : c.surface0,
    onPrimaryContainer: c.text,
    secondary: c.blue,
    onSecondary: onAccent,
    secondaryContainer: dark ? c.surface1 : c.surface0,
    onSecondaryContainer: c.text,
    tertiary: c.teal,
    onTertiary: onAccent,
    error: c.red,
    onError: onAccent,
    errorContainer: c.red.withValues(alpha: dark ? 0.22 : 0.16),
    onErrorContainer: c.red,
    surface: pageColor,
    onSurface: c.text,
    surfaceContainerLowest: c.crust,
    surfaceContainerLow: c.mantle,
    surfaceContainer: cardColor,
    surfaceContainerHigh: dark ? c.surface0 : c.base,
    surfaceContainerHighest: c.surface1,
    onSurfaceVariant: c.subtext0,
    outline: borderColor,
    outlineVariant: borderColor.withValues(alpha: 0.5),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: pageColor,
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
      backgroundColor: dark ? c.mantle : c.base,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: borderColor)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? c.mantle : c.base,
      indicatorColor: c.mauve.withValues(alpha: 0.22),
      selectedIconTheme: IconThemeData(color: c.mauve),
      unselectedIconTheme: IconThemeData(color: c.subtext0),
      selectedLabelTextStyle:
          TextStyle(color: c.mauve, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: c.subtext0),
    ),
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
    dividerColor: borderColor,
    listTileTheme: ListTileThemeData(iconColor: c.subtext0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? c.base : c.mantle,
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
        borderSide: BorderSide(color: c.mauve, width: 2),
      ),
      helperMaxLines: 3,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor:
          dark ? c.mantle : c.surface0.withValues(alpha: 0.5),
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
      backgroundColor: dark ? c.surface1 : c.surface0,
      contentTextStyle: TextStyle(color: c.text),
      behavior: SnackBarBehavior.floating,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: dark ? c.surface1 : c.surface0,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: c.text, fontSize: 12),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: c.mauve,
      collapsedIconColor: c.subtext0,
      textColor: c.text,
      collapsedTextColor: c.text,
    ),
  );
}
