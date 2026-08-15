import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';
import 'accounts.dart';

/// Everything the monthly plan needs, combined so the screen isn't seven
/// levels of nested StreamBuilders.
class _PlanData {
  const _PlanData({
    required this.entries,
    required this.targets,
    required this.scheduledIncomeCents,
    required this.billsDueThisMonthCents,
    required this.cardFeesDueThisMonthCents,
    required this.reserveForIrregularBillsCents,
    required this.reserveForCardFeesCents,
  });

  final List<BudgetEntry> entries;
  final List<BudgetTarget> targets;
  final int scheduledIncomeCents;
  final int billsDueThisMonthCents;
  final int cardFeesDueThisMonthCents;
  final int reserveForIrregularBillsCents;
  final int reserveForCardFeesCents;
}

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  Stream<_PlanData> _watchPlan(HomebaseRepository repo, int profileId) {
    return combineLatest<dynamic>([
      repo.watchBudgetForMonth(profileId: profileId, month: _month),
      repo.watchBudgetTargets(profileId: profileId),
      repo.watchMonthlyIncomeCents(profileId: profileId),
      repo.watchBillsDueThisMonthCents(profileId: profileId, month: _month),
      repo.watchCardFeesDueThisMonthCents(profileId: profileId),
      repo.watchReserveForIrregularBillsCents(profileId: profileId),
      repo.watchReserveForCardFeesCents(profileId: profileId),
    ]).map((values) => _PlanData(
          entries: values[0] as List<BudgetEntry>,
          targets: values[1] as List<BudgetTarget>,
          scheduledIncomeCents: values[2] as int,
          billsDueThisMonthCents: values[3] as int,
          cardFeesDueThisMonthCents: values[4] as int,
          reserveForIrregularBillsCents: values[5] as int,
          reserveForCardFeesCents: values[6] as int,
        ));
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
      body: StreamBuilder<_PlanData>(
        stream: _watchPlan(repo, profileId),
        builder: (context, snap) {
          final data = snap.data;
          if (data == null) return const SizedBox.shrink();
          return _buildBody(context, data, scheme);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, _PlanData data, ColorScheme scheme) {
    final entries = data.entries;
    final targets = data.targets;
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
                  'Two different things, kept separate rather than blended '
                      'into one number: money actually charged this month, '
                      'and money worth setting aside for bills that aren\'t '
                      'monthly.',
                  'Income comes from your paycheck schedules on the '
                      'Paychecks screen, normalized to a month — a bi-weekly '
                      'schedule is multiplied by 26 and divided by 12. That '
                      'is why it may not match a single paycheck times two.',
                  '"Due this month" only counts a bill in the month it '
                      'actually charges — a quarterly or annual bill shows '
                      'up here only in the month it hits, matching what your '
                      'bank statement would show.',
                  '"Set aside" is different: it spreads bills that aren\'t '
                      'monthly evenly across their period, so an \$80/year '
                      'subscription shows as \$6.67 here every month, even '
                      'in months nothing is actually charged. This is not '
                      'cash leaving your account — it is a reserve you are '
                      'building toward the real charge.',
                  'Card annual fees work the same way: Homebase does not '
                      'know which month yours lands in, so the full fee '
                      'never appears in "due this month" — only its monthly '
                      'twelfth appears in "set aside".',
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
                      fmtCents(data.scheduledIncomeCents)),
                  _planRow('Bills due this month',
                      '-${fmtCents(data.billsDueThisMonthCents)}'),
                  _planRow('Card fees due this month',
                      '-${fmtCents(data.cardFeesDueThisMonthCents)}'),
                  const Divider(),
                  _planRow(
                      'Left to budget',
                      fmtCents(data.scheduledIncomeCents -
                          data.billsDueThisMonthCents -
                          data.cardFeesDueThisMonthCents),
                      bold: true),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(Icons.savings_outlined,
                        size: 14, color: scheme.secondary),
                    const SizedBox(width: 6),
                    Text('Worth setting aside (not charged yet)',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: scheme.secondary)),
                  ]),
                  _planRow('For quarterly/annual bills',
                      fmtCents(data.reserveForIrregularBillsCents),
                      color: scheme.secondary),
                  _planRow('For card annual fees',
                      fmtCents(data.reserveForCardFeesCents),
                      color: scheme.secondary),
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
          SectionHeader('Entries',
              icon: Icons.list_alt_outlined,
              info: InfoButton(
                title: 'Entries',
                body: [
                  'The month\'s actual income and expenses — this is what '
                      '"Income", "Expenses" and the category breakdown above '
                      'are built from.',
                  'A paycheck marked received on the Paychecks screen drops '
                      'an income entry here automatically, amount and bonus '
                      'included, so you do not have to enter it twice. It '
                      'shows a paycheck icon and cannot be deleted directly '
                      '— mark the paycheck unreceived instead.',
                  'Everything else — groceries, a side gig, cash you found '
                      'in a coat pocket — you add yourself with Add entry.',
                ],
              )),
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
                          e.sourcePaycheckId != null
                              ? Icons.payments_outlined
                              : e.type == EntryType.income
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                          color: e.type == EntryType.income
                              ? scheme.primary
                              : scheme.error),
                      title: Text(e.description ?? e.category),
                      subtitle: Text(
                          '${e.category} • ${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}'
                          '${e.sourcePaycheckId != null ? ' • from a paycheck' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '${e.type == EntryType.income ? '+' : '-'}${fmtCents(e.amountCents)}'),
                          IconButton(
                            tooltip: e.sourcePaycheckId != null
                                ? 'Managed by its paycheck — mark it '
                                    'unreceived on Paychecks to remove this'
                                : 'Delete',
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: e.sourcePaycheckId != null
                                ? null
                                : () => ref
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

  Widget _planRow(String label, String value,
      {bool bold = false, Color? color}) {
    final style = TextStyle(
        fontWeight: bold ? FontWeight.bold : null, color: color);
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
