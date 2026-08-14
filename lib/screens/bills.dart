import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  /// Which month is on screen. Defaults to now, so the list is correct on
  /// launch and every bill shows unpaid again once a new month starts.
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: const Text('Add bill'),
      ),
      body: StreamBuilder<List<({Bill bill, bool paid})>>(
        stream:
            repo.watchBillsForMonth(profileId: profileId, month: _month),
        builder: (context, snap) {
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return Column(
              children: [
                _monthBar(context, unpaidCount: 0, totalCents: 0),
                const Expanded(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No bills yet',
                    message:
                        'Add recurring bills to track due dates and what is '
                        'still unpaid this month.',
                  ),
                ),
              ],
            );
          }
          final unpaid = rows.where((r) => !r.paid).toList();
          final totalCents = rows
              .where((r) => r.bill.recurring)
              .fold(0, (s, r) => s + r.bill.amountCents);
          final unpaidCents = unpaid.fold(0, (s, r) => s + r.bill.amountCents);
          final today = DateTime.now();

          return Column(
            children: [
              _monthBar(context,
                  unpaidCount: unpaid.length, totalCents: totalCents),
              Expanded(
                child: ListView(
                  padding: kPagePadding,
                  children: [
                    Wrap(spacing: 16, runSpacing: 16, children: [
                      StatCard(
                        label: 'Recurring total',
                        value: '${fmtCents(totalCents)} / mo',
                        icon: Icons.summarize_outlined,
                        color: scheme.secondary,
                      ),
                      StatCard(
                        label: 'Still unpaid',
                        value: fmtCents(unpaidCents),
                        icon: Icons.pending_actions_outlined,
                        color: unpaid.isEmpty ? scheme.primary : scheme.error,
                        note: unpaid.isEmpty
                            ? 'all paid'
                            : '${unpaid.length} of ${rows.length} left',
                      ),
                    ]),
                    kSectionGap,
                    SectionHeader('Bills',
                        icon: Icons.receipt_long_outlined,
                        info: const InfoButton(
                          title: 'How paid status works',
                          body: [
                            'Paid status is recorded against the month it '
                                'covers, not as a single on/off flag.',
                            'That means nothing to reset: on the 1st every '
                                'bill shows unpaid again automatically, and '
                                'past months keep their real history — step '
                                'back with the arrows to see them.',
                            'A due day later than a short month (the 31st in '
                                'February) is treated as the last day of '
                                'that month.',
                          ],
                        )),
                    for (final row in rows)
                      _billTile(context, row, today, scheme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _monthBar(BuildContext context,
      {required int unpaidCount, required int totalCents}) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1)),
            ),
            Text('${_monthNames[_month.month - 1]} ${_month.year}',
                style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              tooltip: 'Next month',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1)),
            ),
            if (!_isCurrentMonth)
              TextButton.icon(
                icon: const Icon(Icons.today, size: 16),
                label: const Text('This month'),
                onPressed: () {
                  final now = DateTime.now();
                  setState(() => _month = DateTime(now.year, now.month));
                },
              ),
            const Spacer(),
            Text(
              unpaidCount == 0
                  ? 'Everything paid'
                  : '$unpaidCount unpaid',
              style: TextStyle(
                  color: unpaidCount == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billTile(BuildContext context, ({Bill bill, bool paid}) row,
      DateTime today, ColorScheme scheme) {
    final b = row.bill;
    final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
    final dueDate = DateTime(
        _month.year, _month.month, b.dueDay > lastDay ? lastDay : b.dueDay);
    final overdue = !row.paid &&
        _month.year == today.year &&
        _month.month == today.month &&
        dueDate.isBefore(DateTime(today.year, today.month, today.day));
    final profileId = ref.read(activeProfileProvider)!.id;

    return Card(
      child: CheckboxListTile(
        value: row.paid,
        onChanged: (v) => ref.read(repositoryProvider).setBillPaid(
              profileId: profileId,
              billId: b.id,
              month: _month,
              paid: v ?? false,
            ),
        title: Text(b.name),
        subtitle: Row(
          children: [
            Icon(
                overdue
                    ? Icons.warning_amber_outlined
                    : Icons.event_outlined,
                size: 14,
                color: overdue ? scheme.error : null),
            const SizedBox(width: 4),
            Text(
              'Due ${_monthNames[dueDate.month - 1].substring(0, 3)} '
              '${dueDate.day}'
              '${overdue ? ' • overdue' : ''} • ${b.category}'
              '${b.recurring ? '' : ' • one-time'}',
              style: TextStyle(color: overdue ? scheme.error : null),
            ),
          ],
        ),
        secondary: SizedBox(
          width: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(fmtCents(b.amountCents),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _edit(b)),
              IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _delete(b)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Bill b) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${b.name}?'),
        content: const Text('Its payment history is deleted too.'),
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

  Future<void> _edit(Bill? existing) async {
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
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add bill' : 'Edit bill'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DialogField(name, 'Name', autofocus: true),
              DialogField(amount, 'Amount (\$)'),
              DialogField(dueDay, 'Due day (1-31)',
                  helper: 'Days past the end of a short month move to its '
                      'last day'),
              DialogField(category, 'Category'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring monthly'),
                value: recurring,
                onChanged: (v) => setLocal(() => recurring = v),
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
        ));
  }
}
