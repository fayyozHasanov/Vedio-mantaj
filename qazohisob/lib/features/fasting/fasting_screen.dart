import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/debt_overview.dart';
import '../../shared/widgets/record_tile.dart';
import '../../shared/widgets/worship_actions.dart';

/// Missed Ramadan fasts: totals, actions and history.
class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ro‘za qazolari')),
      body: AsyncBody(
        value: snapshot,
        builder: (snap) {
          final summary = snap.fasting;
          return ListView(
            padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, 32),
            children: [
              DebtOverviewCard(
                summary: summary,
                unit: 'kun',
                color: context.palette.fasting,
                onEditInitial: () =>
                    editInitialFlow(context, ref, current: summary.initial),
              ),
              const SizedBox(height: Gap.lg),
              TrackerActions(
                primaryKey: const Key('fastComplete'),
                primaryLabel: 'Ro‘za tutdim',
                primaryIcon: Icons.nightlight_round,
                color: context.palette.fasting,
                onPrimary: () => completeFastFlow(context, ref),
                onAddDebt: () => addDebtFlow(context, ref),
              ),
              const SizedBox(height: Gap.md),
              AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: context.palette.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Text(
                        'Har bir “Ro‘za tutdim” qarzni aynan 1 kunga '
                        'kamaytiradi. Ro‘za faqat siz belgilaganingizda qayd '
                        'etiladi — sana yoki eslatma orqali avtomatik '
                        'belgilanmaydi.',
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHeader('Tarix'),
              RecordList(
                records: snap.fastingRecords,
                emptyMessage:
                    'Tutgan qazo ro‘zalaringiz shu yerda '
                    'ko‘rinadi.',
              ),
            ],
          );
        },
      ),
    );
  }
}
