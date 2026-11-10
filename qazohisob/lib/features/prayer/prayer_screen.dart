import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/progress.dart';
import '../../shared/domain/debt_summary.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/record_tile.dart';
import '../../shared/widgets/worship_actions.dart';

/// List of all prayers with their own debt.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    final vitr = ref.watch(settingsProvider).value?.vitrEnabled ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Namoz qazolari')),
      body: AsyncBody(
        value: snapshot,
        builder: (snap) {
          final total = snap.prayerTotal(vitrEnabled: vitr);
          return ListView(
            padding: pagePadding(context, top: Gap.sm, bottom: 32),
            children: [
              _TotalCard(total: total),
              const SectionHeader('Namozlar'),
              for (final t in PrayerType.visible(vitrEnabled: vitr)) ...[
                _PrayerCard(type: t, summary: snap.prayer(t)),
                const SizedBox(height: Gap.md),
              ],
              if (!vitr)
                AppCard(
                  onTap: () => context.push('/settings'),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: context.palette.textSecondary,
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(
                          'Vitr hisobi o‘chirilgan. Uni Sozlamalarda alohida '
                          'yoqishingiz mumkin.',
                          style: context.text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final DebtSummary total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jami qolgan', style: context.text.bodySmall),
                    Text(
                      formatCount(total.remaining),
                      key: const Key('prayerTotalRemaining'),
                      style: context.text.displaySmall,
                    ),
                  ],
                ),
              ),
              Text(
                formatPercent(total.progress),
                style: context.text.titleLarge?.copyWith(
                  color: context.palette.prayer,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          ProgressBar(value: total.progress, height: 10),
          const SizedBox(height: Gap.sm),
          Text(
            '${formatCount(total.completed)} ta ado qilindi · '
            'jami ${formatCount(total.totalDebt)} ta',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends ConsumerWidget {
  const _PrayerCard({required this.type, required this.summary});

  final PrayerType type;
  final DebtSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return AppCard(
      key: Key('prayerCard_${type.name}'),
      onTap: () => context.go('/prayer/${type.name}'),
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(icon: prayerIcon(type), color: p.prayer, size: 44),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label, style: context.text.titleMedium),
                    Text(
                      'Ado: ${formatCount(summary.completed)} / '
                      '${formatCount(summary.totalDebt)}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCount(summary.remaining),
                    key: Key('remaining_${type.name}'),
                    style: context.text.titleLarge,
                  ),
                  Text('qoldi', style: context.text.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(child: ProgressBar(value: summary.progress)),
              const SizedBox(width: Gap.md),
              Text(
                formatPercent(summary.progress),
                style: context.text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  key: Key('quick_${type.name}'),
                  onPressed: () =>
                      completePrayerFlow(context, ref, type, quick: true),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('+1 ado'),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: OutlinedButton(
                  key: Key('many_${type.name}'),
                  onPressed: () => completePrayerFlow(context, ref, type),
                  child: const Text('Bir nechta'),
                ),
              ),
              const SizedBox(width: Gap.sm),
              IconButton.outlined(
                key: Key('addDebt_${type.name}'),
                tooltip: 'Qarz qo‘shish',
                onPressed: () => addDebtFlow(context, ref, prayer: type),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
