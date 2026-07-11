// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PrayerLogDaysTable extends PrayerLogDays
    with TableInfo<$PrayerLogDaysTable, PrayerLogDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerLogDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UtcDateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<UtcDateTime>($PrayerLogDaysTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [dayKey, deviceId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_log_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerLogDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  PrayerLogDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLogDayRow(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      updatedAt: $PrayerLogDaysTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $PrayerLogDaysTable createAlias(String alias) {
    return $PrayerLogDaysTable(attachedDatabase, alias);
  }

  static TypeConverter<UtcDateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
}

class PrayerLogDayRow extends DataClass implements Insertable<PrayerLogDayRow> {
  /// `yyyy-MM-dd` (geçerlilik domain `DayKey` tipinde doğrulanır).
  final String dayKey;
  final String deviceId;

  /// Pull-merge imleç sorgularının index'li alanı (10 §25).
  final UtcDateTime updatedAt;
  const PrayerLogDayRow({
    required this.dayKey,
    required this.deviceId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    map['device_id'] = Variable<String>(deviceId);
    {
      map['updated_at'] = Variable<int>(
        $PrayerLogDaysTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  PrayerLogDaysCompanion toCompanion(bool nullToAbsent) {
    return PrayerLogDaysCompanion(
      dayKey: Value(dayKey),
      deviceId: Value(deviceId),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrayerLogDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLogDayRow(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      updatedAt: serializer.fromJson<UtcDateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'deviceId': serializer.toJson<String>(deviceId),
      'updatedAt': serializer.toJson<UtcDateTime>(updatedAt),
    };
  }

  PrayerLogDayRow copyWith({
    String? dayKey,
    String? deviceId,
    UtcDateTime? updatedAt,
  }) => PrayerLogDayRow(
    dayKey: dayKey ?? this.dayKey,
    deviceId: deviceId ?? this.deviceId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrayerLogDayRow copyWithCompanion(PrayerLogDaysCompanion data) {
    return PrayerLogDayRow(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogDayRow(')
          ..write('dayKey: $dayKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, deviceId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLogDayRow &&
          other.dayKey == this.dayKey &&
          other.deviceId == this.deviceId &&
          other.updatedAt == this.updatedAt);
}

class PrayerLogDaysCompanion extends UpdateCompanion<PrayerLogDayRow> {
  final Value<String> dayKey;
  final Value<String> deviceId;
  final Value<UtcDateTime> updatedAt;
  final Value<int> rowid;
  const PrayerLogDaysCompanion({
    this.dayKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerLogDaysCompanion.insert({
    required String dayKey,
    required String deviceId,
    required UtcDateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey),
       deviceId = Value(deviceId),
       updatedAt = Value(updatedAt);
  static Insertable<PrayerLogDayRow> custom({
    Expression<String>? dayKey,
    Expression<String>? deviceId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (deviceId != null) 'device_id': deviceId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerLogDaysCompanion copyWith({
    Value<String>? dayKey,
    Value<String>? deviceId,
    Value<UtcDateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrayerLogDaysCompanion(
      dayKey: dayKey ?? this.dayKey,
      deviceId: deviceId ?? this.deviceId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $PrayerLogDaysTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogDaysCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerEntriesTable extends PrayerEntries
    with TableInfo<$PrayerEntriesTable, PrayerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prayer_log_days (day_key) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrayerName, String> prayerName =
      GeneratedColumn<String>(
        'prayer_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerName>($PrayerEntriesTable.$converterprayerName);
  @override
  late final GeneratedColumnWithTypeConverter<PrayerCompletionStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PrayerCompletionStatus>($PrayerEntriesTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<UtcDateTime?, int> loggedAt =
      GeneratedColumn<int>(
        'logged_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<UtcDateTime?>($PrayerEntriesTable.$converterloggedAtn);
  static const VerificationMeta _undoneMeta = const VerificationMeta('undone');
  @override
  late final GeneratedColumn<bool> undone = GeneratedColumn<bool>(
    'undone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("undone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayKey,
    prayerName,
    status,
    loggedAt,
    undone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('undone')) {
      context.handle(
        _undoneMeta,
        undone.isAcceptableOrUnknown(data['undone']!, _undoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey, prayerName};
  @override
  PrayerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerEntryRow(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      prayerName: $PrayerEntriesTable.$converterprayerName.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer_name'],
        )!,
      ),
      status: $PrayerEntriesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      loggedAt: $PrayerEntriesTable.$converterloggedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}logged_at'],
        ),
      ),
      undone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}undone'],
      )!,
    );
  }

  @override
  $PrayerEntriesTable createAlias(String alias) {
    return $PrayerEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrayerName, String, String> $converterprayerName =
      const EnumNameConverter<PrayerName>(PrayerName.values);
  static JsonTypeConverter2<PrayerCompletionStatus, String, String>
  $converterstatus = const EnumNameConverter<PrayerCompletionStatus>(
    PrayerCompletionStatus.values,
  );
  static TypeConverter<UtcDateTime, int> $converterloggedAt =
      const UtcDateTimeConverter();
  static TypeConverter<UtcDateTime?, int?> $converterloggedAtn =
      NullAwareTypeConverter.wrap($converterloggedAt);
}

class PrayerEntryRow extends DataClass implements Insertable<PrayerEntryRow> {
  final String dayKey;
  final PrayerName prayerName;
  final PrayerCompletionStatus status;

  /// Yerel niyet zamanı; çakışma tie-break ölçütü (10 §14-1, §27-10).
  final UtcDateTime? loggedAt;

  /// Açık geri alma tombstone'u (TASK 012B deterministik merge girdisi).
  final bool undone;
  const PrayerEntryRow({
    required this.dayKey,
    required this.prayerName,
    required this.status,
    this.loggedAt,
    required this.undone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    {
      map['prayer_name'] = Variable<String>(
        $PrayerEntriesTable.$converterprayerName.toSql(prayerName),
      );
    }
    {
      map['status'] = Variable<String>(
        $PrayerEntriesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || loggedAt != null) {
      map['logged_at'] = Variable<int>(
        $PrayerEntriesTable.$converterloggedAtn.toSql(loggedAt),
      );
    }
    map['undone'] = Variable<bool>(undone);
    return map;
  }

  PrayerEntriesCompanion toCompanion(bool nullToAbsent) {
    return PrayerEntriesCompanion(
      dayKey: Value(dayKey),
      prayerName: Value(prayerName),
      status: Value(status),
      loggedAt: loggedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(loggedAt),
      undone: Value(undone),
    );
  }

  factory PrayerEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerEntryRow(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      prayerName: $PrayerEntriesTable.$converterprayerName.fromJson(
        serializer.fromJson<String>(json['prayerName']),
      ),
      status: $PrayerEntriesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      loggedAt: serializer.fromJson<UtcDateTime?>(json['loggedAt']),
      undone: serializer.fromJson<bool>(json['undone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'prayerName': serializer.toJson<String>(
        $PrayerEntriesTable.$converterprayerName.toJson(prayerName),
      ),
      'status': serializer.toJson<String>(
        $PrayerEntriesTable.$converterstatus.toJson(status),
      ),
      'loggedAt': serializer.toJson<UtcDateTime?>(loggedAt),
      'undone': serializer.toJson<bool>(undone),
    };
  }

  PrayerEntryRow copyWith({
    String? dayKey,
    PrayerName? prayerName,
    PrayerCompletionStatus? status,
    Value<UtcDateTime?> loggedAt = const Value.absent(),
    bool? undone,
  }) => PrayerEntryRow(
    dayKey: dayKey ?? this.dayKey,
    prayerName: prayerName ?? this.prayerName,
    status: status ?? this.status,
    loggedAt: loggedAt.present ? loggedAt.value : this.loggedAt,
    undone: undone ?? this.undone,
  );
  PrayerEntryRow copyWithCompanion(PrayerEntriesCompanion data) {
    return PrayerEntryRow(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      prayerName: data.prayerName.present
          ? data.prayerName.value
          : this.prayerName,
      status: data.status.present ? data.status.value : this.status,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      undone: data.undone.present ? data.undone.value : this.undone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerEntryRow(')
          ..write('dayKey: $dayKey, ')
          ..write('prayerName: $prayerName, ')
          ..write('status: $status, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('undone: $undone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, prayerName, status, loggedAt, undone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerEntryRow &&
          other.dayKey == this.dayKey &&
          other.prayerName == this.prayerName &&
          other.status == this.status &&
          other.loggedAt == this.loggedAt &&
          other.undone == this.undone);
}

class PrayerEntriesCompanion extends UpdateCompanion<PrayerEntryRow> {
  final Value<String> dayKey;
  final Value<PrayerName> prayerName;
  final Value<PrayerCompletionStatus> status;
  final Value<UtcDateTime?> loggedAt;
  final Value<bool> undone;
  final Value<int> rowid;
  const PrayerEntriesCompanion({
    this.dayKey = const Value.absent(),
    this.prayerName = const Value.absent(),
    this.status = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerEntriesCompanion.insert({
    required String dayKey,
    required PrayerName prayerName,
    required PrayerCompletionStatus status,
    this.loggedAt = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey),
       prayerName = Value(prayerName),
       status = Value(status);
  static Insertable<PrayerEntryRow> custom({
    Expression<String>? dayKey,
    Expression<String>? prayerName,
    Expression<String>? status,
    Expression<int>? loggedAt,
    Expression<bool>? undone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (prayerName != null) 'prayer_name': prayerName,
      if (status != null) 'status': status,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (undone != null) 'undone': undone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerEntriesCompanion copyWith({
    Value<String>? dayKey,
    Value<PrayerName>? prayerName,
    Value<PrayerCompletionStatus>? status,
    Value<UtcDateTime?>? loggedAt,
    Value<bool>? undone,
    Value<int>? rowid,
  }) {
    return PrayerEntriesCompanion(
      dayKey: dayKey ?? this.dayKey,
      prayerName: prayerName ?? this.prayerName,
      status: status ?? this.status,
      loggedAt: loggedAt ?? this.loggedAt,
      undone: undone ?? this.undone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (prayerName.present) {
      map['prayer_name'] = Variable<String>(
        $PrayerEntriesTable.$converterprayerName.toSql(prayerName.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PrayerEntriesTable.$converterstatus.toSql(status.value),
      );
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<int>(
        $PrayerEntriesTable.$converterloggedAtn.toSql(loggedAt.value),
      );
    }
    if (undone.present) {
      map['undone'] = Variable<bool>(undone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerEntriesCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('prayerName: $prayerName, ')
          ..write('status: $status, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('undone: $undone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntityType, String>
  entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncEntityType>($SyncOperationsTable.$converterentityType);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperationType, String>
  operationType =
      GeneratedColumn<String>(
        'operation_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOperationType>(
        $SyncOperationsTable.$converteroperationType,
      );
  static const VerificationMeta _payloadRefMeta = const VerificationMeta(
    'payloadRef',
  );
  @override
  late final GeneratedColumn<String> payloadRef = GeneratedColumn<String>(
    'payload_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadHashMeta = const VerificationMeta(
    'payloadHash',
  );
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
    'payload_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UtcDateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<UtcDateTime>($SyncOperationsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<UtcDateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<UtcDateTime>($SyncOperationsTable.$converterupdatedAt);
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<UtcDateTime?, int> nextRetryAt =
      GeneratedColumn<int>(
        'next_retry_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<UtcDateTime?>(
        $SyncOperationsTable.$converternextRetryAtn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperationStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncOperationStatus>($SyncOperationsTable.$converterstatus);
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SensitivityClass, String>
  sensitivityClass =
      GeneratedColumn<String>(
        'sensitivity_class',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SensitivityClass>(
        $SyncOperationsTable.$convertersensitivityClass,
      );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    uid,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadRef,
    payloadHash,
    createdAt,
    updatedAt,
    retryCount,
    nextRetryAt,
    status,
    lastErrorCode,
    idempotencyKey,
    sensitivityClass,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_ref')) {
      context.handle(
        _payloadRefMeta,
        payloadRef.isAcceptableOrUnknown(data['payload_ref']!, _payloadRefMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadRefMeta);
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
        _payloadHashMeta,
        payloadHash.isAcceptableOrUnknown(
          data['payload_hash']!,
          _payloadHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadHashMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperationRow(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: $SyncOperationsTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: $SyncOperationsTable.$converteroperationType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation_type'],
        )!,
      ),
      payloadRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_ref'],
      )!,
      payloadHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_hash'],
      )!,
      createdAt: $SyncOperationsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $SyncOperationsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: $SyncOperationsTable.$converternextRetryAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}next_retry_at'],
        ),
      ),
      status: $SyncOperationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      sensitivityClass: $SyncOperationsTable.$convertersensitivityClass.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sensitivity_class'],
        )!,
      ),
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEntityType, String, String>
  $converterentityType = const EnumNameConverter<SyncEntityType>(
    SyncEntityType.values,
  );
  static JsonTypeConverter2<SyncOperationType, String, String>
  $converteroperationType = const EnumNameConverter<SyncOperationType>(
    SyncOperationType.values,
  );
  static TypeConverter<UtcDateTime, int> $convertercreatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<UtcDateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<UtcDateTime, int> $converternextRetryAt =
      const UtcDateTimeConverter();
  static TypeConverter<UtcDateTime?, int?> $converternextRetryAtn =
      NullAwareTypeConverter.wrap($converternextRetryAt);
  static JsonTypeConverter2<SyncOperationStatus, String, String>
  $converterstatus = const EnumNameConverter<SyncOperationStatus>(
    SyncOperationStatus.values,
  );
  static JsonTypeConverter2<SensitivityClass, String, String>
  $convertersensitivityClass = const EnumNameConverter<SensitivityClass>(
    SensitivityClass.values,
  );
}

class SyncOperationRow extends DataClass
    implements Insertable<SyncOperationRow> {
  final String operationId;
  final String uid;
  final String deviceId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final String payloadRef;
  final String payloadHash;
  final UtcDateTime createdAt;
  final UtcDateTime updatedAt;
  final int retryCount;
  final UtcDateTime? nextRetryAt;
  final SyncOperationStatus status;

  /// Son hata SINIFI (kova) — ham hata mesajı saklanmaz (10 §11).
  final String? lastErrorCode;
  final String idempotencyKey;
  final SensitivityClass sensitivityClass;
  const SyncOperationRow({
    required this.operationId,
    required this.uid,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadRef,
    required this.payloadHash,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    this.nextRetryAt,
    required this.status,
    this.lastErrorCode,
    required this.idempotencyKey,
    required this.sensitivityClass,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['uid'] = Variable<String>(uid);
    map['device_id'] = Variable<String>(deviceId);
    {
      map['entity_type'] = Variable<String>(
        $SyncOperationsTable.$converterentityType.toSql(entityType),
      );
    }
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation_type'] = Variable<String>(
        $SyncOperationsTable.$converteroperationType.toSql(operationType),
      );
    }
    map['payload_ref'] = Variable<String>(payloadRef);
    map['payload_hash'] = Variable<String>(payloadHash);
    {
      map['created_at'] = Variable<int>(
        $SyncOperationsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $SyncOperationsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<int>(
        $SyncOperationsTable.$converternextRetryAtn.toSql(nextRetryAt),
      );
    }
    {
      map['status'] = Variable<String>(
        $SyncOperationsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    {
      map['sensitivity_class'] = Variable<String>(
        $SyncOperationsTable.$convertersensitivityClass.toSql(sensitivityClass),
      );
    }
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      operationId: Value(operationId),
      uid: Value(uid),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadRef: Value(payloadRef),
      payloadHash: Value(payloadHash),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      status: Value(status),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      idempotencyKey: Value(idempotencyKey),
      sensitivityClass: Value(sensitivityClass),
    );
  }

  factory SyncOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperationRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      uid: serializer.fromJson<String>(json['uid']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: $SyncOperationsTable.$converterentityType.fromJson(
        serializer.fromJson<String>(json['entityType']),
      ),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: $SyncOperationsTable.$converteroperationType.fromJson(
        serializer.fromJson<String>(json['operationType']),
      ),
      payloadRef: serializer.fromJson<String>(json['payloadRef']),
      payloadHash: serializer.fromJson<String>(json['payloadHash']),
      createdAt: serializer.fromJson<UtcDateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<UtcDateTime>(json['updatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<UtcDateTime?>(json['nextRetryAt']),
      status: $SyncOperationsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      sensitivityClass: $SyncOperationsTable.$convertersensitivityClass
          .fromJson(serializer.fromJson<String>(json['sensitivityClass'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'uid': serializer.toJson<String>(uid),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(
        $SyncOperationsTable.$converterentityType.toJson(entityType),
      ),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(
        $SyncOperationsTable.$converteroperationType.toJson(operationType),
      ),
      'payloadRef': serializer.toJson<String>(payloadRef),
      'payloadHash': serializer.toJson<String>(payloadHash),
      'createdAt': serializer.toJson<UtcDateTime>(createdAt),
      'updatedAt': serializer.toJson<UtcDateTime>(updatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<UtcDateTime?>(nextRetryAt),
      'status': serializer.toJson<String>(
        $SyncOperationsTable.$converterstatus.toJson(status),
      ),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'sensitivityClass': serializer.toJson<String>(
        $SyncOperationsTable.$convertersensitivityClass.toJson(
          sensitivityClass,
        ),
      ),
    };
  }

  SyncOperationRow copyWith({
    String? operationId,
    String? uid,
    String? deviceId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operationType,
    String? payloadRef,
    String? payloadHash,
    UtcDateTime? createdAt,
    UtcDateTime? updatedAt,
    int? retryCount,
    Value<UtcDateTime?> nextRetryAt = const Value.absent(),
    SyncOperationStatus? status,
    Value<String?> lastErrorCode = const Value.absent(),
    String? idempotencyKey,
    SensitivityClass? sensitivityClass,
  }) => SyncOperationRow(
    operationId: operationId ?? this.operationId,
    uid: uid ?? this.uid,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payloadRef: payloadRef ?? this.payloadRef,
    payloadHash: payloadHash ?? this.payloadHash,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    status: status ?? this.status,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    sensitivityClass: sensitivityClass ?? this.sensitivityClass,
  );
  SyncOperationRow copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperationRow(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      uid: data.uid.present ? data.uid.value : this.uid,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadRef: data.payloadRef.present
          ? data.payloadRef.value
          : this.payloadRef,
      payloadHash: data.payloadHash.present
          ? data.payloadHash.value
          : this.payloadHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      status: data.status.present ? data.status.value : this.status,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      sensitivityClass: data.sensitivityClass.present
          ? data.sensitivityClass.value
          : this.sensitivityClass,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationRow(')
          ..write('operationId: $operationId, ')
          ..write('uid: $uid, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadRef: $payloadRef, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('sensitivityClass: $sensitivityClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    uid,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadRef,
    payloadHash,
    createdAt,
    updatedAt,
    retryCount,
    nextRetryAt,
    status,
    lastErrorCode,
    idempotencyKey,
    sensitivityClass,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperationRow &&
          other.operationId == this.operationId &&
          other.uid == this.uid &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadRef == this.payloadRef &&
          other.payloadHash == this.payloadHash &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.status == this.status &&
          other.lastErrorCode == this.lastErrorCode &&
          other.idempotencyKey == this.idempotencyKey &&
          other.sensitivityClass == this.sensitivityClass);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperationRow> {
  final Value<String> operationId;
  final Value<String> uid;
  final Value<String> deviceId;
  final Value<SyncEntityType> entityType;
  final Value<String> entityId;
  final Value<SyncOperationType> operationType;
  final Value<String> payloadRef;
  final Value<String> payloadHash;
  final Value<UtcDateTime> createdAt;
  final Value<UtcDateTime> updatedAt;
  final Value<int> retryCount;
  final Value<UtcDateTime?> nextRetryAt;
  final Value<SyncOperationStatus> status;
  final Value<String?> lastErrorCode;
  final Value<String> idempotencyKey;
  final Value<SensitivityClass> sensitivityClass;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.operationId = const Value.absent(),
    this.uid = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadRef = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.sensitivityClass = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String operationId,
    required String uid,
    required String deviceId,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required String payloadRef,
    required String payloadHash,
    required UtcDateTime createdAt,
    required UtcDateTime updatedAt,
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    required SyncOperationStatus status,
    this.lastErrorCode = const Value.absent(),
    required String idempotencyKey,
    required SensitivityClass sensitivityClass,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       uid = Value(uid),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payloadRef = Value(payloadRef),
       payloadHash = Value(payloadHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status),
       idempotencyKey = Value(idempotencyKey),
       sensitivityClass = Value(sensitivityClass);
  static Insertable<SyncOperationRow> custom({
    Expression<String>? operationId,
    Expression<String>? uid,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadRef,
    Expression<String>? payloadHash,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? retryCount,
    Expression<int>? nextRetryAt,
    Expression<String>? status,
    Expression<String>? lastErrorCode,
    Expression<String>? idempotencyKey,
    Expression<String>? sensitivityClass,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (uid != null) 'uid': uid,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadRef != null) 'payload_ref': payloadRef,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (status != null) 'status': status,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (sensitivityClass != null) 'sensitivity_class': sensitivityClass,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? uid,
    Value<String>? deviceId,
    Value<SyncEntityType>? entityType,
    Value<String>? entityId,
    Value<SyncOperationType>? operationType,
    Value<String>? payloadRef,
    Value<String>? payloadHash,
    Value<UtcDateTime>? createdAt,
    Value<UtcDateTime>? updatedAt,
    Value<int>? retryCount,
    Value<UtcDateTime?>? nextRetryAt,
    Value<SyncOperationStatus>? status,
    Value<String?>? lastErrorCode,
    Value<String>? idempotencyKey,
    Value<SensitivityClass>? sensitivityClass,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      operationId: operationId ?? this.operationId,
      uid: uid ?? this.uid,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadRef: payloadRef ?? this.payloadRef,
      payloadHash: payloadHash ?? this.payloadHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      status: status ?? this.status,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      sensitivityClass: sensitivityClass ?? this.sensitivityClass,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $SyncOperationsTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(
        $SyncOperationsTable.$converteroperationType.toSql(operationType.value),
      );
    }
    if (payloadRef.present) {
      map['payload_ref'] = Variable<String>(payloadRef.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SyncOperationsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $SyncOperationsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(
        $SyncOperationsTable.$converternextRetryAtn.toSql(nextRetryAt.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SyncOperationsTable.$converterstatus.toSql(status.value),
      );
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (sensitivityClass.present) {
      map['sensitivity_class'] = Variable<String>(
        $SyncOperationsTable.$convertersensitivityClass.toSql(
          sensitivityClass.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('uid: $uid, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadRef: $payloadRef, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('sensitivityClass: $sensitivityClass, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerLogDaysTable prayerLogDays = $PrayerLogDaysTable(this);
  late final $PrayerEntriesTable prayerEntries = $PrayerEntriesTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final Index prayerLogDaysUpdatedAt = Index(
    'prayer_log_days_updated_at',
    'CREATE INDEX prayer_log_days_updated_at ON prayer_log_days (updated_at)',
  );
  late final Index syncOperationsStatusNextRetryAt = Index(
    'sync_operations_status_next_retry_at',
    'CREATE INDEX sync_operations_status_next_retry_at ON sync_operations (status, next_retry_at)',
  );
  late final Index syncOperationsEntity = Index(
    'sync_operations_entity',
    'CREATE INDEX sync_operations_entity ON sync_operations (entity_type, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerLogDays,
    prayerEntries,
    syncOperations,
    prayerLogDaysUpdatedAt,
    syncOperationsStatusNextRetryAt,
    syncOperationsEntity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'prayer_log_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PrayerLogDaysTableCreateCompanionBuilder =
    PrayerLogDaysCompanion Function({
      required String dayKey,
      required String deviceId,
      required UtcDateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PrayerLogDaysTableUpdateCompanionBuilder =
    PrayerLogDaysCompanion Function({
      Value<String> dayKey,
      Value<String> deviceId,
      Value<UtcDateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PrayerLogDaysTableReferences
    extends
        BaseReferences<_$AppDatabase, $PrayerLogDaysTable, PrayerLogDayRow> {
  $$PrayerLogDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PrayerEntriesTable, List<PrayerEntryRow>>
  _prayerEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prayerEntries,
    aliasName: 'prayer_log_days__day_key__prayer_entries__day_key',
  );

  $$PrayerEntriesTableProcessedTableManager get prayerEntriesRefs {
    final manager = $$PrayerEntriesTableTableManager($_db, $_db.prayerEntries)
        .filter(
          (f) => f.dayKey.dayKey.sqlEquals($_itemColumn<String>('day_key')!),
        );

    final cache = $_typedResult.readTableOrNull(_prayerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrayerLogDaysTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerLogDaysTable> {
  $$PrayerLogDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UtcDateTime, UtcDateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> prayerEntriesRefs(
    Expression<bool> Function($$PrayerEntriesTableFilterComposer f) f,
  ) {
    final $$PrayerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayKey,
      referencedTable: $db.prayerEntries,
      getReferencedColumn: (t) => t.dayKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.prayerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrayerLogDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerLogDaysTable> {
  $$PrayerLogDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerLogDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerLogDaysTable> {
  $$PrayerLogDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UtcDateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> prayerEntriesRefs<T extends Object>(
    Expression<T> Function($$PrayerEntriesTableAnnotationComposer a) f,
  ) {
    final $$PrayerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayKey,
      referencedTable: $db.prayerEntries,
      getReferencedColumn: (t) => t.dayKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrayerLogDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerLogDaysTable,
          PrayerLogDayRow,
          $$PrayerLogDaysTableFilterComposer,
          $$PrayerLogDaysTableOrderingComposer,
          $$PrayerLogDaysTableAnnotationComposer,
          $$PrayerLogDaysTableCreateCompanionBuilder,
          $$PrayerLogDaysTableUpdateCompanionBuilder,
          (PrayerLogDayRow, $$PrayerLogDaysTableReferences),
          PrayerLogDayRow,
          PrefetchHooks Function({bool prayerEntriesRefs})
        > {
  $$PrayerLogDaysTableTableManager(_$AppDatabase db, $PrayerLogDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerLogDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerLogDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerLogDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<UtcDateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerLogDaysCompanion(
                dayKey: dayKey,
                deviceId: deviceId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                required String deviceId,
                required UtcDateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PrayerLogDaysCompanion.insert(
                dayKey: dayKey,
                deviceId: deviceId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayerLogDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({prayerEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (prayerEntriesRefs) db.prayerEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (prayerEntriesRefs)
                    await $_getPrefetchedData<
                      PrayerLogDayRow,
                      $PrayerLogDaysTable,
                      PrayerEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$PrayerLogDaysTableReferences
                          ._prayerEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PrayerLogDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).prayerEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dayKey == item.dayKey),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PrayerLogDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerLogDaysTable,
      PrayerLogDayRow,
      $$PrayerLogDaysTableFilterComposer,
      $$PrayerLogDaysTableOrderingComposer,
      $$PrayerLogDaysTableAnnotationComposer,
      $$PrayerLogDaysTableCreateCompanionBuilder,
      $$PrayerLogDaysTableUpdateCompanionBuilder,
      (PrayerLogDayRow, $$PrayerLogDaysTableReferences),
      PrayerLogDayRow,
      PrefetchHooks Function({bool prayerEntriesRefs})
    >;
typedef $$PrayerEntriesTableCreateCompanionBuilder =
    PrayerEntriesCompanion Function({
      required String dayKey,
      required PrayerName prayerName,
      required PrayerCompletionStatus status,
      Value<UtcDateTime?> loggedAt,
      Value<bool> undone,
      Value<int> rowid,
    });
typedef $$PrayerEntriesTableUpdateCompanionBuilder =
    PrayerEntriesCompanion Function({
      Value<String> dayKey,
      Value<PrayerName> prayerName,
      Value<PrayerCompletionStatus> status,
      Value<UtcDateTime?> loggedAt,
      Value<bool> undone,
      Value<int> rowid,
    });

final class $$PrayerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $PrayerEntriesTable, PrayerEntryRow> {
  $$PrayerEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PrayerLogDaysTable _dayKeyTable(_$AppDatabase db) => db.prayerLogDays
      .createAlias('prayer_entries__day_key__prayer_log_days__day_key');

  $$PrayerLogDaysTableProcessedTableManager get dayKey {
    final $_column = $_itemColumn<String>('day_key')!;

    final manager = $$PrayerLogDaysTableTableManager(
      $_db,
      $_db.prayerLogDays,
    ).filter((f) => f.dayKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrayerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerEntriesTable> {
  $$PrayerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<PrayerName, PrayerName, String>
  get prayerName => $composableBuilder(
    column: $table.prayerName,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    PrayerCompletionStatus,
    PrayerCompletionStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<UtcDateTime?, UtcDateTime, int> get loggedAt =>
      $composableBuilder(
        column: $table.loggedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnFilters(column),
  );

  $$PrayerLogDaysTableFilterComposer get dayKey {
    final $$PrayerLogDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayKey,
      referencedTable: $db.prayerLogDays,
      getReferencedColumn: (t) => t.dayKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerLogDaysTableFilterComposer(
            $db: $db,
            $table: $db.prayerLogDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerEntriesTable> {
  $$PrayerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayerName => $composableBuilder(
    column: $table.prayerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrayerLogDaysTableOrderingComposer get dayKey {
    final $$PrayerLogDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayKey,
      referencedTable: $db.prayerLogDays,
      getReferencedColumn: (t) => t.dayKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerLogDaysTableOrderingComposer(
            $db: $db,
            $table: $db.prayerLogDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerEntriesTable> {
  $$PrayerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<PrayerName, String> get prayerName =>
      $composableBuilder(
        column: $table.prayerName,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<PrayerCompletionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UtcDateTime?, int> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get undone =>
      $composableBuilder(column: $table.undone, builder: (column) => column);

  $$PrayerLogDaysTableAnnotationComposer get dayKey {
    final $$PrayerLogDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayKey,
      referencedTable: $db.prayerLogDays,
      getReferencedColumn: (t) => t.dayKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerLogDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerLogDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerEntriesTable,
          PrayerEntryRow,
          $$PrayerEntriesTableFilterComposer,
          $$PrayerEntriesTableOrderingComposer,
          $$PrayerEntriesTableAnnotationComposer,
          $$PrayerEntriesTableCreateCompanionBuilder,
          $$PrayerEntriesTableUpdateCompanionBuilder,
          (PrayerEntryRow, $$PrayerEntriesTableReferences),
          PrayerEntryRow,
          PrefetchHooks Function({bool dayKey})
        > {
  $$PrayerEntriesTableTableManager(_$AppDatabase db, $PrayerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<PrayerName> prayerName = const Value.absent(),
                Value<PrayerCompletionStatus> status = const Value.absent(),
                Value<UtcDateTime?> loggedAt = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerEntriesCompanion(
                dayKey: dayKey,
                prayerName: prayerName,
                status: status,
                loggedAt: loggedAt,
                undone: undone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                required PrayerName prayerName,
                required PrayerCompletionStatus status,
                Value<UtcDateTime?> loggedAt = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerEntriesCompanion.insert(
                dayKey: dayKey,
                prayerName: prayerName,
                status: status,
                loggedAt: loggedAt,
                undone: undone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayerEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayKey,
                                referencedTable: $$PrayerEntriesTableReferences
                                    ._dayKeyTable(db),
                                referencedColumn: $$PrayerEntriesTableReferences
                                    ._dayKeyTable(db)
                                    .dayKey,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrayerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerEntriesTable,
      PrayerEntryRow,
      $$PrayerEntriesTableFilterComposer,
      $$PrayerEntriesTableOrderingComposer,
      $$PrayerEntriesTableAnnotationComposer,
      $$PrayerEntriesTableCreateCompanionBuilder,
      $$PrayerEntriesTableUpdateCompanionBuilder,
      (PrayerEntryRow, $$PrayerEntriesTableReferences),
      PrayerEntryRow,
      PrefetchHooks Function({bool dayKey})
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String operationId,
      required String uid,
      required String deviceId,
      required SyncEntityType entityType,
      required String entityId,
      required SyncOperationType operationType,
      required String payloadRef,
      required String payloadHash,
      required UtcDateTime createdAt,
      required UtcDateTime updatedAt,
      Value<int> retryCount,
      Value<UtcDateTime?> nextRetryAt,
      required SyncOperationStatus status,
      Value<String?> lastErrorCode,
      required String idempotencyKey,
      required SensitivityClass sensitivityClass,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> operationId,
      Value<String> uid,
      Value<String> deviceId,
      Value<SyncEntityType> entityType,
      Value<String> entityId,
      Value<SyncOperationType> operationType,
      Value<String> payloadRef,
      Value<String> payloadHash,
      Value<UtcDateTime> createdAt,
      Value<UtcDateTime> updatedAt,
      Value<int> retryCount,
      Value<UtcDateTime?> nextRetryAt,
      Value<SyncOperationStatus> status,
      Value<String?> lastErrorCode,
      Value<String> idempotencyKey,
      Value<SensitivityClass> sensitivityClass,
      Value<int> rowid,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEntityType, SyncEntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperationType, SyncOperationType, String>
  get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payloadRef => $composableBuilder(
    column: $table.payloadRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UtcDateTime, UtcDateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<UtcDateTime, UtcDateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UtcDateTime?, UtcDateTime, int>
  get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SyncOperationStatus,
    SyncOperationStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SensitivityClass, SensitivityClass, String>
  get sensitivityClass => $composableBuilder(
    column: $table.sensitivityClass,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadRef => $composableBuilder(
    column: $table.payloadRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensitivityClass => $composableBuilder(
    column: $table.sensitivityClass,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncEntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperationType, String>
  get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadRef => $composableBuilder(
    column: $table.payloadRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UtcDateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UtcDateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UtcDateTime?, int> get nextRetryAt =>
      $composableBuilder(
        column: $table.nextRetryAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SyncOperationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SensitivityClass, String>
  get sensitivityClass => $composableBuilder(
    column: $table.sensitivityClass,
    builder: (column) => column,
  );
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOperationsTable,
          SyncOperationRow,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperationRow,
            BaseReferences<
              _$AppDatabase,
              $SyncOperationsTable,
              SyncOperationRow
            >,
          ),
          SyncOperationRow,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$AppDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<SyncEntityType> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<SyncOperationType> operationType = const Value.absent(),
                Value<String> payloadRef = const Value.absent(),
                Value<String> payloadHash = const Value.absent(),
                Value<UtcDateTime> createdAt = const Value.absent(),
                Value<UtcDateTime> updatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<UtcDateTime?> nextRetryAt = const Value.absent(),
                Value<SyncOperationStatus> status = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<SensitivityClass> sensitivityClass = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                operationId: operationId,
                uid: uid,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadRef: payloadRef,
                payloadHash: payloadHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                status: status,
                lastErrorCode: lastErrorCode,
                idempotencyKey: idempotencyKey,
                sensitivityClass: sensitivityClass,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String uid,
                required String deviceId,
                required SyncEntityType entityType,
                required String entityId,
                required SyncOperationType operationType,
                required String payloadRef,
                required String payloadHash,
                required UtcDateTime createdAt,
                required UtcDateTime updatedAt,
                Value<int> retryCount = const Value.absent(),
                Value<UtcDateTime?> nextRetryAt = const Value.absent(),
                required SyncOperationStatus status,
                Value<String?> lastErrorCode = const Value.absent(),
                required String idempotencyKey,
                required SensitivityClass sensitivityClass,
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                operationId: operationId,
                uid: uid,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadRef: payloadRef,
                payloadHash: payloadHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                status: status,
                lastErrorCode: lastErrorCode,
                idempotencyKey: idempotencyKey,
                sensitivityClass: sensitivityClass,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOperationsTable,
      SyncOperationRow,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperationRow,
        BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperationRow>,
      ),
      SyncOperationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerLogDaysTableTableManager get prayerLogDays =>
      $$PrayerLogDaysTableTableManager(_db, _db.prayerLogDays);
  $$PrayerEntriesTableTableManager get prayerEntries =>
      $$PrayerEntriesTableTableManager(_db, _db.prayerEntries);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
}
