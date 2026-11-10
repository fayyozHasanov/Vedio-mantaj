import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:qazohisob/core/database/app_database.dart';

/// Fresh in-memory database for each test.
AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// A controllable clock.
class TestClock {
  TestClock(this.value);
  DateTime value;
  DateTime call() => value;
}
