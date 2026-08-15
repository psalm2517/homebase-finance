import 'package:drift/drift.dart';

import 'database.dart';
import 'reminder.dart';

/// All data access goes through this layer. Every query scoped to user data
/// takes a required [profileId] — widgets never touch Drift directly, and
/// there is no way to ask for "all rows" across profiles. This enforces the
/// profile-visibility rule structurally and keeps the API shape ready for a
/// future sync backend.
class HomebaseRepository {
  HomebaseRepository(this._db);

  final AppDatabase _db;

  // ---- Profiles ----

  Future<List<Profile>> allProfiles() => _db.select(_db.profiles).get();

  Future<Profile?> profileById(int id) => (_db.select(_db.profiles)
        ..where((p) => p.id.equals(id)))
      .getSingleOrNull();

  Future<int> createProfile(ProfilesCompanion entry) =>
      _db.into(_db.profiles).insert(entry);

  Future<bool> updateProfile(Profile profile) =>
      _db.update(_db.profiles).replace(profile);

  /// Removes a profile and everything belonging to it. The last admin cannot
  /// be deleted — that would lock the household out of profile management.
  Future<void> deleteProfile({required int id}) async {
    final profile = await profileById(id);
    if (profile == null) return;
    if (profile.isAdmin) {
      final admins = (await allProfiles()).where((p) => p.isAdmin).length;
      if (admins <= 1) {
        throw StateError('Cannot delete the only admin profile');
      }
    }
    await _db.transaction(() async {
      await (_db.delete(_db.payments)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.netWorthSnapshots)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.goals)..where((t) => t.profileId.equals(id))).go();
      await (_db.delete(_db.paycheckAllocations)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.paychecks)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.paycheckSchedules)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.categoryRules)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.budgetTargets)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.budgetEntries)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.creditScoreSnapshots)
            ..where((t) => t.profileId.equals(id)))
          .go();
      // Accounts must go after budget entries, which reference them.
      await (_db.delete(_db.accounts)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.billPayments)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.bills)..where((t) => t.profileId.equals(id))).go();
      await (_db.delete(_db.loans)..where((t) => t.profileId.equals(id))).go();
      await (_db.delete(_db.creditCards)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.profiles)..where((t) => t.id.equals(id))).go();
    });
  }

  // ---- Accounts ----

  Stream<List<Account>> watchAccounts({required int profileId}) =>
      (_db.select(_db.accounts)..where((a) => a.profileId.equals(profileId)))
          .watch();

  Future<int> upsertAccount(AccountsCompanion entry) async {
    final id = await _db.into(_db.accounts).insertOnConflictUpdate(entry);
    await recordNetWorthSnapshot(profileId: entry.profileId.value);
    return id;
  }

  Future<int> deleteAccount(
      {required int profileId, required int id}) async {
    final rows = await (_db.delete(_db.accounts)
          ..where((a) => a.profileId.equals(profileId) & a.id.equals(id)))
        .go();
    await recordNetWorthSnapshot(profileId: profileId);
    return rows;
  }

  /// Assets (accounts) minus liabilities (card + loan balances). Re-emits
  /// whenever any of the three tables change.
  Stream<({int assetsCents, int debtsCents, int netCents})> watchNetWorth(
      {required int profileId}) {
    return _db
        .customSelect(
          '''
          SELECT
            (SELECT COALESCE(SUM(balance_cents), 0) FROM accounts
              WHERE profile_id = ?1) AS assets,
            (SELECT COALESCE(SUM(balance_cents), 0) FROM credit_cards
              WHERE profile_id = ?1)
            + (SELECT COALESCE(SUM(balance_cents), 0) FROM loans
              WHERE profile_id = ?1) AS debts
          ''',
          variables: [Variable.withInt(profileId)],
          readsFrom: {_db.accounts, _db.creditCards, _db.loans},
        )
        .watchSingle()
        .map((row) {
      final assets = row.read<int>('assets');
      final debts = row.read<int>('debts');
      return (
        assetsCents: assets,
        debtsCents: debts,
        netCents: assets - debts
      );
    });
  }

  /// Records today's net worth, replacing today's row if one exists. Called
  /// after anything that moves a balance, and on app entry so a day with no
  /// edits still gets a point once you open Homebase.
  Future<void> recordNetWorthSnapshot({required int profileId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final net = await watchNetWorth(profileId: profileId).first;
    await _db.into(_db.netWorthSnapshots).insert(
          NetWorthSnapshotsCompanion.insert(
            profileId: profileId,
            date: today,
            totalAssetsCents: net.assetsCents,
            totalDebtCents: net.debtsCents,
            netWorthCents: net.netCents,
          ),
          // One row per profile per day: a later edit updates the day's
          // figure rather than adding a second point.
          onConflict: DoUpdate(
            (_) => NetWorthSnapshotsCompanion(
              totalAssetsCents: Value(net.assetsCents),
              totalDebtCents: Value(net.debtsCents),
              netWorthCents: Value(net.netCents),
            ),
            target: [
              _db.netWorthSnapshots.profileId,
              _db.netWorthSnapshots.date
            ],
          ),
        );
  }

  /// Net worth history, oldest first, for the trend chart.
  Stream<List<NetWorthSnapshot>> watchNetWorthHistory(
          {required int profileId, int days = 180}) =>
      (_db.select(_db.netWorthSnapshots)
            ..where((s) =>
                s.profileId.equals(profileId) &
                s.date.isBiggerOrEqualValue(
                    DateTime.now().subtract(Duration(days: days))))
            ..orderBy([(s) => OrderingTerm.asc(s.date)]))
          .watch();

  /// Income and expense totals for the last [months] calendar months,
  /// oldest first — feeds the dashboard cashflow chart.
  Stream<List<({DateTime month, int incomeCents, int expenseCents})>>
      watchCashflow({required int profileId, int months = 6}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (months - 1));
    return (_db.select(_db.budgetEntries)
          ..where((e) =>
              e.profileId.equals(profileId) &
              e.date.isBiggerOrEqualValue(start)))
        .watch()
        .map((rows) {
      return [
        for (var i = 0; i < months; i++)
          () {
            final m = DateTime(now.year, now.month - (months - 1) + i);
            final inMonth = rows.where(
                (e) => e.date.year == m.year && e.date.month == m.month);
            return (
              month: m,
              incomeCents: inMonth
                  .where((e) => e.type == EntryType.income)
                  .fold(0, (s, e) => s + e.amountCents),
              expenseCents: inMonth
                  .where((e) => e.type == EntryType.expense)
                  .fold(0, (s, e) => s + e.amountCents),
            );
          }()
      ];
    });
  }

  // ---- Credit cards ----

  Stream<List<CreditCard>> watchCards({required int profileId}) =>
      (_db.select(_db.creditCards)
            ..where((c) => c.profileId.equals(profileId)))
          .watch();

  Future<int> upsertCard(CreditCardsCompanion entry) async {
    final id = await _db.into(_db.creditCards).insertOnConflictUpdate(entry);
    await recordNetWorthSnapshot(profileId: entry.profileId.value);
    return id;
  }

  Future<int> deleteCard({required int profileId, required int id}) async {
    // Payments logged against this card would otherwise be orphaned; the
    // accountId is not a foreign key because it spans two tables.
    await (_db.delete(_db.payments)
          ..where((p) =>
              p.profileId.equals(profileId) &
              p.accountType.equalsValue(PaymentAccountType.card) &
              p.accountId.equals(id)))
        .go();
    final rows = await (_db.delete(_db.creditCards)
          ..where((c) => c.profileId.equals(profileId) & c.id.equals(id)))
        .go();
    await recordNetWorthSnapshot(profileId: profileId);
    return rows;
  }

  // ---- Loans ----

  Stream<List<Loan>> watchLoans({required int profileId}) =>
      (_db.select(_db.loans)..where((l) => l.profileId.equals(profileId)))
          .watch();

  Future<int> upsertLoan(LoansCompanion entry) async {
    final id = await _db.into(_db.loans).insertOnConflictUpdate(entry);
    await recordNetWorthSnapshot(profileId: entry.profileId.value);
    return id;
  }

  Future<int> deleteLoan({required int profileId, required int id}) async {
    await (_db.delete(_db.payments)
          ..where((p) =>
              p.profileId.equals(profileId) &
              p.accountType.equalsValue(PaymentAccountType.loan) &
              p.accountId.equals(id)))
        .go();
    final rows = await (_db.delete(_db.loans)
          ..where((l) => l.profileId.equals(profileId) & l.id.equals(id)))
        .go();
    await recordNetWorthSnapshot(profileId: profileId);
    return rows;
  }

  // ---- Bills ----

  Stream<List<Bill>> watchBills({required int profileId}) =>
      (_db.select(_db.bills)..where((b) => b.profileId.equals(profileId)))
          .watch();

  Future<int> upsertBill(BillsCompanion entry) =>
      _db.into(_db.bills).insertOnConflictUpdate(entry);

  /// Whether [bill] actually comes due in the given month.
  static bool billFallsIn(Bill bill, DateTime month) {
    switch (bill.frequency) {
      case BillFrequency.monthly:
        return true;
      case BillFrequency.quarterly:
        final anchor = bill.dueMonth ?? 1;
        return (month.month - anchor) % 3 == 0;
      case BillFrequency.annual:
        return month.month == (bill.dueMonth ?? 1);
      case BillFrequency.oneTime:
        return month.month == (bill.dueMonth ?? 1) &&
            month.year == (bill.dueYear ?? month.year);
    }
  }

  /// What a bill costs per month once spread across its billing period —
  /// an annual subscription counts as a twelfth each month. One-time bills
  /// contribute nothing to an ongoing monthly figure.
  static int monthlyCostCents(Bill bill) => switch (bill.frequency) {
        BillFrequency.monthly => bill.amountCents,
        BillFrequency.quarterly => (bill.amountCents / 3).round(),
        BillFrequency.annual => (bill.amountCents / 12).round(),
        BillFrequency.oneTime => 0,
      };

  /// Bills paired with whether they are paid for [month]. Because status is
  /// derived from the month, everything shows unpaid again on the 1st with
  /// no manual reset — and past months keep their real history. Only bills
  /// that actually fall in [month] are returned, so an annual subscription
  /// shows up once a year rather than every month.
  Stream<List<({Bill bill, bool paid})>> watchBillsForMonth({
    required int profileId,
    required DateTime month,
  }) {
    final periodStart = DateTime(month.year, month.month);
    final query = _db.select(_db.bills).join([
      leftOuterJoin(
        _db.billPayments,
        _db.billPayments.billId.equalsExp(_db.bills.id) &
            _db.billPayments.periodStart.equals(periodStart),
      )
    ])
      ..where(_db.bills.profileId.equals(profileId))
      ..orderBy([OrderingTerm.asc(_db.bills.dueDay)]);
    final today = DateTime.now();
    return query.watch().map((rows) => [
          for (final row in rows)
            if (billFallsIn(row.readTable(_db.bills), periodStart))
              (
                bill: row.readTable(_db.bills),
                paid: isBillPaid(
                  row.readTable(_db.bills),
                  row.readTableOrNull(_db.billPayments) != null,
                  periodStart,
                  today,
                ),
              )
        ]);
  }

  /// A manual payment record always counts. Otherwise, an autopay bill is
  /// treated as paid once its due date for this period has passed — there is
  /// no manual check-off to wait on, the bank already handled it.
  static bool isBillPaid(
      Bill bill, bool hasPaymentRecord, DateTime periodStart, DateTime today) {
    if (hasPaymentRecord) return true;
    if (!bill.autopay) return false;
    final lastDay = DateTime(periodStart.year, periodStart.month + 1, 0).day;
    final due = DateTime(periodStart.year, periodStart.month,
        bill.dueDay > lastDay ? lastDay : bill.dueDay);
    return !due.isAfter(DateTime(today.year, today.month, today.day));
  }

  /// Marks a bill paid (or not) for a specific month.
  Future<void> setBillPaid({
    required int profileId,
    required int billId,
    required DateTime month,
    required bool paid,
  }) async {
    final periodStart = DateTime(month.year, month.month);
    if (paid) {
      // Conflict target is the bill+month pair, not the row id: marking an
      // already-paid bill paid again is a no-op rather than an error.
      await _db.into(_db.billPayments).insert(
            BillPaymentsCompanion.insert(
              profileId: profileId,
              billId: billId,
              periodStart: periodStart,
              paidAt: DateTime.now(),
            ),
            onConflict: DoNothing(
                target: [_db.billPayments.billId,
                    _db.billPayments.periodStart]),
          );
      await _syncBillPaymentEntry(
          profileId: profileId, billId: billId, periodStart: periodStart);
    } else {
      await (_db.delete(_db.billPayments)
            ..where((p) =>
                p.profileId.equals(profileId) &
                p.billId.equals(billId) &
                p.periodStart.equals(periodStart)))
          .go();
    }
  }

  Future<int> deleteBill({required int profileId, required int id}) =>
      (_db.delete(_db.bills)
            ..where((b) => b.profileId.equals(profileId) & b.id.equals(id)))
          .go();

  /// Creates the expense entry that mirrors a bill payment, so paying a bill
  /// shows up in the month's spending without typing it twice. Un-paying
  /// removes the payment row, and the cascade removes this entry with it.
  Future<void> _syncBillPaymentEntry({
    required int profileId,
    required int billId,
    required DateTime periodStart,
  }) async {
    final payment = await (_db.select(_db.billPayments)
          ..where((p) =>
              p.billId.equals(billId) & p.periodStart.equals(periodStart)))
        .getSingleOrNull();
    if (payment == null) return;

    final existing = await (_db.select(_db.budgetEntries)
          ..where((e) => e.sourceBillPaymentId.equals(payment.id)))
        .getSingleOrNull();
    if (existing != null) return; // already mirrored

    final bill = await (_db.select(_db.bills)..where((b) => b.id.equals(billId)))
        .getSingle();
    await _db.into(_db.budgetEntries).insert(BudgetEntriesCompanion.insert(
          profileId: profileId,
          date: dayInMonth(periodStart.year, periodStart.month, bill.dueDay),
          amountCents: bill.amountCents,
          type: EntryType.expense,
          category: Value(bill.category),
          description: Value(bill.name),
          sourceBillPaymentId: Value(payment.id),
        ));
  }

  /// Autopay bills are treated as paid once their due date passes, but that
  /// status is computed rather than stored. This writes the real payment
  /// rows (and their expense entries) for any autopay bill now past due in
  /// [month], so autopay spending appears in the budget like everything
  /// else. Idempotent — safe to call on every screen load.
  Future<void> materializeAutopayPayments({
    required int profileId,
    required DateTime month,
  }) async {
    final periodStart = DateTime(month.year, month.month);
    final today = DateTime.now();
    final bills = await (_db.select(_db.bills)
          ..where((b) => b.profileId.equals(profileId) & b.autopay.equals(true)))
        .get();
    for (final bill in bills) {
      if (!billFallsIn(bill, periodStart)) continue;
      final due =
          dayInMonth(periodStart.year, periodStart.month, bill.dueDay);
      if (due.isAfter(DateTime(today.year, today.month, today.day))) continue;
      await setBillPaid(
          profileId: profileId, billId: bill.id, month: periodStart, paid: true);
    }
  }

  /// Clamps [day] to a month that may be shorter (a 31st due date lands on
  /// the 28th in February).
  static DateTime dayInMonth(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }

  /// The next occurrence of [day] on or after [from].
  static DateTime nextOccurrence(int day, DateTime from) {
    final thisMonth = dayInMonth(from.year, from.month, day);
    if (!thisMonth.isBefore(DateTime(from.year, from.month, from.day))) {
      return thisMonth;
    }
    return dayInMonth(from.year, from.month + 1, day);
  }

  // ---- Payments ----

  Stream<List<Payment>> watchPayments({required int profileId, int? limit}) {
    final query = _db.select(_db.payments)
      ..where((p) => p.profileId.equals(profileId))
      ..orderBy([(p) => OrderingTerm.desc(p.date)]);
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Stream<List<Payment>> watchPaymentsFor({
    required int profileId,
    required PaymentAccountType accountType,
    required int accountId,
  }) =>
      (_db.select(_db.payments)
            ..where((p) =>
                p.profileId.equals(profileId) &
                p.accountType.equalsValue(accountType) &
                p.accountId.equals(accountId))
            ..orderBy([(p) => OrderingTerm.desc(p.date)]))
          .watch();

  /// Logs a payment and reduces the balance it was made against in one go,
  /// so the card or loan, its utilization, and the net worth trend all move
  /// together. Balances are floored at zero rather than going negative.
  Future<void> addPayment({
    required int profileId,
    required PaymentAccountType accountType,
    required int accountId,
    required int amountCents,
    DateTime? date,
    String? note,
  }) async {
    if (amountCents <= 0) {
      throw ArgumentError.value(
          amountCents, 'amountCents', 'A payment must be positive');
    }
    await _db.transaction(() async {
      await _db.into(_db.payments).insert(PaymentsCompanion.insert(
            profileId: profileId,
            accountType: accountType,
            accountId: accountId,
            amountCents: amountCents,
            date: date ?? DateTime.now(),
            note: Value(note),
          ));

      switch (accountType) {
        case PaymentAccountType.card:
          final card = await (_db.select(_db.creditCards)
                ..where((c) =>
                    c.profileId.equals(profileId) & c.id.equals(accountId)))
              .getSingleOrNull();
          if (card == null) return;
          final next = (card.balanceCents - amountCents).clamp(0, 1 << 62);
          await (_db.update(_db.creditCards)
                ..where((c) => c.id.equals(accountId)))
              .write(CreditCardsCompanion(balanceCents: Value(next)));
        case PaymentAccountType.loan:
          final loan = await (_db.select(_db.loans)
                ..where((l) =>
                    l.profileId.equals(profileId) & l.id.equals(accountId)))
              .getSingleOrNull();
          if (loan == null) return;
          final next = (loan.balanceCents - amountCents).clamp(0, 1 << 62);
          await (_db.update(_db.loans)..where((l) => l.id.equals(accountId)))
              .write(LoansCompanion(balanceCents: Value(next)));
      }
    });
    // Outside the transaction so the snapshot sees the committed balance.
    await recordNetWorthSnapshot(profileId: profileId);
  }

  /// Removes a payment and puts the amount back on the balance, so a
  /// mistyped payment can be undone without editing the balance by hand.
  Future<void> deletePayment(
      {required int profileId, required int id}) async {
    final payment = await (_db.select(_db.payments)
          ..where((p) => p.profileId.equals(profileId) & p.id.equals(id)))
        .getSingleOrNull();
    if (payment == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.payments)..where((p) => p.id.equals(id))).go();
      switch (payment.accountType) {
        case PaymentAccountType.card:
          final card = await (_db.select(_db.creditCards)
                ..where((c) => c.id.equals(payment.accountId)))
              .getSingleOrNull();
          if (card == null) return;
          await (_db.update(_db.creditCards)
                ..where((c) => c.id.equals(payment.accountId)))
              .write(CreditCardsCompanion(
                  balanceCents:
                      Value(card.balanceCents + payment.amountCents)));
        case PaymentAccountType.loan:
          final loan = await (_db.select(_db.loans)
                ..where((l) => l.id.equals(payment.accountId)))
              .getSingleOrNull();
          if (loan == null) return;
          await (_db.update(_db.loans)
                ..where((l) => l.id.equals(payment.accountId)))
              .write(LoansCompanion(
                  balanceCents:
                      Value(loan.balanceCents + payment.amountCents)));
      }
    });
    await recordNetWorthSnapshot(profileId: profileId);
  }

  // ---- Goals ----

  Stream<List<Goal>> watchGoals({required int profileId}) =>
      (_db.select(_db.goals)
            ..where((g) => g.profileId.equals(profileId))
            ..orderBy([(g) => OrderingTerm.asc(g.id)]))
          .watch();

  Future<int> upsertGoal(GoalsCompanion entry) =>
      _db.into(_db.goals).insertOnConflictUpdate(entry);

  Future<int> deleteGoal({required int profileId, required int id}) =>
      (_db.delete(_db.goals)
            ..where((g) => g.profileId.equals(profileId) & g.id.equals(id)))
          .go();

  /// Moves a goal forward (or back, with a negative amount) without needing
  /// to retype the running total. Never drops below zero.
  Future<void> addGoalProgress({
    required int profileId,
    required int id,
    required int amountCents,
  }) async {
    final goal = await (_db.select(_db.goals)
          ..where((g) => g.profileId.equals(profileId) & g.id.equals(id)))
        .getSingleOrNull();
    if (goal == null) return;
    final next = (goal.currentAmountCents + amountCents).clamp(0, 1 << 62);
    await (_db.update(_db.goals)..where((g) => g.id.equals(id)))
        .write(GoalsCompanion(currentAmountCents: Value(next)));
  }

  /// What a goal needs each month to land on time: the shortfall spread over
  /// the whole months remaining. Null when there is no target date, when the
  /// goal is already met, or when the date has passed — there is no
  /// meaningful monthly figure in those cases.
  static int? monthlyNeededFor(Goal goal, {DateTime? now}) {
    final target = goal.targetDate;
    if (target == null) return null;
    final remaining = goal.targetAmountCents - goal.currentAmountCents;
    if (remaining <= 0) return null;
    final n = now ?? DateTime.now();
    final months = (target.year - n.year) * 12 + (target.month - n.month);
    if (months <= 0) return null;
    return (remaining / months).ceil();
  }

  // ---- Reminders ----

  /// Everything worth nudging about in the next [withinDays] days: unpaid
  /// bills coming due, and card or loan payments coming due. Autopay bills
  /// are skipped — there is nothing for you to do about them.
  /// The next time a card's annual fee lands. The stored date is a specific
  /// day, but the fee recurs yearly, so a date that has passed rolls forward
  /// rather than sitting in the past forever.
  static DateTime? nextAnnualFeeDate(CreditCard card, {DateTime? now}) {
    final fee = card.annualFeeDate;
    if (fee == null) return null;
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    var next = dayInMonth(today.year, fee.month, fee.day);
    if (next.isBefore(today)) {
      next = dayInMonth(today.year + 1, fee.month, fee.day);
    }
    return next;
  }

  Future<List<Reminder>> upcomingReminders({
    required int profileId,
    int withinDays = 3,
    /// Annual fees get a longer runway: they are large, once a year, and
    /// worth deciding about (keep the card or cancel) before they hit.
    int annualFeeWithinDays = 14,
    DateTime? now,
  }) async {
    final today = () {
      final n = now ?? DateTime.now();
      return DateTime(n.year, n.month, n.day);
    }();
    final horizon = today.add(Duration(days: withinDays));
    final reminders = <Reminder>[];

    final billRows = await watchBillsForMonth(
            profileId: profileId, month: DateTime(today.year, today.month))
        .first;
    for (final row in billRows) {
      if (row.paid || row.bill.autopay) continue;
      final due = dayInMonth(today.year, today.month, row.bill.dueDay);
      if (due.isBefore(today) || due.isAfter(horizon)) continue;
      reminders.add(Reminder(
        kind: ReminderKind.bill,
        title: row.bill.name,
        amountCents: row.bill.amountCents,
        date: due,
        sourceId: row.bill.id,
      ));
    }

    final feeHorizon = today.add(Duration(days: annualFeeWithinDays));
    final cards = await watchCards(profileId: profileId).first;
    for (final card in cards) {
      if (card.paymentDueDay != null && card.balanceCents > 0) {
        final due = nextOccurrence(card.paymentDueDay!, today);
        if (!due.isAfter(horizon)) {
          reminders.add(Reminder(
            kind: ReminderKind.cardPayment,
            title: card.name,
            amountCents: card.balanceCents,
            date: due,
            sourceId: card.id,
          ));
        }
      }

      final feeDate = nextAnnualFeeDate(card, now: today);
      if (feeDate != null &&
          card.annualFeeCents > 0 &&
          !feeDate.isAfter(feeHorizon)) {
        reminders.add(Reminder(
          kind: ReminderKind.annualFee,
          title: card.name,
          amountCents: card.annualFeeCents,
          date: feeDate,
          sourceId: card.id,
        ));
      }
    }

    final loans = await watchLoans(profileId: profileId).first;
    for (final loan in loans) {
      if (loan.balanceCents <= 0 || loan.monthlyPaymentCents <= 0) continue;
      // Loans have no explicit due day, so treat the 1st as the usual date.
      final due = nextOccurrence(1, today);
      if (due.isAfter(horizon)) continue;
      reminders.add(Reminder(
        kind: ReminderKind.loanPayment,
        title: loan.name,
        amountCents: loan.monthlyPaymentCents,
        date: due,
        sourceId: loan.id,
      ));
    }

    reminders.sort((a, b) => a.date.compareTo(b.date));
    return reminders;
  }

  // ---- Credit score snapshots ----

  Stream<List<CreditScoreSnapshot>> watchScoreHistory(
          {required int profileId}) =>
      (_db.select(_db.creditScoreSnapshots)
            ..where((s) => s.profileId.equals(profileId))
            ..orderBy([(s) => OrderingTerm.asc(s.date)]))
          .watch();

  Future<int> addScoreSnapshot(CreditScoreSnapshotsCompanion entry) =>
      _db.into(_db.creditScoreSnapshots).insert(entry);

  // ---- Budget entries ----

  Stream<List<BudgetEntry>> watchBudgetForMonth(
      {required int profileId, required DateTime month}) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return (_db.select(_db.budgetEntries)
          ..where((e) =>
              e.profileId.equals(profileId) &
              e.date.isBiggerOrEqualValue(start) &
              e.date.isSmallerThanValue(end))
          ..orderBy([(e) => OrderingTerm.desc(e.date)]))
        .watch();
  }

  Future<int> addBudgetEntry(BudgetEntriesCompanion entry) =>
      _db.into(_db.budgetEntries).insert(entry);

  Future<int> deleteBudgetEntry({required int profileId, required int id}) =>
      (_db.delete(_db.budgetEntries)
            ..where((e) => e.profileId.equals(profileId) & e.id.equals(id)))
          .go();

  // ---- Budget targets (spent-vs-target) ----

  Stream<List<BudgetTarget>> watchBudgetTargets({required int profileId}) =>
      (_db.select(_db.budgetTargets)
            ..where((t) => t.profileId.equals(profileId)))
          .watch();

  /// Conflict target is the profile+category pair, not the row id, so
  /// changing an existing target updates it instead of failing on the
  /// unique constraint.
  Future<int> upsertBudgetTarget(BudgetTargetsCompanion entry) =>
      _db.into(_db.budgetTargets).insert(
            entry,
            onConflict: DoUpdate(
              (_) => entry,
              target: [_db.budgetTargets.profileId,
                  _db.budgetTargets.category],
            ),
          );

  Future<int> deleteBudgetTarget({required int profileId, required int id}) =>
      (_db.delete(_db.budgetTargets)
            ..where((t) => t.profileId.equals(profileId) & t.id.equals(id)))
          .go();

  /// Live map of category -> total expenses for [month]. The budget screen
  /// pairs this with [watchBudgetTargets]; it re-emits on every entry change,
  /// so progress bars are always current — no scheduled refresh.
  Stream<Map<String, int>> watchSpentByCategory(
      {required int profileId, required DateTime month}) {
    return watchBudgetForMonth(profileId: profileId, month: month).map((rows) {
      final sums = <String, int>{};
      for (final e in rows.where((e) => e.type == EntryType.expense)) {
        sums[e.category] = (sums[e.category] ?? 0) + e.amountCents;
      }
      return sums;
    });
  }

  // ---- Category rules (auto-categorization) ----

  Stream<List<CategoryRule>> watchRules({required int profileId}) =>
      (_db.select(_db.categoryRules)
            ..where((r) => r.profileId.equals(profileId))
            ..orderBy([(r) => OrderingTerm.asc(r.priority)]))
          .watch();

  Future<int> upsertRule(CategoryRulesCompanion entry) =>
      _db.into(_db.categoryRules).insertOnConflictUpdate(entry);

  Future<int> deleteRule({required int profileId, required int id}) =>
      (_db.delete(_db.categoryRules)
            ..where((r) => r.profileId.equals(profileId) & r.id.equals(id)))
          .go();

  /// First matching rule's category, or null. Description rules match as a
  /// case-insensitive substring; amount rules match the exact value.
  Future<String?> categorize({
    required int profileId,
    String? description,
    int? amountCents,
  }) async {
    final rules = await (_db.select(_db.categoryRules)
          ..where((r) => r.profileId.equals(profileId))
          ..orderBy([(r) => OrderingTerm.asc(r.priority)]))
        .get();
    for (final rule in rules) {
      switch (rule.field) {
        case RuleField.description:
          if (description != null &&
              description.toLowerCase().contains(rule.pattern.toLowerCase())) {
            return rule.category;
          }
        case RuleField.amount:
          // Rule patterns are entered in dollars (e.g. "9.99").
          final dollars = double.tryParse(rule.pattern);
          if (amountCents != null &&
              dollars != null &&
              (dollars * 100).round() == amountCents) {
            return rule.category;
          }
      }
    }
    return null;
  }

  // ---- Paycheck schedules ----

  Stream<List<PaycheckSchedule>> watchSchedules({required int profileId}) =>
      (_db.select(_db.paycheckSchedules)
            ..where((s) => s.profileId.equals(profileId)))
          .watch();

  Future<int> upsertSchedule(PaycheckSchedulesCompanion entry) =>
      _db.into(_db.paycheckSchedules).insertOnConflictUpdate(entry);

  Future<int> deleteSchedule({required int profileId, required int id}) =>
      (_db.delete(_db.paycheckSchedules)
            ..where((s) => s.profileId.equals(profileId) & s.id.equals(id)))
          .go();

  /// Paydays for [schedule] from its anchor date through [until].
  static List<DateTime> paydatesFor(PaycheckSchedule schedule, DateTime until) {
    final dates = <DateTime>[];
    var d = schedule.anchorDate;
    while (!d.isAfter(until)) {
      dates.add(d);
      d = switch (schedule.frequency) {
        PayFrequency.weekly => d.add(const Duration(days: 7)),
        PayFrequency.biweekly => d.add(const Duration(days: 14)),
        // 1st & 15th style: alternate half-month steps from the anchor day.
        PayFrequency.semimonthly => d.day < 15
            ? DateTime(d.year, d.month, d.day + 14)
            : DateTime(d.year, d.month + 1, d.day - 14),
        PayFrequency.monthly => DateTime(d.year, d.month + 1, d.day),
      };
    }
    return dates;
  }

  /// How far ahead paychecks are generated. Far enough to plan a quarter
  /// without the list running away from you.
  static const paycheckHorizon = Duration(days: 90);

  /// Materialize any due-but-missing paychecks for active schedules, through
  /// [until] (e.g. end of next month). Idempotent: skips dates that already
  /// have a check. Call on app launch / paycheck screen open.
  Future<void> generateDuePaychecks(
      {required int profileId, required DateTime until}) async {
    final schedules = await (_db.select(_db.paycheckSchedules)
          ..where((s) => s.profileId.equals(profileId) & s.active.equals(true)))
        .get();
    for (final schedule in schedules) {
      final existing = await (_db.select(_db.paychecks)
            ..where((p) =>
                p.profileId.equals(profileId) &
                p.scheduleId.equals(schedule.id)))
          .get();
      final have = existing.map((p) => p.date).toSet();
      for (final date in paydatesFor(schedule, until)) {
        if (!have.contains(date)) {
          await _db.into(_db.paychecks).insert(PaychecksCompanion.insert(
                profileId: profileId,
                name: schedule.name,
                date: date,
                amountCents: schedule.amountCents,
                scheduleId: Value(schedule.id),
              ));
        }
      }
    }
  }

  /// Recurring bills as a monthly figure, with quarterly and annual bills
  /// spread across their period (an $80/year subscription counts as $6.67).
  /// This is a planning average, not a current-month charge — the Bills
  /// screen labels it "true monthly cost" for exactly that reason.
  Stream<int> watchMonthlyBillsCents({required int profileId}) =>
      watchBills(profileId: profileId).map(
          (bills) => bills.fold(0, (sum, b) => sum + monthlyCostCents(b)));

  /// What the paychecks dated in [month] add up to, received or not, bonuses
  /// included. This is the money you have to budget with for that month —
  /// it does not start at zero and climb on each payday, and unlike a
  /// schedule average it is exact: a bi-weekly month with three paydays
  /// really does show three paychecks.
  Stream<int> watchExpectedIncomeForMonth(
      {required int profileId, required DateTime month}) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return (_db.select(_db.paychecks)
          ..where((p) =>
              p.profileId.equals(profileId) &
              p.dismissed.equals(false) &
              p.date.isBiggerOrEqualValue(start) &
              p.date.isSmallerThanValue(end)))
        .watch()
        .map((rows) =>
            rows.fold(0, (s, p) => s + p.amountCents + p.bonusCents));
  }

  /// Bills that actually charge in [month] — real cash out, matches what a
  /// bank statement would show. Excludes quarterly/annual bills in months
  /// they don't fall in, and excludes card fees entirely (see
  /// [watchCardFeesDueThisMonth] for the one-time annual-fee charge).
  Stream<int> watchBillsDueThisMonthCents(
      {required int profileId, required DateTime month}) {
    final periodStart = DateTime(month.year, month.month);
    return watchBills(profileId: profileId).map((bills) => bills
        .where((b) => billFallsIn(b, periodStart))
        .fold(0, (sum, b) => sum + b.amountCents));
  }

  /// Monthly card fees actually charged every month — just the monthly fee.
  /// Annual fees aren't tied to a known month in Homebase, so they live
  /// entirely in [watchReserveForCardFeesCents] rather than guessing when
  /// they land.
  Stream<int> watchCardFeesDueThisMonthCents({required int profileId}) =>
      watchCards(profileId: profileId)
          .map((cards) => cards.fold(0, (sum, c) => sum + c.monthlyFeeCents));

  /// What to set aside this month toward bills that are not monthly —
  /// quarterly and annual bills spread evenly across their period, so a
  /// $325/year fee is $27.08/month. This is money to reserve, not money
  /// actually leaving your account this month; keep it separate from
  /// [watchBillsDueThisMonthCents] rather than blending the two.
  Stream<int> watchReserveForIrregularBillsCents({required int profileId}) =>
      watchBills(profileId: profileId).map((bills) => bills
          .where((b) => b.frequency != BillFrequency.oneTime)
          .fold(
              0,
              (sum, b) => sum +
                  (b.frequency == BillFrequency.monthly
                      ? 0
                      : monthlyCostCents(b))));

  /// What to set aside this month toward annual card fees — a twelfth of
  /// each one. Also money to reserve, not a current-month charge.
  Stream<int> watchReserveForCardFeesCents({required int profileId}) =>
      watchCards(profileId: profileId).map((cards) => cards.fold(
          0, (sum, c) => sum + (c.annualFeeCents / 12).round()));

  /// Utilization for a single card, from the balance the issuer actually
  /// reported — the statement balance, not what is owed right now. This is
  /// the number a credit score is judged on.
  static double utilizationOf(CreditCard card) => card.creditLimitCents == 0
      ? 0
      : card.statementBalanceCents / card.creditLimitCents;

  /// Overall reported utilization across every card.
  static double overallUtilization(List<CreditCard> cards) {
    final limit = cards.fold(0, (s, c) => s + c.creditLimitCents);
    if (limit == 0) return 0;
    final reported = cards.fold(0, (s, c) => s + c.statementBalanceCents);
    return reported / limit;
  }

  /// Where a card is in its statement cycle right now: when the statement
  /// closes next, and when payment is due. Null fields mean the card has no
  /// cycle configured.
  static ({DateTime? statementCloses, DateTime? paymentDue, int? daysToClose})
      cycleFor(CreditCard card, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final closes = card.statementCloseDay == null
        ? null
        : nextOccurrence(card.statementCloseDay!, today);
    final due = card.paymentDueDay == null
        ? null
        : nextOccurrence(card.paymentDueDay!, today);
    return (
      statementCloses: closes,
      paymentDue: due,
      daysToClose: closes
          ?.difference(DateTime(today.year, today.month, today.day))
          .inDays,
    );
  }

  // ---- Paycheck planning ----

  Stream<List<Paycheck>> watchPaychecks({required int profileId}) =>
      (_db.select(_db.paychecks)
            ..where((p) =>
                p.profileId.equals(profileId) & p.dismissed.equals(false))
            ..orderBy([(p) => OrderingTerm.desc(p.date)]))
          .watch();

  /// Saves the paycheck, then keeps its linked income entry in sync: a
  /// received paycheck gets (or updates) an income row in Entries so the
  /// Budget screen's totals include it without you re-entering the amount;
  /// un-marking it removes that entry again.
  Future<int> upsertPaycheck(PaychecksCompanion entry) async {
    final id = await _db.into(_db.paychecks).insertOnConflictUpdate(entry);
    final paycheck =
        await (_db.select(_db.paychecks)..where((p) => p.id.equals(id)))
            .getSingle();
    await _syncPaycheckEntry(paycheck);
    return id;
  }

  Future<void> _syncPaycheckEntry(Paycheck paycheck) async {
    final existing = await (_db.select(_db.budgetEntries)
          ..where((e) => e.sourcePaycheckId.equals(paycheck.id)))
        .getSingleOrNull();
    if (paycheck.received) {
      await _db.into(_db.budgetEntries).insertOnConflictUpdate(
            BudgetEntriesCompanion(
              id: existing == null
                  ? const Value.absent()
                  : Value(existing.id),
              profileId: Value(paycheck.profileId),
              date: Value(paycheck.date),
              category: const Value('Paycheck'),
              amountCents:
                  Value(paycheck.amountCents + paycheck.bonusCents),
              type: const Value(EntryType.income),
              description: Value(paycheck.name),
              sourcePaycheckId: Value(paycheck.id),
            ),
          );
    } else if (existing != null) {
      await (_db.delete(_db.budgetEntries)..where((e) => e.id.equals(existing.id)))
          .go();
    }
  }

  /// Removes a paycheck from view, along with its allocations and any income
  /// entry it created. A check produced by a schedule is kept as a dismissed
  /// row rather than deleted outright — otherwise the schedule would see an
  /// unclaimed payday and generate it right back. Manually added checks are
  /// deleted for real.
  Future<void> deletePaycheck(
      {required int profileId, required int id}) async {
    final paycheck = await (_db.select(_db.paychecks)
          ..where((p) => p.profileId.equals(profileId) & p.id.equals(id)))
        .getSingleOrNull();
    if (paycheck == null) return;

    await (_db.delete(_db.budgetEntries)
          ..where((e) => e.sourcePaycheckId.equals(id)))
        .go();
    await (_db.delete(_db.paycheckAllocations)
          ..where((a) => a.paycheckId.equals(id)))
        .go();

    if (paycheck.scheduleId == null) {
      await (_db.delete(_db.paychecks)..where((p) => p.id.equals(id))).go();
    } else {
      await (_db.update(_db.paychecks)..where((p) => p.id.equals(id)))
          .write(const PaychecksCompanion(
        dismissed: Value(true),
        received: Value(false),
      ));
    }
  }

  /// Marks any paycheck whose date has arrived as received, creating its
  /// income entry — you get paid on payday whether or not you open the app,
  /// so this shouldn't need a click. Paychecks you set by hand are left
  /// alone, so an override (delayed, never arrived) is not undone.
  /// Idempotent — safe to call on every screen load.
  Future<void> materializeReceivedPaychecks({required int profileId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = await (_db.select(_db.paychecks)
          ..where((p) =>
              p.profileId.equals(profileId) &
              p.received.equals(false) &
              p.receivedIsManual.equals(false) &
              p.dismissed.equals(false) &
              p.date.isSmallerOrEqualValue(today)))
        .get();
    for (final paycheck in due) {
      await (_db.update(_db.paychecks)..where((p) => p.id.equals(paycheck.id)))
          .write(const PaychecksCompanion(received: Value(true)));
      await _syncPaycheckEntry(paycheck.copyWith(received: true));
    }
  }

  Stream<List<PaycheckAllocation>> watchAllocations(
          {required int profileId, required int paycheckId}) =>
      (_db.select(_db.paycheckAllocations)
            ..where((a) =>
                a.profileId.equals(profileId) &
                a.paycheckId.equals(paycheckId)))
          .watch();

  Future<int> upsertAllocation(PaycheckAllocationsCompanion entry) =>
      _db.into(_db.paycheckAllocations).insertOnConflictUpdate(entry);

  Future<int> deleteAllocation({required int profileId, required int id}) =>
      (_db.delete(_db.paycheckAllocations)
            ..where((a) => a.profileId.equals(profileId) & a.id.equals(id)))
          .go();
}
