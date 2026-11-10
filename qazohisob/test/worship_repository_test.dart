import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/shared/data/worship_repository.dart';
import 'package:qazohisob/shared/domain/exceptions.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late WorshipRepository repo;
  late TestClock clock;

  setUp(() {
    db = memoryDb();
    clock = TestClock(DateTime(2026, 11, 10, 9, 30));
    repo = WorshipRepository(db, now: clock.call);
  });

  tearDown(() => db.close());

  group('prayer debt', () {
    test('starts empty for every prayer', () async {
      final s = await repo.loadSnapshot();
      for (final t in PrayerType.values) {
        expect(s.prayer(t).remaining, 0);
        expect(s.prayer(t).totalDebt, 0);
      }
    });

    test('remaining = initial + added - completed', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        100,
        prayerType: PrayerType.bomdod,
      );
      await repo.addPrayerDebt(PrayerType.bomdod, 20);
      await repo.completePrayer(PrayerType.bomdod, 30);
      final s = (await repo.loadSnapshot()).prayer(PrayerType.bomdod);
      expect(s.initial, 100);
      expect(s.added, 20);
      expect(s.completed, 30);
      expect(s.remaining, 90);
      expect(s.progress, closeTo(30 / 120, 1e-9));
    });

    test('debts are tracked separately per prayer', () async {
      await repo.setInitialDebts(
        prayers: {PrayerType.bomdod: 10, PrayerType.asr: 5},
      );
      await repo.completePrayer(PrayerType.asr, 2);
      final s = await repo.loadSnapshot();
      expect(s.prayer(PrayerType.bomdod).remaining, 10);
      expect(s.prayer(PrayerType.asr).remaining, 3);
      expect(s.prayer(PrayerType.peshin).remaining, 0);
    });

    test('completing more than owed requires confirmation', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        3,
        prayerType: PrayerType.shom,
      );
      expect(
        () => repo.completePrayer(PrayerType.shom, 5),
        throwsA(
          isA<ExceedsDebtException>()
              .having((e) => e.remaining, 'remaining', 3)
              .having((e) => e.excess, 'excess', 2),
        ),
      );
      // Nothing was written.
      final s = (await repo.loadSnapshot()).prayer(PrayerType.shom);
      expect(s.completed, 0);
      expect(s.remaining, 3);
    });

    test('confirmed excess adds linked debt and never goes negative', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        3,
        prayerType: PrayerType.shom,
      );
      final result = await repo.completePrayer(
        PrayerType.shom,
        5,
        allowExceed: true,
      );
      expect(result.addedForExcess, 2);
      var s = (await repo.loadSnapshot()).prayer(PrayerType.shom);
      expect(s.remaining, 0);
      expect(s.balance, 0);
      expect(s.completed, 5);

      // Undoing the completion also undoes the linked excess debt.
      await repo.reverseRecord(result.record.id);
      s = (await repo.loadSnapshot()).prayer(PrayerType.shom);
      expect(s.remaining, 3);
      expect(s.added, 0);
    });

    test('rejects zero and negative quantities', () async {
      expect(
        () => repo.addPrayerDebt(PrayerType.asr, 0),
        throwsA(isA<DebtValidationException>()),
      );
      expect(
        () => repo.completePrayer(PrayerType.asr, -1),
        throwsA(isA<DebtValidationException>()),
      );
      expect(
        () => repo.setInitialDebt(
          WorshipKind.prayer,
          -5,
          prayerType: PrayerType.asr,
        ),
        throwsA(isA<DebtValidationException>()),
      );
    });

    test('initial debt cannot be lowered below what was completed', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        10,
        prayerType: PrayerType.peshin,
      );
      await repo.completePrayer(PrayerType.peshin, 8);
      expect(
        () => repo.setInitialDebt(
          WorshipKind.prayer,
          5,
          prayerType: PrayerType.peshin,
        ),
        throwsA(isA<DebtValidationException>()),
      );
      await repo.setInitialDebt(
        WorshipKind.prayer,
        8,
        prayerType: PrayerType.peshin,
      );
      final s = (await repo.loadSnapshot()).prayer(PrayerType.peshin);
      expect(s.remaining, 0);
    });

    test('changing initial debt writes an audit record', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        10,
        prayerType: PrayerType.asr,
      );
      await repo.setInitialDebt(
        WorshipKind.prayer,
        12,
        prayerType: PrayerType.asr,
      );
      final records = (await repo.loadSnapshot()).recordsForPrayer(
        PrayerType.asr,
      );
      expect(
        records.where((r) => r.action == RecordAction.initialSet),
        hasLength(2),
      );
      // Audit records never change the totals.
      expect((await repo.loadSnapshot()).prayer(PrayerType.asr).remaining, 12);
    });
  });

  group('fasting debt', () {
    test('one completed day reduces remaining by exactly one', () async {
      await repo.setInitialDebt(WorshipKind.fast, 30);
      await repo.addFastingDebt(2);
      await repo.completeFast(date: DateTime(2026, 11, 2));
      final s = (await repo.loadSnapshot()).fasting;
      expect(s.totalDebt, 32);
      expect(s.completed, 1);
      expect(s.remaining, 31);
    });

    test('stores the selected completion date (date only)', () async {
      await repo.setInitialDebt(WorshipKind.fast, 5);
      final r = await repo.completeFast(date: DateTime(2026, 10, 7, 18, 45));
      expect(r.record.completedDate, DateTime(2026, 10, 7));
      expect(r.record.createdAt, clock.value);
    });

    test('cannot exceed fasting debt without confirmation', () async {
      expect(() => repo.completeFast(), throwsA(isA<ExceedsDebtException>()));
    });
  });

  group('undo and corrections', () {
    test('reversing keeps the record in history', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        10,
        prayerType: PrayerType.xufton,
      );
      final r = await repo.completePrayer(PrayerType.xufton, 4);
      await repo.reverseRecord(r.record.id);
      final snap = await repo.loadSnapshot();
      expect(snap.prayer(PrayerType.xufton).remaining, 10);
      final stored = snap.records.firstWhere((x) => x.id == r.record.id);
      expect(stored.reversedAt, isNotNull);
    });

    test('restoring a reversed record applies it again', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        10,
        prayerType: PrayerType.xufton,
      );
      final r = await repo.completePrayer(PrayerType.xufton, 4);
      await repo.reverseRecord(r.record.id);
      await repo.restoreRecord(r.record.id);
      expect(
        (await repo.loadSnapshot()).prayer(PrayerType.xufton).remaining,
        6,
      );
    });

    test(
      'cannot reverse added debt if that makes remaining negative',
      () async {
        final added = await repo.addPrayerDebt(PrayerType.asr, 5);
        await repo.completePrayer(PrayerType.asr, 4);
        expect(
          () => repo.reverseRecord(added.id),
          throwsA(isA<DebtValidationException>()),
        );
        expect((await repo.loadSnapshot()).prayer(PrayerType.asr).remaining, 1);
      },
    );

    test('audit records cannot be reversed', () async {
      await repo.setInitialDebt(WorshipKind.fast, 3);
      final audit = (await repo.loadSnapshot()).fastingRecords.single;
      expect(
        () => repo.reverseRecord(audit.id),
        throwsA(isA<DebtValidationException>()),
      );
    });

    test('editing quantity is validated against the debt', () async {
      await repo.setInitialDebt(WorshipKind.fast, 3);
      final r = await repo.completeFast();
      expect(
        () => repo.editRecord(r.record.id, quantity: 5),
        throwsA(isA<DebtValidationException>()),
      );
      await repo.editRecord(
        r.record.id,
        quantity: 2,
        date: DateTime(2026, 9, 1),
        note: ' tuzatildi ',
      );
      final stored = (await repo.loadSnapshot()).records.firstWhere(
        (x) => x.id == r.record.id,
      );
      expect(stored.quantity, 2);
      expect(stored.completedDate, DateTime(2026, 9, 1));
      expect(stored.note, 'tuzatildi');
      expect(stored.editedAt, isNotNull);
    });
  });

  group('duplicates and persistence', () {
    test('the same entry key is only stored once', () async {
      await repo.setInitialDebt(
        WorshipKind.prayer,
        10,
        prayerType: PrayerType.bomdod,
      );
      final a = await repo.completePrayer(
        PrayerType.bomdod,
        1,
        entryKey: 'tap-1',
      );
      final b = await repo.completePrayer(
        PrayerType.bomdod,
        1,
        entryKey: 'tap-1',
      );
      expect(b.duplicate, isTrue);
      expect(b.record.id, a.record.id);
      expect(
        (await repo.loadSnapshot()).prayer(PrayerType.bomdod).remaining,
        9,
      );
    });

    test('snapshot stream updates after each change', () async {
      final values = <int>[];
      final sub = repo.watchSnapshot().listen(
        (s) => values.add(s.prayer(PrayerType.asr).remaining),
      );
      await pumpEventQueue();
      await repo.addPrayerDebt(PrayerType.asr, 3);
      await pumpEventQueue();
      await repo.completePrayer(PrayerType.asr, 1);
      await pumpEventQueue();
      await sub.cancel();
      expect(values.first, 0);
      expect(values.last, 2);
    });
  });
}
