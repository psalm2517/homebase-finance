import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
      body: StreamBuilder<List<CreditCard>>(
        stream: repo.watchCards(profileId: profileId),
        builder: (context, snap) {
          final cards = snap.data ?? [];
          if (cards.isEmpty) {
            return const Center(child: Text('No credit cards yet.'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final c in cards)
                Card(
                  child: ExpansionTile(
                    title: Text(c.name),
                    subtitle: Text(
                        '${fmtCents(c.balanceCents)} of ${fmtCents(c.creditLimitCents)}'),
                    trailing: Text('${c.apr.toStringAsFixed(2)}% APR'),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Balance', fmtCents(c.balanceCents)),
                      _row('Limit', fmtCents(c.creditLimitCents)),
                      _row(
                          'Utilization',
                          c.creditLimitCents == 0
                              ? '—'
                              : '${(c.balanceCents / c.creditLimitCents * 100).toStringAsFixed(1)}%'),
                      _row('APR', '${c.apr.toStringAsFixed(2)}%'),
                      _row('Annual fee', fmtCents(c.annualFeeCents)),
                      _row('Monthly fee', fmtCents(c.monthlyFeeCents)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                              onPressed: () => _edit(context, ref, c),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit')),
                          TextButton.icon(
                              onPressed: () => _delete(context, ref, c),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(width: 120, child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );

  Future<void> _delete(
      BuildContext context, WidgetRef ref, CreditCard c) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${c.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(repositoryProvider)
          .deleteCard(profileId: profileId, id: c.id);
    }
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, CreditCard? existing) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final name = TextEditingController(text: existing?.name);
    final balance = TextEditingController(
        text: existing == null ? '' : (existing.balanceCents / 100).toString());
    final limit = TextEditingController(
        text: existing == null
            ? ''
            : (existing.creditLimitCents / 100).toString());
    final apr =
        TextEditingController(text: existing?.apr.toString() ?? '');
    final annualFee = TextEditingController(
        text:
            existing == null ? '' : (existing.annualFeeCents / 100).toString());
    final monthlyFee = TextEditingController(
        text: existing == null
            ? ''
            : (existing.monthlyFeeCents / 100).toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add card' : 'Edit card'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(name, 'Name'),
              _field(balance, 'Balance (\$)'),
              _field(limit, 'Credit limit (\$)'),
              _field(apr, 'APR (%)'),
              _field(annualFee, 'Annual fee (\$)'),
              _field(monthlyFee, 'Monthly fee (\$)'),
            ],
          ),
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
    );
    if (saved != true || name.text.trim().isEmpty) return;
    await ref.read(repositoryProvider).upsertCard(CreditCardsCompanion(
          id: existing == null ? const Value.absent() : Value(existing.id),
          profileId: Value(profileId),
          name: Value(name.text.trim()),
          balanceCents: Value(parseDollarsToCents(balance.text) ?? 0),
          creditLimitCents: Value(parseDollarsToCents(limit.text) ?? 0),
          apr: Value(double.tryParse(apr.text) ?? 0),
          annualFeeCents: Value(parseDollarsToCents(annualFee.text) ?? 0),
          monthlyFeeCents: Value(parseDollarsToCents(monthlyFee.text) ?? 0),
        ));
  }

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
