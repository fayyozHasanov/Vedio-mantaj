import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Not used on native platforms.
String? webStorageInfo;

/// SQLite file in the app's documents directory.
QueryExecutor openConnection(String name) => driftDatabase(name: name);
