import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/repository.dart';
import 'theme/catppuccin.dart';

/// Master passphrase entered on the unlock screen (Step 4). The database
/// provider stays unusable until it's set.
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

/// The profile whose data is on screen. Null until login (Step 4).
final activeProfileIdProvider = StateProvider<int?>((ref) => null);

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
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary shell until Step 4 screens land.
class _PlaceholderHome extends ConsumerWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homebase'),
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark ? 'Switch to Latte' : 'Switch to Mocha',
            icon: Icon(mode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: const Center(child: Text('Schema ready — screens coming in Step 4')),
    );
  }
}
