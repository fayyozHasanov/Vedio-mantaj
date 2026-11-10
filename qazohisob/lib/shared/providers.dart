import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/notifications/reminder_scheduler.dart';
import 'data/backup_repository.dart';
import 'data/settings_repository.dart';
import 'data/worship_repository.dart';
import 'domain/debt_summary.dart';

/// Overridden in `main.dart` (real database) and in tests (in-memory).
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Current time; overridable for tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => NoopReminderScheduler(),
);

final worshipRepositoryProvider = Provider<WorshipRepository>(
  (ref) => WorshipRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

/// Live debts + history. Updates automatically after every change.
final snapshotProvider = StreamProvider<WorshipSnapshot>(
  (ref) => ref.watch(worshipRepositoryProvider).watchSnapshot(),
);

/// Live settings row.
final settingsProvider = StreamProvider<Setting>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);
