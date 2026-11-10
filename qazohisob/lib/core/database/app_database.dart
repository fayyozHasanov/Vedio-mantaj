import 'package:drift/drift.dart';

import 'connection/connection.dart';

import '../constants/worship_types.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [PrayerDebts, FastingDebts, WorshipRecords, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file.
  /// On the web (PWA build) SQLite runs as WebAssembly in a worker and the
  /// data is kept in the browser's persistent storage.
  factory AppDatabase.open() => AppDatabase(openConnection('qazohisob'));

  /// Bump this and add a step in [migration] whenever the schema changes.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Run each step in order so users upgrading across several
      // versions get every change.
      for (var version = from + 1; version <= to; version++) {
        await _migrateTo(m, version);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await ensureSeedData();
    },
  );

  Future<void> _migrateTo(Migrator m, int version) async {
    switch (version) {
      case 2:
        // Profile (name) and the year length used for period conversion.
        await m.addColumn(settings, settings.firstName);
        await m.addColumn(settings, settings.lastName);
        await m.addColumn(settings, settings.yearDays);
      default:
        break;
    }
  }

  /// Makes sure the singleton rows exist. Safe to call repeatedly.
  Future<void> ensureSeedData() async {
    final now = DateTime.now();
    await batch((b) {
      b.insert(
        settings,
        SettingsCompanion.insert(id: const Value(1)),
        mode: InsertMode.insertOrIgnore,
      );
      b.insert(
        fastingDebts,
        FastingDebtsCompanion.insert(
          id: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
      for (final type in PrayerType.values) {
        b.insert(
          prayerDebts,
          PrayerDebtsCompanion.insert(
            prayerType: type,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }
}
