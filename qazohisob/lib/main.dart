import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'shared/data/settings_repository.dart';
import 'shared/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase.open();
  final settings = await SettingsRepository(db).load();

  final scheduler = LocalReminderScheduler();
  // Keep scheduled reminders in sync with saved settings (e.g. after a
  // restore or a time-zone change). Failures must not block startup.
  unawaited(
    scheduler
        .apply(settings)
        .catchError(
          (Object e) => debugPrint('Eslatmalarni tiklab bo‘lmadi: $e'),
        ),
  );

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: QazoHisobApp(onboarded: settings.onboardingCompleted),
    ),
  );
}
