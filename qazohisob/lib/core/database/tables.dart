import 'package:drift/drift.dart';

import '../constants/worship_types.dart';

/// Initial (estimated) missed-prayer quantity per prayer type.
class PrayerDebts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prayerType => textEnum<PrayerType>().unique()();
  IntColumn get initialQuantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => ['CHECK (initial_quantity >= 0)'];
}

/// Initial (estimated) missed fasting days. Holds a single row (id = 1).
class FastingDebts extends Table {
  IntColumn get id => integer()();
  IntColumn get initialQuantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (initial_quantity >= 0)'];
}

/// Append-only history of everything the user records.
///
/// Records are never deleted by normal use: undoing an entry sets
/// [reversedAt], so the history always shows what happened.
@TableIndex(name: 'worship_records_date', columns: {#completedDate})
@TableIndex(name: 'worship_records_type', columns: {#type, #prayerType})
class WorshipRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Client-generated idempotency key; prevents duplicate records when an
  /// action is submitted twice (e.g. a double tap).
  TextColumn get entryKey => text().unique()();
  TextColumn get type => textEnum<WorshipKind>()();
  TextColumn get prayerType => textEnum<PrayerType>().nullable()();
  TextColumn get action => textEnum<RecordAction>()();
  IntColumn get quantity => integer()();

  /// Calendar day the act happened (or the debt was recorded), stored at
  /// local midnight.
  DateTimeColumn get completedDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  DateTimeColumn get reversedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  List<String> get customConstraints => ['CHECK (quantity >= 0)'];
}

/// App settings. Holds a single row (id = 1).
class Settings extends Table {
  IntColumn get id => integer()();
  TextColumn get theme => textEnum<AppThemeMode>().withDefault(
    Constant(AppThemeMode.system.name),
  )();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get prayerReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Minutes since midnight.
  IntColumn get prayerReminderTime =>
      integer().withDefault(const Constant(20 * 60))();
  BoolColumn get fastingReminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get fastingReminderTime =>
      integer().withDefault(const Constant(21 * 60 + 30))();
  BoolColumn get vitrEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get dailyPrayerGoal => integer().withDefault(const Constant(5))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
