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

  Future<void> setBillPaid(
      {required int profileId, required int id, required bool paid}) async {
    await (_db.update(_db.bills)
          ..where((b) => b.profileId.equals(profileId) & b.id.equals(id)))
        .write(BillsCompanion(paidThisMonth: Value(paid)));
  }

  Future<int> deleteBill({required int profileId, required int id}) =>
      (_db.delete(_db.bills)
            ..where((b) => b.profileId.equals(profileId) & b.id.equals(id)))
          .go();

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

  /// Total of recurring monthly bills — the other half of the breakdown.
  Stream<int> watchMonthlyBillsCents({required int profileId}) =>
      watchBills(profileId: profileId).map((bills) => bills
          .where((b) => b.recurring)
          .fold(0, (sum, b) => sum + b.amountCents));

  // ---- Paycheck planning ----

  Stream<List<Paycheck>> watchPaychecks({required int profileId}) =>
      (_db.select(_db.paychecks)
            ..where((p) => p.profileId.equals(profileId))
            ..orderBy([(p) => OrderingTerm.desc(p.date)]))
          .watch();

  Future<int> upsertPaycheck(PaychecksCompanion entry) =>
      _db.into(_db.paychecks).insertOnConflictUpdate(entry);

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
