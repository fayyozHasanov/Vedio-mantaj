import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/progress.dart';
import '../../shared/domain/debt_summary.dart';
import '../../shared/domain/statistics.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/record_tile.dart';

class StatisticsView extends ConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    final vitr = ref.watch(settingsProvider).value?.vitrEnabled ?? false;
    final today = dateOnly(ref.watch(clockProvider)());
    return AsyncBody(
      value: snapshot,
      builder: (snap) {
        final prayer = snap.prayerTotal(vitrEnabled: vitr);
        final fasting = snap.fasting;
        final overall = snap.overallProgress(vitrEnabled: vitr);
        final week = dailyActivity(snap.records, today: today, days: 7);
        final months = monthlyActivity(snap.records, today: today, months: 6);
        final last30 = completedInLastDays(
          snap.records,
          today: today,
          days: 30,
        );
        return ListView(
          padding: pagePadding(context, top: Gap.lg, bottom: 32),
          children: [
            AppCard(
              padding: const EdgeInsets.all(Gap.xl),
              child: Row(
                children: [
                  ProgressRing(
                    value: overall,
                    size: 96,
                    child: Text(
                      formatPercent(overall),
                      key: const Key('statsOverall'),
                      style: context.text.titleLarge,
                    ),
                  ),
                  const SizedBox(width: Gap.xl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Umumiy bajarilish',
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Namoz va ro‘za qazolari birgalikda. '
                          'Oxirgi 30 kunda: ${formatCount(last30.prayers)} '
                          'namoz, ${formatCount(last30.fasts)} kun ro‘za.',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader('Namoz'),
            _TotalsRow(
              summary: prayer,
              unit: 'ta',
              color: context.palette.prayer,
            ),
            const SectionHeader('Ro‘za'),
            _TotalsRow(
              summary: fasting,
              unit: 'kun',
              color: context.palette.fasting,
            ),
            const SectionHeader('Haftalik'),
            AppCard(
              child: _ActivityChart(
                labels: [
                  for (final d in week) uzWeekdaysShort[d.day.weekday - 1],
                ],
                tooltips: [for (final d in week) formatDateShort(d.day)],
                prayers: [for (final d in week) d.prayers],
                fasts: [for (final d in week) d.fasts],
              ),
            ),
            const SectionHeader('Oylik'),
            AppCard(
              child: _ActivityChart(
                labels: [
                  for (final m in months) uzMonthsShort[m.month.month - 1],
                ],
                tooltips: [
                  for (final m in months)
                    '${uzMonths[m.month.month - 1]} ${m.month.year}',
                ],
                prayers: [for (final m in months) m.prayers],
                fasts: [for (final m in months) m.fasts],
              ),
            ),
            const SectionHeader('Namozlar kesimida'),
            AppCard(
              child: Column(
                children: [
                  for (final t in PrayerType.visible(vitrEnabled: vitr))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            prayerIcon(t),
                            size: 20,
                            color: context.palette.prayer,
                          ),
                          const SizedBox(width: Gap.md),
                          SizedBox(
                            width: 64,
                            child: Text(
                              t.label,
                              style: context.text.titleSmall,
                            ),
                          ),
                          Expanded(
                            child: ProgressBar(
                              value: snap.prayer(t).progress,
                              height: 8,
                            ),
                          ),
                          const SizedBox(width: Gap.md),
                          SizedBox(
                            width: 44,
                            child: Text(
                              formatPercent(snap.prayer(t).progress),
                              textAlign: TextAlign.end,
                              style: context.text.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.summary,
    required this.unit,
    required this.color,
  });

  final DebtSummary summary;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, int value, {bool accent = false}) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          vertical: Gap.lg,
          horizontal: Gap.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatCount(value),
                      style: context.text.titleLarge?.copyWith(
                        color: accent ? color : null,
                      ),
                    ),
                    TextSpan(text: ' $unit', style: context.text.bodySmall),
                  ],
                ),
              ),
            ),
            Text(
              label,
              style: context.text.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
    return Row(
      children: [
        cell('Jami qarz', summary.totalDebt),
        const SizedBox(width: Gap.sm),
        cell('Ado qilingan', summary.completed),
        const SizedBox(width: Gap.sm),
        cell('Qolgan', summary.remaining, accent: true),
      ],
    );
  }
}

/// Stacked bars: prayers (green) + fasts (gold).
class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.labels,
    required this.tooltips,
    required this.prayers,
    required this.fasts,
  });

  final List<String> labels;
  final List<String> tooltips;
  final List<int> prayers;
  final List<int> fasts;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxY = [
      for (var i = 0; i < prayers.length; i++) prayers[i] + fasts[i],
    ].fold(0, math.max);
    final empty = maxY == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Legend(color: p.prayer, label: 'Namoz'),
            const SizedBox(width: Gap.lg),
            _Legend(color: p.fasting, label: 'Ro‘za'),
            const Spacer(),
            if (empty) Text('Hali faollik yo‘q', style: context.text.bodySmall),
          ],
        ),
        const SizedBox(height: Gap.lg),
        SizedBox(
          height: 168,
          child: BarChart(
            BarChartData(
              maxY: empty ? 5 : maxY * 1.15,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: p.track, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        labels[value.toInt()],
                        style: context.text.bodySmall,
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF103D32),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        '${tooltips[group.x]}\n'
                        'Namoz: ${prayers[group.x]} · Ro‘za: ${fasts[group.x]}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < labels.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (prayers[i] + fasts[i]).toDouble(),
                        width: 18,
                        color: p.prayer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            prayers[i].toDouble(),
                            p.prayer,
                          ),
                          BarChartRodStackItem(
                            prayers[i].toDouble(),
                            (prayers[i] + fasts[i]).toDouble(),
                            p.fasting,
                          ),
                        ],
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: empty ? 5 : maxY * 1.15,
                          color: p.track.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.text.bodySmall),
      ],
    );
  }
}
