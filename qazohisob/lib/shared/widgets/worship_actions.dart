import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/utilities/ids.dart';
import '../../core/widgets/dialogs.dart';
import '../data/worship_repository.dart';
import '../domain/exceptions.dart';
import '../providers.dart';

/// User-facing flows shared by several screens. Each flow collects input,
/// calls the repository, handles validation errors and offers undo.

String recordSubject(WorshipRecord r) =>
    r.type == WorshipKind.fast ? 'Ro‘za' : (r.prayerType?.label ?? 'Namoz');

String unitFor(WorshipKind kind) => kind == WorshipKind.fast ? 'kun' : 'ta';

/// Mark prayers of [type] as made up.
Future<void> completePrayerFlow(
  BuildContext context,
  WidgetRef ref,
  PrayerType type, {
  DateTime? date,
  bool quick = false,
}) async {
  final repo = ref.read(worshipRepositoryProvider);
  QuantityInput? input;
  if (quick) {
    input = QuantityInput(quantity: 1, date: date ?? dateOnly(DateTime.now()));
  } else {
    input = await showQuantitySheet(
      context,
      title: '${type.label} — ado qildim',
      subtitle: 'Ado qilgan qazo namozlaringiz sonini kiriting',
      confirmLabel: 'Ado qilindi deb belgilash',
      initialDate: date,
      icon: Icons.check_circle_outline_rounded,
    );
  }
  if (input == null || !context.mounted) return;
  final key = newEntryKey();
  final value = input;
  final result = await _completeWithConfirmation(
    context,
    unit: 'ta',
    run: (allowExceed) => repo.completePrayer(
      type,
      value.quantity,
      date: value.date,
      note: value.note,
      entryKey: key,
      allowExceed: allowExceed,
    ),
  );
  if (result == null || !context.mounted) return;
  showSnack(
    context,
    '${type.label}: ${formatCount(value.quantity)} ta ado qilindi',
    actionLabel: 'Bekor qilish',
    onAction: () => reverseRecordFlow(context, ref, result.record),
  );
}

/// Mark one fasting day as made up on a chosen date.
Future<void> completeFastFlow(
  BuildContext context,
  WidgetRef ref, {
  DateTime? date,
}) async {
  final repo = ref.read(worshipRepositoryProvider);
  final input = await showQuantitySheet(
    context,
    title: 'Ro‘za tutdim',
    subtitle: 'Bir kunlik qazo ro‘za qayd etiladi',
    confirmLabel: 'Tutildi deb belgilash',
    quantityEditable: false,
    initialDate: date,
    icon: Icons.nightlight_round,
    accent: context.palette.fasting,
  );
  if (input == null || !context.mounted) return;

  final snapshot = await repo.loadSnapshot();
  final sameDay = snapshot.fastingRecords.any(
    (r) =>
        r.reversedAt == null &&
        r.action == RecordAction.completed &&
        isSameDay(r.completedDate, input.date),
  );
  if (sameDay && context.mounted) {
    final ok = await showConfirmDialog(
      context,
      title: 'Bu kun allaqachon qayd etilgan',
      message:
          '${formatDate(input.date)} sanasida qazo ro‘za allaqachon '
          'belgilangan. Yana bir kun qo‘shilsinmi?',
      confirmLabel: 'Qo‘shish',
    );
    if (!ok) return;
  }
  if (!context.mounted) return;
  final key = newEntryKey();
  final result = await _completeWithConfirmation(
    context,
    unit: 'kun',
    run: (allowExceed) => repo.completeFast(
      date: input.date,
      note: input.note,
      entryKey: key,
      allowExceed: allowExceed,
    ),
  );
  if (result == null || !context.mounted) return;
  showSnack(
    context,
    'Qazo ro‘za qayd etildi (${formatDate(input.date)})',
    actionLabel: 'Bekor qilish',
    onAction: () => reverseRecordFlow(context, ref, result.record),
  );
}

Future<CompletionResult?> _completeWithConfirmation(
  BuildContext context, {
  required String unit,
  required Future<CompletionResult> Function(bool allowExceed) run,
}) async {
  try {
    return await run(false);
  } on ExceedsDebtException catch (e) {
    if (!context.mounted) return null;
    final ok = await showConfirmDialog(
      context,
      title: 'Qarzdan ortiq miqdor',
      message:
          'Qolgan qarz: ${formatCount(e.remaining)} $unit. '
          'Siz ${formatCount(e.requested)} $unit kiritdingiz.\n\n'
          'Tasdiqlasangiz, ortiqcha ${formatCount(e.excess)} $unit avval '
          'qarzga qo‘shiladi, so‘ng ado qilingan deb belgilanadi. '
          'Qolgan qarz manfiy bo‘lmaydi.',
      confirmLabel: 'Tasdiqlash',
    );
    if (!ok || !context.mounted) return null;
    try {
      return await run(true);
    } on WorshipException catch (e) {
      if (context.mounted) showSnack(context, e.message);
      return null;
    }
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
    return null;
  }
}

/// Add newly discovered missed prayers or fasting days.
Future<void> addDebtFlow(
  BuildContext context,
  WidgetRef ref, {
  PrayerType? prayer,
}) async {
  final repo = ref.read(worshipRepositoryProvider);
  final isFast = prayer == null;
  final input = await showQuantitySheet(
    context,
    title: isFast ? 'Ro‘za qarzi qo‘shish' : '${prayer.label} — qarz qo‘shish',
    subtitle: 'Keyinroq aniqlangan qazolarni qo‘shing',
    confirmLabel: 'Qarzga qo‘shish',
    quantityUnit: isFast ? 'kun' : 'ta',
    icon: Icons.add_circle_outline_rounded,
    accent: context.palette.gold,
  );
  if (input == null || !context.mounted) return;
  try {
    final record = isFast
        ? await repo.addFastingDebt(
            input.quantity,
            date: input.date,
            note: input.note,
            entryKey: newEntryKey(),
          )
        : await repo.addPrayerDebt(
            prayer,
            input.quantity,
            date: input.date,
            note: input.note,
            entryKey: newEntryKey(),
          );
    if (!context.mounted) return;
    showSnack(
      context,
      '${formatCount(input.quantity)} ${isFast ? 'kun' : 'ta'} qarz qo‘shildi',
      actionLabel: 'Bekor qilish',
      onAction: () => reverseRecordFlow(context, ref, record),
    );
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
  }
}

/// Edit the estimated initial debt.
Future<void> editInitialFlow(
  BuildContext context,
  WidgetRef ref, {
  PrayerType? prayer,
  required int current,
}) async {
  final repo = ref.read(worshipRepositoryProvider);
  final isFast = prayer == null;
  final input = await showQuantitySheet(
    context,
    title: 'Boshlang‘ich qarz',
    subtitle: isFast
        ? 'Taxminiy qazo ro‘za kunlari soni'
        : '${prayer.label} — taxminiy qazo namozlar soni',
    confirmLabel: 'Saqlash',
    initialQuantity: current,
    minQuantity: 0,
    showDate: false,
    showNote: false,
    quantityUnit: isFast ? 'kun' : 'ta',
    icon: Icons.edit_note_rounded,
  );
  if (input == null || !context.mounted) return;
  try {
    await repo.setInitialDebt(
      isFast ? WorshipKind.fast : WorshipKind.prayer,
      input.quantity,
      prayerType: prayer,
    );
    if (context.mounted) showSnack(context, 'Boshlang‘ich qarz yangilandi');
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
  }
}

/// Undo a record after confirmation. The record stays in the history.
Future<void> reverseRecordFlow(
  BuildContext context,
  WidgetRef ref,
  WorshipRecord record,
) async {
  if (!context.mounted) return;
  final ok = await showConfirmDialog(
    context,
    title: 'Yozuvni bekor qilasizmi?',
    message:
        '${describeRecord(record)} (${formatDate(record.completedDate)}) '
        'bekor qilinadi va hisob-kitobdan chiqariladi. Yozuv tarixda '
        '“bekor qilingan” deb saqlanib qoladi va uni qayta tiklash mumkin.',
    confirmLabel: 'Bekor qilish',
    cancelLabel: 'Yo‘q',
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  try {
    await ref.read(worshipRepositoryProvider).reverseRecord(record.id);
    if (context.mounted) showSnack(context, 'Yozuv bekor qilindi');
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
  }
}

Future<void> restoreRecordFlow(
  BuildContext context,
  WidgetRef ref,
  WorshipRecord record,
) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Yozuvni qayta tiklaysizmi?',
    message: '${describeRecord(record)} yana hisob-kitobga qo‘shiladi.',
    confirmLabel: 'Tiklash',
  );
  if (!ok || !context.mounted) return;
  try {
    await ref.read(worshipRepositoryProvider).restoreRecord(record.id);
    if (context.mounted) showSnack(context, 'Yozuv tiklandi');
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
  }
}

/// Correct date, quantity or note of a record.
Future<void> editRecordFlow(
  BuildContext context,
  WidgetRef ref,
  WorshipRecord record,
) async {
  final isFastCompletion =
      record.type == WorshipKind.fast &&
      record.action == RecordAction.completed;
  final input = await showQuantitySheet(
    context,
    title: 'Yozuvni tahrirlash',
    subtitle: describeRecord(record),
    confirmLabel: 'Saqlash',
    initialQuantity: record.quantity,
    quantityEditable: !isFastCompletion,
    initialDate: record.completedDate,
    initialNote: record.note,
    quantityUnit: unitFor(record.type),
    icon: Icons.edit_rounded,
  );
  if (input == null || !context.mounted) return;
  try {
    await ref
        .read(worshipRepositoryProvider)
        .editRecord(
          record.id,
          date: input.date,
          quantity: input.quantity,
          note: input.note ?? '',
        );
    if (context.mounted) showSnack(context, 'Yozuv yangilandi');
  } on WorshipException catch (e) {
    if (context.mounted) showSnack(context, e.message);
  }
}

String describeRecord(WorshipRecord r) {
  final unit = unitFor(r.type);
  final subject = recordSubject(r);
  return switch (r.action) {
    RecordAction.completed =>
      r.type == WorshipKind.fast
          ? 'Qazo ro‘za: ${formatCount(r.quantity)} kun tutildi'
          : '$subject: ${formatCount(r.quantity)} ta ado qilindi',
    RecordAction.debtAdded =>
      '$subject: +${formatCount(r.quantity)} $unit qarz qo‘shildi',
    RecordAction.initialSet =>
      '$subject: boshlang‘ich qarz ${formatCount(r.quantity)} $unit',
  };
}
