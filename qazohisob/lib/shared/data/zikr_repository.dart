import 'package:drift/drift.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/utilities/date_utils.dart';
import '../domain/zikr.dart';

/// Stores the daily zikr counters.
class ZikrRepository {
  ZikrRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Counters of one session of [day].
  Future<ZikrProgress> load(DateTime day, ZikrSession session) async {
    final rows =
        await (_db.select(_db.zikrCounts)..where(
              (t) =>
                  t.day.equals(dateOnly(day)) & t.session.equalsValue(session),
            ))
            .get();
    final counts = List.filled(NaqshbandiyaWird.items.length, 0);
    for (final r in rows) {
      if (r.item >= 0 && r.item < counts.length) counts[r.item] = r.count;
    }
    return ZikrProgress(counts);
  }

  /// Sets the counter of one tasbih (insert or update).
  Future<void> save(DateTime day, ZikrSession session, int item, int count) {
    if (item < 0 || item >= NaqshbandiyaWird.items.length) {
      throw RangeError.index(item, NaqshbandiyaWird.items, 'item');
    }
    final value = count.clamp(0, NaqshbandiyaWird.items[item].target);
    final now = _now();
    return _db
        .into(_db.zikrCounts)
        .insert(
          ZikrCountsCompanion.insert(
            day: dateOnly(day),
            session: session,
            item: item,
            count: value,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) =>
                ZikrCountsCompanion(count: Value(value), updatedAt: Value(now)),
            target: [
              _db.zikrCounts.day,
              _db.zikrCounts.session,
              _db.zikrCounts.item,
            ],
          ),
        );
  }

  /// All counters from [from] onwards, grouped by day; updates live.
  Stream<Map<DateTime, ZikrDay>> watchSince(DateTime from) =>
      (_db.select(_db.zikrCounts)
            ..where((t) => t.day.isBiggerOrEqualValue(dateOnly(from))))
          .watch()
          .map(groupZikr);
}
