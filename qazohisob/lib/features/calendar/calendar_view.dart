import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/domain/statistics.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/pickers.dart';
import '../../shared/widgets/record_tile.dart';

/// Month calendar showing completed prayers (green) and fasts (gold).
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(ref.read(clockProvider)());
    _month = DateTime(today.year, today.month);
    _selected = today;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(snapshotProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    return AsyncBody(
      value: snapshot,
      builder: (snap) {
        final byDay = activityByDay(snap.records);
        final dayRecords = snap.records
            .where((r) => isSameDay(r.completedDate, _selected))
            .toList();
        final monthEnd = DateTime(_month.year, _month.month + 1);
        final monthTotals = byDay.values
            .where((d) => !d.day.isBefore(_month) && d.day.isBefore(monthEnd))
            .fold((
              p: 0,
              f: 0,
            ), (s, d) => (p: s.p + d.prayers, f: s.f + d.fasts));
        return ListView(
          padding: pagePadding(context, top: Gap.lg, bottom: 32),
          children: [
            AppCard(
              padding: const EdgeInsets.fromLTRB(
                Gap.md,
                Gap.sm,
                Gap.md,
                Gap.lg,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const Key('prevMonth'),
                        tooltip: 'Oldingi oy',
                        onPressed: () => _shiftMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          '${uzMonths[_month.month - 1]} ${_month.year}',
                          key: const Key('monthTitle'),
                          textAlign: TextAlign.center,
                          style: context.text.titleMedium,
                        ),
                      ),
                      IconButton(
                        key: const Key('nextMonth'),
                        tooltip: 'Keyingi oy',
                        onPressed: () => _shiftMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Row(
                    children: [
                      for (final w in uzWeekdaysShort)
                        Expanded(
                          child: Center(
                            child: Text(w, style: context.text.bodySmall),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  _MonthGrid(
                    month: _month,
                    today: today,
                    selected: _selected,
                    activity: byDay,
                    onSelect: (d) => setState(() => _selected = d),
                  ),
                  const SizedBox(height: Gap.md),
                  Text(
                    'Bu oyda: ${formatCount(monthTotals.p)} namoz, '
                    '${formatCount(monthTotals.f)} kun ro‘za',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            SectionHeader(
              formatWeekdayDate(_selected),
              trailing: _selected.isAfter(today)
                  ? null
                  : TextButton.icon(
                      key: const Key('addForDay'),
                      onPressed: () => recordCompletionFlow(
                        context,
                        ref,
                        date: _selected,
                        includeFasting: true,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Qo‘shish'),
                    ),
            ),
            RecordList(
              records: dayRecords,
              emptyTitle: 'Bu kunda yozuv yo‘q',
              emptyMessage: 'Yozuvni tuzatish uchun ustiga bosing.',
            ),
          ],
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.activity,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final Map<DateTime, DayActivity> activity;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // Monday-first
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: () {
                    final index = r * 7 + c - leading + 1;
                    if (index < 1 || index > daysInMonth) {
                      return const SizedBox(height: 48);
                    }
                    final day = DateTime(month.year, month.month, index);
                    return _DayCell(
                      day: day,
                      isToday: isSameDay(day, today),
                      isSelected: isSameDay(day, selected),
                      activity: activity[day],
                      onTap: () => onSelect(day),
                    );
                  }(),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.activity,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final DayActivity? activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final primary = context.colors.primary;
    final hasPrayer = (activity?.prayers ?? 0) > 0;
    final hasFast = (activity?.fasts ?? 0) > 0;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('day_${day.day}'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: isToday && !isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.gold, width: 1.5),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(
                      visible: hasPrayer,
                      color: isSelected ? Colors.white : p.prayer,
                    ),
                    if (hasPrayer && hasFast) const SizedBox(width: 3),
                    _Dot(visible: hasFast, color: p.fasting),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.visible, required this.color});

  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 5);
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
