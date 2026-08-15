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
