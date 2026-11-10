import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/shared/data/backup_repository.dart';
import 'package:qazohisob/shared/data/zikr_repository.dart';
import 'package:qazohisob/shared/domain/zikr.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 11, 10);

  test('wird has six tasbihs of 101', () {
    expect(NaqshbandiyaWird.items, hasLength(6));
    expect(NaqshbandiyaWird.items.every((i) => i.target == 101), isTrue);
    expect(NaqshbandiyaWird.totalPerSession, 606);
  });

  test('session follows the time of day', () {
    expect(sessionFor(DateTime(2026, 1, 1, 6)), ZikrSession.morning);
    expect(sessionFor(DateTime(2026, 1, 1, 16)), ZikrSession.evening);
  });

  test('progress knows finished items and the next one', () {
    final p = ZikrProgress([101, 101, 50, 0, 0, 0]);
    expect(p.doneItems, 2);
    expect(p.nextItem, 2);
    expect(p.isComplete, isFalse);
    expect(ZikrProgress(List.filled(6, 101)).isComplete, isTrue);
  });

  group('repository', () {
    late AppDatabase db;
    late ZikrRepository repo;
    setUp(() {
      db = memoryDb();
      repo = ZikrRepository(db, now: () => today);
    });
    tearDown(() => db.close());

    test('saves, updates and caps counters per day and session', () async {
      await repo.save(today, ZikrSession.morning, 0, 40);
      await repo.save(today, ZikrSession.morning, 0, 60);
      await repo.save(today, ZikrSession.morning, 1, 500);
      await repo.save(today, ZikrSession.evening, 0, 7);
      final morning = await repo.load(today, ZikrSession.morning);
      expect(morning.counts.take(2), [60, 101]);
      final evening = await repo.load(today, ZikrSession.evening);
      expect(evening.counts.first, 7);
      expect((await db.select(db.zikrCounts).get()), hasLength(3));
    });

    test('streak counts days with both sessions complete', () async {
      Future<void> complete(DateTime d) async {
        for (final s in ZikrSession.values) {
          for (var i = 0; i < 6; i++) {
            await repo.save(d, s, i, 101);
          }
        }
      }

      await complete(DateTime(2026, 11, 8));
      await complete(DateTime(2026, 11, 9));
      // Today only the morning is done: the streak still counts up to
      // yesterday.
      for (var i = 0; i < 6; i++) {
        await repo.save(today, ZikrSession.morning, i, 101);
      }
      final days = await repo.watchSince(DateTime(2026, 11, 1)).first;
      expect(days[today]![ZikrSession.morning].isComplete, isTrue);
      expect(days[today]!.isComplete, isFalse);
      expect(zikrStreak(days, today: today), 2);
      await complete(today);
      final after = await repo.watchSince(DateTime(2026, 11, 1)).first;
      expect(zikrStreak(after, today: today), 3);
    });

    test('backup round-trip keeps zikr counters; reset clears them', () async {
      await repo.save(today, ZikrSession.evening, 3, 33);
      final backup = BackupRepository(db);
      final json = await backup.exportJson();
      await backup.resetAll();
      expect(await db.select(db.zikrCounts).get(), isEmpty);
      await backup.restoreJson(json);
      final p = await repo.load(today, ZikrSession.evening);
      expect(p.counts[3], 33);
    });
  });
}
