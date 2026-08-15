/// Day of month with its ordinal suffix: 1 -> "1st", 22 -> "22nd".
/// The teens are the exception that catches naive versions out — 11, 12 and
/// 13 take "th" despite ending in 1, 2 and 3.
String ordinalDay(int day) {
  final suffix = (day % 100 >= 11 && day % 100 <= 13)
      ? 'th'
      : switch (day % 10) {
          1 => 'st',
          2 => 'nd',
          3 => 'rd',
          _ => 'th',
        };
  return '$day$suffix';
}

/// Formats integer cents as dollars, e.g. 123456 -> "$1,234.56".
String fmtCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final dollars = (abs ~/ 100).toString();
  final withCommas = dollars.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '$sign\$$withCommas.${(abs % 100).toString().padLeft(2, '0')}';
}

/// Parses "1,234.56" or "1234" (dollars) into cents; null if invalid.
int? parseDollarsToCents(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll('\$', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  return (value * 100).round();
}
