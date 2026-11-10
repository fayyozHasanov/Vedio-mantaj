import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/debt_overview.dart';
import '../../shared/widgets/record_tile.dart';
import '../../shared/widgets/worship_actions.dart';

/// One prayer: totals, actions and full transaction history.
class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({super.key, required this.type});

  final PrayerType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${type.label} namozi')),
      body: AsyncBody(
        value: snapshot,
        builder: (snap) {
          final summary = snap.prayer(type);
          return ListView(
            padding: pagePadding(context, top: Gap.sm, bottom: 32),
            children: [
              DebtOverviewCard(
                summary: summary,
                unit: 'ta',
                color: context.palette.prayer,
                onEditInitial: () => editInitialFlow(
                  context,
                  ref,
                  prayer: type,
                  current: summary.initial,
                ),
              ),
              const SizedBox(height: Gap.lg),
              TrackerActions(
                primaryKey: const Key('detailComplete'),
                primaryLabel: 'Ado qildim',
                color: context.palette.prayer,
                onPrimary: () => completePrayerFlow(context, ref, type),
                onAddDebt: () => addDebtFlow(context, ref, prayer: type),
              ),
              const SectionHeader('Tarix'),
              RecordList(
                records: snap.recordsForPrayer(type),
                emptyMessage:
                    'Ado qilgan yoki qo‘shgan qazolaringiz shu '
                    'yerda sana va vaqti bilan ko‘rinadi.',
              ),
            ],
          );
        },
      ),
    );
  }
}
