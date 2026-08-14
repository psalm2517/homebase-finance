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
  Stream<Map<String, double>> watchSpentByCategory(
      {required int profileId, required DateTime month}) {
    return watchBudgetForMonth(profileId: profileId, month: month).map((rows) {
      final sums = <String, double>{};
      for (final e in rows.where((e) => e.type == EntryType.expense)) {
        sums[e.category] = (sums[e.category] ?? 0) + e.amount;
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
    double? amount,
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
          if (amount != null && double.tryParse(rule.pattern) == amount) {
            return rule.category;
          }
      }
    }
    return null;
  }
}
