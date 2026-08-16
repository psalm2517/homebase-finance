import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/notifications.dart';
import 'data/repository.dart';
import 'screens/profile_picker.dart';
import 'screens/shell.dart';
import 'theme/catppuccin.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: HomebaseApp()));
}

class HomebaseApp extends ConsumerWidget {
  const HomebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Homebase Finance',
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
    final profile = ref.watch(loggedInProfileProvider);
    if (profile == null) return const ProfilePickerScreen();
    return const AppShell();
  }
}
