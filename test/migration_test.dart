import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homebase/data/database.dart';
import 'package:homebase/data/repository.dart';
import 'package:sqlite3/sqlite3.dart';

/// Builds a schema-v2 file (the shape shipped before billing cycles) so the
/// v2 -> v3 upgrade is exercised the way a real user's database will be.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('homebase_migration');
    file = File('${dir.path}/homebase.sqlite');

    final raw = sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE profiles (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pin_hash TEXT NULL,
        is_admin INTEGER NOT NULL DEFAULT 0);
    ''');
    raw.execute('''
      CREATE TABLE bills (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        due_day INTEGER NOT NULL,
        recurring INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL DEFAULT 'Other',
        paid_this_month INTEGER NOT NULL DEFAULT 0);
    ''');
    raw.execute('''
      CREATE TABLE credit_cards (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        balance_cents INTEGER NOT NULL DEFAULT 0,
        credit_limit_cents INTEGER NOT NULL,
        apr REAL NOT NULL DEFAULT 0,
        annual_fee_cents INTEGER NOT NULL DEFAULT 0,
        monthly_fee_cents INTEGER NOT NULL DEFAULT 0);
    ''');
    raw.execute(
        "INSERT INTO profiles (name, is_admin) VALUES ('Owner', 1);");
    raw.execute('INSERT INTO bills '
        '(profile_id, name, amount_cents, due_day, paid_this_month) '
        "VALUES (1, 'Rent', 145000, 1, 1);");
    raw.execute('INSERT INTO bills '
        '(profile_id, name, amount_cents, due_day, paid_this_month) '
        "VALUES (1, 'Power', 9000, 12, 0);");
    raw.execute('INSERT INTO credit_cards '
        '(profile_id, name, credit_limit_cents) '
        "VALUES (1, 'Visa', 500000);");
    raw.execute('PRAGMA user_version = 2;');
    raw.close();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('v2 database upgrades and keeps paid bills paid for this month',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    final repo = HomebaseRepository(db);

    final rows = await repo
        .watchBillsForMonth(profileId: 1, month: DateTime.now())
        .first;

    expect(rows.length, 2);
    final rent = rows.firstWhere((r) => r.bill.name == 'Rent');
    final power = rows.firstWhere((r) => r.bill.name == 'Power');
    expect(rent.paid, isTrue,
        reason: 'a bill flagged paid before the upgrade stays paid');
    expect(power.paid, isFalse);

    // Next month starts clean without any manual reset.
    final now = DateTime.now();
    final next = await repo
        .watchBillsForMonth(
            profileId: 1, month: DateTime(now.year, now.month + 1))
        .first;
    expect(next.every((r) => !r.paid), isTrue);
  });

  test('v2 database gains billing cycle columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final cards = await db.select(db.creditCards).get();
    expect(cards.single.statementDay, isNull);
    expect(cards.single.paymentDueDay, isNull);

    await (db.update(db.creditCards)..where((c) => c.id.equals(1)))
        .write(const CreditCardsCompanion(statementDay: Value(20)));
    final updated = await db.select(db.creditCards).getSingle();
    expect(updated.statementDay, 20);
    expect(HomebaseRepository.cycleFor(updated, now: DateTime(2026, 8, 14))
        .statementCloses,
        DateTime(2026, 8, 20));
  });
}
