import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;

    return StreamBuilder<List<CreditCard>>(
      stream: repo.watchCards(profileId: profileId),
      builder: (context, cardsSnap) {
        return StreamBuilder<List<Loan>>(
          stream: repo.watchLoans(profileId: profileId),
          builder: (context, loansSnap) {
            return StreamBuilder<List<Bill>>(
              stream: repo.watchBills(profileId: profileId),
              builder: (context, billsSnap) {
                final cards = cardsSnap.data ?? [];
                final loans = loansSnap.data ?? [];
                final bills = billsSnap.data ?? [];
                return _Dashboard(
                    cards: cards, loans: loans, bills: bills,
                    profileId: profileId);
              },
            );
          },
        );
      },
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard(
      {required this.cards,
      required this.loans,
      required this.bills,
      required this.profileId});

  final List<CreditCard> cards;
  final List<Loan> loans;
  final List<Bill> bills;
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final cardDebt = cards.fold(0, (s, c) => s + c.balanceCents);
    final loanDebt = loans.fold(0, (s, l) => s + l.balanceCents);
    final totalDebt = cardDebt + loanDebt;
    final totalLimit = cards.fold(0, (s, c) => s + c.creditLimitCents);
    final overallUtil = totalLimit == 0 ? 0.0 : cardDebt / totalLimit;

    final today = DateTime.now();
    final weekAhead = [
      for (var i = 0; i < 7; i++) DateTime(today.year, today.month, today.day + i)
    ];
    final upcoming = bills.where((b) {
      return weekAhead.any((d) =>
          b.dueDay == d.day ||
          // due day beyond month length lands on the last day
          (b.dueDay > DateTime(d.year, d.month + 1, 0).day &&
              d.day == DateTime(d.year, d.month + 1, 0).day));
    }).toList();

    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _stat(context, 'Net worth', fmtCents(-totalDebt),
                  totalDebt > 0 ? scheme.error : scheme.primary),
              _stat(context, 'Total debt', fmtCents(totalDebt), scheme.error),
              _stat(
                  context,
                  'Overall utilization',
                  '${(overallUtil * 100).toStringAsFixed(1)}%',
                  overallUtil > 0.3 ? scheme.error : scheme.primary,
                  flag: overallUtil > 0.3 ? 'over 30%' : null),
            ],
          ),
          const SizedBox(height: 24),
          Text('Utilization per card',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (cards.isEmpty)
            const Text('No cards yet.')
          else
            Card(
              child: Column(
                children: [
                  for (final c in cards)
                    ListTile(
                      title: Text(c.name),
                      subtitle: LinearProgressIndicator(
                        value: c.creditLimitCents == 0
                            ? 0
                            : (c.balanceCents / c.creditLimitCents)
                                .clamp(0.0, 1.0),
                        color: c.creditLimitCents != 0 &&
                                c.balanceCents / c.creditLimitCents > 0.3
                            ? scheme.error
                            : scheme.primary,
                      ),
                      trailing: Text(c.creditLimitCents == 0
                          ? '—'
                          : '${(c.balanceCents / c.creditLimitCents * 100).toStringAsFixed(1)}%'),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text('Bills due this week',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const Text('Nothing due in the next 7 days.')
          else
            Card(
              child: Column(
                children: [
                  for (final b in upcoming)
                    ListTile(
                      leading: Icon(
                          b.paidThisMonth
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: b.paidThisMonth
                              ? scheme.primary
                              : scheme.error),
                      title: Text(b.name),
                      subtitle: Text('Due day ${b.dueDay}'),
                      trailing: Text(fmtCents(b.amountCents)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text('Credit score trend',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<CreditScoreSnapshot>>(
            stream: repo.watchScoreHistory(profileId: profileId),
            builder: (context, snap) {
              final scores = snap.data ?? [];
              if (scores.length < 2) {
                return const Text(
                    'Add at least two score snapshots to see a trend.');
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _ScoreChartPainter(
                          scores: scores,
                          lineColor: scheme.primary,
                          labelColor: scheme.onSurface),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color,
      {String? flag}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: color)),
            if (flag != null)
              Text(flag,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _ScoreChartPainter extends CustomPainter {
  _ScoreChartPainter(
      {required this.scores,
      required this.lineColor,
      required this.labelColor});

  final List<CreditScoreSnapshot> scores;
  final Color lineColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minScore =
        scores.map((s) => s.score).reduce((a, b) => a < b ? a : b) - 20;
    final maxScore =
        scores.map((s) => s.score).reduce((a, b) => a > b ? a : b) + 20;
    final range = (maxScore - minScore).clamp(1, 850);

    Offset point(int i) {
      final x = scores.length == 1
          ? size.width / 2
          : i * size.width / (scores.length - 1);
      final y =
          size.height - (scores[i].score - minScore) / range * size.height;
      return Offset(x, y);
    }

    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < scores.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(path, line);

    final dot = Paint()..color = lineColor;
    for (var i = 0; i < scores.length; i++) {
      canvas.drawCircle(point(i), 4, dot);
      final tp = TextPainter(
        text: TextSpan(
            text: '${scores[i].score}',
            style: TextStyle(color: labelColor, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, point(i) + const Offset(-10, -20));
    }
  }

  @override
  bool shouldRepaint(_ScoreChartPainter old) =>
      old.scores != scores || old.lineColor != lineColor;
}
