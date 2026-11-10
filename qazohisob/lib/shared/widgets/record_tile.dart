import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import 'worship_actions.dart';

/// One history entry. Tapping opens the correction actions.
class RecordTile extends ConsumerWidget {
  const RecordTile({super.key, required this.record});

  final WorshipRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final reversed = record.reversedAt != null;
    final (IconData icon, Color color) = switch (record.action) {
      RecordAction.completed =>
        record.type == WorshipKind.fast
            ? (Icons.nightlight_round, p.fasting)
            : (Icons.check_rounded, p.prayer),
      RecordAction.debtAdded => (Icons.add_rounded, context.colors.error),
      RecordAction.initialSet => (Icons.edit_note_rounded, p.textSecondary),
    };
    final details = <String>[
      formatDate(record.completedDate),
      'qayd: ${formatDateTime(record.createdAt)}',
      if (record.editedAt != null) 'tahrirlangan',
    ];
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showActions(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: reversed ? 0.45 : 1,
              child: IconBadge(icon: icon, color: color, size: 38),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    describeRecord(record),
                    style: context.text.titleSmall?.copyWith(
                      decoration: reversed ? TextDecoration.lineThrough : null,
                      color: reversed ? p.textSecondary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(details.join(' · '), style: context.text.bodySmall),
                  if (record.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        record.note!,
                        style: context.text.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (reversed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Bekor qilingan · ${formatDateTime(record.reversedAt!)}',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (record.action != RecordAction.initialSet)
              Icon(Icons.more_horiz_rounded, color: p.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    if (record.action == RecordAction.initialSet) return;
    final reversed = record.reversedAt != null;
    final choice = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(describeRecord(record), style: context.text.titleMedium),
            Text(
              formatDate(record.completedDate),
              style: context.text.bodySmall,
            ),
            const SizedBox(height: Gap.md),
            if (!reversed)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Tahrirlash'),
                subtitle: const Text('Sana, miqdor yoki izohni tuzatish'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            if (!reversed)
              ListTile(
                leading: Icon(Icons.undo_rounded, color: context.colors.error),
                title: Text(
                  'Bekor qilish',
                  style: TextStyle(color: context.colors.error),
                ),
                subtitle: const Text('Xato kiritilgan bo‘lsa'),
                onTap: () => Navigator.pop(context, 'reverse'),
              ),
            if (reversed)
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: const Text('Qayta tiklash'),
                onTap: () => Navigator.pop(context, 'restore'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'edit':
        await editRecordFlow(context, ref, record);
      case 'reverse':
        await reverseRecordFlow(context, ref, record);
      case 'restore':
        await restoreRecordFlow(context, ref, record);
    }
  }
}

/// History list inside a card, grouped as a simple column.
class RecordList extends StatelessWidget {
  const RecordList({
    super.key,
    required this.records,
    this.emptyTitle = 'Hozircha yozuvlar yo‘q',
    this.emptyMessage,
    this.limit,
  });

  final List<WorshipRecord> records;
  final String emptyTitle;
  final String? emptyMessage;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.history_rounded,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }
    final shown = limit == null ? records : records.take(limit!).toList();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 54),
            RecordTile(record: shown[i]),
          ],
        ],
      ),
    );
  }
}

/// Small helper so screens can show loading / error states uniformly.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    final data = value.value;
    if (data != null) return builder(data);
    if (value.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ma’lumotlarni yuklab bo‘lmadi:\n${value.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
