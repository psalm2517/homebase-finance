import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add loan'),
      ),
      body: StreamBuilder<List<Loan>>(
        stream: repo.watchLoans(profileId: profileId),
        builder: (context, snap) {
          final loans = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (loans.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No loans yet.')))
              else ...[
                _PayoffCalculator(loans: loans),
                const SizedBox(height: 16),
                for (final l in loans)
                  Card(
                    child: ExpansionTile(
                      title: Text(l.name),
                      subtitle: LinearProgressIndicator(
                        value: l.originalAmountCents == 0
                            ? 0
                            : 1 - l.balanceCents / l.originalAmountCents,
                      ),
                      trailing: Text(fmtCents(l.balanceCents)),
                      childrenPadding: const EdgeInsets.all(16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('Balance', fmtCents(l.balanceCents)),
                        _row('Original', fmtCents(l.originalAmountCents)),
                        _row('APR', '${l.apr.toStringAsFixed(2)}%'),
                        _row('Monthly payment',
                            fmtCents(l.monthlyPaymentCents)),
                        const SizedBox(height: 8),
                        Row(children: [
                          TextButton.icon(
                              onPressed: () => _edit(context, ref, l),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit')),
                          TextButton.icon(
                              onPressed: () => _delete(context, ref, l),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete')),
                        ]),
                      ],
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(width: 140, child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );

  Future<void> _delete(BuildContext context, WidgetRef ref, Loan l) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${l.name}?'),
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
          .deleteLoan(profileId: profileId, id: l.id);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Loan? existing) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final name = TextEditingController(text: existing?.name);
    final balance = TextEditingController(
        text: existing == null ? '' : (existing.balanceCents / 100).toString());
    final original = TextEditingController(
        text: existing == null
            ? ''
            : (existing.originalAmountCents / 100).toString());
    final apr = TextEditingController(text: existing?.apr.toString() ?? '');
    final payment = TextEditingController(
        text: existing == null
            ? ''
            : (existing.monthlyPaymentCents / 100).toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add loan' : 'Edit loan'),
        content: SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(name, 'Name'),
            _field(balance, 'Balance (\$)'),
            _field(original, 'Original amount (\$)'),
            _field(apr, 'APR (%)'),
            _field(payment, 'Monthly payment (\$)'),
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
    );
    if (saved != true || name.text.trim().isEmpty) return;
    await ref.read(repositoryProvider).upsertLoan(LoansCompanion(
          id: existing == null ? const Value.absent() : Value(existing.id),
          profileId: Value(profileId),
          name: Value(name.text.trim()),
          balanceCents: Value(parseDollarsToCents(balance.text) ?? 0),
          originalAmountCents: Value(parseDollarsToCents(original.text) ?? 0),
          apr: Value(double.tryParse(apr.text) ?? 0),
          monthlyPaymentCents: Value(parseDollarsToCents(payment.text) ?? 0),
        ));
  }

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
            controller: c,
            decoration: InputDecoration(
                labelText: label, border: const OutlineInputBorder())),
      );
}

/// Snowball (smallest balance first) vs avalanche (highest APR first).
class _PayoffCalculator extends StatefulWidget {
  const _PayoffCalculator({required this.loans});
  final List<Loan> loans;

  @override
  State<_PayoffCalculator> createState() => _PayoffCalculatorState();
}

class _PayoffCalculatorState extends State<_PayoffCalculator> {
  final _extra = TextEditingController(text: '0');

  ({int months, int interestCents})? _simulate(
      List<Loan> loans, int extraCents, int Function(Loan) priority) {
    final balances = {for (final l in loans) l.id: l.balanceCents};
    final order = [...loans]
      ..sort((a, b) => priority(a).compareTo(priority(b)));
    var months = 0;
    var interest = 0;
    while (balances.values.any((b) => b > 0) && months < 1200) {
      months++;
      // Accrue interest, make minimum payments, then throw extra (plus
      // freed-up minimums of paid-off loans) at the priority target.
      var budget = extraCents;
      for (final l in loans) {
        final bal = balances[l.id]!;
        if (bal <= 0) {
          budget += l.monthlyPaymentCents;
          continue;
        }
        final accrued = (bal * l.apr / 100 / 12).round();
        interest += accrued;
        balances[l.id] = bal + accrued - l.monthlyPaymentCents;
        if (balances[l.id]! < 0) {
          budget += -balances[l.id]!;
          balances[l.id] = 0;
        }
      }
      for (final l in order) {
        if (budget <= 0) break;
        final bal = balances[l.id]!;
        if (bal <= 0) continue;
        final pay = bal < budget ? bal : budget;
        balances[l.id] = bal - pay;
        budget -= pay;
      }
      // Detect non-amortizing debt (payment below interest): bail out.
      if (months > 1 &&
          balances.values.every((b) => b > 0) &&
          loans.every((l) =>
              l.monthlyPaymentCents + extraCents <=
              (balances[l.id]! * l.apr / 100 / 12).round())) {
        return null;
      }
    }
    if (months >= 1200) return null;
    return (months: months, interestCents: interest);
  }

  @override
  Widget build(BuildContext context) {
    final extraCents = parseDollarsToCents(_extra.text) ?? 0;
    final snowball = _simulate(
        widget.loans, extraCents, (l) => l.balanceCents);
    final avalanche = _simulate(
        widget.loans, extraCents, (l) => -(l.apr * 1000).round());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payoff calculator',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _extra,
                decoration: const InputDecoration(
                    labelText: 'Extra per month (\$)',
                    border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _strategy(context, 'Snowball',
                        'Smallest balance first', snowball)),
                const SizedBox(width: 12),
                Expanded(
                    child: _strategy(context, 'Avalanche',
                        'Highest APR first', avalanche)),
              ],
            ),
            if (snowball != null && avalanche != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  avalanche.interestCents < snowball.interestCents
                      ? 'Avalanche saves ${fmtCents(snowball.interestCents - avalanche.interestCents)} in interest.'
                      : 'Both strategies cost about the same here.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _strategy(BuildContext context, String name, String detail,
      ({int months, int interestCents})? result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          if (result == null)
            const Text('Never pays off — payments don\'t cover interest.')
          else ...[
            Text(
                '${result.months ~/ 12}y ${result.months % 12}m to debt-free'),
            Text('${fmtCents(result.interestCents)} total interest'),
          ],
        ],
      ),
    );
  }
}
