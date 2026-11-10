// Web worker used by Drift on the web build.
// Rebuild with: dart compile js -O4 tool/drift_worker.dart -o web/drift_worker.js
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
