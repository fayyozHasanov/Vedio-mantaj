import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utilities/date_utils.dart';
import 'app_card.dart';

/// Asks the user to confirm. Returns true only on explicit confirmation.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Tasdiqlash',
  String cancelLabel = 'Bekor qilish',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.colors.error,
                  minimumSize: const Size(48, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(48, 44)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: actionLabel == null ? 3 : 5),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}

Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(child: Text(message)),
    actions: [
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 44)),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Tushunarli'),
      ),
    ],
  ),
);

Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  DateTime? last,
}) {
  final today = dateOnly(DateTime.now());
  final lastDate = last ?? today;
  return showDatePicker(
    context: context,
    initialDate: initial.isAfter(lastDate) ? lastDate : initial,
    firstDate: DateTime(1950),
    lastDate: lastDate,
    helpText: 'Sanani tanlang',
    cancelText: 'Bekor qilish',
    confirmText: 'Tanlash',
  );
}

/// Values returned by [showQuantitySheet].
class QuantityInput {
  const QuantityInput({required this.quantity, required this.date, this.note});
  final int quantity;
  final DateTime date;
  final String? note;
}

/// Bottom sheet for entering a quantity, date and optional note.
Future<QuantityInput?> showQuantitySheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String confirmLabel,
  int initialQuantity = 1,
  bool quantityEditable = true,
  bool showDate = true,
  DateTime? initialDate,
  bool showNote = true,
  String quantityUnit = 'ta',
  IconData icon = Icons.check_rounded,
  Color? accent,
  int minQuantity = 1,
  String? initialNote,
}) {
  // A floating snackbar would otherwise cover the sheet's confirm button.
  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  return showModalBottomSheet<QuantityInput>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _QuantitySheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      initialQuantity: initialQuantity,
      quantityEditable: quantityEditable,
      showDate: showDate,
      initialDate: initialDate ?? dateOnly(DateTime.now()),
      showNote: showNote,
      unit: quantityUnit,
      icon: icon,
      accent: accent,
      minQuantity: minQuantity,
      initialNote: initialNote,
    ),
  );
}

class _QuantitySheet extends StatefulWidget {
  const _QuantitySheet({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.initialQuantity,
    required this.quantityEditable,
    required this.showDate,
    required this.initialDate,
    required this.showNote,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.minQuantity,
    required this.initialNote,
  });

  final String title;
  final String? subtitle;
  final String confirmLabel;
  final int initialQuantity;
  final bool quantityEditable;
  final bool showDate;
  final DateTime initialDate;
  final bool showNote;
  final String unit;
  final IconData icon;
  final Color? accent;
  final int minQuantity;
  final String? initialNote;

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late final TextEditingController _qty = TextEditingController(
    text: '${widget.initialQuantity}',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initialNote ?? '',
  );
  late DateTime _date = widget.initialDate;

  int get _value => int.tryParse(_qty.text) ?? 0;

  void _set(int v) {
    final clamped = v.clamp(0, 100000);
    setState(() => _qty.text = '$clamped');
  }

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ?? context.colors.primary;
    final valid =
        int.tryParse(_qty.text) != null && _value >= widget.minQuantity;
    return Padding(
      padding: EdgeInsets.only(
        left: Gap.page,
        right: Gap.page,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Gap.page,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconBadge(icon: widget.icon, color: accent, size: 44),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: context.text.titleLarge),
                      if (widget.subtitle != null)
                        Text(widget.subtitle!, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            if (widget.quantityEditable) ...[
              Row(
                children: [
                  _RoundButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Kamaytirish',
                    onTap: _value > widget.minQuantity
                        ? () => _set(_value - 1)
                        : null,
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('quantityField'),
                      controller: _qty,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: context.text.headlineMedium,
                      decoration: InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixText: widget.unit,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _RoundButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Ko‘paytirish',
                    onTap: () => _set(_value + 1),
                  ),
                ],
              ),
              const SizedBox(height: Gap.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Gap.sm,
                children: [
                  for (final n in const [5, 10, 30, 100])
                    ActionChip(
                      label: Text('+$n'),
                      onPressed: () => _set(_value + n),
                    ),
                ],
              ),
              const SizedBox(height: Gap.lg),
            ],
            if (widget.showDate)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.event_rounded),
                title: const Text('Sana'),
                trailing: Text(
                  formatDate(_date),
                  style: context.text.titleSmall?.copyWith(color: accent),
                ),
                onTap: () async {
                  final d = await pickDate(context, initial: _date);
                  if (d != null) setState(() => _date = dateOnly(d));
                },
              ),
            if (widget.showNote) ...[
              const SizedBox(height: Gap.sm),
              TextField(
                controller: _note,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Izoh (ixtiyoriy)',
                  counterText: '',
                ),
              ),
            ],
            const SizedBox(height: Gap.xl),
            FilledButton(
              key: const Key('quantityConfirm'),
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: valid
                  ? () => Navigator.of(context).pop(
                      QuantityInput(
                        quantity: _value,
                        date: _date,
                        note: _note.text,
                      ),
                    )
                  : null,
              child: Text(widget.confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      iconSize: 26,
      style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}
