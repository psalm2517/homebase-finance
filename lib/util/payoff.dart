/// Result of projecting a single debt to zero.
class PayoffProjection {
  const PayoffProjection({
    required this.months,
    required this.totalInterestCents,
    required this.balanceByMonth,
  });

  /// Months until the balance reaches zero.
  final int months;
  final int totalInterestCents;

  /// Balance at the end of each month, starting with the opening balance,
  /// for charting the path down to zero.
  final List<int> balanceByMonth;

  DateTime payoffDate(DateTime from) =>
      DateTime(from.year, from.month + months, from.day);
}

/// Projects a single debt paid down by a fixed amount each month.
///
/// Interest accrues monthly at [apr] / 12 on the remaining balance, then the
/// payment is applied — the ordering banks actually use, and the reason a
/// payment barely above the interest takes so long to clear anything.
///
/// Returns null when the payment cannot outrun the interest, because there
/// is no payoff date to show in that case rather than a misleadingly large
/// number.
PayoffProjection? simulatePayoff({
  required int balanceCents,
  required double apr,
  required int monthlyPaymentCents,
  int extraCents = 0,
  int maxMonths = 1200,
}) {
  if (balanceCents <= 0) {
    return const PayoffProjection(
        months: 0, totalInterestCents: 0, balanceByMonth: [0]);
  }
  final payment = monthlyPaymentCents + extraCents;
  if (payment <= 0) return null;

  var balance = balanceCents;
  var totalInterest = 0;
  final series = <int>[balance];

  for (var month = 1; month <= maxMonths; month++) {
    final interest = (balance * apr / 100 / 12).round();
    // A payment that does not cover the interest never clears the debt.
    if (payment <= interest) return null;

    totalInterest += interest;
    balance = balance + interest - payment;
    if (balance <= 0) {
      series.add(0);
      return PayoffProjection(
        months: month,
        totalInterestCents: totalInterest,
        balanceByMonth: series,
      );
    }
    series.add(balance);
  }
  return null;
}

/// A typical credit card minimum: 1% of the balance plus that month's
/// interest, never less than $25. Cards do not store a minimum payment, so
/// this is the starting point the simulator offers.
int estimateCardMinimumPayment({
  required int balanceCents,
  required double apr,
}) {
  if (balanceCents <= 0) return 0;
  final interest = (balanceCents * apr / 100 / 12).round();
  final onePercent = (balanceCents * 0.01).round();
  final estimate = onePercent + interest;
  const floor = 2500; // $25.00
  final capped = estimate < floor ? floor : estimate;
  // Never suggest more than the balance itself.
  return capped > balanceCents ? balanceCents : capped;
}

/// One debt in a multi-debt payoff plan.
class DebtInput {
  const DebtInput({
    required this.id,
    required this.balanceCents,
    required this.apr,
    required this.minimumPaymentCents,
  });

  final int id;
  final int balanceCents;
  final double apr;
  final int minimumPaymentCents;
}

/// Which debt gets the spare money first.
enum PayoffStrategy {
  /// Smallest balance first — clears individual debts sooner.
  snowball,

  /// Highest APR first — mathematically cheapest.
  avalanche,
}

class MultiDebtProjection {
  const MultiDebtProjection({
    required this.months,
    required this.totalInterestCents,
    required this.payoffOrder,
  });

  final int months;
  final int totalInterestCents;

  /// Debt ids in the order they were cleared.
  final List<int> payoffOrder;
}

/// Projects several debts paid off together: every minimum is paid each
/// month, then any extra — plus the freed-up minimum of anything already
/// cleared — is thrown at whichever debt the strategy prioritises.
///
/// Returns null when the debts cannot be cleared, which happens when the
/// minimums do not cover the interest and there is no extra to make up the
/// difference.
MultiDebtProjection? simulateMultiDebtPayoff({
  required List<DebtInput> debts,
  required PayoffStrategy strategy,
  int extraCents = 0,
  int maxMonths = 1200,
}) {
  final live = debts.where((d) => d.balanceCents > 0).toList();
  if (live.isEmpty) {
    return const MultiDebtProjection(
        months: 0, totalInterestCents: 0, payoffOrder: []);
  }

  final balances = {for (final d in live) d.id: d.balanceCents};
  final order = [...live]..sort((a, b) => switch (strategy) {
        PayoffStrategy.snowball =>
          a.balanceCents.compareTo(b.balanceCents),
        PayoffStrategy.avalanche => b.apr.compareTo(a.apr),
      });

  var months = 0;
  var totalInterest = 0;
  final cleared = <int>[];

  while (balances.values.any((b) => b > 0)) {
    months++;
    if (months > maxMonths) return null;

    var budget = extraCents;
    var progressed = false;

    for (final d in live) {
      final balance = balances[d.id]!;
      if (balance <= 0) {
        // A cleared debt frees its minimum for the others.
        budget += d.minimumPaymentCents;
        continue;
      }
      final interest = (balance * d.apr / 100 / 12).round();
      totalInterest += interest;
      var next = balance + interest - d.minimumPaymentCents;
      if (next < balance) progressed = true;
      if (next < 0) {
        budget += -next;
        next = 0;
      }
      balances[d.id] = next;
      if (next == 0 && !cleared.contains(d.id)) cleared.add(d.id);
    }

    for (final d in order) {
      if (budget <= 0) break;
      final balance = balances[d.id]!;
      if (balance <= 0) continue;
      final pay = balance < budget ? balance : budget;
      balances[d.id] = balance - pay;
      budget -= pay;
      if (pay > 0) progressed = true;
      if (balances[d.id] == 0 && !cleared.contains(d.id)) cleared.add(d.id);
    }

    // Nothing moved this month, so nothing ever will.
    if (!progressed) return null;
  }

  return MultiDebtProjection(
    months: months,
    totalInterestCents: totalInterest,
    payoffOrder: cleared,
  );
}
