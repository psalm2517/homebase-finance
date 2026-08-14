import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';

/// Master passphrase gate. On first run this passphrase creates the encrypted
/// database; afterwards a wrong passphrase fails to open it.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _unlock() async {
    final passphrase = _controller.text;
    if (passphrase.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    // Probe the passphrase against the database before committing it.
    final probe = AppDatabase(passphrase);
    try {
      await probe.select(probe.profiles).get();
      await probe.close();
      if (!mounted) return;
      ref.read(masterPassphraseProvider.notifier).state = passphrase;
    } catch (_) {
      await probe.close();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Wrong passphrase — the database could not be unlocked.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.home_outlined,
                      size: 56, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Homebase',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    obscureText: true,
                    autofocus: true,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: 'Master passphrase',
                      helperText:
                          'First run? This passphrase will encrypt your data.',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _unlock,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
