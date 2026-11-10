import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../domain/debt_summary.dart';
import '../providers.dart';
import 'worship_actions.dart';

/// Choice made in [showWorshipPicker]: a prayer type, or fasting (null).
class WorshipChoice {
  const WorshipChoice.prayer(PrayerType this.prayer);
  const WorshipChoice.fast() : prayer = null;
  final PrayerType? prayer;
  bool get isFast => prayer == null;
}

/// Bottom sheet listing prayers (and optionally fasting) with their
/// remaining debt.
Future<WorshipChoice?> showWorshipPicker(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  bool includeFasting = true,
}) {
  final snapshot = ref.read(snapshotProvider).value;
  final vitr = ref.read(settingsProvider).value?.vitrEnabled ?? false;
  return showModalBottomSheet<WorshipChoice>(
    useRootNavigator: true,
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      Widget tile({
        required IconData icon,
        required Color color,
        required String label,
        required DebtSummary? summary,
        required String unit,
        required WorshipChoice choice,
      }) => ListTile(
        key: Key('pick_${choice.prayer?.name ?? 'fast'}'),
        leading: IconBadge(icon: icon, color: color),
        title: Text(label),
        subtitle: summary == null
            ? null
            : Text('Qolgan: ${formatCount(summary.remaining)} $unit'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pop(context, choice),
      );
      return Padding(
        padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                child: Text(title, style: context.text.titleLarge),
              ),
              const SizedBox(height: Gap.sm),
              for (final t in PrayerType.visible(vitrEnabled: vitr))
                tile(
                  icon: prayerIcon(t),
                  color: context.palette.prayer,
                  label: t.label,
                  summary: snapshot?.prayer(t),
                  unit: 'ta',
                  choice: WorshipChoice.prayer(t),
                ),
              if (includeFasting) ...[
                const Divider(),
                tile(
                  icon: Icons.nightlight_round,
                  color: context.palette.fasting,
                  label: 'Ro‘za',
                  summary: snapshot?.fasting,
                  unit: 'kun',
                  choice: const WorshipChoice.fast(),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// "Ado qildim" for any prayer or fasting, optionally on a given date.
Future<void> recordCompletionFlow(
  BuildContext context,
  WidgetRef ref, {
  DateTime? date,
  bool includeFasting = false,
}) async {
  final choice = await showWorshipPicker(
    context,
    ref,
    title: includeFasting
        ? 'Nimani ado qildingiz?'
        : 'Qaysi namozni ado qildingiz?',
    includeFasting: includeFasting,
  );
  if (choice == null || !context.mounted) return;
  if (choice.isFast) {
    await completeFastFlow(context, ref, date: date);
  } else {
    await completePrayerFlow(context, ref, choice.prayer!, date: date);
  }
}

Future<void> recordDebtFlow(BuildContext context, WidgetRef ref) async {
  final choice = await showWorshipPicker(
    context,
    ref,
    title: 'Qaysi qarzni qo‘shasiz?',
  );
  if (choice == null || !context.mounted) return;
  await addDebtFlow(context, ref, prayer: choice.prayer);
}
