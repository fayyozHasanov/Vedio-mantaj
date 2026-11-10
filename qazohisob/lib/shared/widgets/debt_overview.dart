import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/progress.dart';
import '../domain/debt_summary.dart';

/// Ring + breakdown (initial / added / completed / remaining) for one debt.
class DebtOverviewCard extends StatelessWidget {
  const DebtOverviewCard({
    super.key,
    required this.summary,
    required this.unit,
    required this.color,
    this.onEditInitial,
  });

  final DebtSummary summary;
  final String unit;
  final Color color;
  final VoidCallback? onEditInitial;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                value: summary.progress,
                size: 104,
                colors: [color, Color.lerp(color, p.gold, 0.6)!],
                child: Text(
                  formatPercent(summary.progress),
                  style: context.text.titleLarge,
                ),
              ),
              const SizedBox(width: Gap.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qolgan qarz', style: context.text.bodySmall),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatCount(summary.remaining),
                            style: context.text.displaySmall?.copyWith(
                              color: color,
                            ),
                          ),
                          TextSpan(
                            text: ' $unit',
                            style: context.text.titleMedium?.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      key: const Key('remainingValue'),
                    ),
                    if (summary.isCleared)
                      Text(
                        'Barcha qazolar ado qilindi',
                        style: TextStyle(
                          color: p.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              _Figure(
                label: 'Boshlang‘ich',
                value: summary.initial,
                onTap: onEditInitial,
                editable: onEditInitial != null,
              ),
              _Figure(label: 'Qo‘shilgan', value: summary.added),
              _Figure(label: 'Ado qilingan', value: summary.completed),
              _Figure(label: 'Jami qarz', value: summary.totalDebt),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.onTap,
    this.editable = false,
  });

  final String label;
  final int value;
  final VoidCallback? onTap;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCount(value),
                        style: context.text.titleMedium,
                      ),
                    ),
                  ),
                  if (editable) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: context.palette.textSecondary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: context.text.bodySmall?.copyWith(fontSize: 11.5),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary + secondary action buttons used on tracker screens.
class TrackerActions extends StatelessWidget {
  const TrackerActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onAddDebt,
    required this.color,
    this.primaryIcon = Icons.check_rounded,
    this.primaryKey,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onAddDebt;
  final Color color;
  final IconData primaryIcon;
  final Key? primaryKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            key: primaryKey,
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: onPrimary,
            icon: Icon(primaryIcon),
            label: Text(primaryLabel),
          ),
        ),
        const SizedBox(width: Gap.md),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: onAddDebt,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Qarz'),
          ),
        ),
      ],
    );
  }
}
