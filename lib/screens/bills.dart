import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add bill'),
      ),
      body: StreamBuilder<List<Bill>>(
        stream: repo.watchBills(profileId: profileId),
        builder: (context, snap) {
          final bills = (snap.data ?? [])
            ..sort((a, b) => a.dueDay.compareTo(b.dueDay));
          if (bills.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No bills yet',
              message:
                  'Add recurring bills to track due dates and what is still '
                  'unpaid this month.',
            );
          }
          final totalCents = bills
              .where((b) => b.recurring)
              .fold(0, (s, b) => s + b.amountCents);
          final unpaid = bills.where((b) => !b.paidThisMonth).length;
          return ListView(
            padding: kPagePadding,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: Text(
                      'Recurring total: ${fmtCents(totalCents)} / month'),
                  subtitle: Text('$unpaid still unpaid this month'),
                  trailing: TextButton(
                    onPressed: () => _resetMonth(ref, bills),
                    child: const Text('New month: reset paid'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final b in bills)
                Card(
                  child: CheckboxListTile(
                    value: b.paidThisMonth,
                    onChanged: (v) => ref.read(repositoryProvider).setBillPaid(
                        profileId: profileId, id: b.id, paid: v ?? false),
                    title: Text(b.name),
                    subtitle: Text(
                        'Due day ${b.dueDay} • ${b.category}${b.recurring ? ' • recurring' : ' • one-time'}'),
                    secondary: SizedBox(
                      width: 170,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(fmtCents(b.amountCents)),
                          IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _edit(context, ref, b)),
                          IconButton(
                              icon:
                                  const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => _delete(context, ref, b)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _resetMonth(WidgetRef ref, List<Bill> bills) async {
    final repo = ref.read(repositoryProvider);
    final profileId = ref.read(activeProfileProvider)!.id;
    for (final b in bills.where((b) => b.paidThisMonth)) {
      await repo.setBillPaid(profileId: profileId, id: b.id, paid: false);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Bill b) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${b.name}?'),
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
          .deleteBill(profileId: profileId, id: b.id);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Bill? existing) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final name = TextEditingController(text: existing?.name);
    final amount = TextEditingController(
        text: existing == null ? '' : (existing.amountCents / 100).toString());
    final dueDay =
        TextEditingController(text: existing?.dueDay.toString() ?? '');
    final category = TextEditingController(text: existing?.category ?? '');
    var recurring = existing?.recurring ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add bill' : 'Edit bill'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DialogField(name, 'Name'),
              DialogField(amount, 'Amount (\$)'),
              DialogField(dueDay, 'Due day (1-31)'),
              DialogField(category, 'Category'),
              SwitchListTile(
                title: const Text('Recurring monthly'),
                value: recurring,
                onChanged: (v) => setState(() => recurring = v),
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
    await ref.read(repositoryProvider).upsertBill(BillsCompanion(
          id: existing == null ? const Value.absent() : Value(existing.id),
          profileId: Value(profileId),
          name: Value(name.text.trim()),
          amountCents: Value(parseDollarsToCents(amount.text) ?? 0),
          dueDay: Value((int.tryParse(dueDay.text) ?? 1).clamp(1, 31)),
          category: Value(
              category.text.trim().isEmpty ? 'Other' : category.text.trim()),
          recurring: Value(recurring),
          paidThisMonth: Value(existing?.paidThisMonth ?? false),
        ));
  }

}
