import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catppuccin.dart';

/// Selected Catppuccin flavor, persisted on the device.
///
/// Deliberately in shared_preferences rather than a Drift table: this is a
/// preference belonging to this computer, not financial data. Keeping it out
/// of the database means restoring someone else's backup cannot silently
/// change your theme, and the backup file stays purely about money.
class FlavorController extends StateNotifier<CatppuccinFlavor> {
  FlavorController() : super(CatppuccinFlavor.mocha) {
    _load();
  }

  static const _key = 'catppuccin_flavor';
  static const _lastDarkKey = 'catppuccin_last_dark_flavor';

  /// Remembered so the light/dark toggle returns to the dark flavor you
  /// actually chose, rather than always snapping back to Mocha.
  CatppuccinFlavor _lastDark = CatppuccinFlavor.mocha;
  CatppuccinFlavor get lastDark => _lastDark;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastDark =
          CatppuccinFlavorInfo.fromStorage(prefs.getString(_lastDarkKey));
      state = CatppuccinFlavorInfo.fromStorage(prefs.getString(_key));
    } catch (_) {
      // Unreadable preferences should never stop the app starting; the
      // default flavor already applies.
    }
  }

  Future<void> select(CatppuccinFlavor flavor) async {
    state = flavor;
    if (flavor.isDark) _lastDark = flavor;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, flavor.storageKey);
      if (flavor.isDark) {
        await prefs.setString(_lastDarkKey, flavor.storageKey);
      }
    } catch (_) {
      // The choice still applies for this session even if it cannot be
      // written; better than refusing to change theme.
    }
  }

  /// Quick toggle: Latte when on a dark flavor, and back to whichever dark
  /// flavor was last in use.
  Future<void> toggleLightDark() =>
      select(state.isDark ? CatppuccinFlavor.latte : _lastDark);
}

final flavorProvider =
    StateNotifierProvider<FlavorController, CatppuccinFlavor>(
        (ref) => FlavorController());
