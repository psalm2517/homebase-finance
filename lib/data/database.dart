import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Whether a budget entry adds to or subtracts from the month.
enum EntryType { income, expense }

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
  RealColumn get balance => real().withDefault(const Constant(0))();
  RealColumn get creditLimit => real()(); // `limit` is an SQL keyword
  RealColumn get apr => real().withDefault(const Constant(0))();
  RealColumn get annualFee => real().withDefault(const Constant(0))();
  RealColumn get monthlyFee => real().withDefault(const Constant(0))();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  RealColumn get balance => real()();
  RealColumn get originalAmount => real()();
  RealColumn get apr => real().withDefault(const Constant(0))();
  RealColumn get monthlyPayment => real().withDefault(const Constant(0))();
}

class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  RealColumn get amount => real()();
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
  RealColumn get amount => real()();
  TextColumn get type => textEnum<EntryType>()();
}

@DriftDatabase(tables: [
  Profiles,
  CreditCards,
  Loans,
  Bills,
  CreditScoreSnapshots,
  BudgetEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
