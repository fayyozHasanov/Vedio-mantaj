import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/widgets/startup_error_app.dart';
import 'shared/data/settings_repository.dart';
import 'shared/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await start();
}

/// Opens the database and runs the app. If the database cannot be opened
/// (e.g. browser storage is unavailable), shows an error screen with a retry
/// button instead of hanging on the splash screen.
Future<void> start() async {
  final AppDatabase db;
  final Setting settings;
  try {
    db = AppDatabase.open();
    settings = await SettingsRepository(db)
        .load()
        .timeout(const Duration(seconds: 20));
  } catch (error, stack) {
    debugPrint('QazoHisob startup failed: $error\n$stack');
    runApp(StartupErrorApp(error: error, onRetry: start));
    return;
  }

  // Local notifications exist only in the native iOS app; the web (PWA)
  // build has no reminders.
  final ReminderScheduler scheduler = kIsWeb
      ? NoopReminderScheduler()
      : LocalReminderScheduler();
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
