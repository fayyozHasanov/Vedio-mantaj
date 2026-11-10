import 'package:drift/drift.dart';

import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/utilities/ids.dart';
import '../domain/debt_summary.dart';
import '../domain/exceptions.dart';

/// Result of recording completed acts.
class CompletionResult {
  const CompletionResult({
    required this.record,
    this.addedForExcess = 0,
    this.duplicate = false,
  });

  final WorshipRecord record;

  /// Debt that was added automatically because the user confirmed
  /// completing more than was owed.
  final int addedForExcess;

  /// True when the same entry key was already stored (nothing changed).
  final bool duplicate;
}

/// All reads and writes of debts and history. Every write runs inside a
/// database transaction so counts and history never disagree.
class WorshipRepository {
  WorshipRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const _excessSuffix = '#excess';

  // ---------------------------------------------------------------- reads

  Future<WorshipSnapshot> loadSnapshot() => _db.transaction(_readSnapshot);

  Future<WorshipSnapshot> _readSnapshot() async {
    final debts = await _db.select(_db.prayerDebts).get();
    final fasting = await (_db.select(
      _db.fastingDebts,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    final records = await _db.select(_db.worshipRecords).get();
    return WorshipSnapshot.build(
      prayerInitial: {for (final d in debts) d.prayerType: d.initialQuantity},
      fastingInitial: fasting?.initialQuantity ?? 0,
      records: records,
    );
  }

  /// Emits a fresh snapshot now and after every change to the data.
  Stream<WorshipSnapshot> watchSnapshot() {
    final updates = _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.prayerDebts,
        _db.fastingDebts,
        _db.worshipRecords,
      ]),
    );
    return Stream<void>.multi((controller) {
      controller.add(null);
      final sub = updates.listen((_) => controller.add(null));
      controller.onCancel = sub.cancel;
    }).asyncMap((_) => loadSnapshot());
  }

  Future<DebtSummary> summaryFor(WorshipKind kind, [PrayerType? type]) =>
      _db.transaction(() => _summary(kind, type));

  Future<DebtSummary> _summary(WorshipKind kind, PrayerType? type) async {
    _checkKind(kind, type);
    final int initial;
    if (kind == WorshipKind.prayer) {
      final row = await (_db.select(
        _db.prayerDebts,
      )..where((t) => t.prayerType.equalsValue(type))).getSingleOrNull();
      initial = row?.initialQuantity ?? 0;
    } else {
      final row = await (_db.select(
        _db.fastingDebts,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      initial = row?.initialQuantity ?? 0;
    }
    final query = _db.select(_db.worshipRecords)
      ..where((t) => t.type.equalsValue(kind));
    if (type != null) query.where((t) => t.prayerType.equalsValue(type));
    return summarizeDebt(initial: initial, records: await query.get());
  }

  // --------------------------------------------------------- initial debt

  /// Sets the user's estimated initial debt. Writes an audit record so the
  /// change is visible in the history.
  Future<void> setInitialDebt(
    WorshipKind kind,
    int value, {
    PrayerType? prayerType,
  }) => _db.transaction(() => _setInitial(kind, prayerType, value));

  /// Saves several initial values at once (used by onboarding and the
  /// "edit initial debts" screen).
  Future<void> setInitialDebts({
    required Map<PrayerType, int> prayers,
    int? fasting,
  }) => _db.transaction(() async {
    for (final e in prayers.entries) {
      await _setInitial(WorshipKind.prayer, e.key, e.value);
    }
    if (fasting != null) {
      await _setInitial(WorshipKind.fast, null, fasting);
    }
  });

  Future<void> _setInitial(
    WorshipKind kind,
    PrayerType? type,
    int value,
  ) async {
    _checkKind(kind, type);
    if (value < 0) {
      throw const DebtValidationException(
        'Miqdor manfiy bo‘lishi mumkin emas.',
      );
    }
    final summary = await _summary(kind, type);
    if (summary.initial == value) return;
    final minimum = summary.completed - summary.added;
    if (value < minimum) {
      throw DebtValidationException(
        'Boshlang‘ich qarz kamida ${formatCount(minimum)} bo‘lishi kerak, '
        'chunki shuncha ado allaqachon qayd etilgan.',
      );
    }
    final now = _now();
    if (kind == WorshipKind.prayer) {
      await (_db.update(
        _db.prayerDebts,
      )..where((t) => t.prayerType.equalsValue(type))).write(
        PrayerDebtsCompanion(
          initialQuantity: Value(value),
          updatedAt: Value(now),
        ),
      );
    } else {
      await (_db.update(_db.fastingDebts)..where((t) => t.id.equals(1))).write(
        FastingDebtsCompanion(
          initialQuantity: Value(value),
          updatedAt: Value(now),
        ),
      );
    }
    await _db
        .into(_db.worshipRecords)
        .insert(
          WorshipRecordsCompanion.insert(
            entryKey: newEntryKey(),
            type: kind,
            prayerType: Value(type),
            action: RecordAction.initialSet,
            quantity: value,
            completedDate: dateOnly(now),
            createdAt: now,
            note: Value('Avvalgi qiymat: ${formatCount(summary.initial)}'),
          ),
        );
  }

  // ------------------------------------------------------------ add debt

  Future<WorshipRecord> addPrayerDebt(
    PrayerType type,
    int quantity, {
    DateTime? date,
    String? note,
    String? entryKey,
  }) => _addDebt(WorshipKind.prayer, type, quantity, date, note, entryKey);

  Future<WorshipRecord> addFastingDebt(
    int quantity, {
    DateTime? date,
    String? note,
    String? entryKey,
  }) => _addDebt(WorshipKind.fast, null, quantity, date, note, entryKey);

  Future<WorshipRecord> _addDebt(
    WorshipKind kind,
    PrayerType? type,
    int quantity,
    DateTime? date,
    String? note,
    String? entryKey,
  ) {
    _checkKind(kind, type);
    _checkQuantity(quantity);
    final key = entryKey ?? newEntryKey();
    return _db.transaction(() async {
      final existing = await _byKey(key);
      if (existing != null) return existing;
      final now = _now();
      final id = await _db
          .into(_db.worshipRecords)
          .insert(
            WorshipRecordsCompanion.insert(
              entryKey: key,
              type: kind,
              prayerType: Value(type),
              action: RecordAction.debtAdded,
              quantity: quantity,
              completedDate: dateOnly(date ?? now),
              createdAt: now,
              note: Value(_cleanNote(note)),
            ),
          );
      return _byId(id);
    });
  }

  // ------------------------------------------------------------ complete

  /// Records [quantity] made-up prayers of [type].
  ///
  /// Throws [ExceedsDebtException] when [quantity] is larger than what is
  /// owed, unless [allowExceed] is true. In that case the excess is first
  /// added to the debt (as a linked record) so the remaining debt never goes
  /// below zero.
  Future<CompletionResult> completePrayer(
    PrayerType type,
    int quantity, {
    DateTime? date,
    String? note,
    String? entryKey,
    bool allowExceed = false,
  }) => _complete(
    WorshipKind.prayer,
    type,
    quantity,
    date,
    note,
    entryKey,
    allowExceed,
  );

  /// Records made-up fasting days. One day reduces the debt by exactly one.
  Future<CompletionResult> completeFast({
    int days = 1,
    DateTime? date,
    String? note,
    String? entryKey,
    bool allowExceed = false,
  }) => _complete(
    WorshipKind.fast,
    null,
    days,
    date,
    note,
    entryKey,
    allowExceed,
  );

  Future<CompletionResult> _complete(
    WorshipKind kind,
    PrayerType? type,
    int quantity,
    DateTime? date,
    String? note,
    String? entryKey,
    bool allowExceed,
  ) {
    _checkKind(kind, type);
    _checkQuantity(quantity);
    final key = entryKey ?? newEntryKey();
    return _db.transaction(() async {
      final existing = await _byKey(key);
      if (existing != null) {
        return CompletionResult(record: existing, duplicate: true);
      }
      final summary = await _summary(kind, type);
      final excess = quantity - summary.remaining;
      if (excess > 0 && !allowExceed) {
        throw ExceedsDebtException(
          remaining: summary.remaining,
          requested: quantity,
        );
      }
      final now = _now();
      final day = dateOnly(date ?? now);
      if (excess > 0) {
        await _db
            .into(_db.worshipRecords)
            .insert(
              WorshipRecordsCompanion.insert(
                entryKey: '$key$_excessSuffix',
                type: kind,
                prayerType: Value(type),
                action: RecordAction.debtAdded,
                quantity: excess,
                completedDate: day,
                createdAt: now,
                note: const Value(
                  'Qarzdan ortiq ado tasdiqlangani uchun qo‘shildi',
                ),
              ),
            );
      }
      final id = await _db
          .into(_db.worshipRecords)
          .insert(
            WorshipRecordsCompanion.insert(
              entryKey: key,
              type: kind,
              prayerType: Value(type),
              action: RecordAction.completed,
              quantity: quantity,
              completedDate: day,
              createdAt: now,
              note: Value(_cleanNote(note)),
            ),
          );
      return CompletionResult(
        record: await _byId(id),
        addedForExcess: excess > 0 ? excess : 0,
      );
    });
  }

  // ------------------------------------------------------ undo / correct

  /// Marks a record as reversed (undo). The record stays in the history.
  Future<void> reverseRecord(int id) => _db.transaction(() async {
    final r = await _byId(id);
    if (r.reversedAt != null) return;
    if (r.action == RecordAction.initialSet) {
      throw const DebtValidationException(
        'Boshlang‘ich qiymat yozuvini bekor qilib bo‘lmaydi. '
        'Uni “Boshlang‘ich qarzni tahrirlash” orqali o‘zgartiring.',
      );
    }
    final now = _now();
    if (r.action == RecordAction.debtAdded) {
      final s = await _summary(r.type, r.prayerType);
      if (s.balance - r.quantity < 0) {
        throw const DebtValidationException(
          'Bu qarzni bekor qilsangiz, qolgan qarz manfiy bo‘lib qoladi. '
          'Avval tegishli ado yozuvlarini bekor qiling.',
        );
      }
    }
    await _setReversed(r.id, now);
    if (r.action == RecordAction.completed) {
      final linked = await _byKey('${r.entryKey}$_excessSuffix');
      if (linked != null && linked.reversedAt == null) {
        await _setReversed(linked.id, now);
      }
    }
  });

  /// Restores a previously reversed record.
  Future<void> restoreRecord(int id) => _db.transaction(() async {
    final r = await _byId(id);
    if (r.reversedAt == null) return;
    if (r.action == RecordAction.completed) {
      final linked = await _byKey('${r.entryKey}$_excessSuffix');
      final linkedQty = linked != null && linked.reversedAt != null
          ? linked.quantity
          : 0;
      final s = await _summary(r.type, r.prayerType);
      if (s.remaining + linkedQty < r.quantity) {
        throw const DebtValidationException(
          'Bu yozuvni tiklab bo‘lmaydi: ado miqdori qolgan qarzdan oshib '
          'ketadi.',
        );
      }
      if (linkedQty > 0) await _setReversed(linked!.id, null);
    }
    await _setReversed(r.id, null);
  });

  /// Corrects the date, quantity or note of a record.
  Future<void> editRecord(
    int id, {
    DateTime? date,
    int? quantity,
    String? note,
  }) => _db.transaction(() async {
    final r = await _byId(id);
    if (r.action == RecordAction.initialSet) {
      throw const DebtValidationException(
        'Boshlang‘ich qiymat yozuvini tahrirlab bo‘lmaydi.',
      );
    }
    if (quantity != null) {
      _checkQuantity(quantity);
      if (r.reversedAt == null && quantity != r.quantity) {
        final s = await _summary(r.type, r.prayerType);
        final delta = quantity - r.quantity;
        final newBalance = r.action == RecordAction.completed
            ? s.balance - delta
            : s.balance + delta;
        if (newBalance < 0) {
          throw const DebtValidationException(
            'Bu o‘zgarish qolgan qarzni manfiy qilib qo‘yadi.',
          );
        }
      }
    }
    await (_db.update(_db.worshipRecords)..where((t) => t.id.equals(id))).write(
      WorshipRecordsCompanion(
        completedDate: date == null
            ? const Value.absent()
            : Value(dateOnly(date)),
        quantity: quantity == null ? const Value.absent() : Value(quantity),
        note: note == null ? const Value.absent() : Value(_cleanNote(note)),
        editedAt: Value(_now()),
      ),
    );
  });

  // ------------------------------------------------------------ helpers

  Future<void> _setReversed(int id, DateTime? at) =>
      (_db.update(_db.worshipRecords)..where((t) => t.id.equals(id))).write(
        WorshipRecordsCompanion(reversedAt: Value(at)),
      );

  Future<WorshipRecord?> _byKey(String key) => (_db.select(
    _db.worshipRecords,
  )..where((t) => t.entryKey.equals(key))).getSingleOrNull();

  Future<WorshipRecord> _byId(int id) async {
    final r = await (_db.select(
      _db.worshipRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) {
      throw const DebtValidationException('Yozuv topilmadi.');
    }
    return r;
  }

  static void _checkQuantity(int quantity) {
    if (quantity <= 0) {
      throw const DebtValidationException('Miqdor kamida 1 bo‘lishi kerak.');
    }
    if (quantity > 100000) {
      throw const DebtValidationException('Miqdor juda katta.');
    }
  }

  static void _checkKind(WorshipKind kind, PrayerType? type) {
    if (kind == WorshipKind.prayer && type == null) {
      throw ArgumentError('Namoz turi ko‘rsatilmagan.');
    }
    if (kind == WorshipKind.fast && type != null) {
      throw ArgumentError('Ro‘za yozuvida namoz turi bo‘lmaydi.');
    }
  }

  static String? _cleanNote(String? note) {
    final t = note?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
