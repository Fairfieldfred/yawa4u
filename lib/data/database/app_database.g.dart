// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrainingCyclesTable extends TrainingCycles with TableInfo<$TrainingCyclesTable, TrainingCycle> {
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
  static const VerificationMeta _muscleGroupPrioritiesMeta = const VerificationMeta('muscleGroupPriorities');
  @override
  late final GeneratedColumn<String> muscleGroupPriorities = GeneratedColumn<String>(
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
  static const VerificationMeta _recoveryPeriodTypeMeta = const VerificationMeta('recoveryPeriodType');
  @override
  late final GeneratedColumn<int> recoveryPeriodType = GeneratedColumn<int>(
    'recovery_period_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primarySportMeta = const VerificationMeta(
    'primarySport',
  );
  @override
  late final GeneratedColumn<int> primarySport = GeneratedColumn<int>(
    'primary_sport',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorUuidMeta = const VerificationMeta(
    'creatorUuid',
  );
  @override
  late final GeneratedColumn<String> creatorUuid = GeneratedColumn<String>(
    'creator_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUuidMeta = const VerificationMeta(
    'ownerUuid',
  );
  @override
  late final GeneratedColumn<String> ownerUuid = GeneratedColumn<String>(
    'owner_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    primarySport,
    creatorUuid,
    ownerUuid,
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
    if (data.containsKey('primary_sport')) {
      context.handle(
        _primarySportMeta,
        primarySport.isAcceptableOrUnknown(
          data['primary_sport']!,
          _primarySportMeta,
        ),
      );
    }
    if (data.containsKey('creator_uuid')) {
      context.handle(
        _creatorUuidMeta,
        creatorUuid.isAcceptableOrUnknown(
          data['creator_uuid']!,
          _creatorUuidMeta,
        ),
      );
    }
    if (data.containsKey('owner_uuid')) {
      context.handle(
        _ownerUuidMeta,
        ownerUuid.isAcceptableOrUnknown(data['owner_uuid']!, _ownerUuidMeta),
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
      primarySport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_sport'],
      ),
      creatorUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_uuid'],
      ),
      ownerUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uuid'],
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
  final int? primarySport;
  final String? creatorUuid;
  final String? ownerUuid;
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
    this.primarySport,
    this.creatorUuid,
    this.ownerUuid,
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
    if (!nullToAbsent || primarySport != null) {
      map['primary_sport'] = Variable<int>(primarySport);
    }
    if (!nullToAbsent || creatorUuid != null) {
      map['creator_uuid'] = Variable<String>(creatorUuid);
    }
    if (!nullToAbsent || ownerUuid != null) {
      map['owner_uuid'] = Variable<String>(ownerUuid);
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
      gender: gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      createdDate: Value(createdDate),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      muscleGroupPriorities: muscleGroupPriorities == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroupPriorities),
      templateName: templateName == null && nullToAbsent ? const Value.absent() : Value(templateName),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recoveryPeriodType: recoveryPeriodType == null && nullToAbsent ? const Value.absent() : Value(recoveryPeriodType),
      primarySport: primarySport == null && nullToAbsent ? const Value.absent() : Value(primarySport),
      creatorUuid: creatorUuid == null && nullToAbsent ? const Value.absent() : Value(creatorUuid),
      ownerUuid: ownerUuid == null && nullToAbsent ? const Value.absent() : Value(ownerUuid),
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
      primarySport: serializer.fromJson<int?>(json['primarySport']),
      creatorUuid: serializer.fromJson<String?>(json['creatorUuid']),
      ownerUuid: serializer.fromJson<String?>(json['ownerUuid']),
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
      'primarySport': serializer.toJson<int?>(primarySport),
      'creatorUuid': serializer.toJson<String?>(creatorUuid),
      'ownerUuid': serializer.toJson<String?>(ownerUuid),
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
    Value<int?> primarySport = const Value.absent(),
    Value<String?> creatorUuid = const Value.absent(),
    Value<String?> ownerUuid = const Value.absent(),
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
    muscleGroupPriorities: muscleGroupPriorities.present ? muscleGroupPriorities.value : this.muscleGroupPriorities,
    templateName: templateName.present ? templateName.value : this.templateName,
    notes: notes.present ? notes.value : this.notes,
    recoveryPeriodType: recoveryPeriodType.present ? recoveryPeriodType.value : this.recoveryPeriodType,
    primarySport: primarySport.present ? primarySport.value : this.primarySport,
    creatorUuid: creatorUuid.present ? creatorUuid.value : this.creatorUuid,
    ownerUuid: ownerUuid.present ? ownerUuid.value : this.ownerUuid,
  );
  TrainingCycle copyWithCompanion(TrainingCyclesCompanion data) {
    return TrainingCycle(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      periodsTotal: data.periodsTotal.present ? data.periodsTotal.value : this.periodsTotal,
      daysPerPeriod: data.daysPerPeriod.present ? data.daysPerPeriod.value : this.daysPerPeriod,
      recoveryPeriod: data.recoveryPeriod.present ? data.recoveryPeriod.value : this.recoveryPeriod,
      status: data.status.present ? data.status.value : this.status,
      gender: data.gender.present ? data.gender.value : this.gender,
      createdDate: data.createdDate.present ? data.createdDate.value : this.createdDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      muscleGroupPriorities: data.muscleGroupPriorities.present
          ? data.muscleGroupPriorities.value
          : this.muscleGroupPriorities,
      templateName: data.templateName.present ? data.templateName.value : this.templateName,
      notes: data.notes.present ? data.notes.value : this.notes,
      recoveryPeriodType: data.recoveryPeriodType.present ? data.recoveryPeriodType.value : this.recoveryPeriodType,
      primarySport: data.primarySport.present ? data.primarySport.value : this.primarySport,
      creatorUuid: data.creatorUuid.present ? data.creatorUuid.value : this.creatorUuid,
      ownerUuid: data.ownerUuid.present ? data.ownerUuid.value : this.ownerUuid,
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
          ..write('recoveryPeriodType: $recoveryPeriodType, ')
          ..write('primarySport: $primarySport, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
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
    primarySport,
    creatorUuid,
    ownerUuid,
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
          other.recoveryPeriodType == this.recoveryPeriodType &&
          other.primarySport == this.primarySport &&
          other.creatorUuid == this.creatorUuid &&
          other.ownerUuid == this.ownerUuid);
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
  final Value<int?> primarySport;
  final Value<String?> creatorUuid;
  final Value<String?> ownerUuid;
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
    this.primarySport = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
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
    this.primarySport = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
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
    Expression<int>? primarySport,
    Expression<String>? creatorUuid,
    Expression<String>? ownerUuid,
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
      if (muscleGroupPriorities != null) 'muscle_group_priorities': muscleGroupPriorities,
      if (templateName != null) 'template_name': templateName,
      if (notes != null) 'notes': notes,
      if (recoveryPeriodType != null) 'recovery_period_type': recoveryPeriodType,
      if (primarySport != null) 'primary_sport': primarySport,
      if (creatorUuid != null) 'creator_uuid': creatorUuid,
      if (ownerUuid != null) 'owner_uuid': ownerUuid,
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
    Value<int?>? primarySport,
    Value<String?>? creatorUuid,
    Value<String?>? ownerUuid,
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
      muscleGroupPriorities: muscleGroupPriorities ?? this.muscleGroupPriorities,
      templateName: templateName ?? this.templateName,
      notes: notes ?? this.notes,
      recoveryPeriodType: recoveryPeriodType ?? this.recoveryPeriodType,
      primarySport: primarySport ?? this.primarySport,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
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
    if (primarySport.present) {
      map['primary_sport'] = Variable<int>(primarySport.value);
    }
    if (creatorUuid.present) {
      map['creator_uuid'] = Variable<String>(creatorUuid.value);
    }
    if (ownerUuid.present) {
      map['owner_uuid'] = Variable<String>(ownerUuid.value);
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
          ..write('recoveryPeriodType: $recoveryPeriodType, ')
          ..write('primarySport: $primarySport, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises with TableInfo<$ExercisesTable, Exercise> {
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
  );
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _secondaryMuscleGroupMeta = const VerificationMeta('secondaryMuscleGroup');
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
  late final GeneratedColumn<DateTime> lastPerformed = GeneratedColumn<DateTime>(
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
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    workoutUuid,
    sessionUuid,
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
    restSeconds,
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
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
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
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
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
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      ),
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
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
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
  final String? sessionUuid;
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
  final int? restSeconds;
  const Exercise({
    required this.id,
    required this.uuid,
    required this.workoutUuid,
    this.sessionUuid,
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
    this.restSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['workout_uuid'] = Variable<String>(workoutUuid);
    if (!nullToAbsent || sessionUuid != null) {
      map['session_uuid'] = Variable<String>(sessionUuid);
    }
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
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      workoutUuid: Value(workoutUuid),
      sessionUuid: sessionUuid == null && nullToAbsent ? const Value.absent() : Value(sessionUuid),
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      secondaryMuscleGroup: secondaryMuscleGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscleGroup),
      equipmentType: Value(equipmentType),
      orderIndex: Value(orderIndex),
      bodyweight: bodyweight == null && nullToAbsent ? const Value.absent() : Value(bodyweight),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      lastPerformed: lastPerformed == null && nullToAbsent ? const Value.absent() : Value(lastPerformed),
      videoUrl: videoUrl == null && nullToAbsent ? const Value.absent() : Value(videoUrl),
      isNotePinned: Value(isNotePinned),
      restSeconds: restSeconds == null && nullToAbsent ? const Value.absent() : Value(restSeconds),
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
      sessionUuid: serializer.fromJson<String?>(json['sessionUuid']),
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
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'workoutUuid': serializer.toJson<String>(workoutUuid),
      'sessionUuid': serializer.toJson<String?>(sessionUuid),
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
      'restSeconds': serializer.toJson<int?>(restSeconds),
    };
  }

  Exercise copyWith({
    int? id,
    String? uuid,
    String? workoutUuid,
    Value<String?> sessionUuid = const Value.absent(),
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
    Value<int?> restSeconds = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    workoutUuid: workoutUuid ?? this.workoutUuid,
    sessionUuid: sessionUuid.present ? sessionUuid.value : this.sessionUuid,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    secondaryMuscleGroup: secondaryMuscleGroup.present ? secondaryMuscleGroup.value : this.secondaryMuscleGroup,
    equipmentType: equipmentType ?? this.equipmentType,
    orderIndex: orderIndex ?? this.orderIndex,
    bodyweight: bodyweight.present ? bodyweight.value : this.bodyweight,
    notes: notes.present ? notes.value : this.notes,
    lastPerformed: lastPerformed.present ? lastPerformed.value : this.lastPerformed,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    isNotePinned: isNotePinned ?? this.isNotePinned,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      workoutUuid: data.workoutUuid.present ? data.workoutUuid.value : this.workoutUuid,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present ? data.muscleGroup.value : this.muscleGroup,
      secondaryMuscleGroup: data.secondaryMuscleGroup.present
          ? data.secondaryMuscleGroup.value
          : this.secondaryMuscleGroup,
      equipmentType: data.equipmentType.present ? data.equipmentType.value : this.equipmentType,
      orderIndex: data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      bodyweight: data.bodyweight.present ? data.bodyweight.value : this.bodyweight,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastPerformed: data.lastPerformed.present ? data.lastPerformed.value : this.lastPerformed,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      isNotePinned: data.isNotePinned.present ? data.isNotePinned.value : this.isNotePinned,
      restSeconds: data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workoutUuid: $workoutUuid, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('notes: $notes, ')
          ..write('lastPerformed: $lastPerformed, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('isNotePinned: $isNotePinned, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    workoutUuid,
    sessionUuid,
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
    restSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.workoutUuid == this.workoutUuid &&
          other.sessionUuid == this.sessionUuid &&
          other.name == this.name &&
          other.muscleGroup == this.muscleGroup &&
          other.secondaryMuscleGroup == this.secondaryMuscleGroup &&
          other.equipmentType == this.equipmentType &&
          other.orderIndex == this.orderIndex &&
          other.bodyweight == this.bodyweight &&
          other.notes == this.notes &&
          other.lastPerformed == this.lastPerformed &&
          other.videoUrl == this.videoUrl &&
          other.isNotePinned == this.isNotePinned &&
          other.restSeconds == this.restSeconds);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> workoutUuid;
  final Value<String?> sessionUuid;
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
  final Value<int?> restSeconds;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.workoutUuid = const Value.absent(),
    this.sessionUuid = const Value.absent(),
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
    this.restSeconds = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String workoutUuid,
    this.sessionUuid = const Value.absent(),
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
    this.restSeconds = const Value.absent(),
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
    Expression<String>? sessionUuid,
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
    Expression<int>? restSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (workoutUuid != null) 'workout_uuid': workoutUuid,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (secondaryMuscleGroup != null) 'secondary_muscle_group': secondaryMuscleGroup,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (orderIndex != null) 'order_index': orderIndex,
      if (bodyweight != null) 'bodyweight': bodyweight,
      if (notes != null) 'notes': notes,
      if (lastPerformed != null) 'last_performed': lastPerformed,
      if (videoUrl != null) 'video_url': videoUrl,
      if (isNotePinned != null) 'is_note_pinned': isNotePinned,
      if (restSeconds != null) 'rest_seconds': restSeconds,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? workoutUuid,
    Value<String?>? sessionUuid,
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
    Value<int?>? restSeconds,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      workoutUuid: workoutUuid ?? this.workoutUuid,
      sessionUuid: sessionUuid ?? this.sessionUuid,
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
      restSeconds: restSeconds ?? this.restSeconds,
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
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
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
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workoutUuid: $workoutUuid, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscleGroup: $secondaryMuscleGroup, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('notes: $notes, ')
          ..write('lastPerformed: $lastPerformed, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('isNotePinned: $isNotePinned, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSetsTable extends ExerciseSets with TableInfo<$ExerciseSetsTable, ExerciseSet> {
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
      weight: weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      reps: Value(reps),
      setType: Value(setType),
      isLogged: Value(isLogged),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
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
      exerciseUuid: data.exerciseUuid.present ? data.exerciseUuid.value : this.exerciseUuid,
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

class $ExerciseFeedbacksTable extends ExerciseFeedbacks with TableInfo<$ExerciseFeedbacksTable, ExerciseFeedback> {
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
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _muscleGroupSorenessMeta = const VerificationMeta('muscleGroupSoreness');
  @override
  late final GeneratedColumn<String> muscleGroupSoreness = GeneratedColumn<String>(
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
    sessionUuid,
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
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
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
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      ),
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

class ExerciseFeedback extends DataClass implements Insertable<ExerciseFeedback> {
  final int id;
  final String exerciseUuid;
  final String? sessionUuid;
  final int? jointPain;
  final int? musclePump;
  final int? workload;
  final int? soreness;
  final String? muscleGroupSoreness;
  final DateTime? timestamp;
  const ExerciseFeedback({
    required this.id,
    required this.exerciseUuid,
    this.sessionUuid,
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
    if (!nullToAbsent || sessionUuid != null) {
      map['session_uuid'] = Variable<String>(sessionUuid);
    }
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
      sessionUuid: sessionUuid == null && nullToAbsent ? const Value.absent() : Value(sessionUuid),
      jointPain: jointPain == null && nullToAbsent ? const Value.absent() : Value(jointPain),
      musclePump: musclePump == null && nullToAbsent ? const Value.absent() : Value(musclePump),
      workload: workload == null && nullToAbsent ? const Value.absent() : Value(workload),
      soreness: soreness == null && nullToAbsent ? const Value.absent() : Value(soreness),
      muscleGroupSoreness: muscleGroupSoreness == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroupSoreness),
      timestamp: timestamp == null && nullToAbsent ? const Value.absent() : Value(timestamp),
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
      sessionUuid: serializer.fromJson<String?>(json['sessionUuid']),
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
      'sessionUuid': serializer.toJson<String?>(sessionUuid),
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
    Value<String?> sessionUuid = const Value.absent(),
    Value<int?> jointPain = const Value.absent(),
    Value<int?> musclePump = const Value.absent(),
    Value<int?> workload = const Value.absent(),
    Value<int?> soreness = const Value.absent(),
    Value<String?> muscleGroupSoreness = const Value.absent(),
    Value<DateTime?> timestamp = const Value.absent(),
  }) => ExerciseFeedback(
    id: id ?? this.id,
    exerciseUuid: exerciseUuid ?? this.exerciseUuid,
    sessionUuid: sessionUuid.present ? sessionUuid.value : this.sessionUuid,
    jointPain: jointPain.present ? jointPain.value : this.jointPain,
    musclePump: musclePump.present ? musclePump.value : this.musclePump,
    workload: workload.present ? workload.value : this.workload,
    soreness: soreness.present ? soreness.value : this.soreness,
    muscleGroupSoreness: muscleGroupSoreness.present ? muscleGroupSoreness.value : this.muscleGroupSoreness,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
  );
  ExerciseFeedback copyWithCompanion(ExerciseFeedbacksCompanion data) {
    return ExerciseFeedback(
      id: data.id.present ? data.id.value : this.id,
      exerciseUuid: data.exerciseUuid.present ? data.exerciseUuid.value : this.exerciseUuid,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      jointPain: data.jointPain.present ? data.jointPain.value : this.jointPain,
      musclePump: data.musclePump.present ? data.musclePump.value : this.musclePump,
      workload: data.workload.present ? data.workload.value : this.workload,
      soreness: data.soreness.present ? data.soreness.value : this.soreness,
      muscleGroupSoreness: data.muscleGroupSoreness.present ? data.muscleGroupSoreness.value : this.muscleGroupSoreness,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseFeedback(')
          ..write('id: $id, ')
          ..write('exerciseUuid: $exerciseUuid, ')
          ..write('sessionUuid: $sessionUuid, ')
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
    sessionUuid,
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
          other.sessionUuid == this.sessionUuid &&
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
  final Value<String?> sessionUuid;
  final Value<int?> jointPain;
  final Value<int?> musclePump;
  final Value<int?> workload;
  final Value<int?> soreness;
  final Value<String?> muscleGroupSoreness;
  final Value<DateTime?> timestamp;
  const ExerciseFeedbacksCompanion({
    this.id = const Value.absent(),
    this.exerciseUuid = const Value.absent(),
    this.sessionUuid = const Value.absent(),
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
    this.sessionUuid = const Value.absent(),
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
    Expression<String>? sessionUuid,
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
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (jointPain != null) 'joint_pain': jointPain,
      if (musclePump != null) 'muscle_pump': musclePump,
      if (workload != null) 'workload': workload,
      if (soreness != null) 'soreness': soreness,
      if (muscleGroupSoreness != null) 'muscle_group_soreness': muscleGroupSoreness,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ExerciseFeedbacksCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseUuid,
    Value<String?>? sessionUuid,
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
      sessionUuid: sessionUuid ?? this.sessionUuid,
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
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
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
          ..write('sessionUuid: $sessionUuid, ')
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
  static const VerificationMeta _secondaryMuscleGroupMeta = const VerificationMeta('secondaryMuscleGroup');
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
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    restSeconds,
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
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
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
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
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

class CustomExerciseDefinition extends DataClass implements Insertable<CustomExerciseDefinition> {
  final int id;
  final String uuid;
  final String name;
  final int muscleGroup;
  final int? secondaryMuscleGroup;
  final int equipmentType;
  final String? videoUrl;
  final int? restSeconds;
  final DateTime createdAt;
  const CustomExerciseDefinition({
    required this.id,
    required this.uuid,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    this.videoUrl,
    this.restSeconds,
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
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
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
      videoUrl: videoUrl == null && nullToAbsent ? const Value.absent() : Value(videoUrl),
      restSeconds: restSeconds == null && nullToAbsent ? const Value.absent() : Value(restSeconds),
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
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
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
      'restSeconds': serializer.toJson<int?>(restSeconds),
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
    Value<int?> restSeconds = const Value.absent(),
    DateTime? createdAt,
  }) => CustomExerciseDefinition(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    secondaryMuscleGroup: secondaryMuscleGroup.present ? secondaryMuscleGroup.value : this.secondaryMuscleGroup,
    equipmentType: equipmentType ?? this.equipmentType,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomExerciseDefinition copyWithCompanion(
    CustomExerciseDefinitionsCompanion data,
  ) {
    return CustomExerciseDefinition(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present ? data.muscleGroup.value : this.muscleGroup,
      secondaryMuscleGroup: data.secondaryMuscleGroup.present
          ? data.secondaryMuscleGroup.value
          : this.secondaryMuscleGroup,
      equipmentType: data.equipmentType.present ? data.equipmentType.value : this.equipmentType,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      restSeconds: data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
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
          ..write('restSeconds: $restSeconds, ')
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
    restSeconds,
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
          other.restSeconds == this.restSeconds &&
          other.createdAt == this.createdAt);
}

class CustomExerciseDefinitionsCompanion extends UpdateCompanion<CustomExerciseDefinition> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> muscleGroup;
  final Value<int?> secondaryMuscleGroup;
  final Value<int> equipmentType;
  final Value<String?> videoUrl;
  final Value<int?> restSeconds;
  final Value<DateTime> createdAt;
  const CustomExerciseDefinitionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.secondaryMuscleGroup = const Value.absent(),
    this.equipmentType = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.restSeconds = const Value.absent(),
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
    this.restSeconds = const Value.absent(),
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
    Expression<int>? restSeconds,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (secondaryMuscleGroup != null) 'secondary_muscle_group': secondaryMuscleGroup,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (videoUrl != null) 'video_url': videoUrl,
      if (restSeconds != null) 'rest_seconds': restSeconds,
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
    Value<int?>? restSeconds,
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
      restSeconds: restSeconds ?? this.restSeconds,
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
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
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
          ..write('restSeconds: $restSeconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserMeasurementsTable extends UserMeasurements with TableInfo<$UserMeasurementsTable, UserMeasurement> {
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
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      bodyFatPercent: bodyFatPercent == null && nullToAbsent ? const Value.absent() : Value(bodyFatPercent),
      leanMassKg: leanMassKg == null && nullToAbsent ? const Value.absent() : Value(leanMassKg),
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
    bodyFatPercent: bodyFatPercent.present ? bodyFatPercent.value : this.bodyFatPercent,
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
      bodyFatPercent: data.bodyFatPercent.present ? data.bodyFatPercent.value : this.bodyFatPercent,
      leanMassKg: data.leanMassKg.present ? data.leanMassKg.value : this.leanMassKg,
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
  int get hashCode => Object.hash(id, uuid, name, skinJson, isActive, createdAt);
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

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> trainingCycleUuid = GeneratedColumn<String>(
    'training_cycle_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_cycles (uuid)',
    ),
  );
  static const VerificationMeta _sportMeta = const VerificationMeta('sport');
  @override
  late final GeneratedColumn<int> sport = GeneratedColumn<int>(
    'sport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodNumberMeta = const VerificationMeta(
    'periodNumber',
  );
  @override
  late final GeneratedColumn<int> periodNumber = GeneratedColumn<int>(
    'period_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  late final GeneratedColumn<DateTime> scheduledDate = GeneratedColumn<DateTime>(
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
  late final GeneratedColumn<DateTime> completedDate = GeneratedColumn<DateTime>(
    'completed_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
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
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorUuidMeta = const VerificationMeta(
    'creatorUuid',
  );
  @override
  late final GeneratedColumn<String> creatorUuid = GeneratedColumn<String>(
    'creator_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUuidMeta = const VerificationMeta(
    'ownerUuid',
  );
  @override
  late final GeneratedColumn<String> ownerUuid = GeneratedColumn<String>(
    'owner_uuid',
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
    sport,
    source,
    periodNumber,
    dayNumber,
    dayName,
    label,
    status,
    scheduledDate,
    completedDate,
    startTime,
    endTime,
    notes,
    externalId,
    creatorUuid,
    ownerUuid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
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
    }
    if (data.containsKey('sport')) {
      context.handle(
        _sportMeta,
        sport.isAcceptableOrUnknown(data['sport']!, _sportMeta),
      );
    } else if (isInserting) {
      context.missing(_sportMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('period_number')) {
      context.handle(
        _periodNumberMeta,
        periodNumber.isAcceptableOrUnknown(
          data['period_number']!,
          _periodNumberMeta,
        ),
      );
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
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
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('creator_uuid')) {
      context.handle(
        _creatorUuidMeta,
        creatorUuid.isAcceptableOrUnknown(
          data['creator_uuid']!,
          _creatorUuidMeta,
        ),
      );
    }
    if (data.containsKey('owner_uuid')) {
      context.handle(
        _ownerUuidMeta,
        ownerUuid.isAcceptableOrUnknown(data['owner_uuid']!, _ownerUuidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
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
      ),
      sport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sport'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source'],
      )!,
      periodNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_number'],
      ),
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      ),
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
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      creatorUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_uuid'],
      ),
      ownerUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uuid'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String uuid;
  final String? trainingCycleUuid;
  final int sport;
  final int source;
  final int? periodNumber;
  final int? dayNumber;
  final String? dayName;
  final String? label;
  final int status;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final String? externalId;
  final String? creatorUuid;
  final String? ownerUuid;
  const Session({
    required this.id,
    required this.uuid,
    this.trainingCycleUuid,
    required this.sport,
    required this.source,
    this.periodNumber,
    this.dayNumber,
    this.dayName,
    this.label,
    required this.status,
    this.scheduledDate,
    this.completedDate,
    this.startTime,
    this.endTime,
    this.notes,
    this.externalId,
    this.creatorUuid,
    this.ownerUuid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || trainingCycleUuid != null) {
      map['training_cycle_uuid'] = Variable<String>(trainingCycleUuid);
    }
    map['sport'] = Variable<int>(sport);
    map['source'] = Variable<int>(source);
    if (!nullToAbsent || periodNumber != null) {
      map['period_number'] = Variable<int>(periodNumber);
    }
    if (!nullToAbsent || dayNumber != null) {
      map['day_number'] = Variable<int>(dayNumber);
    }
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
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    if (!nullToAbsent || creatorUuid != null) {
      map['creator_uuid'] = Variable<String>(creatorUuid);
    }
    if (!nullToAbsent || ownerUuid != null) {
      map['owner_uuid'] = Variable<String>(ownerUuid);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      trainingCycleUuid: trainingCycleUuid == null && nullToAbsent ? const Value.absent() : Value(trainingCycleUuid),
      sport: Value(sport),
      source: Value(source),
      periodNumber: periodNumber == null && nullToAbsent ? const Value.absent() : Value(periodNumber),
      dayNumber: dayNumber == null && nullToAbsent ? const Value.absent() : Value(dayNumber),
      dayName: dayName == null && nullToAbsent ? const Value.absent() : Value(dayName),
      label: label == null && nullToAbsent ? const Value.absent() : Value(label),
      status: Value(status),
      scheduledDate: scheduledDate == null && nullToAbsent ? const Value.absent() : Value(scheduledDate),
      completedDate: completedDate == null && nullToAbsent ? const Value.absent() : Value(completedDate),
      startTime: startTime == null && nullToAbsent ? const Value.absent() : Value(startTime),
      endTime: endTime == null && nullToAbsent ? const Value.absent() : Value(endTime),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      externalId: externalId == null && nullToAbsent ? const Value.absent() : Value(externalId),
      creatorUuid: creatorUuid == null && nullToAbsent ? const Value.absent() : Value(creatorUuid),
      ownerUuid: ownerUuid == null && nullToAbsent ? const Value.absent() : Value(ownerUuid),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      trainingCycleUuid: serializer.fromJson<String?>(
        json['trainingCycleUuid'],
      ),
      sport: serializer.fromJson<int>(json['sport']),
      source: serializer.fromJson<int>(json['source']),
      periodNumber: serializer.fromJson<int?>(json['periodNumber']),
      dayNumber: serializer.fromJson<int?>(json['dayNumber']),
      dayName: serializer.fromJson<String?>(json['dayName']),
      label: serializer.fromJson<String?>(json['label']),
      status: serializer.fromJson<int>(json['status']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      creatorUuid: serializer.fromJson<String?>(json['creatorUuid']),
      ownerUuid: serializer.fromJson<String?>(json['ownerUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'trainingCycleUuid': serializer.toJson<String?>(trainingCycleUuid),
      'sport': serializer.toJson<int>(sport),
      'source': serializer.toJson<int>(source),
      'periodNumber': serializer.toJson<int?>(periodNumber),
      'dayNumber': serializer.toJson<int?>(dayNumber),
      'dayName': serializer.toJson<String?>(dayName),
      'label': serializer.toJson<String?>(label),
      'status': serializer.toJson<int>(status),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'notes': serializer.toJson<String?>(notes),
      'externalId': serializer.toJson<String?>(externalId),
      'creatorUuid': serializer.toJson<String?>(creatorUuid),
      'ownerUuid': serializer.toJson<String?>(ownerUuid),
    };
  }

  Session copyWith({
    int? id,
    String? uuid,
    Value<String?> trainingCycleUuid = const Value.absent(),
    int? sport,
    int? source,
    Value<int?> periodNumber = const Value.absent(),
    Value<int?> dayNumber = const Value.absent(),
    Value<String?> dayName = const Value.absent(),
    Value<String?> label = const Value.absent(),
    int? status,
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<DateTime?> completedDate = const Value.absent(),
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
    Value<String?> creatorUuid = const Value.absent(),
    Value<String?> ownerUuid = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    trainingCycleUuid: trainingCycleUuid.present ? trainingCycleUuid.value : this.trainingCycleUuid,
    sport: sport ?? this.sport,
    source: source ?? this.source,
    periodNumber: periodNumber.present ? periodNumber.value : this.periodNumber,
    dayNumber: dayNumber.present ? dayNumber.value : this.dayNumber,
    dayName: dayName.present ? dayName.value : this.dayName,
    label: label.present ? label.value : this.label,
    status: status ?? this.status,
    scheduledDate: scheduledDate.present ? scheduledDate.value : this.scheduledDate,
    completedDate: completedDate.present ? completedDate.value : this.completedDate,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    notes: notes.present ? notes.value : this.notes,
    externalId: externalId.present ? externalId.value : this.externalId,
    creatorUuid: creatorUuid.present ? creatorUuid.value : this.creatorUuid,
    ownerUuid: ownerUuid.present ? ownerUuid.value : this.ownerUuid,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      trainingCycleUuid: data.trainingCycleUuid.present ? data.trainingCycleUuid.value : this.trainingCycleUuid,
      sport: data.sport.present ? data.sport.value : this.sport,
      source: data.source.present ? data.source.value : this.source,
      periodNumber: data.periodNumber.present ? data.periodNumber.value : this.periodNumber,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      dayName: data.dayName.present ? data.dayName.value : this.dayName,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      scheduledDate: data.scheduledDate.present ? data.scheduledDate.value : this.scheduledDate,
      completedDate: data.completedDate.present ? data.completedDate.value : this.completedDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      externalId: data.externalId.present ? data.externalId.value : this.externalId,
      creatorUuid: data.creatorUuid.present ? data.creatorUuid.value : this.creatorUuid,
      ownerUuid: data.ownerUuid.present ? data.ownerUuid.value : this.ownerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('sport: $sport, ')
          ..write('source: $source, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('dayName: $dayName, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('notes: $notes, ')
          ..write('externalId: $externalId, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    trainingCycleUuid,
    sport,
    source,
    periodNumber,
    dayNumber,
    dayName,
    label,
    status,
    scheduledDate,
    completedDate,
    startTime,
    endTime,
    notes,
    externalId,
    creatorUuid,
    ownerUuid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.trainingCycleUuid == this.trainingCycleUuid &&
          other.sport == this.sport &&
          other.source == this.source &&
          other.periodNumber == this.periodNumber &&
          other.dayNumber == this.dayNumber &&
          other.dayName == this.dayName &&
          other.label == this.label &&
          other.status == this.status &&
          other.scheduledDate == this.scheduledDate &&
          other.completedDate == this.completedDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.notes == this.notes &&
          other.externalId == this.externalId &&
          other.creatorUuid == this.creatorUuid &&
          other.ownerUuid == this.ownerUuid);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> trainingCycleUuid;
  final Value<int> sport;
  final Value<int> source;
  final Value<int?> periodNumber;
  final Value<int?> dayNumber;
  final Value<String?> dayName;
  final Value<String?> label;
  final Value<int> status;
  final Value<DateTime?> scheduledDate;
  final Value<DateTime?> completedDate;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<String?> notes;
  final Value<String?> externalId;
  final Value<String?> creatorUuid;
  final Value<String?> ownerUuid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.trainingCycleUuid = const Value.absent(),
    this.sport = const Value.absent(),
    this.source = const Value.absent(),
    this.periodNumber = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.dayName = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.externalId = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.trainingCycleUuid = const Value.absent(),
    required int sport,
    required int source,
    this.periodNumber = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.dayName = const Value.absent(),
    this.label = const Value.absent(),
    required int status,
    this.scheduledDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.externalId = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  }) : uuid = Value(uuid),
       sport = Value(sport),
       source = Value(source),
       status = Value(status);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? trainingCycleUuid,
    Expression<int>? sport,
    Expression<int>? source,
    Expression<int>? periodNumber,
    Expression<int>? dayNumber,
    Expression<String>? dayName,
    Expression<String>? label,
    Expression<int>? status,
    Expression<DateTime>? scheduledDate,
    Expression<DateTime>? completedDate,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? notes,
    Expression<String>? externalId,
    Expression<String>? creatorUuid,
    Expression<String>? ownerUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (trainingCycleUuid != null) 'training_cycle_uuid': trainingCycleUuid,
      if (sport != null) 'sport': sport,
      if (source != null) 'source': source,
      if (periodNumber != null) 'period_number': periodNumber,
      if (dayNumber != null) 'day_number': dayNumber,
      if (dayName != null) 'day_name': dayName,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (notes != null) 'notes': notes,
      if (externalId != null) 'external_id': externalId,
      if (creatorUuid != null) 'creator_uuid': creatorUuid,
      if (ownerUuid != null) 'owner_uuid': ownerUuid,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String?>? trainingCycleUuid,
    Value<int>? sport,
    Value<int>? source,
    Value<int?>? periodNumber,
    Value<int?>? dayNumber,
    Value<String?>? dayName,
    Value<String?>? label,
    Value<int>? status,
    Value<DateTime?>? scheduledDate,
    Value<DateTime?>? completedDate,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<String?>? notes,
    Value<String?>? externalId,
    Value<String?>? creatorUuid,
    Value<String?>? ownerUuid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      trainingCycleUuid: trainingCycleUuid ?? this.trainingCycleUuid,
      sport: sport ?? this.sport,
      source: source ?? this.source,
      periodNumber: periodNumber ?? this.periodNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      label: label ?? this.label,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      externalId: externalId ?? this.externalId,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
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
    if (sport.present) {
      map['sport'] = Variable<int>(sport.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
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
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (creatorUuid.present) {
      map['creator_uuid'] = Variable<String>(creatorUuid.value);
    }
    if (ownerUuid.present) {
      map['owner_uuid'] = Variable<String>(ownerUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('sport: $sport, ')
          ..write('source: $source, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('dayName: $dayName, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('notes: $notes, ')
          ..write('externalId: $externalId, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }
}

class $CyclePeriodsTable extends CyclePeriods with TableInfo<$CyclePeriodsTable, CyclePeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclePeriodsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> trainingCycleUuid = GeneratedColumn<String>(
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
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<int> phase = GeneratedColumn<int>(
    'phase',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _creatorUuidMeta = const VerificationMeta(
    'creatorUuid',
  );
  @override
  late final GeneratedColumn<String> creatorUuid = GeneratedColumn<String>(
    'creator_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUuidMeta = const VerificationMeta(
    'ownerUuid',
  );
  @override
  late final GeneratedColumn<String> ownerUuid = GeneratedColumn<String>(
    'owner_uuid',
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
    phase,
    notes,
    creatorUuid,
    ownerUuid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CyclePeriod> instance, {
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
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('creator_uuid')) {
      context.handle(
        _creatorUuidMeta,
        creatorUuid.isAcceptableOrUnknown(
          data['creator_uuid']!,
          _creatorUuidMeta,
        ),
      );
    }
    if (data.containsKey('owner_uuid')) {
      context.handle(
        _ownerUuidMeta,
        ownerUuid.isAcceptableOrUnknown(data['owner_uuid']!, _ownerUuidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclePeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclePeriod(
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
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      creatorUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_uuid'],
      ),
      ownerUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uuid'],
      ),
    );
  }

  @override
  $CyclePeriodsTable createAlias(String alias) {
    return $CyclePeriodsTable(attachedDatabase, alias);
  }
}

class CyclePeriod extends DataClass implements Insertable<CyclePeriod> {
  final int id;
  final String uuid;
  final String trainingCycleUuid;
  final int periodNumber;
  final int? phase;
  final String? notes;
  final String? creatorUuid;
  final String? ownerUuid;
  const CyclePeriod({
    required this.id,
    required this.uuid,
    required this.trainingCycleUuid,
    required this.periodNumber,
    this.phase,
    this.notes,
    this.creatorUuid,
    this.ownerUuid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['training_cycle_uuid'] = Variable<String>(trainingCycleUuid);
    map['period_number'] = Variable<int>(periodNumber);
    if (!nullToAbsent || phase != null) {
      map['phase'] = Variable<int>(phase);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || creatorUuid != null) {
      map['creator_uuid'] = Variable<String>(creatorUuid);
    }
    if (!nullToAbsent || ownerUuid != null) {
      map['owner_uuid'] = Variable<String>(ownerUuid);
    }
    return map;
  }

  CyclePeriodsCompanion toCompanion(bool nullToAbsent) {
    return CyclePeriodsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      trainingCycleUuid: Value(trainingCycleUuid),
      periodNumber: Value(periodNumber),
      phase: phase == null && nullToAbsent ? const Value.absent() : Value(phase),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      creatorUuid: creatorUuid == null && nullToAbsent ? const Value.absent() : Value(creatorUuid),
      ownerUuid: ownerUuid == null && nullToAbsent ? const Value.absent() : Value(ownerUuid),
    );
  }

  factory CyclePeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclePeriod(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      trainingCycleUuid: serializer.fromJson<String>(json['trainingCycleUuid']),
      periodNumber: serializer.fromJson<int>(json['periodNumber']),
      phase: serializer.fromJson<int?>(json['phase']),
      notes: serializer.fromJson<String?>(json['notes']),
      creatorUuid: serializer.fromJson<String?>(json['creatorUuid']),
      ownerUuid: serializer.fromJson<String?>(json['ownerUuid']),
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
      'phase': serializer.toJson<int?>(phase),
      'notes': serializer.toJson<String?>(notes),
      'creatorUuid': serializer.toJson<String?>(creatorUuid),
      'ownerUuid': serializer.toJson<String?>(ownerUuid),
    };
  }

  CyclePeriod copyWith({
    int? id,
    String? uuid,
    String? trainingCycleUuid,
    int? periodNumber,
    Value<int?> phase = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> creatorUuid = const Value.absent(),
    Value<String?> ownerUuid = const Value.absent(),
  }) => CyclePeriod(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    trainingCycleUuid: trainingCycleUuid ?? this.trainingCycleUuid,
    periodNumber: periodNumber ?? this.periodNumber,
    phase: phase.present ? phase.value : this.phase,
    notes: notes.present ? notes.value : this.notes,
    creatorUuid: creatorUuid.present ? creatorUuid.value : this.creatorUuid,
    ownerUuid: ownerUuid.present ? ownerUuid.value : this.ownerUuid,
  );
  CyclePeriod copyWithCompanion(CyclePeriodsCompanion data) {
    return CyclePeriod(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      trainingCycleUuid: data.trainingCycleUuid.present ? data.trainingCycleUuid.value : this.trainingCycleUuid,
      periodNumber: data.periodNumber.present ? data.periodNumber.value : this.periodNumber,
      phase: data.phase.present ? data.phase.value : this.phase,
      notes: data.notes.present ? data.notes.value : this.notes,
      creatorUuid: data.creatorUuid.present ? data.creatorUuid.value : this.creatorUuid,
      ownerUuid: data.ownerUuid.present ? data.ownerUuid.value : this.ownerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclePeriod(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('phase: $phase, ')
          ..write('notes: $notes, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    trainingCycleUuid,
    periodNumber,
    phase,
    notes,
    creatorUuid,
    ownerUuid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclePeriod &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.trainingCycleUuid == this.trainingCycleUuid &&
          other.periodNumber == this.periodNumber &&
          other.phase == this.phase &&
          other.notes == this.notes &&
          other.creatorUuid == this.creatorUuid &&
          other.ownerUuid == this.ownerUuid);
}

class CyclePeriodsCompanion extends UpdateCompanion<CyclePeriod> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> trainingCycleUuid;
  final Value<int> periodNumber;
  final Value<int?> phase;
  final Value<String?> notes;
  final Value<String?> creatorUuid;
  final Value<String?> ownerUuid;
  const CyclePeriodsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.trainingCycleUuid = const Value.absent(),
    this.periodNumber = const Value.absent(),
    this.phase = const Value.absent(),
    this.notes = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  });
  CyclePeriodsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String trainingCycleUuid,
    required int periodNumber,
    this.phase = const Value.absent(),
    this.notes = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  }) : uuid = Value(uuid),
       trainingCycleUuid = Value(trainingCycleUuid),
       periodNumber = Value(periodNumber);
  static Insertable<CyclePeriod> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? trainingCycleUuid,
    Expression<int>? periodNumber,
    Expression<int>? phase,
    Expression<String>? notes,
    Expression<String>? creatorUuid,
    Expression<String>? ownerUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (trainingCycleUuid != null) 'training_cycle_uuid': trainingCycleUuid,
      if (periodNumber != null) 'period_number': periodNumber,
      if (phase != null) 'phase': phase,
      if (notes != null) 'notes': notes,
      if (creatorUuid != null) 'creator_uuid': creatorUuid,
      if (ownerUuid != null) 'owner_uuid': ownerUuid,
    });
  }

  CyclePeriodsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? trainingCycleUuid,
    Value<int>? periodNumber,
    Value<int?>? phase,
    Value<String?>? notes,
    Value<String?>? creatorUuid,
    Value<String?>? ownerUuid,
  }) {
    return CyclePeriodsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      trainingCycleUuid: trainingCycleUuid ?? this.trainingCycleUuid,
      periodNumber: periodNumber ?? this.periodNumber,
      phase: phase ?? this.phase,
      notes: notes ?? this.notes,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
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
    if (phase.present) {
      map['phase'] = Variable<int>(phase.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (creatorUuid.present) {
      map['creator_uuid'] = Variable<String>(creatorUuid.value);
    }
    if (ownerUuid.present) {
      map['owner_uuid'] = Variable<String>(ownerUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclePeriodsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('trainingCycleUuid: $trainingCycleUuid, ')
          ..write('periodNumber: $periodNumber, ')
          ..write('phase: $phase, ')
          ..write('notes: $notes, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }
}

class $SessionCardioTable extends SessionCardio with TableInfo<$SessionCardioTable, SessionCardioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionCardioTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES sessions (uuid)',
    ),
  );
  static const VerificationMeta _plannedDistanceMMeta = const VerificationMeta(
    'plannedDistanceM',
  );
  @override
  late final GeneratedColumn<double> plannedDistanceM = GeneratedColumn<double>(
    'planned_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDistanceMMeta = const VerificationMeta(
    'actualDistanceM',
  );
  @override
  late final GeneratedColumn<double> actualDistanceM = GeneratedColumn<double>(
    'actual_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationSecMeta = const VerificationMeta('plannedDurationSec');
  @override
  late final GeneratedColumn<int> plannedDurationSec = GeneratedColumn<int>(
    'planned_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecMeta = const VerificationMeta(
    'actualDurationSec',
  );
  @override
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
    'actual_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta(
    'elevationGainM',
  );
  @override
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
    'elevation_gain_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationLossMMeta = const VerificationMeta(
    'elevationLossM',
  );
  @override
  late final GeneratedColumn<double> elevationLossM = GeneratedColumn<double>(
    'elevation_loss_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageHrMeta = const VerificationMeta(
    'averageHr',
  );
  @override
  late final GeneratedColumn<int> averageHr = GeneratedColumn<int>(
    'average_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<int> maxHr = GeneratedColumn<int>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageCadenceMeta = const VerificationMeta(
    'averageCadence',
  );
  @override
  late final GeneratedColumn<double> averageCadence = GeneratedColumn<double>(
    'average_cadence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averagePowerWattsMeta = const VerificationMeta(
    'averagePowerWatts',
  );
  @override
  late final GeneratedColumn<double> averagePowerWatts = GeneratedColumn<double>(
    'average_power_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedPowerWattsMeta = const VerificationMeta('normalizedPowerWatts');
  @override
  late final GeneratedColumn<double> normalizedPowerWatts = GeneratedColumn<double>(
    'normalized_power_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageSpeedMpsMeta = const VerificationMeta(
    'averageSpeedMps',
  );
  @override
  late final GeneratedColumn<double> averageSpeedMps = GeneratedColumn<double>(
    'average_speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averagePaceSecPerMeterMeta = const VerificationMeta('averagePaceSecPerMeter');
  @override
  late final GeneratedColumn<double> averagePaceSecPerMeter = GeneratedColumn<double>(
    'average_pace_sec_per_meter',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poolLengthMMeta = const VerificationMeta(
    'poolLengthM',
  );
  @override
  late final GeneratedColumn<double> poolLengthM = GeneratedColumn<double>(
    'pool_length_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokeTypeMeta = const VerificationMeta(
    'strokeType',
  );
  @override
  late final GeneratedColumn<int> strokeType = GeneratedColumn<int>(
    'stroke_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lapCountMeta = const VerificationMeta(
    'lapCount',
  );
  @override
  late final GeneratedColumn<int> lapCount = GeneratedColumn<int>(
    'lap_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _swolfMeta = const VerificationMeta('swolf');
  @override
  late final GeneratedColumn<int> swolf = GeneratedColumn<int>(
    'swolf',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perceivedExertionMeta = const VerificationMeta(
    'perceivedExertion',
  );
  @override
  late final GeneratedColumn<int> perceivedExertion = GeneratedColumn<int>(
    'perceived_exertion',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    sessionUuid,
    plannedDistanceM,
    actualDistanceM,
    plannedDurationSec,
    actualDurationSec,
    elevationGainM,
    elevationLossM,
    averageHr,
    maxHr,
    averageCadence,
    averagePowerWatts,
    normalizedPowerWatts,
    averageSpeedMps,
    averagePaceSecPerMeter,
    poolLengthM,
    strokeType,
    lapCount,
    swolf,
    perceivedExertion,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_cardio';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionCardioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('planned_distance_m')) {
      context.handle(
        _plannedDistanceMMeta,
        plannedDistanceM.isAcceptableOrUnknown(
          data['planned_distance_m']!,
          _plannedDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('actual_distance_m')) {
      context.handle(
        _actualDistanceMMeta,
        actualDistanceM.isAcceptableOrUnknown(
          data['actual_distance_m']!,
          _actualDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('planned_duration_sec')) {
      context.handle(
        _plannedDurationSecMeta,
        plannedDurationSec.isAcceptableOrUnknown(
          data['planned_duration_sec']!,
          _plannedDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_sec')) {
      context.handle(
        _actualDurationSecMeta,
        actualDurationSec.isAcceptableOrUnknown(
          data['actual_duration_sec']!,
          _actualDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(
          data['elevation_gain_m']!,
          _elevationGainMMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss_m')) {
      context.handle(
        _elevationLossMMeta,
        elevationLossM.isAcceptableOrUnknown(
          data['elevation_loss_m']!,
          _elevationLossMMeta,
        ),
      );
    }
    if (data.containsKey('average_hr')) {
      context.handle(
        _averageHrMeta,
        averageHr.isAcceptableOrUnknown(data['average_hr']!, _averageHrMeta),
      );
    }
    if (data.containsKey('max_hr')) {
      context.handle(
        _maxHrMeta,
        maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta),
      );
    }
    if (data.containsKey('average_cadence')) {
      context.handle(
        _averageCadenceMeta,
        averageCadence.isAcceptableOrUnknown(
          data['average_cadence']!,
          _averageCadenceMeta,
        ),
      );
    }
    if (data.containsKey('average_power_watts')) {
      context.handle(
        _averagePowerWattsMeta,
        averagePowerWatts.isAcceptableOrUnknown(
          data['average_power_watts']!,
          _averagePowerWattsMeta,
        ),
      );
    }
    if (data.containsKey('normalized_power_watts')) {
      context.handle(
        _normalizedPowerWattsMeta,
        normalizedPowerWatts.isAcceptableOrUnknown(
          data['normalized_power_watts']!,
          _normalizedPowerWattsMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_mps')) {
      context.handle(
        _averageSpeedMpsMeta,
        averageSpeedMps.isAcceptableOrUnknown(
          data['average_speed_mps']!,
          _averageSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('average_pace_sec_per_meter')) {
      context.handle(
        _averagePaceSecPerMeterMeta,
        averagePaceSecPerMeter.isAcceptableOrUnknown(
          data['average_pace_sec_per_meter']!,
          _averagePaceSecPerMeterMeta,
        ),
      );
    }
    if (data.containsKey('pool_length_m')) {
      context.handle(
        _poolLengthMMeta,
        poolLengthM.isAcceptableOrUnknown(
          data['pool_length_m']!,
          _poolLengthMMeta,
        ),
      );
    }
    if (data.containsKey('stroke_type')) {
      context.handle(
        _strokeTypeMeta,
        strokeType.isAcceptableOrUnknown(data['stroke_type']!, _strokeTypeMeta),
      );
    }
    if (data.containsKey('lap_count')) {
      context.handle(
        _lapCountMeta,
        lapCount.isAcceptableOrUnknown(data['lap_count']!, _lapCountMeta),
      );
    }
    if (data.containsKey('swolf')) {
      context.handle(
        _swolfMeta,
        swolf.isAcceptableOrUnknown(data['swolf']!, _swolfMeta),
      );
    }
    if (data.containsKey('perceived_exertion')) {
      context.handle(
        _perceivedExertionMeta,
        perceivedExertion.isAcceptableOrUnknown(
          data['perceived_exertion']!,
          _perceivedExertionMeta,
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
  SessionCardioData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionCardioData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      plannedDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_distance_m'],
      ),
      actualDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance_m'],
      ),
      plannedDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_sec'],
      ),
      actualDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_sec'],
      ),
      elevationGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_m'],
      ),
      elevationLossM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss_m'],
      ),
      averageHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_hr'],
      ),
      maxHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hr'],
      ),
      averageCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_cadence'],
      ),
      averagePowerWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_power_watts'],
      ),
      normalizedPowerWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_power_watts'],
      ),
      averageSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_mps'],
      ),
      averagePaceSecPerMeter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_pace_sec_per_meter'],
      ),
      poolLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pool_length_m'],
      ),
      strokeType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_type'],
      ),
      lapCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lap_count'],
      ),
      swolf: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}swolf'],
      ),
      perceivedExertion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_exertion'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SessionCardioTable createAlias(String alias) {
    return $SessionCardioTable(attachedDatabase, alias);
  }
}

class SessionCardioData extends DataClass implements Insertable<SessionCardioData> {
  final int id;
  final String sessionUuid;
  final double? plannedDistanceM;
  final double? actualDistanceM;
  final int? plannedDurationSec;
  final int? actualDurationSec;
  final double? elevationGainM;
  final double? elevationLossM;
  final int? averageHr;
  final int? maxHr;
  final double? averageCadence;
  final double? averagePowerWatts;
  final double? normalizedPowerWatts;
  final double? averageSpeedMps;
  final double? averagePaceSecPerMeter;
  final double? poolLengthM;
  final int? strokeType;
  final int? lapCount;
  final int? swolf;
  final int? perceivedExertion;
  final String? notes;
  const SessionCardioData({
    required this.id,
    required this.sessionUuid,
    this.plannedDistanceM,
    this.actualDistanceM,
    this.plannedDurationSec,
    this.actualDurationSec,
    this.elevationGainM,
    this.elevationLossM,
    this.averageHr,
    this.maxHr,
    this.averageCadence,
    this.averagePowerWatts,
    this.normalizedPowerWatts,
    this.averageSpeedMps,
    this.averagePaceSecPerMeter,
    this.poolLengthM,
    this.strokeType,
    this.lapCount,
    this.swolf,
    this.perceivedExertion,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    if (!nullToAbsent || plannedDistanceM != null) {
      map['planned_distance_m'] = Variable<double>(plannedDistanceM);
    }
    if (!nullToAbsent || actualDistanceM != null) {
      map['actual_distance_m'] = Variable<double>(actualDistanceM);
    }
    if (!nullToAbsent || plannedDurationSec != null) {
      map['planned_duration_sec'] = Variable<int>(plannedDurationSec);
    }
    if (!nullToAbsent || actualDurationSec != null) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec);
    }
    if (!nullToAbsent || elevationGainM != null) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM);
    }
    if (!nullToAbsent || elevationLossM != null) {
      map['elevation_loss_m'] = Variable<double>(elevationLossM);
    }
    if (!nullToAbsent || averageHr != null) {
      map['average_hr'] = Variable<int>(averageHr);
    }
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<int>(maxHr);
    }
    if (!nullToAbsent || averageCadence != null) {
      map['average_cadence'] = Variable<double>(averageCadence);
    }
    if (!nullToAbsent || averagePowerWatts != null) {
      map['average_power_watts'] = Variable<double>(averagePowerWatts);
    }
    if (!nullToAbsent || normalizedPowerWatts != null) {
      map['normalized_power_watts'] = Variable<double>(normalizedPowerWatts);
    }
    if (!nullToAbsent || averageSpeedMps != null) {
      map['average_speed_mps'] = Variable<double>(averageSpeedMps);
    }
    if (!nullToAbsent || averagePaceSecPerMeter != null) {
      map['average_pace_sec_per_meter'] = Variable<double>(
        averagePaceSecPerMeter,
      );
    }
    if (!nullToAbsent || poolLengthM != null) {
      map['pool_length_m'] = Variable<double>(poolLengthM);
    }
    if (!nullToAbsent || strokeType != null) {
      map['stroke_type'] = Variable<int>(strokeType);
    }
    if (!nullToAbsent || lapCount != null) {
      map['lap_count'] = Variable<int>(lapCount);
    }
    if (!nullToAbsent || swolf != null) {
      map['swolf'] = Variable<int>(swolf);
    }
    if (!nullToAbsent || perceivedExertion != null) {
      map['perceived_exertion'] = Variable<int>(perceivedExertion);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionCardioCompanion toCompanion(bool nullToAbsent) {
    return SessionCardioCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      plannedDistanceM: plannedDistanceM == null && nullToAbsent ? const Value.absent() : Value(plannedDistanceM),
      actualDistanceM: actualDistanceM == null && nullToAbsent ? const Value.absent() : Value(actualDistanceM),
      plannedDurationSec: plannedDurationSec == null && nullToAbsent ? const Value.absent() : Value(plannedDurationSec),
      actualDurationSec: actualDurationSec == null && nullToAbsent ? const Value.absent() : Value(actualDurationSec),
      elevationGainM: elevationGainM == null && nullToAbsent ? const Value.absent() : Value(elevationGainM),
      elevationLossM: elevationLossM == null && nullToAbsent ? const Value.absent() : Value(elevationLossM),
      averageHr: averageHr == null && nullToAbsent ? const Value.absent() : Value(averageHr),
      maxHr: maxHr == null && nullToAbsent ? const Value.absent() : Value(maxHr),
      averageCadence: averageCadence == null && nullToAbsent ? const Value.absent() : Value(averageCadence),
      averagePowerWatts: averagePowerWatts == null && nullToAbsent ? const Value.absent() : Value(averagePowerWatts),
      normalizedPowerWatts: normalizedPowerWatts == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedPowerWatts),
      averageSpeedMps: averageSpeedMps == null && nullToAbsent ? const Value.absent() : Value(averageSpeedMps),
      averagePaceSecPerMeter: averagePaceSecPerMeter == null && nullToAbsent
          ? const Value.absent()
          : Value(averagePaceSecPerMeter),
      poolLengthM: poolLengthM == null && nullToAbsent ? const Value.absent() : Value(poolLengthM),
      strokeType: strokeType == null && nullToAbsent ? const Value.absent() : Value(strokeType),
      lapCount: lapCount == null && nullToAbsent ? const Value.absent() : Value(lapCount),
      swolf: swolf == null && nullToAbsent ? const Value.absent() : Value(swolf),
      perceivedExertion: perceivedExertion == null && nullToAbsent ? const Value.absent() : Value(perceivedExertion),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory SessionCardioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionCardioData(
      id: serializer.fromJson<int>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      plannedDistanceM: serializer.fromJson<double?>(json['plannedDistanceM']),
      actualDistanceM: serializer.fromJson<double?>(json['actualDistanceM']),
      plannedDurationSec: serializer.fromJson<int?>(json['plannedDurationSec']),
      actualDurationSec: serializer.fromJson<int?>(json['actualDurationSec']),
      elevationGainM: serializer.fromJson<double?>(json['elevationGainM']),
      elevationLossM: serializer.fromJson<double?>(json['elevationLossM']),
      averageHr: serializer.fromJson<int?>(json['averageHr']),
      maxHr: serializer.fromJson<int?>(json['maxHr']),
      averageCadence: serializer.fromJson<double?>(json['averageCadence']),
      averagePowerWatts: serializer.fromJson<double?>(
        json['averagePowerWatts'],
      ),
      normalizedPowerWatts: serializer.fromJson<double?>(
        json['normalizedPowerWatts'],
      ),
      averageSpeedMps: serializer.fromJson<double?>(json['averageSpeedMps']),
      averagePaceSecPerMeter: serializer.fromJson<double?>(
        json['averagePaceSecPerMeter'],
      ),
      poolLengthM: serializer.fromJson<double?>(json['poolLengthM']),
      strokeType: serializer.fromJson<int?>(json['strokeType']),
      lapCount: serializer.fromJson<int?>(json['lapCount']),
      swolf: serializer.fromJson<int?>(json['swolf']),
      perceivedExertion: serializer.fromJson<int?>(json['perceivedExertion']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'plannedDistanceM': serializer.toJson<double?>(plannedDistanceM),
      'actualDistanceM': serializer.toJson<double?>(actualDistanceM),
      'plannedDurationSec': serializer.toJson<int?>(plannedDurationSec),
      'actualDurationSec': serializer.toJson<int?>(actualDurationSec),
      'elevationGainM': serializer.toJson<double?>(elevationGainM),
      'elevationLossM': serializer.toJson<double?>(elevationLossM),
      'averageHr': serializer.toJson<int?>(averageHr),
      'maxHr': serializer.toJson<int?>(maxHr),
      'averageCadence': serializer.toJson<double?>(averageCadence),
      'averagePowerWatts': serializer.toJson<double?>(averagePowerWatts),
      'normalizedPowerWatts': serializer.toJson<double?>(normalizedPowerWatts),
      'averageSpeedMps': serializer.toJson<double?>(averageSpeedMps),
      'averagePaceSecPerMeter': serializer.toJson<double?>(
        averagePaceSecPerMeter,
      ),
      'poolLengthM': serializer.toJson<double?>(poolLengthM),
      'strokeType': serializer.toJson<int?>(strokeType),
      'lapCount': serializer.toJson<int?>(lapCount),
      'swolf': serializer.toJson<int?>(swolf),
      'perceivedExertion': serializer.toJson<int?>(perceivedExertion),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SessionCardioData copyWith({
    int? id,
    String? sessionUuid,
    Value<double?> plannedDistanceM = const Value.absent(),
    Value<double?> actualDistanceM = const Value.absent(),
    Value<int?> plannedDurationSec = const Value.absent(),
    Value<int?> actualDurationSec = const Value.absent(),
    Value<double?> elevationGainM = const Value.absent(),
    Value<double?> elevationLossM = const Value.absent(),
    Value<int?> averageHr = const Value.absent(),
    Value<int?> maxHr = const Value.absent(),
    Value<double?> averageCadence = const Value.absent(),
    Value<double?> averagePowerWatts = const Value.absent(),
    Value<double?> normalizedPowerWatts = const Value.absent(),
    Value<double?> averageSpeedMps = const Value.absent(),
    Value<double?> averagePaceSecPerMeter = const Value.absent(),
    Value<double?> poolLengthM = const Value.absent(),
    Value<int?> strokeType = const Value.absent(),
    Value<int?> lapCount = const Value.absent(),
    Value<int?> swolf = const Value.absent(),
    Value<int?> perceivedExertion = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SessionCardioData(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    plannedDistanceM: plannedDistanceM.present ? plannedDistanceM.value : this.plannedDistanceM,
    actualDistanceM: actualDistanceM.present ? actualDistanceM.value : this.actualDistanceM,
    plannedDurationSec: plannedDurationSec.present ? plannedDurationSec.value : this.plannedDurationSec,
    actualDurationSec: actualDurationSec.present ? actualDurationSec.value : this.actualDurationSec,
    elevationGainM: elevationGainM.present ? elevationGainM.value : this.elevationGainM,
    elevationLossM: elevationLossM.present ? elevationLossM.value : this.elevationLossM,
    averageHr: averageHr.present ? averageHr.value : this.averageHr,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    averageCadence: averageCadence.present ? averageCadence.value : this.averageCadence,
    averagePowerWatts: averagePowerWatts.present ? averagePowerWatts.value : this.averagePowerWatts,
    normalizedPowerWatts: normalizedPowerWatts.present ? normalizedPowerWatts.value : this.normalizedPowerWatts,
    averageSpeedMps: averageSpeedMps.present ? averageSpeedMps.value : this.averageSpeedMps,
    averagePaceSecPerMeter: averagePaceSecPerMeter.present ? averagePaceSecPerMeter.value : this.averagePaceSecPerMeter,
    poolLengthM: poolLengthM.present ? poolLengthM.value : this.poolLengthM,
    strokeType: strokeType.present ? strokeType.value : this.strokeType,
    lapCount: lapCount.present ? lapCount.value : this.lapCount,
    swolf: swolf.present ? swolf.value : this.swolf,
    perceivedExertion: perceivedExertion.present ? perceivedExertion.value : this.perceivedExertion,
    notes: notes.present ? notes.value : this.notes,
  );
  SessionCardioData copyWithCompanion(SessionCardioCompanion data) {
    return SessionCardioData(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      plannedDistanceM: data.plannedDistanceM.present ? data.plannedDistanceM.value : this.plannedDistanceM,
      actualDistanceM: data.actualDistanceM.present ? data.actualDistanceM.value : this.actualDistanceM,
      plannedDurationSec: data.plannedDurationSec.present ? data.plannedDurationSec.value : this.plannedDurationSec,
      actualDurationSec: data.actualDurationSec.present ? data.actualDurationSec.value : this.actualDurationSec,
      elevationGainM: data.elevationGainM.present ? data.elevationGainM.value : this.elevationGainM,
      elevationLossM: data.elevationLossM.present ? data.elevationLossM.value : this.elevationLossM,
      averageHr: data.averageHr.present ? data.averageHr.value : this.averageHr,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      averageCadence: data.averageCadence.present ? data.averageCadence.value : this.averageCadence,
      averagePowerWatts: data.averagePowerWatts.present ? data.averagePowerWatts.value : this.averagePowerWatts,
      normalizedPowerWatts: data.normalizedPowerWatts.present
          ? data.normalizedPowerWatts.value
          : this.normalizedPowerWatts,
      averageSpeedMps: data.averageSpeedMps.present ? data.averageSpeedMps.value : this.averageSpeedMps,
      averagePaceSecPerMeter: data.averagePaceSecPerMeter.present
          ? data.averagePaceSecPerMeter.value
          : this.averagePaceSecPerMeter,
      poolLengthM: data.poolLengthM.present ? data.poolLengthM.value : this.poolLengthM,
      strokeType: data.strokeType.present ? data.strokeType.value : this.strokeType,
      lapCount: data.lapCount.present ? data.lapCount.value : this.lapCount,
      swolf: data.swolf.present ? data.swolf.value : this.swolf,
      perceivedExertion: data.perceivedExertion.present ? data.perceivedExertion.value : this.perceivedExertion,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionCardioData(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('elevationLossM: $elevationLossM, ')
          ..write('averageHr: $averageHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('averageCadence: $averageCadence, ')
          ..write('averagePowerWatts: $averagePowerWatts, ')
          ..write('normalizedPowerWatts: $normalizedPowerWatts, ')
          ..write('averageSpeedMps: $averageSpeedMps, ')
          ..write('averagePaceSecPerMeter: $averagePaceSecPerMeter, ')
          ..write('poolLengthM: $poolLengthM, ')
          ..write('strokeType: $strokeType, ')
          ..write('lapCount: $lapCount, ')
          ..write('swolf: $swolf, ')
          ..write('perceivedExertion: $perceivedExertion, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionUuid,
    plannedDistanceM,
    actualDistanceM,
    plannedDurationSec,
    actualDurationSec,
    elevationGainM,
    elevationLossM,
    averageHr,
    maxHr,
    averageCadence,
    averagePowerWatts,
    normalizedPowerWatts,
    averageSpeedMps,
    averagePaceSecPerMeter,
    poolLengthM,
    strokeType,
    lapCount,
    swolf,
    perceivedExertion,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionCardioData &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.plannedDistanceM == this.plannedDistanceM &&
          other.actualDistanceM == this.actualDistanceM &&
          other.plannedDurationSec == this.plannedDurationSec &&
          other.actualDurationSec == this.actualDurationSec &&
          other.elevationGainM == this.elevationGainM &&
          other.elevationLossM == this.elevationLossM &&
          other.averageHr == this.averageHr &&
          other.maxHr == this.maxHr &&
          other.averageCadence == this.averageCadence &&
          other.averagePowerWatts == this.averagePowerWatts &&
          other.normalizedPowerWatts == this.normalizedPowerWatts &&
          other.averageSpeedMps == this.averageSpeedMps &&
          other.averagePaceSecPerMeter == this.averagePaceSecPerMeter &&
          other.poolLengthM == this.poolLengthM &&
          other.strokeType == this.strokeType &&
          other.lapCount == this.lapCount &&
          other.swolf == this.swolf &&
          other.perceivedExertion == this.perceivedExertion &&
          other.notes == this.notes);
}

class SessionCardioCompanion extends UpdateCompanion<SessionCardioData> {
  final Value<int> id;
  final Value<String> sessionUuid;
  final Value<double?> plannedDistanceM;
  final Value<double?> actualDistanceM;
  final Value<int?> plannedDurationSec;
  final Value<int?> actualDurationSec;
  final Value<double?> elevationGainM;
  final Value<double?> elevationLossM;
  final Value<int?> averageHr;
  final Value<int?> maxHr;
  final Value<double?> averageCadence;
  final Value<double?> averagePowerWatts;
  final Value<double?> normalizedPowerWatts;
  final Value<double?> averageSpeedMps;
  final Value<double?> averagePaceSecPerMeter;
  final Value<double?> poolLengthM;
  final Value<int?> strokeType;
  final Value<int?> lapCount;
  final Value<int?> swolf;
  final Value<int?> perceivedExertion;
  final Value<String?> notes;
  const SessionCardioCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.plannedDistanceM = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.elevationLossM = const Value.absent(),
    this.averageHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.averageCadence = const Value.absent(),
    this.averagePowerWatts = const Value.absent(),
    this.normalizedPowerWatts = const Value.absent(),
    this.averageSpeedMps = const Value.absent(),
    this.averagePaceSecPerMeter = const Value.absent(),
    this.poolLengthM = const Value.absent(),
    this.strokeType = const Value.absent(),
    this.lapCount = const Value.absent(),
    this.swolf = const Value.absent(),
    this.perceivedExertion = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SessionCardioCompanion.insert({
    this.id = const Value.absent(),
    required String sessionUuid,
    this.plannedDistanceM = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.elevationLossM = const Value.absent(),
    this.averageHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.averageCadence = const Value.absent(),
    this.averagePowerWatts = const Value.absent(),
    this.normalizedPowerWatts = const Value.absent(),
    this.averageSpeedMps = const Value.absent(),
    this.averagePaceSecPerMeter = const Value.absent(),
    this.poolLengthM = const Value.absent(),
    this.strokeType = const Value.absent(),
    this.lapCount = const Value.absent(),
    this.swolf = const Value.absent(),
    this.perceivedExertion = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sessionUuid = Value(sessionUuid);
  static Insertable<SessionCardioData> custom({
    Expression<int>? id,
    Expression<String>? sessionUuid,
    Expression<double>? plannedDistanceM,
    Expression<double>? actualDistanceM,
    Expression<int>? plannedDurationSec,
    Expression<int>? actualDurationSec,
    Expression<double>? elevationGainM,
    Expression<double>? elevationLossM,
    Expression<int>? averageHr,
    Expression<int>? maxHr,
    Expression<double>? averageCadence,
    Expression<double>? averagePowerWatts,
    Expression<double>? normalizedPowerWatts,
    Expression<double>? averageSpeedMps,
    Expression<double>? averagePaceSecPerMeter,
    Expression<double>? poolLengthM,
    Expression<int>? strokeType,
    Expression<int>? lapCount,
    Expression<int>? swolf,
    Expression<int>? perceivedExertion,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (plannedDistanceM != null) 'planned_distance_m': plannedDistanceM,
      if (actualDistanceM != null) 'actual_distance_m': actualDistanceM,
      if (plannedDurationSec != null) 'planned_duration_sec': plannedDurationSec,
      if (actualDurationSec != null) 'actual_duration_sec': actualDurationSec,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (elevationLossM != null) 'elevation_loss_m': elevationLossM,
      if (averageHr != null) 'average_hr': averageHr,
      if (maxHr != null) 'max_hr': maxHr,
      if (averageCadence != null) 'average_cadence': averageCadence,
      if (averagePowerWatts != null) 'average_power_watts': averagePowerWatts,
      if (normalizedPowerWatts != null) 'normalized_power_watts': normalizedPowerWatts,
      if (averageSpeedMps != null) 'average_speed_mps': averageSpeedMps,
      if (averagePaceSecPerMeter != null) 'average_pace_sec_per_meter': averagePaceSecPerMeter,
      if (poolLengthM != null) 'pool_length_m': poolLengthM,
      if (strokeType != null) 'stroke_type': strokeType,
      if (lapCount != null) 'lap_count': lapCount,
      if (swolf != null) 'swolf': swolf,
      if (perceivedExertion != null) 'perceived_exertion': perceivedExertion,
      if (notes != null) 'notes': notes,
    });
  }

  SessionCardioCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionUuid,
    Value<double?>? plannedDistanceM,
    Value<double?>? actualDistanceM,
    Value<int?>? plannedDurationSec,
    Value<int?>? actualDurationSec,
    Value<double?>? elevationGainM,
    Value<double?>? elevationLossM,
    Value<int?>? averageHr,
    Value<int?>? maxHr,
    Value<double?>? averageCadence,
    Value<double?>? averagePowerWatts,
    Value<double?>? normalizedPowerWatts,
    Value<double?>? averageSpeedMps,
    Value<double?>? averagePaceSecPerMeter,
    Value<double?>? poolLengthM,
    Value<int?>? strokeType,
    Value<int?>? lapCount,
    Value<int?>? swolf,
    Value<int?>? perceivedExertion,
    Value<String?>? notes,
  }) {
    return SessionCardioCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      elevationLossM: elevationLossM ?? this.elevationLossM,
      averageHr: averageHr ?? this.averageHr,
      maxHr: maxHr ?? this.maxHr,
      averageCadence: averageCadence ?? this.averageCadence,
      averagePowerWatts: averagePowerWatts ?? this.averagePowerWatts,
      normalizedPowerWatts: normalizedPowerWatts ?? this.normalizedPowerWatts,
      averageSpeedMps: averageSpeedMps ?? this.averageSpeedMps,
      averagePaceSecPerMeter: averagePaceSecPerMeter ?? this.averagePaceSecPerMeter,
      poolLengthM: poolLengthM ?? this.poolLengthM,
      strokeType: strokeType ?? this.strokeType,
      lapCount: lapCount ?? this.lapCount,
      swolf: swolf ?? this.swolf,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (plannedDistanceM.present) {
      map['planned_distance_m'] = Variable<double>(plannedDistanceM.value);
    }
    if (actualDistanceM.present) {
      map['actual_distance_m'] = Variable<double>(actualDistanceM.value);
    }
    if (plannedDurationSec.present) {
      map['planned_duration_sec'] = Variable<int>(plannedDurationSec.value);
    }
    if (actualDurationSec.present) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    if (elevationLossM.present) {
      map['elevation_loss_m'] = Variable<double>(elevationLossM.value);
    }
    if (averageHr.present) {
      map['average_hr'] = Variable<int>(averageHr.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<int>(maxHr.value);
    }
    if (averageCadence.present) {
      map['average_cadence'] = Variable<double>(averageCadence.value);
    }
    if (averagePowerWatts.present) {
      map['average_power_watts'] = Variable<double>(averagePowerWatts.value);
    }
    if (normalizedPowerWatts.present) {
      map['normalized_power_watts'] = Variable<double>(
        normalizedPowerWatts.value,
      );
    }
    if (averageSpeedMps.present) {
      map['average_speed_mps'] = Variable<double>(averageSpeedMps.value);
    }
    if (averagePaceSecPerMeter.present) {
      map['average_pace_sec_per_meter'] = Variable<double>(
        averagePaceSecPerMeter.value,
      );
    }
    if (poolLengthM.present) {
      map['pool_length_m'] = Variable<double>(poolLengthM.value);
    }
    if (strokeType.present) {
      map['stroke_type'] = Variable<int>(strokeType.value);
    }
    if (lapCount.present) {
      map['lap_count'] = Variable<int>(lapCount.value);
    }
    if (swolf.present) {
      map['swolf'] = Variable<int>(swolf.value);
    }
    if (perceivedExertion.present) {
      map['perceived_exertion'] = Variable<int>(perceivedExertion.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCardioCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('plannedDistanceM: $plannedDistanceM, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('elevationLossM: $elevationLossM, ')
          ..write('averageHr: $averageHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('averageCadence: $averageCadence, ')
          ..write('averagePowerWatts: $averagePowerWatts, ')
          ..write('normalizedPowerWatts: $normalizedPowerWatts, ')
          ..write('averageSpeedMps: $averageSpeedMps, ')
          ..write('averagePaceSecPerMeter: $averagePaceSecPerMeter, ')
          ..write('poolLengthM: $poolLengthM, ')
          ..write('strokeType: $strokeType, ')
          ..write('lapCount: $lapCount, ')
          ..write('swolf: $swolf, ')
          ..write('perceivedExertion: $perceivedExertion, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SessionIntervalsTable extends SessionIntervals with TableInfo<$SessionIntervalsTable, SessionInterval> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionIntervalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (uuid)',
    ),
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
  static const VerificationMeta _intentTypeMeta = const VerificationMeta(
    'intentType',
  );
  @override
  late final GeneratedColumn<int> intentType = GeneratedColumn<int>(
    'intent_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetKindMeta = const VerificationMeta(
    'targetKind',
  );
  @override
  late final GeneratedColumn<int> targetKind = GeneratedColumn<int>(
    'target_kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDurationSecMeta = const VerificationMeta(
    'targetDurationSec',
  );
  @override
  late final GeneratedColumn<int> targetDurationSec = GeneratedColumn<int>(
    'target_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDistanceMMeta = const VerificationMeta(
    'targetDistanceM',
  );
  @override
  late final GeneratedColumn<double> targetDistanceM = GeneratedColumn<double>(
    'target_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetHrZoneMeta = const VerificationMeta(
    'targetHrZone',
  );
  @override
  late final GeneratedColumn<int> targetHrZone = GeneratedColumn<int>(
    'target_hr_zone',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPaceZoneMeta = const VerificationMeta(
    'targetPaceZone',
  );
  @override
  late final GeneratedColumn<int> targetPaceZone = GeneratedColumn<int>(
    'target_pace_zone',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetPowerZoneMeta = const VerificationMeta(
    'targetPowerZone',
  );
  @override
  late final GeneratedColumn<int> targetPowerZone = GeneratedColumn<int>(
    'target_power_zone',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetValueMinMeta = const VerificationMeta(
    'targetValueMin',
  );
  @override
  late final GeneratedColumn<double> targetValueMin = GeneratedColumn<double>(
    'target_value_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetValueMaxMeta = const VerificationMeta(
    'targetValueMax',
  );
  @override
  late final GeneratedColumn<double> targetValueMax = GeneratedColumn<double>(
    'target_value_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetFreeformMeta = const VerificationMeta(
    'targetFreeform',
  );
  @override
  late final GeneratedColumn<String> targetFreeform = GeneratedColumn<String>(
    'target_freeform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecMeta = const VerificationMeta(
    'actualDurationSec',
  );
  @override
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
    'actual_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDistanceMMeta = const VerificationMeta(
    'actualDistanceM',
  );
  @override
  late final GeneratedColumn<double> actualDistanceM = GeneratedColumn<double>(
    'actual_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualAverageHrMeta = const VerificationMeta(
    'actualAverageHr',
  );
  @override
  late final GeneratedColumn<int> actualAverageHr = GeneratedColumn<int>(
    'actual_average_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualAveragePaceSecPerMeterMeta = const VerificationMeta(
    'actualAveragePaceSecPerMeter',
  );
  @override
  late final GeneratedColumn<double> actualAveragePaceSecPerMeter = GeneratedColumn<double>(
    'actual_average_pace_sec_per_meter',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualAveragePowerWattsMeta = const VerificationMeta('actualAveragePowerWatts');
  @override
  late final GeneratedColumn<double> actualAveragePowerWatts = GeneratedColumn<double>(
    'actual_average_power_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatCountMeta = const VerificationMeta(
    'repeatCount',
  );
  @override
  late final GeneratedColumn<int> repeatCount = GeneratedColumn<int>(
    'repeat_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIntervalUuidMeta = const VerificationMeta('parentIntervalUuid');
  @override
  late final GeneratedColumn<String> parentIntervalUuid = GeneratedColumn<String>(
    'parent_interval_uuid',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    sessionUuid,
    orderIndex,
    intentType,
    targetKind,
    targetDurationSec,
    targetDistanceM,
    targetHrZone,
    targetPaceZone,
    targetPowerZone,
    targetValueMin,
    targetValueMax,
    targetFreeform,
    actualDurationSec,
    actualDistanceM,
    actualAverageHr,
    actualAveragePaceSecPerMeter,
    actualAveragePowerWatts,
    repeatCount,
    parentIntervalUuid,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_intervals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionInterval> instance, {
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
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('intent_type')) {
      context.handle(
        _intentTypeMeta,
        intentType.isAcceptableOrUnknown(data['intent_type']!, _intentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_intentTypeMeta);
    }
    if (data.containsKey('target_kind')) {
      context.handle(
        _targetKindMeta,
        targetKind.isAcceptableOrUnknown(data['target_kind']!, _targetKindMeta),
      );
    } else if (isInserting) {
      context.missing(_targetKindMeta);
    }
    if (data.containsKey('target_duration_sec')) {
      context.handle(
        _targetDurationSecMeta,
        targetDurationSec.isAcceptableOrUnknown(
          data['target_duration_sec']!,
          _targetDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('target_distance_m')) {
      context.handle(
        _targetDistanceMMeta,
        targetDistanceM.isAcceptableOrUnknown(
          data['target_distance_m']!,
          _targetDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('target_hr_zone')) {
      context.handle(
        _targetHrZoneMeta,
        targetHrZone.isAcceptableOrUnknown(
          data['target_hr_zone']!,
          _targetHrZoneMeta,
        ),
      );
    }
    if (data.containsKey('target_pace_zone')) {
      context.handle(
        _targetPaceZoneMeta,
        targetPaceZone.isAcceptableOrUnknown(
          data['target_pace_zone']!,
          _targetPaceZoneMeta,
        ),
      );
    }
    if (data.containsKey('target_power_zone')) {
      context.handle(
        _targetPowerZoneMeta,
        targetPowerZone.isAcceptableOrUnknown(
          data['target_power_zone']!,
          _targetPowerZoneMeta,
        ),
      );
    }
    if (data.containsKey('target_value_min')) {
      context.handle(
        _targetValueMinMeta,
        targetValueMin.isAcceptableOrUnknown(
          data['target_value_min']!,
          _targetValueMinMeta,
        ),
      );
    }
    if (data.containsKey('target_value_max')) {
      context.handle(
        _targetValueMaxMeta,
        targetValueMax.isAcceptableOrUnknown(
          data['target_value_max']!,
          _targetValueMaxMeta,
        ),
      );
    }
    if (data.containsKey('target_freeform')) {
      context.handle(
        _targetFreeformMeta,
        targetFreeform.isAcceptableOrUnknown(
          data['target_freeform']!,
          _targetFreeformMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_sec')) {
      context.handle(
        _actualDurationSecMeta,
        actualDurationSec.isAcceptableOrUnknown(
          data['actual_duration_sec']!,
          _actualDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('actual_distance_m')) {
      context.handle(
        _actualDistanceMMeta,
        actualDistanceM.isAcceptableOrUnknown(
          data['actual_distance_m']!,
          _actualDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('actual_average_hr')) {
      context.handle(
        _actualAverageHrMeta,
        actualAverageHr.isAcceptableOrUnknown(
          data['actual_average_hr']!,
          _actualAverageHrMeta,
        ),
      );
    }
    if (data.containsKey('actual_average_pace_sec_per_meter')) {
      context.handle(
        _actualAveragePaceSecPerMeterMeta,
        actualAveragePaceSecPerMeter.isAcceptableOrUnknown(
          data['actual_average_pace_sec_per_meter']!,
          _actualAveragePaceSecPerMeterMeta,
        ),
      );
    }
    if (data.containsKey('actual_average_power_watts')) {
      context.handle(
        _actualAveragePowerWattsMeta,
        actualAveragePowerWatts.isAcceptableOrUnknown(
          data['actual_average_power_watts']!,
          _actualAveragePowerWattsMeta,
        ),
      );
    }
    if (data.containsKey('repeat_count')) {
      context.handle(
        _repeatCountMeta,
        repeatCount.isAcceptableOrUnknown(
          data['repeat_count']!,
          _repeatCountMeta,
        ),
      );
    }
    if (data.containsKey('parent_interval_uuid')) {
      context.handle(
        _parentIntervalUuidMeta,
        parentIntervalUuid.isAcceptableOrUnknown(
          data['parent_interval_uuid']!,
          _parentIntervalUuidMeta,
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
  SessionInterval map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionInterval(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      intentType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intent_type'],
      )!,
      targetKind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_kind'],
      )!,
      targetDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_duration_sec'],
      ),
      targetDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_m'],
      ),
      targetHrZone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_hr_zone'],
      ),
      targetPaceZone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_pace_zone'],
      ),
      targetPowerZone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_power_zone'],
      ),
      targetValueMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value_min'],
      ),
      targetValueMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value_max'],
      ),
      targetFreeform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_freeform'],
      ),
      actualDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_sec'],
      ),
      actualDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance_m'],
      ),
      actualAverageHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_average_hr'],
      ),
      actualAveragePaceSecPerMeter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_average_pace_sec_per_meter'],
      ),
      actualAveragePowerWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_average_power_watts'],
      ),
      repeatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_count'],
      ),
      parentIntervalUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_interval_uuid'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SessionIntervalsTable createAlias(String alias) {
    return $SessionIntervalsTable(attachedDatabase, alias);
  }
}

class SessionInterval extends DataClass implements Insertable<SessionInterval> {
  final int id;
  final String uuid;
  final String sessionUuid;
  final int orderIndex;
  final int intentType;
  final int targetKind;
  final int? targetDurationSec;
  final double? targetDistanceM;
  final int? targetHrZone;
  final int? targetPaceZone;
  final int? targetPowerZone;
  final double? targetValueMin;
  final double? targetValueMax;
  final String? targetFreeform;
  final int? actualDurationSec;
  final double? actualDistanceM;
  final int? actualAverageHr;
  final double? actualAveragePaceSecPerMeter;
  final double? actualAveragePowerWatts;
  final int? repeatCount;
  final String? parentIntervalUuid;
  final String? notes;
  const SessionInterval({
    required this.id,
    required this.uuid,
    required this.sessionUuid,
    required this.orderIndex,
    required this.intentType,
    required this.targetKind,
    this.targetDurationSec,
    this.targetDistanceM,
    this.targetHrZone,
    this.targetPaceZone,
    this.targetPowerZone,
    this.targetValueMin,
    this.targetValueMax,
    this.targetFreeform,
    this.actualDurationSec,
    this.actualDistanceM,
    this.actualAverageHr,
    this.actualAveragePaceSecPerMeter,
    this.actualAveragePowerWatts,
    this.repeatCount,
    this.parentIntervalUuid,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['order_index'] = Variable<int>(orderIndex);
    map['intent_type'] = Variable<int>(intentType);
    map['target_kind'] = Variable<int>(targetKind);
    if (!nullToAbsent || targetDurationSec != null) {
      map['target_duration_sec'] = Variable<int>(targetDurationSec);
    }
    if (!nullToAbsent || targetDistanceM != null) {
      map['target_distance_m'] = Variable<double>(targetDistanceM);
    }
    if (!nullToAbsent || targetHrZone != null) {
      map['target_hr_zone'] = Variable<int>(targetHrZone);
    }
    if (!nullToAbsent || targetPaceZone != null) {
      map['target_pace_zone'] = Variable<int>(targetPaceZone);
    }
    if (!nullToAbsent || targetPowerZone != null) {
      map['target_power_zone'] = Variable<int>(targetPowerZone);
    }
    if (!nullToAbsent || targetValueMin != null) {
      map['target_value_min'] = Variable<double>(targetValueMin);
    }
    if (!nullToAbsent || targetValueMax != null) {
      map['target_value_max'] = Variable<double>(targetValueMax);
    }
    if (!nullToAbsent || targetFreeform != null) {
      map['target_freeform'] = Variable<String>(targetFreeform);
    }
    if (!nullToAbsent || actualDurationSec != null) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec);
    }
    if (!nullToAbsent || actualDistanceM != null) {
      map['actual_distance_m'] = Variable<double>(actualDistanceM);
    }
    if (!nullToAbsent || actualAverageHr != null) {
      map['actual_average_hr'] = Variable<int>(actualAverageHr);
    }
    if (!nullToAbsent || actualAveragePaceSecPerMeter != null) {
      map['actual_average_pace_sec_per_meter'] = Variable<double>(
        actualAveragePaceSecPerMeter,
      );
    }
    if (!nullToAbsent || actualAveragePowerWatts != null) {
      map['actual_average_power_watts'] = Variable<double>(
        actualAveragePowerWatts,
      );
    }
    if (!nullToAbsent || repeatCount != null) {
      map['repeat_count'] = Variable<int>(repeatCount);
    }
    if (!nullToAbsent || parentIntervalUuid != null) {
      map['parent_interval_uuid'] = Variable<String>(parentIntervalUuid);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionIntervalsCompanion toCompanion(bool nullToAbsent) {
    return SessionIntervalsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      sessionUuid: Value(sessionUuid),
      orderIndex: Value(orderIndex),
      intentType: Value(intentType),
      targetKind: Value(targetKind),
      targetDurationSec: targetDurationSec == null && nullToAbsent ? const Value.absent() : Value(targetDurationSec),
      targetDistanceM: targetDistanceM == null && nullToAbsent ? const Value.absent() : Value(targetDistanceM),
      targetHrZone: targetHrZone == null && nullToAbsent ? const Value.absent() : Value(targetHrZone),
      targetPaceZone: targetPaceZone == null && nullToAbsent ? const Value.absent() : Value(targetPaceZone),
      targetPowerZone: targetPowerZone == null && nullToAbsent ? const Value.absent() : Value(targetPowerZone),
      targetValueMin: targetValueMin == null && nullToAbsent ? const Value.absent() : Value(targetValueMin),
      targetValueMax: targetValueMax == null && nullToAbsent ? const Value.absent() : Value(targetValueMax),
      targetFreeform: targetFreeform == null && nullToAbsent ? const Value.absent() : Value(targetFreeform),
      actualDurationSec: actualDurationSec == null && nullToAbsent ? const Value.absent() : Value(actualDurationSec),
      actualDistanceM: actualDistanceM == null && nullToAbsent ? const Value.absent() : Value(actualDistanceM),
      actualAverageHr: actualAverageHr == null && nullToAbsent ? const Value.absent() : Value(actualAverageHr),
      actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter == null && nullToAbsent
          ? const Value.absent()
          : Value(actualAveragePaceSecPerMeter),
      actualAveragePowerWatts: actualAveragePowerWatts == null && nullToAbsent
          ? const Value.absent()
          : Value(actualAveragePowerWatts),
      repeatCount: repeatCount == null && nullToAbsent ? const Value.absent() : Value(repeatCount),
      parentIntervalUuid: parentIntervalUuid == null && nullToAbsent ? const Value.absent() : Value(parentIntervalUuid),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory SessionInterval.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionInterval(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      intentType: serializer.fromJson<int>(json['intentType']),
      targetKind: serializer.fromJson<int>(json['targetKind']),
      targetDurationSec: serializer.fromJson<int?>(json['targetDurationSec']),
      targetDistanceM: serializer.fromJson<double?>(json['targetDistanceM']),
      targetHrZone: serializer.fromJson<int?>(json['targetHrZone']),
      targetPaceZone: serializer.fromJson<int?>(json['targetPaceZone']),
      targetPowerZone: serializer.fromJson<int?>(json['targetPowerZone']),
      targetValueMin: serializer.fromJson<double?>(json['targetValueMin']),
      targetValueMax: serializer.fromJson<double?>(json['targetValueMax']),
      targetFreeform: serializer.fromJson<String?>(json['targetFreeform']),
      actualDurationSec: serializer.fromJson<int?>(json['actualDurationSec']),
      actualDistanceM: serializer.fromJson<double?>(json['actualDistanceM']),
      actualAverageHr: serializer.fromJson<int?>(json['actualAverageHr']),
      actualAveragePaceSecPerMeter: serializer.fromJson<double?>(
        json['actualAveragePaceSecPerMeter'],
      ),
      actualAveragePowerWatts: serializer.fromJson<double?>(
        json['actualAveragePowerWatts'],
      ),
      repeatCount: serializer.fromJson<int?>(json['repeatCount']),
      parentIntervalUuid: serializer.fromJson<String?>(
        json['parentIntervalUuid'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'intentType': serializer.toJson<int>(intentType),
      'targetKind': serializer.toJson<int>(targetKind),
      'targetDurationSec': serializer.toJson<int?>(targetDurationSec),
      'targetDistanceM': serializer.toJson<double?>(targetDistanceM),
      'targetHrZone': serializer.toJson<int?>(targetHrZone),
      'targetPaceZone': serializer.toJson<int?>(targetPaceZone),
      'targetPowerZone': serializer.toJson<int?>(targetPowerZone),
      'targetValueMin': serializer.toJson<double?>(targetValueMin),
      'targetValueMax': serializer.toJson<double?>(targetValueMax),
      'targetFreeform': serializer.toJson<String?>(targetFreeform),
      'actualDurationSec': serializer.toJson<int?>(actualDurationSec),
      'actualDistanceM': serializer.toJson<double?>(actualDistanceM),
      'actualAverageHr': serializer.toJson<int?>(actualAverageHr),
      'actualAveragePaceSecPerMeter': serializer.toJson<double?>(
        actualAveragePaceSecPerMeter,
      ),
      'actualAveragePowerWatts': serializer.toJson<double?>(
        actualAveragePowerWatts,
      ),
      'repeatCount': serializer.toJson<int?>(repeatCount),
      'parentIntervalUuid': serializer.toJson<String?>(parentIntervalUuid),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SessionInterval copyWith({
    int? id,
    String? uuid,
    String? sessionUuid,
    int? orderIndex,
    int? intentType,
    int? targetKind,
    Value<int?> targetDurationSec = const Value.absent(),
    Value<double?> targetDistanceM = const Value.absent(),
    Value<int?> targetHrZone = const Value.absent(),
    Value<int?> targetPaceZone = const Value.absent(),
    Value<int?> targetPowerZone = const Value.absent(),
    Value<double?> targetValueMin = const Value.absent(),
    Value<double?> targetValueMax = const Value.absent(),
    Value<String?> targetFreeform = const Value.absent(),
    Value<int?> actualDurationSec = const Value.absent(),
    Value<double?> actualDistanceM = const Value.absent(),
    Value<int?> actualAverageHr = const Value.absent(),
    Value<double?> actualAveragePaceSecPerMeter = const Value.absent(),
    Value<double?> actualAveragePowerWatts = const Value.absent(),
    Value<int?> repeatCount = const Value.absent(),
    Value<String?> parentIntervalUuid = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SessionInterval(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    orderIndex: orderIndex ?? this.orderIndex,
    intentType: intentType ?? this.intentType,
    targetKind: targetKind ?? this.targetKind,
    targetDurationSec: targetDurationSec.present ? targetDurationSec.value : this.targetDurationSec,
    targetDistanceM: targetDistanceM.present ? targetDistanceM.value : this.targetDistanceM,
    targetHrZone: targetHrZone.present ? targetHrZone.value : this.targetHrZone,
    targetPaceZone: targetPaceZone.present ? targetPaceZone.value : this.targetPaceZone,
    targetPowerZone: targetPowerZone.present ? targetPowerZone.value : this.targetPowerZone,
    targetValueMin: targetValueMin.present ? targetValueMin.value : this.targetValueMin,
    targetValueMax: targetValueMax.present ? targetValueMax.value : this.targetValueMax,
    targetFreeform: targetFreeform.present ? targetFreeform.value : this.targetFreeform,
    actualDurationSec: actualDurationSec.present ? actualDurationSec.value : this.actualDurationSec,
    actualDistanceM: actualDistanceM.present ? actualDistanceM.value : this.actualDistanceM,
    actualAverageHr: actualAverageHr.present ? actualAverageHr.value : this.actualAverageHr,
    actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter.present
        ? actualAveragePaceSecPerMeter.value
        : this.actualAveragePaceSecPerMeter,
    actualAveragePowerWatts: actualAveragePowerWatts.present
        ? actualAveragePowerWatts.value
        : this.actualAveragePowerWatts,
    repeatCount: repeatCount.present ? repeatCount.value : this.repeatCount,
    parentIntervalUuid: parentIntervalUuid.present ? parentIntervalUuid.value : this.parentIntervalUuid,
    notes: notes.present ? notes.value : this.notes,
  );
  SessionInterval copyWithCompanion(SessionIntervalsCompanion data) {
    return SessionInterval(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      orderIndex: data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      intentType: data.intentType.present ? data.intentType.value : this.intentType,
      targetKind: data.targetKind.present ? data.targetKind.value : this.targetKind,
      targetDurationSec: data.targetDurationSec.present ? data.targetDurationSec.value : this.targetDurationSec,
      targetDistanceM: data.targetDistanceM.present ? data.targetDistanceM.value : this.targetDistanceM,
      targetHrZone: data.targetHrZone.present ? data.targetHrZone.value : this.targetHrZone,
      targetPaceZone: data.targetPaceZone.present ? data.targetPaceZone.value : this.targetPaceZone,
      targetPowerZone: data.targetPowerZone.present ? data.targetPowerZone.value : this.targetPowerZone,
      targetValueMin: data.targetValueMin.present ? data.targetValueMin.value : this.targetValueMin,
      targetValueMax: data.targetValueMax.present ? data.targetValueMax.value : this.targetValueMax,
      targetFreeform: data.targetFreeform.present ? data.targetFreeform.value : this.targetFreeform,
      actualDurationSec: data.actualDurationSec.present ? data.actualDurationSec.value : this.actualDurationSec,
      actualDistanceM: data.actualDistanceM.present ? data.actualDistanceM.value : this.actualDistanceM,
      actualAverageHr: data.actualAverageHr.present ? data.actualAverageHr.value : this.actualAverageHr,
      actualAveragePaceSecPerMeter: data.actualAveragePaceSecPerMeter.present
          ? data.actualAveragePaceSecPerMeter.value
          : this.actualAveragePaceSecPerMeter,
      actualAveragePowerWatts: data.actualAveragePowerWatts.present
          ? data.actualAveragePowerWatts.value
          : this.actualAveragePowerWatts,
      repeatCount: data.repeatCount.present ? data.repeatCount.value : this.repeatCount,
      parentIntervalUuid: data.parentIntervalUuid.present ? data.parentIntervalUuid.value : this.parentIntervalUuid,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionInterval(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('intentType: $intentType, ')
          ..write('targetKind: $targetKind, ')
          ..write('targetDurationSec: $targetDurationSec, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('targetHrZone: $targetHrZone, ')
          ..write('targetPaceZone: $targetPaceZone, ')
          ..write('targetPowerZone: $targetPowerZone, ')
          ..write('targetValueMin: $targetValueMin, ')
          ..write('targetValueMax: $targetValueMax, ')
          ..write('targetFreeform: $targetFreeform, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('actualAverageHr: $actualAverageHr, ')
          ..write(
            'actualAveragePaceSecPerMeter: $actualAveragePaceSecPerMeter, ',
          )
          ..write('actualAveragePowerWatts: $actualAveragePowerWatts, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('parentIntervalUuid: $parentIntervalUuid, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    uuid,
    sessionUuid,
    orderIndex,
    intentType,
    targetKind,
    targetDurationSec,
    targetDistanceM,
    targetHrZone,
    targetPaceZone,
    targetPowerZone,
    targetValueMin,
    targetValueMax,
    targetFreeform,
    actualDurationSec,
    actualDistanceM,
    actualAverageHr,
    actualAveragePaceSecPerMeter,
    actualAveragePowerWatts,
    repeatCount,
    parentIntervalUuid,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionInterval &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.sessionUuid == this.sessionUuid &&
          other.orderIndex == this.orderIndex &&
          other.intentType == this.intentType &&
          other.targetKind == this.targetKind &&
          other.targetDurationSec == this.targetDurationSec &&
          other.targetDistanceM == this.targetDistanceM &&
          other.targetHrZone == this.targetHrZone &&
          other.targetPaceZone == this.targetPaceZone &&
          other.targetPowerZone == this.targetPowerZone &&
          other.targetValueMin == this.targetValueMin &&
          other.targetValueMax == this.targetValueMax &&
          other.targetFreeform == this.targetFreeform &&
          other.actualDurationSec == this.actualDurationSec &&
          other.actualDistanceM == this.actualDistanceM &&
          other.actualAverageHr == this.actualAverageHr &&
          other.actualAveragePaceSecPerMeter == this.actualAveragePaceSecPerMeter &&
          other.actualAveragePowerWatts == this.actualAveragePowerWatts &&
          other.repeatCount == this.repeatCount &&
          other.parentIntervalUuid == this.parentIntervalUuid &&
          other.notes == this.notes);
}

class SessionIntervalsCompanion extends UpdateCompanion<SessionInterval> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> sessionUuid;
  final Value<int> orderIndex;
  final Value<int> intentType;
  final Value<int> targetKind;
  final Value<int?> targetDurationSec;
  final Value<double?> targetDistanceM;
  final Value<int?> targetHrZone;
  final Value<int?> targetPaceZone;
  final Value<int?> targetPowerZone;
  final Value<double?> targetValueMin;
  final Value<double?> targetValueMax;
  final Value<String?> targetFreeform;
  final Value<int?> actualDurationSec;
  final Value<double?> actualDistanceM;
  final Value<int?> actualAverageHr;
  final Value<double?> actualAveragePaceSecPerMeter;
  final Value<double?> actualAveragePowerWatts;
  final Value<int?> repeatCount;
  final Value<String?> parentIntervalUuid;
  final Value<String?> notes;
  const SessionIntervalsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.intentType = const Value.absent(),
    this.targetKind = const Value.absent(),
    this.targetDurationSec = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.targetHrZone = const Value.absent(),
    this.targetPaceZone = const Value.absent(),
    this.targetPowerZone = const Value.absent(),
    this.targetValueMin = const Value.absent(),
    this.targetValueMax = const Value.absent(),
    this.targetFreeform = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.actualAverageHr = const Value.absent(),
    this.actualAveragePaceSecPerMeter = const Value.absent(),
    this.actualAveragePowerWatts = const Value.absent(),
    this.repeatCount = const Value.absent(),
    this.parentIntervalUuid = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SessionIntervalsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String sessionUuid,
    required int orderIndex,
    required int intentType,
    required int targetKind,
    this.targetDurationSec = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.targetHrZone = const Value.absent(),
    this.targetPaceZone = const Value.absent(),
    this.targetPowerZone = const Value.absent(),
    this.targetValueMin = const Value.absent(),
    this.targetValueMax = const Value.absent(),
    this.targetFreeform = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.actualDistanceM = const Value.absent(),
    this.actualAverageHr = const Value.absent(),
    this.actualAveragePaceSecPerMeter = const Value.absent(),
    this.actualAveragePowerWatts = const Value.absent(),
    this.repeatCount = const Value.absent(),
    this.parentIntervalUuid = const Value.absent(),
    this.notes = const Value.absent(),
  }) : uuid = Value(uuid),
       sessionUuid = Value(sessionUuid),
       orderIndex = Value(orderIndex),
       intentType = Value(intentType),
       targetKind = Value(targetKind);
  static Insertable<SessionInterval> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? sessionUuid,
    Expression<int>? orderIndex,
    Expression<int>? intentType,
    Expression<int>? targetKind,
    Expression<int>? targetDurationSec,
    Expression<double>? targetDistanceM,
    Expression<int>? targetHrZone,
    Expression<int>? targetPaceZone,
    Expression<int>? targetPowerZone,
    Expression<double>? targetValueMin,
    Expression<double>? targetValueMax,
    Expression<String>? targetFreeform,
    Expression<int>? actualDurationSec,
    Expression<double>? actualDistanceM,
    Expression<int>? actualAverageHr,
    Expression<double>? actualAveragePaceSecPerMeter,
    Expression<double>? actualAveragePowerWatts,
    Expression<int>? repeatCount,
    Expression<String>? parentIntervalUuid,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (orderIndex != null) 'order_index': orderIndex,
      if (intentType != null) 'intent_type': intentType,
      if (targetKind != null) 'target_kind': targetKind,
      if (targetDurationSec != null) 'target_duration_sec': targetDurationSec,
      if (targetDistanceM != null) 'target_distance_m': targetDistanceM,
      if (targetHrZone != null) 'target_hr_zone': targetHrZone,
      if (targetPaceZone != null) 'target_pace_zone': targetPaceZone,
      if (targetPowerZone != null) 'target_power_zone': targetPowerZone,
      if (targetValueMin != null) 'target_value_min': targetValueMin,
      if (targetValueMax != null) 'target_value_max': targetValueMax,
      if (targetFreeform != null) 'target_freeform': targetFreeform,
      if (actualDurationSec != null) 'actual_duration_sec': actualDurationSec,
      if (actualDistanceM != null) 'actual_distance_m': actualDistanceM,
      if (actualAverageHr != null) 'actual_average_hr': actualAverageHr,
      if (actualAveragePaceSecPerMeter != null) 'actual_average_pace_sec_per_meter': actualAveragePaceSecPerMeter,
      if (actualAveragePowerWatts != null) 'actual_average_power_watts': actualAveragePowerWatts,
      if (repeatCount != null) 'repeat_count': repeatCount,
      if (parentIntervalUuid != null) 'parent_interval_uuid': parentIntervalUuid,
      if (notes != null) 'notes': notes,
    });
  }

  SessionIntervalsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? sessionUuid,
    Value<int>? orderIndex,
    Value<int>? intentType,
    Value<int>? targetKind,
    Value<int?>? targetDurationSec,
    Value<double?>? targetDistanceM,
    Value<int?>? targetHrZone,
    Value<int?>? targetPaceZone,
    Value<int?>? targetPowerZone,
    Value<double?>? targetValueMin,
    Value<double?>? targetValueMax,
    Value<String?>? targetFreeform,
    Value<int?>? actualDurationSec,
    Value<double?>? actualDistanceM,
    Value<int?>? actualAverageHr,
    Value<double?>? actualAveragePaceSecPerMeter,
    Value<double?>? actualAveragePowerWatts,
    Value<int?>? repeatCount,
    Value<String?>? parentIntervalUuid,
    Value<String?>? notes,
  }) {
    return SessionIntervalsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      orderIndex: orderIndex ?? this.orderIndex,
      intentType: intentType ?? this.intentType,
      targetKind: targetKind ?? this.targetKind,
      targetDurationSec: targetDurationSec ?? this.targetDurationSec,
      targetDistanceM: targetDistanceM ?? this.targetDistanceM,
      targetHrZone: targetHrZone ?? this.targetHrZone,
      targetPaceZone: targetPaceZone ?? this.targetPaceZone,
      targetPowerZone: targetPowerZone ?? this.targetPowerZone,
      targetValueMin: targetValueMin ?? this.targetValueMin,
      targetValueMax: targetValueMax ?? this.targetValueMax,
      targetFreeform: targetFreeform ?? this.targetFreeform,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      actualAverageHr: actualAverageHr ?? this.actualAverageHr,
      actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter ?? this.actualAveragePaceSecPerMeter,
      actualAveragePowerWatts: actualAveragePowerWatts ?? this.actualAveragePowerWatts,
      repeatCount: repeatCount ?? this.repeatCount,
      parentIntervalUuid: parentIntervalUuid ?? this.parentIntervalUuid,
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
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (intentType.present) {
      map['intent_type'] = Variable<int>(intentType.value);
    }
    if (targetKind.present) {
      map['target_kind'] = Variable<int>(targetKind.value);
    }
    if (targetDurationSec.present) {
      map['target_duration_sec'] = Variable<int>(targetDurationSec.value);
    }
    if (targetDistanceM.present) {
      map['target_distance_m'] = Variable<double>(targetDistanceM.value);
    }
    if (targetHrZone.present) {
      map['target_hr_zone'] = Variable<int>(targetHrZone.value);
    }
    if (targetPaceZone.present) {
      map['target_pace_zone'] = Variable<int>(targetPaceZone.value);
    }
    if (targetPowerZone.present) {
      map['target_power_zone'] = Variable<int>(targetPowerZone.value);
    }
    if (targetValueMin.present) {
      map['target_value_min'] = Variable<double>(targetValueMin.value);
    }
    if (targetValueMax.present) {
      map['target_value_max'] = Variable<double>(targetValueMax.value);
    }
    if (targetFreeform.present) {
      map['target_freeform'] = Variable<String>(targetFreeform.value);
    }
    if (actualDurationSec.present) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec.value);
    }
    if (actualDistanceM.present) {
      map['actual_distance_m'] = Variable<double>(actualDistanceM.value);
    }
    if (actualAverageHr.present) {
      map['actual_average_hr'] = Variable<int>(actualAverageHr.value);
    }
    if (actualAveragePaceSecPerMeter.present) {
      map['actual_average_pace_sec_per_meter'] = Variable<double>(
        actualAveragePaceSecPerMeter.value,
      );
    }
    if (actualAveragePowerWatts.present) {
      map['actual_average_power_watts'] = Variable<double>(
        actualAveragePowerWatts.value,
      );
    }
    if (repeatCount.present) {
      map['repeat_count'] = Variable<int>(repeatCount.value);
    }
    if (parentIntervalUuid.present) {
      map['parent_interval_uuid'] = Variable<String>(parentIntervalUuid.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionIntervalsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('intentType: $intentType, ')
          ..write('targetKind: $targetKind, ')
          ..write('targetDurationSec: $targetDurationSec, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('targetHrZone: $targetHrZone, ')
          ..write('targetPaceZone: $targetPaceZone, ')
          ..write('targetPowerZone: $targetPowerZone, ')
          ..write('targetValueMin: $targetValueMin, ')
          ..write('targetValueMax: $targetValueMax, ')
          ..write('targetFreeform: $targetFreeform, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('actualDistanceM: $actualDistanceM, ')
          ..write('actualAverageHr: $actualAverageHr, ')
          ..write(
            'actualAveragePaceSecPerMeter: $actualAveragePaceSecPerMeter, ',
          )
          ..write('actualAveragePowerWatts: $actualAveragePowerWatts, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('parentIntervalUuid: $parentIntervalUuid, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SessionSamplesTable extends SessionSamples with TableInfo<$SessionSamplesTable, SessionSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSamplesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (uuid)',
    ),
  );
  static const VerificationMeta _offsetSecMeta = const VerificationMeta(
    'offsetSec',
  );
  @override
  late final GeneratedColumn<int> offsetSec = GeneratedColumn<int>(
    'offset_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrMeta = const VerificationMeta('hr');
  @override
  late final GeneratedColumn<int> hr = GeneratedColumn<int>(
    'hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<double> cadence = GeneratedColumn<double>(
    'cadence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerWMeta = const VerificationMeta('powerW');
  @override
  late final GeneratedColumn<double> powerW = GeneratedColumn<double>(
    'power_w',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokeRateMeta = const VerificationMeta(
    'strokeRate',
  );
  @override
  late final GeneratedColumn<double> strokeRate = GeneratedColumn<double>(
    'stroke_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    offsetSec,
    lat,
    lng,
    altitudeM,
    hr,
    cadence,
    powerW,
    speedMps,
    strokeRate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('offset_sec')) {
      context.handle(
        _offsetSecMeta,
        offsetSec.isAcceptableOrUnknown(data['offset_sec']!, _offsetSecMeta),
      );
    } else if (isInserting) {
      context.missing(_offsetSecMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    if (data.containsKey('hr')) {
      context.handle(_hrMeta, hr.isAcceptableOrUnknown(data['hr']!, _hrMeta));
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    }
    if (data.containsKey('power_w')) {
      context.handle(
        _powerWMeta,
        powerW.isAcceptableOrUnknown(data['power_w']!, _powerWMeta),
      );
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('stroke_rate')) {
      context.handle(
        _strokeRateMeta,
        strokeRate.isAcceptableOrUnknown(data['stroke_rate']!, _strokeRateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      offsetSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_sec'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
      hr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hr'],
      ),
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cadence'],
      ),
      powerW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_w'],
      ),
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      strokeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stroke_rate'],
      ),
    );
  }

  @override
  $SessionSamplesTable createAlias(String alias) {
    return $SessionSamplesTable(attachedDatabase, alias);
  }
}

class SessionSample extends DataClass implements Insertable<SessionSample> {
  final int id;
  final String sessionUuid;
  final int offsetSec;
  final double? lat;
  final double? lng;
  final double? altitudeM;
  final int? hr;
  final double? cadence;
  final double? powerW;
  final double? speedMps;
  final double? strokeRate;
  const SessionSample({
    required this.id,
    required this.sessionUuid,
    required this.offsetSec,
    this.lat,
    this.lng,
    this.altitudeM,
    this.hr,
    this.cadence,
    this.powerW,
    this.speedMps,
    this.strokeRate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['offset_sec'] = Variable<int>(offsetSec);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    if (!nullToAbsent || hr != null) {
      map['hr'] = Variable<int>(hr);
    }
    if (!nullToAbsent || cadence != null) {
      map['cadence'] = Variable<double>(cadence);
    }
    if (!nullToAbsent || powerW != null) {
      map['power_w'] = Variable<double>(powerW);
    }
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    if (!nullToAbsent || strokeRate != null) {
      map['stroke_rate'] = Variable<double>(strokeRate);
    }
    return map;
  }

  SessionSamplesCompanion toCompanion(bool nullToAbsent) {
    return SessionSamplesCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      offsetSec: Value(offsetSec),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      altitudeM: altitudeM == null && nullToAbsent ? const Value.absent() : Value(altitudeM),
      hr: hr == null && nullToAbsent ? const Value.absent() : Value(hr),
      cadence: cadence == null && nullToAbsent ? const Value.absent() : Value(cadence),
      powerW: powerW == null && nullToAbsent ? const Value.absent() : Value(powerW),
      speedMps: speedMps == null && nullToAbsent ? const Value.absent() : Value(speedMps),
      strokeRate: strokeRate == null && nullToAbsent ? const Value.absent() : Value(strokeRate),
    );
  }

  factory SessionSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSample(
      id: serializer.fromJson<int>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      offsetSec: serializer.fromJson<int>(json['offsetSec']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      hr: serializer.fromJson<int?>(json['hr']),
      cadence: serializer.fromJson<double?>(json['cadence']),
      powerW: serializer.fromJson<double?>(json['powerW']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      strokeRate: serializer.fromJson<double?>(json['strokeRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'offsetSec': serializer.toJson<int>(offsetSec),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'hr': serializer.toJson<int?>(hr),
      'cadence': serializer.toJson<double?>(cadence),
      'powerW': serializer.toJson<double?>(powerW),
      'speedMps': serializer.toJson<double?>(speedMps),
      'strokeRate': serializer.toJson<double?>(strokeRate),
    };
  }

  SessionSample copyWith({
    int? id,
    String? sessionUuid,
    int? offsetSec,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> altitudeM = const Value.absent(),
    Value<int?> hr = const Value.absent(),
    Value<double?> cadence = const Value.absent(),
    Value<double?> powerW = const Value.absent(),
    Value<double?> speedMps = const Value.absent(),
    Value<double?> strokeRate = const Value.absent(),
  }) => SessionSample(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    offsetSec: offsetSec ?? this.offsetSec,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
    hr: hr.present ? hr.value : this.hr,
    cadence: cadence.present ? cadence.value : this.cadence,
    powerW: powerW.present ? powerW.value : this.powerW,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    strokeRate: strokeRate.present ? strokeRate.value : this.strokeRate,
  );
  SessionSample copyWithCompanion(SessionSamplesCompanion data) {
    return SessionSample(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      offsetSec: data.offsetSec.present ? data.offsetSec.value : this.offsetSec,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      hr: data.hr.present ? data.hr.value : this.hr,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      powerW: data.powerW.present ? data.powerW.value : this.powerW,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      strokeRate: data.strokeRate.present ? data.strokeRate.value : this.strokeRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSample(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('offsetSec: $offsetSec, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('hr: $hr, ')
          ..write('cadence: $cadence, ')
          ..write('powerW: $powerW, ')
          ..write('speedMps: $speedMps, ')
          ..write('strokeRate: $strokeRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionUuid,
    offsetSec,
    lat,
    lng,
    altitudeM,
    hr,
    cadence,
    powerW,
    speedMps,
    strokeRate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSample &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.offsetSec == this.offsetSec &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.altitudeM == this.altitudeM &&
          other.hr == this.hr &&
          other.cadence == this.cadence &&
          other.powerW == this.powerW &&
          other.speedMps == this.speedMps &&
          other.strokeRate == this.strokeRate);
}

class SessionSamplesCompanion extends UpdateCompanion<SessionSample> {
  final Value<int> id;
  final Value<String> sessionUuid;
  final Value<int> offsetSec;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> altitudeM;
  final Value<int?> hr;
  final Value<double?> cadence;
  final Value<double?> powerW;
  final Value<double?> speedMps;
  final Value<double?> strokeRate;
  const SessionSamplesCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.offsetSec = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.hr = const Value.absent(),
    this.cadence = const Value.absent(),
    this.powerW = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.strokeRate = const Value.absent(),
  });
  SessionSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String sessionUuid,
    required int offsetSec,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.hr = const Value.absent(),
    this.cadence = const Value.absent(),
    this.powerW = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.strokeRate = const Value.absent(),
  }) : sessionUuid = Value(sessionUuid),
       offsetSec = Value(offsetSec);
  static Insertable<SessionSample> custom({
    Expression<int>? id,
    Expression<String>? sessionUuid,
    Expression<int>? offsetSec,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? altitudeM,
    Expression<int>? hr,
    Expression<double>? cadence,
    Expression<double>? powerW,
    Expression<double>? speedMps,
    Expression<double>? strokeRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (offsetSec != null) 'offset_sec': offsetSec,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (hr != null) 'hr': hr,
      if (cadence != null) 'cadence': cadence,
      if (powerW != null) 'power_w': powerW,
      if (speedMps != null) 'speed_mps': speedMps,
      if (strokeRate != null) 'stroke_rate': strokeRate,
    });
  }

  SessionSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionUuid,
    Value<int>? offsetSec,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? altitudeM,
    Value<int?>? hr,
    Value<double?>? cadence,
    Value<double?>? powerW,
    Value<double?>? speedMps,
    Value<double?>? strokeRate,
  }) {
    return SessionSamplesCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      offsetSec: offsetSec ?? this.offsetSec,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altitudeM: altitudeM ?? this.altitudeM,
      hr: hr ?? this.hr,
      cadence: cadence ?? this.cadence,
      powerW: powerW ?? this.powerW,
      speedMps: speedMps ?? this.speedMps,
      strokeRate: strokeRate ?? this.strokeRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (offsetSec.present) {
      map['offset_sec'] = Variable<int>(offsetSec.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (hr.present) {
      map['hr'] = Variable<int>(hr.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<double>(cadence.value);
    }
    if (powerW.present) {
      map['power_w'] = Variable<double>(powerW.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (strokeRate.present) {
      map['stroke_rate'] = Variable<double>(strokeRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSamplesCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('offsetSec: $offsetSec, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('hr: $hr, ')
          ..write('cadence: $cadence, ')
          ..write('powerW: $powerW, ')
          ..write('speedMps: $speedMps, ')
          ..write('strokeRate: $strokeRate')
          ..write(')'))
        .toString();
  }
}

class $SportZonesTable extends SportZones with TableInfo<$SportZonesTable, SportZone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SportZonesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sportMeta = const VerificationMeta('sport');
  @override
  late final GeneratedColumn<int> sport = GeneratedColumn<int>(
    'sport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneNumberMeta = const VerificationMeta(
    'zoneNumber',
  );
  @override
  late final GeneratedColumn<int> zoneNumber = GeneratedColumn<int>(
    'zone_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUuidMeta = const VerificationMeta(
    'ownerUuid',
  );
  @override
  late final GeneratedColumn<String> ownerUuid = GeneratedColumn<String>(
    'owner_uuid',
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
    sport,
    zoneNumber,
    minValue,
    maxValue,
    unit,
    ownerUuid,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sport_zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<SportZone> instance, {
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
    if (data.containsKey('sport')) {
      context.handle(
        _sportMeta,
        sport.isAcceptableOrUnknown(data['sport']!, _sportMeta),
      );
    } else if (isInserting) {
      context.missing(_sportMeta);
    }
    if (data.containsKey('zone_number')) {
      context.handle(
        _zoneNumberMeta,
        zoneNumber.isAcceptableOrUnknown(data['zone_number']!, _zoneNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneNumberMeta);
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    } else if (isInserting) {
      context.missing(_minValueMeta);
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    } else if (isInserting) {
      context.missing(_maxValueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('owner_uuid')) {
      context.handle(
        _ownerUuidMeta,
        ownerUuid.isAcceptableOrUnknown(data['owner_uuid']!, _ownerUuidMeta),
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
  SportZone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SportZone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      sport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sport'],
      )!,
      zoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_number'],
      )!,
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      )!,
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      ownerUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uuid'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SportZonesTable createAlias(String alias) {
    return $SportZonesTable(attachedDatabase, alias);
  }
}

class SportZone extends DataClass implements Insertable<SportZone> {
  final int id;
  final String uuid;
  final int sport;
  final int zoneNumber;
  final double minValue;
  final double maxValue;
  final String unit;
  final String? ownerUuid;
  final DateTime createdAt;
  const SportZone({
    required this.id,
    required this.uuid,
    required this.sport,
    required this.zoneNumber,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    this.ownerUuid,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['sport'] = Variable<int>(sport);
    map['zone_number'] = Variable<int>(zoneNumber);
    map['min_value'] = Variable<double>(minValue);
    map['max_value'] = Variable<double>(maxValue);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || ownerUuid != null) {
      map['owner_uuid'] = Variable<String>(ownerUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SportZonesCompanion toCompanion(bool nullToAbsent) {
    return SportZonesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      sport: Value(sport),
      zoneNumber: Value(zoneNumber),
      minValue: Value(minValue),
      maxValue: Value(maxValue),
      unit: Value(unit),
      ownerUuid: ownerUuid == null && nullToAbsent ? const Value.absent() : Value(ownerUuid),
      createdAt: Value(createdAt),
    );
  }

  factory SportZone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SportZone(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      sport: serializer.fromJson<int>(json['sport']),
      zoneNumber: serializer.fromJson<int>(json['zoneNumber']),
      minValue: serializer.fromJson<double>(json['minValue']),
      maxValue: serializer.fromJson<double>(json['maxValue']),
      unit: serializer.fromJson<String>(json['unit']),
      ownerUuid: serializer.fromJson<String?>(json['ownerUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'sport': serializer.toJson<int>(sport),
      'zoneNumber': serializer.toJson<int>(zoneNumber),
      'minValue': serializer.toJson<double>(minValue),
      'maxValue': serializer.toJson<double>(maxValue),
      'unit': serializer.toJson<String>(unit),
      'ownerUuid': serializer.toJson<String?>(ownerUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SportZone copyWith({
    int? id,
    String? uuid,
    int? sport,
    int? zoneNumber,
    double? minValue,
    double? maxValue,
    String? unit,
    Value<String?> ownerUuid = const Value.absent(),
    DateTime? createdAt,
  }) => SportZone(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    sport: sport ?? this.sport,
    zoneNumber: zoneNumber ?? this.zoneNumber,
    minValue: minValue ?? this.minValue,
    maxValue: maxValue ?? this.maxValue,
    unit: unit ?? this.unit,
    ownerUuid: ownerUuid.present ? ownerUuid.value : this.ownerUuid,
    createdAt: createdAt ?? this.createdAt,
  );
  SportZone copyWithCompanion(SportZonesCompanion data) {
    return SportZone(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      sport: data.sport.present ? data.sport.value : this.sport,
      zoneNumber: data.zoneNumber.present ? data.zoneNumber.value : this.zoneNumber,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      ownerUuid: data.ownerUuid.present ? data.ownerUuid.value : this.ownerUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SportZone(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('sport: $sport, ')
          ..write('zoneNumber: $zoneNumber, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('unit: $unit, ')
          ..write('ownerUuid: $ownerUuid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    sport,
    zoneNumber,
    minValue,
    maxValue,
    unit,
    ownerUuid,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SportZone &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.sport == this.sport &&
          other.zoneNumber == this.zoneNumber &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.unit == this.unit &&
          other.ownerUuid == this.ownerUuid &&
          other.createdAt == this.createdAt);
}

class SportZonesCompanion extends UpdateCompanion<SportZone> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> sport;
  final Value<int> zoneNumber;
  final Value<double> minValue;
  final Value<double> maxValue;
  final Value<String> unit;
  final Value<String?> ownerUuid;
  final Value<DateTime> createdAt;
  const SportZonesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.sport = const Value.absent(),
    this.zoneNumber = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.ownerUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SportZonesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int sport,
    required int zoneNumber,
    required double minValue,
    required double maxValue,
    required String unit,
    this.ownerUuid = const Value.absent(),
    required DateTime createdAt,
  }) : uuid = Value(uuid),
       sport = Value(sport),
       zoneNumber = Value(zoneNumber),
       minValue = Value(minValue),
       maxValue = Value(maxValue),
       unit = Value(unit),
       createdAt = Value(createdAt);
  static Insertable<SportZone> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? sport,
    Expression<int>? zoneNumber,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<String>? unit,
    Expression<String>? ownerUuid,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (sport != null) 'sport': sport,
      if (zoneNumber != null) 'zone_number': zoneNumber,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (unit != null) 'unit': unit,
      if (ownerUuid != null) 'owner_uuid': ownerUuid,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SportZonesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? sport,
    Value<int>? zoneNumber,
    Value<double>? minValue,
    Value<double>? maxValue,
    Value<String>? unit,
    Value<String?>? ownerUuid,
    Value<DateTime>? createdAt,
  }) {
    return SportZonesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      sport: sport ?? this.sport,
      zoneNumber: zoneNumber ?? this.zoneNumber,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      unit: unit ?? this.unit,
      ownerUuid: ownerUuid ?? this.ownerUuid,
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
    if (sport.present) {
      map['sport'] = Variable<int>(sport.value);
    }
    if (zoneNumber.present) {
      map['zone_number'] = Variable<int>(zoneNumber.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (ownerUuid.present) {
      map['owner_uuid'] = Variable<String>(ownerUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SportZonesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('sport: $sport, ')
          ..write('zoneNumber: $zoneNumber, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('unit: $unit, ')
          ..write('ownerUuid: $ownerUuid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CardioFeedbackTable extends CardioFeedback with TableInfo<$CardioFeedbackTable, CardioFeedbackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioFeedbackTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES sessions (uuid)',
    ),
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breathingMeta = const VerificationMeta(
    'breathing',
  );
  @override
  late final GeneratedColumn<int> breathing = GeneratedColumn<int>(
    'breathing',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giComfortMeta = const VerificationMeta(
    'giComfort',
  );
  @override
  late final GeneratedColumn<int> giComfort = GeneratedColumn<int>(
    'gi_comfort',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
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
  static const VerificationMeta _creatorUuidMeta = const VerificationMeta(
    'creatorUuid',
  );
  @override
  late final GeneratedColumn<String> creatorUuid = GeneratedColumn<String>(
    'creator_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUuidMeta = const VerificationMeta(
    'ownerUuid',
  );
  @override
  late final GeneratedColumn<String> ownerUuid = GeneratedColumn<String>(
    'owner_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    rpe,
    breathing,
    giComfort,
    weather,
    notes,
    timestamp,
    creatorUuid,
    ownerUuid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioFeedbackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('breathing')) {
      context.handle(
        _breathingMeta,
        breathing.isAcceptableOrUnknown(data['breathing']!, _breathingMeta),
      );
    }
    if (data.containsKey('gi_comfort')) {
      context.handle(
        _giComfortMeta,
        giComfort.isAcceptableOrUnknown(data['gi_comfort']!, _giComfortMeta),
      );
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('creator_uuid')) {
      context.handle(
        _creatorUuidMeta,
        creatorUuid.isAcceptableOrUnknown(
          data['creator_uuid']!,
          _creatorUuidMeta,
        ),
      );
    }
    if (data.containsKey('owner_uuid')) {
      context.handle(
        _ownerUuidMeta,
        ownerUuid.isAcceptableOrUnknown(data['owner_uuid']!, _ownerUuidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardioFeedbackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioFeedbackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      breathing: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breathing'],
      ),
      giComfort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gi_comfort'],
      ),
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      ),
      creatorUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_uuid'],
      ),
      ownerUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uuid'],
      ),
    );
  }

  @override
  $CardioFeedbackTable createAlias(String alias) {
    return $CardioFeedbackTable(attachedDatabase, alias);
  }
}

class CardioFeedbackData extends DataClass implements Insertable<CardioFeedbackData> {
  final int id;
  final String sessionUuid;
  final int? rpe;
  final int? breathing;
  final int? giComfort;
  final String? weather;
  final String? notes;
  final DateTime? timestamp;
  final String? creatorUuid;
  final String? ownerUuid;
  const CardioFeedbackData({
    required this.id,
    required this.sessionUuid,
    this.rpe,
    this.breathing,
    this.giComfort,
    this.weather,
    this.notes,
    this.timestamp,
    this.creatorUuid,
    this.ownerUuid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || breathing != null) {
      map['breathing'] = Variable<int>(breathing);
    }
    if (!nullToAbsent || giComfort != null) {
      map['gi_comfort'] = Variable<int>(giComfort);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    if (!nullToAbsent || creatorUuid != null) {
      map['creator_uuid'] = Variable<String>(creatorUuid);
    }
    if (!nullToAbsent || ownerUuid != null) {
      map['owner_uuid'] = Variable<String>(ownerUuid);
    }
    return map;
  }

  CardioFeedbackCompanion toCompanion(bool nullToAbsent) {
    return CardioFeedbackCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      breathing: breathing == null && nullToAbsent ? const Value.absent() : Value(breathing),
      giComfort: giComfort == null && nullToAbsent ? const Value.absent() : Value(giComfort),
      weather: weather == null && nullToAbsent ? const Value.absent() : Value(weather),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      timestamp: timestamp == null && nullToAbsent ? const Value.absent() : Value(timestamp),
      creatorUuid: creatorUuid == null && nullToAbsent ? const Value.absent() : Value(creatorUuid),
      ownerUuid: ownerUuid == null && nullToAbsent ? const Value.absent() : Value(ownerUuid),
    );
  }

  factory CardioFeedbackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioFeedbackData(
      id: serializer.fromJson<int>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      breathing: serializer.fromJson<int?>(json['breathing']),
      giComfort: serializer.fromJson<int?>(json['giComfort']),
      weather: serializer.fromJson<String?>(json['weather']),
      notes: serializer.fromJson<String?>(json['notes']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      creatorUuid: serializer.fromJson<String?>(json['creatorUuid']),
      ownerUuid: serializer.fromJson<String?>(json['ownerUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'rpe': serializer.toJson<int?>(rpe),
      'breathing': serializer.toJson<int?>(breathing),
      'giComfort': serializer.toJson<int?>(giComfort),
      'weather': serializer.toJson<String?>(weather),
      'notes': serializer.toJson<String?>(notes),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'creatorUuid': serializer.toJson<String?>(creatorUuid),
      'ownerUuid': serializer.toJson<String?>(ownerUuid),
    };
  }

  CardioFeedbackData copyWith({
    int? id,
    String? sessionUuid,
    Value<int?> rpe = const Value.absent(),
    Value<int?> breathing = const Value.absent(),
    Value<int?> giComfort = const Value.absent(),
    Value<String?> weather = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> timestamp = const Value.absent(),
    Value<String?> creatorUuid = const Value.absent(),
    Value<String?> ownerUuid = const Value.absent(),
  }) => CardioFeedbackData(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    rpe: rpe.present ? rpe.value : this.rpe,
    breathing: breathing.present ? breathing.value : this.breathing,
    giComfort: giComfort.present ? giComfort.value : this.giComfort,
    weather: weather.present ? weather.value : this.weather,
    notes: notes.present ? notes.value : this.notes,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    creatorUuid: creatorUuid.present ? creatorUuid.value : this.creatorUuid,
    ownerUuid: ownerUuid.present ? ownerUuid.value : this.ownerUuid,
  );
  CardioFeedbackData copyWithCompanion(CardioFeedbackCompanion data) {
    return CardioFeedbackData(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present ? data.sessionUuid.value : this.sessionUuid,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      breathing: data.breathing.present ? data.breathing.value : this.breathing,
      giComfort: data.giComfort.present ? data.giComfort.value : this.giComfort,
      weather: data.weather.present ? data.weather.value : this.weather,
      notes: data.notes.present ? data.notes.value : this.notes,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      creatorUuid: data.creatorUuid.present ? data.creatorUuid.value : this.creatorUuid,
      ownerUuid: data.ownerUuid.present ? data.ownerUuid.value : this.ownerUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioFeedbackData(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('rpe: $rpe, ')
          ..write('breathing: $breathing, ')
          ..write('giComfort: $giComfort, ')
          ..write('weather: $weather, ')
          ..write('notes: $notes, ')
          ..write('timestamp: $timestamp, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionUuid,
    rpe,
    breathing,
    giComfort,
    weather,
    notes,
    timestamp,
    creatorUuid,
    ownerUuid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioFeedbackData &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.rpe == this.rpe &&
          other.breathing == this.breathing &&
          other.giComfort == this.giComfort &&
          other.weather == this.weather &&
          other.notes == this.notes &&
          other.timestamp == this.timestamp &&
          other.creatorUuid == this.creatorUuid &&
          other.ownerUuid == this.ownerUuid);
}

class CardioFeedbackCompanion extends UpdateCompanion<CardioFeedbackData> {
  final Value<int> id;
  final Value<String> sessionUuid;
  final Value<int?> rpe;
  final Value<int?> breathing;
  final Value<int?> giComfort;
  final Value<String?> weather;
  final Value<String?> notes;
  final Value<DateTime?> timestamp;
  final Value<String?> creatorUuid;
  final Value<String?> ownerUuid;
  const CardioFeedbackCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.rpe = const Value.absent(),
    this.breathing = const Value.absent(),
    this.giComfort = const Value.absent(),
    this.weather = const Value.absent(),
    this.notes = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  });
  CardioFeedbackCompanion.insert({
    this.id = const Value.absent(),
    required String sessionUuid,
    this.rpe = const Value.absent(),
    this.breathing = const Value.absent(),
    this.giComfort = const Value.absent(),
    this.weather = const Value.absent(),
    this.notes = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.creatorUuid = const Value.absent(),
    this.ownerUuid = const Value.absent(),
  }) : sessionUuid = Value(sessionUuid);
  static Insertable<CardioFeedbackData> custom({
    Expression<int>? id,
    Expression<String>? sessionUuid,
    Expression<int>? rpe,
    Expression<int>? breathing,
    Expression<int>? giComfort,
    Expression<String>? weather,
    Expression<String>? notes,
    Expression<DateTime>? timestamp,
    Expression<String>? creatorUuid,
    Expression<String>? ownerUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (rpe != null) 'rpe': rpe,
      if (breathing != null) 'breathing': breathing,
      if (giComfort != null) 'gi_comfort': giComfort,
      if (weather != null) 'weather': weather,
      if (notes != null) 'notes': notes,
      if (timestamp != null) 'timestamp': timestamp,
      if (creatorUuid != null) 'creator_uuid': creatorUuid,
      if (ownerUuid != null) 'owner_uuid': ownerUuid,
    });
  }

  CardioFeedbackCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionUuid,
    Value<int?>? rpe,
    Value<int?>? breathing,
    Value<int?>? giComfort,
    Value<String?>? weather,
    Value<String?>? notes,
    Value<DateTime?>? timestamp,
    Value<String?>? creatorUuid,
    Value<String?>? ownerUuid,
  }) {
    return CardioFeedbackCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      rpe: rpe ?? this.rpe,
      breathing: breathing ?? this.breathing,
      giComfort: giComfort ?? this.giComfort,
      weather: weather ?? this.weather,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (breathing.present) {
      map['breathing'] = Variable<int>(breathing.value);
    }
    if (giComfort.present) {
      map['gi_comfort'] = Variable<int>(giComfort.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (creatorUuid.present) {
      map['creator_uuid'] = Variable<String>(creatorUuid.value);
    }
    if (ownerUuid.present) {
      map['owner_uuid'] = Variable<String>(ownerUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('rpe: $rpe, ')
          ..write('breathing: $breathing, ')
          ..write('giComfort: $giComfort, ')
          ..write('weather: $weather, ')
          ..write('notes: $notes, ')
          ..write('timestamp: $timestamp, ')
          ..write('creatorUuid: $creatorUuid, ')
          ..write('ownerUuid: $ownerUuid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrainingCyclesTable trainingCycles = $TrainingCyclesTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseSetsTable exerciseSets = $ExerciseSetsTable(this);
  late final $ExerciseFeedbacksTable exerciseFeedbacks = $ExerciseFeedbacksTable(this);
  late final $CustomExerciseDefinitionsTable customExerciseDefinitions = $CustomExerciseDefinitionsTable(this);
  late final $UserMeasurementsTable userMeasurements = $UserMeasurementsTable(
    this,
  );
  late final $SkinsTable skins = $SkinsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $CyclePeriodsTable cyclePeriods = $CyclePeriodsTable(this);
  late final $SessionCardioTable sessionCardio = $SessionCardioTable(this);
  late final $SessionIntervalsTable sessionIntervals = $SessionIntervalsTable(
    this,
  );
  late final $SessionSamplesTable sessionSamples = $SessionSamplesTable(this);
  late final $SportZonesTable sportZones = $SportZonesTable(this);
  late final $CardioFeedbackTable cardioFeedback = $CardioFeedbackTable(this);
  late final TrainingCycleDao trainingCycleDao = TrainingCycleDao(
    this as AppDatabase,
  );
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
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final CyclePeriodDao cyclePeriodDao = CyclePeriodDao(
    this as AppDatabase,
  );
  late final SessionCardioDao sessionCardioDao = SessionCardioDao(
    this as AppDatabase,
  );
  late final SessionIntervalDao sessionIntervalDao = SessionIntervalDao(
    this as AppDatabase,
  );
  late final SessionSampleDao sessionSampleDao = SessionSampleDao(
    this as AppDatabase,
  );
  late final SportZoneDao sportZoneDao = SportZoneDao(this as AppDatabase);
  late final CardioFeedbackDao cardioFeedbackDao = CardioFeedbackDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trainingCycles,
    exercises,
    exerciseSets,
    exerciseFeedbacks,
    customExerciseDefinitions,
    userMeasurements,
    skins,
    sessions,
    cyclePeriods,
    sessionCardio,
    sessionIntervals,
    sessionSamples,
    sportZones,
    cardioFeedback,
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
      Value<int?> primarySport,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
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
      Value<int?> primarySport,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });

final class $$TrainingCyclesTableReferences extends BaseReferences<_$AppDatabase, $TrainingCyclesTable, TrainingCycle> {
  $$TrainingCyclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(
      db.trainingCycles.uuid,
      db.sessions.trainingCycleUuid,
    ),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter(
      (f) => f.trainingCycleUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CyclePeriodsTable, List<CyclePeriod>> _cyclePeriodsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cyclePeriods,
        aliasName: $_aliasNameGenerator(
          db.trainingCycles.uuid,
          db.cyclePeriods.trainingCycleUuid,
        ),
      );

  $$CyclePeriodsTableProcessedTableManager get cyclePeriodsRefs {
    final manager = $$CyclePeriodsTableTableManager($_db, $_db.cyclePeriods).filter(
      (f) => f.trainingCycleUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_cyclePeriodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingCyclesTableFilterComposer extends Composer<_$AppDatabase, $TrainingCyclesTable> {
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

  ColumnFilters<int> get primarySport => $composableBuilder(
    column: $table.primarySport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cyclePeriodsRefs(
    Expression<bool> Function($$CyclePeriodsTableFilterComposer f) f,
  ) {
    final $$CyclePeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.cyclePeriods,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclePeriodsTableFilterComposer(
            $db: $db,
            $table: $db.cyclePeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingCyclesTableOrderingComposer extends Composer<_$AppDatabase, $TrainingCyclesTable> {
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

  ColumnOrderings<int> get primarySport => $composableBuilder(
    column: $table.primarySport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingCyclesTableAnnotationComposer extends Composer<_$AppDatabase, $TrainingCyclesTable> {
  $$TrainingCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

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

  GeneratedColumn<int> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get gender => $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupPriorities => $composableBuilder(
    column: $table.muscleGroupPriorities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get recoveryPeriodType => $composableBuilder(
    column: $table.recoveryPeriodType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primarySport => $composableBuilder(
    column: $table.primarySport,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerUuid => $composableBuilder(column: $table.ownerUuid, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cyclePeriodsRefs<T extends Object>(
    Expression<T> Function($$CyclePeriodsTableAnnotationComposer a) f,
  ) {
    final $$CyclePeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.cyclePeriods,
      getReferencedColumn: (t) => t.trainingCycleUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclePeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.cyclePeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
          PrefetchHooks Function({bool sessionsRefs, bool cyclePeriodsRefs})
        > {
  $$TrainingCyclesTableTableManager(
    _$AppDatabase db,
    $TrainingCyclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TrainingCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TrainingCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TrainingCyclesTableAnnotationComposer($db: db, $table: table),
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
                Value<int?> primarySport = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
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
                primarySport: primarySport,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
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
                Value<int?> primarySport = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
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
                primarySport: primarySport,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingCyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false, cyclePeriodsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionsRefs) db.sessions,
                if (cyclePeriodsRefs) db.cyclePeriods,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<TrainingCycle, $TrainingCyclesTable, Session>(
                      currentTable: table,
                      referencedTable: $$TrainingCyclesTableReferences._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TrainingCyclesTableReferences(
                        db,
                        table,
                        p0,
                      ).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                        (e) => e.trainingCycleUuid == item.uuid,
                      ),
                      typedResults: items,
                    ),
                  if (cyclePeriodsRefs)
                    await $_getPrefetchedData<TrainingCycle, $TrainingCyclesTable, CyclePeriod>(
                      currentTable: table,
                      referencedTable: $$TrainingCyclesTableReferences._cyclePeriodsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TrainingCyclesTableReferences(
                        db,
                        table,
                        p0,
                      ).cyclePeriodsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
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
      PrefetchHooks Function({bool sessionsRefs, bool cyclePeriodsRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String uuid,
      required String workoutUuid,
      Value<String?> sessionUuid,
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
      Value<int?> restSeconds,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> workoutUuid,
      Value<String?> sessionUuid,
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
      Value<int?> restSeconds,
    });

final class $$ExercisesTableReferences extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseSetsTable, List<ExerciseSet>> _exerciseSetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSets,
        aliasName: $_aliasNameGenerator(
          db.exercises.uuid,
          db.exerciseSets.exerciseUuid,
        ),
      );

  $$ExerciseSetsTableProcessedTableManager get exerciseSetsRefs {
    final manager = $$ExerciseSetsTableTableManager($_db, $_db.exerciseSets).filter(
      (f) => f.exerciseUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_exerciseSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseFeedbacksTable, List<ExerciseFeedback>> _exerciseFeedbacksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
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

class $$ExercisesTableFilterComposer extends Composer<_$AppDatabase, $ExercisesTable> {
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

  ColumnFilters<String> get workoutUuid => $composableBuilder(
    column: $table.workoutUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
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

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer extends Composer<_$AppDatabase, $ExercisesTable> {
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

  ColumnOrderings<String> get workoutUuid => $composableBuilder(
    column: $table.workoutUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
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

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get workoutUuid => $composableBuilder(
    column: $table.workoutUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

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

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPerformed => $composableBuilder(
    column: $table.lastPerformed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoUrl => $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isNotePinned => $composableBuilder(
    column: $table.isNotePinned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseFeedbacksRefs<T extends Object>(
    Expression<T> Function($$ExerciseFeedbacksTableAnnotationComposer a) f,
  ) {
    final $$ExerciseFeedbacksTableAnnotationComposer composer = $composerBuilder(
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
            bool exerciseSetsRefs,
            bool exerciseFeedbacksRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> workoutUuid = const Value.absent(),
                Value<String?> sessionUuid = const Value.absent(),
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
                Value<int?> restSeconds = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                uuid: uuid,
                workoutUuid: workoutUuid,
                sessionUuid: sessionUuid,
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
                restSeconds: restSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String workoutUuid,
                Value<String?> sessionUuid = const Value.absent(),
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
                Value<int?> restSeconds = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                uuid: uuid,
                workoutUuid: workoutUuid,
                sessionUuid: sessionUuid,
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
                restSeconds: restSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseSetsRefs = false, exerciseFeedbacksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseSetsRefs) db.exerciseSets,
                if (exerciseFeedbacksRefs) db.exerciseFeedbacks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseSetsRefs)
                    await $_getPrefetchedData<Exercise, $ExercisesTable, ExerciseSet>(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences._exerciseSetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExercisesTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                        (e) => e.exerciseUuid == item.uuid,
                      ),
                      typedResults: items,
                    ),
                  if (exerciseFeedbacksRefs)
                    await $_getPrefetchedData<Exercise, $ExercisesTable, ExerciseFeedback>(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences._exerciseFeedbacksRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExercisesTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseFeedbacksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
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

final class $$ExerciseSetsTableReferences extends BaseReferences<_$AppDatabase, $ExerciseSetsTable, ExerciseSet> {
  $$ExerciseSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseUuidTable(_$AppDatabase db) => db.exercises.createAlias(
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

class $$ExerciseSetsTableFilterComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableOrderingComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSetsTableAnnotationComposer extends Composer<_$AppDatabase, $ExerciseSetsTable> {
  $$ExerciseSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get setNumber => $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get weight => $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get reps => $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get setType => $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<bool> get isLogged => $composableBuilder(column: $table.isLogged, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSkipped => $composableBuilder(column: $table.isSkipped, builder: (column) => column);

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
          createFilteringComposer: () => $$ExerciseSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseSetsTableAnnotationComposer($db: db, $table: table),
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
                                referencedTable: $$ExerciseSetsTableReferences._exerciseUuidTable(db),
                                referencedColumn: $$ExerciseSetsTableReferences._exerciseUuidTable(db).uuid,
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
      Value<String?> sessionUuid,
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
      Value<String?> sessionUuid,
      Value<int?> jointPain,
      Value<int?> musclePump,
      Value<int?> workload,
      Value<int?> soreness,
      Value<String?> muscleGroupSoreness,
      Value<DateTime?> timestamp,
    });

final class $$ExerciseFeedbacksTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseFeedbacksTable, ExerciseFeedback> {
  $$ExerciseFeedbacksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseUuidTable(_$AppDatabase db) => db.exercises.createAlias(
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

class $$ExerciseFeedbacksTableFilterComposer extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
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

  ColumnFilters<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseFeedbacksTableOrderingComposer extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
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

  ColumnOrderings<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseFeedbacksTableAnnotationComposer extends Composer<_$AppDatabase, $ExerciseFeedbacksTable> {
  $$ExerciseFeedbacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jointPain => $composableBuilder(column: $table.jointPain, builder: (column) => column);

  GeneratedColumn<int> get musclePump => $composableBuilder(
    column: $table.musclePump,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workload => $composableBuilder(column: $table.workload, builder: (column) => column);

  GeneratedColumn<int> get soreness => $composableBuilder(column: $table.soreness, builder: (column) => column);

  GeneratedColumn<String> get muscleGroupSoreness => $composableBuilder(
    column: $table.muscleGroupSoreness,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp => $composableBuilder(column: $table.timestamp, builder: (column) => column);

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
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
          createFilteringComposer: () => $$ExerciseFeedbacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseFeedbacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseFeedbacksTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseUuid = const Value.absent(),
                Value<String?> sessionUuid = const Value.absent(),
                Value<int?> jointPain = const Value.absent(),
                Value<int?> musclePump = const Value.absent(),
                Value<int?> workload = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<String?> muscleGroupSoreness = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
              }) => ExerciseFeedbacksCompanion(
                id: id,
                exerciseUuid: exerciseUuid,
                sessionUuid: sessionUuid,
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
                Value<String?> sessionUuid = const Value.absent(),
                Value<int?> jointPain = const Value.absent(),
                Value<int?> musclePump = const Value.absent(),
                Value<int?> workload = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<String?> muscleGroupSoreness = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
              }) => ExerciseFeedbacksCompanion.insert(
                id: id,
                exerciseUuid: exerciseUuid,
                sessionUuid: sessionUuid,
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
                                referencedTable: $$ExerciseFeedbacksTableReferences._exerciseUuidTable(db),
                                referencedColumn: $$ExerciseFeedbacksTableReferences._exerciseUuidTable(db).uuid,
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
      Value<int?> restSeconds,
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
      Value<int?> restSeconds,
      Value<DateTime> createdAt,
    });

class $$CustomExerciseDefinitionsTableFilterComposer extends Composer<_$AppDatabase, $CustomExerciseDefinitionsTable> {
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

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
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

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
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
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

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

  GeneratedColumn<String> get videoUrl => $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
            BaseReferences<_$AppDatabase, $CustomExerciseDefinitionsTable, CustomExerciseDefinition>,
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
          createFilteringComposer: () => $$CustomExerciseDefinitionsTableFilterComposer(
            $db: db,
            $table: table,
          ),
          createOrderingComposer: () => $$CustomExerciseDefinitionsTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$CustomExerciseDefinitionsTableAnnotationComposer(
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
                Value<int?> restSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomExerciseDefinitionsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                videoUrl: videoUrl,
                restSeconds: restSeconds,
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
                Value<int?> restSeconds = const Value.absent(),
                required DateTime createdAt,
              }) => CustomExerciseDefinitionsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: secondaryMuscleGroup,
                equipmentType: equipmentType,
                videoUrl: videoUrl,
                restSeconds: restSeconds,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
        BaseReferences<_$AppDatabase, $CustomExerciseDefinitionsTable, CustomExerciseDefinition>,
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

class $$UserMeasurementsTableFilterComposer extends Composer<_$AppDatabase, $UserMeasurementsTable> {
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

class $$UserMeasurementsTableOrderingComposer extends Composer<_$AppDatabase, $UserMeasurementsTable> {
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

class $$UserMeasurementsTableAnnotationComposer extends Composer<_$AppDatabase, $UserMeasurementsTable> {
  $$UserMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get heightCm => $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg => $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp => $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

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
            BaseReferences<_$AppDatabase, $UserMeasurementsTable, UserMeasurement>,
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
          createFilteringComposer: () => $$UserMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserMeasurementsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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

class $$SkinsTableOrderingComposer extends Composer<_$AppDatabase, $SkinsTable> {
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

class $$SkinsTableAnnotationComposer extends Composer<_$AppDatabase, $SkinsTable> {
  $$SkinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get skinJson => $composableBuilder(column: $table.skinJson, builder: (column) => column);

  GeneratedColumn<bool> get isActive => $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          createFilteringComposer: () => $$SkinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SkinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SkinsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String uuid,
      Value<String?> trainingCycleUuid,
      required int sport,
      required int source,
      Value<int?> periodNumber,
      Value<int?> dayNumber,
      Value<String?> dayName,
      Value<String?> label,
      required int status,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> completedDate,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String?> notes,
      Value<String?> externalId,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String?> trainingCycleUuid,
      Value<int> sport,
      Value<int> source,
      Value<int?> periodNumber,
      Value<int?> dayNumber,
      Value<String?> dayName,
      Value<String?> label,
      Value<int> status,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> completedDate,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String?> notes,
      Value<String?> externalId,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });

final class $$SessionsTableReferences extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingCyclesTable _trainingCycleUuidTable(_$AppDatabase db) => db.trainingCycles.createAlias(
    $_aliasNameGenerator(
      db.sessions.trainingCycleUuid,
      db.trainingCycles.uuid,
    ),
  );

  $$TrainingCyclesTableProcessedTableManager? get trainingCycleUuid {
    final $_column = $_itemColumn<String>('training_cycle_uuid');
    if ($_column == null) return null;
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

  static MultiTypedResultKey<$SessionCardioTable, List<SessionCardioData>> _sessionCardioRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionCardio,
        aliasName: $_aliasNameGenerator(
          db.sessions.uuid,
          db.sessionCardio.sessionUuid,
        ),
      );

  $$SessionCardioTableProcessedTableManager get sessionCardioRefs {
    final manager = $$SessionCardioTableTableManager($_db, $_db.sessionCardio).filter(
      (f) => f.sessionUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_sessionCardioRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionIntervalsTable, List<SessionInterval>> _sessionIntervalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessionIntervals,
    aliasName: $_aliasNameGenerator(
      db.sessions.uuid,
      db.sessionIntervals.sessionUuid,
    ),
  );

  $$SessionIntervalsTableProcessedTableManager get sessionIntervalsRefs {
    final manager = $$SessionIntervalsTableTableManager($_db, $_db.sessionIntervals).filter(
      (f) => f.sessionUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _sessionIntervalsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionSamplesTable, List<SessionSample>> _sessionSamplesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionSamples,
        aliasName: $_aliasNameGenerator(
          db.sessions.uuid,
          db.sessionSamples.sessionUuid,
        ),
      );

  $$SessionSamplesTableProcessedTableManager get sessionSamplesRefs {
    final manager = $$SessionSamplesTableTableManager($_db, $_db.sessionSamples).filter(
      (f) => f.sessionUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_sessionSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardioFeedbackTable, List<CardioFeedbackData>> _cardioFeedbackRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardioFeedback,
    aliasName: $_aliasNameGenerator(
      db.sessions.uuid,
      db.cardioFeedback.sessionUuid,
    ),
  );

  $$CardioFeedbackTableProcessedTableManager get cardioFeedbackRefs {
    final manager = $$CardioFeedbackTableTableManager($_db, $_db.cardioFeedback).filter(
      (f) => f.sessionUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_cardioFeedbackRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<int> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get source => $composableBuilder(
    column: $table.source,
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

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionCardioRefs(
    Expression<bool> Function($$SessionCardioTableFilterComposer f) f,
  ) {
    final $$SessionCardioTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionCardio,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionCardioTableFilterComposer(
            $db: $db,
            $table: $db.sessionCardio,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionIntervalsRefs(
    Expression<bool> Function($$SessionIntervalsTableFilterComposer f) f,
  ) {
    final $$SessionIntervalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionIntervals,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionIntervalsTableFilterComposer(
            $db: $db,
            $table: $db.sessionIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionSamplesRefs(
    Expression<bool> Function($$SessionSamplesTableFilterComposer f) f,
  ) {
    final $$SessionSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionSamples,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSamplesTableFilterComposer(
            $db: $db,
            $table: $db.sessionSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardioFeedbackRefs(
    Expression<bool> Function($$CardioFeedbackTableFilterComposer f) f,
  ) {
    final $$CardioFeedbackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.cardioFeedback,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioFeedbackTableFilterComposer(
            $db: $db,
            $table: $db.cardioFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<int> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
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

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get sport => $composableBuilder(column: $table.sport, builder: (column) => column);

  GeneratedColumn<int> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get periodNumber => $composableBuilder(
    column: $table.periodNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayNumber => $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get dayName => $composableBuilder(column: $table.dayName, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime => $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime => $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerUuid => $composableBuilder(column: $table.ownerUuid, builder: (column) => column);

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionCardioRefs<T extends Object>(
    Expression<T> Function($$SessionCardioTableAnnotationComposer a) f,
  ) {
    final $$SessionCardioTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionCardio,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionCardioTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionCardio,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionIntervalsRefs<T extends Object>(
    Expression<T> Function($$SessionIntervalsTableAnnotationComposer a) f,
  ) {
    final $$SessionIntervalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionIntervals,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionIntervalsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionSamplesRefs<T extends Object>(
    Expression<T> Function($$SessionSamplesTableAnnotationComposer a) f,
  ) {
    final $$SessionSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.sessionSamples,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardioFeedbackRefs<T extends Object>(
    Expression<T> Function($$CardioFeedbackTableAnnotationComposer a) f,
  ) {
    final $$CardioFeedbackTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.cardioFeedback,
      getReferencedColumn: (t) => t.sessionUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioFeedbackTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool trainingCycleUuid,
            bool sessionCardioRefs,
            bool sessionIntervalsRefs,
            bool sessionSamplesRefs,
            bool cardioFeedbackRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String?> trainingCycleUuid = const Value.absent(),
                Value<int> sport = const Value.absent(),
                Value<int> source = const Value.absent(),
                Value<int?> periodNumber = const Value.absent(),
                Value<int?> dayNumber = const Value.absent(),
                Value<String?> dayName = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                sport: sport,
                source: source,
                periodNumber: periodNumber,
                dayNumber: dayNumber,
                dayName: dayName,
                label: label,
                status: status,
                scheduledDate: scheduledDate,
                completedDate: completedDate,
                startTime: startTime,
                endTime: endTime,
                notes: notes,
                externalId: externalId,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<String?> trainingCycleUuid = const Value.absent(),
                required int sport,
                required int source,
                Value<int?> periodNumber = const Value.absent(),
                Value<int?> dayNumber = const Value.absent(),
                Value<String?> dayName = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required int status,
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                sport: sport,
                source: source,
                periodNumber: periodNumber,
                dayNumber: dayNumber,
                dayName: dayName,
                label: label,
                status: status,
                scheduledDate: scheduledDate,
                completedDate: completedDate,
                startTime: startTime,
                endTime: endTime,
                notes: notes,
                externalId: externalId,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trainingCycleUuid = false,
                sessionCardioRefs = false,
                sessionIntervalsRefs = false,
                sessionSamplesRefs = false,
                cardioFeedbackRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionCardioRefs) db.sessionCardio,
                    if (sessionIntervalsRefs) db.sessionIntervals,
                    if (sessionSamplesRefs) db.sessionSamples,
                    if (cardioFeedbackRefs) db.cardioFeedback,
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
                        if (trainingCycleUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.trainingCycleUuid,
                                    referencedTable: $$SessionsTableReferences._trainingCycleUuidTable(db),
                                    referencedColumn: $$SessionsTableReferences._trainingCycleUuidTable(db).uuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionCardioRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionCardioData>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionCardioRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionCardioRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionUuid == item.uuid,
                          ),
                          typedResults: items,
                        ),
                      if (sessionIntervalsRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionInterval>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionIntervalsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionIntervalsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionUuid == item.uuid,
                          ),
                          typedResults: items,
                        ),
                      if (sessionSamplesRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, SessionSample>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._sessionSamplesRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionSamplesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionUuid == item.uuid,
                          ),
                          typedResults: items,
                        ),
                      if (cardioFeedbackRefs)
                        await $_getPrefetchedData<Session, $SessionsTable, CardioFeedbackData>(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences._cardioFeedbackRefsTable(db),
                          managerFromTypedResult: (p0) => $$SessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).cardioFeedbackRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionUuid == item.uuid,
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool trainingCycleUuid,
        bool sessionCardioRefs,
        bool sessionIntervalsRefs,
        bool sessionSamplesRefs,
        bool cardioFeedbackRefs,
      })
    >;
typedef $$CyclePeriodsTableCreateCompanionBuilder =
    CyclePeriodsCompanion Function({
      Value<int> id,
      required String uuid,
      required String trainingCycleUuid,
      required int periodNumber,
      Value<int?> phase,
      Value<String?> notes,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });
typedef $$CyclePeriodsTableUpdateCompanionBuilder =
    CyclePeriodsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> trainingCycleUuid,
      Value<int> periodNumber,
      Value<int?> phase,
      Value<String?> notes,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });

final class $$CyclePeriodsTableReferences extends BaseReferences<_$AppDatabase, $CyclePeriodsTable, CyclePeriod> {
  $$CyclePeriodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingCyclesTable _trainingCycleUuidTable(_$AppDatabase db) => db.trainingCycles.createAlias(
    $_aliasNameGenerator(
      db.cyclePeriods.trainingCycleUuid,
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
}

class $$CyclePeriodsTableFilterComposer extends Composer<_$AppDatabase, $CyclePeriodsTable> {
  $$CyclePeriodsTableFilterComposer({
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

  ColumnFilters<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CyclePeriodsTableOrderingComposer extends Composer<_$AppDatabase, $CyclePeriodsTable> {
  $$CyclePeriodsTableOrderingComposer({
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

  ColumnOrderings<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CyclePeriodsTableAnnotationComposer extends Composer<_$AppDatabase, $CyclePeriodsTable> {
  $$CyclePeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get periodNumber => $composableBuilder(
    column: $table.periodNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get phase => $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerUuid => $composableBuilder(column: $table.ownerUuid, builder: (column) => column);

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
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CyclePeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CyclePeriodsTable,
          CyclePeriod,
          $$CyclePeriodsTableFilterComposer,
          $$CyclePeriodsTableOrderingComposer,
          $$CyclePeriodsTableAnnotationComposer,
          $$CyclePeriodsTableCreateCompanionBuilder,
          $$CyclePeriodsTableUpdateCompanionBuilder,
          (CyclePeriod, $$CyclePeriodsTableReferences),
          CyclePeriod,
          PrefetchHooks Function({bool trainingCycleUuid})
        > {
  $$CyclePeriodsTableTableManager(_$AppDatabase db, $CyclePeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CyclePeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CyclePeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CyclePeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> trainingCycleUuid = const Value.absent(),
                Value<int> periodNumber = const Value.absent(),
                Value<int?> phase = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => CyclePeriodsCompanion(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                periodNumber: periodNumber,
                phase: phase,
                notes: notes,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String trainingCycleUuid,
                required int periodNumber,
                Value<int?> phase = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => CyclePeriodsCompanion.insert(
                id: id,
                uuid: uuid,
                trainingCycleUuid: trainingCycleUuid,
                periodNumber: periodNumber,
                phase: phase,
                notes: notes,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CyclePeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trainingCycleUuid = false}) {
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
                    if (trainingCycleUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trainingCycleUuid,
                                referencedTable: $$CyclePeriodsTableReferences._trainingCycleUuidTable(db),
                                referencedColumn: $$CyclePeriodsTableReferences._trainingCycleUuidTable(db).uuid,
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

typedef $$CyclePeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CyclePeriodsTable,
      CyclePeriod,
      $$CyclePeriodsTableFilterComposer,
      $$CyclePeriodsTableOrderingComposer,
      $$CyclePeriodsTableAnnotationComposer,
      $$CyclePeriodsTableCreateCompanionBuilder,
      $$CyclePeriodsTableUpdateCompanionBuilder,
      (CyclePeriod, $$CyclePeriodsTableReferences),
      CyclePeriod,
      PrefetchHooks Function({bool trainingCycleUuid})
    >;
typedef $$SessionCardioTableCreateCompanionBuilder =
    SessionCardioCompanion Function({
      Value<int> id,
      required String sessionUuid,
      Value<double?> plannedDistanceM,
      Value<double?> actualDistanceM,
      Value<int?> plannedDurationSec,
      Value<int?> actualDurationSec,
      Value<double?> elevationGainM,
      Value<double?> elevationLossM,
      Value<int?> averageHr,
      Value<int?> maxHr,
      Value<double?> averageCadence,
      Value<double?> averagePowerWatts,
      Value<double?> normalizedPowerWatts,
      Value<double?> averageSpeedMps,
      Value<double?> averagePaceSecPerMeter,
      Value<double?> poolLengthM,
      Value<int?> strokeType,
      Value<int?> lapCount,
      Value<int?> swolf,
      Value<int?> perceivedExertion,
      Value<String?> notes,
    });
typedef $$SessionCardioTableUpdateCompanionBuilder =
    SessionCardioCompanion Function({
      Value<int> id,
      Value<String> sessionUuid,
      Value<double?> plannedDistanceM,
      Value<double?> actualDistanceM,
      Value<int?> plannedDurationSec,
      Value<int?> actualDurationSec,
      Value<double?> elevationGainM,
      Value<double?> elevationLossM,
      Value<int?> averageHr,
      Value<int?> maxHr,
      Value<double?> averageCadence,
      Value<double?> averagePowerWatts,
      Value<double?> normalizedPowerWatts,
      Value<double?> averageSpeedMps,
      Value<double?> averagePaceSecPerMeter,
      Value<double?> poolLengthM,
      Value<int?> strokeType,
      Value<int?> lapCount,
      Value<int?> swolf,
      Value<int?> perceivedExertion,
      Value<String?> notes,
    });

final class $$SessionCardioTableReferences
    extends BaseReferences<_$AppDatabase, $SessionCardioTable, SessionCardioData> {
  $$SessionCardioTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions.createAlias(
    $_aliasNameGenerator(db.sessionCardio.sessionUuid, db.sessions.uuid),
  );

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionCardioTableFilterComposer extends Composer<_$AppDatabase, $SessionCardioTable> {
  $$SessionCardioTableFilterComposer({
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

  ColumnFilters<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLossM => $composableBuilder(
    column: $table.elevationLossM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get averageHr => $composableBuilder(
    column: $table.averageHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageCadence => $composableBuilder(
    column: $table.averageCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averagePowerWatts => $composableBuilder(
    column: $table.averagePowerWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedPowerWatts => $composableBuilder(
    column: $table.normalizedPowerWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averagePaceSecPerMeter => $composableBuilder(
    column: $table.averagePaceSecPerMeter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get poolLengthM => $composableBuilder(
    column: $table.poolLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeType => $composableBuilder(
    column: $table.strokeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapCount => $composableBuilder(
    column: $table.lapCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get swolf => $composableBuilder(
    column: $table.swolf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionCardioTableOrderingComposer extends Composer<_$AppDatabase, $SessionCardioTable> {
  $$SessionCardioTableOrderingComposer({
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

  ColumnOrderings<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLossM => $composableBuilder(
    column: $table.elevationLossM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averageHr => $composableBuilder(
    column: $table.averageHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageCadence => $composableBuilder(
    column: $table.averageCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averagePowerWatts => $composableBuilder(
    column: $table.averagePowerWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedPowerWatts => $composableBuilder(
    column: $table.normalizedPowerWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averagePaceSecPerMeter => $composableBuilder(
    column: $table.averagePaceSecPerMeter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get poolLengthM => $composableBuilder(
    column: $table.poolLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeType => $composableBuilder(
    column: $table.strokeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapCount => $composableBuilder(
    column: $table.lapCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get swolf => $composableBuilder(
    column: $table.swolf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionCardioTableAnnotationComposer extends Composer<_$AppDatabase, $SessionCardioTable> {
  $$SessionCardioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get plannedDistanceM => $composableBuilder(
    column: $table.plannedDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSec => $composableBuilder(
    column: $table.plannedDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLossM => $composableBuilder(
    column: $table.elevationLossM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get averageHr => $composableBuilder(column: $table.averageHr, builder: (column) => column);

  GeneratedColumn<int> get maxHr => $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<double> get averageCadence => $composableBuilder(
    column: $table.averageCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averagePowerWatts => $composableBuilder(
    column: $table.averagePowerWatts,
    builder: (column) => column,
  );

  GeneratedColumn<double> get normalizedPowerWatts => $composableBuilder(
    column: $table.normalizedPowerWatts,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averagePaceSecPerMeter => $composableBuilder(
    column: $table.averagePaceSecPerMeter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get poolLengthM => $composableBuilder(
    column: $table.poolLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get strokeType => $composableBuilder(
    column: $table.strokeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapCount => $composableBuilder(column: $table.lapCount, builder: (column) => column);

  GeneratedColumn<int> get swolf => $composableBuilder(column: $table.swolf, builder: (column) => column);

  GeneratedColumn<int> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionCardioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionCardioTable,
          SessionCardioData,
          $$SessionCardioTableFilterComposer,
          $$SessionCardioTableOrderingComposer,
          $$SessionCardioTableAnnotationComposer,
          $$SessionCardioTableCreateCompanionBuilder,
          $$SessionCardioTableUpdateCompanionBuilder,
          (SessionCardioData, $$SessionCardioTableReferences),
          SessionCardioData,
          PrefetchHooks Function({bool sessionUuid})
        > {
  $$SessionCardioTableTableManager(_$AppDatabase db, $SessionCardioTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionCardioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionCardioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionCardioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> elevationGainM = const Value.absent(),
                Value<double?> elevationLossM = const Value.absent(),
                Value<int?> averageHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<double?> averageCadence = const Value.absent(),
                Value<double?> averagePowerWatts = const Value.absent(),
                Value<double?> normalizedPowerWatts = const Value.absent(),
                Value<double?> averageSpeedMps = const Value.absent(),
                Value<double?> averagePaceSecPerMeter = const Value.absent(),
                Value<double?> poolLengthM = const Value.absent(),
                Value<int?> strokeType = const Value.absent(),
                Value<int?> lapCount = const Value.absent(),
                Value<int?> swolf = const Value.absent(),
                Value<int?> perceivedExertion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionCardioCompanion(
                id: id,
                sessionUuid: sessionUuid,
                plannedDistanceM: plannedDistanceM,
                actualDistanceM: actualDistanceM,
                plannedDurationSec: plannedDurationSec,
                actualDurationSec: actualDurationSec,
                elevationGainM: elevationGainM,
                elevationLossM: elevationLossM,
                averageHr: averageHr,
                maxHr: maxHr,
                averageCadence: averageCadence,
                averagePowerWatts: averagePowerWatts,
                normalizedPowerWatts: normalizedPowerWatts,
                averageSpeedMps: averageSpeedMps,
                averagePaceSecPerMeter: averagePaceSecPerMeter,
                poolLengthM: poolLengthM,
                strokeType: strokeType,
                lapCount: lapCount,
                swolf: swolf,
                perceivedExertion: perceivedExertion,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionUuid,
                Value<double?> plannedDistanceM = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<int?> plannedDurationSec = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> elevationGainM = const Value.absent(),
                Value<double?> elevationLossM = const Value.absent(),
                Value<int?> averageHr = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<double?> averageCadence = const Value.absent(),
                Value<double?> averagePowerWatts = const Value.absent(),
                Value<double?> normalizedPowerWatts = const Value.absent(),
                Value<double?> averageSpeedMps = const Value.absent(),
                Value<double?> averagePaceSecPerMeter = const Value.absent(),
                Value<double?> poolLengthM = const Value.absent(),
                Value<int?> strokeType = const Value.absent(),
                Value<int?> lapCount = const Value.absent(),
                Value<int?> swolf = const Value.absent(),
                Value<int?> perceivedExertion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionCardioCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                plannedDistanceM: plannedDistanceM,
                actualDistanceM: actualDistanceM,
                plannedDurationSec: plannedDurationSec,
                actualDurationSec: actualDurationSec,
                elevationGainM: elevationGainM,
                elevationLossM: elevationLossM,
                averageHr: averageHr,
                maxHr: maxHr,
                averageCadence: averageCadence,
                averagePowerWatts: averagePowerWatts,
                normalizedPowerWatts: normalizedPowerWatts,
                averageSpeedMps: averageSpeedMps,
                averagePaceSecPerMeter: averagePaceSecPerMeter,
                poolLengthM: poolLengthM,
                strokeType: strokeType,
                lapCount: lapCount,
                swolf: swolf,
                perceivedExertion: perceivedExertion,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionCardioTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false}) {
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
                    if (sessionUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionUuid,
                                referencedTable: $$SessionCardioTableReferences._sessionUuidTable(db),
                                referencedColumn: $$SessionCardioTableReferences._sessionUuidTable(db).uuid,
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

typedef $$SessionCardioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionCardioTable,
      SessionCardioData,
      $$SessionCardioTableFilterComposer,
      $$SessionCardioTableOrderingComposer,
      $$SessionCardioTableAnnotationComposer,
      $$SessionCardioTableCreateCompanionBuilder,
      $$SessionCardioTableUpdateCompanionBuilder,
      (SessionCardioData, $$SessionCardioTableReferences),
      SessionCardioData,
      PrefetchHooks Function({bool sessionUuid})
    >;
typedef $$SessionIntervalsTableCreateCompanionBuilder =
    SessionIntervalsCompanion Function({
      Value<int> id,
      required String uuid,
      required String sessionUuid,
      required int orderIndex,
      required int intentType,
      required int targetKind,
      Value<int?> targetDurationSec,
      Value<double?> targetDistanceM,
      Value<int?> targetHrZone,
      Value<int?> targetPaceZone,
      Value<int?> targetPowerZone,
      Value<double?> targetValueMin,
      Value<double?> targetValueMax,
      Value<String?> targetFreeform,
      Value<int?> actualDurationSec,
      Value<double?> actualDistanceM,
      Value<int?> actualAverageHr,
      Value<double?> actualAveragePaceSecPerMeter,
      Value<double?> actualAveragePowerWatts,
      Value<int?> repeatCount,
      Value<String?> parentIntervalUuid,
      Value<String?> notes,
    });
typedef $$SessionIntervalsTableUpdateCompanionBuilder =
    SessionIntervalsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> sessionUuid,
      Value<int> orderIndex,
      Value<int> intentType,
      Value<int> targetKind,
      Value<int?> targetDurationSec,
      Value<double?> targetDistanceM,
      Value<int?> targetHrZone,
      Value<int?> targetPaceZone,
      Value<int?> targetPowerZone,
      Value<double?> targetValueMin,
      Value<double?> targetValueMax,
      Value<String?> targetFreeform,
      Value<int?> actualDurationSec,
      Value<double?> actualDistanceM,
      Value<int?> actualAverageHr,
      Value<double?> actualAveragePaceSecPerMeter,
      Value<double?> actualAveragePowerWatts,
      Value<int?> repeatCount,
      Value<String?> parentIntervalUuid,
      Value<String?> notes,
    });

final class $$SessionIntervalsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionIntervalsTable, SessionInterval> {
  $$SessionIntervalsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions.createAlias(
    $_aliasNameGenerator(db.sessionIntervals.sessionUuid, db.sessions.uuid),
  );

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionIntervalsTableFilterComposer extends Composer<_$AppDatabase, $SessionIntervalsTable> {
  $$SessionIntervalsTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentType => $composableBuilder(
    column: $table.intentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetHrZone => $composableBuilder(
    column: $table.targetHrZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPaceZone => $composableBuilder(
    column: $table.targetPaceZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPowerZone => $composableBuilder(
    column: $table.targetPowerZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValueMin => $composableBuilder(
    column: $table.targetValueMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValueMax => $composableBuilder(
    column: $table.targetValueMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetFreeform => $composableBuilder(
    column: $table.targetFreeform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualAverageHr => $composableBuilder(
    column: $table.actualAverageHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualAveragePaceSecPerMeter => $composableBuilder(
    column: $table.actualAveragePaceSecPerMeter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualAveragePowerWatts => $composableBuilder(
    column: $table.actualAveragePowerWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentIntervalUuid => $composableBuilder(
    column: $table.parentIntervalUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionIntervalsTableOrderingComposer extends Composer<_$AppDatabase, $SessionIntervalsTable> {
  $$SessionIntervalsTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentType => $composableBuilder(
    column: $table.intentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetHrZone => $composableBuilder(
    column: $table.targetHrZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPaceZone => $composableBuilder(
    column: $table.targetPaceZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPowerZone => $composableBuilder(
    column: $table.targetPowerZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValueMin => $composableBuilder(
    column: $table.targetValueMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValueMax => $composableBuilder(
    column: $table.targetValueMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetFreeform => $composableBuilder(
    column: $table.targetFreeform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualAverageHr => $composableBuilder(
    column: $table.actualAverageHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualAveragePaceSecPerMeter => $composableBuilder(
    column: $table.actualAveragePaceSecPerMeter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualAveragePowerWatts => $composableBuilder(
    column: $table.actualAveragePowerWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentIntervalUuid => $composableBuilder(
    column: $table.parentIntervalUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionIntervalsTableAnnotationComposer extends Composer<_$AppDatabase, $SessionIntervalsTable> {
  $$SessionIntervalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intentType => $composableBuilder(
    column: $table.intentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetHrZone => $composableBuilder(
    column: $table.targetHrZone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPaceZone => $composableBuilder(
    column: $table.targetPaceZone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPowerZone => $composableBuilder(
    column: $table.targetPowerZone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValueMin => $composableBuilder(
    column: $table.targetValueMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValueMax => $composableBuilder(
    column: $table.targetValueMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetFreeform => $composableBuilder(
    column: $table.targetFreeform,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSec => $composableBuilder(
    column: $table.actualDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceM => $composableBuilder(
    column: $table.actualDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualAverageHr => $composableBuilder(
    column: $table.actualAverageHr,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualAveragePaceSecPerMeter => $composableBuilder(
    column: $table.actualAveragePaceSecPerMeter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualAveragePowerWatts => $composableBuilder(
    column: $table.actualAveragePowerWatts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentIntervalUuid => $composableBuilder(
    column: $table.parentIntervalUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionIntervalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionIntervalsTable,
          SessionInterval,
          $$SessionIntervalsTableFilterComposer,
          $$SessionIntervalsTableOrderingComposer,
          $$SessionIntervalsTableAnnotationComposer,
          $$SessionIntervalsTableCreateCompanionBuilder,
          $$SessionIntervalsTableUpdateCompanionBuilder,
          (SessionInterval, $$SessionIntervalsTableReferences),
          SessionInterval,
          PrefetchHooks Function({bool sessionUuid})
        > {
  $$SessionIntervalsTableTableManager(
    _$AppDatabase db,
    $SessionIntervalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionIntervalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionIntervalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionIntervalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> intentType = const Value.absent(),
                Value<int> targetKind = const Value.absent(),
                Value<int?> targetDurationSec = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                Value<int?> targetHrZone = const Value.absent(),
                Value<int?> targetPaceZone = const Value.absent(),
                Value<int?> targetPowerZone = const Value.absent(),
                Value<double?> targetValueMin = const Value.absent(),
                Value<double?> targetValueMax = const Value.absent(),
                Value<String?> targetFreeform = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<int?> actualAverageHr = const Value.absent(),
                Value<double?> actualAveragePaceSecPerMeter = const Value.absent(),
                Value<double?> actualAveragePowerWatts = const Value.absent(),
                Value<int?> repeatCount = const Value.absent(),
                Value<String?> parentIntervalUuid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionIntervalsCompanion(
                id: id,
                uuid: uuid,
                sessionUuid: sessionUuid,
                orderIndex: orderIndex,
                intentType: intentType,
                targetKind: targetKind,
                targetDurationSec: targetDurationSec,
                targetDistanceM: targetDistanceM,
                targetHrZone: targetHrZone,
                targetPaceZone: targetPaceZone,
                targetPowerZone: targetPowerZone,
                targetValueMin: targetValueMin,
                targetValueMax: targetValueMax,
                targetFreeform: targetFreeform,
                actualDurationSec: actualDurationSec,
                actualDistanceM: actualDistanceM,
                actualAverageHr: actualAverageHr,
                actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter,
                actualAveragePowerWatts: actualAveragePowerWatts,
                repeatCount: repeatCount,
                parentIntervalUuid: parentIntervalUuid,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String sessionUuid,
                required int orderIndex,
                required int intentType,
                required int targetKind,
                Value<int?> targetDurationSec = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                Value<int?> targetHrZone = const Value.absent(),
                Value<int?> targetPaceZone = const Value.absent(),
                Value<int?> targetPowerZone = const Value.absent(),
                Value<double?> targetValueMin = const Value.absent(),
                Value<double?> targetValueMax = const Value.absent(),
                Value<String?> targetFreeform = const Value.absent(),
                Value<int?> actualDurationSec = const Value.absent(),
                Value<double?> actualDistanceM = const Value.absent(),
                Value<int?> actualAverageHr = const Value.absent(),
                Value<double?> actualAveragePaceSecPerMeter = const Value.absent(),
                Value<double?> actualAveragePowerWatts = const Value.absent(),
                Value<int?> repeatCount = const Value.absent(),
                Value<String?> parentIntervalUuid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionIntervalsCompanion.insert(
                id: id,
                uuid: uuid,
                sessionUuid: sessionUuid,
                orderIndex: orderIndex,
                intentType: intentType,
                targetKind: targetKind,
                targetDurationSec: targetDurationSec,
                targetDistanceM: targetDistanceM,
                targetHrZone: targetHrZone,
                targetPaceZone: targetPaceZone,
                targetPowerZone: targetPowerZone,
                targetValueMin: targetValueMin,
                targetValueMax: targetValueMax,
                targetFreeform: targetFreeform,
                actualDurationSec: actualDurationSec,
                actualDistanceM: actualDistanceM,
                actualAverageHr: actualAverageHr,
                actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter,
                actualAveragePowerWatts: actualAveragePowerWatts,
                repeatCount: repeatCount,
                parentIntervalUuid: parentIntervalUuid,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionIntervalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false}) {
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
                    if (sessionUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionUuid,
                                referencedTable: $$SessionIntervalsTableReferences._sessionUuidTable(db),
                                referencedColumn: $$SessionIntervalsTableReferences._sessionUuidTable(db).uuid,
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

typedef $$SessionIntervalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionIntervalsTable,
      SessionInterval,
      $$SessionIntervalsTableFilterComposer,
      $$SessionIntervalsTableOrderingComposer,
      $$SessionIntervalsTableAnnotationComposer,
      $$SessionIntervalsTableCreateCompanionBuilder,
      $$SessionIntervalsTableUpdateCompanionBuilder,
      (SessionInterval, $$SessionIntervalsTableReferences),
      SessionInterval,
      PrefetchHooks Function({bool sessionUuid})
    >;
typedef $$SessionSamplesTableCreateCompanionBuilder =
    SessionSamplesCompanion Function({
      Value<int> id,
      required String sessionUuid,
      required int offsetSec,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> altitudeM,
      Value<int?> hr,
      Value<double?> cadence,
      Value<double?> powerW,
      Value<double?> speedMps,
      Value<double?> strokeRate,
    });
typedef $$SessionSamplesTableUpdateCompanionBuilder =
    SessionSamplesCompanion Function({
      Value<int> id,
      Value<String> sessionUuid,
      Value<int> offsetSec,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> altitudeM,
      Value<int?> hr,
      Value<double?> cadence,
      Value<double?> powerW,
      Value<double?> speedMps,
      Value<double?> strokeRate,
    });

final class $$SessionSamplesTableReferences extends BaseReferences<_$AppDatabase, $SessionSamplesTable, SessionSample> {
  $$SessionSamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions.createAlias(
    $_aliasNameGenerator(db.sessionSamples.sessionUuid, db.sessions.uuid),
  );

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionSamplesTableFilterComposer extends Composer<_$AppDatabase, $SessionSamplesTable> {
  $$SessionSamplesTableFilterComposer({
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

  ColumnFilters<int> get offsetSec => $composableBuilder(
    column: $table.offsetSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hr => $composableBuilder(
    column: $table.hr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerW => $composableBuilder(
    column: $table.powerW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strokeRate => $composableBuilder(
    column: $table.strokeRate,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSamplesTableOrderingComposer extends Composer<_$AppDatabase, $SessionSamplesTable> {
  $$SessionSamplesTableOrderingComposer({
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

  ColumnOrderings<int> get offsetSec => $composableBuilder(
    column: $table.offsetSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hr => $composableBuilder(
    column: $table.hr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerW => $composableBuilder(
    column: $table.powerW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strokeRate => $composableBuilder(
    column: $table.strokeRate,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSamplesTableAnnotationComposer extends Composer<_$AppDatabase, $SessionSamplesTable> {
  $$SessionSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get offsetSec => $composableBuilder(column: $table.offsetSec, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get altitudeM => $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<int> get hr => $composableBuilder(column: $table.hr, builder: (column) => column);

  GeneratedColumn<double> get cadence => $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<double> get powerW => $composableBuilder(column: $table.powerW, builder: (column) => column);

  GeneratedColumn<double> get speedMps => $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<double> get strokeRate => $composableBuilder(
    column: $table.strokeRate,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSamplesTable,
          SessionSample,
          $$SessionSamplesTableFilterComposer,
          $$SessionSamplesTableOrderingComposer,
          $$SessionSamplesTableAnnotationComposer,
          $$SessionSamplesTableCreateCompanionBuilder,
          $$SessionSamplesTableUpdateCompanionBuilder,
          (SessionSample, $$SessionSamplesTableReferences),
          SessionSample,
          PrefetchHooks Function({bool sessionUuid})
        > {
  $$SessionSamplesTableTableManager(
    _$AppDatabase db,
    $SessionSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<int> offsetSec = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<int?> hr = const Value.absent(),
                Value<double?> cadence = const Value.absent(),
                Value<double?> powerW = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<double?> strokeRate = const Value.absent(),
              }) => SessionSamplesCompanion(
                id: id,
                sessionUuid: sessionUuid,
                offsetSec: offsetSec,
                lat: lat,
                lng: lng,
                altitudeM: altitudeM,
                hr: hr,
                cadence: cadence,
                powerW: powerW,
                speedMps: speedMps,
                strokeRate: strokeRate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionUuid,
                required int offsetSec,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<int?> hr = const Value.absent(),
                Value<double?> cadence = const Value.absent(),
                Value<double?> powerW = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<double?> strokeRate = const Value.absent(),
              }) => SessionSamplesCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                offsetSec: offsetSec,
                lat: lat,
                lng: lng,
                altitudeM: altitudeM,
                hr: hr,
                cadence: cadence,
                powerW: powerW,
                speedMps: speedMps,
                strokeRate: strokeRate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false}) {
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
                    if (sessionUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionUuid,
                                referencedTable: $$SessionSamplesTableReferences._sessionUuidTable(db),
                                referencedColumn: $$SessionSamplesTableReferences._sessionUuidTable(db).uuid,
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

typedef $$SessionSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSamplesTable,
      SessionSample,
      $$SessionSamplesTableFilterComposer,
      $$SessionSamplesTableOrderingComposer,
      $$SessionSamplesTableAnnotationComposer,
      $$SessionSamplesTableCreateCompanionBuilder,
      $$SessionSamplesTableUpdateCompanionBuilder,
      (SessionSample, $$SessionSamplesTableReferences),
      SessionSample,
      PrefetchHooks Function({bool sessionUuid})
    >;
typedef $$SportZonesTableCreateCompanionBuilder =
    SportZonesCompanion Function({
      Value<int> id,
      required String uuid,
      required int sport,
      required int zoneNumber,
      required double minValue,
      required double maxValue,
      required String unit,
      Value<String?> ownerUuid,
      required DateTime createdAt,
    });
typedef $$SportZonesTableUpdateCompanionBuilder =
    SportZonesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> sport,
      Value<int> zoneNumber,
      Value<double> minValue,
      Value<double> maxValue,
      Value<String> unit,
      Value<String?> ownerUuid,
      Value<DateTime> createdAt,
    });

class $$SportZonesTableFilterComposer extends Composer<_$AppDatabase, $SportZonesTable> {
  $$SportZonesTableFilterComposer({
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

  ColumnFilters<int> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zoneNumber => $composableBuilder(
    column: $table.zoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SportZonesTableOrderingComposer extends Composer<_$AppDatabase, $SportZonesTable> {
  $$SportZonesTableOrderingComposer({
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

  ColumnOrderings<int> get sport => $composableBuilder(
    column: $table.sport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoneNumber => $composableBuilder(
    column: $table.zoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SportZonesTableAnnotationComposer extends Composer<_$AppDatabase, $SportZonesTable> {
  $$SportZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get sport => $composableBuilder(column: $table.sport, builder: (column) => column);

  GeneratedColumn<int> get zoneNumber => $composableBuilder(
    column: $table.zoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minValue => $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue => $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<String> get unit => $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get ownerUuid => $composableBuilder(column: $table.ownerUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SportZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SportZonesTable,
          SportZone,
          $$SportZonesTableFilterComposer,
          $$SportZonesTableOrderingComposer,
          $$SportZonesTableAnnotationComposer,
          $$SportZonesTableCreateCompanionBuilder,
          $$SportZonesTableUpdateCompanionBuilder,
          (
            SportZone,
            BaseReferences<_$AppDatabase, $SportZonesTable, SportZone>,
          ),
          SportZone,
          PrefetchHooks Function()
        > {
  $$SportZonesTableTableManager(_$AppDatabase db, $SportZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SportZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SportZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SportZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> sport = const Value.absent(),
                Value<int> zoneNumber = const Value.absent(),
                Value<double> minValue = const Value.absent(),
                Value<double> maxValue = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SportZonesCompanion(
                id: id,
                uuid: uuid,
                sport: sport,
                zoneNumber: zoneNumber,
                minValue: minValue,
                maxValue: maxValue,
                unit: unit,
                ownerUuid: ownerUuid,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required int sport,
                required int zoneNumber,
                required double minValue,
                required double maxValue,
                required String unit,
                Value<String?> ownerUuid = const Value.absent(),
                required DateTime createdAt,
              }) => SportZonesCompanion.insert(
                id: id,
                uuid: uuid,
                sport: sport,
                zoneNumber: zoneNumber,
                minValue: minValue,
                maxValue: maxValue,
                unit: unit,
                ownerUuid: ownerUuid,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SportZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SportZonesTable,
      SportZone,
      $$SportZonesTableFilterComposer,
      $$SportZonesTableOrderingComposer,
      $$SportZonesTableAnnotationComposer,
      $$SportZonesTableCreateCompanionBuilder,
      $$SportZonesTableUpdateCompanionBuilder,
      (SportZone, BaseReferences<_$AppDatabase, $SportZonesTable, SportZone>),
      SportZone,
      PrefetchHooks Function()
    >;
typedef $$CardioFeedbackTableCreateCompanionBuilder =
    CardioFeedbackCompanion Function({
      Value<int> id,
      required String sessionUuid,
      Value<int?> rpe,
      Value<int?> breathing,
      Value<int?> giComfort,
      Value<String?> weather,
      Value<String?> notes,
      Value<DateTime?> timestamp,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });
typedef $$CardioFeedbackTableUpdateCompanionBuilder =
    CardioFeedbackCompanion Function({
      Value<int> id,
      Value<String> sessionUuid,
      Value<int?> rpe,
      Value<int?> breathing,
      Value<int?> giComfort,
      Value<String?> weather,
      Value<String?> notes,
      Value<DateTime?> timestamp,
      Value<String?> creatorUuid,
      Value<String?> ownerUuid,
    });

final class $$CardioFeedbackTableReferences
    extends BaseReferences<_$AppDatabase, $CardioFeedbackTable, CardioFeedbackData> {
  $$CardioFeedbackTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionUuidTable(_$AppDatabase db) => db.sessions.createAlias(
    $_aliasNameGenerator(db.cardioFeedback.sessionUuid, db.sessions.uuid),
  );

  $$SessionsTableProcessedTableManager get sessionUuid {
    final $_column = $_itemColumn<String>('session_uuid')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardioFeedbackTableFilterComposer extends Composer<_$AppDatabase, $CardioFeedbackTable> {
  $$CardioFeedbackTableFilterComposer({
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

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breathing => $composableBuilder(
    column: $table.breathing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get giComfort => $composableBuilder(
    column: $table.giComfort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionUuid {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioFeedbackTableOrderingComposer extends Composer<_$AppDatabase, $CardioFeedbackTable> {
  $$CardioFeedbackTableOrderingComposer({
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

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breathing => $composableBuilder(
    column: $table.breathing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get giComfort => $composableBuilder(
    column: $table.giComfort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUuid => $composableBuilder(
    column: $table.ownerUuid,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionUuid {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioFeedbackTableAnnotationComposer extends Composer<_$AppDatabase, $CardioFeedbackTable> {
  $$CardioFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rpe => $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get breathing => $composableBuilder(column: $table.breathing, builder: (column) => column);

  GeneratedColumn<int> get giComfort => $composableBuilder(column: $table.giComfort, builder: (column) => column);

  GeneratedColumn<String> get weather => $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp => $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get creatorUuid => $composableBuilder(
    column: $table.creatorUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerUuid => $composableBuilder(column: $table.ownerUuid, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionUuid {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionUuid,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardioFeedbackTable,
          CardioFeedbackData,
          $$CardioFeedbackTableFilterComposer,
          $$CardioFeedbackTableOrderingComposer,
          $$CardioFeedbackTableAnnotationComposer,
          $$CardioFeedbackTableCreateCompanionBuilder,
          $$CardioFeedbackTableUpdateCompanionBuilder,
          (CardioFeedbackData, $$CardioFeedbackTableReferences),
          CardioFeedbackData,
          PrefetchHooks Function({bool sessionUuid})
        > {
  $$CardioFeedbackTableTableManager(
    _$AppDatabase db,
    $CardioFeedbackTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CardioFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CardioFeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CardioFeedbackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int?> breathing = const Value.absent(),
                Value<int?> giComfort = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => CardioFeedbackCompanion(
                id: id,
                sessionUuid: sessionUuid,
                rpe: rpe,
                breathing: breathing,
                giComfort: giComfort,
                weather: weather,
                notes: notes,
                timestamp: timestamp,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionUuid,
                Value<int?> rpe = const Value.absent(),
                Value<int?> breathing = const Value.absent(),
                Value<int?> giComfort = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
                Value<String?> creatorUuid = const Value.absent(),
                Value<String?> ownerUuid = const Value.absent(),
              }) => CardioFeedbackCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                rpe: rpe,
                breathing: breathing,
                giComfort: giComfort,
                weather: weather,
                notes: notes,
                timestamp: timestamp,
                creatorUuid: creatorUuid,
                ownerUuid: ownerUuid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardioFeedbackTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionUuid = false}) {
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
                    if (sessionUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionUuid,
                                referencedTable: $$CardioFeedbackTableReferences._sessionUuidTable(db),
                                referencedColumn: $$CardioFeedbackTableReferences._sessionUuidTable(db).uuid,
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

typedef $$CardioFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardioFeedbackTable,
      CardioFeedbackData,
      $$CardioFeedbackTableFilterComposer,
      $$CardioFeedbackTableOrderingComposer,
      $$CardioFeedbackTableAnnotationComposer,
      $$CardioFeedbackTableCreateCompanionBuilder,
      $$CardioFeedbackTableUpdateCompanionBuilder,
      (CardioFeedbackData, $$CardioFeedbackTableReferences),
      CardioFeedbackData,
      PrefetchHooks Function({bool sessionUuid})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles => $$TrainingCyclesTableTableManager(_db, _db.trainingCycles);
  $$ExercisesTableTableManager get exercises => $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseSetsTableTableManager get exerciseSets => $$ExerciseSetsTableTableManager(_db, _db.exerciseSets);
  $$ExerciseFeedbacksTableTableManager get exerciseFeedbacks =>
      $$ExerciseFeedbacksTableTableManager(_db, _db.exerciseFeedbacks);
  $$CustomExerciseDefinitionsTableTableManager get customExerciseDefinitions =>
      $$CustomExerciseDefinitionsTableTableManager(
        _db,
        _db.customExerciseDefinitions,
      );
  $$UserMeasurementsTableTableManager get userMeasurements =>
      $$UserMeasurementsTableTableManager(_db, _db.userMeasurements);
  $$SkinsTableTableManager get skins => $$SkinsTableTableManager(_db, _db.skins);
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db, _db.sessions);
  $$CyclePeriodsTableTableManager get cyclePeriods => $$CyclePeriodsTableTableManager(_db, _db.cyclePeriods);
  $$SessionCardioTableTableManager get sessionCardio => $$SessionCardioTableTableManager(_db, _db.sessionCardio);
  $$SessionIntervalsTableTableManager get sessionIntervals =>
      $$SessionIntervalsTableTableManager(_db, _db.sessionIntervals);
  $$SessionSamplesTableTableManager get sessionSamples => $$SessionSamplesTableTableManager(_db, _db.sessionSamples);
  $$SportZonesTableTableManager get sportZones => $$SportZonesTableTableManager(_db, _db.sportZones);
  $$CardioFeedbackTableTableManager get cardioFeedback => $$CardioFeedbackTableTableManager(_db, _db.cardioFeedback);
}
