import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/pin.dart';

/// Admin-only: add, rename, re-PIN, or remove profiles. Non-admins never
/// reach this screen — it isn't in their navigation at all.
class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  late Future<List<Profile>> _profiles;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _profiles = ref.read(repositoryProvider).allProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(loggedInProfileProvider)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add profile'),
      ),
      body: FutureBuilder<List<Profile>>(
        future: _profiles,
        builder: (context, snap) {
          final profiles = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Profiles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                  'Each profile has its own cards, loans, bills, budget and '
                  'paychecks. Admins can view any profile; everyone else sees '
                  'only their own.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              for (final p in profiles)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(p.name.characters.first.toUpperCase())),
                    title: Text(p.name),
                    subtitle: Text([
                      p.isAdmin ? 'Admin' : 'Member',
                      if (p.pinHash != null) 'PIN set' else 'No PIN',
                      if (p.id == loggedIn.id) 'signed in',
                    ].join(' • ')),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _edit(p)),
                      IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed:
                              p.id == loggedIn.id ? null : () => _delete(p)),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(Profile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${p.name}?'),
        content: const Text(
            'This permanently removes the profile and all of its cards, '
            'loans, bills, budget entries and paychecks. This cannot be '
            'undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete everything')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(repositoryProvider).deleteProfile(id: p.id);
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _edit(Profile? existing) async {
    final name = TextEditingController(text: existing?.name);
    final pin = TextEditingController();
    var isAdmin = existing?.isAdmin ?? false;
    var clearPin = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add profile' : 'Edit profile'),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                controller: pin,
                obscureText: true,
                enabled: !clearPin,
                decoration: InputDecoration(
                  labelText: existing == null
                      ? 'PIN (optional)'
                      : 'New PIN (leave blank to keep current)',
                  border: const OutlineInputBorder(),
                ),
              ),
              if (existing?.pinHash != null)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remove PIN'),
                  value: clearPin,
                  onChanged: (v) => setLocal(() => clearPin = v ?? false),
                ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Admin'),
                subtitle: const Text('Can view and switch into any profile'),
                value: isAdmin,
                onChanged: (v) => setLocal(() => isAdmin = v),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true || name.text.trim().isEmpty) return;
    final repo = ref.read(repositoryProvider);
    if (existing == null) {
      await repo.createProfile(ProfilesCompanion.insert(
        name: name.text.trim(),
        isAdmin: Value(isAdmin),
        pinHash: Value(pin.text.isEmpty ? null : hashPin(pin.text)),
      ));
    } else {
      await repo.updateProfile(existing.copyWith(
        name: name.text.trim(),
        isAdmin: isAdmin,
        pinHash: Value(clearPin
            ? null
            : pin.text.isEmpty
                ? existing.pinHash
                : hashPin(pin.text)),
      ));
    }
    if (!mounted) return;
    setState(_reload);
  }
}
