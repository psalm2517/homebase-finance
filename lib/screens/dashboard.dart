import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../main.dart';
import '../util/money.dart';
import '../widgets/common.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final profileId = ref.watch(activeProfileProvider)!.id;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: kPagePadding,
      children: [
        StreamBuilder<({int assetsCents, int debtsCents, int netCents})>(
          stream: repo.watchNetWorth(profileId: profileId),
          builder: (context, snap) {
            final net = snap.data;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                  label: 'Net worth',
                  value: net == null ? '—' : fmtCents(net.netCents),
                  icon: Icons.savings_outlined,
                  color: (net?.netCents ?? 0) >= 0
                      ? scheme.primary
                      : scheme.error,
                  note: net == null ? null : 'assets minus debts',
                  info: const InfoButton(
                    title: 'Net worth',
                    body: [
                      'Everything you own minus everything you owe.',
                      'Assets are the balances of your accounts (checking, '
                          'savings, cash, investment, retirement). Debts are '
                          'your credit card balances plus your loan balances.',
                      'A negative number is normal early on, especially with '
                          'student loans or a car note. What matters is the '
                          'direction it moves over time.',
                    ],
                  ),
                ),
                StatCard(
                  label: 'Assets',
                  value: net == null ? '—' : fmtCents(net.assetsCents),
                  icon: Icons.account_balance_outlined,
                  color: scheme.secondary,
                ),
                StatCard(
                  label: 'Total debt',
                  value: net == null ? '—' : fmtCents(net.debtsCents),
                  icon: Icons.credit_card,
                  color: scheme.error,
                ),
              ],
            );
          },
        ),
        kSectionGap,
        StreamBuilder<List<NetWorthSnapshot>>(
          stream: repo.watchNetWorthHistory(profileId: profileId),
          builder: (context, snap) {
            final history = snap.data ?? [];
            final first = history.isEmpty ? null : history.first;
            final last = history.isEmpty ? null : history.last;
            final change = (first == null || last == null)
                ? 0
                : last.netWorthCents - first.netWorthCents;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader('Net worth trend',
                    icon: Icons.timeline,
                    info: const InfoButton(
                      title: 'Net worth trend',
                      body: [
                        'Your net worth recorded over time, so you can see '
                            'the direction rather than just today\'s number.',
                        'A point is written whenever you change an account, '
                            'card or loan balance, and once when you open '
                            'Homebase on a new day. Only one point is kept '
                            'per day — later edits update that day rather '
                            'than adding another.',
                        'The dashed line is zero. Below it you owe more than '
                            'you own, which is common with a car loan or '
                            'student debt; what matters is the slope.',
                        'History starts from when you first ran this version, '
                            'so the line will look short until a few days '
                            'have passed.',
                      ],
                    ),
                    action: history.length < 2
                        ? null
                        : Text(
                            '${change >= 0 ? '+' : ''}${fmtCents(change)} '
                            'over ${history.length} days',
                            style: TextStyle(
                                color: change >= 0
                                    ? scheme.primary
                                    : scheme.error),
                          )),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: history.length < 2
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: EmptyState(
                              icon: Icons.timeline,
                              title: 'Not enough history yet',
                              message:
                                  'Come back tomorrow, or change a balance, '
                                  'and the trend will start to build.',
                            ),
                          )
                        : SizedBox(
                            height: 220,
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _NetWorthChartPainter(
                                history: history,
                                line: scheme.primary,
                                negative: scheme.error,
                                label: scheme.onSurface,
                                grid: scheme.outline,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        kSectionGap,
        StreamBuilder<List<CreditCard>>(
          stream: repo.watchCards(profileId: profileId),
          builder: (context, snap) {
            final cards = snap.data ?? [];
            final balance = cards.fold(0, (s, c) => s + c.balanceCents);
            final limit = cards.fold(0, (s, c) => s + c.creditLimitCents);
            final overall = limit == 0 ? 0.0 : balance / limit;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader('Credit utilization',
                    icon: Icons.donut_large_outlined,
                    info: const InfoButton(
                      title: 'Credit utilization',
                      body: [
                        'The share of your available credit you are currently '
                            'using: balance divided by credit limit.',
                        'Keeping it under 30% is the common guidance, because '
                            'utilization is one of the largest factors in a '
                            'credit score. Under 10% is better still.',
                        'It is measured both per card and across all cards, so '
                            'one maxed-out card can hurt even if your overall '
                            'number looks fine. Homebase flags anything above '
                            '30% in red.',
                        'Scores generally use the balance reported on your '
                            'statement date, not your balance after you pay, '
                            'so paying before the statement closes lowers the '
                            'number that gets reported.',
                      ],
                    ),
                    action: cards.isEmpty
                        ? null
                        : Text(
                            'Overall ${(overall * 100).toStringAsFixed(1)}%'
                            '${overall > 0.30 ? ' — over 30%' : ''}',
                            style: TextStyle(
                                color: overall > 0.30
                                    ? scheme.error
                                    : scheme.primary),
                          )),
                if (cards.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.credit_card_off_outlined,
                        title: 'No credit cards',
                        message:
                            'Add cards to track balances and utilization.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final c in cards)
                          _utilizationTile(context, c, scheme),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        kSectionGap,
        StreamBuilder<List<({DateTime month, int incomeCents, int expenseCents})>>(
          stream: repo.watchCashflow(profileId: profileId),
          builder: (context, snap) {
            final data = snap.data ?? [];
            final hasAny = data
                .any((d) => d.incomeCents != 0 || d.expenseCents != 0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Cashflow',
                    icon: Icons.bar_chart_outlined,
                    info: InfoButton(
                      title: 'Cashflow',
                      body: [
                        'Money in versus money out for each of the last six '
                            'months, built from your Budget entries.',
                        'Green bars are income, red bars are expenses. When '
                            'the red bar is taller than the green one, you '
                            'spent more than you earned that month.',
                        'This only counts entries you have logged in Budget — '
                            'it is not pulled from your bank.',
                      ],
                    )),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: hasAny
                        ? SizedBox(
                            height: 220,
                            child: _CashflowChart(
                                data: data,
                                income: scheme.primary,
                                expense: scheme.error,
                                label: scheme.onSurface),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(16),
                            child: EmptyState(
                              icon: Icons.bar_chart_outlined,
                              title: 'No cashflow yet',
                              message:
                                  'Add income and expenses in Budget to see '
                                  'money in versus money out by month.',
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        kSectionGap,
        StreamBuilder<List<({Bill bill, bool paid})>>(
          stream: repo.watchBillsForMonth(
              profileId: profileId, month: DateTime.now()),
          builder: (context, snap) {
            final rows = snap.data ?? [];
            final today = DateTime.now();
            final lastDay = DateTime(today.year, today.month + 1, 0).day;
            final windowEnd = today.add(const Duration(days: 7));
            final upcoming = rows.where((r) {
              final day = r.bill.dueDay > lastDay ? lastDay : r.bill.dueDay;
              final due = DateTime(today.year, today.month, day);
              return !due.isBefore(DateTime(today.year, today.month, today.day)) &&
                  !due.isAfter(windowEnd);
            }).toList();
            final overdue = rows.where((r) {
              final day = r.bill.dueDay > lastDay ? lastDay : r.bill.dueDay;
              final due = DateTime(today.year, today.month, day);
              return !r.paid &&
                  !r.bill.autopay &&
                  due.isBefore(DateTime(today.year, today.month, today.day));
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Bills due this week',
                    icon: Icons.event_outlined,
                    info: InfoButton(
                      title: 'Bills due this week',
                      body: [
                        'Any bill whose due day falls in the next seven days, '
                            'plus anything already overdue and unpaid this '
                            'month.',
                        'Paid status is tracked per month, so this clears '
                            'itself when a new month begins — there is '
                            'nothing to reset.',
                        'A bill due on a day later than the current month has '
                            '(the 31st in February) is treated as due on the '
                            'last day of that month.',
                      ],
                    )),
                if (upcoming.isEmpty && overdue.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'Nothing due this week',
                        message: 'Bills due in the next 7 days appear here.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final r in [...overdue, ...upcoming])
                          ListTile(
                            leading: Icon(
                                r.paid
                                    ? Icons.check_circle
                                    : overdue.contains(r)
                                        ? Icons.warning_amber_outlined
                                        : Icons.schedule,
                                color: r.paid
                                    ? scheme.primary
                                    : scheme.error),
                            title: Text(r.bill.name),
                            subtitle: Text(
                                'Due the ${ordinalDay(r.bill.dueDay)} • '
                                '${r.bill.category}'
                                '${overdue.contains(r) ? ' • overdue' : ''}'),
                            trailing: Text(fmtCents(r.bill.amountCents),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        kSectionGap,
        StreamBuilder<List<CreditScoreSnapshot>>(
          stream: repo.watchScoreHistory(profileId: profileId),
          builder: (context, snap) {
            final scores = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Credit score trend',
                    icon: Icons.show_chart,
                    info: InfoButton(
                      title: 'Credit score trend',
                      body: [
                        'Your score over time, from snapshots you log '
                            'manually. Nothing is fetched from a bureau.',
                        'The main drivers: payment history (never miss a due '
                            'date), utilization (keep it low), age of '
                            'accounts (older is better, so avoid closing old '
                            'cards), credit mix, and hard inquiries (each new '
                            'application dings you briefly).',
                        'Two snapshots are needed before a line appears.',
                      ],
                    )),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: scores.length < 2
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: EmptyState(
                              icon: Icons.show_chart,
                              title: 'Not enough history',
                              message:
                                  'Log at least two credit score snapshots to '
                                  'see a trend line.',
                            ),
                          )
                        : SizedBox(
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
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _utilizationTile(
      BuildContext context, CreditCard c, ColorScheme scheme) {
    final ratio =
        c.creditLimitCents == 0 ? 0.0 : c.balanceCents / c.creditLimitCents;
    final over = ratio > 0.30;
    return ListTile(
      leading: Icon(Icons.credit_card,
          color: over ? scheme.error : scheme.primary),
      title: Text(c.name),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: LinearProgressIndicator(
          value: ratio.clamp(0.0, 1.0),
          color: over ? scheme.error : scheme.primary,
        ),
      ),
      trailing: Text(
        c.creditLimitCents == 0
            ? '—'
            : '${(ratio * 100).toStringAsFixed(1)}%',
        style: TextStyle(
            fontWeight: FontWeight.w600, color: over ? scheme.error : null),
      ),
    );
  }
}

/// Grouped income/expense bars by month.
class _CashflowChart extends StatelessWidget {
  const _CashflowChart(
      {required this.data,
      required this.income,
      required this.expense,
      required this.label});

  final List<({DateTime month, int incomeCents, int expenseCents})> data;
  final Color income;
  final Color expense;
  final Color label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legend(income, 'Income'),
            const SizedBox(width: 16),
            _legend(expense, 'Expenses'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _CashflowPainter(
                data: data,
                income: income,
                expense: expense,
                label: label),
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      );
}

class _CashflowPainter extends CustomPainter {
  _CashflowPainter(
      {required this.data,
      required this.income,
      required this.expense,
      required this.label});

  final List<({DateTime month, int incomeCents, int expenseCents})> data;
  final Color income;
  final Color expense;
  final Color label;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxValue = data
        .expand((d) => [d.incomeCents, d.expenseCents])
        .fold(0, (a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    const labelHeight = 20.0;
    final chartHeight = size.height - labelHeight;
    final slot = size.width / data.length;
    final barWidth = (slot * 0.30).clamp(6.0, 28.0);

    for (var i = 0; i < data.length; i++) {
      final centre = slot * i + slot / 2;
      final d = data[i];

      void bar(int cents, Color color, double offset) {
        final h = cents / maxValue * (chartHeight - 8);
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
              centre + offset, chartHeight - h, barWidth, h),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = color);
      }

      bar(d.incomeCents, income, -barWidth - 2);
      bar(d.expenseCents, expense, 2);

      final tp = TextPainter(
        text: TextSpan(
            text: _months[d.month.month - 1],
            style: TextStyle(
                color: label.withValues(alpha: 0.7), fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(centre - tp.width / 2, size.height - labelHeight + 4));
    }
  }

  @override
  bool shouldRepaint(_CashflowPainter old) =>
      old.data != data || old.income != income;
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
      return Offset(x.clamp(6.0, size.width - 6), y);
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
      tp.paint(canvas, point(i) + Offset(-tp.width / 2, -20));
    }
  }

  @override
  bool shouldRepaint(_ScoreChartPainter old) =>
      old.scores != scores || old.lineColor != lineColor;
}

/// Net worth over time. Handles negative values by anchoring the scale to
/// include zero and drawing a dashed baseline there.
class _NetWorthChartPainter extends CustomPainter {
  _NetWorthChartPainter({
    required this.history,
    required this.line,
    required this.negative,
    required this.label,
    required this.grid,
  });

  final List<NetWorthSnapshot> history;
  final Color line;
  final Color negative;
  final Color label;
  final Color grid;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;
    const labelHeight = 20.0;
    final chartHeight = size.height - labelHeight;

    final values = history.map((s) => s.netWorthCents).toList();
    // Always include zero so the baseline is meaningful.
    var minValue = values.reduce((a, b) => a < b ? a : b);
    var maxValue = values.reduce((a, b) => a > b ? a : b);
    if (minValue > 0) minValue = 0;
    if (maxValue < 0) maxValue = 0;
    final range = (maxValue - minValue) == 0 ? 1 : (maxValue - minValue);

    double yFor(int cents) =>
        chartHeight - ((cents - minValue) / range) * (chartHeight - 8) - 4;
    double xFor(int i) =>
        history.length == 1 ? size.width / 2 : i * size.width / (history.length - 1);

    // Zero baseline, dashed.
    final zeroY = yFor(0);
    final dash = Paint()
      ..color = grid.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, zeroY), Offset(x + 4, zeroY), dash);
    }

    final path = Path()..moveTo(xFor(0), yFor(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(xFor(i), yFor(values[i]));
    }

    // Soft fill under the line, tinted by whether it ends up or down.
    final ending = values.last >= 0 ? line : negative;
    final fill = Path.from(path)
      ..lineTo(xFor(values.length - 1), zeroY)
      ..lineTo(xFor(0), zeroY)
      ..close();
    canvas.drawPath(fill, Paint()..color = ending.withValues(alpha: 0.12));

    canvas.drawPath(
        path,
        Paint()
          ..color = ending
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke);

    // End point emphasised with its value.
    final lastX = xFor(values.length - 1);
    final lastY = yFor(values.last);
    canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = ending);

    void drawText(String text, Offset at, {Color? color, bool right = false}) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(color: color ?? label, fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at - (right ? Offset(tp.width, 0) : Offset.zero));
    }

    drawText(fmtCents(values.last),
        Offset(lastX - 6, lastY - 18), color: ending, right: true);

    // First and last dates along the bottom.
    final firstDate = history.first.date;
    final lastDate = history.last.date;
    drawText('${_months[firstDate.month - 1]} ${firstDate.day}',
        Offset(0, size.height - labelHeight + 4));
    drawText('${_months[lastDate.month - 1]} ${lastDate.day}',
        Offset(size.width, size.height - labelHeight + 4), right: true);
  }

  @override
  bool shouldRepaint(_NetWorthChartPainter old) =>
      old.history != history || old.line != line;
}
