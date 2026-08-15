/// What a reminder is about. Kept separate from the table definitions
/// because reminders are computed, not stored — they always reflect the
/// current state of your bills and balances.
enum ReminderKind { bill, cardPayment, loanPayment, annualFee }

class Reminder {
  const Reminder({
    required this.kind,
    required this.title,
    required this.amountCents,
    required this.date,
    required this.sourceId,
  });

  final ReminderKind kind;
  final String title;
  final int amountCents;
  final DateTime date;

  /// Row id of the bill, card or loan this came from.
  final int sourceId;

  /// Stable id so the same reminder is not notified twice in a day.
  String get dedupeKey =>
      '${kind.name}:$sourceId:${date.year}-${date.month}-${date.day}';

  int daysUntil(DateTime from) =>
      date.difference(DateTime(from.year, from.month, from.day)).inDays;
}
