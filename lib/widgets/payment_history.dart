import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';

/// Recent payments logged against one card or loan, with a way to undo one.
/// Without this, a mistyped payment could only be corrected by hand-editing
/// the balance, and the Payments log was invisible.
class PaymentHistory extends ConsumerWidget {
  const PaymentHistory({
    super.key,
    required this.accountType,
    required this.accountId,
  });

  final PaymentAccountType accountType;
  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Payment>>(
      stream: repo.watchPaymentsFor(
          profileId: profileId,
          accountType: accountType,
          accountId: accountId),
      builder: (context, snap) {
        final payments = snap.data ?? [];
        if (payments.isEmpty) return const SizedBox.shrink();
        final shown = payments.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Recent payments',
                style: Theme.of(context).textTheme.labelMedium),
            for (final p in shown)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.payments_outlined,
                    size: 18, color: scheme.primary),
                title: Text(fmtCents(p.amountCents)),
                subtitle: Text(
                    '${_fmtDate(p.date)}${p.note == null ? '' : ' • ${p.note}'}'),
                trailing: IconButton(
                  tooltip: 'Undo — puts the amount back on the balance',
                  icon: const Icon(Icons.undo, size: 18),
                  onPressed: () => _undo(context, ref, profileId, p),
                ),
              ),
            if (payments.length > shown.length)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    '${payments.length - shown.length} older '
                    '${payments.length - shown.length == 1 ? 'payment' : 'payments'} '
                    'not shown',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
          ],
        );
      },
    );
  }

  Future<void> _undo(BuildContext context, WidgetRef ref, int profileId,
      Payment payment) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo this payment?'),
        content: Text(
            '${fmtCents(payment.amountCents)} goes back onto the balance and '
            'the payment is removed from the log.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Undo payment')),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(repositoryProvider)
        .deletePayment(profileId: profileId, id: payment.id);
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${ordinalDay(d.day)}';
  }
}
