import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';

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
            return const EmptyState(
              icon: Icons.credit_card_outlined,
              title: 'No credit cards yet',
              message:
                  'Add a card to track its balance, utilization and fees.',
            );
          }
          return ListView(
            padding: kPagePadding,
            children: [
              for (final c in cards)
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.credit_card),
                    title: Text(c.name),
                    subtitle: Text(
                        '${fmtCents(c.balanceCents)} of ${fmtCents(c.creditLimitCents)}'),
                    trailing: Text('${c.apr.toStringAsFixed(2)}% APR'),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailRow('Balance', fmtCents(c.balanceCents)),
                      DetailRow('Limit', fmtCents(c.creditLimitCents)),
                      DetailRow(
                          'Utilization',
                          c.creditLimitCents == 0
                              ? '—'
                              : '${(c.balanceCents / c.creditLimitCents * 100).toStringAsFixed(1)}%'),
                      DetailRow('APR', '${c.apr.toStringAsFixed(2)}%'),
                      DetailRow('Annual fee', fmtCents(c.annualFeeCents)),
                      DetailRow('Monthly fee', fmtCents(c.monthlyFeeCents)),
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
              DialogField(name, 'Name'),
              DialogField(balance, 'Balance (\$)'),
              DialogField(limit, 'Credit limit (\$)'),
              DialogField(apr, 'APR (%)'),
              DialogField(annualFee, 'Annual fee (\$)'),
              DialogField(monthlyFee, 'Monthly fee (\$)'),
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

}
