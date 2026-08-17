import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homebase_money/data/database.dart';
import 'package:homebase_money/data/repository.dart';
import 'package:homebase_money/util/payoff.dart';

/// The rule these tests protect: statement balance is what the bureaus see,
/// so it drives utilization only. Everything about money actually owed uses
/// the current balance.
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

  /// A card already paid down: owes $100 now, but $400 was reported.
  Future<int> addDivergedCard() => repo.upsertCard(
        CreditCardsCompanion.insert(
          profileId: profileId,
          name: 'Visa',
          creditLimitCents: 100000, // $1,000 limit
          balanceCents: const Value(10000), // $100 owed now
          statementBalanceCents: const Value(40000), // $400 reported
          apr: const Value(24),
        ),
      );

  test('utilization uses the reported statement balance, not the current one',
      () async {
    await addDivergedCard();
    final card = (await repo.watchCards(profileId: profileId).first).single;

    expect(HomebaseRepository.utilizationOf(card), 0.40,
        reason: '\$400 reported on a \$1,000 limit, not the \$100 owed now');
  });

  test('overall utilization sums reported balances', () async {
    await addDivergedCard();
    await repo.upsertCard(CreditCardsCompanion.insert(
      profileId: profileId,
      name: 'Amex',
      creditLimitCents: 100000,
      balanceCents: const Value(0),
      statementBalanceCents: const Value(20000),
    ));

    final cards = await repo.watchCards(profileId: profileId).first;
    expect(HomebaseRepository.overallUtilization(cards), 0.30,
        reason: '\$600 reported across \$2,000 of limits');
  });

  test('net worth and total debt use the current balance', () async {
    await addDivergedCard();

    final net = await repo.watchNetWorth(profileId: profileId).first;
    expect(net.debtsCents, 10000,
        reason: 'you owe \$100, regardless of what was reported');
    expect(net.netCents, -10000);
  });

  test('a payment reduces the current balance and leaves the reported one',
      () async {
    final id = await addDivergedCard();

    await repo.addPayment(
        profileId: profileId,
        accountType: PaymentAccountType.card,
        accountId: id,
        amountCents: 5000);

    final card = (await repo.watchCards(profileId: profileId).first).single;
    expect(card.balanceCents, 5000, reason: 'real money came off');
    expect(card.statementBalanceCents, 40000,
        reason: 'the reported figure does not change until the next '
            'statement closes');
    expect(HomebaseRepository.utilizationOf(card), 0.40,
        reason: 'so utilization is unchanged by paying today');
  });

  test('reminders use the current balance, since that is what is owed',
      () async {
    await repo.upsertCard(CreditCardsCompanion.insert(
      profileId: profileId,
      name: 'Visa',
      creditLimitCents: 100000,
      balanceCents: const Value(10000),
      statementBalanceCents: const Value(40000),
      paymentDueDay: const Value(17),
    ));

    final reminders = await repo.upcomingReminders(
        profileId: profileId, now: DateTime(2026, 8, 15));

    expect(reminders.single.amountCents, 10000,
        reason: 'the reminder is about money you owe now');
  });

  test('a card with nothing owed but a reported balance still counts toward '
      'utilization', () async {
    await repo.upsertCard(CreditCardsCompanion.insert(
      profileId: profileId,
      name: 'Paid off',
      creditLimitCents: 100000,
      balanceCents: const Value(0),
      statementBalanceCents: const Value(50000),
    ));
    final card = (await repo.watchCards(profileId: profileId).first).single;

    expect(HomebaseRepository.utilizationOf(card), 0.50);
    expect((await repo.watchNetWorth(profileId: profileId).first).debtsCents,
        0);
  });

  test('the payoff simulator projects the current balance', () {
    // $100 owed at 24% APR clears fast; the $400 reported figure would not.
    final projection = simulatePayoff(
        balanceCents: 10000, apr: 24, monthlyPaymentCents: 5000)!;
    expect(projection.months, lessThanOrEqualTo(3));
  });

  test('a real minimum payment is preferred over the estimate', () async {
    await repo.upsertCard(CreditCardsCompanion.insert(
      profileId: profileId,
      name: 'Visa',
      creditLimitCents: 100000,
      balanceCents: const Value(50000),
      minimumPaymentDueCents: const Value(3500),
      apr: const Value(24),
    ));
    final card = (await repo.watchCards(profileId: profileId).first).single;

    expect(card.minimumPaymentDueCents, 3500);
    // The estimate would have been different, so the stored one matters.
    expect(
        estimateCardMinimumPayment(
            balanceCents: card.balanceCents, apr: card.apr),
        isNot(3500));
  });
}
