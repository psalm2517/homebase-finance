import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';

IconData accountIcon(AccountType type) => switch (type) {
      AccountType.checking => Icons.account_balance_wallet_outlined,
      AccountType.savings => Icons.savings_outlined,
      AccountType.cash => Icons.payments_outlined,
      AccountType.investment => Icons.trending_up,
      AccountType.retirement => Icons.beach_access_outlined,
      AccountType.other => Icons.account_balance_outlined,
    };

String accountLabel(AccountType type) => switch (type) {
      AccountType.checking => 'Checking',
      AccountType.savings => 'Savings',
      AccountType.cash => 'Cash',
      AccountType.investment => 'Investment',
      AccountType.retirement => 'Retirement',
      AccountType.other => 'Other',
    };

/// Plain-language guide to picking a type. The split that matters is tax
/// treatment: retirement accounts are tax-advantaged and penalized for early
/// withdrawal, investment accounts are ordinary taxable brokerages.
String accountHint(AccountType type) => switch (type) {
      AccountType.checking => 'Everyday spending account at a bank.',
      AccountType.savings =>
        'Savings, money market or high-yield savings account.',
      AccountType.cash => 'Physical cash, or an app balance like Venmo.',
      AccountType.investment =>
        'Taxable brokerage you can withdraw from anytime — '
            'individual or joint brokerage, crypto.',
      AccountType.retirement =>
        'Tax-advantaged and penalized before age 59½ — '
            '401(k), 403(b), Roth IRA, Traditional IRA, HSA.',
      AccountType.other => 'Anything else you count as an asset.',
    };

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add account'),
      ),
      body: StreamBuilder<List<Account>>(
        stream: repo.watchAccounts(profileId: profileId),
        builder: (context, snap) {
          final accounts = snap.data ?? [];
          if (accounts.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_outlined,
              title: 'No accounts yet',
              message:
                  'Add your checking, savings, cash or investment accounts to '
                  'see real net worth on the dashboard.',
            );
          }
          final total = accounts.fold(0, (s, a) => s + a.balanceCents);
          final byType = <AccountType, List<Account>>{};
          for (final a in accounts) {
            byType.putIfAbsent(a.type, () => []).add(a);
          }
          return ListView(
            padding: kPagePadding,
            children: [
              StatCard(
                label: 'Total across accounts',
                value: fmtCents(total),
                icon: Icons.account_balance_outlined,
                color: total >= 0 ? scheme.primary : scheme.error,
                info: const InfoButton(
                  title: 'Account types',
                  body: [
                    'Checking, savings and cash are money you can spend now.',
                    'Investment means an ordinary taxable brokerage — an '
                        'individual or joint brokerage account, or crypto. '
                        'You can sell and withdraw whenever you want, and you '
                        'owe tax on gains and dividends.',
                    'Retirement means a tax-advantaged account with strings '
                        'attached: 401(k), 403(b), Traditional IRA, Roth IRA, '
                        'HSA. They grow tax-free or tax-deferred, but taking '
                        'money out before age 59½ generally means a 10% '
                        'penalty plus taxes.',
                    'So a Roth IRA and a 401(k) are Retirement; a regular '
                        'brokerage account is Investment. The difference is '
                        'the tax wrapper, not what you hold inside it — you '
                        'can own the same index fund in either one.',
                    'These types only group and label accounts in Homebase. '
                        'All of them count as assets toward net worth.',
                  ],
                ),
              ),
              kSectionGap,
              for (final type in AccountType.values)
                if (byType[type] != null) ...[
                  SectionHeader(accountLabel(type), icon: accountIcon(type)),
                  Card(
                    child: Column(
                      children: [
                        for (final a in byType[type]!)
                          ListTile(
                            leading: Icon(accountIcon(a.type)),
                            title: Text(a.name),
                            subtitle:
                                a.institution == null || a.institution!.isEmpty
                                    ? null
                                    : Text(a.institution!),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(fmtCents(a.balanceCents),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: a.balanceCents < 0
                                            ? scheme.error
                                            : null)),
                                IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    onPressed: () => _edit(context, ref, a)),
                                IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18),
                                    onPressed: () =>
                                        _delete(context, ref, a)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  kSectionGap,
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Account account) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${account.name}?'),
        content: const Text(
            'Transactions linked to this account stay, but lose the link.'),
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
          .deleteAccount(profileId: profileId, id: account.id);
    }
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, Account? existing) async {
    final profileId = ref.read(activeProfileProvider)!.id;
    final name = TextEditingController(text: existing?.name);
    final institution = TextEditingController(text: existing?.institution);
    final balance = TextEditingController(
        text: existing == null ? '' : (existing.balanceCents / 100).toString());
    var type = existing?.type ?? AccountType.checking;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => SubmitOnEnter(
          onSubmit: () => Navigator.pop(context, true),
          child: AlertDialog(
          title: Text(existing == null ? 'Add account' : 'Edit account'),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DialogField(name, 'Account name', autofocus: true),
              DialogField(institution, 'Institution (optional)'),
              DropdownButtonFormField<AccountType>(
                initialValue: type,
                decoration: InputDecoration(
                    labelText: 'Type',
                    helperText: accountHint(type),
                    helperMaxLines: 3,
                    border: const OutlineInputBorder()),
                items: [
                  for (final t in AccountType.values)
                    DropdownMenuItem(
                      value: t,
                      child: Row(children: [
                        Icon(accountIcon(t), size: 16),
                        const SizedBox(width: 8),
                        Text(accountLabel(t)),
                      ]),
                    ),
                ],
                onChanged: (v) => setLocal(() => type = v!),
              ),
              const SizedBox(height: 12),
              DialogField(balance, 'Current balance (\$)'),
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
      ),
    );
    if (saved != true || name.text.trim().isEmpty) return;
    await ref.read(repositoryProvider).upsertAccount(AccountsCompanion(
          id: existing == null ? const Value.absent() : Value(existing.id),
          profileId: Value(profileId),
          name: Value(name.text.trim()),
          institution: Value(institution.text.trim().isEmpty
              ? null
              : institution.text.trim()),
          type: Value(type),
          balanceCents: Value(parseDollarsToCents(balance.text) ?? 0),
        ));
  }
}
