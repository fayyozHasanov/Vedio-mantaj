/// Platform-specific database connection: native SQLite file on iOS,
/// SQLite (WebAssembly) in browser storage on the web.
library;

export 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
