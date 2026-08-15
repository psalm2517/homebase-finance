import 'package:flutter/material.dart';

import '../util/money.dart';
import '../util/payoff.dart';
import 'common.dart';

/// "What if I paid a bit more?" — a slider over extra monthly payment with
/// the projected payoff date, interest saved and time saved, plus a chart
/// comparing the current track against the simulated one.
class PayoffSimulator extends StatefulWidget {
  const PayoffSimulator({
    super.key,
    required this.name,
    required this.balanceCents,
    required this.apr,
    required this.basePaymentCents,
    this.basePaymentLabel = 'Current monthly payment',
  });

  final String name;
  final int balanceCents;
  final double apr;

  /// The payment being made today — a loan's monthly payment, or the
  /// estimated minimum on a card.
  final int basePaymentCents;
  final String basePaymentLabel;

  @override
  State<PayoffSimulator> createState() => _PayoffSimulatorState();
}

class _PayoffSimulatorState extends State<PayoffSimulator> {
  int _extraCents = 0;

  /// Slider ceiling: enough to clear most debts quickly without a useless
  /// range. Rounded to a tidy number so the labels read well.
  int get _maxExtra {
    final tenth = (widget.balanceCents / 10).round();
    final floor = widget.basePaymentCents * 2;
    final raw = tenth > floor ? tenth : floor;
    final rounded = ((raw / 5000).ceil() * 5000);
    return rounded < 5000 ? 5000 : rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = simulatePayoff(
      balanceCents: widget.balanceCents,
      apr: widget.apr,
      monthlyPaymentCents: widget.basePaymentCents,
    );
    final simulated = simulatePayoff(
      balanceCents: widget.balanceCents,
      apr: widget.apr,
      monthlyPaymentCents: widget.basePaymentCents,
      extraCents: _extraCents,
    );

    if (widget.balanceCents <= 0) {
      return const EmptyState(
        icon: Icons.celebration_outlined,
        title: 'Already paid off',
        message: 'Nothing left to project on this account.',
      );
    }

    final now = DateTime.now();
    final interestSaved = (current != null && simulated != null)
        ? current.totalInterestCents - simulated.totalInterestCents
        : null;
    final monthsSaved = (current != null && simulated != null)
        ? current.months - simulated.months
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailRow(widget.basePaymentLabel,
            fmtCents(widget.basePaymentCents)),
        DetailRow('Balance', fmtCents(widget.balanceCents)),
        DetailRow('APR', '${widget.apr.toStringAsFixed(2)}%'),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Extra each month'),
            const Spacer(),
            Text(fmtCents(_extraCents),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: scheme.primary)),
          ],
        ),
        Slider(
          value: _extraCents.toDouble().clamp(0, _maxExtra.toDouble()),
          max: _maxExtra.toDouble(),
          divisions: 40,
          label: fmtCents(_extraCents),
          onChanged: (v) =>
              setState(() => _extraCents = (v / 500).round() * 500),
        ),
        if (current == null)
          Card(
            color: scheme.errorContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.warning_amber_outlined, color: scheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'At ${fmtCents(widget.basePaymentCents)} a month this '
                    'never gets paid off — the interest is larger than the '
                    'payment. Move the slider up to find an amount that does.',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ]),
            ),
          ),
        if (simulated != null) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _result(
                context,
                'Paid off',
                _fmtMonthYear(simulated.payoffDate(now)),
                '${simulated.months ~/ 12}y ${simulated.months % 12}m',
                scheme.primary),
            _result(
                context,
                'Total interest',
                fmtCents(simulated.totalInterestCents),
                'over the life of the debt',
                scheme.error),
            if (interestSaved != null && interestSaved > 0)
              _result(
                  context,
                  'Interest saved',
                  fmtCents(interestSaved),
                  monthsSaved == null || monthsSaved <= 0
                      ? 'vs your current payment'
                      : '$monthsSaved months sooner',
                  scheme.secondary),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _PayoffChartPainter(
                current: current?.balanceByMonth,
                simulated: simulated.balanceByMonth,
                currentColor: scheme.outline,
                simulatedColor: scheme.primary,
                label: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            if (current != null) ...[
              _legend(context, scheme.outline, 'Current payment', dashed: true),
              const SizedBox(width: 16),
            ],
            _legend(context, scheme.primary,
                _extraCents == 0 ? 'Projection' : 'With extra payment'),
          ]),
        ],
      ],
    );
  }

  Widget _result(BuildContext context, String label, String value,
      String note, Color color) {
    return SizedBox(
      width: 190,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: color)),
              Text(note, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String text,
      {bool dashed = false}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
              color: dashed ? color.withValues(alpha: 0.6) : color,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }

  static String _fmtMonthYear(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

/// Balance falling to zero: the current path dashed, the simulated path
/// solid, on a shared scale so the gap between them is the saving.
class _PayoffChartPainter extends CustomPainter {
  _PayoffChartPainter({
    required this.current,
    required this.simulated,
    required this.currentColor,
    required this.simulatedColor,
    required this.label,
  });

  final List<int>? current;
  final List<int> simulated;
  final Color currentColor;
  final Color simulatedColor;
  final Color label;

  @override
  void paint(Canvas canvas, Size size) {
    final longest = current == null
        ? simulated.length
        : (current!.length > simulated.length
            ? current!.length
            : simulated.length);
    if (longest < 2) return;

    final maxBalance = [
      ...simulated,
      ...?current,
    ].reduce((a, b) => a > b ? a : b);
    if (maxBalance <= 0) return;

    const labelHeight = 18.0;
    final chartHeight = size.height - labelHeight;

    Offset point(int i, int value) => Offset(
          i * size.width / (longest - 1),
          chartHeight - (value / maxBalance) * (chartHeight - 6),
        );

    void drawSeries(List<int> series, Color color, {bool dashed = false}) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = dashed ? 1.8 : 2.5
        ..style = PaintingStyle.stroke;
      if (!dashed) {
        final path = Path()..moveTo(point(0, series[0]).dx, point(0, series[0]).dy);
        for (var i = 1; i < series.length; i++) {
          final p = point(i, series[i]);
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, paint);
        return;
      }
      // Dashes drawn segment by segment so the two lines stay legible where
      // they overlap.
      for (var i = 1; i < series.length; i++) {
        if (i.isEven) continue;
        canvas.drawLine(
            point(i - 1, series[i - 1]), point(i, series[i]), paint);
      }
    }

    if (current != null) {
      drawSeries(current!, currentColor.withValues(alpha: 0.8), dashed: true);
    }
    drawSeries(simulated, simulatedColor);

    // Zero line and the two payoff points.
    final axis = Paint()..color = label.withValues(alpha: 0.2);
    canvas.drawLine(
        Offset(0, chartHeight), Offset(size.width, chartHeight), axis);

    void tick(List<int> series, Color color) {
      final i = series.length - 1;
      canvas.drawCircle(point(i, series[i]), 3.5, Paint()..color = color);
      final years = (i / 12).floor();
      final months = i % 12;
      final tp = TextPainter(
        text: TextSpan(
            text: years > 0 ? '${years}y ${months}m' : '${months}m',
            style: TextStyle(color: color, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset((point(i, series[i]).dx - tp.width).clamp(0, size.width - tp.width),
              size.height - labelHeight + 2));
    }

    if (current != null) tick(current!, currentColor);
    tick(simulated, simulatedColor);
  }

  @override
  bool shouldRepaint(_PayoffChartPainter old) =>
      old.simulated != simulated || old.current != current;
}
