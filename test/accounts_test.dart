import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homebase/data/database.dart';
import 'package:homebase/data/repository.dart';

void main() {
  late AppDatabase db;
  late HomebaseRepository repo;
  late int profileId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HomebaseRepository(db);
    profileId = await repo.createProfile(
        ProfilesCompanion.insert(name: 'Owner', isAdmin: const Value(true)));
  });

  tearDown(() => db.close());

  test('net worth is assets minus card and loan debt', () async {
    await repo.upsertAccount(AccountsCompanion.insert(
        profileId: profileId,
        name: 'Checking',
        type: AccountType.checking,
        balanceCents: const Value(250000)));
    await repo.upsertAccount(AccountsCompanion.insert(
        profileId: profileId,
        name: 'Savings',
        type: AccountType.savings,
        balanceCents: const Value(1000000)));
    await repo.upsertCard(CreditCardsCompanion.insert(
        profileId: profileId,
        name: 'Visa',
        creditLimitCents: 500000,
        balanceCents: const Value(120000)));
    await repo.upsertLoan(LoansCompanion.insert(
        profileId: profileId,
        name: 'Car',
        balanceCents: 800000,
        originalAmountCents: 1500000));

    final net = await repo.watchNetWorth(profileId: profileId).first;
    expect(net.assetsCents, 1250000);
    expect(net.debtsCents, 920000);
    expect(net.netCents, 330000);
  });

  test('net worth ignores other profiles', () async {
    final other = await repo.createProfile(ProfilesCompanion.insert(name: 'Mom'));
    await repo.upsertAccount(AccountsCompanion.insert(
        profileId: other,
        name: 'Her savings',
        type: AccountType.savings,
        balanceCents: const Value(9999999)));

    final net = await repo.watchNetWorth(profileId: profileId).first;
    expect(net.assetsCents, 0);
    expect(net.netCents, 0);
  });

  test('cashflow buckets income and expenses into the current month',
      () async {
    final now = DateTime.now();
    await repo.addBudgetEntry(BudgetEntriesCompanion.insert(
        profileId: profileId,
        date: now,
        amountCents: 300000,
        type: EntryType.income));
    await repo.addBudgetEntry(BudgetEntriesCompanion.insert(
        profileId: profileId,
        date: now,
        amountCents: 45000,
        type: EntryType.expense));

    final flow = await repo.watchCashflow(profileId: profileId).first;
    final current = flow.last;
    expect(current.month.month, now.month);
    expect(current.incomeCents, 300000);
    expect(current.expenseCents, 45000);
  });
}
