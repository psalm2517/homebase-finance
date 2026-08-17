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

  /// Day of month the statement closes.
  IntColumn get statementCloseDay => integer().nullable()();

  /// Day of month the payment is due, typically ~21-25 days after closing.
  IntColumn get paymentDueDay => integer().nullable()();

  /// Balance as of the last statement close — the figure the issuer reports
  /// to the credit bureaus. Utilization and anything credit-score related
  /// uses this; everything about money actually owed uses [balanceCents].
  IntColumn get statementBalanceCents =>
      integer().withDefault(const Constant(0))();

  /// Minimum payment shown on the current statement, when known. The payoff
  /// simulator prefers this over its own estimate.
  IntColumn get minimumPaymentDueCents => integer().nullable()();

  /// When the annual fee next hits. The amount is [annualFeeCents], which
  /// already feeds the budget set-aside — a second amount field here could
  /// disagree with it.
  DateTimeColumn get annualFeeDate => dateTime().nullable()();
}

/// Which kind of debt a payment was made against.
enum PaymentAccountType { card, loan }

/// A logged payment toward a card or loan. Kept as its own history so a
/// balance can be explained (and recomputed) rather than just overwritten.
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get accountType => textEnum<PaymentAccountType>()();

  /// Row id in CreditCards or Loans, depending on [accountType]. Not a
  /// foreign key because it points at one of two tables; cleanup is handled
  /// when a card or loan is deleted.
  IntColumn get accountId => integer()();

  IntColumn get amountCents => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
}

/// Point-in-time record of net worth, so the trend can be charted. Written
/// whenever a balance changes, at most once per day.
class NetWorthSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();

  /// Midnight of the day being recorded — one snapshot per profile per day.
  DateTimeColumn get date => dateTime()();
  IntColumn get totalAssetsCents => integer()();
  IntColumn get totalDebtCents => integer()();
  IntColumn get netWorthCents => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, date},
      ];
}

/// Saving toward something, or paying something off.
enum GoalType { savings, payoff }

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => textEnum<GoalType>()();
  IntColumn get targetAmountCents => integer()();
  IntColumn get currentAmountCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
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

/// How often a bill comes due.
enum BillFrequency { monthly, quarterly, annual, oneTime }

class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  IntColumn get amountCents => integer()();
  IntColumn get dueDay => integer()(); // 1-31, clamped to month length
  TextColumn get frequency =>
      textEnum<BillFrequency>().withDefault(const Constant('monthly'))();

  /// If true, the bill is charged automatically. Once its due day passes it
  /// is treated as paid with no manual check-off, and it never shows the
  /// overdue warning.
  BoolColumn get autopay => boolean().withDefault(const Constant(false))();

  /// Month it falls in. Required for annual and one-time bills; for
  /// quarterly it is the anchor month, repeating every three months.
  /// Unused for monthly bills.
  IntColumn get dueMonth => integer().nullable()();

  /// One-time bills only.
  IntColumn get dueYear => integer().nullable()();

  TextColumn get category => text().withDefault(const Constant('Other'))();
}

/// One row per bill per month it was paid for. "Paid" is derived from the
/// presence of a row for the current month, so status rolls over on its own
/// when the calendar month changes — nothing to reset by hand.
class BillPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  IntColumn get billId =>
      integer().references(Bills, #id, onDelete: KeyAction.cascade)();

  /// Midnight on the first day of the month this payment covers.
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get paidAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {billId, periodStart},
      ];
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

  /// Set when this entry was generated automatically because a paycheck was
  /// marked received — keeps the two in sync instead of double-entry.
  IntColumn get sourcePaycheckId =>
      integer().nullable().references(Paychecks, #id, onDelete: KeyAction.cascade)();

  /// Set when this entry was generated automatically because a bill was
  /// marked paid. Deleting the payment (or the bill) removes this entry.
  IntColumn get sourceBillPaymentId => integer()
      .nullable()
      .references(BillPayments, #id, onDelete: KeyAction.cascade)();
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

  /// True once you set [received] by hand. Automatic processing skips these
  /// rows, so overriding a paycheck (it was delayed, it never arrived) is
  /// not undone the next time the app opens.
  BoolColumn get receivedIsManual =>
      boolean().withDefault(const Constant(false))();

  /// Deleted by you. The row is kept rather than removed so the schedule
  /// that produced it doesn't just generate the same payday again; it is
  /// hidden everywhere in the UI.
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();

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
  BillPayments,
  CreditScoreSnapshots,
  BudgetEntries,
  BudgetTargets,
  CategoryRules,
  Payments,
  NetWorthSnapshots,
  Goals,
  PaycheckSchedules,
  Paychecks,
  PaycheckAllocations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(accounts);
            await m.addColumn(budgetEntries, budgetEntries.accountId);
          }
          if (from < 3) {
            await m.createTable(billPayments);
            // Carry any bills currently flagged paid into a payment record
            // for the current month, then drop the boolean column.
            final now = DateTime.now();
            final periodStart = DateTime(now.year, now.month);
            await customInsert(
              'INSERT INTO bill_payments '
              '(profile_id, bill_id, period_start, paid_at) '
              'SELECT profile_id, id, ?, ? FROM bills '
              'WHERE paid_this_month = 1',
              variables: [
                Variable.withInt(periodStart.millisecondsSinceEpoch ~/ 1000),
                Variable.withInt(now.millisecondsSinceEpoch ~/ 1000),
              ],
            );
            await m.addColumn(creditCards, creditCards.statementCloseDay);
            await m.addColumn(creditCards, creditCards.paymentDueDay);
          }
          if (from < 4) {
            // Bills gain a frequency. Anything previously marked recurring
            // becomes monthly; the rest become one-time in the current month.
            final now = DateTime.now();
            await m.addColumn(bills, bills.dueMonth);
            await m.addColumn(bills, bills.dueYear);
            await m.addColumn(bills, bills.frequency);
            await customUpdate(
              "UPDATE bills SET frequency = CASE WHEN recurring = 1 "
              "THEN 'monthly' ELSE 'oneTime' END, "
              'due_month = CASE WHEN recurring = 1 THEN NULL ELSE ?1 END, '
              'due_year = CASE WHEN recurring = 1 THEN NULL ELSE ?2 END',
              variables: [
                Variable.withInt(now.month),
                Variable.withInt(now.year),
              ],
              updates: {bills},
            );
          }
          if (from < 5) {
            await m.addColumn(bills, bills.autopay);
          }
          if (from < 6) {
            await m.addColumn(budgetEntries, budgetEntries.sourcePaycheckId);
          }
          if (from < 7) {
            await m.addColumn(
                budgetEntries, budgetEntries.sourceBillPaymentId);
          }
          if (from < 9) {
            await m.addColumn(paychecks, paychecks.dismissed);
          }
          if (from < 10) {
            await m.createTable(payments);
            await m.createTable(netWorthSnapshots);
            await m.createTable(goals);
            await m.addColumn(creditCards, creditCards.annualFeeDate);
          }
          if (from < 11) {
            // statementDay becomes statementCloseDay: same meaning, clearer
            // name now that a statement *balance* exists alongside it.
            if (from >= 3) {
              await m.renameColumn(
                  creditCards, 'statement_day', creditCards.statementCloseDay);
            }
            await m.addColumn(creditCards, creditCards.statementBalanceCents);
            await m.addColumn(
                creditCards, creditCards.minimumPaymentDueCents);
            // Seed the statement balance from the current balance so
            // utilization is not zero for everyone on first launch.
            await customUpdate(
              'UPDATE credit_cards SET statement_balance_cents = '
              'balance_cents WHERE statement_balance_cents = 0',
              updates: {creditCards},
            );
          }
          if (from < 8) {
            await m.addColumn(paychecks, paychecks.receivedIsManual);
            // Anything already marked received was marked by hand, so keep
            // it that way rather than letting automation reinterpret it.
            await customUpdate(
              'UPDATE paychecks SET received_is_manual = 1 WHERE received = 1',
              updates: {paychecks},
            );
          }
          if (from < 4) {
            // Rebuild bills once, after every column addition (including
            // autopay above), to drop columns no longer in the schema:
            // paid_this_month (replaced by BillPayments) and recurring
            // (replaced by frequency).
            await m.alterTable(TableMigration(bills));
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Where the database file lives, or null when it is in memory.
  Future<String?> get databasePath async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'homebase.sqlite'));
    return file.existsSync() ? file.path : null;
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'homebase.sqlite'));
      await _migrateFromRename(file);
      return NativeDatabase.createInBackground(file);
    });
  }

  /// The application id has changed twice as the project was renamed
  /// (homebase -> homebase_finance -> homebase_money), and on Linux and
  /// Android that id decides where getApplicationSupportDirectory points.
  /// Without this, a rename would look to the user like their data had been
  /// wiped. Each previous directory is checked newest first, so an install
  /// that skipped a rename still finds its database.
  static Future<void> _migrateFromRename(File newFile) async {
    if (newFile.existsSync()) return;
    try {
      final support = await getApplicationSupportDirectory();
      const previousIds = [
        'dev.homebase.homebase_finance',
        'dev.homebase.homebase',
      ];
      for (final id in previousIds) {
        final oldFile =
            File(p.join(support.parent.path, id, 'homebase.sqlite'));
        if (!oldFile.existsSync()) continue;
        await newFile.parent.create(recursive: true);
        await oldFile.copy(newFile.path);
        return;
      }
    } catch (_) {
      // Best-effort: if this fails, _openConnection just creates a fresh
      // database, same as any other first run.
    }
  }
}
