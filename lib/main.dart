import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/repository.dart';
import 'screens/profile_picker.dart';
import 'screens/shell.dart';
import 'screens/unlock.dart';
import 'theme/catppuccin.dart';

/// Master passphrase entered on the unlock screen. The database provider
/// stays unusable until it's set.
final masterPassphraseProvider = StateProvider<String?>((ref) => null);

final databaseProvider = Provider<AppDatabase>((ref) {
  final passphrase = ref.watch(masterPassphraseProvider);
  if (passphrase == null) {
    throw StateError('Database accessed before unlock');
  }
  final db = AppDatabase(passphrase);
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<HomebaseRepository>(
    (ref) => HomebaseRepository(ref.watch(databaseProvider)));

/// Mocha (dark) by default; toggled to Latte from the UI.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Who authenticated at the profile picker. Determines admin powers.
final loggedInProfileProvider = StateProvider<Profile?>((ref) => null);

/// Whose data is on screen. Same as logged-in for non-admins; admins can
/// switch it. Reset on login change.
final activeProfileProvider = StateProvider<Profile?>((ref) {
  return ref.watch(loggedInProfileProvider);
});

void main() {
  runApp(const ProviderScope(child: HomebaseApp()));
}

class HomebaseApp extends ConsumerWidget {
  const HomebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Homebase',
      theme: latteTheme(),
      darkTheme: mochaTheme(),
      themeMode: mode,
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(masterPassphraseProvider) != null;
    if (!unlocked) return const UnlockScreen();
    final profile = ref.watch(loggedInProfileProvider);
    if (profile == null) return const ProfilePickerScreen();
    return const AppShell();
  }
}
