import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/shared/data/backup_repository.dart';
import 'package:qazohisob/shared/data/onboarding_state.dart';
import 'package:qazohisob/shared/data/settings_repository.dart';
import 'package:qazohisob/shared/data/worship_repository.dart';

import 'helpers.dart';

void main() {
  group('profile and onboarding state', () {
    late AppDatabase db;
    late SettingsRepository settings;

    setUp(() {
      db = memoryDb();
      settings = SettingsRepository(db);
    });
    tearDown(() => db.close());

    test('a fresh install shows onboarding', () async {
      expect(await isOnboarded(db), isFalse);
    });

    test('saving the name signs in and completes onboarding', () async {
      await settings.saveProfile(firstName: '  Ali ', lastName: 'Valiyev ');
      final s = await settings.load();
      expect(s.firstName, 'Ali');
      expect(s.lastName, 'Valiyev');
      expect(s.onboardingCompleted, isTrue);
      expect(await isOnboarded(db), isTrue);
    });

    test('empty names are rejected', () async {
      expect(
        () => settings.saveProfile(firstName: ' ', lastName: 'Valiyev'),
        throwsArgumentError,
      );
    });

    test('existing data never sends the user back to onboarding', () async {
      // Debts were entered but onboarding was interrupted before the end.
      await WorshipRepository(db)
          .setInitialDebt(WorshipKind.prayer, 10, prayerType: PrayerType.asr);
      expect((await settings.load()).onboardingCompleted, isFalse);
      expect(await isOnboarded(db), isTrue);
      // The stored flag is repaired.
      expect((await settings.load()).onboardingCompleted, isTrue);
    });

    test('reset clears the name so onboarding starts again', () async {
      await settings.saveProfile(firstName: 'Ali', lastName: 'Valiyev');
      await BackupRepository(db).resetAll();
      final s = await settings.load();
      expect(s.firstName, isEmpty);
      expect(await isOnboarded(db), isFalse);
    });

    test('profile and year length survive backup and restore', () async {
      await settings.saveProfile(firstName: 'Ali', lastName: 'Valiyev');
      await settings.setYearDays(354);
      final backup = BackupRepository(db);
      final json = await backup.exportJson();
      await backup.resetAll();
      await backup.restoreJson(json);
      final s = await settings.load();
      expect(s.firstName, 'Ali');
      expect(s.lastName, 'Valiyev');
      expect(s.yearDays, 354);
    });
  });

  test('schema v1 database is upgraded to the latest keeping data', () async {
    final dir = await Directory.systemTemp.createTemp('qazohisob_mig');
    final file = File('${dir.path}/db.sqlite');
    try {
      // Create a database, then turn it back into the version 1 layout.
      var db = AppDatabase(NativeDatabase(file));
      await WorshipRepository(
        db,
      ).setInitialDebt(WorshipKind.prayer, 42, prayerType: PrayerType.bomdod);
      await SettingsRepository(db).setVitrEnabled(true);
      for (final column in ['first_name', 'last_name', 'year_days']) {
        await db.customStatement('ALTER TABLE settings DROP COLUMN $column');
      }
      await db.customStatement('DROP TABLE zikr_counts');
      await db.customStatement('PRAGMA user_version = 1');
      await db.close();

      // Opening with the current schema runs the migration.
      db = AppDatabase(NativeDatabase(file));
      final s = await SettingsRepository(db).load();
      expect(s.firstName, '');
      expect(s.lastName, '');
      expect(s.yearDays, 365);
      expect(s.vitrEnabled, isTrue);
      final snap = await WorshipRepository(db).loadSnapshot();
      expect(snap.prayer(PrayerType.bomdod).remaining, 42);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 3);
      // v3 added the zikr table.
      await db.customSelect('SELECT COUNT(*) FROM zikr_counts').get();
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
