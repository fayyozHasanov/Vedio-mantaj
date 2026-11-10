import 'dart:math' as math;

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';

/// Totals for one debt (a single prayer type, or fasting).
///
/// Remaining = Initial debt + Added debt - Completed.
class DebtSummary {
  const DebtSummary({
    required this.initial,
    required this.added,
    required this.completed,
  });

  static const zero = DebtSummary(initial: 0, added: 0, completed: 0);

  final int initial;
  final int added;
  final int completed;

  /// Everything that has ever been owed.
  int get totalDebt => initial + added;

  /// Exact balance; negative only if data was imported inconsistently.
  int get balance => totalDebt - completed;

  /// What is still owed. Never negative.
  int get remaining => math.max(0, balance);

  /// Completed share of the total debt, 0..1.
  double get progress {
    if (totalDebt <= 0) return 0;
    return (completed / totalDebt).clamp(0.0, 1.0);
  }

  bool get isCleared => totalDebt > 0 && remaining == 0;

  DebtSummary operator +(DebtSummary other) => DebtSummary(
    initial: initial + other.initial,
    added: added + other.added,
    completed: completed + other.completed,
  );

  @override
  bool operator ==(Object other) =>
      other is DebtSummary &&
      other.initial == initial &&
      other.added == added &&
      other.completed == completed;

  @override
  int get hashCode => Object.hash(initial, added, completed);

  @override
  String toString() =>
      'DebtSummary(initial: $initial, added: $added, completed: $completed)';
}

/// Builds a [DebtSummary] from the initial estimate and the history
/// records belonging to that debt. Reversed records and audit entries are
/// ignored.
DebtSummary summarizeDebt({
  required int initial,
  required Iterable<WorshipRecord> records,
}) {
  var added = 0;
  var completed = 0;
  for (final r in records) {
    if (r.reversedAt != null) continue;
    switch (r.action) {
      case RecordAction.debtAdded:
        added += r.quantity;
      case RecordAction.completed:
        completed += r.quantity;
      case RecordAction.initialSet:
        break;
    }
  }
  return DebtSummary(initial: initial, added: added, completed: completed);
}

/// Everything the UI needs, computed from one consistent database read.
class WorshipSnapshot {
  WorshipSnapshot({
    required this.prayers,
    required this.fasting,
    required List<WorshipRecord> records,
  }) : records = List.unmodifiable(records);

  factory WorshipSnapshot.build({
    required Map<PrayerType, int> prayerInitial,
    required int fastingInitial,
    required List<WorshipRecord> records,
  }) {
    final prayers = <PrayerType, DebtSummary>{
      for (final type in PrayerType.values)
        type: summarizeDebt(
          initial: prayerInitial[type] ?? 0,
          records: records.where(
            (r) => r.type == WorshipKind.prayer && r.prayerType == type,
          ),
        ),
    };
    final fasting = summarizeDebt(
      initial: fastingInitial,
      records: records.where((r) => r.type == WorshipKind.fast),
    );
    final sorted = [...records]
      ..sort((a, b) {
        final c = b.completedDate.compareTo(a.completedDate);
        return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
      });
    return WorshipSnapshot(prayers: prayers, fasting: fasting, records: sorted);
  }

  final Map<PrayerType, DebtSummary> prayers;
  final DebtSummary fasting;

  /// All records, newest first.
  final List<WorshipRecord> records;

  DebtSummary prayer(PrayerType type) => prayers[type] ?? DebtSummary.zero;

  /// Combined prayer totals. Vitr is only included when enabled.
  DebtSummary prayerTotal({required bool vitrEnabled}) =>
      PrayerType.visible(vitrEnabled: vitrEnabled)
          .fold(DebtSummary.zero, (sum, t) => sum + prayer(t));

  /// Prayers and fasting days combined into one progress figure.
  double overallProgress({required bool vitrEnabled}) {
    final all = prayerTotal(vitrEnabled: vitrEnabled) + fasting;
    return all.progress;
  }

  List<WorshipRecord> recordsForPrayer(PrayerType type) => records
      .where((r) => r.type == WorshipKind.prayer && r.prayerType == type)
      .toList();

  List<WorshipRecord> get fastingRecords =>
      records.where((r) => r.type == WorshipKind.fast).toList();
}
