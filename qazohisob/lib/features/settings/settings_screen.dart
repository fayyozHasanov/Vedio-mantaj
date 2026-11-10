import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_texts.dart';
import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dialogs.dart';
import '../../shared/domain/exceptions.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/record_tile.dart';
import 'data/file_transfer.dart';

final fileTransferProvider = Provider<FileTransfer>(
  (ref) => const FileTransfer(),
);

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: AsyncBody(
        value: settings,
        builder: (s) => _SettingsBody(settings: s),
      ),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  const _SettingsBody({required this.settings});

  final Setting settings;

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  bool _busy = false;

  Setting get s => widget.settings;

  /// Saves a settings change and re-schedules reminders accordingly.
  Future<void> _saveReminders(SettingsCompanion changes) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.update(changes);
    try {
      await ref.read(reminderSchedulerProvider).apply(await repo.load());
    } catch (e) {
      if (mounted) showSnack(context, 'Eslatmani rejalashtirib bo‘lmadi: $e');
    }
  }

  Future<void> _toggleNotifications(bool enable) async {
    if (enable) {
      final granted = await ref
          .read(reminderSchedulerProvider)
          .requestPermission();
      if (!granted) {
        if (mounted) {
          showSnack(
            context,
            'Bildirishnomalarga ruxsat berilmadi. iPhone Sozlamalari → '
            'QazoHisob bo‘limidan ruxsat bering.',
          );
        }
        return;
      }
    }
    await _saveReminders(
      SettingsCompanion(notificationsEnabled: Value(enable)),
    );
  }

  Future<void> _pickTime({required bool prayer}) async {
    final current = prayer ? s.prayerReminderTime : s.fastingReminderTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: 'Eslatma vaqti',
      cancelText: 'Bekor qilish',
      confirmText: 'Saqlash',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    await _saveReminders(
      prayer
          ? SettingsCompanion(prayerReminderTime: Value(minutes))
          : SettingsCompanion(fastingReminderTime: Value(minutes)),
    );
  }

  Future<void> _export({required bool csv}) async {
    setState(() => _busy = true);
    try {
      final backup = ref.read(backupRepositoryProvider);
      final transfer = ref.read(fileTransferProvider);
      final content = csv
          ? await backup.exportCsv()
          : await backup.exportJson();
      final file = await transfer.writeExport(
        content: content,
        extension: csv ? 'csv' : 'json',
      );
      if (!mounted) return;
      await transfer.share(
        context,
        file,
        csv ? 'text/csv' : 'application/json',
      );
    } catch (e) {
      if (mounted) showSnack(context, 'Eksport qilib bo‘lmadi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final String? source;
    try {
      source = await ref.read(fileTransferProvider).pickBackup();
    } catch (e) {
      if (mounted) showSnack(context, 'Faylni o‘qib bo‘lmadi: $e');
      return;
    }
    if (source == null || !mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Zaxiradan tiklaysizmi?',
      message:
          'Hozirgi barcha qarzlar, tarix va sozlamalar tanlangan '
          'zaxira fayldagi ma’lumotlar bilan almashtiriladi. Davom etishdan '
          'oldin joriy ma’lumotlarni eksport qilib qo‘yish tavsiya etiladi.',
      confirmLabel: 'Tiklash',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(backupRepositoryProvider).restoreJson(source);
      await ref
          .read(reminderSchedulerProvider)
          .apply(await ref.read(settingsRepositoryProvider).load());
      if (mounted) showSnack(context, 'Ma’lumotlar zaxiradan tiklandi');
    } on WorshipException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  Future<void> _reset() async {
    final first = await showConfirmDialog(
      context,
      title: 'Barcha ma’lumotlarni o‘chirasizmi?',
      message:
          'Barcha qarzlar, ado qilingan yozuvlar va butun tarix '
          'o‘chiriladi. Bu amalni ortga qaytarib bo‘lmaydi.',
      confirmLabel: 'Davom etish',
      destructive: true,
    );
    if (!first || !mounted) return;
    final second = await showConfirmDialog(
      context,
      title: 'Ishonchingiz komilmi?',
      message: 'Zaxira nusxasi bo‘lmasa, ma’lumotlarni tiklab bo‘lmaydi.',
      confirmLabel: 'Ha, o‘chirish',
      destructive: true,
    );
    if (!second || !mounted) return;
    await ref.read(backupRepositoryProvider).resetAll();
    await ref
        .read(reminderSchedulerProvider)
        .apply(await ref.read(settingsRepositoryProvider).load());
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final version = ref.watch(appVersionProvider);
    return AbsorbPointer(
      absorbing: _busy,
      child: ListView(
        padding: pagePadding(context, top: 0, bottom: 40),
        children: [
          const SectionHeader('Ko‘rinish'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mavzu', style: context.text.titleSmall),
                const SizedBox(height: Gap.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppThemeMode>(
                    key: const Key('themeSelector'),
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        label: Text('Tizim'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        label: Text('Yorug‘'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        label: Text('Qorong‘i'),
                      ),
                    ],
                    selected: {s.theme},
                    onSelectionChanged: (v) => settingsRepo.setTheme(v.first),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('Hisob'),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: 4,
            ),
            child: Column(
              children: [
                ListTile(
                  key: const Key('initialDebtsTile'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('Boshlang‘ich qarzlar'),
                  subtitle: const Text('Taxminiy qazo miqdorlarini tahrirlash'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/initial'),
                ),
                const Divider(),
                SwitchListTile(
                  key: const Key('settingsVitr'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.auto_awesome_rounded),
                  title: const Text('Vitr namozini hisoblash'),
                  subtitle: const Text('Hukmi mazhablarda farq qiladi'),
                  value: s.vitrEnabled,
                  onChanged: settingsRepo.setVitrEnabled,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Kunlik maqsad'),
                  subtitle: Text('${s.dailyPrayerGoal} ta qazo namoz'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Kamaytirish',
                        onPressed: s.dailyPrayerGoal > 1
                            ? () => settingsRepo.setDailyGoal(
                                s.dailyPrayerGoal - 1,
                              )
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      IconButton(
                        tooltip: 'Ko‘paytirish',
                        onPressed: s.dailyPrayerGoal < 100
                            ? () => settingsRepo.setDailyGoal(
                                s.dailyPrayerGoal + 1,
                              )
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('Eslatmalar'),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: 4,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('notificationsSwitch'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Eslatmalarni yoqish'),
                  subtitle: const Text(
                    'Eslatma faqat yodlatadi, hech narsani belgilamaydi',
                  ),
                  value: s.notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                if (s.notificationsEnabled) ...[
                  const Divider(),
                  _ReminderRow(
                    keyPrefix: 'prayer',
                    title: 'Namoz eslatmasi',
                    enabled: s.prayerReminderEnabled,
                    minutes: s.prayerReminderTime,
                    onToggle: (v) => _saveReminders(
                      SettingsCompanion(prayerReminderEnabled: Value(v)),
                    ),
                    onPickTime: () => _pickTime(prayer: true),
                  ),
                  const Divider(),
                  _ReminderRow(
                    keyPrefix: 'fasting',
                    title: 'Ro‘za eslatmasi',
                    enabled: s.fastingReminderEnabled,
                    minutes: s.fastingReminderTime,
                    onToggle: (v) => _saveReminders(
                      SettingsCompanion(fastingReminderEnabled: Value(v)),
                    ),
                    onPickTime: () => _pickTime(prayer: false),
                  ),
                ],
              ],
            ),
          ),
          const SectionHeader('Ma’lumotlar'),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: 4,
            ),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.backup_outlined,
                  title: 'Zaxira nusxa (JSON)',
                  subtitle: 'Barcha ma’lumotlarni faylga eksport qilish',
                  onTap: () => _export(csv: false),
                ),
                const Divider(),
                _ActionTile(
                  icon: Icons.table_chart_outlined,
                  title: 'Tarixni eksport qilish (CSV)',
                  subtitle: 'Excel yoki Numbers uchun',
                  onTap: () => _export(csv: true),
                ),
                const Divider(),
                _ActionTile(
                  icon: Icons.restore_rounded,
                  title: 'Zaxiradan tiklash',
                  subtitle: 'JSON zaxira faylini tanlash',
                  onTap: _restore,
                ),
                const Divider(),
                _ActionTile(
                  key: const Key('resetData'),
                  icon: Icons.delete_outline_rounded,
                  title: 'Ma’lumotlarni tozalash',
                  subtitle: 'Hammasini o‘chirish (tasdiq so‘raladi)',
                  danger: true,
                  onTap: _reset,
                ),
              ],
            ),
          ),
          const SectionHeader('Ilova haqida'),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: 4,
            ),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.menu_book_outlined,
                  title: AppTexts.disclaimerTitle,
                  subtitle: 'Hisoblash usullari va hukmlar haqida',
                  onTap: () => showInfoDialog(
                    context,
                    title: AppTexts.disclaimerTitle,
                    message: AppTexts.disclaimer,
                  ),
                ),
                const Divider(),
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: AppTexts.privacyTitle,
                  subtitle: 'Ma’lumotlar faqat qurilmangizda',
                  onTap: () => showInfoDialog(
                    context,
                    title: AppTexts.privacyTitle,
                    message: AppTexts.privacy,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Ilova versiyasi'),
                  trailing: Text(
                    version.value ?? '—',
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(Gap.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.keyPrefix,
    required this.title,
    required this.enabled,
    required this.minutes,
    required this.onToggle,
    required this.onPickTime,
  });

  final String keyPrefix;
  final String title;
  final bool enabled;
  final int minutes;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleSmall),
              Text('Har kuni', style: context.text.bodySmall),
            ],
          ),
        ),
        TextButton(
          key: Key('${keyPrefix}Time'),
          onPressed: enabled ? onPickTime : null,
          child: Text(
            formatMinutes(minutes),
            style: const TextStyle(fontSize: 17),
          ),
        ),
        Switch(
          key: Key('${keyPrefix}ReminderSwitch'),
          value: enabled,
          onChanged: onToggle,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.colors.error : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
