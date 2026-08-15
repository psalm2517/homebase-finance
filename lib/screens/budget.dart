import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';
import 'accounts.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

/// A simple month view: what came in, what went out, what is left, and where
/// it went. Forward-looking planning lives on the Dashboard instead, so this
/// screen only ever describes the month you are looking at.
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
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
        onPressed: () => _addEntry(context),
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: combineLatest<dynamic>([
          repo.watchBudgetForMonth(profileId: profileId, month: _month),
          repo.watchBudgetTargets(profileId: profileId),
          repo.watchExpectedIncomeForMonth(
              profileId: profileId, month: _month),
          repo.watchBillsDueThisMonthCents(
              profileId: profileId, month: _month),
          repo.watchCardFeesDueThisMonthCents(profileId: profileId),
        ]),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox.shrink();
          final entries = snap.data![0] as List<BudgetEntry>;
          final targets = snap.data![1] as List<BudgetTarget>;
          final expectedIncome = snap.data![2] as int;
          final billsDue = (snap.data![3] as int) + (snap.data![4] as int);
          return _body(context, entries, targets, expectedIncome, billsDue,
              scheme);
        },
      ),
    );
  }

  Widget _body(
      BuildContext context,
      List<BudgetEntry> entries,
      List<BudgetTarget> targets,
      int expectedIncomeCents,
      int billsDueCents,
      ColorScheme scheme) {
    final moneyIn = entries
        .where((e) => e.type == EntryType.income)
        .fold(0, (s, e) => s + e.amountCents);
    final moneyOut = entries
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
      ..sort((a, b) =>
          (spentByCategory[b] ?? 0).compareTo(spentByCategory[a] ?? 0));

    return Column(
      children: [
        _monthBar(context),
        Expanded(
          child: ListView(
            padding: kPagePadding,
            children: [
              Wrap(spacing: 16, runSpacing: 16, children: [
                StatCard(
                  label: 'Income this month',
                  value: fmtCents(expectedIncomeCents),
                  icon: Icons.arrow_downward,
                  color: scheme.primary,
                  note: moneyIn == expectedIncomeCents
                      ? 'all received'
                      : '${fmtCents(moneyIn)} received so far',
                  info: const InfoButton(
                    title: 'Income this month',
                    body: [
                      'What your paychecks for this month add up to, whether '
                          'or not payday has arrived yet — so you can budget '
                          'the whole month from the 1st instead of watching '
                          'the number climb.',
                      'It is the real sum of this month\'s paychecks, not an '
                          'average, so a month with three paydays shows three '
                          'paychecks. Bonuses are included.',
                      'The smaller line underneath tells you how much of it '
                          'has actually landed so far.',
                      'Add or remove paychecks on the Paychecks screen; they '
                          'are generated 90 days ahead from your schedule.',
                    ],
                  ),
                ),
                StatCard(
                  label: 'Spent so far',
                  value: fmtCents(moneyOut),
                  icon: Icons.arrow_upward,
                  color: scheme.error,
                  note: billsDueCents > 0
                      ? '${fmtCents(billsDueCents)} of bills due this month'
                      : null,
                ),
                StatCard(
                  label: 'Free to spend',
                  value: fmtCents(expectedIncomeCents - billsDueCents),
                  icon: Icons.savings_outlined,
                  color: expectedIncomeCents - billsDueCents >= 0
                      ? scheme.secondary
                      : scheme.error,
                  note: 'income minus this month\'s bills',
                  info: const InfoButton(
                    title: 'Free to spend',
                    body: [
                      'This month\'s paycheck total minus the bills that '
                          'actually charge this month — the amount genuinely '
                          'yours to spend or save.',
                      'It is steady from the 1st, because it counts paychecks '
                          'you are due as well as ones already received.',
                      'Only bills landing in this month are subtracted, so a '
                          'quarterly or annual bill pulls it down only in the '
                          'month it hits. What to set aside for those is on '
                          'the Dashboard.',
                    ],
                  ),
                ),
              ]),
              kSectionGap,
              SectionHeader('Where it went',
                  icon: Icons.donut_small_outlined,
                  info: const InfoButton(
                    title: 'Where it went',
                    body: [
                      'This month\'s spending grouped by category, biggest '
                          'first.',
                      'If you set a target for a category, a bar shows how '
                          'much of it you have used, turning red once you go '
                          'over. Targets are optional — without one you just '
                          'see the amount.',
                      'Set targets from the menu in the top right.',
                    ],
                  )),
              if (categories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.donut_small_outlined,
                      title: 'Nothing spent yet',
                      message:
                          'Expenses appear here as you mark bills paid or add '
                          'entries.',
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final cat in categories)
                        _categoryTile(context, cat,
                            spentByCategory[cat] ?? 0, _targetFor(targets, cat),
                            scheme),
                    ],
                  ),
                ),
              kSectionGap,
              const SectionHeader('Everything this month',
                  icon: Icons.list_alt_outlined),
              if (entries.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.list_alt_outlined,
                      title: 'Nothing yet this month',
                      message:
                          'Paychecks and paid bills land here on their own. '
                          'Use Add entry for anything else.',
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final e in entries) _entryTile(context, e, scheme),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthBar(BuildContext context) {
    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
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
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'targets') _manageTargets(context);
                if (value == 'rules') _manageRules(context);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'targets',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.track_changes),
                    title: Text('Spending targets'),
                    subtitle: Text('Optional limit per category'),
                  ),
                ),
                PopupMenuItem(
                  value: 'rules',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.rule),
                    title: Text('Auto-categorize'),
                    subtitle: Text('Fill categories in for you'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(BuildContext context, BudgetEntry e, ColorScheme scheme) {
    final automatic = e.sourcePaycheckId != null || e.sourceBillPaymentId != null;
    return ListTile(
      leading: Icon(
          e.sourcePaycheckId != null
              ? Icons.payments_outlined
              : e.sourceBillPaymentId != null
                  ? Icons.receipt_long_outlined
                  : e.type == EntryType.income
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
          color: e.type == EntryType.income ? scheme.primary : scheme.error),
      title: Text(e.description ?? e.category),
      subtitle: Text('${e.category} • '
          '${_monthNames[e.date.month - 1].substring(0, 3)} ${e.date.day}'
          '${automatic ? ' • added automatically' : ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${e.type == EntryType.income ? '+' : '-'}'
            '${fmtCents(e.amountCents)}',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: e.type == EntryType.income ? scheme.primary : null),
          ),
          IconButton(
            tooltip: automatic
                ? 'Added automatically — remove it on Paychecks or Bills'
                : 'Delete',
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: automatic
                ? null
                : () => ref.read(repositoryProvider).deleteBudgetEntry(
                    profileId: ref.read(activeProfileProvider)!.id, id: e.id),
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

  Widget _categoryTile(BuildContext context, String category, int spentCents,
      int? targetCents, ColorScheme scheme) {
    final over = targetCents != null && spentCents > targetCents;
    return ListTile(
      title: Text(category),
      subtitle: targetCents == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: (spentCents / targetCents).clamp(0.0, 1.0),
                color: over ? scheme.error : scheme.primary,
              ),
            ),
      trailing: Text(
        targetCents == null
            ? fmtCents(spentCents)
            : '${fmtCents(spentCents)} of ${fmtCents(targetCents)}',
        style: TextStyle(
            fontWeight: FontWeight.w600, color: over ? scheme.error : null),
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => Navigator.pop(context, true),
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
                  onSubmitted: (_) => Navigator.pop(context, true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: category,
                  onSubmitted: (_) => Navigator.pop(context, true),
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
            StatefulBuilder(builder: (context, _) {
              Future<void> add() async {
                final cents = parseDollarsToCents(target.text);
                if (category.text.trim().isEmpty || cents == null) return;
                await repo.upsertBudgetTarget(BudgetTargetsCompanion.insert(
                    profileId: profileId,
                    category: category.text.trim(),
                    monthlyTargetCents: cents));
                category.clear();
                target.clear();
              }

              return Row(children: [
                Expanded(
                    child: TextField(
                        controller: category,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => add(),
                        decoration:
                            const InputDecoration(labelText: 'Category'))),
                const SizedBox(width: 8),
                SizedBox(
                    width: 110,
                    child: TextField(
                        controller: target,
                        onSubmitted: (_) => add(),
                        decoration: const InputDecoration(
                            labelText: 'Target \$'))),
                IconButton(
                    tooltip: 'Add target',
                    icon: const Icon(Icons.add),
                    onPressed: add),
              ]);
            }),
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
        builder: (context, setState) {
          Future<void> addRule() async {
            if (pattern.text.trim().isEmpty || category.text.trim().isEmpty) {
              return;
            }
            await repo.upsertRule(CategoryRulesCompanion.insert(
                profileId: profileId,
                field: field,
                pattern: pattern.text.trim(),
                category: category.text.trim()));
            pattern.clear();
            category.clear();
          }

          return AlertDialog(
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
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => addRule(),
                        decoration:
                            const InputDecoration(labelText: 'Pattern'))),
                const SizedBox(width: 8),
                SizedBox(
                    width: 110,
                    child: TextField(
                        controller: category,
                        onSubmitted: (_) => addRule(),
                        decoration:
                            const InputDecoration(labelText: 'Category'))),
                IconButton(
                  tooltip: 'Add rule',
                  icon: const Icon(Icons.add),
                  onPressed: addRule,
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
        );
        },
      ),
    );
  }
}
