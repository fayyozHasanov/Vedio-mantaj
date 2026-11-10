import 'dart:math';

final Random _random = Random.secure();

/// Random 128-bit hex key used to make record inserts idempotent.
String newEntryKey() {
  final buf = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buf.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buf.toString();
}
