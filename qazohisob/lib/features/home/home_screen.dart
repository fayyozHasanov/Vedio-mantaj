import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/islamic_pattern.dart';
import '../../core/widgets/progress.dart';
import '../../shared/domain/debt_summary.dart';
import '../../shared/domain/period.dart';
import '../../shared/domain/statistics.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/pickers.dart';
import '../../shared/widgets/record_tile.dart';
import '../../shared/widgets/worship_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    final settings = ref.watch(settingsProvider).value;
    final now = ref.watch(clockProvider)();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncBody(
          value: snapshot,
          builder: (snap) =>
              _HomeBody(snap: snap, settings: settings, today: dateOnly(now)),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.snap,
    required this.settings,
    required this.today,
  });

  final WorshipSnapshot snap;
  final Setting? settings;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitr = settings?.vitrEnabled ?? false;
    final prayer = snap.prayerTotal(vitrEnabled: vitr);
    final fasting = snap.fasting;
    final overall = snap.overallProgress(vitrEnabled: vitr);
    final hasDebt = prayer.totalDebt > 0 || fasting.totalDebt > 0;
    final todayActivity =
        activityByDay(snap.records)[today] ?? DayActivity(day: today);
    final name = settings?.firstName ?? '';
    final yearDays = settings?.yearDays ?? gregorianYearDays;
    // One missed day = one of each prayer, so the longest prayer debt is
    // the time it covers.
    final prayerDays = PrayerType.visible(vitrEnabled: vitr)
        .map((t) => snap.prayer(t).remaining)
        .fold(0, (a, b) => a > b ? a : b);

    return ListView(
      padding: pagePadding(context, top: Gap.md, bottom: 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty
                        ? 'Assalomu alaykum!'
                        : 'Assalomu alaykum, $name!',
                    key: const Key('greeting'),
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(formatWeekdayDate(today), style: context.text.bodySmall),
                ],
              ),
            ),
            IconButton.filledTonal(
              key: const Key('settingsButton'),
              tooltip: 'Sozlamalar',
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: Gap.xl),
        _HeroCard(
          overall: overall,
          prayer: prayer,
          fasting: fasting,
          hasDebt: hasDebt,
          prayerPeriod: prayerDays > 0
              ? '≈ ${formatPeriod(prayerDays, yearDays: yearDays)}'
              : null,
        ),
        const SizedBox(height: Gap.lg),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.mosque_outlined,
                color: context.palette.prayer,
                label: 'Qolgan namozlar',
                value: formatCount(prayer.remaining),
                onTap: () => context.go('/prayer'),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_outline_rounded,
                color: context.palette.prayer,
                label: 'Ado qilingan namozlar',
                value: formatCount(prayer.completed),
                onTap: () => context.go('/prayer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.nightlight_outlined,
                color: context.palette.fasting,
                label: 'Qolgan ro‘zalar',
                value: '${formatCount(fasting.remaining)} kun',
                onTap: () => context.go('/fasting'),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _StatTile(
                icon: Icons.nightlight_round,
                color: context.palette.fasting,
                label: 'Tutilgan ro‘zalar',
                value: '${formatCount(fasting.completed)} kun',
                onTap: () => context.go('/fasting'),
              ),
            ),
          ],
        ),
        const SectionHeader('Bugun'),
        _TodayCard(
          activity: todayActivity,
          goal: settings?.dailyPrayerGoal ?? 5,
          vitrEnabled: vitr,
        ),
        const SectionHeader('Tezkor amallar'),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                key: const Key('quickPrayer'),
                icon: Icons.mosque_rounded,
                label: 'Namoz\nado qildim',
                color: context.palette.prayer,
                onTap: () => recordCompletionFlow(context, ref),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _QuickAction(
                key: const Key('quickFast'),
                icon: Icons.nightlight_round,
                label: 'Ro‘za\ntutdim',
                color: context.palette.fasting,
                onTap: () => completeFastFlow(context, ref),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _QuickAction(
                key: const Key('quickDebt'),
                icon: Icons.add_rounded,
                label: 'Qarz\nqo‘shish',
                color: context.colors.error,
                onTap: () => recordDebtFlow(context, ref),
              ),
            ),
          ],
        ),
        const SectionHeader('Namozlar bo‘yicha'),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.lg,
            vertical: Gap.sm,
          ),
          child: Column(
            children: [
              for (final t in PrayerType.visible(vitrEnabled: vitr))
                _PrayerRow(type: t, summary: snap.prayer(t)),
            ],
          ),
        ),
        const SizedBox(height: Gap.xl),
        Text(
          'Ilova faqat siz kiritgan ma’lumotlarni hisoblaydi. Hukmlar bo‘yicha '
          'malakali olimga murojaat qiling.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.overall,
    required this.prayer,
    required this.fasting,
    required this.hasDebt,
    this.prayerPeriod,
  });

  final double overall;
  final DebtSummary prayer;
  final DebtSummary fasting;
  final bool hasDebt;
  final String? prayerPeriod;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const onHero = Colors.white;
    final soft = Colors.white.withValues(alpha: 0.72);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroStart, p.heroEnd],
        ),
        boxShadow: kLiteEffects
            ? null
            : [
                BoxShadow(
                  color: p.heroEnd.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: IslamicPattern()),
          Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProgressRing(
                      value: overall,
                      size: 112,
                      stroke: 10,
                      trackColor: Colors.white.withValues(alpha: 0.14),
                      colors: [p.gold, const Color(0xFFF1DDA8), p.gold],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatPercent(overall),
                            key: const Key('overallPercent'),
                            style: context.text.headlineSmall?.copyWith(
                              color: onHero,
                            ),
                          ),
                          Text(
                            'bajarildi',
                            style: TextStyle(color: soft, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Gap.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UMUMIY JARAYON',
                            style: TextStyle(
                              color: p.gold,
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasDebt
                                ? '${formatCount(prayer.completed + fasting.completed)} ta ibodat ado qilindi'
                                : 'Qarzlaringizni kiritib boshlang',
                            style: context.text.titleMedium?.copyWith(
                              color: onHero,
                              height: 1.25,
                            ),
                          ),
                          if (!hasDebt) ...[
                            const SizedBox(height: Gap.sm),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: p.gold,
                                foregroundColor: const Color(0xFF103D32),
                                minimumSize: const Size(40, 40),
                              ),
                              onPressed: () =>
                                  context.push('/settings/initial'),
                              child: const Text('Kiritish'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: _HeroFigure(
                        label: 'Namoz qarzi',
                        value: formatCount(prayer.remaining),
                        unit: 'ta qoldi',
                        note: prayerPeriod,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(width: Gap.lg),
                    Expanded(
                      child: _HeroFigure(
                        label: 'Ro‘za qarzi',
                        value: formatCount(fasting.remaining),
                        unit: 'kun qoldi',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({
    required this.label,
    required this.value,
    required this.unit,
    this.note,
  });

  final String label;
  final String value;
  final String unit;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final soft = Colors.white.withValues(alpha: 0.72);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: soft, fontSize: 13)),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(color: soft, fontSize: 13),
              ),
            ],
          ),
        ),
        if (note != null)
          Text(
            note!,
            key: const Key('prayerPeriod'),
            style: TextStyle(color: soft, fontSize: 12.5),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 36),
          const SizedBox(height: Gap.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: context.text.titleLarge),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.activity,
    required this.goal,
    required this.vitrEnabled,
  });

  final DayActivity activity;
  final int goal;
  final bool vitrEnabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = activity.prayers;
    final reached = done >= goal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: formatCount(done),
                        style: context.text.headlineSmall,
                      ),
                      TextSpan(
                        text: ' / $goal ta qazo namoz',
                        style: context.text.bodyMedium?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reached)
                Chip(
                  avatar: Icon(
                    Icons.emoji_events_rounded,
                    size: 18,
                    color: p.gold,
                  ),
                  label: const Text('Maqsad bajarildi'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          ProgressBar(value: goal == 0 ? 0 : done / goal),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final t in PrayerType.visible(vitrEnabled: vitrEnabled))
                _MiniCount(
                  label: t.label,
                  count: activity.prayerByType[t] ?? 0,
                  color: p.prayer,
                ),
              _MiniCount(
                label: 'Ro‘za',
                count: activity.fasts,
                color: p.fasting,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  const _MiniCount({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.12)
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label · $count',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: active ? color : context.palette.textSecondary,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: Gap.lg, horizontal: Gap.sm),
      child: Column(
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(height: Gap.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.titleSmall?.copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends ConsumerWidget {
  const _PrayerRow({required this.type, required this.summary});

  final PrayerType type;
  final DebtSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.go('/prayer/${type.name}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(prayerIcon(type), color: context.palette.prayer, size: 22),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(type.label, style: context.text.titleSmall),
                      ),
                      Text(
                        '${formatCount(summary.remaining)} qoldi',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ProgressBar(value: summary.progress, height: 6),
                ],
              ),
            ),
            const SizedBox(width: Gap.sm),
            IconButton(
              key: Key('homeQuick_${type.name}'),
              tooltip: '${type.label}: 1 ta ado qildim',
              onPressed: () =>
                  completePrayerFlow(context, ref, type, quick: true),
              icon: Icon(
                Icons.add_circle_rounded,
                color: context.palette.prayer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
