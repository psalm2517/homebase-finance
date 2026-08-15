import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homebase/data/database.dart';
import 'package:homebase/data/reminder.dart';
import 'package:homebase/data/repository.dart';

void main() {
  late AppDatabase db;
  late HomebaseRepository repo;
  late int profileId;
  // A fixed "today" so the tests do not drift with the real calendar.
  final today = DateTime(2026, 8, 15);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HomebaseRepository(db);
    profileId = await repo.createProfile(
        ProfilesCompanion.insert(name: 'Owner', isAdmin: const Value(true)));
  });

  tearDown(() => db.close());

  Future<int> addBill(String name, int dueDay,
          {bool autopay = false, int cents = 9400}) =>
      repo.upsertBill(BillsCompanion.insert(
        profileId: profileId,
        name: name,
        amountCents: cents,
        dueDay: dueDay,
        autopay: Value(autopay),
      ));

  test('a bill due within three days is reminded', () async {
    await addBill('MetroPCS', 18); // 3 days out

    final reminders =
        await repo.upcomingReminders(profileId: profileId, now: today);

    expect(reminders.length, 1);
    expect(reminders.single.title, 'MetroPCS');
    expect(reminders.single.kind, ReminderKind.bill);
    expect(reminders.single.daysUntil(today), 3);
  });

  test('a bill further out is not reminded yet', () async {
    await addBill('Later', 25);

    expect(await repo.upcomingReminders(profileId: profileId, now: today),
        isEmpty);
  });

  test('autopay bills are skipped — nothing for you to do', () async {
    await addBill('Spotify', 17, autopay: true);

    expect(await repo.upcomingReminders(profileId: profileId, now: today),
        isEmpty);
  });

  test('a bill already paid is not reminded', () async {
    final id = await addBill('MetroPCS', 18);
    await repo.setBillPaid(
        profileId: profileId,
        billId: id,
        month: DateTime(2026, 8),
        paid: true);

    expect(await repo.upcomingReminders(profileId: profileId, now: today),
        isEmpty);
  });

  test('a card payment coming due is reminded, with its balance', () async {
    await repo.upsertCard(CreditCardsCompanion.insert(
        profileId: profileId,
        name: 'Visa',
        creditLimitCents: 500000,
        balanceCents: const Value(120000),
        paymentDueDay: const Value(17)));

    final reminders =
        await repo.upcomingReminders(profileId: profileId, now: today);

    expect(reminders.single.kind, ReminderKind.cardPayment);
    expect(reminders.single.amountCents, 120000);
  });

  test('a card with no balance is not reminded', () async {
    await repo.upsertCard(CreditCardsCompanion.insert(
        profileId: profileId,
        name: 'Unused',
        creditLimitCents: 500000,
        paymentDueDay: const Value(17)));

    expect(await repo.upcomingReminders(profileId: profileId, now: today),
        isEmpty);
  });

  test('reminders are sorted soonest first', () async {
    await addBill('Later', 18);
    await addBill('Sooner', 16);

    final reminders =
        await repo.upcomingReminders(profileId: profileId, now: today);

    expect(reminders.map((r) => r.title).toList(), ['Sooner', 'Later']);
  });

  test('reminders never cross profiles', () async {
    final other =
        await repo.createProfile(ProfilesCompanion.insert(name: 'Mom'));
    await addBill('Mine', 17);

    expect(await repo.upcomingReminders(profileId: other, now: today),
        isEmpty);
  });

  test('dedupe keys are stable per reminder per day', () {
    final a = Reminder(
        kind: ReminderKind.bill,
        title: 'X',
        amountCents: 100,
        date: DateTime(2026, 8, 18),
        sourceId: 1);
    final b = Reminder(
        kind: ReminderKind.bill,
        title: 'X',
        amountCents: 100,
        date: DateTime(2026, 8, 18),
        sourceId: 1);
    expect(a.dedupeKey, b.dedupeKey);
  });
}
