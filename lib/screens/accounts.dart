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
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add account' : 'Edit account'),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DialogField(name, 'Account name', autofocus: true),
              DialogField(institution, 'Institution (optional)'),
              DropdownButtonFormField<AccountType>(
                initialValue: type,
                decoration: const InputDecoration(
                    labelText: 'Type', border: OutlineInputBorder()),
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
