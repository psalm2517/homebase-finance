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

  test('marking a paycheck received creates a matching income entry',
      () async {
    final id = await repo.upsertPaycheck(PaychecksCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        date: DateTime(2026, 8, 15),
        amountCents: 185000));

    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      received: const Value(true),
    ));

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries.length, 1);
    expect(entries.single.type, EntryType.income);
    expect(entries.single.amountCents, 185000);
    expect(entries.single.sourcePaycheckId, id);
  });

  test('a bonus is included in the linked entry amount', () async {
    final id = await repo.upsertPaycheck(PaychecksCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        date: DateTime(2026, 8, 15),
        amountCents: 185000));

    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      bonusCents: const Value(50000),
      received: const Value(true),
    ));

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries.single.amountCents, 235000);
  });

  test('un-marking received removes the linked entry', () async {
    final id = await repo.upsertPaycheck(PaychecksCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        date: DateTime(2026, 8, 15),
        amountCents: 185000));
    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      received: const Value(true),
    ));

    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      received: const Value(false),
    ));

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries, isEmpty);
  });

  test('re-saving a received paycheck updates the entry instead of '
      'duplicating it', () async {
    final id = await repo.upsertPaycheck(PaychecksCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        date: DateTime(2026, 8, 15),
        amountCents: 185000));
    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      received: const Value(true),
    ));
    // Bonus added after the fact, still received.
    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      bonusCents: const Value(10000),
      received: const Value(true),
    ));

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries.length, 1, reason: 'same entry updated, not duplicated');
    expect(entries.single.amountCents, 195000);
  });

  test('deleting a paycheck removes its linked entry', () async {
    final id = await repo.upsertPaycheck(PaychecksCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        date: DateTime(2026, 8, 15),
        amountCents: 185000));
    await repo.upsertPaycheck(PaychecksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: const Value('Day job'),
      date: Value(DateTime(2026, 8, 15)),
      amountCents: const Value(185000),
      received: const Value(true),
    ));

    await repo.deletePaycheck(profileId: profileId, id: id);

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries, isEmpty);
  });

  test('schedule-generated paychecks start unreceived with no entry',
      () async {
    await repo.upsertSchedule(PaycheckSchedulesCompanion.insert(
        profileId: profileId,
        name: 'Day job',
        frequency: PayFrequency.biweekly,
        anchorDate: DateTime(2026, 8, 7),
        amountCents: 185000));
    await repo.generateDuePaychecks(
        profileId: profileId, until: DateTime(2026, 8, 31));

    final entries = await repo
        .watchBudgetForMonth(profileId: profileId, month: DateTime(2026, 8))
        .first;
    expect(entries, isEmpty,
        reason: 'generated checks are not received yet, so no entry exists');
  });
}
