import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/utilities/date_utils.dart';

/// Completed acts on one calendar day.
class DayActivity {
  const DayActivity({
    required this.day,
    this.prayers = 0,
    this.fasts = 0,
    this.prayerByType = const {},
  });

  final DateTime day;
  final int prayers;
  final int fasts;
  final Map<PrayerType, int> prayerByType;

  bool get isEmpty => prayers == 0 && fasts == 0;
  int get total => prayers + fasts;
}

/// Completed acts in one calendar month.
class MonthActivity {
  const MonthActivity({
    required this.month,
    required this.prayers,
    required this.fasts,
  });

  /// First day of the month.
  final DateTime month;
  final int prayers;
  final int fasts;
}

Iterable<WorshipRecord> _activeCompletions(Iterable<WorshipRecord> records) =>
    records.where(
      (r) => r.reversedAt == null && r.action == RecordAction.completed,
    );

/// Completed acts grouped by calendar day.
Map<DateTime, DayActivity> activityByDay(Iterable<WorshipRecord> records) {
  final prayers = <DateTime, int>{};
  final fasts = <DateTime, int>{};
  final byType = <DateTime, Map<PrayerType, int>>{};
  for (final r in _activeCompletions(records)) {
    final day = dateOnly(r.completedDate);
    if (r.type == WorshipKind.prayer) {
      prayers[day] = (prayers[day] ?? 0) + r.quantity;
      final m = byType.putIfAbsent(day, () => {});
      final t = r.prayerType;
      if (t != null) m[t] = (m[t] ?? 0) + r.quantity;
    } else {
      fasts[day] = (fasts[day] ?? 0) + r.quantity;
    }
  }
  final days = {...prayers.keys, ...fasts.keys};
  return {
    for (final d in days)
      d: DayActivity(
        day: d,
        prayers: prayers[d] ?? 0,
        fasts: fasts[d] ?? 0,
        prayerByType: byType[d] ?? const {},
      ),
  };
}

/// One entry per day for the [days] days ending on [today] (oldest first).
List<DayActivity> dailyActivity(
  Iterable<WorshipRecord> records, {
  required DateTime today,
  int days = 7,
}) {
  final byDay = activityByDay(records);
  final end = dateOnly(today);
  return [
    for (var i = days - 1; i >= 0; i--)
      () {
        final d = DateTime(end.year, end.month, end.day - i);
        return byDay[d] ?? DayActivity(day: d);
      }(),
  ];
}

/// One entry per month for the [months] months ending with [today]'s month
/// (oldest first).
List<MonthActivity> monthlyActivity(
  Iterable<WorshipRecord> records, {
  required DateTime today,
  int months = 6,
}) {
  final result = <MonthActivity>[];
  for (var i = months - 1; i >= 0; i--) {
    final start = DateTime(today.year, today.month - i);
    final end = DateTime(start.year, start.month + 1);
    var p = 0;
    var f = 0;
    for (final r in _activeCompletions(records)) {
      final d = r.completedDate;
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      if (r.type == WorshipKind.prayer) {
        p += r.quantity;
      } else {
        f += r.quantity;
      }
    }
    result.add(MonthActivity(month: start, prayers: p, fasts: f));
  }
  return result;
}

/// Sum of completed acts in the [days] days ending on [today].
({int prayers, int fasts}) completedInLastDays(
  Iterable<WorshipRecord> records, {
  required DateTime today,
  required int days,
}) {
  final list = dailyActivity(records, today: today, days: days);
  return (
    prayers: list.fold(0, (s, d) => s + d.prayers),
    fasts: list.fold(0, (s, d) => s + d.fasts),
  );
}
