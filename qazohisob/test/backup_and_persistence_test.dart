import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/shared/data/backup_repository.dart';
import 'package:qazohisob/shared/data/settings_repository.dart';
import 'package:qazohisob/shared/data/worship_repository.dart';
import 'package:qazohisob/shared/domain/exceptions.dart';

import 'helpers.dart';

void main() {
  group('persistence', () {
    test('data survives closing and reopening the database file', () async {
      final dir = await Directory.systemTemp.createTemp('qazohisob_test');
      final file = File('${dir.path}/db.sqlite');
      try {
        var db = AppDatabase(NativeDatabase(file));
        var repo = WorshipRepository(db);
        await repo.setInitialDebt(
          WorshipKind.prayer,
          40,
          prayerType: PrayerType.asr,
        );
        await repo.completePrayer(PrayerType.asr, 15);
        await repo.setInitialDebt(WorshipKind.fast, 6);
        await repo.completeFast(date: DateTime(2026, 3, 1));
        await SettingsRepository(db).setVitrEnabled(true);
        await db.close();

        db = AppDatabase(NativeDatabase(file));
        repo = WorshipRepository(db);
        final snap = await repo.loadSnapshot();
        expect(snap.prayer(PrayerType.asr).remaining, 25);
        expect(snap.fasting.remaining, 5);
        expect((await SettingsRepository(db).load()).vitrEnabled, isTrue);
        await db.close();
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test('seed rows are created once', () async {
      final db = memoryDb();
      await db.ensureSeedData();
      await db.ensureSeedData();
      expect(
        await db.select(db.prayerDebts).get(),
        hasLength(PrayerType.values.length),
      );
      expect(await db.select(db.settings).get(), hasLength(1));
      await db.close();
    });
  });

  group('backup', () {
    late AppDatabase db;
    late WorshipRepository repo;
    late BackupRepository backup;

    setUp(() async {
      db = memoryDb();
      repo = WorshipRepository(db);
      backup = BackupRepository(db, now: () => DateTime(2026, 11, 10, 12));
      await repo.setInitialDebts(
        prayers: {PrayerType.bomdod: 30, PrayerType.shom: 12},
        fasting: 10,
      );
      await repo.addPrayerDebt(PrayerType.shom, 3, note: 'safar, "eski"');
      final r = await repo.completePrayer(PrayerType.bomdod, 5);
      await repo.completeFast(date: DateTime(2026, 4, 2));
      await repo.reverseRecord(r.record.id);
      await repo.completePrayer(PrayerType.bomdod, 2);
    });

    tearDown(() => db.close());

    test('JSON export and restore round-trip', () async {
      final before = await repo.loadSnapshot();
      final json = await backup.exportJson();
      final map = jsonDecode(json) as Map<String, Object?>;
      expect(map['app'], 'QazoHisob');
      expect(map['format'], 1);

      await backup.resetAll();
      expect((await repo.loadSnapshot()).records, isEmpty);

      await backup.restoreJson(json);
      final after = await repo.loadSnapshot();
      for (final t in PrayerType.values) {
        expect(after.prayer(t), before.prayer(t), reason: t.name);
      }
      expect(after.fasting, before.fasting);
      expect(after.records, hasLength(before.records.length));
      expect(after.records.where((r) => r.reversedAt != null), hasLength(1));
      expect((await SettingsRepository(db).load()).onboardingCompleted, isTrue);
    });

    test('restore rejects foreign or broken files without changes', () async {
      final before = await repo.loadSnapshot();
      expect(
        () => backup.restoreJson('not json'),
        throwsA(isA<BackupFormatException>()),
      );
      expect(
        () => backup.restoreJson('{"app":"Other"}'),
        throwsA(isA<BackupFormatException>()),
      );
      final broken =
          jsonDecode(await backup.exportJson()) as Map<String, Object?>;
      (broken['records'] as List).add({'entryKey': 'x', 'type': 'prayer'});
      expect(
        () => backup.restoreMap(broken),
        throwsA(isA<BackupFormatException>()),
      );
      final after = await repo.loadSnapshot();
      expect(after.prayer(PrayerType.bomdod), before.prayer(PrayerType.bomdod));
    });

    test('restore skips duplicated records', () async {
      final map = jsonDecode(await backup.exportJson()) as Map<String, Object?>;
      final records = map['records'] as List;
      records.add(records.last);
      await backup.restoreMap(map);
      final snap = await repo.loadSnapshot();
      expect(snap.records, hasLength(records.length - 1));
    });

    test('CSV export has a header and escapes values', () async {
      final csv = await backup.exportCsv();
      final lines = csv.split('\r\n');
      expect(
        lines.first,
        'id,sana,turi,namoz,amal,miqdor,yaratilgan,holat,izoh',
      );
      expect(csv, contains('"safar, ""eski"""'));
      expect(csv, contains('Bekor qilingan'));
      expect(lines.length, (await repo.loadSnapshot()).records.length + 1);
    });

    test('reset clears debts and history and restarts onboarding', () async {
      await SettingsRepository(db).setOnboardingCompleted(true);
      await backup.resetAll();
      final snap = await repo.loadSnapshot();
      expect(snap.records, isEmpty);
      expect(snap.prayer(PrayerType.bomdod).totalDebt, 0);
      expect(snap.fasting.totalDebt, 0);
      expect(
        (await SettingsRepository(db).load()).onboardingCompleted,
        isFalse,
      );
    });
  });
}
