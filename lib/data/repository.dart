import 'package:drift/drift.dart';

import 'database.dart';

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

  Future<int> upsertAccount(AccountsCompanion entry) =>
      _db.into(_db.accounts).insertOnConflictUpdate(entry);

  Future<int> deleteAccount({required int profileId, required int id}) =>
      (_db.delete(_db.accounts)
            ..where((a) => a.profileId.equals(profileId) & a.id.equals(id)))
          .go();

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

  Future<int> upsertCard(CreditCardsCompanion entry) =>
      _db.into(_db.creditCards).insertOnConflictUpdate(entry);

  Future<int> deleteCard({required int profileId, required int id}) =>
      (_db.delete(_db.creditCards)
            ..where((c) => c.profileId.equals(profileId) & c.id.equals(id)))
          .go();

  // ---- Loans ----

  Stream<List<Loan>> watchLoans({required int profileId}) =>
      (_db.select(_db.loans)..where((l) => l.profileId.equals(profileId)))
          .watch();

  Future<int> upsertLoan(LoansCompanion entry) =>
      _db.into(_db.loans).insertOnConflictUpdate(entry);

  Future<int> deleteLoan({required int profileId, required int id}) =>
      (_db.delete(_db.loans)
            ..where((l) => l.profileId.equals(profileId) & l.id.equals(id)))
          .go();

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

  Future<int> upsertBudgetTarget(BudgetTargetsCompanion entry) =>
      _db.into(_db.budgetTargets).insertOnConflictUpdate(entry);

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

  /// After-tax monthly income from active schedules, normalized
  /// (weekly x52/12, bi-weekly x26/12, semi-monthly x2, monthly x1).
  /// Feeds the bills-vs-income breakdown.
  Stream<int> watchMonthlyIncomeCents({required int profileId}) =>
      watchSchedules(profileId: profileId).map((schedules) {
        var cents = 0.0;
        for (final s in schedules.where((s) => s.active)) {
          cents += switch (s.frequency) {
            PayFrequency.weekly => s.amountCents * 52 / 12,
            PayFrequency.biweekly => s.amountCents * 26 / 12,
            PayFrequency.semimonthly => s.amountCents * 2.0,
            PayFrequency.monthly => s.amountCents * 1.0,
          };
        }
        return cents.round();
      });

  /// Recurring bills as a monthly figure, with quarterly and annual bills
  /// spread across their period (an $80/year subscription counts as $6.67).
  /// This is a planning average, not a current-month charge — the Bills
  /// screen labels it "true monthly cost" for exactly that reason.
  Stream<int> watchMonthlyBillsCents({required int profileId}) =>
      watchBills(profileId: profileId).map(
          (bills) => bills.fold(0, (sum, b) => sum + monthlyCostCents(b)));

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

  /// Where a card is in its statement cycle right now: when the statement
  /// closes next, and when payment is due. Null fields mean the card has no
  /// cycle configured.
  static ({DateTime? statementCloses, DateTime? paymentDue, int? daysToClose})
      cycleFor(CreditCard card, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final closes = card.statementDay == null
        ? null
        : nextOccurrence(card.statementDay!, today);
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
            ..where((p) => p.profileId.equals(profileId))
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

  /// Deleting a paycheck cascades to its allocations.
  Future<int> deletePaycheck({required int profileId, required int id}) =>
      (_db.delete(_db.paychecks)
            ..where((p) => p.profileId.equals(profileId) & p.id.equals(id)))
          .go();

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
