import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/utilities/date_utils.dart';
import '../domain/exceptions.dart';

/// Export (JSON / CSV), backup restore and full reset.
class BackupRepository {
  BackupRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const appId = 'QazoHisob';
  static const formatVersion = 1;

  // ---------------------------------------------------------------- export

  Future<Map<String, Object?>> exportMap() => _db.transaction(() async {
    final settings = await (_db.select(
      _db.settings,
    )..where((t) => t.id.equals(1))).getSingle();
    final prayers = await _db.select(_db.prayerDebts).get();
    final fasting = await (_db.select(
      _db.fastingDebts,
    )..where((t) => t.id.equals(1))).getSingle();
    final records = await (_db.select(
      _db.worshipRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return {
      'app': appId,
      'format': formatVersion,
      'exportedAt': _now().toIso8601String(),
      'settings': {
        'theme': settings.theme.name,
        'notificationsEnabled': settings.notificationsEnabled,
        'prayerReminderEnabled': settings.prayerReminderEnabled,
        'prayerReminderTime': settings.prayerReminderTime,
        'fastingReminderEnabled': settings.fastingReminderEnabled,
        'fastingReminderTime': settings.fastingReminderTime,
        'vitrEnabled': settings.vitrEnabled,
        'dailyPrayerGoal': settings.dailyPrayerGoal,
      },
      'prayerDebts': [
        for (final p in prayers)
          {
            'prayerType': p.prayerType.name,
            'initialQuantity': p.initialQuantity,
            'createdAt': p.createdAt.toIso8601String(),
            'updatedAt': p.updatedAt.toIso8601String(),
          },
      ],
      'fastingDebt': {
        'initialQuantity': fasting.initialQuantity,
        'createdAt': fasting.createdAt.toIso8601String(),
        'updatedAt': fasting.updatedAt.toIso8601String(),
      },
      'records': [
        for (final r in records)
          {
            'entryKey': r.entryKey,
            'type': r.type.name,
            'prayerType': r.prayerType?.name,
            'action': r.action.name,
            'quantity': r.quantity,
            'completedDate': r.completedDate.toIso8601String(),
            'createdAt': r.createdAt.toIso8601String(),
            'editedAt': r.editedAt?.toIso8601String(),
            'reversedAt': r.reversedAt?.toIso8601String(),
            'note': r.note,
          },
      ],
    };
  });

  Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert(await exportMap());

  /// History as CSV (one row per record), suitable for spreadsheets.
  Future<String> exportCsv() async {
    final records =
        await (_db.select(_db.worshipRecords)..orderBy([
              (t) => OrderingTerm.asc(t.completedDate),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final rows = <List<String>>[
      [
        'id',
        'sana',
        'turi',
        'namoz',
        'amal',
        'miqdor',
        'yaratilgan',
        'holat',
        'izoh',
      ],
      for (final r in records)
        [
          '${r.id}',
          '${r.completedDate.year}-${two(r.completedDate.month)}-'
              '${two(r.completedDate.day)}',
          r.type == WorshipKind.prayer ? 'Namoz' : 'Ro‘za',
          r.prayerType?.label ?? '',
          switch (r.action) {
            RecordAction.completed => 'Ado qilindi',
            RecordAction.debtAdded => 'Qarz qo‘shildi',
            RecordAction.initialSet => 'Boshlang‘ich qiymat',
          },
          '${r.quantity}',
          r.createdAt.toIso8601String(),
          r.reversedAt == null ? 'Faol' : 'Bekor qilingan',
          r.note ?? '',
        ],
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }

  static String _csvCell(String v) {
    if (v.contains(RegExp(r'[",\r\n]'))) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  // --------------------------------------------------------------- restore

  /// Replaces all data with the contents of a JSON backup.
  Future<void> restoreJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const BackupFormatException('Fayl JSON formatida emas.');
    }
    return restoreMap(decoded);
  }

  Future<void> restoreMap(Object? data) async {
    final parsed = _parse(data);
    await _db.transaction(() async {
      await _db.delete(_db.worshipRecords).go();
      final now = _now();
      for (final type in PrayerType.values) {
        await (_db.update(
          _db.prayerDebts,
        )..where((t) => t.prayerType.equalsValue(type))).write(
          PrayerDebtsCompanion(
            initialQuantity: Value(parsed.prayerInitial[type] ?? 0),
            updatedAt: Value(now),
          ),
        );
      }
      await (_db.update(_db.fastingDebts)..where((t) => t.id.equals(1))).write(
        FastingDebtsCompanion(
          initialQuantity: Value(parsed.fastingInitial),
          updatedAt: Value(now),
        ),
      );
      await _db.batch((b) => b.insertAll(_db.worshipRecords, parsed.records));
      await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
        parsed.settings.copyWith(onboardingCompleted: const Value(true)),
      );
    });
  }

  _ParsedBackup _parse(Object? data) {
    T read<T>(Map<String, Object?> m, String key) {
      final v = m[key];
      if (v is T) return v;
      throw BackupFormatException('Zaxira faylida “$key” maydoni noto‘g‘ri.');
    }

    DateTime date(Map<String, Object?> m, String key) {
      final v = DateTime.tryParse(read<String>(m, key));
      if (v == null) {
        throw BackupFormatException('“$key” sanasi noto‘g‘ri.');
      }
      return v;
    }

    DateTime? optDate(Map<String, Object?> m, String key) =>
        m[key] == null ? null : date(m, key);

    E byName<E extends Enum>(List<E> values, String name) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      throw BackupFormatException('Noma’lum qiymat: $name');
    }

    int nonNegative(Map<String, Object?> m, String key) {
      final v = read<int>(m, key);
      if (v < 0) {
        throw BackupFormatException('“$key” manfiy bo‘lmasligi kerak.');
      }
      return v;
    }

    if (data is! Map<String, Object?>) {
      throw const BackupFormatException('Zaxira fayli tuzilishi noto‘g‘ri.');
    }
    if (data['app'] != appId) {
      throw const BackupFormatException('Bu fayl QazoHisob zaxirasi emas.');
    }
    final format = data['format'];
    if (format is! int || format > formatVersion) {
      throw const BackupFormatException(
        'Zaxira fayli ilovaning yangiroq versiyasida yaratilgan.',
      );
    }

    final prayerInitial = <PrayerType, int>{};
    for (final item in read<List<Object?>>(data, 'prayerDebts')) {
      if (item is! Map<String, Object?>) {
        throw const BackupFormatException('Namoz qarzlari ro‘yxati noto‘g‘ri.');
      }
      prayerInitial[byName(
        PrayerType.values,
        read<String>(item, 'prayerType'),
      )] = nonNegative(
        item,
        'initialQuantity',
      );
    }
    final fastingInitial = nonNegative(
      read<Map<String, Object?>>(data, 'fastingDebt'),
      'initialQuantity',
    );

    final seen = <String>{};
    final records = <WorshipRecordsCompanion>[];
    for (final item in read<List<Object?>>(data, 'records')) {
      if (item is! Map<String, Object?>) {
        throw const BackupFormatException('Yozuvlar ro‘yxati noto‘g‘ri.');
      }
      final key = read<String>(item, 'entryKey');
      if (!seen.add(key)) continue; // skip duplicated records
      final kind = byName(WorshipKind.values, read<String>(item, 'type'));
      final prayerName = item['prayerType'];
      final prayer = prayerName == null
          ? null
          : byName(PrayerType.values, prayerName as String);
      if ((kind == WorshipKind.prayer) != (prayer != null)) {
        throw const BackupFormatException('Yozuv turi va namoz turi mos emas.');
      }
      records.add(
        WorshipRecordsCompanion.insert(
          entryKey: key,
          type: kind,
          prayerType: Value(prayer),
          action: byName(RecordAction.values, read<String>(item, 'action')),
          quantity: nonNegative(item, 'quantity'),
          completedDate: dateOnly(date(item, 'completedDate')),
          createdAt: date(item, 'createdAt'),
          editedAt: Value(optDate(item, 'editedAt')),
          reversedAt: Value(optDate(item, 'reversedAt')),
          note: Value(item['note'] as String?),
        ),
      );
    }

    final s = read<Map<String, Object?>>(data, 'settings');
    int minutes(String key) {
      final v = read<int>(s, key);
      if (v < 0 || v >= 24 * 60) {
        throw BackupFormatException('“$key” vaqti noto‘g‘ri.');
      }
      return v;
    }

    final settings = SettingsCompanion(
      theme: Value(byName(AppThemeMode.values, read<String>(s, 'theme'))),
      notificationsEnabled: Value(read<bool>(s, 'notificationsEnabled')),
      prayerReminderEnabled: Value(read<bool>(s, 'prayerReminderEnabled')),
      prayerReminderTime: Value(minutes('prayerReminderTime')),
      fastingReminderEnabled: Value(read<bool>(s, 'fastingReminderEnabled')),
      fastingReminderTime: Value(minutes('fastingReminderTime')),
      vitrEnabled: Value(read<bool>(s, 'vitrEnabled')),
      dailyPrayerGoal: Value(read<int>(s, 'dailyPrayerGoal').clamp(1, 100)),
    );

    return _ParsedBackup(
      prayerInitial: prayerInitial,
      fastingInitial: fastingInitial,
      records: records,
      settings: settings,
    );
  }

  // ----------------------------------------------------------------- reset

  /// Deletes all history and debts. Only called after explicit confirmation.
  Future<void> resetAll() => _db.transaction(() async {
    final now = _now();
    await _db.delete(_db.worshipRecords).go();
    await _db
        .update(_db.prayerDebts)
        .write(
          PrayerDebtsCompanion(
            initialQuantity: const Value(0),
            updatedAt: Value(now),
          ),
        );
    await _db
        .update(_db.fastingDebts)
        .write(
          FastingDebtsCompanion(
            initialQuantity: const Value(0),
            updatedAt: Value(now),
          ),
        );
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      const SettingsCompanion(
        onboardingCompleted: Value(false),
        notificationsEnabled: Value(false),
      ),
    );
  });
}

class _ParsedBackup {
  _ParsedBackup({
    required this.prayerInitial,
    required this.fastingInitial,
    required this.records,
    required this.settings,
  });

  final Map<PrayerType, int> prayerInitial;
  final int fastingInitial;
  final List<WorshipRecordsCompanion> records;
  final SettingsCompanion settings;
}
