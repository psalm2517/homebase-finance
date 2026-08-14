import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Whether a budget entry adds to or subtracts from the month.
enum EntryType { income, expense }

/// Kind of account. Credit and loan balances are tracked in their own
/// tables; these are the cash/asset side of net worth.
enum AccountType { checking, savings, cash, investment, retirement, other }

/// A bank, cash, or investment account.
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get institution => text().nullable()();
  TextColumn get type => textEnum<AccountType>()();
  IntColumn get balanceCents => integer().withDefault(const Constant(0))();
}

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get pinHash => text().nullable()();
  BoolColumn get isAdmin => boolean().withDefault(const Constant(false))();
}

class CreditCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get balanceCents => integer().withDefault(const Constant(0))();
  IntColumn get creditLimitCents => integer()(); // `limit` is an SQL keyword
  RealColumn get apr => real().withDefault(const Constant(0))();
  IntColumn get annualFeeCents => integer().withDefault(const Constant(0))();
  IntColumn get monthlyFeeCents => integer().withDefault(const Constant(0))();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get balanceCents => integer()();
  IntColumn get originalAmountCents => integer()();
  RealColumn get apr => real().withDefault(const Constant(0))();
  IntColumn get monthlyPaymentCents => integer().withDefault(const Constant(0))();
}

class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get amountCents => integer()();
  IntColumn get dueDay => integer()(); // 1-31, clamped to month length in UI
  BoolColumn get recurring => boolean().withDefault(const Constant(true))();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  BoolColumn get paidThisMonth =>
      boolean().withDefault(const Constant(false))();
}

class CreditScoreSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get score => integer()();
  RealColumn get utilization => real()(); // 0.0 - 1.0
  IntColumn get derogatoryMarks => integer().withDefault(const Constant(0))();
  IntColumn get accountAgeMonths => integer().withDefault(const Constant(0))();
  IntColumn get hardInquiries => integer().withDefault(const Constant(0))();
}

class BudgetEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  IntColumn get amountCents => integer()();
  TextColumn get type => textEnum<EntryType>()();
  TextColumn get description => text().nullable()(); // matched by CategoryRules
  /// Which account the money moved through, when known.
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
}

/// Per-category monthly spending target for the budget screen.
class BudgetTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get category => text().withLength(min: 1, max: 64)();
  IntColumn get monthlyTargetCents => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, category},
      ];
}

/// What part of a budget entry a categorization rule matches against.
enum RuleField { description, amount }

/// Auto-categorization: when a new entry's [field] matches [pattern]
/// (case-insensitive substring for description, exact value for amount),
/// assign [category]. First match by [priority] wins.
class CategoryRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get field => textEnum<RuleField>()();
  TextColumn get pattern => text().withLength(min: 1, max: 128)();
  TextColumn get category => text().withLength(min: 1, max: 64)();
  IntColumn get priority => integer().withDefault(const Constant(0))();
}

/// How often a paycheck schedule pays out.
enum PayFrequency { weekly, biweekly, semimonthly, monthly }

/// A recurring paycheck: set it once and the app generates the individual
/// checks. Amounts are after-tax (take-home).
class PaycheckSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)(); // e.g. "Day job"
  TextColumn get frequency => textEnum<PayFrequency>()();
  DateTimeColumn get anchorDate => dateTime()(); // first/next known payday
  IntColumn get amountCents => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// An expected or received paycheck to plan against.
class Paychecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountCents => integer()();
  IntColumn get bonusCents => integer().withDefault(const Constant(0))();
  BoolColumn get received => boolean().withDefault(const Constant(false))();

  /// Set when this check was generated from a schedule.
  IntColumn get scheduleId =>
      integer().nullable().references(PaycheckSchedules, #id)();
}

/// "From this paycheck, [amountCents] goes to [target]" — e.g. Savings, Rent.
/// Optionally linked to a Bill so paying it can mark the bill paid.
class PaycheckAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  IntColumn get paycheckId =>
      integer().references(Paychecks, #id, onDelete: KeyAction.cascade)();
  TextColumn get target => text().withLength(min: 1, max: 64)();
  IntColumn get amountCents => integer()();
  IntColumn get billId => integer().nullable().references(Bills, #id)();
}

@DriftDatabase(tables: [
  Profiles,
  Accounts,
  CreditCards,
  Loans,
  Bills,
  CreditScoreSnapshots,
  BudgetEntries,
  BudgetTargets,
  CategoryRules,
  PaycheckSchedules,
  Paychecks,
  PaycheckAllocations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(accounts);
            await m.addColumn(budgetEntries, budgetEntries.accountId);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'homebase.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
