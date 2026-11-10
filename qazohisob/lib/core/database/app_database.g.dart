// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PrayerDebtsTable extends PrayerDebts
    with TableInfo<$PrayerDebtsTable, PrayerDebt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerDebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrayerType, String> prayerType =
      GeneratedColumn<String>(
        'prayer_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      ).withConverter<PrayerType>($PrayerDebtsTable.$converterprayerType);
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prayerType,
    initialQuantity,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerDebt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerDebt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerDebt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prayerType: $PrayerDebtsTable.$converterprayerType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer_type'],
        )!,
      ),
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrayerDebtsTable createAlias(String alias) {
    return $PrayerDebtsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrayerType, String, String> $converterprayerType =
      const EnumNameConverter<PrayerType>(PrayerType.values);
}

class PrayerDebt extends DataClass implements Insertable<PrayerDebt> {
  final int id;
  final PrayerType prayerType;
  final int initialQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PrayerDebt({
    required this.id,
    required this.prayerType,
    required this.initialQuantity,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['prayer_type'] = Variable<String>(
        $PrayerDebtsTable.$converterprayerType.toSql(prayerType),
      );
    }
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrayerDebtsCompanion toCompanion(bool nullToAbsent) {
    return PrayerDebtsCompanion(
      id: Value(id),
      prayerType: Value(prayerType),
      initialQuantity: Value(initialQuantity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrayerDebt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerDebt(
      id: serializer.fromJson<int>(json['id']),
      prayerType: $PrayerDebtsTable.$converterprayerType.fromJson(
        serializer.fromJson<String>(json['prayerType']),
      ),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prayerType': serializer.toJson<String>(
        $PrayerDebtsTable.$converterprayerType.toJson(prayerType),
      ),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrayerDebt copyWith({
    int? id,
    PrayerType? prayerType,
    int? initialQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PrayerDebt(
    id: id ?? this.id,
    prayerType: prayerType ?? this.prayerType,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrayerDebt copyWithCompanion(PrayerDebtsCompanion data) {
    return PrayerDebt(
      id: data.id.present ? data.id.value : this.id,
      prayerType: data.prayerType.present
          ? data.prayerType.value
          : this.prayerType,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerDebt(')
          ..write('id: $id, ')
          ..write('prayerType: $prayerType, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, prayerType, initialQuantity, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerDebt &&
          other.id == this.id &&
          other.prayerType == this.prayerType &&
          other.initialQuantity == this.initialQuantity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PrayerDebtsCompanion extends UpdateCompanion<PrayerDebt> {
  final Value<int> id;
  final Value<PrayerType> prayerType;
  final Value<int> initialQuantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PrayerDebtsCompanion({
    this.id = const Value.absent(),
    this.prayerType = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PrayerDebtsCompanion.insert({
    this.id = const Value.absent(),
    required PrayerType prayerType,
    this.initialQuantity = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : prayerType = Value(prayerType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PrayerDebt> custom({
    Expression<int>? id,
    Expression<String>? prayerType,
    Expression<int>? initialQuantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prayerType != null) 'prayer_type': prayerType,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PrayerDebtsCompanion copyWith({
    Value<int>? id,
    Value<PrayerType>? prayerType,
    Value<int>? initialQuantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PrayerDebtsCompanion(
      id: id ?? this.id,
      prayerType: prayerType ?? this.prayerType,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prayerType.present) {
      map['prayer_type'] = Variable<String>(
        $PrayerDebtsTable.$converterprayerType.toSql(prayerType.value),
      );
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerDebtsCompanion(')
          ..write('id: $id, ')
          ..write('prayerType: $prayerType, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FastingDebtsTable extends FastingDebts
    with TableInfo<$FastingDebtsTable, FastingDebt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FastingDebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    initialQuantity,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fasting_debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FastingDebt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FastingDebt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FastingDebt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FastingDebtsTable createAlias(String alias) {
    return $FastingDebtsTable(attachedDatabase, alias);
  }
}

class FastingDebt extends DataClass implements Insertable<FastingDebt> {
  final int id;
  final int initialQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FastingDebt({
    required this.id,
    required this.initialQuantity,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FastingDebtsCompanion toCompanion(bool nullToAbsent) {
    return FastingDebtsCompanion(
      id: Value(id),
      initialQuantity: Value(initialQuantity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FastingDebt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FastingDebt(
      id: serializer.fromJson<int>(json['id']),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FastingDebt copyWith({
    int? id,
    int? initialQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FastingDebt(
    id: id ?? this.id,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FastingDebt copyWithCompanion(FastingDebtsCompanion data) {
    return FastingDebt(
      id: data.id.present ? data.id.value : this.id,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FastingDebt(')
          ..write('id: $id, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, initialQuantity, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FastingDebt &&
          other.id == this.id &&
          other.initialQuantity == this.initialQuantity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FastingDebtsCompanion extends UpdateCompanion<FastingDebt> {
  final Value<int> id;
  final Value<int> initialQuantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FastingDebtsCompanion({
    this.id = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FastingDebtsCompanion.insert({
    this.id = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FastingDebt> custom({
    Expression<int>? id,
    Expression<int>? initialQuantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FastingDebtsCompanion copyWith({
    Value<int>? id,
    Value<int>? initialQuantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FastingDebtsCompanion(
      id: id ?? this.id,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FastingDebtsCompanion(')
          ..write('id: $id, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorshipRecordsTable extends WorshipRecords
    with TableInfo<$WorshipRecordsTable, WorshipRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorshipRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorshipKind, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorshipKind>($WorshipRecordsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<PrayerType?, String> prayerType =
      GeneratedColumn<String>(
        'prayer_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PrayerType?>($WorshipRecordsTable.$converterprayerTypen);
  @override
  late final GeneratedColumnWithTypeConverter<RecordAction, String> action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordAction>($WorshipRecordsTable.$converteraction);
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversedAtMeta = const VerificationMeta(
    'reversedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reversedAt = GeneratedColumn<DateTime>(
    'reversed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryKey,
    type,
    prayerType,
    action,
    quantity,
    completedDate,
    createdAt,
    editedAt,
    reversedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worship_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorshipRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('reversed_at')) {
      context.handle(
        _reversedAtMeta,
        reversedAt.isAcceptableOrUnknown(data['reversed_at']!, _reversedAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorshipRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorshipRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      type: $WorshipRecordsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      prayerType: $WorshipRecordsTable.$converterprayerTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer_type'],
        ),
      ),
      action: $WorshipRecordsTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      reversedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reversed_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorshipRecordsTable createAlias(String alias) {
    return $WorshipRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorshipKind, String, String> $convertertype =
      const EnumNameConverter<WorshipKind>(WorshipKind.values);
  static JsonTypeConverter2<PrayerType, String, String> $converterprayerType =
      const EnumNameConverter<PrayerType>(PrayerType.values);
  static JsonTypeConverter2<PrayerType?, String?, String?>
  $converterprayerTypen = JsonTypeConverter2.asNullable($converterprayerType);
  static JsonTypeConverter2<RecordAction, String, String> $converteraction =
      const EnumNameConverter<RecordAction>(RecordAction.values);
}

class WorshipRecord extends DataClass implements Insertable<WorshipRecord> {
  final int id;

  /// Client-generated idempotency key; prevents duplicate records when an
  /// action is submitted twice (e.g. a double tap).
  final String entryKey;
  final WorshipKind type;
  final PrayerType? prayerType;
  final RecordAction action;
  final int quantity;

  /// Calendar day the act happened (or the debt was recorded), stored at
  /// local midnight.
  final DateTime completedDate;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? reversedAt;
  final String? note;
  const WorshipRecord({
    required this.id,
    required this.entryKey,
    required this.type,
    this.prayerType,
    required this.action,
    required this.quantity,
    required this.completedDate,
    required this.createdAt,
    this.editedAt,
    this.reversedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_key'] = Variable<String>(entryKey);
    {
      map['type'] = Variable<String>(
        $WorshipRecordsTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || prayerType != null) {
      map['prayer_type'] = Variable<String>(
        $WorshipRecordsTable.$converterprayerTypen.toSql(prayerType),
      );
    }
    {
      map['action'] = Variable<String>(
        $WorshipRecordsTable.$converteraction.toSql(action),
      );
    }
    map['quantity'] = Variable<int>(quantity);
    map['completed_date'] = Variable<DateTime>(completedDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    if (!nullToAbsent || reversedAt != null) {
      map['reversed_at'] = Variable<DateTime>(reversedAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorshipRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorshipRecordsCompanion(
      id: Value(id),
      entryKey: Value(entryKey),
      type: Value(type),
      prayerType: prayerType == null && nullToAbsent
          ? const Value.absent()
          : Value(prayerType),
      action: Value(action),
      quantity: Value(quantity),
      completedDate: Value(completedDate),
      createdAt: Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      reversedAt: reversedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reversedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WorshipRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorshipRecord(
      id: serializer.fromJson<int>(json['id']),
      entryKey: serializer.fromJson<String>(json['entryKey']),
      type: $WorshipRecordsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      prayerType: $WorshipRecordsTable.$converterprayerTypen.fromJson(
        serializer.fromJson<String?>(json['prayerType']),
      ),
      action: $WorshipRecordsTable.$converteraction.fromJson(
        serializer.fromJson<String>(json['action']),
      ),
      quantity: serializer.fromJson<int>(json['quantity']),
      completedDate: serializer.fromJson<DateTime>(json['completedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      reversedAt: serializer.fromJson<DateTime?>(json['reversedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryKey': serializer.toJson<String>(entryKey),
      'type': serializer.toJson<String>(
        $WorshipRecordsTable.$convertertype.toJson(type),
      ),
      'prayerType': serializer.toJson<String?>(
        $WorshipRecordsTable.$converterprayerTypen.toJson(prayerType),
      ),
      'action': serializer.toJson<String>(
        $WorshipRecordsTable.$converteraction.toJson(action),
      ),
      'quantity': serializer.toJson<int>(quantity),
      'completedDate': serializer.toJson<DateTime>(completedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'reversedAt': serializer.toJson<DateTime?>(reversedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  WorshipRecord copyWith({
    int? id,
    String? entryKey,
    WorshipKind? type,
    Value<PrayerType?> prayerType = const Value.absent(),
    RecordAction? action,
    int? quantity,
    DateTime? completedDate,
    DateTime? createdAt,
    Value<DateTime?> editedAt = const Value.absent(),
    Value<DateTime?> reversedAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => WorshipRecord(
    id: id ?? this.id,
    entryKey: entryKey ?? this.entryKey,
    type: type ?? this.type,
    prayerType: prayerType.present ? prayerType.value : this.prayerType,
    action: action ?? this.action,
    quantity: quantity ?? this.quantity,
    completedDate: completedDate ?? this.completedDate,
    createdAt: createdAt ?? this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    reversedAt: reversedAt.present ? reversedAt.value : this.reversedAt,
    note: note.present ? note.value : this.note,
  );
  WorshipRecord copyWithCompanion(WorshipRecordsCompanion data) {
    return WorshipRecord(
      id: data.id.present ? data.id.value : this.id,
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      type: data.type.present ? data.type.value : this.type,
      prayerType: data.prayerType.present
          ? data.prayerType.value
          : this.prayerType,
      action: data.action.present ? data.action.value : this.action,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      reversedAt: data.reversedAt.present
          ? data.reversedAt.value
          : this.reversedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorshipRecord(')
          ..write('id: $id, ')
          ..write('entryKey: $entryKey, ')
          ..write('type: $type, ')
          ..write('prayerType: $prayerType, ')
          ..write('action: $action, ')
          ..write('quantity: $quantity, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryKey,
    type,
    prayerType,
    action,
    quantity,
    completedDate,
    createdAt,
    editedAt,
    reversedAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorshipRecord &&
          other.id == this.id &&
          other.entryKey == this.entryKey &&
          other.type == this.type &&
          other.prayerType == this.prayerType &&
          other.action == this.action &&
          other.quantity == this.quantity &&
          other.completedDate == this.completedDate &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt &&
          other.reversedAt == this.reversedAt &&
          other.note == this.note);
}

class WorshipRecordsCompanion extends UpdateCompanion<WorshipRecord> {
  final Value<int> id;
  final Value<String> entryKey;
  final Value<WorshipKind> type;
  final Value<PrayerType?> prayerType;
  final Value<RecordAction> action;
  final Value<int> quantity;
  final Value<DateTime> completedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> editedAt;
  final Value<DateTime?> reversedAt;
  final Value<String?> note;
  const WorshipRecordsCompanion({
    this.id = const Value.absent(),
    this.entryKey = const Value.absent(),
    this.type = const Value.absent(),
    this.prayerType = const Value.absent(),
    this.action = const Value.absent(),
    this.quantity = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.reversedAt = const Value.absent(),
    this.note = const Value.absent(),
  });
  WorshipRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String entryKey,
    required WorshipKind type,
    this.prayerType = const Value.absent(),
    required RecordAction action,
    required int quantity,
    required DateTime completedDate,
    required DateTime createdAt,
    this.editedAt = const Value.absent(),
    this.reversedAt = const Value.absent(),
    this.note = const Value.absent(),
  }) : entryKey = Value(entryKey),
       type = Value(type),
       action = Value(action),
       quantity = Value(quantity),
       completedDate = Value(completedDate),
       createdAt = Value(createdAt);
  static Insertable<WorshipRecord> custom({
    Expression<int>? id,
    Expression<String>? entryKey,
    Expression<String>? type,
    Expression<String>? prayerType,
    Expression<String>? action,
    Expression<int>? quantity,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editedAt,
    Expression<DateTime>? reversedAt,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryKey != null) 'entry_key': entryKey,
      if (type != null) 'type': type,
      if (prayerType != null) 'prayer_type': prayerType,
      if (action != null) 'action': action,
      if (quantity != null) 'quantity': quantity,
      if (completedDate != null) 'completed_date': completedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (reversedAt != null) 'reversed_at': reversedAt,
      if (note != null) 'note': note,
    });
  }

  WorshipRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? entryKey,
    Value<WorshipKind>? type,
    Value<PrayerType?>? prayerType,
    Value<RecordAction>? action,
    Value<int>? quantity,
    Value<DateTime>? completedDate,
    Value<DateTime>? createdAt,
    Value<DateTime?>? editedAt,
    Value<DateTime?>? reversedAt,
    Value<String?>? note,
  }) {
    return WorshipRecordsCompanion(
      id: id ?? this.id,
      entryKey: entryKey ?? this.entryKey,
      type: type ?? this.type,
      prayerType: prayerType ?? this.prayerType,
      action: action ?? this.action,
      quantity: quantity ?? this.quantity,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      reversedAt: reversedAt ?? this.reversedAt,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $WorshipRecordsTable.$convertertype.toSql(type.value),
      );
    }
    if (prayerType.present) {
      map['prayer_type'] = Variable<String>(
        $WorshipRecordsTable.$converterprayerTypen.toSql(prayerType.value),
      );
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $WorshipRecordsTable.$converteraction.toSql(action.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (reversedAt.present) {
      map['reversed_at'] = Variable<DateTime>(reversedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorshipRecordsCompanion(')
          ..write('id: $id, ')
          ..write('entryKey: $entryKey, ')
          ..write('type: $type, ')
          ..write('prayerType: $prayerType, ')
          ..write('action: $action, ')
          ..write('quantity: $quantity, ')
          ..write('completedDate: $completedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppThemeMode, String> theme =
      GeneratedColumn<String>(
        'theme',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AppThemeMode.system.name),
      ).withConverter<AppThemeMode>($SettingsTable.$convertertheme);
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _prayerReminderEnabledMeta =
      const VerificationMeta('prayerReminderEnabled');
  @override
  late final GeneratedColumn<bool> prayerReminderEnabled =
      GeneratedColumn<bool>(
        'prayer_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prayer_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _prayerReminderTimeMeta =
      const VerificationMeta('prayerReminderTime');
  @override
  late final GeneratedColumn<int> prayerReminderTime = GeneratedColumn<int>(
    'prayer_reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20 * 60),
  );
  static const VerificationMeta _fastingReminderEnabledMeta =
      const VerificationMeta('fastingReminderEnabled');
  @override
  late final GeneratedColumn<bool> fastingReminderEnabled =
      GeneratedColumn<bool>(
        'fasting_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("fasting_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _fastingReminderTimeMeta =
      const VerificationMeta('fastingReminderTime');
  @override
  late final GeneratedColumn<int> fastingReminderTime = GeneratedColumn<int>(
    'fasting_reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(21 * 60 + 30),
  );
  static const VerificationMeta _vitrEnabledMeta = const VerificationMeta(
    'vitrEnabled',
  );
  @override
  late final GeneratedColumn<bool> vitrEnabled = GeneratedColumn<bool>(
    'vitr_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vitr_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyPrayerGoalMeta = const VerificationMeta(
    'dailyPrayerGoal',
  );
  @override
  late final GeneratedColumn<int> dailyPrayerGoal = GeneratedColumn<int>(
    'daily_prayer_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearDaysMeta = const VerificationMeta(
    'yearDays',
  );
  @override
  late final GeneratedColumn<int> yearDays = GeneratedColumn<int>(
    'year_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(365),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    theme,
    notificationsEnabled,
    prayerReminderEnabled,
    prayerReminderTime,
    fastingReminderEnabled,
    fastingReminderTime,
    vitrEnabled,
    dailyPrayerGoal,
    onboardingCompleted,
    firstName,
    lastName,
    yearDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('prayer_reminder_enabled')) {
      context.handle(
        _prayerReminderEnabledMeta,
        prayerReminderEnabled.isAcceptableOrUnknown(
          data['prayer_reminder_enabled']!,
          _prayerReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('prayer_reminder_time')) {
      context.handle(
        _prayerReminderTimeMeta,
        prayerReminderTime.isAcceptableOrUnknown(
          data['prayer_reminder_time']!,
          _prayerReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('fasting_reminder_enabled')) {
      context.handle(
        _fastingReminderEnabledMeta,
        fastingReminderEnabled.isAcceptableOrUnknown(
          data['fasting_reminder_enabled']!,
          _fastingReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('fasting_reminder_time')) {
      context.handle(
        _fastingReminderTimeMeta,
        fastingReminderTime.isAcceptableOrUnknown(
          data['fasting_reminder_time']!,
          _fastingReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('vitr_enabled')) {
      context.handle(
        _vitrEnabledMeta,
        vitrEnabled.isAcceptableOrUnknown(
          data['vitr_enabled']!,
          _vitrEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_prayer_goal')) {
      context.handle(
        _dailyPrayerGoalMeta,
        dailyPrayerGoal.isAcceptableOrUnknown(
          data['daily_prayer_goal']!,
          _dailyPrayerGoalMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('year_days')) {
      context.handle(
        _yearDaysMeta,
        yearDays.isAcceptableOrUnknown(data['year_days']!, _yearDaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      theme: $SettingsTable.$convertertheme.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme'],
        )!,
      ),
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      prayerReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prayer_reminder_enabled'],
      )!,
      prayerReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prayer_reminder_time'],
      )!,
      fastingReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fasting_reminder_enabled'],
      )!,
      fastingReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fasting_reminder_time'],
      )!,
      vitrEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vitr_enabled'],
      )!,
      dailyPrayerGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_prayer_goal'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      yearDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_days'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppThemeMode, String, String> $convertertheme =
      const EnumNameConverter<AppThemeMode>(AppThemeMode.values);
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final AppThemeMode theme;
  final bool notificationsEnabled;
  final bool prayerReminderEnabled;

  /// Minutes since midnight.
  final int prayerReminderTime;
  final bool fastingReminderEnabled;
  final int fastingReminderTime;
  final bool vitrEnabled;
  final int dailyPrayerGoal;
  final bool onboardingCompleted;

  /// User's first name (ism), entered on first launch.
  final String firstName;

  /// User's last name (familiya).
  final String lastName;

  /// Days per year when converting "years / months / days" into a number of
  /// missed prayers: 365 (Gregorian) or 354 (Hijri). Chosen by the user.
  final int yearDays;
  const Setting({
    required this.id,
    required this.theme,
    required this.notificationsEnabled,
    required this.prayerReminderEnabled,
    required this.prayerReminderTime,
    required this.fastingReminderEnabled,
    required this.fastingReminderTime,
    required this.vitrEnabled,
    required this.dailyPrayerGoal,
    required this.onboardingCompleted,
    required this.firstName,
    required this.lastName,
    required this.yearDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme'] = Variable<String>(
        $SettingsTable.$convertertheme.toSql(theme),
      );
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['prayer_reminder_enabled'] = Variable<bool>(prayerReminderEnabled);
    map['prayer_reminder_time'] = Variable<int>(prayerReminderTime);
    map['fasting_reminder_enabled'] = Variable<bool>(fastingReminderEnabled);
    map['fasting_reminder_time'] = Variable<int>(fastingReminderTime);
    map['vitr_enabled'] = Variable<bool>(vitrEnabled);
    map['daily_prayer_goal'] = Variable<int>(dailyPrayerGoal);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['year_days'] = Variable<int>(yearDays);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      theme: Value(theme),
      notificationsEnabled: Value(notificationsEnabled),
      prayerReminderEnabled: Value(prayerReminderEnabled),
      prayerReminderTime: Value(prayerReminderTime),
      fastingReminderEnabled: Value(fastingReminderEnabled),
      fastingReminderTime: Value(fastingReminderTime),
      vitrEnabled: Value(vitrEnabled),
      dailyPrayerGoal: Value(dailyPrayerGoal),
      onboardingCompleted: Value(onboardingCompleted),
      firstName: Value(firstName),
      lastName: Value(lastName),
      yearDays: Value(yearDays),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      theme: $SettingsTable.$convertertheme.fromJson(
        serializer.fromJson<String>(json['theme']),
      ),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      prayerReminderEnabled: serializer.fromJson<bool>(
        json['prayerReminderEnabled'],
      ),
      prayerReminderTime: serializer.fromJson<int>(json['prayerReminderTime']),
      fastingReminderEnabled: serializer.fromJson<bool>(
        json['fastingReminderEnabled'],
      ),
      fastingReminderTime: serializer.fromJson<int>(
        json['fastingReminderTime'],
      ),
      vitrEnabled: serializer.fromJson<bool>(json['vitrEnabled']),
      dailyPrayerGoal: serializer.fromJson<int>(json['dailyPrayerGoal']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      yearDays: serializer.fromJson<int>(json['yearDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'theme': serializer.toJson<String>(
        $SettingsTable.$convertertheme.toJson(theme),
      ),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'prayerReminderEnabled': serializer.toJson<bool>(prayerReminderEnabled),
      'prayerReminderTime': serializer.toJson<int>(prayerReminderTime),
      'fastingReminderEnabled': serializer.toJson<bool>(fastingReminderEnabled),
      'fastingReminderTime': serializer.toJson<int>(fastingReminderTime),
      'vitrEnabled': serializer.toJson<bool>(vitrEnabled),
      'dailyPrayerGoal': serializer.toJson<int>(dailyPrayerGoal),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'yearDays': serializer.toJson<int>(yearDays),
    };
  }

  Setting copyWith({
    int? id,
    AppThemeMode? theme,
    bool? notificationsEnabled,
    bool? prayerReminderEnabled,
    int? prayerReminderTime,
    bool? fastingReminderEnabled,
    int? fastingReminderTime,
    bool? vitrEnabled,
    int? dailyPrayerGoal,
    bool? onboardingCompleted,
    String? firstName,
    String? lastName,
    int? yearDays,
  }) => Setting(
    id: id ?? this.id,
    theme: theme ?? this.theme,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    prayerReminderEnabled: prayerReminderEnabled ?? this.prayerReminderEnabled,
    prayerReminderTime: prayerReminderTime ?? this.prayerReminderTime,
    fastingReminderEnabled:
        fastingReminderEnabled ?? this.fastingReminderEnabled,
    fastingReminderTime: fastingReminderTime ?? this.fastingReminderTime,
    vitrEnabled: vitrEnabled ?? this.vitrEnabled,
    dailyPrayerGoal: dailyPrayerGoal ?? this.dailyPrayerGoal,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    yearDays: yearDays ?? this.yearDays,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      theme: data.theme.present ? data.theme.value : this.theme,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      prayerReminderEnabled: data.prayerReminderEnabled.present
          ? data.prayerReminderEnabled.value
          : this.prayerReminderEnabled,
      prayerReminderTime: data.prayerReminderTime.present
          ? data.prayerReminderTime.value
          : this.prayerReminderTime,
      fastingReminderEnabled: data.fastingReminderEnabled.present
          ? data.fastingReminderEnabled.value
          : this.fastingReminderEnabled,
      fastingReminderTime: data.fastingReminderTime.present
          ? data.fastingReminderTime.value
          : this.fastingReminderTime,
      vitrEnabled: data.vitrEnabled.present
          ? data.vitrEnabled.value
          : this.vitrEnabled,
      dailyPrayerGoal: data.dailyPrayerGoal.present
          ? data.dailyPrayerGoal.value
          : this.dailyPrayerGoal,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      yearDays: data.yearDays.present ? data.yearDays.value : this.yearDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('prayerReminderEnabled: $prayerReminderEnabled, ')
          ..write('prayerReminderTime: $prayerReminderTime, ')
          ..write('fastingReminderEnabled: $fastingReminderEnabled, ')
          ..write('fastingReminderTime: $fastingReminderTime, ')
          ..write('vitrEnabled: $vitrEnabled, ')
          ..write('dailyPrayerGoal: $dailyPrayerGoal, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('yearDays: $yearDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    theme,
    notificationsEnabled,
    prayerReminderEnabled,
    prayerReminderTime,
    fastingReminderEnabled,
    fastingReminderTime,
    vitrEnabled,
    dailyPrayerGoal,
    onboardingCompleted,
    firstName,
    lastName,
    yearDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.theme == this.theme &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.prayerReminderEnabled == this.prayerReminderEnabled &&
          other.prayerReminderTime == this.prayerReminderTime &&
          other.fastingReminderEnabled == this.fastingReminderEnabled &&
          other.fastingReminderTime == this.fastingReminderTime &&
          other.vitrEnabled == this.vitrEnabled &&
          other.dailyPrayerGoal == this.dailyPrayerGoal &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.yearDays == this.yearDays);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<AppThemeMode> theme;
  final Value<bool> notificationsEnabled;
  final Value<bool> prayerReminderEnabled;
  final Value<int> prayerReminderTime;
  final Value<bool> fastingReminderEnabled;
  final Value<int> fastingReminderTime;
  final Value<bool> vitrEnabled;
  final Value<int> dailyPrayerGoal;
  final Value<bool> onboardingCompleted;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int> yearDays;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.prayerReminderEnabled = const Value.absent(),
    this.prayerReminderTime = const Value.absent(),
    this.fastingReminderEnabled = const Value.absent(),
    this.fastingReminderTime = const Value.absent(),
    this.vitrEnabled = const Value.absent(),
    this.dailyPrayerGoal = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.yearDays = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.prayerReminderEnabled = const Value.absent(),
    this.prayerReminderTime = const Value.absent(),
    this.fastingReminderEnabled = const Value.absent(),
    this.fastingReminderTime = const Value.absent(),
    this.vitrEnabled = const Value.absent(),
    this.dailyPrayerGoal = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.yearDays = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? theme,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? prayerReminderEnabled,
    Expression<int>? prayerReminderTime,
    Expression<bool>? fastingReminderEnabled,
    Expression<int>? fastingReminderTime,
    Expression<bool>? vitrEnabled,
    Expression<int>? dailyPrayerGoal,
    Expression<bool>? onboardingCompleted,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? yearDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (theme != null) 'theme': theme,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (prayerReminderEnabled != null)
        'prayer_reminder_enabled': prayerReminderEnabled,
      if (prayerReminderTime != null)
        'prayer_reminder_time': prayerReminderTime,
      if (fastingReminderEnabled != null)
        'fasting_reminder_enabled': fastingReminderEnabled,
      if (fastingReminderTime != null)
        'fasting_reminder_time': fastingReminderTime,
      if (vitrEnabled != null) 'vitr_enabled': vitrEnabled,
      if (dailyPrayerGoal != null) 'daily_prayer_goal': dailyPrayerGoal,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (yearDays != null) 'year_days': yearDays,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<AppThemeMode>? theme,
    Value<bool>? notificationsEnabled,
    Value<bool>? prayerReminderEnabled,
    Value<int>? prayerReminderTime,
    Value<bool>? fastingReminderEnabled,
    Value<int>? fastingReminderTime,
    Value<bool>? vitrEnabled,
    Value<int>? dailyPrayerGoal,
    Value<bool>? onboardingCompleted,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int>? yearDays,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerReminderEnabled:
          prayerReminderEnabled ?? this.prayerReminderEnabled,
      prayerReminderTime: prayerReminderTime ?? this.prayerReminderTime,
      fastingReminderEnabled:
          fastingReminderEnabled ?? this.fastingReminderEnabled,
      fastingReminderTime: fastingReminderTime ?? this.fastingReminderTime,
      vitrEnabled: vitrEnabled ?? this.vitrEnabled,
      dailyPrayerGoal: dailyPrayerGoal ?? this.dailyPrayerGoal,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      yearDays: yearDays ?? this.yearDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
        $SettingsTable.$convertertheme.toSql(theme.value),
      );
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (prayerReminderEnabled.present) {
      map['prayer_reminder_enabled'] = Variable<bool>(
        prayerReminderEnabled.value,
      );
    }
    if (prayerReminderTime.present) {
      map['prayer_reminder_time'] = Variable<int>(prayerReminderTime.value);
    }
    if (fastingReminderEnabled.present) {
      map['fasting_reminder_enabled'] = Variable<bool>(
        fastingReminderEnabled.value,
      );
    }
    if (fastingReminderTime.present) {
      map['fasting_reminder_time'] = Variable<int>(fastingReminderTime.value);
    }
    if (vitrEnabled.present) {
      map['vitr_enabled'] = Variable<bool>(vitrEnabled.value);
    }
    if (dailyPrayerGoal.present) {
      map['daily_prayer_goal'] = Variable<int>(dailyPrayerGoal.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (yearDays.present) {
      map['year_days'] = Variable<int>(yearDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('prayerReminderEnabled: $prayerReminderEnabled, ')
          ..write('prayerReminderTime: $prayerReminderTime, ')
          ..write('fastingReminderEnabled: $fastingReminderEnabled, ')
          ..write('fastingReminderTime: $fastingReminderTime, ')
          ..write('vitrEnabled: $vitrEnabled, ')
          ..write('dailyPrayerGoal: $dailyPrayerGoal, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('yearDays: $yearDays')
          ..write(')'))
        .toString();
  }
}

class $ZikrCountsTable extends ZikrCounts
    with TableInfo<$ZikrCountsTable, ZikrCount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZikrCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ZikrSession, String> session =
      GeneratedColumn<String>(
        'session',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ZikrSession>($ZikrCountsTable.$convertersession);
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<int> item = GeneratedColumn<int>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    session,
    item,
    count,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zikr_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZikrCount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, session, item},
  ];
  @override
  ZikrCount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZikrCount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      session: $ZikrCountsTable.$convertersession.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}session'],
        )!,
      ),
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ZikrCountsTable createAlias(String alias) {
    return $ZikrCountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ZikrSession, String, String> $convertersession =
      const EnumNameConverter<ZikrSession>(ZikrSession.values);
}

class ZikrCount extends DataClass implements Insertable<ZikrCount> {
  final int id;

  /// Local calendar day (midnight).
  final DateTime day;
  final ZikrSession session;

  /// Index of the tasbih in the wird (0-based).
  final int item;
  final int count;
  final DateTime updatedAt;
  const ZikrCount({
    required this.id,
    required this.day,
    required this.session,
    required this.item,
    required this.count,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<DateTime>(day);
    {
      map['session'] = Variable<String>(
        $ZikrCountsTable.$convertersession.toSql(session),
      );
    }
    map['item'] = Variable<int>(item);
    map['count'] = Variable<int>(count);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ZikrCountsCompanion toCompanion(bool nullToAbsent) {
    return ZikrCountsCompanion(
      id: Value(id),
      day: Value(day),
      session: Value(session),
      item: Value(item),
      count: Value(count),
      updatedAt: Value(updatedAt),
    );
  }

  factory ZikrCount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZikrCount(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      session: $ZikrCountsTable.$convertersession.fromJson(
        serializer.fromJson<String>(json['session']),
      ),
      item: serializer.fromJson<int>(json['item']),
      count: serializer.fromJson<int>(json['count']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<DateTime>(day),
      'session': serializer.toJson<String>(
        $ZikrCountsTable.$convertersession.toJson(session),
      ),
      'item': serializer.toJson<int>(item),
      'count': serializer.toJson<int>(count),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ZikrCount copyWith({
    int? id,
    DateTime? day,
    ZikrSession? session,
    int? item,
    int? count,
    DateTime? updatedAt,
  }) => ZikrCount(
    id: id ?? this.id,
    day: day ?? this.day,
    session: session ?? this.session,
    item: item ?? this.item,
    count: count ?? this.count,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ZikrCount copyWithCompanion(ZikrCountsCompanion data) {
    return ZikrCount(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      session: data.session.present ? data.session.value : this.session,
      item: data.item.present ? data.item.value : this.item,
      count: data.count.present ? data.count.value : this.count,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZikrCount(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('session: $session, ')
          ..write('item: $item, ')
          ..write('count: $count, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, session, item, count, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZikrCount &&
          other.id == this.id &&
          other.day == this.day &&
          other.session == this.session &&
          other.item == this.item &&
          other.count == this.count &&
          other.updatedAt == this.updatedAt);
}

class ZikrCountsCompanion extends UpdateCompanion<ZikrCount> {
  final Value<int> id;
  final Value<DateTime> day;
  final Value<ZikrSession> session;
  final Value<int> item;
  final Value<int> count;
  final Value<DateTime> updatedAt;
  const ZikrCountsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.session = const Value.absent(),
    this.item = const Value.absent(),
    this.count = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ZikrCountsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime day,
    required ZikrSession session,
    required int item,
    required int count,
    required DateTime updatedAt,
  }) : day = Value(day),
       session = Value(session),
       item = Value(item),
       count = Value(count),
       updatedAt = Value(updatedAt);
  static Insertable<ZikrCount> custom({
    Expression<int>? id,
    Expression<DateTime>? day,
    Expression<String>? session,
    Expression<int>? item,
    Expression<int>? count,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (session != null) 'session': session,
      if (item != null) 'item': item,
      if (count != null) 'count': count,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ZikrCountsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? day,
    Value<ZikrSession>? session,
    Value<int>? item,
    Value<int>? count,
    Value<DateTime>? updatedAt,
  }) {
    return ZikrCountsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      session: session ?? this.session,
      item: item ?? this.item,
      count: count ?? this.count,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(
        $ZikrCountsTable.$convertersession.toSql(session.value),
      );
    }
    if (item.present) {
      map['item'] = Variable<int>(item.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZikrCountsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('session: $session, ')
          ..write('item: $item, ')
          ..write('count: $count, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerDebtsTable prayerDebts = $PrayerDebtsTable(this);
  late final $FastingDebtsTable fastingDebts = $FastingDebtsTable(this);
  late final $WorshipRecordsTable worshipRecords = $WorshipRecordsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ZikrCountsTable zikrCounts = $ZikrCountsTable(this);
  late final Index worshipRecordsDate = Index(
    'worship_records_date',
    'CREATE INDEX worship_records_date ON worship_records (completed_date)',
  );
  late final Index worshipRecordsType = Index(
    'worship_records_type',
    'CREATE INDEX worship_records_type ON worship_records (type, prayer_type)',
  );
  late final Index zikrCountsDay = Index(
    'zikr_counts_day',
    'CREATE INDEX zikr_counts_day ON zikr_counts (day)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerDebts,
    fastingDebts,
    worshipRecords,
    settings,
    zikrCounts,
    worshipRecordsDate,
    worshipRecordsType,
    zikrCountsDay,
  ];
}

typedef $$PrayerDebtsTableCreateCompanionBuilder =
    PrayerDebtsCompanion Function({
      Value<int> id,
      required PrayerType prayerType,
      Value<int> initialQuantity,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PrayerDebtsTableUpdateCompanionBuilder =
    PrayerDebtsCompanion Function({
      Value<int> id,
      Value<PrayerType> prayerType,
      Value<int> initialQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$PrayerDebtsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerDebtsTable> {
  $$PrayerDebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrayerType, PrayerType, String>
  get prayerType => $composableBuilder(
    column: $table.prayerType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerDebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerDebtsTable> {
  $$PrayerDebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayerType => $composableBuilder(
    column: $table.prayerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerDebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerDebtsTable> {
  $$PrayerDebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrayerType, String> get prayerType =>
      $composableBuilder(
        column: $table.prayerType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PrayerDebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerDebtsTable,
          PrayerDebt,
          $$PrayerDebtsTableFilterComposer,
          $$PrayerDebtsTableOrderingComposer,
          $$PrayerDebtsTableAnnotationComposer,
          $$PrayerDebtsTableCreateCompanionBuilder,
          $$PrayerDebtsTableUpdateCompanionBuilder,
          (
            PrayerDebt,
            BaseReferences<_$AppDatabase, $PrayerDebtsTable, PrayerDebt>,
          ),
          PrayerDebt,
          PrefetchHooks Function()
        > {
  $$PrayerDebtsTableTableManager(_$AppDatabase db, $PrayerDebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerDebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerDebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerDebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<PrayerType> prayerType = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PrayerDebtsCompanion(
                id: id,
                prayerType: prayerType,
                initialQuantity: initialQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required PrayerType prayerType,
                Value<int> initialQuantity = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PrayerDebtsCompanion.insert(
                id: id,
                prayerType: prayerType,
                initialQuantity: initialQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerDebtsTable, PrayerDebt>(table),
                  BaseReferences<_$AppDatabase, $PrayerDebtsTable, PrayerDebt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerDebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerDebtsTable,
      PrayerDebt,
      $$PrayerDebtsTableFilterComposer,
      $$PrayerDebtsTableOrderingComposer,
      $$PrayerDebtsTableAnnotationComposer,
      $$PrayerDebtsTableCreateCompanionBuilder,
      $$PrayerDebtsTableUpdateCompanionBuilder,
      (
        PrayerDebt,
        BaseReferences<_$AppDatabase, $PrayerDebtsTable, PrayerDebt>,
      ),
      PrayerDebt,
      PrefetchHooks Function()
    >;
typedef $$FastingDebtsTableCreateCompanionBuilder =
    FastingDebtsCompanion Function({
      Value<int> id,
      Value<int> initialQuantity,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FastingDebtsTableUpdateCompanionBuilder =
    FastingDebtsCompanion Function({
      Value<int> id,
      Value<int> initialQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FastingDebtsTableFilterComposer
    extends Composer<_$AppDatabase, $FastingDebtsTable> {
  $$FastingDebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FastingDebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $FastingDebtsTable> {
  $$FastingDebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FastingDebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FastingDebtsTable> {
  $$FastingDebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FastingDebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FastingDebtsTable,
          FastingDebt,
          $$FastingDebtsTableFilterComposer,
          $$FastingDebtsTableOrderingComposer,
          $$FastingDebtsTableAnnotationComposer,
          $$FastingDebtsTableCreateCompanionBuilder,
          $$FastingDebtsTableUpdateCompanionBuilder,
          (
            FastingDebt,
            BaseReferences<_$AppDatabase, $FastingDebtsTable, FastingDebt>,
          ),
          FastingDebt,
          PrefetchHooks Function()
        > {
  $$FastingDebtsTableTableManager(_$AppDatabase db, $FastingDebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FastingDebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FastingDebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FastingDebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FastingDebtsCompanion(
                id: id,
                initialQuantity: initialQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FastingDebtsCompanion.insert(
                id: id,
                initialQuantity: initialQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FastingDebtsTable, FastingDebt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FastingDebtsTable,
                    FastingDebt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FastingDebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FastingDebtsTable,
      FastingDebt,
      $$FastingDebtsTableFilterComposer,
      $$FastingDebtsTableOrderingComposer,
      $$FastingDebtsTableAnnotationComposer,
      $$FastingDebtsTableCreateCompanionBuilder,
      $$FastingDebtsTableUpdateCompanionBuilder,
      (
        FastingDebt,
        BaseReferences<_$AppDatabase, $FastingDebtsTable, FastingDebt>,
      ),
      FastingDebt,
      PrefetchHooks Function()
    >;
typedef $$WorshipRecordsTableCreateCompanionBuilder =
    WorshipRecordsCompanion Function({
      Value<int> id,
      required String entryKey,
      required WorshipKind type,
      Value<PrayerType?> prayerType,
      required RecordAction action,
      required int quantity,
      required DateTime completedDate,
      required DateTime createdAt,
      Value<DateTime?> editedAt,
      Value<DateTime?> reversedAt,
      Value<String?> note,
    });
typedef $$WorshipRecordsTableUpdateCompanionBuilder =
    WorshipRecordsCompanion Function({
      Value<int> id,
      Value<String> entryKey,
      Value<WorshipKind> type,
      Value<PrayerType?> prayerType,
      Value<RecordAction> action,
      Value<int> quantity,
      Value<DateTime> completedDate,
      Value<DateTime> createdAt,
      Value<DateTime?> editedAt,
      Value<DateTime?> reversedAt,
      Value<String?> note,
    });

class $$WorshipRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorshipKind, WorshipKind, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PrayerType?, PrayerType, String>
  get prayerType => $composableBuilder(
    column: $table.prayerType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<RecordAction, RecordAction, String>
  get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorshipRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayerType => $composableBuilder(
    column: $table.prayerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorshipRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorshipKind, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrayerType?, String> get prayerType =>
      $composableBuilder(
        column: $table.prayerType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<RecordAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WorshipRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorshipRecordsTable,
          WorshipRecord,
          $$WorshipRecordsTableFilterComposer,
          $$WorshipRecordsTableOrderingComposer,
          $$WorshipRecordsTableAnnotationComposer,
          $$WorshipRecordsTableCreateCompanionBuilder,
          $$WorshipRecordsTableUpdateCompanionBuilder,
          (
            WorshipRecord,
            BaseReferences<_$AppDatabase, $WorshipRecordsTable, WorshipRecord>,
          ),
          WorshipRecord,
          PrefetchHooks Function()
        > {
  $$WorshipRecordsTableTableManager(
    _$AppDatabase db,
    $WorshipRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorshipRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorshipRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorshipRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entryKey = const Value.absent(),
                Value<WorshipKind> type = const Value.absent(),
                Value<PrayerType?> prayerType = const Value.absent(),
                Value<RecordAction> action = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime> completedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<DateTime?> reversedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorshipRecordsCompanion(
                id: id,
                entryKey: entryKey,
                type: type,
                prayerType: prayerType,
                action: action,
                quantity: quantity,
                completedDate: completedDate,
                createdAt: createdAt,
                editedAt: editedAt,
                reversedAt: reversedAt,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entryKey,
                required WorshipKind type,
                Value<PrayerType?> prayerType = const Value.absent(),
                required RecordAction action,
                required int quantity,
                required DateTime completedDate,
                required DateTime createdAt,
                Value<DateTime?> editedAt = const Value.absent(),
                Value<DateTime?> reversedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WorshipRecordsCompanion.insert(
                id: id,
                entryKey: entryKey,
                type: type,
                prayerType: prayerType,
                action: action,
                quantity: quantity,
                completedDate: completedDate,
                createdAt: createdAt,
                editedAt: editedAt,
                reversedAt: reversedAt,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorshipRecordsTable, WorshipRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorshipRecordsTable,
                    WorshipRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorshipRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorshipRecordsTable,
      WorshipRecord,
      $$WorshipRecordsTableFilterComposer,
      $$WorshipRecordsTableOrderingComposer,
      $$WorshipRecordsTableAnnotationComposer,
      $$WorshipRecordsTableCreateCompanionBuilder,
      $$WorshipRecordsTableUpdateCompanionBuilder,
      (
        WorshipRecord,
        BaseReferences<_$AppDatabase, $WorshipRecordsTable, WorshipRecord>,
      ),
      WorshipRecord,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<AppThemeMode> theme,
  Value<bool> notificationsEnabled,
  Value<bool> prayerReminderEnabled,
  Value<int> prayerReminderTime,
  Value<bool> fastingReminderEnabled,
  Value<int> fastingReminderTime,
  Value<bool> vitrEnabled,
  Value<int> dailyPrayerGoal,
  Value<bool> onboardingCompleted,
  Value<String> firstName,
  Value<String> lastName,
  Value<int> yearDays,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<AppThemeMode> theme,
  Value<bool> notificationsEnabled,
  Value<bool> prayerReminderEnabled,
  Value<int> prayerReminderTime,
  Value<bool> fastingReminderEnabled,
  Value<int> fastingReminderTime,
  Value<bool> vitrEnabled,
  Value<int> dailyPrayerGoal,
  Value<bool> onboardingCompleted,
  Value<String> firstName,
  Value<String> lastName,
  Value<int> yearDays,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppThemeMode, AppThemeMode, String>
  get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get prayerReminderEnabled => $composableBuilder(
    column: $table.prayerReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prayerReminderTime => $composableBuilder(
    column: $table.prayerReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fastingReminderEnabled => $composableBuilder(
    column: $table.fastingReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fastingReminderTime => $composableBuilder(
    column: $table.fastingReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vitrEnabled => $composableBuilder(
    column: $table.vitrEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyPrayerGoal => $composableBuilder(
    column: $table.dailyPrayerGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearDays => $composableBuilder(
    column: $table.yearDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get prayerReminderEnabled => $composableBuilder(
    column: $table.prayerReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prayerReminderTime => $composableBuilder(
    column: $table.prayerReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fastingReminderEnabled => $composableBuilder(
    column: $table.fastingReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fastingReminderTime => $composableBuilder(
    column: $table.fastingReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vitrEnabled => $composableBuilder(
    column: $table.vitrEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyPrayerGoal => $composableBuilder(
    column: $table.dailyPrayerGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearDays => $composableBuilder(
    column: $table.yearDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppThemeMode, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get prayerReminderEnabled => $composableBuilder(
    column: $table.prayerReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prayerReminderTime => $composableBuilder(
    column: $table.prayerReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fastingReminderEnabled => $composableBuilder(
    column: $table.fastingReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fastingReminderTime => $composableBuilder(
    column: $table.fastingReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vitrEnabled => $composableBuilder(
    column: $table.vitrEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyPrayerGoal => $composableBuilder(
    column: $table.dailyPrayerGoal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get yearDays =>
      $composableBuilder(column: $table.yearDays, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> theme = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> prayerReminderEnabled = const Value.absent(),
                Value<int> prayerReminderTime = const Value.absent(),
                Value<bool> fastingReminderEnabled = const Value.absent(),
                Value<int> fastingReminderTime = const Value.absent(),
                Value<bool> vitrEnabled = const Value.absent(),
                Value<int> dailyPrayerGoal = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int> yearDays = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                theme: theme,
                notificationsEnabled: notificationsEnabled,
                prayerReminderEnabled: prayerReminderEnabled,
                prayerReminderTime: prayerReminderTime,
                fastingReminderEnabled: fastingReminderEnabled,
                fastingReminderTime: fastingReminderTime,
                vitrEnabled: vitrEnabled,
                dailyPrayerGoal: dailyPrayerGoal,
                onboardingCompleted: onboardingCompleted,
                firstName: firstName,
                lastName: lastName,
                yearDays: yearDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> theme = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> prayerReminderEnabled = const Value.absent(),
                Value<int> prayerReminderTime = const Value.absent(),
                Value<bool> fastingReminderEnabled = const Value.absent(),
                Value<int> fastingReminderTime = const Value.absent(),
                Value<bool> vitrEnabled = const Value.absent(),
                Value<int> dailyPrayerGoal = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int> yearDays = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                theme: theme,
                notificationsEnabled: notificationsEnabled,
                prayerReminderEnabled: prayerReminderEnabled,
                prayerReminderTime: prayerReminderTime,
                fastingReminderEnabled: fastingReminderEnabled,
                fastingReminderTime: fastingReminderTime,
                vitrEnabled: vitrEnabled,
                dailyPrayerGoal: dailyPrayerGoal,
                onboardingCompleted: onboardingCompleted,
                firstName: firstName,
                lastName: lastName,
                yearDays: yearDays,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ZikrCountsTableCreateCompanionBuilder = ZikrCountsCompanion Function({
  Value<int> id,
  required DateTime day,
  required ZikrSession session,
  required int item,
  required int count,
  required DateTime updatedAt,
});
typedef $$ZikrCountsTableUpdateCompanionBuilder = ZikrCountsCompanion Function({
  Value<int> id,
  Value<DateTime> day,
  Value<ZikrSession> session,
  Value<int> item,
  Value<int> count,
  Value<DateTime> updatedAt,
});

class $$ZikrCountsTableFilterComposer
    extends Composer<_$AppDatabase, $ZikrCountsTable> {
  $$ZikrCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ZikrSession, ZikrSession, String>
  get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZikrCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ZikrCountsTable> {
  $$ZikrCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZikrCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZikrCountsTable> {
  $$ZikrCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ZikrSession, String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);

  GeneratedColumn<int> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ZikrCountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZikrCountsTable,
          ZikrCount,
          $$ZikrCountsTableFilterComposer,
          $$ZikrCountsTableOrderingComposer,
          $$ZikrCountsTableAnnotationComposer,
          $$ZikrCountsTableCreateCompanionBuilder,
          $$ZikrCountsTableUpdateCompanionBuilder,
          (
            ZikrCount,
            BaseReferences<_$AppDatabase, $ZikrCountsTable, ZikrCount>,
          ),
          ZikrCount,
          PrefetchHooks Function()
        > {
  $$ZikrCountsTableTableManager(_$AppDatabase db, $ZikrCountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZikrCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZikrCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZikrCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<ZikrSession> session = const Value.absent(),
                Value<int> item = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ZikrCountsCompanion(
                id: id,
                day: day,
                session: session,
                item: item,
                count: count,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime day,
                required ZikrSession session,
                required int item,
                required int count,
                required DateTime updatedAt,
              }) => ZikrCountsCompanion.insert(
                id: id,
                day: day,
                session: session,
                item: item,
                count: count,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ZikrCountsTable, ZikrCount>(table),
                  BaseReferences<_$AppDatabase, $ZikrCountsTable, ZikrCount>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZikrCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZikrCountsTable,
      ZikrCount,
      $$ZikrCountsTableFilterComposer,
      $$ZikrCountsTableOrderingComposer,
      $$ZikrCountsTableAnnotationComposer,
      $$ZikrCountsTableCreateCompanionBuilder,
      $$ZikrCountsTableUpdateCompanionBuilder,
      (ZikrCount, BaseReferences<_$AppDatabase, $ZikrCountsTable, ZikrCount>),
      ZikrCount,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerDebtsTableTableManager get prayerDebts =>
      $$PrayerDebtsTableTableManager(_db, _db.prayerDebts);
  $$FastingDebtsTableTableManager get fastingDebts =>
      $$FastingDebtsTableTableManager(_db, _db.fastingDebts);
  $$WorshipRecordsTableTableManager get worshipRecords =>
      $$WorshipRecordsTableTableManager(_db, _db.worshipRecords);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ZikrCountsTableTableManager get zikrCounts =>
      $$ZikrCountsTableTableManager(_db, _db.zikrCounts);
}
