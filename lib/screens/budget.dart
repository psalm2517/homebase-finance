import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';
import 'accounts.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEntry(context),
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
      ),
      body: StreamBuilder<List<BudgetEntry>>(
        stream: repo.watchBudgetForMonth(profileId: profileId, month: _month),
        builder: (context, entriesSnap) {
          return StreamBuilder<List<BudgetTarget>>(
            stream: repo.watchBudgetTargets(profileId: profileId),
            builder: (context, targetsSnap) {
              return StreamBuilder<int>(
                stream: repo.watchMonthlyIncomeCents(profileId: profileId),
                builder: (context, schedIncomeSnap) {
                  return StreamBuilder<int>(
                    stream: repo.watchMonthlyBillsCents(profileId: profileId),
                    builder: (context, billsTotalSnap) {
                      return StreamBuilder<int>(
                        stream: repo.watchMonthlyCardFeesCents(
                            profileId: profileId),
                        builder: (context, feesSnap) {
                          final entries = entriesSnap.data ?? [];
                          final targets = targetsSnap.data ?? [];
                          final schedIncome = schedIncomeSnap.data ?? 0;
                          final billsTotal = billsTotalSnap.data ?? 0;
                          final fees = feesSnap.data ?? 0;
                          return _buildBody(context, entries, targets,
                              schedIncome, billsTotal, fees, scheme);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      List<BudgetEntry> entries,
      List<BudgetTarget> targets,
      int schedIncomeCents,
      int billsTotalCents,
      int cardFeesCents,
      ColorScheme scheme) {
    final income = entries
        .where((e) => e.type == EntryType.income)
        .fold(0, (s, e) => s + e.amountCents);
    final expenses = entries
        .where((e) => e.type == EntryType.expense)
        .fold(0, (s, e) => s + e.amountCents);
    final spentByCategory = <String, int>{};
    for (final e in entries.where((e) => e.type == EntryType.expense)) {
      spentByCategory[e.category] =
          (spentByCategory[e.category] ?? 0) + e.amountCents;
    }
    final categories = {
      ...spentByCategory.keys,
      ...targets.map((t) => t.category)
    }.toList()
      ..sort();

    return SingleChildScrollView(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() =>
                      _month = DateTime(_month.year, _month.month - 1))),
              Text(
                  '${_month.year}-${_month.month.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() =>
                      _month = DateTime(_month.year, _month.month + 1))),
              const Spacer(),
              TextButton.icon(
                  onPressed: () => _manageTargets(context),
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Targets')),
              TextButton.icon(
                  onPressed: () => _manageRules(context),
                  icon: const Icon(Icons.rule),
                  label: const Text('Rules')),
              const InfoButton(
                title: 'Auto-categorization rules',
                body: [
                  'Rules fill in the category for you as you type a new '
                      'entry, so you are not picking one every time.',
                  'A description rule matches when the text you type contains '
                      'the pattern, ignoring capitalization — a rule for '
                      '"coffee" catches "Coffee Lab" and "COFFEE #12".',
                  'An amount rule matches an exact dollar figure, which is '
                      'handy for fixed subscriptions like 9.99.',
                  'Rules are checked in order and the first match wins. You '
                      'can always type over the category it picked.',
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 16, runSpacing: 16, children: [
            StatCard(
                label: 'Income (entries)',
                value: fmtCents(income),
                icon: Icons.arrow_downward,
                color: scheme.primary),
            StatCard(
                label: 'Expenses',
                value: fmtCents(expenses),
                icon: Icons.arrow_upward,
                color: scheme.error),
            StatCard(
                label: 'Net',
                value: fmtCents(income - expenses),
                icon: Icons.balance,
                color: income >= expenses ? scheme.primary : scheme.error),
          ]),
          const SizedBox(height: 24),
          const SectionHeader('Monthly plan (after-tax income vs bills)',
              icon: Icons.calculate_outlined,
              info: InfoButton(
                title: 'Monthly plan',
                body: [
                  'A quick sanity check: what you expect to earn in a normal '
                      'month, minus what your recurring bills cost, leaves '
                      'the amount you actually have to work with.',
                  'Income comes from your paycheck schedules on the Paychecks '
                      'screen, normalized to a month — a bi-weekly schedule '
                      'is multiplied by 26 and divided by 12, weekly by 52 '
                      'and divided by 12. That is why it may not match a '
                      'single paycheck times two.',
                  'Bills that are not monthly are spread across their term, '
                      'so an annual subscription counts as a twelfth each '
                      'month — that is what you need to set aside.',
                  'Credit card fees count too: any monthly fee in full, plus '
                      'a twelfth of each annual fee.',
                  'Every amount you enter in Homebase is after tax, so this '
                      'is take-home money.',
                ],
              )),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _planRow('Expected monthly income (from paycheck schedules)',
                      fmtCents(schedIncomeCents)),
                  _planRow('Recurring bills (annual and quarterly spread '
                      'across their term)',
                      '-${fmtCents(billsTotalCents)}'),
                  _planRow('Credit card fees (monthly, plus a twelfth of '
                      'each annual fee)',
                      '-${fmtCents(cardFeesCents)}'),
                  const Divider(),
                  _planRow(
                      'Left to budget',
                      fmtCents(schedIncomeCents -
                          billsTotalCents -
                          cardFeesCents),
                      bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Spending by category',
              icon: Icons.donut_small_outlined,
              info: InfoButton(
                title: 'Spending vs targets',
                body: [
                  'Each category shows what you have spent this month against '
                      'the target you set, with the bar turning red once you '
                      'go over.',
                  'There is no refresh schedule — the moment you add an '
                      'expense the bar moves. Only the current calendar '
                      'month counts, so spending resets on the 1st while '
                      'your targets stay.',
                  'Set targets with the Targets button above.',
                ],
              )),
          if (categories.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.donut_small_outlined,
                  title: 'Nothing categorized yet',
                  message:
                      'Add expenses, or set category targets, to track '
                      'spending against a budget.',
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final cat in categories)
                    _categoryTile(context, cat, spentByCategory[cat] ?? 0,
                        _targetFor(targets, cat), scheme),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader('Entries', icon: Icons.list_alt_outlined),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No entries this month',
                  message:
                      'Add income and expenses to build this month\'s picture.',
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final e in entries)
                    ListTile(
                      leading: Icon(
                          e.type == EntryType.income
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: e.type == EntryType.income
                              ? scheme.primary
                              : scheme.error),
                      title: Text(e.description ?? e.category),
                      subtitle: Text(
                          '${e.category} • ${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '${e.type == EntryType.income ? '+' : '-'}${fmtCents(e.amountCents)}'),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => ref
                                .read(repositoryProvider)
                                .deleteBudgetEntry(
                                    profileId: ref
                                        .read(activeProfileProvider)!
                                        .id,
                                    id: e.id),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int? _targetFor(List<BudgetTarget> targets, String category) {
    for (final t in targets) {
      if (t.category == category) return t.monthlyTargetCents;
    }
    return null;
  }

  Widget _planRow(String label, String value, {bool bold = false}) {
    final style =
        bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _categoryTile(BuildContext context, String category, int spentCents,
      int? targetCents, ColorScheme scheme) {
    final over = targetCents != null && spentCents > targetCents;
    return ListTile(
      title: Text(category),
      subtitle: targetCents == null
          ? null
          : LinearProgressIndicator(
              value: (spentCents / targetCents).clamp(0.0, 1.0),
              color: over ? scheme.error : scheme.primary,
            ),
      trailing: Text(
        targetCents == null
            ? fmtCents(spentCents)
            : '${fmtCents(spentCents)} / ${fmtCents(targetCents)}',
        style: TextStyle(color: over ? scheme.error : null),
      ),
    );
  }

  Future<void> _addEntry(BuildContext context) async {
    final repo = ref.read(repositoryProvider);
    final profileId = ref.read(activeProfileProvider)!.id;
    final description = TextEditingController();
    final amount = TextEditingController();
    final category = TextEditingController();
    var type = EntryType.expense;
    var autoCategorized = false;
    int? accountId;
    final accounts = await repo.watchAccounts(profileId: profileId).first;
    if (!context.mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add entry'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SegmentedButton<EntryType>(
                segments: const [
                  ButtonSegment(
                      value: EntryType.expense, label: Text('Expense')),
                  ButtonSegment(
                      value: EntryType.income, label: Text('Income')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                onChanged: (text) async {
                  final match = await repo.categorize(
                      profileId: profileId,
                      description: text,
                      amountCents: parseDollarsToCents(amount.text));
                  if (match != null &&
                      (category.text.isEmpty || autoCategorized)) {
                    setState(() {
                      category.text = match;
                      autoCategorized = true;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: amount,
                  decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: category,
                  onChanged: (_) => autoCategorized = false,
                  decoration: InputDecoration(
                      labelText: 'Category',
                      helperText:
                          autoCategorized ? 'Auto-categorized by rule' : null,
                      border: const OutlineInputBorder())),
              if (accounts.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: accountId,
                  decoration: const InputDecoration(
                      labelText: 'Account (optional)',
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Not linked')),
                    for (final a in accounts)
                      DropdownMenuItem(
                        value: a.id,
                        child: Row(children: [
                          Icon(accountIcon(a.type), size: 16),
                          const SizedBox(width: 8),
                          Text(a.name),
                        ]),
                      ),
                  ],
                  onChanged: (v) => setState(() => accountId = v),
                ),
              ],
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
    if (saved != true) return;
    final cents = parseDollarsToCents(amount.text);
    if (cents == null) return;
    await repo.addBudgetEntry(BudgetEntriesCompanion.insert(
      profileId: profileId,
      date: DateTime.now(),
      amountCents: cents,
      type: type,
      category: Value(
          category.text.trim().isEmpty ? 'Other' : category.text.trim()),
      description: Value(
          description.text.trim().isEmpty ? null : description.text.trim()),
      accountId: Value(accountId),
    ));
  }

  Future<void> _manageTargets(BuildContext context) async {
    final repo = ref.read(repositoryProvider);
    final profileId = ref.read(activeProfileProvider)!.id;
    final category = TextEditingController();
    final target = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Budget targets'),
        content: SizedBox(
          width: 420,
          height: 400,
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: category,
                      decoration:
                          const InputDecoration(labelText: 'Category'))),
              const SizedBox(width: 8),
              SizedBox(
                  width: 110,
                  child: TextField(
                      controller: target,
                      decoration:
                          const InputDecoration(labelText: 'Target \$'))),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final cents = parseDollarsToCents(target.text);
                  if (category.text.trim().isEmpty || cents == null) return;
                  await repo.upsertBudgetTarget(
                      BudgetTargetsCompanion.insert(
                          profileId: profileId,
                          category: category.text.trim(),
                          monthlyTargetCents: cents));
                  category.clear();
                  target.clear();
                },
              ),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<BudgetTarget>>(
                stream: repo.watchBudgetTargets(profileId: profileId),
                builder: (context, snap) {
                  final targets = snap.data ?? [];
                  return ListView(children: [
                    for (final t in targets)
                      ListTile(
                        title: Text(t.category),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(fmtCents(t.monthlyTargetCents)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18),
                              onPressed: () => repo.deleteBudgetTarget(
                                  profileId: profileId, id: t.id)),
                        ]),
                      ),
                  ]);
                },
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  Future<void> _manageRules(BuildContext context) async {
    final repo = ref.read(repositoryProvider);
    final profileId = ref.read(activeProfileProvider)!.id;
    final pattern = TextEditingController();
    final category = TextEditingController();
    var field = RuleField.description;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Auto-categorization rules'),
          content: SizedBox(
            width: 480,
            height: 420,
            child: Column(children: [
              Row(children: [
                DropdownButton<RuleField>(
                  value: field,
                  items: const [
                    DropdownMenuItem(
                        value: RuleField.description,
                        child: Text('Description contains')),
                    DropdownMenuItem(
                        value: RuleField.amount,
                        child: Text('Amount equals')),
                  ],
                  onChanged: (v) => setState(() => field = v!),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: pattern,
                        decoration:
                            const InputDecoration(labelText: 'Pattern'))),
                const SizedBox(width: 8),
                SizedBox(
                    width: 110,
                    child: TextField(
                        controller: category,
                        decoration:
                            const InputDecoration(labelText: 'Category'))),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (pattern.text.trim().isEmpty ||
                        category.text.trim().isEmpty) {
                      return;
                    }
                    await repo.upsertRule(CategoryRulesCompanion.insert(
                        profileId: profileId,
                        field: field,
                        pattern: pattern.text.trim(),
                        category: category.text.trim()));
                    pattern.clear();
                    category.clear();
                  },
                ),
              ]),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<CategoryRule>>(
                  stream: repo.watchRules(profileId: profileId),
                  builder: (context, snap) {
                    final rules = snap.data ?? [];
                    return ListView(children: [
                      for (final r in rules)
                        ListTile(
                          title: Text(
                              '${r.field == RuleField.description ? 'description contains' : 'amount ='} "${r.pattern}"'),
                          subtitle: Text('→ ${r.category}'),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18),
                              onPressed: () => repo.deleteRule(
                                  profileId: profileId, id: r.id)),
                        ),
                    ]);
                  },
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
