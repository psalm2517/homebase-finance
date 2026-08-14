import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/pin.dart';

/// First run: create the two profiles. After that: pick a profile and enter
/// its PIN (if set). Non-admins land straight in their own data; the
/// visibility rule lives in AppShell (only admins get a switcher).
class ProfilePickerScreen extends ConsumerWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    return Scaffold(
      body: FutureBuilder(
        future: repo.allProfiles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profiles = snapshot.data!;
          if (profiles.isEmpty) return const _FirstRunSetup();
          return _Picker(profiles: profiles);
        },
      ),
    );
  }
}

class _Picker extends ConsumerWidget {
  const _Picker({required this.profiles});
  final List<Profile> profiles;

  Future<void> _select(
      BuildContext context, WidgetRef ref, Profile profile) async {
    if (profile.pinHash != null) {
      final ok = await _askPin(context, profile);
      if (!ok) return;
    }
    ref.read(loggedInProfileProvider.notifier).state = profile;
  }

  Future<bool> _askPin(BuildContext context, Profile profile) async {
    final controller = TextEditingController();
    String? error;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('PIN for ${profile.name}'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(labelText: 'PIN', errorText: error),
            onSubmitted: (_) {
              if (verifyPin(controller.text, profile.pinHash!)) {
                Navigator.pop(context, true);
              } else {
                setState(() => error = 'Wrong PIN');
              }
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (verifyPin(controller.text, profile.pinHash!)) {
                  Navigator.pop(context, true);
                } else {
                  setState(() => error = 'Wrong PIN');
                }
              },
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Who is this?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final p in profiles)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _select(context, ref, p),
                    child: Card(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              child: Text(p.name.characters.first,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(height: 12),
                            Text(p.name,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            if (p.pinHash != null)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(Icons.lock_outline, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Creates exactly two profiles: the admin and the regular one.
class _FirstRunSetup extends ConsumerStatefulWidget {
  const _FirstRunSetup();

  @override
  ConsumerState<_FirstRunSetup> createState() => _FirstRunSetupState();
}

class _FirstRunSetupState extends ConsumerState<_FirstRunSetup> {
  final _adminName = TextEditingController();
  final _adminPin = TextEditingController();
  final _memberName = TextEditingController();
  final _memberPin = TextEditingController();
  bool _busy = false;

  Future<void> _create() async {
    if (_adminName.text.trim().isEmpty || _memberName.text.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    await repo.createProfile(ProfilesCompanion.insert(
      name: _adminName.text.trim(),
      isAdmin: const Value(true),
      pinHash: Value(
          _adminPin.text.isEmpty ? null : hashPin(_adminPin.text)),
    ));
    await repo.createProfile(ProfilesCompanion.insert(
      name: _memberName.text.trim(),
      pinHash: Value(
          _memberPin.text.isEmpty ? null : hashPin(_memberPin.text)),
    ));
    // Re-enter the picker by rebuilding from _Root.
    if (!mounted) return;
    final profiles = await repo.allProfiles();
    if (!mounted) return;
    ref.read(loggedInProfileProvider.notifier).state =
        profiles.firstWhere((p) => p.isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Set up profiles',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Two profiles: you (admin) and one member.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                TextField(
                    controller: _adminName,
                    decoration: const InputDecoration(
                        labelText: 'Your name (admin)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: _adminPin,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Your PIN (optional)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 20),
                TextField(
                    controller: _memberName,
                    decoration: const InputDecoration(
                        labelText: 'Member name',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: _memberPin,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Member PIN (optional)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _create,
                  child: const Text('Create profiles'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
