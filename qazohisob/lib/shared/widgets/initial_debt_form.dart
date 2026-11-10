import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dialogs.dart';
import '../domain/exceptions.dart';
import '../providers.dart';

/// Form for the user's own estimate of missed prayers and fasts.
/// Nothing is calculated automatically; the optional helper only copies a
/// number the user typed into every prayer field.
class InitialDebtForm extends ConsumerStatefulWidget {
  const InitialDebtForm({
    super.key,
    required this.saveLabel,
    required this.onSaved,
    this.showVitrToggle = true,
  });

  final String saveLabel;
  final VoidCallback onSaved;
  final bool showVitrToggle;

  @override
  ConsumerState<InitialDebtForm> createState() => _InitialDebtFormState();
}

class _InitialDebtFormState extends ConsumerState<InitialDebtForm> {
  final Map<PrayerType, TextEditingController> _prayer = {
    for (final t in PrayerType.values) t: TextEditingController(),
  };
  final TextEditingController _fasting = TextEditingController();
  final TextEditingController _fillDays = TextEditingController();
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await ref.read(worshipRepositoryProvider).loadSnapshot();
    if (!mounted) return;
    setState(() {
      for (final t in PrayerType.values) {
        final v = snap.prayer(t).initial;
        _prayer[t]!.text = v == 0 ? '' : '$v';
      }
      final f = snap.fasting.initial;
      _fasting.text = f == 0 ? '' : '$f';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final c in _prayer.values) {
      c.dispose();
    }
    _fasting.dispose();
    _fillDays.dispose();
    super.dispose();
  }

  int _read(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void _fillAll(bool vitr) {
    final days = _read(_fillDays);
    if (days <= 0) {
      showSnack(context, 'Avval kunlar sonini kiriting');
      return;
    }
    setState(() {
      for (final t in PrayerType.visible(vitrEnabled: vitr)) {
        _prayer[t]!.text = '$days';
      }
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _save(bool vitr) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(worshipRepositoryProvider)
          .setInitialDebts(
            prayers: {
              for (final t in PrayerType.visible(vitrEnabled: vitr))
                t: _read(_prayer[t]!),
            },
            fasting: _read(_fasting),
          );
      if (mounted) widget.onSaved();
    } on WorshipException catch (e) {
      if (mounted) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitr = ref.watch(settingsProvider).value?.vitrEnabled ?? false;
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tez to‘ldirish (ixtiyoriy)',
                style: context.text.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Har bir namozdan bir xil miqdorda qazo bo‘lsa, sonini bir '
                'marta kiriting — barcha namoz maydonlariga yoziladi. '
                'Miqdorni o‘zingiz belgilaysiz.',
                style: context.text.bodySmall,
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('fillDaysField'),
                      controller: _fillDays,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(hintText: 'Soni'),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  FilledButton.tonal(
                    key: const Key('fillAllButton'),
                    onPressed: () => _fillAll(vitr),
                    child: const Text('To‘ldirish'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showVitrToggle) ...[
          const SizedBox(height: Gap.md),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: 4,
            ),
            child: SwitchListTile(
              key: const Key('vitrSwitch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Vitr namozini ham hisoblash'),
              subtitle: const Text('Vitrning hukmi mazhablarda farq qiladi'),
              value: vitr,
              onChanged: (v) =>
                  ref.read(settingsRepositoryProvider).setVitrEnabled(v),
            ),
          ),
        ],
        const SectionHeader('Qazo namozlar'),
        AppCard(
          child: Column(
            children: [
              for (final t in PrayerType.visible(vitrEnabled: vitr))
                _NumberRow(
                  key: ValueKey('row_${t.name}'),
                  fieldKey: Key('initial_${t.name}'),
                  icon: prayerIcon(t),
                  color: context.palette.prayer,
                  label: t.label,
                  unit: 'ta',
                  controller: _prayer[t]!,
                ),
            ],
          ),
        ),
        const SectionHeader('Qazo ro‘zalar'),
        AppCard(
          child: _NumberRow(
            fieldKey: const Key('initial_fast'),
            icon: Icons.nightlight_round,
            color: context.palette.fasting,
            label: 'Ro‘za',
            unit: 'kun',
            controller: _fasting,
          ),
        ),
        const SizedBox(height: Gap.xl),
        FilledButton(
          key: const Key('saveInitial'),
          onPressed: _saving ? null : () => _save(vitr),
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.saveLabel),
        ),
      ],
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    super.key,
    required this.fieldKey,
    required this.icon,
    required this.color,
    required this.label,
    required this.unit,
    required this.controller,
  });

  final Key fieldKey;
  final IconData icon;
  final Color color;
  final String label;
  final String unit;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 36),
          const SizedBox(width: Gap.md),
          Expanded(child: Text(label, style: context.text.titleSmall)),
          SizedBox(
            width: 130,
            child: TextField(
              key: fieldKey,
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(hintText: '0', suffixText: unit),
            ),
          ),
        ],
      ),
    );
  }
}
