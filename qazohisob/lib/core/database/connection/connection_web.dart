import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Which browser storage was chosen (shown on the startup error screen).
String? webStorageInfo;

/// Storage back-ends in order of preference. Each one is tried with a
/// timeout, because some browsers (notably Safari) can hang on one of them
/// instead of failing; the next one is tried in that case.
const _preference = [
  WasmStorageImplementation.opfsShared,
  WasmStorageImplementation.opfsLocks,
  WasmStorageImplementation.sharedIndexedDb,
  WasmStorageImplementation.unsafeIndexedDb,
];

QueryExecutor openConnection(String name) =>
    DatabaseConnection.delayed(_open(name));

Future<DatabaseConnection> _open(String name) async {
  final probed = await WasmDatabase.probe(
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
    databaseName: name,
  ).timeout(const Duration(seconds: 15));

  final available = probed.availableStorages.toSet();
  final missing = probed.missingFeatures.map((f) => f.name).join(', ');

  // Keep using the storage that already holds the user's data.
  final existingApis = {
    for (final db in probed.existingDatabases)
      if (db.$2 == name) db.$1,
  };
  final candidates = <WasmStorageImplementation>{
    ..._preference.where(
      (i) => available.contains(i) && existingApis.contains(i.storageApi),
    ),
    ..._preference.where(available.contains),
  }.toList();

  final failures = <String>[];
  for (final implementation in candidates) {
    try {
      final connection = await probed
          .open(implementation, name)
          .timeout(const Duration(seconds: 8));
      webStorageInfo =
          implementation.name + (missing.isEmpty ? '' : ' (yo‘q: $missing)');
      debugPrint('QazoHisob web storage: $webStorageInfo');
      return connection;
    } catch (e) {
      failures.add('${implementation.name}: $e');
      debugPrint('QazoHisob: ${implementation.name} failed: $e');
    }
  }

  webStorageInfo = 'mavjud emas (yo‘q: $missing)';
  throw StateError(
    'Brauzer ma’lumotlarni doimiy saqlay olmayapti '
    '(${failures.isEmpty ? 'mos saqlash turi topilmadi' : failures.join('; ')}). '
    'Safari Maxfiy (Private) rejimda bo‘lishi mumkin.',
  );
}
