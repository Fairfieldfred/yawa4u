// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrainingCyclesTable extends TrainingCycles
    with TableInfo<$TrainingCyclesTable, TrainingCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingCyclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodsTotalMeta = const VerificationMeta(
    'periodsTotal',
  );
  @override
  late final GeneratedColumn<int> periodsTotal = GeneratedColumn<int>(
    'periods_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysPerPeriodMeta = const VerificationMeta(
    'daysPerPeriod',
  );
  @override
  late final GeneratedColumn<int> daysPerPeriod = GeneratedColumn<int>(
    'days_per_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoveryPeriodMeta = const VerificationMeta(
    'recoveryPeriod',
  );
  @override
  late final GeneratedColumn<int> recoveryPeriod = GeneratedColumn<int>(
    'recovery_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<int> gender = GeneratedColumn<int>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'created_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleGroupPrioritiesMeta =
      const VerificationMeta('muscleGroupPriorities');
  @override
  late final GeneratedColumn<String> muscleGroupPriorities =
      GeneratedColumn<String>(
        'muscle_group_priorities',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _templateNameMeta = const VerificationMeta(
    'templateName',
  );
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
    'template_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoveryPeriodTypeMeta =
      const VerificationMeta('recoveryPeriodType');
  @override
  late final GeneratedColumn<int> recoveryPeriodType = GeneratedColumn<int>(
    'recovery_period_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    name,
    periodsTotal,
    daysPerPeriod,
    recoveryPeriod,
    status,
    gender,
    createdDate,
    startDate,
    endDate,
    muscleGroupPriorities,
    templateName,
    notes,
    recoveryPeriodType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingCycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('periods_total')) {
      context.handle(
        _periodsTotalMeta,
        periodsTotal.isAcceptableOrUnknown(
          data['periods_total']!,
          _periodsTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodsTotalMeta);
    }
    if (data.containsKey('days_per_period')) {
      context.handle(
        _daysPerPeriodMeta,
        daysPerPeriod.isAcceptableOrUnknown(
          data['days_per_period']!,
          _daysPerPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysPerPeriodMeta);
    }
    if (data.containsKey('recovery_period')) {
      context.handle(
        _recoveryPeriodMeta,
        recoveryPeriod.isAcceptableOrUnknown(
          data['recovery_period']!,
          _recoveryPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryPeriodMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('created_date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['created_date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('muscle_group_priorities')) {
      context.handle(
        _muscleGroupPrioritiesMeta,
        muscleGroupPriorities.isAcceptableOrUnknown(
          data['muscle_group_priorities']!,
          _muscleGroupPrioritiesMeta,
        ),
      );
    }
    if (data.containsKey('template_name')) {
      context.handle(
        _templateNameMeta,
        templateName.isAcceptableOrUnknown(
          data['template_name']!,
          _templateNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('recovery_period_type')) {
      context.handle(
        _recoveryPeriodTypeMeta,
        recoveryPeriodType.isAcceptableOrUnknown(
          data['recovery_period_type']!,
          _recoveryPeriodTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingCycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      periodsTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}periods_total'],
      )!,
      daysPerPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_period'],
      )!,
      recoveryPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recovery_period'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gender'],
      ),
      createdDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_date'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      muscleGroupPriorities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group_priorities'],
      ),
      templateName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      recoveryPeriodType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recovery_period_type'],
      ),
    );
  }

  @override
  $TrainingCyclesTable createAlias(String alias) {
    return $TrainingCyclesTable(attachedDatabase, alias);
  }
}

class TrainingCycle extends DataClass implements Insertable<TrainingCycle> {
  final int id;
  final String uuid;
  final String name;
  final int periodsTotal;
  final int daysPerPeriod;
  final int recoveryPeriod;
  final int status;
  final int? gender;
  final DateTime createdDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? muscleGroupPriorities;
  final String? templateName;
  final String? notes;
  final int? recoveryPeriodType;
  const TrainingCycle({
    required this.id,
    required this.uuid,
    required this.name,
    required this.periodsTotal,
    required this.daysPerPeriod,
    required this.recoveryPeriod,
    required this.status,
    this.gender,
    required this.createdDate,
    this.startDate,
    this.endDate,
    this.muscleGroupPriorities,
    this.templateName,
    this.notes,
    this.recoveryPeriodType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['periods_total'] = Variable<int>(periodsTotal);
    map['days_per_period'] = Variable<int>(daysPerPeriod);
    map['recovery_period'] = Variable<int>(recoveryPeriod);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<int>(gender);
    }
    map['created_date'] = Variable<DateTime>(createdDate);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || muscleGroupPriorities != null) {
      map['muscle_group_priorities'] = Variable<String>(muscleGroupPriorities);
    }
    if (!nullToAbsent || templateName != null) {
      map['template_name'] = Variable<String>(templateName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || recoveryPeriodType != null) {
      map['recovery_period_type'] = Variable<int>(recoveryPeriodType);
    }
    return map;
  }

  TrainingCyclesCompanion toCompanion(bool nullToAbsent) {
    return TrainingCyclesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      periodsTotal: Value(periodsTotal),
      daysPerPeriod: Value(daysPerPeriod),
      recoveryPeriod: Value(recoveryPeriod),
      status: Value(status),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      createdDate: Value(createdDate),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      muscleGroupPriorities: muscleGroupPriorities == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroupPriorities),
      templateName: templateName == null && nullToAbsent
          ? const Value.absent()
          : Value(templateName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      recoveryPeriodType: recoveryPeriodType == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryPeriodType),
    );
  }

  factory TrainingCycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingCycle(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      periodsTotal: serializer.fromJson<int>(json['periodsTotal']),
      daysPerPeriod: serializer.fromJson<int>(json['daysPerPeriod']),
      recoveryPeriod: serializer.fromJson<int>(json['recoveryPeriod']),
      status: serializer.fromJson<int>(json['status']),
      gender: serializer.fromJson<int?>(json['gender']),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      muscleGroupPriorities: serializer.fromJson<String?>(
        json['muscleGroupPriorities'],
      ),
      templateName: serializer.fromJson<String?>(json['templateName']),
      notes: serializer.fromJson<String?>(json['notes']),
      recoveryPeriodType: serializer.fromJson<int?>(json['recoveryPeriodType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'periodsTotal': serializer.toJson<int>(periodsTotal),
      'daysPerPeriod': serializer.toJson<int>(daysPerPeriod),
      'recoveryPeriod': serializer.toJson<int>(recoveryPeriod),
      'status': serializer.toJson<int>(status),
      'gender': serializer.toJson<int?>(gender),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'muscleGroupPriorities': serializer.toJson<String?>(
        muscleGroupPriorities,
      ),
      'templateName': serializer.toJson<String?>(templateName),
      'notes': serializer.toJson<String?>(notes),
      'recoveryPeriodType': serializer.toJson<int?>(recoveryPeriodType),
    };
  }

  TrainingCycle copyWith({
    int? id,
    String? uuid,
    String? name,
    int? periodsTotal,
    int? daysPerPeriod,
    int? recoveryPeriod,
    int? status,
    Value<int?> gender = const Value.absent(),
    DateTime? createdDate,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> muscleGroupPriorities = const Value.absent(),
    Value<String?> templateName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> recoveryPeriodType = const Value.absent(),
  }) => TrainingCycle(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    periodsTotal: periodsTotal ?? this.periodsTotal,
    daysPerPeriod: daysPerPeriod ?? this.daysPerPeriod,
    recoveryPeriod: recoveryPeriod ?? this.recoveryPeriod,
    status: status ?? this.status,
    gender: gender.present ? gender.value : this.gender,
    createdDate: createdDate ?? this.createdDate,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    muscleGroupPriorities: muscleGroupPriorities.present
        ? muscleGroupPriorities.value
        : this.muscleGroupPriorities,
    templateName: templateName.present ? templateName.value : this.templateName,
    notes: notes.present ? notes.value : this.notes,
    recoveryPeriodType: recoveryPeriodType.present
        ? recoveryPeriodType.value
        : this.recoveryPeriodType,
  );
  TrainingCycle copyWithCompanion(TrainingCyclesCompanion data) {
    return TrainingCycle(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      periodsTotal: data.periodsTotal.present
          ? data.periodsTotal.value
          : this.periodsTotal,
      daysPerPeriod: data.daysPerPeriod.present
          ? data.daysPerPeriod.value
          : this.daysPerPeriod,
      recoveryPeriod: data.recoveryPeriod.present
          ? data.recoveryPeriod.value
          : this.recoveryPeriod,
      status: data.status.present ? data.status.value : this.status,
      gender: data.gender.present ? data.gender.value : this.gender,
      createdDate: data.createdDate.present
          ? data.createdDate.value
          : this.createdDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      muscleGroupPriorities: data.muscleGroupPriorities.present
          ? data.muscleGroupPriorities.value
          : this.muscleGroupPriorities,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      notes: data.notes.present ? data.notes.value : this.notes,
      recoveryPeriodType: data.recoveryPeriodType.present
          ? data.recoveryPeriodType.value
          : this.recoveryPeriodType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingCycle(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('periodsTotal: $periodsTotal, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('recoveryPeriod: $recoveryPeriod, ')
          ..write('status: $status, ')
          ..write('gender: $gender, ')
          ..write('createdDate: $createdDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('muscleGroupPriorities: $muscleGroupPriorities, ')
          ..write('templateName: $templateName, ')
          ..write('notes: $notes, ')
          ..write('recoveryPeriodType: $recoveryPeriodType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    name,
    periodsTotal,
    daysPerPeriod,
    recoveryPeriod,
    status,
    gender,
    createdDate,
    startDate,
    endDate,
    muscleGroupPriorities,
    templateName,
    notes,
    recoveryPeriodType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingCycle &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.periodsTotal == this.periodsTotal &&
          other.daysPerPeriod == this.daysPerPeriod &&
          other.recoveryPeriod == this.recoveryPeriod &&
          other.status == this.status &&
          other.gender == this.gender &&
          other.createdDate == this.createdDate &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.muscleGroupPriorities == this.muscleGroupPriorities &&
          other.templateName == this.templateName &&
          other.notes == this.notes &&
          other.recoveryPeriodType == this.recoveryPeriodType);
}

class TrainingCyclesCompanion extends UpdateCompanion<TrainingCycle> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> periodsTotal;
  final Value<int> daysPerPeriod;
  final Value<int> recoveryPeriod;
  final Value<int> status;
  final Value<int?> gender;
  final Value<DateTime> createdDate;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> muscleGroupPriorities;
  final Value<String?> templateName;
  final Value<String?> notes;
  final Value<int?> recoveryPeriodType;
  const TrainingCyclesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.periodsTotal = const Value.absent(),
    this.daysPerPeriod = const Value.absent(),
    this.recoveryPeriod = const Value.absent(),
    this.status = const Value.absent(),
    this.gender = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.muscleGroupPriorities = const Value.absent(),
    this.templateName = const Value.absent(),
    this.notes = const Value.absent(),
    this.recoveryPeriodType = const Value.absent(),
  });
  TrainingCyclesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required int periodsTotal,
    required int daysPerPeriod,
    required int recoveryPeriod,
    required int status,
    this.gender = const Value.absent(),
    required DateTime createdDate,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.muscleGroupPriorities = const Value.absent(),
    this.templateName = const Value.absent(),
    this.notes = const Value.absent(),
    this.recoveryPeriodType = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       periodsTotal = Value(periodsTotal),
       daysPerPeriod = Value(daysPerPeriod),
       recoveryPeriod = Value(recoveryPeriod),
       status = Value(status),
       createdDate = Value(createdDate);
  static Insertable<TrainingCycle> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? periodsTotal,
    Expression<int>? daysPerPeriod,
    Expression<int>? recoveryPeriod,
    Expression<int>? status,
    Expression<int>? gender,
    Expression<DateTime>? createdDate,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? muscleGroupPriorities,
    Expression<String>? templateName,
    Expression<String>? notes,
    Expression<int>? recoveryPeriodType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (periodsTotal != null) 'periods_total': periodsTotal,
      if (daysPerPeriod != null) 'days_per_period': daysPerPeriod,
      if (recoveryPeriod != null) 'recovery_period': recoveryPeriod,
      if (status != null) 'status': status,
      if (gender != null) 'gender': gender,
      if (createdDate != null) 'created_date': createdDate,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (muscleGroupPriorities != null)
        'muscle_group_priorities': muscleGroupPriorities,
      if (templateName != null) 'template_name': templateName,
      if (notes != null) 'notes': notes,
      if (recoveryPeriodType != null)
        'recovery_period_type': recoveryPeriodType,
    });
  }

  TrainingCyclesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<int>? periodsTotal,
    Value<int>? daysPerPeriod,
    Value<int>? recoveryPeriod,
    Value<int>? status,
    Value<int?>? gender,
    Value<DateTime>? createdDate,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? muscleGroupPriorities,
    Value<String?>? templateName,
    Value<String?>? notes,
    Value<int?>? recoveryPeriodType,
  }) {
    return TrainingCyclesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      periodsTotal: periodsTotal ?? this.periodsTotal,
      daysPerPeriod: daysPerPeriod ?? this.daysPerPeriod,
      recoveryPeriod: recoveryPeriod ?? this.recoveryPeriod,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      createdDate: createdDate ?? this.createdDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      muscleGroupPriorities:
          muscleGroupPriorities ?? this.muscleGroupPriorities,
      templateName: templateName ?? this.templateName,
      notes: notes ?? this.notes,
      recoveryPeriodType: recoveryPeriodType ?? this.recoveryPeriodType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (periodsTotal.present) {
      map['periods_total'] = Variable<int>(periodsTotal.value);
    }
    if (daysPerPeriod.present) {
      map['days_per_period'] = Variable<int>(daysPerPeriod.value);
    }
    if (recoveryPeriod.present) {
      map['recovery_period'] = Variable<int>(recoveryPeriod.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(gender.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<DateTime>(createdDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (muscleGroupPriorities.present) {
      map['muscle_group_priorities'] = Variable<String>(
        muscleGroupPriorities.value,
      );
    }
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recoveryPeriodType.present) {
      map['recovery_period_type'] = Variable<int>(recoveryPeriodType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingCyclesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('periodsTotal: $periodsTotal, ')
          ..write('daysPerPeriod: $daysPerPeriod, ')
          ..write('recoveryPeriod: $recoveryPeriod, ')
          ..write('status: $status, ')
          ..write('gender: $gender, ')
          ..write('createdDate: $createdDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('muscleGroupPriorities: $muscleGroupPriorities, ')
          ..write('templateName: $templateName, ')
          ..write('notes: $notes, ')
          ..write('recoveryPeriodType: $recoveryPeriodType')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _trainingCycleUuidMeta = const VerificationMeta(
    'trainingCycleUuid',
  );
  @override
  late final GeneratedColumn<String> trainingCycleUuid =
      GeneratedColumn<String>(
        'training_cycle_uuid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES training_cycles (uuid)',
        ),
      );
  static const VerificationMeta _periodNumberMeta = const VerificationMeta(
    'periodNumber',
  );
  @override
  late final GeneratedColumn<int> periodNumber = GeneratedColumn<int>(
    'period_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNameMeta = const VerificationMeta(
    'dayName',
  );
  @override
  late final GeneratedColumn<String> dayName = GeneratedColumn<String>(
    'day_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    trainingCycleUuid,
    periodNumber,
    dayNumber,
    dayName,
    label,
    status,
    scheduledDate,
    completedDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('training_cycle_uuid')) {
      context.handle(
        _trainingCycleUuidMeta,
        trainingCycleUuid.isAcceptableOrUnknown(
          data['training_cycle_uuid']!,
          _trainingCycleUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trainingCycleUuidMeta);
    }
    if (data.containsKey('period_number')) {
      context.handle(
        _periodNumberMeta,
        periodNumber.isAcceptableOrUnknown(
          data['period_number']!,
          _periodNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodNumberMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('day_name')) {
      context.handle(
        _dayNameMeta,
        dayName.isAcceptableOrUnknown(data['day_name']!, _dayNameMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      trainingCycleUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_cycle_uuid'],
      )!,
      periodNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_number'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      dayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_name'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final String uuid;
  final String trainingCycleUuid;
  final int periodNumber;
  final int dayNumber;
  final String? dayName;
  final String? label;
  final int status;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? notes;
  const Workout({
    required this.id,
    required this.uuid,
    required this.trainingCycleUuid,
    required this.periodNumber,
    required this.dayNumber,
    this.dayName,
    this.label,
    required this.status,
    this.scheduledDate,
    this.completedDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['training_cycle_uuid'] = Variable<String>(trainingCycleUuid);
    map['period_number'] = Variable<int>(periodNumber);
    map['day_number'] = Variable<int>(dayNumber);
    if (!nullToAbsent || dayName != null) {
      map['day_name'] = Variable<String>(dayName);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      trainingCycleUuid: Value(trainingCycleUuid),
      periodNumber: Value(periodNumber),
      dayNumber: Value(dayNumber),
      dayName: dayName == null && nullToAbsent
          ? const Value.absent()
          : Value(dayName),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      status: Value(status),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      trainingCycleUuid: serializer.fromJson<String>(json['trainingCycleUuid']),
      periodNumber: serializer.fromJson<int>(json['periodNumber']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      dayName: serializer.fromJson<String?>(json['dayName']),
      label: serializer.fromJson<String?>(json['label']),
      status: serializer.fromJson<int>(json['status']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'trainingCycleUuid': serializer.toJson<String>(trainingCycleUuid),
      'periodNumber': serializer.toJson<int>(periodNumber),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'dayName': serializer.toJson<String?>(dayName),
      'label': serializer.toJson<String?>(label),
      'status': serializer.toJson<int>(status),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Workout copyWith({
    int? id,
    String? uuid,
    String? trainingCycleUuid,
    int? periodNumber,
    int? dayNumber,
    Value<String?> dayName = const Value.absent(),
    Value<String?> label = const Value.absent(),
    int? status,
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<DateTime?> completedDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    trainingCycleUuid: trainingCycleUuid ?? this.trainingCycleUuid,
    periodNumber: periodNumber ?? this.periodNumber,
    dayNumber: dayNumber ?? this.dayNumber,
    dayName: dayName.present ? dayName.value : this.dayName,
    label: label.present ? label.value : this.label,
    status: status ?? this.status,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
    completedDate: completedDate.present
        ? completedDate.value
        : this.completedDate,
    notes: notes.present ? notes.value : this.notes,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      trainingCycleUuid: data.trainingCycleUuid.present
          ? data.trainingCycleUuid.value
          : this.trainingCycleUuid,
      periodNumber: data.periodNumber.present
          ? data.periodNumber.value
          : this.periodNumber,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      dayName: data.dayName.present ? data.dayName.value : this.dayName,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('dayName: $dayName, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    trainingCycleUuid,
    periodNumber,
    dayNumber,
    dayName,
    label,
    status,
    scheduledDate,
    completedDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.trainingCycleUuid == this.trainingCycleUuid &&
          other.periodNumber == this.periodNumber &&
          other.dayNumber == this.dayNumber &&
          other.dayName == this.dayName &&
          other.label == this.label &&
          other.status == this.status &&
          other.scheduledDate == this.scheduledDate &&
          other.completedDate == this.completedDate &&
          other.notes == this.notes);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> trainingCycleUuid;
  final Value<int> periodNumber;
  final Value<int> dayNumber;
  final Value<String?> dayName;
  final Value<String?> label;
  final Value<int> status;
  final Value<DateTime?> scheduledDate;
  final Value<DateTime?> completedDate;
  final Value<String?> notes;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.trainingCycleUuid = const Value.absent(),
    this.periodNumber = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.dayName = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String trainingCycleUuid,
    required int periodNumber,
    required int dayNumber,
    this.dayName = const Value.absent(),
    this.label = const Value.absent(),
    required int status,
    this.scheduledDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
  }) : uuid = Value(uuid),
       trainingCycleUuid = Value(trainingCycleUuid),
       periodNumber = Value(periodNumber),
       dayNumber = Value(dayNumber),
       status = Value(status);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? trainingCycleUuid,
    Expression<int>? periodNumber,
    Expression<int>? dayNumber,
    Expression<String>? dayName,
    Expression<String>? label,
    Expression<int>? status,
    Expression<DateTime>? scheduledDate,
    Expression<DateTime>? completedDate,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (trainingCycleUuid != null) 'training_cycle_uuid': trainingCycleUuid,
      if (periodNumber != null) 'period_number': periodNumber,
      if (dayNumber != null) 'day_number': dayNumber,
      if (dayName != null) 'day_name': dayName,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? trainingCycleUuid,
    Value<int>? periodNumber,
    Value<int>? dayNumber,
    Value<String?>? dayName,
    Value<String?>? label,
    Value<int>? status,
    Value<DateTime?>? scheduledDate,
    Value<DateTime?>? completedDate,
    Value<String?>? notes,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      trainingCycleUuid: trainingCycleUuid ?? this.trainingCycleUuid,
      periodNumber: periodNumber ?? this.periodNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      label: label ?? this.label,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (trainingCycleUuid.present) {
      map['training_cycle_uuid'] = Variable<String>(trainingCycleUuid.value);
    }
    if (periodNumber.present) {
      map['period_number'] = Variable<int>(periodNumber.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (dayName.present) {
      map['day_name'] = Variable<String>(dayName.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('dayName: $dayName, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _workoutUuidMeta = const VerificationMeta(
    'workoutUuid',
  );
  @override
  late final GeneratedColumn<String> workoutUuid = GeneratedColumn<String>(
    'workout_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (uuid)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<int> muscleGroup = GeneratedColumn<int>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMuscleGroupMeta =
      const VerificationMeta('secondaryMuscleGroup');
  @override
  late final GeneratedColumn<int> secondaryMuscleGroup = GeneratedColumn<int>(
    'secondary_muscle_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentTypeMeta = const VerificationMeta(
    'equipmentType',
  );
  @override
  late final GeneratedColumn<int> equipmentType = GeneratedColumn<int>(
    'equipment_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyweightMeta = const VerificationMeta(
    'bodyweight',
  );
  @override
  late final GeneratedColumn<double> bodyweight = GeneratedColumn<double>(
    'bodyweight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPerformedMeta = const VerificationMeta(
    'lastPerformed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPerformed =
      GeneratedColumn<DateTime>(
        'last_performed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isNotePinnedMeta = const VerificationMeta(
    'isNotePinned',
  );
  @override
  late final GeneratedColumn<bool> isNotePinned = GeneratedColumn<bool>(
    'is_note_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_note_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    workoutUuid,
    name,
    muscleGroup,
    secondaryMuscleGroup,
    equipmentType,
    orderIndex,
    bodyweight,
    notes,
    lastPerformed,
    videoUrl,
    isNotePinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('workout_uuid')) {
      context.handle(
        _workoutUuidMeta,
        workoutUuid.isAcceptableOrUnknown(
          data['workout_uuid']!,
          _workoutUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutUuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('secondary_muscle_group')) {
      context.handle(
        _secondaryMuscleGroupMeta,
        secondaryMuscleGroup.isAcceptableOrUnknown(
          data['secondary_muscle_group']!,
          _secondaryMuscleGroupMeta,
        ),
      );
    }
    if (data.containsKey('equipment_type')) {
      context.handle(
        _equipmentTypeMeta,
        equipmentType.isAcceptableOrUnknown(
          data['equipment_type']!,
          _equipmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentTypeMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('bodyweight')) {
      context.handle(
        _bodyweightMeta,
        bodyweight.isAcceptableOrUnknown(data['bodyweight']!, _bodyweightMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('last_performed')) {
      context.handle(
        _lastPerformedMeta,
        lastPerformed.isAcceptableOrUnknown(
          data['last_performed']!,
          _lastPerformedMeta,
        ),
      );
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('is_note_pinned')) {
      context.handle(
        _isNotePinnedMeta,
        isNotePinned.isAcceptableOrUnknown(
          data['is_note_pinned']!,
          _isNotePinnedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      workoutUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_group'],
      )!,
      secondaryMuscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}secondary_muscle_group'],
      ),
      equipmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipment_type'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      bodyweight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bodyweight'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      lastPerformed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_performed'],
      ),
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      isNotePinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_note_pinned'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String uuid;
  final String workoutUuid;
  final String name;
  final int muscleGroup;
  final int? secondaryMuscleGroup;
  final int equipmentType;
  final int orderIndex;
  final double? bodyweight;
  final String? notes;
  final DateTime? lastPerformed;
  final String? videoUrl;
  final bool isNotePinned;
  const Exercise({
    required this.id,
    required this.uuid,
    required this.workoutUuid,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    required this.orderIndex,
    this.bodyweight,
    this.notes,
    this.lastPerformed,
    this.videoUrl,
    required this.isNotePinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['workout_uuid'] = Variable<String>(workoutUuid);
    map['name'] = Variable<String>(name);
    map['muscle_group'] = Variable<int>(muscleGroup);
    if (!nullToAbsent || secondaryMuscleGroup != null) {
      map['secondary_muscle_group'] = Variable<int>(secondaryMuscleGroup);
    }
    map['equipment_type'] = Variable<int>(equipmentType);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || bodyweight != null) {
      map['bodyweight'] = Variable<double>(bodyweight);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || lastPerformed != null) {
      map['last_performed'] = Variable<DateTime>(lastPerformed);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    map['is_note_pinned'] = Variable<bool>(isNotePinned);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      workoutUuid: Value(workoutUuid),
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      secondaryMuscleGroup: secondaryMuscleGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscleGroup),
      equipmentType: Value(equipmentType),
      orderIndex: Value(orderIndex),
      bodyweight: bodyweight == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyweight),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      lastPerformed: lastPerformed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPerformed),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      isNotePinned: Value(isNotePinned),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      workoutUuid: serializer.fromJson<String>(json['workoutUuid']),
      name: serializer.fromJson<String>(json['name']),
      muscleGroup: serializer.fromJson<int>(json['muscleGroup']),
      secondaryMuscleGroup: serializer.fromJson<int?>(
        json['secondaryMuscleGroup'],
      ),
      equipmentType: serializer.fromJson<int>(json['equipmentType']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      bodyweight: serializer.fromJson<double?>(json['bodyweight']),
      notes: serializer.fromJson<String?>(json['notes']),
      lastPerformed: serializer.fromJson<DateTime?>(json['lastPerformed']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      isNotePinned: serializer.fromJson<bool>(json['isNotePinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'workoutUuid': serializer.toJson<String>(workoutUuid),
      'name': serializer.toJson<String>(name),
      'muscleGroup': serializer.toJson<int>(muscleGroup),
      'secondaryMuscleGroup': serializer.toJson<int?>(secondaryMuscleGroup),
      'equipmentType': serializer.toJson<int>(equipmentType),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'bodyweight': serializer.toJson<double?>(bodyweight),
      'notes': serializer.toJson<String?>(notes),
      'lastPerformed': serializer.toJson<DateTime?>(lastPerformed),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'isNotePinned': serializer.toJson<bool>(isNotePinned),
    };
  }

  Exercise copyWith({
    int? id,
    String? uuid,
    String? workoutUuid,
    String? name,
    int? muscleGroup,
    Value<int?> secondaryMuscleGroup = const Value.absent(),
    int? equipmentType,
    int? orderIndex,
    Value<double?> bodyweight = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> lastPerformed = const Value.absent(),
    Value<String?> videoUrl = const Value.absent(),
    bool? isNotePinned,
  }) => Exercise(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    workoutUuid: workoutUuid ?? this.workoutUuid,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    secondaryMuscleGroup: secondaryMuscleGroup.present
        ? secondaryMuscleGroup.value
        : this.secondaryMuscleGroup,
    equipmentType: equipmentType ?? this.equipmentType,
    orderIndex: orderIndex ?? this.orderIndex,
    bodyweight: bodyweight.present ? bodyweight.value : this.bodyweight,
    notes: notes.present ? notes.value : this.notes,
    lastPerformed: lastPerformed.present
        ? lastPerformed.value
        : this.lastPerformed,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    isNotePinned: isNotePinned ?? this.isNotePinned,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      workoutUuid: data.workoutUuid.present
          ? data.workoutUuid.value
          : this.workoutUuid,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      secondaryMuscleGroup: data.secondaryMuscleGroup.present
          ? data.secondaryMuscleGroup.value
          : this.secondaryMuscleGroup,
      equipmentType: data.equipmentType.present
          ? data.equipmentType.value
          : this.equipmentType,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      bodyweight: data.bodyweight.present
          ? data.bodyweight.value
          : this.bodyweight,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastPerformed: data.lastPerformed.present
          ? data.lastPerformed.value
          : this.lastPerformed,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      isNotePinned: data.isNotePinned.present
          ? data.isNotePinned.value
          : this.isNotePinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workoutUuid: $workoutUuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('notes: $notes, ')
          ..write('lastPerformed: $lastPerformed, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('isNotePinned: $isNotePinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    workoutUuid,
    name,
    muscleGroup,
    secondaryMuscleGroup,
    equipmentType,
    orderIndex,
    bodyweight,
    notes,
    lastPerformed,
    videoUrl,
    isNotePinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.workoutUuid == this.workoutUuid &&
          other.name == this.name &&
          other.muscleGroup == this.muscleGroup &&
          other.secondaryMuscleGroup == this.secondaryMuscleGroup &&
          other.equipmentType == this.equipmentType &&
          other.orderIndex == this.orderIndex &&
          other.bodyweight == this.bodyweight &&
          other.notes == this.notes &&
          other.lastPerformed == this.lastPerformed &&
          other.videoUrl == this.videoUrl &&
          other.isNotePinned == this.isNotePinned);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> workoutUuid;
  final Value<String> name;
  final Value<int> muscleGroup;
  final Value<int?> secondaryMuscleGroup;
  final Value<int> equipmentType;
  final Value<int> orderIndex;
  final Value<double?> bodyweight;
  final Value<String?> notes;
  final Value<DateTime?> lastPerformed;
  final Value<String?> videoUrl;
  final Value<bool> isNotePinned;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.workoutUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.secondaryMuscleGroup = const Value.absent(),
    this.equipmentType = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.bodyweight = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastPerformed = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.isNotePinned = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String workoutUuid,
    required String name,
    required int muscleGroup,
    this.secondaryMuscleGroup = const Value.absent(),
    required int equipmentType,
    required int orderIndex,
    this.bodyweight = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastPerformed = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.isNotePinned = const Value.absent(),
  }) : uuid = Value(uuid),
       workoutUuid = Value(workoutUuid),
       name = Value(name),
       muscleGroup = Value(muscleGroup),
       equipmentType = Value(equipmentType),
       orderIndex = Value(orderIndex);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? workoutUuid,
    Expression<String>? name,
    Expression<int>? muscleGroup,
    Expression<int>? secondaryMuscleGroup,
    Expression<int>? equipmentType,
    Expression<int>? orderIndex,
    Expression<double>? bodyweight,
    Expression<String>? notes,
    Expression<DateTime>? lastPerformed,
    Expression<String>? videoUrl,
    Expression<bool>? isNotePinned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (workoutUuid != null) 'workout_uuid': workoutUuid,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (secondaryMuscleGroup != null)
        'secondary_muscle_group': secondaryMuscleGroup,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (orderIndex != null) 'order_index': orderIndex,
      if (bodyweight != null) 'bodyweight': bodyweight,
      if (notes != null) 'notes': notes,
      if (lastPerformed != null) 'last_performed': lastPerformed,
      if (videoUrl != null) 'video_url': videoUrl,
      if (isNotePinned != null) 'is_note_pinned': isNotePinned,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? workoutUuid,
    Value<String>? name,
    Value<int>? muscleGroup,
    Value<int?>? secondaryMuscleGroup,
    Value<int>? equipmentType,
    Value<int>? orderIndex,
    Value<double?>? bodyweight,
    Value<String?>? notes,
    Value<DateTime?>? lastPerformed,
    Value<String?>? videoUrl,
    Value<bool>? isNotePinned,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      workoutUuid: workoutUuid ?? this.workoutUuid,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      orderIndex: orderIndex ?? this.orderIndex,
      bodyweight: bodyweight ?? this.bodyweight,
      notes: notes ?? this.notes,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      videoUrl: videoUrl ?? this.videoUrl,
      isNotePinned: isNotePinned ?? this.isNotePinned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (workoutUuid.present) {
      map['workout_uuid'] = Variable<String>(workoutUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<int>(muscleGroup.value);
    }
    if (secondaryMuscleGroup.present) {
      map['secondary_muscle_group'] = Variable<int>(secondaryMuscleGroup.value);
    }
    if (equipmentType.present) {
      map['equipment_type'] = Variable<int>(equipmentType.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (bodyweight.present) {
      map['bodyweight'] = Variable<double>(bodyweight.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lastPerformed.present) {
      map['last_performed'] = Variable<DateTime>(lastPerformed.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (isNotePinned.present) {
      map['is_note_pinned'] = Variable<bool>(isNotePinned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workoutUuid: $workoutUuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('notes: $notes, ')
          ..write('lastPerformed: $lastPerformed, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('isNotePinned: $isNotePinned')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets
    with TableInfo<$ExerciseSetsTable, ExerciseSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _exerciseUuidMeta = const VerificationMeta(
    'exerciseUuid',
  );
  @override
  late final GeneratedColumn<String> exerciseUuid = GeneratedColumn<String>(
    'exercise_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (uuid)',
    ),
  );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<String> reps = GeneratedColumn<String>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setTypeMeta = const VerificationMeta(
    'setType',
  );
  @override
  late final GeneratedColumn<int> setType = GeneratedColumn<int>(
    'set_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLoggedMeta = const VerificationMeta(
    'isLogged',
  );
  @override
  late final GeneratedColumn<bool> isLogged = GeneratedColumn<bool>(
    'is_logged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_logged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSkippedMeta = const VerificationMeta(
    'isSkipped',
  );
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
    'is_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    exerciseUuid,
    setNumber,
    weight,
    reps,
    setType,
    isLogged,
    notes,
    isSkipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('exercise_uuid')) {
      context.handle(
        _exerciseUuidMeta,
        exerciseUuid.isAcceptableOrUnknown(
          data['exercise_uuid']!,
          _exerciseUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseUuidMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('set_type')) {
      context.handle(
        _setTypeMeta,
        setType.isAcceptableOrUnknown(data['set_type']!, _setTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_setTypeMeta);
    }
    if (data.containsKey('is_logged')) {
      context.handle(
        _isLoggedMeta,
        isLogged.isAcceptableOrUnknown(data['is_logged']!, _isLoggedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_skipped')) {
      context.handle(
        _isSkippedMeta,
        isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      exerciseUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_uuid'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reps'],
      )!,
      setType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_type'],
      )!,
      isLogged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_logged'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skipped'],
      )!,
    );
  }

  @override
  $ExerciseSetsTable createAlias(String alias) {
    return $ExerciseSetsTable(attachedDatabase, alias);
  }
}

class ExerciseSet extends DataClass implements Insertable<ExerciseSet> {
  final int id;
  final String uuid;
  final String exerciseUuid;
  final int setNumber;
  final double? weight;
  final String reps;
  final int setType;
  final bool isLogged;
  final String? notes;
  final bool isSkipped;
  const ExerciseSet({
    required this.id,
    required this.uuid,
    required this.exerciseUuid,
    required this.setNumber,
    this.weight,
    required this.reps,
    required this.setType,
    required this.isLogged,
    this.notes,
    required this.isSkipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['exercise_uuid'] = Variable<String>(exerciseUuid);
    map['set_number'] = Variable<int>(setNumber);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    map['reps'] = Variable<String>(reps);
    map['set_type'] = Variable<int>(setType);
    map['is_logged'] = Variable<bool>(isLogged);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_skipped'] = Variable<bool>(isSkipped);
    return map;
  }

  ExerciseSetsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSetsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      exerciseUuid: Value(exerciseUuid),
      setNumber: Value(setNumber),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      reps: Value(reps),
      setType: Value(setType),
      isLogged: Value(isLogged),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isSkipped: Value(isSkipped),
    );
  }

  factory ExerciseSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSet(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      exerciseUuid: serializer.fromJson<String>(json['exerciseUuid']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      weight: serializer.fromJson<double?>(json['weight']),
      reps: serializer.fromJson<String>(json['reps']),
      setType: serializer.fromJson<int>(json['setType']),
      isLogged: serializer.fromJson<bool>(json['isLogged']),
      notes: serializer.fromJson<String?>(json['notes']),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'exerciseUuid': serializer.toJson<String>(exerciseUuid),
      'setNumber': serializer.toJson<int>(setNumber),
      'weight': serializer.toJson<double?>(weight),
      'reps': serializer.toJson<String>(reps),
      'setType': serializer.toJson<int>(setType),
      'isLogged': serializer.toJson<bool>(isLogged),
      'notes': serializer.toJson<String?>(notes),
      'isSkipped': serializer.toJson<bool>(isSkipped),
    };
  }

  ExerciseSet copyWith({
    int? id,
    String? uuid,
    String? exerciseUuid,
    int? setNumber,
    Value<double?> weight = const Value.absent(),
    String? reps,
    int? setType,
    bool? isLogged,
    Value<String?> notes = const Value.absent(),
    bool? isSkipped,
  }) => ExerciseSet(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    exerciseUuid: exerciseUuid ?? this.exerciseUuid,
    setNumber: setNumber ?? this.setNumber,
    weight: weight.present ? weight.value : this.weight,
    reps: reps ?? this.reps,
    setType: setType ?? this.setType,
    isLogged: isLogged ?? this.isLogged,
    notes: notes.present ? notes.value : this.notes,
    isSkipped: isSkipped ?? this.isSkipped,
  );
  ExerciseSet copyWithCompanion(ExerciseSetsCompanion data) {
    return ExerciseSet(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      exerciseUuid: data.exerciseUuid.present
          ? data.exerciseUuid.value
          : this.exerciseUuid,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      setType: data.setType.present ? data.setType.value : this.setType,
      isLogged: data.isLogged.present ? data.isLogged.value : this.isLogged,
      notes: data.notes.present ? data.notes.value : this.notes,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSet(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseUuid: $exerciseUuid, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('setType: $setType, ')
          ..write('isLogged: $isLogged, ')
          ..write('notes: $notes, ')
          ..write('isSkipped: $isSkipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    exerciseUuid,
    setNumber,
    weight,
    reps,
    setType,
    isLogged,
    notes,
    isSkipped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSet &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.exerciseUuid == this.exerciseUuid &&
          other.setNumber == this.setNumber &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.setType == this.setType &&
          other.isLogged == this.isLogged &&
          other.notes == this.notes &&
          other.isSkipped == this.isSkipped);
}

class ExerciseSetsCompanion extends UpdateCompanion<ExerciseSet> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> exerciseUuid;
  final Value<int> setNumber;
  final Value<double?> weight;
  final Value<String> reps;
  final Value<int> setType;
  final Value<bool> isLogged;
  final Value<String?> notes;
  final Value<bool> isSkipped;
  const ExerciseSetsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.exerciseUuid = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.setType = const Value.absent(),
    this.isLogged = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSkipped = const Value.absent(),
  });
  ExerciseSetsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String exerciseUuid,
    required int setNumber,
    this.weight = const Value.absent(),
    required String reps,
    required int setType,
    this.isLogged = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSkipped = const Value.absent(),
  }) : uuid = Value(uuid),
       exerciseUuid = Value(exerciseUuid),
       setNumber = Value(setNumber),
       reps = Value(reps),
       setType = Value(setType);
  static Insertable<ExerciseSet> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? exerciseUuid,
    Expression<int>? setNumber,
    Expression<double>? weight,
    Expression<String>? reps,
    Expression<int>? setType,
    Expression<bool>? isLogged,
    Expression<String>? notes,
    Expression<bool>? isSkipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (exerciseUuid != null) 'exercise_uuid': exerciseUuid,
      if (setNumber != null) 'set_number': setNumber,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (setType != null) 'set_type': setType,
      if (isLogged != null) 'is_logged': isLogged,
      if (notes != null) 'notes': notes,
      if (isSkipped != null) 'is_skipped': isSkipped,
    });
  }

  ExerciseSetsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? exerciseUuid,
    Value<int>? setNumber,
    Value<double?>? weight,
    Value<String>? reps,
    Value<int>? setType,
    Value<bool>? isLogged,
    Value<String?>? notes,
    Value<bool>? isSkipped,
  }) {
    return ExerciseSetsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      exerciseUuid: exerciseUuid ?? this.exerciseUuid,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setType: setType ?? this.setType,
      isLogged: isLogged ?? this.isLogged,
      notes: notes ?? this.notes,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (exerciseUuid.present) {
      map['exercise_uuid'] = Variable<String>(exerciseUuid.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<String>(reps.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<int>(setType.value);
    }
    if (isLogged.present) {
      map['is_logged'] = Variable<bool>(isLogged.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSetsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseUuid: $exerciseUuid, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('setType: $setType, ')
          ..write('isLogged: $isLogged, ')
          ..write('notes: $notes, ')
          ..write('isSkipped: $isSkipped')
          ..write(')'))
        .toString();
  }
}

class $ExerciseFeedbacksTable extends ExerciseFeedbacks
    with TableInfo<$ExerciseFeedbacksTable, ExerciseFeedback> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseFeedbacksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _exerciseUuidMeta = const VerificationMeta(
    'exerciseUuid',
  );
  @override
  late final GeneratedColumn<String> exerciseUuid = GeneratedColumn<String>(
    'exercise_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES exercises (uuid)',
    ),
  );
  static const VerificationMeta _jointPainMeta = const VerificationMeta(
    'jointPain',
  );
  @override
  late final GeneratedColumn<int> jointPain = GeneratedColumn<int>(
    'joint_pain',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _musclePumpMeta = const VerificationMeta(
    'musclePump',
  );
  @override
  late final GeneratedColumn<int> musclePump = GeneratedColumn<int>(
    'muscle_pump',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workloadMeta = const VerificationMeta(
    'workload',
  );
  @override
  late final GeneratedColumn<int> workload = GeneratedColumn<int>(
    'workload',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sorenessMeta = const VerificationMeta(
    'soreness',
  );
  @override
  late final GeneratedColumn<int> soreness = GeneratedColumn<int>(
    'soreness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleGroupSorenessMeta =
      const VerificationMeta('muscleGroupSoreness');
  @override
  late final GeneratedColumn<String> muscleGroupSoreness =
      GeneratedColumn<String>(
        'muscle_group_soreness',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseUuid,
    jointPain,
    musclePump,
    workload,
    soreness,
    muscleGroupSoreness,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_feedbacks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseFeedback> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_uuid')) {
      context.handle(
        _exerciseUuidMeta,
        exerciseUuid.isAcceptableOrUnknown(
          data['exercise_uuid']!,
          _exerciseUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseUuidMeta);
    }
    if (data.containsKey('joint_pain')) {
      context.handle(
        _jointPainMeta,
        jointPain.isAcceptableOrUnknown(data['joint_pain']!, _jointPainMeta),
      );
    }
    if (data.containsKey('muscle_pump')) {
      context.handle(
        _musclePumpMeta,
        musclePump.isAcceptableOrUnknown(data['muscle_pump']!, _musclePumpMeta),
      );
    }
    if (data.containsKey('workload')) {
      context.handle(
        _workloadMeta,
        workload.isAcceptableOrUnknown(data['workload']!, _workloadMeta),
      );
    }
    if (data.containsKey('soreness')) {
      context.handle(
        _sorenessMeta,
        soreness.isAcceptableOrUnknown(data['soreness']!, _sorenessMeta),
      );
    }
    if (data.containsKey('muscle_group_soreness')) {
      context.handle(
        _muscleGroupSorenessMeta,
        muscleGroupSoreness.isAcceptableOrUnknown(
          data['muscle_group_soreness']!,
          _muscleGroupSorenessMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseFeedback map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseFeedback(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_uuid'],
      )!,
      jointPain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}joint_pain'],
      ),
      musclePump: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_pump'],
      ),
      workload: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workload'],
      ),
      soreness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}soreness'],
      ),
      muscleGroupSoreness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group_soreness'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      ),
    );
  }

  @override
  $ExerciseFeedbacksTable createAlias(String alias) {
    return $ExerciseFeedbacksTable(attachedDatabase, alias);
  }
}

class ExerciseFeedback extends DataClass
    implements Insertable<ExerciseFeedback> {
  final int id;
  final String exerciseUuid;
  final int? jointPain;
  final int? musclePump;
  final int? workload;
  final int? soreness;
  final String? muscleGroupSoreness;
  final DateTime? timestamp;
  const ExerciseFeedback({
    required this.id,
    required this.exerciseUuid,
    this.jointPain,
    this.musclePump,
    this.workload,
    this.soreness,
    this.muscleGroupSoreness,
    this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_uuid'] = Variable<String>(exerciseUuid);
    if (!nullToAbsent || jointPain != null) {
      map['joint_pain'] = Variable<int>(jointPain);
    }
    if (!nullToAbsent || musclePump != null) {
      map['muscle_pump'] = Variable<int>(musclePump);
    }
    if (!nullToAbsent || workload != null) {
      map['workload'] = Variable<int>(workload);
    }
    if (!nullToAbsent || soreness != null) {
      map['soreness'] = Variable<int>(soreness);
    }
    if (!nullToAbsent || muscleGroupSoreness != null) {
      map['muscle_group_soreness'] = Variable<String>(muscleGroupSoreness);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    return map;
  }

  ExerciseFeedbacksCompanion toCompanion(bool nullToAbsent) {
    return ExerciseFeedbacksCompanion(
      id: Value(id),
      exerciseUuid: Value(exerciseUuid),
      jointPain: jointPain == null && nullToAbsent
          ? const Value.absent()
          : Value(jointPain),
      musclePump: musclePump == null && nullToAbsent
          ? const Value.absent()
          : Value(musclePump),
      workload: workload == null && nullToAbsent
          ? const Value.absent()
          : Value(workload),
      soreness: soreness == null && nullToAbsent
          ? const Value.absent()
          : Value(soreness),
      muscleGroupSoreness: muscleGroupSoreness == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroupSoreness),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
    );
  }

  factory ExerciseFeedback.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseFeedback(
      id: serializer.fromJson<int>(json['id']),
      exerciseUuid: serializer.fromJson<String>(json['exerciseUuid']),
      jointPain: serializer.fromJson<int?>(json['jointPain']),
      musclePump: serializer.fromJson<int?>(json['musclePump']),
      workload: serializer.fromJson<int?>(json['workload']),
      soreness: serializer.fromJson<int?>(json['soreness']),
      muscleGroupSoreness: serializer.fromJson<String?>(
        json['muscleGroupSoreness'],
      ),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseUuid': serializer.toJson<String>(exerciseUuid),
      'jointPain': serializer.toJson<int?>(jointPain),
      'musclePump': serializer.toJson<int?>(musclePump),
      'workload': serializer.toJson<int?>(workload),
      'soreness': serializer.toJson<int?>(soreness),
      'muscleGroupSoreness': serializer.toJson<String?>(muscleGroupSoreness),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
    };
  }

  ExerciseFeedback copyWith({
    int? id,
    String? exerciseUuid,
    Value<int?> jointPain = const Value.absent(),
    Value<int?> musclePump = const Value.absent(),
    Value<int?> workload = const Value.absent(),
    Value<int?> soreness = const Value.absent(),
    Value<String?> muscleGroupSoreness = const Value.absent(),
    Value<DateTime?> timestamp = const Value.absent(),
  }) => ExerciseFeedback(
    id: id ?? this.id,
    exerciseUuid: exerciseUuid ?? this.exerciseUuid,
    jointPain: jointPain.present ? jointPain.value : this.jointPain,
    musclePump: musclePump.present ? musclePump.value : this.musclePump,
    workload: workload.present ? workload.value : this.workload,
    soreness: soreness.present ? soreness.value : this.soreness,
    muscleGroupSoreness: muscleGroupSoreness.present
        ? muscleGroupSoreness.value
        : this.muscleGroupSoreness,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
  );
  ExerciseFeedback copyWithCompanion(ExerciseFeedbacksCompanion data) {
    return ExerciseFeedback(
      id: data.id.present ? data.id.value : this.id,
      exerciseUuid: data.exerciseUuid.present
          ? data.exerciseUuid.value
          : this.exerciseUuid,
      jointPain: data.jointPain.present ? data.jointPain.value : this.jointPain,
      musclePump: data.musclePump.present
          ? data.musclePump.value
          : this.musclePump,
      workload: data.workload.present ? data.workload.value : this.workload,
      soreness: data.soreness.present ? data.soreness.value : this.soreness,
      muscleGroupSoreness: data.muscleGroupSoreness.present
          ? data.muscleGroupSoreness.value
          : this.muscleGroupSoreness,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseFeedback(')
          ..write('id: $id, ')
          ..write('exerciseUuid: $exerciseUuid, ')
          ..write('jointPain: $jointPain, ')
          ..write('musclePump: $musclePump, ')
          ..write('workload: $workload, ')
          ..write('soreness: $soreness, ')
          ..write('muscleGroupSoreness: $muscleGroupSoreness, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseUuid,
    jointPain,
    musclePump,
    workload,
    soreness,
    muscleGroupSoreness,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseFeedback &&
          other.id == this.id &&
          other.exerciseUuid == this.exerciseUuid &&
          other.jointPain == this.jointPain &&
          other.musclePump == this.musclePump &&
          other.workload == this.workload &&
          other.soreness == this.soreness &&
          other.muscleGroupSoreness == this.muscleGroupSoreness &&
          other.timestamp == this.timestamp);
}

class ExerciseFeedbacksCompanion extends UpdateCompanion<ExerciseFeedback> {
  final Value<int> id;
  final Value<String> exerciseUuid;
  final Value<int?> jointPain;
  final Value<int?> musclePump;
  final Value<int?> workload;
  final Value<int?> soreness;
  final Value<String?> muscleGroupSoreness;
  final Value<DateTime?> timestamp;
  const ExerciseFeedbacksCompanion({
    this.id = const Value.absent(),
    this.exerciseUuid = const Value.absent(),
    this.jointPain = const Value.absent(),
    this.musclePump = const Value.absent(),
    this.workload = const Value.absent(),
    this.soreness = const Value.absent(),
    this.muscleGroupSoreness = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ExerciseFeedbacksCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseUuid,
    this.jointPain = const Value.absent(),
    this.musclePump = const Value.absent(),
    this.workload = const Value.absent(),
    this.soreness = const Value.absent(),
    this.muscleGroupSoreness = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : exerciseUuid = Value(exerciseUuid);
  static Insertable<ExerciseFeedback> custom({
    Expression<int>? id,
    Expression<String>? exerciseUuid,
    Expression<int>? jointPain,
    Expression<int>? musclePump,
    Expression<int>? workload,
    Expression<int>? soreness,
    Expression<String>? muscleGroupSoreness,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseUuid != null) 'exercise_uuid': exerciseUuid,
      if (jointPain != null) 'joint_pain': jointPain,
      if (musclePump != null) 'muscle_pump': musclePump,
      if (workload != null) 'workload': workload,
      if (soreness != null) 'soreness': soreness,
      if (muscleGroupSoreness != null)
        'muscle_group_soreness': muscleGroupSoreness,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ExerciseFeedbacksCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseUuid,
    Value<int?>? jointPain,
    Value<int?>? musclePump,
    Value<int?>? workload,
    Value<int?>? soreness,
    Value<String?>? muscleGroupSoreness,
    Value<DateTime?>? timestamp,
  }) {
    return ExerciseFeedbacksCompanion(
      id: id ?? this.id,
      exerciseUuid: exerciseUuid ?? this.exerciseUuid,
      jointPain: jointPain ?? this.jointPain,
      musclePump: musclePump ?? this.musclePump,
      workload: workload ?? this.workload,
      soreness: soreness ?? this.soreness,
      muscleGroupSoreness: muscleGroupSoreness ?? this.muscleGroupSoreness,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseUuid.present) {
      map['exercise_uuid'] = Variable<String>(exerciseUuid.value);
    }
    if (jointPain.present) {
      map['joint_pain'] = Variable<int>(jointPain.value);
    }
    if (musclePump.present) {
      map['muscle_pump'] = Variable<int>(musclePump.value);
    }
    if (workload.present) {
      map['workload'] = Variable<int>(workload.value);
    }
    if (soreness.present) {
      map['soreness'] = Variable<int>(soreness.value);
    }
    if (muscleGroupSoreness.present) {
      map['muscle_group_soreness'] = Variable<String>(
        muscleGroupSoreness.value,
      );
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseFeedbacksCompanion(')
          ..write('id: $id, ')
          ..write('exerciseUuid: $exerciseUuid, ')
          ..write('jointPain: $jointPain, ')
          ..write('musclePump: $musclePump, ')
          ..write('workload: $workload, ')
          ..write('soreness: $soreness, ')
          ..write('muscleGroupSoreness: $muscleGroupSoreness, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $CustomExerciseDefinitionsTable extends CustomExerciseDefinitions
    with TableInfo<$CustomExerciseDefinitionsTable, CustomExerciseDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExerciseDefinitionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<int> muscleGroup = GeneratedColumn<int>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMuscleGroupMeta =
      const VerificationMeta('secondaryMuscleGroup');
  @override
  late final GeneratedColumn<int> secondaryMuscleGroup = GeneratedColumn<int>(
    'secondary_muscle_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentTypeMeta = const VerificationMeta(
    'equipmentType',
  );
  @override
  late final GeneratedColumn<int> equipmentType = GeneratedColumn<int>(
    'equipment_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    name,
    muscleGroup,
    secondaryMuscleGroup,
    equipmentType,
    videoUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercise_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExerciseDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('secondary_muscle_group')) {
      context.handle(
        _secondaryMuscleGroupMeta,
        secondaryMuscleGroup.isAcceptableOrUnknown(
          data['secondary_muscle_group']!,
          _secondaryMuscleGroupMeta,
        ),
      );
    }
    if (data.containsKey('equipment_type')) {
      context.handle(
        _equipmentTypeMeta,
        equipmentType.isAcceptableOrUnknown(
          data['equipment_type']!,
          _equipmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentTypeMeta);
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExerciseDefinition map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExerciseDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_group'],
      )!,
      secondaryMuscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}secondary_muscle_group'],
      ),
      equipmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipment_type'],
      )!,
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomExerciseDefinitionsTable createAlias(String alias) {
    return $CustomExerciseDefinitionsTable(attachedDatabase, alias);
  }
}

class CustomExerciseDefinition extends DataClass
    implements Insertable<CustomExerciseDefinition> {
  final int id;
  final String uuid;
  final String name;
  final int muscleGroup;
  final int? secondaryMuscleGroup;
  final int equipmentType;
  final String? videoUrl;
  final DateTime createdAt;
  const CustomExerciseDefinition({
    required this.id,
    required this.uuid,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    this.videoUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['muscle_group'] = Variable<int>(muscleGroup);
    if (!nullToAbsent || secondaryMuscleGroup != null) {
      map['secondary_muscle_group'] = Variable<int>(secondaryMuscleGroup);
    }
    map['equipment_type'] = Variable<int>(equipmentType);
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomExerciseDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CustomExerciseDefinitionsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      secondaryMuscleGroup: secondaryMuscleGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscleGroup),
      equipmentType: Value(equipmentType),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      createdAt: Value(createdAt),
    );
  }

  factory CustomExerciseDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExerciseDefinition(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      muscleGroup: serializer.fromJson<int>(json['muscleGroup']),
      secondaryMuscleGroup: serializer.fromJson<int?>(
        json['secondaryMuscleGroup'],
      ),
      equipmentType: serializer.fromJson<int>(json['equipmentType']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'muscleGroup': serializer.toJson<int>(muscleGroup),
      'secondaryMuscleGroup': serializer.toJson<int?>(secondaryMuscleGroup),
      'equipmentType': serializer.toJson<int>(equipmentType),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomExerciseDefinition copyWith({
    int? id,
    String? uuid,
    String? name,
    int? muscleGroup,
    Value<int?> secondaryMuscleGroup = const Value.absent(),
    int? equipmentType,
    Value<String?> videoUrl = const Value.absent(),
    DateTime? createdAt,
  }) => CustomExerciseDefinition(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    secondaryMuscleGroup: secondaryMuscleGroup.present
        ? secondaryMuscleGroup.value
        : this.secondaryMuscleGroup,
    equipmentType: equipmentType ?? this.equipmentType,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomExerciseDefinition copyWithCompanion(
    CustomExerciseDefinitionsCompanion data,
  ) {
    return CustomExerciseDefinition(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      secondaryMuscleGroup: data.secondaryMuscleGroup.present
          ? data.secondaryMuscleGroup.value
          : this.secondaryMuscleGroup,
      equipmentType: data.equipmentType.present
          ? data.equipmentType.value
          : this.equipmentType,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExerciseDefinition(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    name,
    muscleGroup,
    secondaryMuscleGroup,
    equipmentType,
    videoUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExerciseDefinition &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.muscleGroup == this.muscleGroup &&
          other.secondaryMuscleGroup == this.secondaryMuscleGroup &&
          other.equipmentType == this.equipmentType &&
          other.videoUrl == this.videoUrl &&
          other.createdAt == this.createdAt);
}

class CustomExerciseDefinitionsCompanion
    extends UpdateCompanion<CustomExerciseDefinition> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> muscleGroup;
  final Value<int?> secondaryMuscleGroup;
  final Value<int> equipmentType;
  final Value<String?> videoUrl;
  final Value<DateTime> createdAt;
  const CustomExerciseDefinitionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.secondaryMuscleGroup = const Value.absent(),
    this.equipmentType = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomExerciseDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required int muscleGroup,
    this.secondaryMuscleGroup = const Value.absent(),
    required int equipmentType,
    this.videoUrl = const Value.absent(),
    required DateTime createdAt,
  }) : uuid = Value(uuid),
       name = Value(name),
       muscleGroup = Value(muscleGroup),
       equipmentType = Value(equipmentType),
       createdAt = Value(createdAt);
  static Insertable<CustomExerciseDefinition> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? muscleGroup,
    Expression<int>? secondaryMuscleGroup,
    Expression<int>? equipmentType,
    Expression<String>? videoUrl,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (secondaryMuscleGroup != null)
        'secondary_muscle_group': secondaryMuscleGroup,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (videoUrl != null) 'video_url': videoUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomExerciseDefinitionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<int>? muscleGroup,
    Value<int?>? secondaryMuscleGroup,
    Value<int>? equipmentType,
    Value<String?>? videoUrl,
    Value<DateTime>? createdAt,
  }) {
    return CustomExerciseDefinitionsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<int>(muscleGroup.value);
    }
    if (secondaryMuscleGroup.present) {
      map['secondary_muscle_group'] = Variable<int>(secondaryMuscleGroup.value);
    }
    if (equipmentType.present) {
      map['equipment_type'] = Variable<int>(equipmentType.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExerciseDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserMeasurementsTable extends UserMeasurements
    with TableInfo<$UserMeasurementsTable, UserMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMeasurementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyFatPercentMeta = const VerificationMeta(
    'bodyFatPercent',
  );
  @override
  late final GeneratedColumn<double> bodyFatPercent = GeneratedColumn<double>(
    'body_fat_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leanMassKgMeta = const VerificationMeta(
    'leanMassKg',
  );
  @override
  late final GeneratedColumn<double> leanMassKg = GeneratedColumn<double>(
    'lean_mass_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    heightCm,
    weightKg,
    timestamp,
    notes,
    bodyFatPercent,
    leanMassKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('body_fat_percent')) {
      context.handle(
        _bodyFatPercentMeta,
        bodyFatPercent.isAcceptableOrUnknown(
          data['body_fat_percent']!,
          _bodyFatPercentMeta,
        ),
      );
    }
    if (data.containsKey('lean_mass_kg')) {
      context.handle(
        _leanMassKgMeta,
        leanMassKg.isAcceptableOrUnknown(
          data['lean_mass_kg']!,
          _leanMassKgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      bodyFatPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_percent'],
      ),
      leanMassKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lean_mass_kg'],
      ),
    );
  }

  @override
  $UserMeasurementsTable createAlias(String alias) {
    return $UserMeasurementsTable(attachedDatabase, alias);
  }
}

class UserMeasurement extends DataClass implements Insertable<UserMeasurement> {
  final int id;
  final String uuid;
  final double heightCm;
  final double weightKg;
  final DateTime timestamp;
  final String? notes;
  final double? bodyFatPercent;
  final double? leanMassKg;
  const UserMeasurement({
    required this.id,
    required this.uuid,
    required this.heightCm,
    required this.weightKg,
    required this.timestamp,
    this.notes,
    this.bodyFatPercent,
    this.leanMassKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || bodyFatPercent != null) {
      map['body_fat_percent'] = Variable<double>(bodyFatPercent);
    }
    if (!nullToAbsent || leanMassKg != null) {
      map['lean_mass_kg'] = Variable<double>(leanMassKg);
    }
    return map;
  }

  UserMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return UserMeasurementsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      timestamp: Value(timestamp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      bodyFatPercent: bodyFatPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPercent),
      leanMassKg: leanMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(leanMassKg),
    );
  }

  factory UserMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMeasurement(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
      bodyFatPercent: serializer.fromJson<double?>(json['bodyFatPercent']),
      leanMassKg: serializer.fromJson<double?>(json['leanMassKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'notes': serializer.toJson<String?>(notes),
      'bodyFatPercent': serializer.toJson<double?>(bodyFatPercent),
      'leanMassKg': serializer.toJson<double?>(leanMassKg),
    };
  }

  UserMeasurement copyWith({
    int? id,
    String? uuid,
    double? heightCm,
    double? weightKg,
    DateTime? timestamp,
    Value<String?> notes = const Value.absent(),
    Value<double?> bodyFatPercent = const Value.absent(),
    Value<double?> leanMassKg = const Value.absent(),
  }) => UserMeasurement(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    timestamp: timestamp ?? this.timestamp,
    notes: notes.present ? notes.value : this.notes,
    bodyFatPercent: bodyFatPercent.present
        ? bodyFatPercent.value
        : this.bodyFatPercent,
    leanMassKg: leanMassKg.present ? leanMassKg.value : this.leanMassKg,
  );
  UserMeasurement copyWithCompanion(UserMeasurementsCompanion data) {
    return UserMeasurement(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
      bodyFatPercent: data.bodyFatPercent.present
          ? data.bodyFatPercent.value
          : this.bodyFatPercent,
      leanMassKg: data.leanMassKg.present
          ? data.leanMassKg.value
          : this.leanMassKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMeasurement(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes, ')
          ..write('bodyFatPercent: $bodyFatPercent, ')
          ..write('leanMassKg: $leanMassKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    heightCm,
    weightKg,
    timestamp,
    notes,
    bodyFatPercent,
    leanMassKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMeasurement &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes &&
          other.bodyFatPercent == this.bodyFatPercent &&
          other.leanMassKg == this.leanMassKg);
}

class UserMeasurementsCompanion extends UpdateCompanion<UserMeasurement> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<DateTime> timestamp;
  final Value<String?> notes;
  final Value<double?> bodyFatPercent;
  final Value<double?> leanMassKg;
  const UserMeasurementsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
    this.bodyFatPercent = const Value.absent(),
    this.leanMassKg = const Value.absent(),
  });
  UserMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required double heightCm,
    required double weightKg,
    required DateTime timestamp,
    this.notes = const Value.absent(),
    this.bodyFatPercent = const Value.absent(),
    this.leanMassKg = const Value.absent(),
  }) : uuid = Value(uuid),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       timestamp = Value(timestamp);
  static Insertable<UserMeasurement> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<DateTime>? timestamp,
    Expression<String>? notes,
    Expression<double>? bodyFatPercent,
    Expression<double>? leanMassKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
      if (bodyFatPercent != null) 'body_fat_percent': bodyFatPercent,
      if (leanMassKg != null) 'lean_mass_kg': leanMassKg,
    });
  }

  UserMeasurementsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<DateTime>? timestamp,
    Value<String?>? notes,
    Value<double?>? bodyFatPercent,
    Value<double?>? leanMassKg,
  }) {
    return UserMeasurementsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      leanMassKg: leanMassKg ?? this.leanMassKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (bodyFatPercent.present) {
      map['body_fat_percent'] = Variable<double>(bodyFatPercent.value);
    }
    if (leanMassKg.present) {
      map['lean_mass_kg'] = Variable<double>(leanMassKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes, ')
          ..write('bodyFatPercent: $bodyFatPercent, ')
          ..write('leanMassKg: $leanMassKg')
          ..write(')'))
        .toString();
  }
}

class $SkinsTable extends Skins with TableInfo<$SkinsTable, Skin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkinsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skinJsonMeta = const VerificationMeta(
    'skinJson',
  );
  @override
  late final GeneratedColumn<String> skinJson = GeneratedColumn<String>(
    'skin_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    name,
    skinJson,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Skin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('skin_json')) {
      context.handle(
        _skinJsonMeta,
        skinJson.isAcceptableOrUnknown(data['skin_json']!, _skinJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_skinJsonMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      skinJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skin_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SkinsTable createAlias(String alias) {
    return $SkinsTable(attachedDatabase, alias);
  }
}

class Skin extends DataClass implements Insertable<Skin> {
  final int id;
  final String uuid;
  final String name;
  final String skinJson;
  final bool isActive;
  final DateTime createdAt;
  const Skin({
    required this.id,
    required this.uuid,
    required this.name,
    required this.skinJson,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['skin_json'] = Variable<String>(skinJson);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SkinsCompanion toCompanion(bool nullToAbsent) {
    return SkinsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      skinJson: Value(skinJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Skin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skin(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      skinJson: serializer.fromJson<String>(json['skinJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'skinJson': serializer.toJson<String>(skinJson),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Skin copyWith({
    int? id,
    String? uuid,
    String? name,
    String? skinJson,
    bool? isActive,
    DateTime? createdAt,
  }) => Skin(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    skinJson: skinJson ?? this.skinJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Skin copyWithCompanion(SkinsCompanion data) {
    return Skin(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      skinJson: data.skinJson.present ? data.skinJson.value : this.skinJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skin(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('skinJson: $skinJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, name, skinJson, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skin &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.skinJson == this.skinJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SkinsCompanion extends UpdateCompanion<Skin> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> skinJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const SkinsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.skinJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SkinsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required String skinJson,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : uuid = Value(uuid),
       name = Value(name),
       skinJson = Value(skinJson),
       createdAt = Value(createdAt);
  static Insertable<Skin> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? skinJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (skinJson != null) 'skin_json': skinJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SkinsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<String>? skinJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return SkinsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      skinJson: skinJson ?? this.skinJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (skinJson.present) {
      map['skin_json'] = Variable<String>(skinJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkinsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('skinJson: $skinJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrainingCyclesTable trainingCycles = $TrainingCyclesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $ExerciseFeedbacksTable exerciseFeedbacks =
      $ExerciseFeedbacksTable(this);
  late final $CustomExerciseDefinitionsTable customExerciseDefinitions =
      $CustomExerciseDefinitionsTable(this);
  late final $UserMeasurementsTable userMeasurements = $UserMeasurementsTable(
    this,
  );
  late final $SkinsTable skins = $SkinsTable(this);
  late final TrainingCycleDao trainingCycleDao = TrainingCycleDao(
    this as AppDatabase,
  );
  late final WorkoutDao workoutDao = WorkoutDao(this as AppDatabase);
  late final ExerciseDao exerciseDao = ExerciseDao(this as AppDatabase);
  late final ExerciseSetDao exerciseSetDao = ExerciseSetDao(
    this as AppDatabase,
  );
  late final ExerciseFeedbackDao exerciseFeedbackDao = ExerciseFeedbackDao(
    this as AppDatabase,
  );
  late final CustomExerciseDao customExerciseDao = CustomExerciseDao(
    this as AppDatabase,
  );
  late final UserMeasurementDao userMeasurementDao = UserMeasurementDao(
    this as AppDatabase,
  );
  late final SkinDao skinDao = SkinDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trainingCycles,
    workouts,
    exercises,
    exerciseSets,
    exerciseFeedbacks,
    customExerciseDefinitions,
    userMeasurements,
    skins,
  ];
}

typedef $$TrainingCyclesTableCreateCompanionBuilder =
    TrainingCyclesCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      required int periodsTotal,
      required int daysPerPeriod,
      required int recoveryPeriod,
      required int status,
      Value<int?> gender,
      required DateTime createdDate,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> muscleGroupPriorities,
      Value<String?> templateName,
      Value<String?> notes,
      Value<int?> recoveryPeriodType,
    });
typedef $$TrainingCyclesTableUpdateCompanionBuilder =
    TrainingCyclesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<int> periodsTotal,
      Value<int> daysPerPeriod,
      Value<int> recoveryPeriod,
      Value<int> status,
      Value<int?> gender,
      Value<DateTime> createdDate,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> muscleGroupPriorities,
      Value<String?> templateName,
      Value<String?> notes,
      Value<int?> recoveryPeriodType,
    });

final class $$TrainingCyclesTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingCyclesTable, TrainingCycle> {
  $$TrainingCyclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workouts,
    aliasName: $_aliasNameGenerator(
      db.trainingCycles.uuid,
      db.workouts.trainingCycleUuid,
    ),
  );

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts).filter(
      (f) => f.trainingCycleUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingCyclesTable> {
  $$TrainingCyclesTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodsTotal => $composableBuilder(
    column: $table.periodsTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerPeriod => $composableBuilder(
    column: $table.daysPerPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recoveryPeriod => $composableBuilder(
    column: $table.recoveryPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroupPriorities => $composableBuilder(
    column: $table.muscleGroupPriorities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recoveryPeriodType => $composableBuilder(
    column: $table.recoveryPeriodType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutsRefs(
    Expression<bool> Function($$WorkoutsTableFilterComposer f) f,
  ) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingCyclesTable> {
  $$TrainingCyclesTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodsTotal => $composableBuilder(
    column: $table.periodsTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerPeriod => $composableBuilder(
    column: $table.daysPerPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recoveryPeriod => $composableBuilder(
    column: $table.recoveryPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroupPriorities => $composableBuilder(
    column: $table.muscleGroupPriorities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recoveryPeriodType => $composableBuilder(
    column: $table.recoveryPeriodType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingCyclesTable> {
  $$TrainingCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get periodsTotal => $composableBuilder(
    column: $table.periodsTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysPerPeriod => $composableBuilder(
    column: $table.daysPerPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recoveryPeriod => $composableBuilder(
    column: $table.recoveryPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupPriorities => $composableBuilder(
    column: $table.muscleGroupPriorities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get recoveryPeriodType => $composableBuilder(
    column: $table.recoveryPeriodType,
    builder: (column) => column,
  );

  Expression<T> workoutsRefs<T extends Object>(
    Expression<T> Function($$WorkoutsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingCyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingCyclesTable,
          TrainingCycle,
          $$TrainingCyclesTableFilterComposer,
          $$TrainingCyclesTableOrderingComposer,
          $$TrainingCyclesTableAnnotationComposer,
          $$TrainingCyclesTableCreateCompanionBuilder,
          $$TrainingCyclesTableUpdateCompanionBuilder,
          (TrainingCycle, $$TrainingCyclesTableReferences),
          TrainingCycle,
          PrefetchHooks Function({bool workoutsRefs})
        > {
  $$TrainingCyclesTableTableManager(
    _$AppDatabase db,
    $TrainingCyclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> periodsTotal = const Value.absent(),
                Value<int> daysPerPeriod = const Value.absent(),
                Value<int> recoveryPeriod = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> gender = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> muscleGroupPriorities = const Value.absent(),
                Value<String?> templateName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> recoveryPeriodType = const Value.absent(),
              }) => TrainingCyclesCompanion(
                id: id,
                uuid: uuid,
                name: name,
                periodsTotal: periodsTotal,
                daysPerPeriod: daysPerPeriod,
                recoveryPeriod: recoveryPeriod,
                status: status,
                gender: gender,
                createdDate: createdDate,
                startDate: startDate,
                endDate: endDate,
                muscleGroupPriorities: muscleGroupPriorities,
                templateName: templateName,
                notes: notes,
                recoveryPeriodType: recoveryPeriodType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                required int periodsTotal,
                required int daysPerPeriod,
                required int recoveryPeriod,
                required int status,
                Value<int?> gender = const Value.absent(),
                required DateTime createdDate,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> muscleGroupPriorities = const Value.absent(),
                Value<String?> templateName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> recoveryPeriodType = const Value.absent(),
              }) => TrainingCyclesCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                periodsTotal: periodsTotal,
                daysPerPeriod: daysPerPeriod,
                recoveryPeriod: recoveryPeriod,
                status: status,
                gender: gender,
                createdDate: createdDate,
                startDate: startDate,
                endDate: endDate,
                muscleGroupPriorities: muscleGroupPriorities,
                templateName: templateName,
                notes: notes,
                recoveryPeriodType: recoveryPeriodType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingCyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutsRefs) db.workouts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutsRefs)
                    await $_getPrefetchedData<
                      TrainingCycle,
                      $TrainingCyclesTable,
                      Workout
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingCyclesTableReferences
                          ._workoutsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrainingCyclesTableReferences(
                            db,
                            table,
                            p0,
                          ).workoutsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.trainingCycleUuid == item.uuid,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrainingCyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingCyclesTable,
      TrainingCycle,
      $$TrainingCyclesTableFilterComposer,
      $$TrainingCyclesTableOrderingComposer,
      $$TrainingCyclesTableAnnotationComposer,
      $$TrainingCyclesTableCreateCompanionBuilder,
      $$TrainingCyclesTableUpdateCompanionBuilder,
      (TrainingCycle, $$TrainingCyclesTableReferences),
      TrainingCycle,
      PrefetchHooks Function({bool workoutsRefs})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      required String uuid,
      required String trainingCycleUuid,
      required int periodNumber,
      required int dayNumber,
      Value<String?> dayName,
      Value<String?> label,
      required int status,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> completedDate,
      Value<String?> notes,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> trainingCycleUuid,
      Value<int> periodNumber,
      Value<int> dayNumber,
      Value<String?> dayName,
      Value<String?> label,
      Value<int> status,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> completedDate,
      Value<String?> notes,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingCyclesTable _trainingCycleUuidTable(_$AppDatabase db) =>
      db.trainingCycles.createAlias(
        $_aliasNameGenerator(
          db.workouts.trainingCycleUuid,
          db.trainingCycles.uuid,
        ),
      );

  $$TrainingCyclesTableProcessedTableManager get trainingCycleUuid {
    final $_column = $_itemColumn<String>('training_cycle_uuid')!;

    final manager = $$TrainingCyclesTableTableManager(
      $_db,
      $_db.trainingCycles,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trainingCycleUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: $_aliasNameGenerator(db.workouts.uuid, db.exercises.workoutUuid),
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager($_db, $_db.exercises).filter(
      (f) => f.workoutUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodNumber => $composableBuilder(
    column: $table.periodNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayName => $composableBuilder(
    column: $table.dayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingCyclesTableFilterComposer get trainingCycleUuid {
    final $$TrainingCyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingCycleUuid,
      referencedTable: $db.trainingCycles,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingCyclesTableFilterComposer(
            $db: $db,
            $table: $db.trainingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.workoutUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodNumber => $composableBuilder(
    column: $table.periodNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayName => $composableBuilder(
    column: $table.dayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingCyclesTableOrderingComposer get trainingCycleUuid {
    final $$TrainingCyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingCycleUuid,
      referencedTable: $db.trainingCycles,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingCyclesTableOrderingComposer(
            $db: $db,
            $table: $db.trainingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get periodNumber => $composableBuilder(
    column: $table.periodNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get dayName =>
      $composableBuilder(column: $table.dayName, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TrainingCyclesTableAnnotationComposer get trainingCycleUuid {
    final $$TrainingCyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingCycleUuid,
      referencedTable: $db.trainingCycles,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingCyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.workoutUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({bool trainingCycleUuid, bool exercisesRefs})
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> trainingCycleUuid = const Value.absent(),
                Value<int> periodNumber = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String?> dayName = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                periodNumber: periodNumber,
                dayNumber: dayNumber,
                dayName: dayName,
                label: label,
                status: status,
                scheduledDate: scheduledDate,
                completedDate: completedDate,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String trainingCycleUuid,
                required int periodNumber,
                required int dayNumber,
                Value<String?> dayName = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required int status,
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                periodNumber: periodNumber,
                dayNumber: dayNumber,
                dayName: dayName,
                label: label,
                status: status,
                scheduledDate: scheduledDate,
                completedDate: completedDate,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trainingCycleUuid = false, exercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (exercisesRefs) db.exercises],
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
                        if (trainingCycleUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.trainingCycleUuid,
                                    referencedTable: $$WorkoutsTableReferences
                                        ._trainingCycleUuidTable(db),
                                    referencedColumn: $$WorkoutsTableReferences
                                        ._trainingCycleUuidTable(db)
                                        .uuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exercisesRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          Exercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._exercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).exercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({bool trainingCycleUuid, bool exercisesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String uuid,
      required String workoutUuid,
      required String name,
      required int muscleGroup,
      Value<int?> secondaryMuscleGroup,
      required int equipmentType,
      required int orderIndex,
      Value<double?> bodyweight,
      Value<String?> notes,
      Value<DateTime?> lastPerformed,
      Value<String?> videoUrl,
      Value<bool> isNotePinned,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> workoutUuid,
      Value<String> name,
      Value<int> muscleGroup,
      Value<int?> secondaryMuscleGroup,
      Value<int> equipmentType,
      Value<int> orderIndex,
      Value<double?> bodyweight,
      Value<String?> notes,
      Value<DateTime?> lastPerformed,
      Value<String?> videoUrl,
      Value<bool> isNotePinned,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutUuidTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.exercises.workoutUuid, db.workouts.uuid),
      );

  $$WorkoutsTableProcessedTableManager get workoutUuid {
    final $_column = $_itemColumn<String>('workout_uuid')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>>
  _exerciseSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseSets,
    aliasName: $_aliasNameGenerator(
      db.exercises.uuid,
      db.exerciseSets.exerciseUuid,
    ),
  );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager($_db, $_db.exerciseSets)
        .filter(
          (f) => f.exerciseUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
        );

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseFeedbacksTable, List<ExerciseFeedback>>
  _exerciseFeedbacksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseFeedbacks,
        aliasName: $_aliasNameGenerator(
          db.exercises.uuid,
          db.exerciseFeedbacks.exerciseUuid,
        ),
      );

  $$ExerciseFeedbacksTableProcessedTableManager get exerciseFeedbacksRefs {
    final manager =
        $$ExerciseFeedbacksTableTableManager(
          $_db,
          $_db.exerciseFeedbacks,
        ).filter(
          (f) => f.exerciseUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _exerciseFeedbacksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPerformed => $composableBuilder(
    column: $table.lastPerformed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNotePinned => $composableBuilder(
    column: $table.isNotePinned,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutUuid {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutUuid,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseSetsRefs(
    Expression<bool> Function($$ExerciseSetsTableFilterComposer f) f,
  ) {
    final $$ExerciseSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.exerciseUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseFeedbacksRefs(
    Expression<bool> Function($$ExerciseFeedbacksTableFilterComposer f) f,
  ) {
    final $$ExerciseFeedbacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.exerciseFeedbacks,
      getReferencedColumn: (t) => t.exerciseUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseFeedbacksTableFilterComposer(
            $db: $db,
            $table: $db.exerciseFeedbacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPerformed => $composableBuilder(
    column: $table.lastPerformed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNotePinned => $composableBuilder(
    column: $table.isNotePinned,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutUuid {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutUuid,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPerformed => $composableBuilder(
    column: $table.lastPerformed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isNotePinned => $composableBuilder(
    column: $table.isNotePinned,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutUuid {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutUuid,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseSetsRefs<T extends Object>(
    Expression<T> Function($$ExerciseSetsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.exerciseSets,
      getReferencedColumn: (t) => t.exerciseUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseFeedbacksRefs<T extends Object>(
    Expression<T> Function($$ExerciseFeedbacksTableAnnotationComposer a) f,
  ) {
    final $$ExerciseFeedbacksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.uuid,
          referencedTable: $db.exerciseFeedbacks,
          getReferencedColumn: (t) => t.exerciseUuid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseFeedbacksTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseFeedbacks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool workoutUuid,
            bool exerciseSetsRefs,
            bool exerciseFeedbacksRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> workoutUuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> muscleGroup = const Value.absent(),
                Value<int?> secondaryMuscleGroup = const Value.absent(),
                Value<int> equipmentType = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<double?> bodyweight = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastPerformed = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<bool> isNotePinned = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                uuid: uuid,
                workoutUuid: workoutUuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                orderIndex: orderIndex,
                bodyweight: bodyweight,
                notes: notes,
                lastPerformed: lastPerformed,
                videoUrl: videoUrl,
                isNotePinned: isNotePinned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String workoutUuid,
                required String name,
                required int muscleGroup,
                Value<int?> secondaryMuscleGroup = const Value.absent(),
                required int equipmentType,
                required int orderIndex,
                Value<double?> bodyweight = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastPerformed = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<bool> isNotePinned = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                uuid: uuid,
                workoutUuid: workoutUuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                orderIndex: orderIndex,
                bodyweight: bodyweight,
                notes: notes,
                lastPerformed: lastPerformed,
                videoUrl: videoUrl,
                isNotePinned: isNotePinned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutUuid = false,
                exerciseSetsRefs = false,
                exerciseFeedbacksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseSetsRefs) db.exerciseSets,
                    if (exerciseFeedbacksRefs) db.exerciseFeedbacks,
                  ],
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
                        if (workoutUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutUuid,
                                    referencedTable: $$ExercisesTableReferences
                                        ._workoutUuidTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._workoutUuidTable(db)
                                        .uuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseSetsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseSet
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseFeedbacksRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseFeedback
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseFeedbacksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseFeedbacksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool workoutUuid,
        bool exerciseSetsRefs,
        bool exerciseFeedbacksRefs,
      })
    >;
typedef $$ExerciseSetsTableCreateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      required String uuid,
      required String exerciseUuid,
      required int setNumber,
      Value<double?> weight,
      required String reps,
      required int setType,
      Value<bool> isLogged,
      Value<String?> notes,
      Value<bool> isSkipped,
    });
typedef $$ExerciseSetsTableUpdateCompanionBuilder =
    ExerciseSetsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> exerciseUuid,
      Value<int> setNumber,
      Value<double?> weight,
      Value<String> reps,
      Value<int> setType,
      Value<bool> isLogged,
      Value<String?> notes,
      Value<bool> isSkipped,
    });

final class $$ExerciseSetsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseSetsTable, ExerciseSet> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseUuidTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.exerciseSets.exerciseUuid, db.exercises.uuid),
      );

  $$ExercisesTableProcessedTableManager get exerciseUuid {
    final $_column = $_itemColumn<String>('exercise_uuid')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseSetsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLogged => $composableBuilder(
    column: $table.isLogged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseUuid {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLogged => $composableBuilder(
    column: $table.isLogged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseUuid {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<bool> get isLogged =>
      $composableBuilder(column: $table.isLogged, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseUuid {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseSetsTable,
          ExerciseSet,
          $$ExerciseSetsTableFilterComposer,
          $$ExerciseSetsTableOrderingComposer,
          $$ExerciseSetsTableAnnotationComposer,
          $$ExerciseSetsTableCreateCompanionBuilder,
          $$ExerciseSetsTableUpdateCompanionBuilder,
          (ExerciseSet, $$ExerciseSetsTableReferences),
          ExerciseSet,
          PrefetchHooks Function({bool exerciseUuid})
        > {
  $$ExerciseSetsTableTableManager(_$AppDatabase db, $ExerciseSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> exerciseUuid = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<String> reps = const Value.absent(),
                Value<int> setType = const Value.absent(),
                Value<bool> isLogged = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
              }) => ExerciseSetsCompanion(
                id: id,
                uuid: uuid,
                exerciseUuid: exerciseUuid,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
                setType: setType,
                isLogged: isLogged,
                notes: notes,
                isSkipped: isSkipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String exerciseUuid,
                required int setNumber,
                Value<double?> weight = const Value.absent(),
                required String reps,
                required int setType,
                Value<bool> isLogged = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
              }) => ExerciseSetsCompanion.insert(
                id: id,
                uuid: uuid,
                exerciseUuid: exerciseUuid,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
                setType: setType,
                isLogged: isLogged,
                notes: notes,
                isSkipped: isSkipped,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseUuid = false}) {
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
                    if (exerciseUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseUuid,
                                referencedTable: $$ExerciseSetsTableReferences
                                    ._exerciseUuidTable(db),
                                referencedColumn: $$ExerciseSetsTableReferences
                                    ._exerciseUuidTable(db)
                                    .uuid,
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

typedef $$ExerciseSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseSetsTable,
      ExerciseSet,
      $$ExerciseSetsTableFilterComposer,
      $$ExerciseSetsTableOrderingComposer,
      $$ExerciseSetsTableAnnotationComposer,
      $$ExerciseSetsTableCreateCompanionBuilder,
      $$ExerciseSetsTableUpdateCompanionBuilder,
      (ExerciseSet, $$ExerciseSetsTableReferences),
      ExerciseSet,
      PrefetchHooks Function({bool exerciseUuid})
    >;
typedef $$ExerciseFeedbacksTableCreateCompanionBuilder =
    ExerciseFeedbacksCompanion Function({
      Value<int> id,
      required String exerciseUuid,
      Value<int?> jointPain,
      Value<int?> musclePump,
      Value<int?> workload,
      Value<int?> soreness,
      Value<String?> muscleGroupSoreness,
      Value<DateTime?> timestamp,
    });
typedef $$ExerciseFeedbacksTableUpdateCompanionBuilder =
    ExerciseFeedbacksCompanion Function({
      Value<int> id,
      Value<String> exerciseUuid,
      Value<int?> jointPain,
      Value<int?> musclePump,
      Value<int?> workload,
      Value<int?> soreness,
      Value<String?> muscleGroupSoreness,
      Value<DateTime?> timestamp,
    });

final class $$ExerciseFeedbacksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseFeedbacksTable,
          ExerciseFeedback
        > {
  $$ExerciseFeedbacksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseUuidTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.exerciseFeedbacks.exerciseUuid,
          db.exercises.uuid,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseUuid {
    final $_column = $_itemColumn<String>('exercise_uuid')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseFeedbacksTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
  $$ExerciseFeedbacksTableFilterComposer({
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

  ColumnFilters<int> get jointPain => $composableBuilder(
    column: $table.jointPain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get musclePump => $composableBuilder(
    column: $table.musclePump,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workload => $composableBuilder(
    column: $table.workload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroupSoreness => $composableBuilder(
    column: $table.muscleGroupSoreness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseUuid {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseFeedbacksTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
  $$ExerciseFeedbacksTableOrderingComposer({
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

  ColumnOrderings<int> get jointPain => $composableBuilder(
    column: $table.jointPain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get musclePump => $composableBuilder(
    column: $table.musclePump,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workload => $composableBuilder(
    column: $table.workload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroupSoreness => $composableBuilder(
    column: $table.muscleGroupSoreness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseUuid {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseFeedbacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
  $$ExerciseFeedbacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jointPain =>
      $composableBuilder(column: $table.jointPain, builder: (column) => column);

  GeneratedColumn<int> get musclePump => $composableBuilder(
    column: $table.musclePump,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workload =>
      $composableBuilder(column: $table.workload, builder: (column) => column);

  GeneratedColumn<int> get soreness =>
      $composableBuilder(column: $table.soreness, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupSoreness => $composableBuilder(
    column: $table.muscleGroupSoreness,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseUuid {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseUuid,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseFeedbacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseFeedbacksTable,
          ExerciseFeedback,
          $$ExerciseFeedbacksTableFilterComposer,
          $$ExerciseFeedbacksTableOrderingComposer,
          $$ExerciseFeedbacksTableAnnotationComposer,
          $$ExerciseFeedbacksTableCreateCompanionBuilder,
          $$ExerciseFeedbacksTableUpdateCompanionBuilder,
          (ExerciseFeedback, $$ExerciseFeedbacksTableReferences),
          ExerciseFeedback,
          PrefetchHooks Function({bool exerciseUuid})
        > {
  $$ExerciseFeedbacksTableTableManager(
    _$AppDatabase db,
    $ExerciseFeedbacksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseFeedbacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseFeedbacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseFeedbacksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseUuid = const Value.absent(),
                Value<int?> jointPain = const Value.absent(),
                Value<int?> musclePump = const Value.absent(),
                Value<int?> workload = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<String?> muscleGroupSoreness = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
              }) => ExerciseFeedbacksCompanion(
                id: id,
                exerciseUuid: exerciseUuid,
                jointPain: jointPain,
                musclePump: musclePump,
                workload: workload,
                soreness: soreness,
                muscleGroupSoreness: muscleGroupSoreness,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String exerciseUuid,
                Value<int?> jointPain = const Value.absent(),
                Value<int?> musclePump = const Value.absent(),
                Value<int?> workload = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<String?> muscleGroupSoreness = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
              }) => ExerciseFeedbacksCompanion.insert(
                id: id,
                exerciseUuid: exerciseUuid,
                jointPain: jointPain,
                musclePump: musclePump,
                workload: workload,
                soreness: soreness,
                muscleGroupSoreness: muscleGroupSoreness,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseFeedbacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseUuid = false}) {
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
                    if (exerciseUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseUuid,
                                referencedTable:
                                    $$ExerciseFeedbacksTableReferences
                                        ._exerciseUuidTable(db),
                                referencedColumn:
                                    $$ExerciseFeedbacksTableReferences
                                        ._exerciseUuidTable(db)
                                        .uuid,
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

typedef $$ExerciseFeedbacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseFeedbacksTable,
      ExerciseFeedback,
      $$ExerciseFeedbacksTableFilterComposer,
      $$ExerciseFeedbacksTableOrderingComposer,
      $$ExerciseFeedbacksTableAnnotationComposer,
      $$ExerciseFeedbacksTableCreateCompanionBuilder,
      $$ExerciseFeedbacksTableUpdateCompanionBuilder,
      (ExerciseFeedback, $$ExerciseFeedbacksTableReferences),
      ExerciseFeedback,
      PrefetchHooks Function({bool exerciseUuid})
    >;
typedef $$CustomExerciseDefinitionsTableCreateCompanionBuilder =
    CustomExerciseDefinitionsCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      required int muscleGroup,
      Value<int?> secondaryMuscleGroup,
      required int equipmentType,
      Value<String?> videoUrl,
      required DateTime createdAt,
    });
typedef $$CustomExerciseDefinitionsTableUpdateCompanionBuilder =
    CustomExerciseDefinitionsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<int> muscleGroup,
      Value<int?> secondaryMuscleGroup,
      Value<int> equipmentType,
      Value<String?> videoUrl,
      Value<DateTime> createdAt,
    });

class $$CustomExerciseDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomExerciseDefinitionsTable> {
  $$CustomExerciseDefinitionsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExerciseDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomExerciseDefinitionsTable> {
  $$CustomExerciseDefinitionsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExerciseDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomExerciseDefinitionsTable> {
  $$CustomExerciseDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get secondaryMuscleGroup => $composableBuilder(
    column: $table.secondaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomExerciseDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomExerciseDefinitionsTable,
          CustomExerciseDefinition,
          $$CustomExerciseDefinitionsTableFilterComposer,
          $$CustomExerciseDefinitionsTableOrderingComposer,
          $$CustomExerciseDefinitionsTableAnnotationComposer,
          $$CustomExerciseDefinitionsTableCreateCompanionBuilder,
          $$CustomExerciseDefinitionsTableUpdateCompanionBuilder,
          (
            CustomExerciseDefinition,
            BaseReferences<
              _$AppDatabase,
              $CustomExerciseDefinitionsTable,
              CustomExerciseDefinition
            >,
          ),
          CustomExerciseDefinition,
          PrefetchHooks Function()
        > {
  $$CustomExerciseDefinitionsTableTableManager(
    _$AppDatabase db,
    $CustomExerciseDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExerciseDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomExerciseDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomExerciseDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> muscleGroup = const Value.absent(),
                Value<int?> secondaryMuscleGroup = const Value.absent(),
                Value<int> equipmentType = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomExerciseDefinitionsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                videoUrl: videoUrl,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                required int muscleGroup,
                Value<int?> secondaryMuscleGroup = const Value.absent(),
                required int equipmentType,
                Value<String?> videoUrl = const Value.absent(),
                required DateTime createdAt,
              }) => CustomExerciseDefinitionsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                videoUrl: videoUrl,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExerciseDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomExerciseDefinitionsTable,
      CustomExerciseDefinition,
      $$CustomExerciseDefinitionsTableFilterComposer,
      $$CustomExerciseDefinitionsTableOrderingComposer,
      $$CustomExerciseDefinitionsTableAnnotationComposer,
      $$CustomExerciseDefinitionsTableCreateCompanionBuilder,
      $$CustomExerciseDefinitionsTableUpdateCompanionBuilder,
      (
        CustomExerciseDefinition,
        BaseReferences<
          _$AppDatabase,
          $CustomExerciseDefinitionsTable,
          CustomExerciseDefinition
        >,
      ),
      CustomExerciseDefinition,
      PrefetchHooks Function()
    >;
typedef $$UserMeasurementsTableCreateCompanionBuilder =
    UserMeasurementsCompanion Function({
      Value<int> id,
      required String uuid,
      required double heightCm,
      required double weightKg,
      required DateTime timestamp,
      Value<String?> notes,
      Value<double?> bodyFatPercent,
      Value<double?> leanMassKg,
    });
typedef $$UserMeasurementsTableUpdateCompanionBuilder =
    UserMeasurementsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<DateTime> timestamp,
      Value<String?> notes,
      Value<double?> bodyFatPercent,
      Value<double?> leanMassKg,
    });

class $$UserMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $UserMeasurementsTable> {
  $$UserMeasurementsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPercent => $composableBuilder(
    column: $table.bodyFatPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leanMassKg => $composableBuilder(
    column: $table.leanMassKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMeasurementsTable> {
  $$UserMeasurementsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPercent => $composableBuilder(
    column: $table.bodyFatPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leanMassKg => $composableBuilder(
    column: $table.leanMassKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMeasurementsTable> {
  $$UserMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPercent => $composableBuilder(
    column: $table.bodyFatPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leanMassKg => $composableBuilder(
    column: $table.leanMassKg,
    builder: (column) => column,
  );
}

class $$UserMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMeasurementsTable,
          UserMeasurement,
          $$UserMeasurementsTableFilterComposer,
          $$UserMeasurementsTableOrderingComposer,
          $$UserMeasurementsTableAnnotationComposer,
          $$UserMeasurementsTableCreateCompanionBuilder,
          $$UserMeasurementsTableUpdateCompanionBuilder,
          (
            UserMeasurement,
            BaseReferences<
              _$AppDatabase,
              $UserMeasurementsTable,
              UserMeasurement
            >,
          ),
          UserMeasurement,
          PrefetchHooks Function()
        > {
  $$UserMeasurementsTableTableManager(
    _$AppDatabase db,
    $UserMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> bodyFatPercent = const Value.absent(),
                Value<double?> leanMassKg = const Value.absent(),
              }) => UserMeasurementsCompanion(
                id: id,
                uuid: uuid,
                heightCm: heightCm,
                weightKg: weightKg,
                timestamp: timestamp,
                notes: notes,
                bodyFatPercent: bodyFatPercent,
                leanMassKg: leanMassKg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required double heightCm,
                required double weightKg,
                required DateTime timestamp,
                Value<String?> notes = const Value.absent(),
                Value<double?> bodyFatPercent = const Value.absent(),
                Value<double?> leanMassKg = const Value.absent(),
              }) => UserMeasurementsCompanion.insert(
                id: id,
                uuid: uuid,
                heightCm: heightCm,
                weightKg: weightKg,
                timestamp: timestamp,
                notes: notes,
                bodyFatPercent: bodyFatPercent,
                leanMassKg: leanMassKg,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMeasurementsTable,
      UserMeasurement,
      $$UserMeasurementsTableFilterComposer,
      $$UserMeasurementsTableOrderingComposer,
      $$UserMeasurementsTableAnnotationComposer,
      $$UserMeasurementsTableCreateCompanionBuilder,
      $$UserMeasurementsTableUpdateCompanionBuilder,
      (
        UserMeasurement,
        BaseReferences<_$AppDatabase, $UserMeasurementsTable, UserMeasurement>,
      ),
      UserMeasurement,
      PrefetchHooks Function()
    >;
typedef $$SkinsTableCreateCompanionBuilder =
    SkinsCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      required String skinJson,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$SkinsTableUpdateCompanionBuilder =
    SkinsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<String> skinJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$SkinsTableFilterComposer extends Composer<_$AppDatabase, $SkinsTable> {
  $$SkinsTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skinJson => $composableBuilder(
    column: $table.skinJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SkinsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkinsTable> {
  $$SkinsTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skinJson => $composableBuilder(
    column: $table.skinJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SkinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkinsTable> {
  $$SkinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get skinJson =>
      $composableBuilder(column: $table.skinJson, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SkinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkinsTable,
          Skin,
          $$SkinsTableFilterComposer,
          $$SkinsTableOrderingComposer,
          $$SkinsTableAnnotationComposer,
          $$SkinsTableCreateCompanionBuilder,
          $$SkinsTableUpdateCompanionBuilder,
          (Skin, BaseReferences<_$AppDatabase, $SkinsTable, Skin>),
          Skin,
          PrefetchHooks Function()
        > {
  $$SkinsTableTableManager(_$AppDatabase db, $SkinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> skinJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SkinsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                skinJson: skinJson,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                required String skinJson,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => SkinsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                skinJson: skinJson,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SkinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkinsTable,
      Skin,
      $$SkinsTableFilterComposer,
      $$SkinsTableOrderingComposer,
      $$SkinsTableAnnotationComposer,
      $$SkinsTableCreateCompanionBuilder,
      $$SkinsTableUpdateCompanionBuilder,
      (Skin, BaseReferences<_$AppDatabase, $SkinsTable, Skin>),
      Skin,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(_db, _db.trainingCycles);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseSetsTableTableManager get exerciseSets =>
      $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$ExerciseFeedbacksTableTableManager get exerciseFeedbacks =>
      $$ExerciseFeedbacksTableTableManager(_db, _db.exerciseFeedbacks);
  $$CustomExerciseDefinitionsTableTableManager get customExerciseDefinitions =>
      $$CustomExerciseDefinitionsTableTableManager(
        _db,
        _db.customExerciseDefinitions,
      );
  $$UserMeasurementsTableTableManager get userMeasurements =>
      $$UserMeasurementsTableTableManager(_db, _db.userMeasurements);
  $$SkinsTableTableManager get skins =>
      $$SkinsTableTableManager(_db, _db.skins);
}
