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

  group('bill paid status is per month', () {
    test('marking paid in one month leaves the next month unpaid', () async {
      final billId = await repo.upsertBill(BillsCompanion.insert(
          profileId: profileId, name: 'Rent', amountCents: 145000, dueDay: 1));
      final august = DateTime(2026, 8);
      final september = DateTime(2026, 9);

      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: august, paid: true);

      final aug = await repo
          .watchBillsForMonth(profileId: profileId, month: august)
          .first;
      final sep = await repo
          .watchBillsForMonth(profileId: profileId, month: september)
          .first;

      expect(aug.single.paid, isTrue, reason: 'paid for August');
      expect(sep.single.paid, isFalse,
          reason: 'September resets on its own — no manual reset');
    });

    test('unmarking removes the payment for that month only', () async {
      final billId = await repo.upsertBill(BillsCompanion.insert(
          profileId: profileId, name: 'Power', amountCents: 9000, dueDay: 12));
      final july = DateTime(2026, 7);
      final august = DateTime(2026, 8);
      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: july, paid: true);
      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: august, paid: true);

      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: august, paid: false);

      expect(
          (await repo
                  .watchBillsForMonth(profileId: profileId, month: july)
                  .first)
              .single
              .paid,
          isTrue,
          reason: 'history for July is kept');
      expect(
          (await repo
                  .watchBillsForMonth(profileId: profileId, month: august)
                  .first)
              .single
              .paid,
          isFalse);
    });

    test('marking paid twice for the same month does not duplicate', () async {
      final billId = await repo.upsertBill(BillsCompanion.insert(
          profileId: profileId, name: 'Water', amountCents: 4000, dueDay: 5));
      final month = DateTime(2026, 8);
      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: month, paid: true);
      await repo.setBillPaid(
          profileId: profileId, billId: billId, month: month, paid: true);

      final rows =
          await repo.watchBillsForMonth(profileId: profileId, month: month).first;
      expect(rows.length, 1);
      expect(rows.single.paid, isTrue);
    });
  });

  group('statement cycle dates', () {
    CreditCard card({int? statementDay, int? dueDay}) => CreditCard(
          id: 1,
          profileId: 1,
          name: 'Visa',
          balanceCents: 0,
          creditLimitCents: 100000,
          apr: 22.99,
          annualFeeCents: 0,
          monthlyFeeCents: 0,
          statementDay: statementDay,
          paymentDueDay: dueDay,
        );

    test('next close is later this month when the day has not passed', () {
      final cycle = HomebaseRepository.cycleFor(card(statementDay: 20),
          now: DateTime(2026, 8, 14));
      expect(cycle.statementCloses, DateTime(2026, 8, 20));
      expect(cycle.daysToClose, 6);
    });

    test('next close rolls into next month once the day has passed', () {
      final cycle = HomebaseRepository.cycleFor(card(statementDay: 5),
          now: DateTime(2026, 8, 14));
      expect(cycle.statementCloses, DateTime(2026, 9, 5));
    });

    test('a 31st cycle day clamps to the last day of a short month', () {
      final cycle = HomebaseRepository.cycleFor(card(statementDay: 31),
          now: DateTime(2026, 2, 10));
      expect(cycle.statementCloses, DateTime(2026, 2, 28));
    });

    test('cards without a configured cycle report nulls', () {
      final cycle = HomebaseRepository.cycleFor(card());
      expect(cycle.statementCloses, isNull);
      expect(cycle.paymentDue, isNull);
    });
  });
}
