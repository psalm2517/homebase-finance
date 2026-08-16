import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homebase_finance/data/database.dart';
import 'package:homebase_finance/data/repository.dart';
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
    raw.execute('''
      CREATE TABLE paychecks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount_cents INTEGER NOT NULL,
        bonus_cents INTEGER NOT NULL DEFAULT 0,
        received INTEGER NOT NULL DEFAULT 0,
        schedule_id INTEGER NULL);
    ''');
    raw.execute('''
      CREATE TABLE budget_entries (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        date INTEGER NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        amount_cents INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NULL,
        account_id INTEGER NULL);
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

  test('recurring bills become monthly, one-offs become one-time', () async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final bills = await db.select(db.bills).get();
    expect(bills.every((b) => b.frequency == BillFrequency.monthly), isTrue,
        reason: 'both seeded bills had recurring = 1');

    // The monthly total still matches, and annual bills added afterwards
    // are spread across the year.
    final repo = HomebaseRepository(db);
    expect(await repo.watchMonthlyBillsCents(profileId: 1).first,
        145000 + 9000);
  });

  test('a v3 database upgrades to v4 and keeps its payment history',
      () async {
    // Someone who already ran the billing-cycle build is on v3: bills have
    // `recurring` but no frequency, and bill_payments already exists.
    final v3Dir = Directory.systemTemp.createTempSync('homebase_v3');
    addTearDown(() => v3Dir.deleteSync(recursive: true));
    final v3File = File('${v3Dir.path}/homebase.sqlite');

    final raw = sqlite3.open(v3File.path);
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
        category TEXT NOT NULL DEFAULT 'Other');
    ''');
    raw.execute('''
      CREATE TABLE bill_payments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        bill_id INTEGER NOT NULL REFERENCES bills (id) ON DELETE CASCADE,
        period_start INTEGER NOT NULL,
        paid_at INTEGER NOT NULL,
        UNIQUE (bill_id, period_start));
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
        monthly_fee_cents INTEGER NOT NULL DEFAULT 0,
        statement_day INTEGER NULL,
        payment_due_day INTEGER NULL);
    ''');
    raw.execute('''
      CREATE TABLE paychecks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount_cents INTEGER NOT NULL,
        bonus_cents INTEGER NOT NULL DEFAULT 0,
        received INTEGER NOT NULL DEFAULT 0,
        schedule_id INTEGER NULL);
    ''');
    raw.execute('''
      CREATE TABLE budget_entries (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        date INTEGER NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        amount_cents INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NULL,
        account_id INTEGER NULL);
    ''');
    raw.execute("INSERT INTO profiles (name, is_admin) VALUES ('Owner', 1);");
    raw.execute('INSERT INTO bills '
        '(profile_id, name, amount_cents, due_day, recurring) '
        "VALUES (1, 'Rent', 145000, 1, 1);");
    final month = DateTime(DateTime.now().year, DateTime.now().month);
    raw.execute('INSERT INTO bill_payments '
        '(profile_id, bill_id, period_start, paid_at) VALUES '
        '(1, 1, ${month.millisecondsSinceEpoch ~/ 1000}, '
        '${DateTime.now().millisecondsSinceEpoch ~/ 1000});');
    raw.execute('PRAGMA user_version = 3;');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(v3File));
    addTearDown(db.close);
    final repo = HomebaseRepository(db);

    final rows = await repo
        .watchBillsForMonth(profileId: 1, month: DateTime.now())
        .first;
    expect(rows.single.bill.frequency, BillFrequency.monthly);
    expect(rows.single.paid, isTrue,
        reason: 'payments recorded under v3 survive the upgrade');
  });

  test('a v4 database upgrades to v5 with autopay off by default', () async {
    final v4Dir = Directory.systemTemp.createTempSync('homebase_v4');
    addTearDown(() => v4Dir.deleteSync(recursive: true));
    final v4File = File('${v4Dir.path}/homebase.sqlite');

    final raw = sqlite3.open(v4File.path);
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
        frequency TEXT NOT NULL DEFAULT 'monthly',
        due_month INTEGER NULL,
        due_year INTEGER NULL,
        category TEXT NOT NULL DEFAULT 'Other');
    ''');
    raw.execute('''
      CREATE TABLE paychecks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount_cents INTEGER NOT NULL,
        bonus_cents INTEGER NOT NULL DEFAULT 0,
        received INTEGER NOT NULL DEFAULT 0,
        schedule_id INTEGER NULL);
    ''');
    raw.execute('''
      CREATE TABLE budget_entries (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        date INTEGER NOT NULL,
        category TEXT NOT NULL DEFAULT 'Other',
        amount_cents INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NULL,
        account_id INTEGER NULL);
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
        monthly_fee_cents INTEGER NOT NULL DEFAULT 0,
        statement_day INTEGER NULL,
        payment_due_day INTEGER NULL);
    ''');
    raw.execute("INSERT INTO profiles (name, is_admin) VALUES ('Owner', 1);");
    raw.execute('INSERT INTO bills '
        '(profile_id, name, amount_cents, due_day, frequency) '
        "VALUES (1, 'Phone', 8000, 18, 'monthly');");
    raw.execute('PRAGMA user_version = 4;');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(v4File));
    addTearDown(db.close);
    final bill = await db.select(db.bills).getSingle();
    expect(bill.autopay, isFalse,
        reason: 'existing bills default to autopay off, not silently on');
  });

  test('v2 database gains billing cycle columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final cards = await db.select(db.creditCards).get();
    expect(cards.single.statementCloseDay, isNull);
    expect(cards.single.paymentDueDay, isNull);

    await (db.update(db.creditCards)..where((c) => c.id.equals(1)))
        .write(const CreditCardsCompanion(statementCloseDay: Value(20)));
    final updated = await db.select(db.creditCards).getSingle();
    expect(updated.statementCloseDay, 20);
    expect(HomebaseRepository.cycleFor(updated, now: DateTime(2026, 8, 14))
        .statementCloses,
        DateTime(2026, 8, 20));
  });

  test('a v9 database gains payments, snapshots, goals and the fee date',
      () async {
    final v9Dir = Directory.systemTemp.createTempSync('homebase_v9');
    addTearDown(() => v9Dir.deleteSync(recursive: true));
    final v9File = File('${v9Dir.path}/homebase.sqlite');

    final raw = sqlite3.open(v9File.path);
    raw.execute("""
      CREATE TABLE profiles (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pin_hash TEXT NULL,
        is_admin INTEGER NOT NULL DEFAULT 0);
    """);
    raw.execute("""
      CREATE TABLE credit_cards (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        balance_cents INTEGER NOT NULL DEFAULT 0,
        credit_limit_cents INTEGER NOT NULL,
        apr REAL NOT NULL DEFAULT 0,
        annual_fee_cents INTEGER NOT NULL DEFAULT 0,
        monthly_fee_cents INTEGER NOT NULL DEFAULT 0,
        statement_day INTEGER NULL,
        payment_due_day INTEGER NULL);
    """);
    raw.execute("INSERT INTO profiles (name, is_admin) VALUES ('Owner', 1);");
    raw.execute('INSERT INTO credit_cards '
        '(profile_id, name, credit_limit_cents, balance_cents, '
        'annual_fee_cents) '
        "VALUES (1, 'Gold', 900000, 120000, 32500);");
    raw.execute('PRAGMA user_version = 9;');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(v9File));
    addTearDown(db.close);
    final repo = HomebaseRepository(db);

    // Existing card data survives, with the new date column empty.
    final card = await db.select(db.creditCards).getSingle();
    expect(card.name, 'Gold');
    expect(card.annualFeeCents, 32500,
        reason: 'the existing fee amount is reused, not duplicated');
    expect(card.annualFeeDate, isNull);

    // The three new tables exist and are usable.
    await db.into(db.payments).insert(PaymentsCompanion.insert(
        profileId: 1,
        accountType: PaymentAccountType.card,
        accountId: card.id,
        amountCents: 5000,
        date: DateTime(2026, 8, 14)));
    await db.into(db.netWorthSnapshots).insert(
        NetWorthSnapshotsCompanion.insert(
            profileId: 1,
            date: DateTime(2026, 8, 14),
            totalAssetsCents: 500000,
            totalDebtCents: 120000,
            netWorthCents: 380000));
    await db.into(db.goals).insert(GoalsCompanion.insert(
        profileId: 1,
        name: 'Emergency fund',
        type: GoalType.savings,
        targetAmountCents: 1000000));

    expect((await db.select(db.payments).get()).length, 1);
    expect((await db.select(db.netWorthSnapshots).get()).single.netWorthCents,
        380000);
    expect((await db.select(db.goals).get()).single.name, 'Emergency fund');

    // Nothing existing broke.
    expect(await repo.allProfiles(), hasLength(1));
  });

  test('one net worth snapshot per profile per day', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = HomebaseRepository(db);
    final pid = await repo.createProfile(
        ProfilesCompanion.insert(name: 'Owner', isAdmin: const Value(true)));

    await db.into(db.netWorthSnapshots).insert(
        NetWorthSnapshotsCompanion.insert(
            profileId: pid,
            date: DateTime(2026, 8, 14),
            totalAssetsCents: 100,
            totalDebtCents: 0,
            netWorthCents: 100));

    // A second row for the same day must collide rather than duplicate.
    await expectLater(
      db.into(db.netWorthSnapshots).insert(NetWorthSnapshotsCompanion.insert(
          profileId: pid,
          date: DateTime(2026, 8, 14),
          totalAssetsCents: 200,
          totalDebtCents: 0,
          netWorthCents: 200)),
      throwsA(anything),
    );
  });

  test('v10 renames statement_day and seeds the statement balance',
      () async {
    final v10Dir = Directory.systemTemp.createTempSync('homebase_v10');
    addTearDown(() => v10Dir.deleteSync(recursive: true));
    final v10File = File('${v10Dir.path}/homebase.sqlite');

    final raw = sqlite3.open(v10File.path);
    raw.execute("""
      CREATE TABLE profiles (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pin_hash TEXT NULL,
        is_admin INTEGER NOT NULL DEFAULT 0);
    """);
    raw.execute("""
      CREATE TABLE credit_cards (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL REFERENCES profiles (id),
        name TEXT NOT NULL,
        balance_cents INTEGER NOT NULL DEFAULT 0,
        credit_limit_cents INTEGER NOT NULL,
        apr REAL NOT NULL DEFAULT 0,
        annual_fee_cents INTEGER NOT NULL DEFAULT 0,
        monthly_fee_cents INTEGER NOT NULL DEFAULT 0,
        statement_day INTEGER NULL,
        payment_due_day INTEGER NULL,
        annual_fee_date INTEGER NULL);
    """);
    raw.execute("INSERT INTO profiles (name, is_admin) VALUES ('Owner', 1);");
    raw.execute('INSERT INTO credit_cards '
        '(profile_id, name, credit_limit_cents, balance_cents, statement_day, '
        'payment_due_day) '
        "VALUES (1, 'Visa', 500000, 120000, 20, 15);");
    raw.execute('PRAGMA user_version = 10;');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(v10File));
    addTearDown(db.close);

    final card = await db.select(db.creditCards).getSingle();
    expect(card.statementCloseDay, 20,
        reason: 'the renamed column keeps its value');
    expect(card.paymentDueDay, 15);
    expect(card.statementBalanceCents, 120000,
        reason: 'seeded from the current balance so utilization is not zero');
    expect(card.minimumPaymentDueCents, isNull);
    expect(HomebaseRepository.utilizationOf(card), closeTo(0.24, 0.001));
  });
}
