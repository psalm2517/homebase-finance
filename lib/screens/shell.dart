import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import 'bills.dart';
import 'budget.dart';
import 'cards.dart';
import 'dashboard.dart';
import 'loans.dart';
import 'paychecks.dart';

/// Desktop shell: NavigationRail sidebar + content. Only admins see the
/// profile switcher; non-admins have no indication other profiles exist.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _titles = [
    'Dashboard',
    'Cards',
    'Loans',
    'Bills',
    'Budget',
    'Paychecks'
  ];

  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(loggedInProfileProvider)!;
    final active = ref.watch(activeProfileProvider) ?? loggedIn;
    final mode = ref.watch(themeModeProvider);

    final pages = [
      const DashboardScreen(),
      const CardsScreen(),
      const LoansScreen(),
      const BillsScreen(),
      const BudgetScreen(),
      const PaychecksScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (loggedIn.isAdmin) _ProfileSwitcher(active: active),
          IconButton(
            tooltip:
                mode == ThemeMode.dark ? 'Switch to Latte' : 'Switch to Mocha',
            icon: Icon(mode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loggedInProfileProvider.notifier).state = null;
              ref.invalidate(activeProfileProvider);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  label: Text('Dashboard')),
              NavigationRailDestination(
                  icon: Icon(Icons.credit_card), label: Text('Cards')),
              NavigationRailDestination(
                  icon: Icon(Icons.account_balance_outlined),
                  label: Text('Loans')),
              NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: Text('Bills')),
              NavigationRailDestination(
                  icon: Icon(Icons.pie_chart_outline), label: Text('Budget')),
              NavigationRailDestination(
                  icon: Icon(Icons.payments_outlined),
                  label: Text('Paychecks')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}

class _ProfileSwitcher extends ConsumerWidget {
  const _ProfileSwitcher({required this.active});
  final Profile active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder<List<Profile>>(
      future: repo.allProfiles(),
      builder: (context, snapshot) {
        final profiles = snapshot.data ?? [active];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButton<int>(
            value: active.id,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.swap_horiz),
            items: [
              for (final p in profiles)
                DropdownMenuItem(
                    value: p.id, child: Text('Viewing: ${p.name}')),
            ],
            onChanged: (id) {
              if (id == null) return;
              ref.read(activeProfileProvider.notifier).state =
                  profiles.firstWhere((p) => p.id == id);
            },
          ),
        );
      },
    );
  }
}
