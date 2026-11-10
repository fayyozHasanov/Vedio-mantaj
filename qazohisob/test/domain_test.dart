import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/core/notifications/reminder_scheduler.dart';
import 'package:qazohisob/core/utilities/date_utils.dart';
import 'package:qazohisob/shared/domain/debt_summary.dart';
import 'package:qazohisob/shared/domain/period.dart';
import 'package:qazohisob/shared/domain/statistics.dart';

var _id = 0;

WorshipRecord rec({
  WorshipKind type = WorshipKind.prayer,
  PrayerType? prayer = PrayerType.bomdod,
  RecordAction action = RecordAction.completed,
  int quantity = 1,
  required DateTime date,
  DateTime? reversedAt,
}) {
  _id++;
  return WorshipRecord(
    id: _id,
    entryKey: 'k$_id',
    type: type,
    prayerType: type == WorshipKind.fast ? null : prayer,
    action: action,
    quantity: quantity,
    completedDate: date,
    createdAt: date,
    reversedAt: reversedAt,
  );
}

void main() {
  group('DebtSummary', () {
    test('remaining = initial + added - completed', () {
      const s = DebtSummary(initial: 50, added: 10, completed: 25);
      expect(s.totalDebt, 60);
      expect(s.remaining, 35);
      expect(s.progress, closeTo(25 / 60, 1e-9));
      expect(s.isCleared, isFalse);
    });

    test('remaining is never negative and progress is capped', () {
      const s = DebtSummary(initial: 2, added: 0, completed: 5);
      expect(s.balance, -3);
      expect(s.remaining, 0);
      expect(s.progress, 1);
    });

    test('progress is zero when there is no debt', () {
      expect(DebtSummary.zero.progress, 0);
      expect(DebtSummary.zero.isCleared, isFalse);
    });

    test('summarizeDebt ignores reversed and audit records', () {
      final d = DateTime(2026, 11, 1);
      final s = summarizeDebt(
        initial: 10,
        records: [
          rec(date: d, quantity: 3),
          rec(date: d, quantity: 2, reversedAt: d),
          rec(date: d, quantity: 4, action: RecordAction.debtAdded),
          rec(date: d, quantity: 99, action: RecordAction.initialSet),
        ],
      );
      expect(s, const DebtSummary(initial: 10, added: 4, completed: 3));
      expect(s.remaining, 11);
    });

    test('snapshot totals respect the Vitr setting', () {
      final d = DateTime(2026, 11, 1);
      final snap = WorshipSnapshot.build(
        prayerInitial: {PrayerType.bomdod: 5, PrayerType.vitr: 7},
        fastingInitial: 4,
        records: [rec(date: d, prayer: PrayerType.vitr, quantity: 2)],
      );
      expect(snap.prayerTotal(vitrEnabled: false).remaining, 5);
      expect(snap.prayerTotal(vitrEnabled: true).remaining, 10);
      // (2 completed) / (5 + 4 fasting) without Vitr.
      expect(snap.overallProgress(vitrEnabled: false), 0);
      expect(snap.overallProgress(vitrEnabled: true), closeTo(2 / 16, 1e-9));
    });
  });

  group('statistics', () {
    final today = DateTime(2026, 11, 10);

    test('daily activity covers the last 7 days, oldest first', () {
      final records = [
        rec(date: DateTime(2026, 11, 10), quantity: 3),
        rec(date: DateTime(2026, 11, 10), prayer: PrayerType.asr, quantity: 2),
        rec(date: DateTime(2026, 11, 8), type: WorshipKind.fast),
        rec(date: DateTime(2026, 11, 1), quantity: 9), // outside window
        rec(date: DateTime(2026, 11, 9), quantity: 4, reversedAt: today),
        rec(
          date: DateTime(2026, 11, 9),
          quantity: 6,
          action: RecordAction.debtAdded,
        ),
      ];
      final week = dailyActivity(records, today: today);
      expect(week, hasLength(7));
      expect(week.first.day, DateTime(2026, 11, 4));
      expect(week.last.day, today);
      expect(week.last.prayers, 5);
      expect(week.last.prayerByType[PrayerType.asr], 2);
      expect(week[4].fasts, 1); // 8 Nov
      expect(week[5].isEmpty, isTrue); // 9 Nov: reversed + debt only
    });

    test('monthly activity groups by calendar month', () {
      final records = [
        rec(date: DateTime(2026, 11, 2), quantity: 5),
        rec(date: DateTime(2026, 10, 31), quantity: 1),
        rec(date: DateTime(2026, 10, 1), type: WorshipKind.fast, quantity: 2),
        rec(date: DateTime(2026, 5, 20), quantity: 7), // 7th month back
      ];
      final months = monthlyActivity(records, today: today);
      expect(months, hasLength(6));
      expect(months.first.month, DateTime(2026, 6));
      expect(months.last.month, DateTime(2026, 11));
      expect(months.last.prayers, 5);
      expect(months[4].prayers, 1);
      expect(months[4].fasts, 2);
      expect(months.fold(0, (s, m) => s + m.prayers), 6);
    });

    test('monthly activity crosses year boundaries', () {
      final months = monthlyActivity(
        [rec(date: DateTime(2025, 12, 15), quantity: 2)],
        today: DateTime(2026, 2, 3),
        months: 3,
      );
      expect(months.map((m) => m.month).toList(), [
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
      expect(months.first.prayers, 2);
    });

    test('completedInLastDays sums prayers and fasts', () {
      final r = completedInLastDays(
        [
          rec(date: DateTime(2026, 11, 9), quantity: 4),
          rec(date: DateTime(2026, 11, 3), type: WorshipKind.fast),
          rec(date: DateTime(2026, 10, 1), quantity: 100),
        ],
        today: today,
        days: 30,
      );
      expect(r.prayers, 4);
      expect(r.fasts, 1);
    });
  });

  group('formatting and reminders', () {
    test('formats Uzbek dates and numbers', () {
      expect(formatDate(DateTime(2026, 11, 10)), '10 Noyabr 2026');
      expect(formatWeekdayDate(DateTime(2026, 11, 10)), 'Seshanba, 10 Noyabr');
      expect(formatCount(1234567), '1 234 567');
      expect(formatMinutes(20 * 60 + 5), '20:05');
      expect(formatPercent(0.456), '46%');
    });

    test('next reminder is later today or tomorrow', () {
      final now = DateTime(2026, 11, 10, 19, 0);
      expect(nextDailyOccurrence(20 * 60, now), DateTime(2026, 11, 10, 20));
      expect(nextDailyOccurrence(19 * 60, now), DateTime(2026, 11, 11, 19));
      expect(
        nextDailyOccurrence(8 * 60, DateTime(2026, 12, 31, 9)),
        DateTime(2027, 1, 1, 8),
      );
    });
  });

  group('period (years / months / days)', () {
    test('converts to days with the chosen year length', () {
      const p = Period(years: 2, months: 3, days: 10);
      expect(p.toDays(yearDays: gregorianYearDays), 2 * 365 + 90 + 10);
      expect(p.toDays(yearDays: hijriYearDays), 2 * 354 + 90 + 10);
    });

    test('splits days back into a readable period', () {
      expect(formatPeriod(430, yearDays: 365), '1 yil 2 oy 5 kun');
      expect(formatPeriod(365, yearDays: 365), '1 yil');
      expect(formatPeriod(45, yearDays: 365), '1 oy 15 kun');
      expect(formatPeriod(0, yearDays: 365), '0 kun');
      expect(formatPeriod(354, yearDays: 354), '1 yil');
      expect(
        Period.fromDays(800, yearDays: 365),
        const Period(years: 2, months: 2, days: 10),
      );
    });

    test('round-trips for any number of days', () {
      for (final yd in [gregorianYearDays, hijriYearDays]) {
        for (var d = 0; d < 1500; d += 7) {
          expect(Period.fromDays(d, yearDays: yd).toDays(yearDays: yd), d);
        }
      }
    });
  });
}
