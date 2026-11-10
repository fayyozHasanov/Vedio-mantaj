import 'package:drift/drift.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$SettingsTable, Setting> get _row =>
      _db.select(_db.settings)..where((t) => t.id.equals(1));

  Stream<Setting> watch() => _row.watchSingle();

  Future<Setting> load() => _row.getSingle();

  Future<void> update(SettingsCompanion changes) =>
      (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(changes);

  Future<void> setTheme(AppThemeMode mode) =>
      update(SettingsCompanion(theme: Value(mode)));

  Future<void> setVitrEnabled(bool enabled) =>
      update(SettingsCompanion(vitrEnabled: Value(enabled)));

  Future<void> setDailyGoal(int goal) =>
      update(SettingsCompanion(dailyPrayerGoal: Value(goal.clamp(1, 100))));

  Future<void> setOnboardingCompleted(bool done) =>
      update(SettingsCompanion(onboardingCompleted: Value(done)));
}
