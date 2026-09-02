// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ParentPlantsTable extends ParentPlants
    with TableInfo<$ParentPlantsTable, ParentPlantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentPlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesTextMeta = const VerificationMeta(
    'speciesText',
  );
  @override
  late final GeneratedColumn<String> speciesText = GeneratedColumn<String>(
    'species_text',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtUtcMeta = const VerificationMeta(
    'archivedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAtUtc =
      GeneratedColumn<DateTime>(
        'archived_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    speciesText,
    notes,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_plants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentPlantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('species_text')) {
      context.handle(
        _speciesTextMeta,
        speciesText.isAcceptableOrUnknown(
          data['species_text']!,
          _speciesTextMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('archived_at_utc')) {
      context.handle(
        _archivedAtUtcMeta,
        archivedAtUtc.isAcceptableOrUnknown(
          data['archived_at_utc']!,
          _archivedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentPlantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentPlantRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      speciesText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_text'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      archivedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at_utc'],
      ),
    );
  }

  @override
  $ParentPlantsTable createAlias(String alias) {
    return $ParentPlantsTable(attachedDatabase, alias);
  }
}

class ParentPlantRow extends DataClass implements Insertable<ParentPlantRow> {
  final String id;
  final String nickname;
  final String? speciesText;
  final String notes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? archivedAtUtc;
  const ParentPlantRow({
    required this.id,
    required this.nickname,
    this.speciesText,
    required this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.archivedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || speciesText != null) {
      map['species_text'] = Variable<String>(speciesText);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || archivedAtUtc != null) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc);
    }
    return map;
  }

  ParentPlantsCompanion toCompanion(bool nullToAbsent) {
    return ParentPlantsCompanion(
      id: Value(id),
      nickname: Value(nickname),
      speciesText: speciesText == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesText),
      notes: Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      archivedAtUtc: archivedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtc),
    );
  }

  factory ParentPlantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentPlantRow(
      id: serializer.fromJson<String>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      speciesText: serializer.fromJson<String?>(json['speciesText']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      archivedAtUtc: serializer.fromJson<DateTime?>(json['archivedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nickname': serializer.toJson<String>(nickname),
      'speciesText': serializer.toJson<String?>(speciesText),
      'notes': serializer.toJson<String>(notes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'archivedAtUtc': serializer.toJson<DateTime?>(archivedAtUtc),
    };
  }

  ParentPlantRow copyWith({
    String? id,
    String? nickname,
    Value<String?> speciesText = const Value.absent(),
    String? notes,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> archivedAtUtc = const Value.absent(),
  }) => ParentPlantRow(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    speciesText: speciesText.present ? speciesText.value : this.speciesText,
    notes: notes ?? this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    archivedAtUtc: archivedAtUtc.present
        ? archivedAtUtc.value
        : this.archivedAtUtc,
  );
  ParentPlantRow copyWithCompanion(ParentPlantsCompanion data) {
    return ParentPlantRow(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      speciesText: data.speciesText.present
          ? data.speciesText.value
          : this.speciesText,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      archivedAtUtc: data.archivedAtUtc.present
          ? data.archivedAtUtc.value
          : this.archivedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentPlantRow(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('speciesText: $speciesText, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    speciesText,
    notes,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentPlantRow &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.speciesText == this.speciesText &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.archivedAtUtc == this.archivedAtUtc);
}

class ParentPlantsCompanion extends UpdateCompanion<ParentPlantRow> {
  final Value<String> id;
  final Value<String> nickname;
  final Value<String?> speciesText;
  final Value<String> notes;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> archivedAtUtc;
  final Value<int> rowid;
  const ParentPlantsCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.speciesText = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParentPlantsCompanion.insert({
    required String id,
    required String nickname,
    this.speciesText = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nickname = Value(nickname),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ParentPlantRow> custom({
    Expression<String>? id,
    Expression<String>? nickname,
    Expression<String>? speciesText,
    Expression<String>? notes,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? archivedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (speciesText != null) 'species_text': speciesText,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (archivedAtUtc != null) 'archived_at_utc': archivedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParentPlantsCompanion copyWith({
    Value<String>? id,
    Value<String>? nickname,
    Value<String?>? speciesText,
    Value<String>? notes,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? archivedAtUtc,
    Value<int>? rowid,
  }) {
    return ParentPlantsCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      speciesText: speciesText ?? this.speciesText,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (speciesText.present) {
      map['species_text'] = Variable<String>(speciesText.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (archivedAtUtc.present) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentPlantsCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('speciesText: $speciesText, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuttingsTable extends Cuttings
    with TableInfo<$CuttingsTable, CuttingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuttingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES parent_plants(id) ON DELETE RESTRICT',
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
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediumMeta = const VerificationMeta('medium');
  @override
  late final GeneratedColumn<String> medium = GeneratedColumn<String>(
    'medium',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtUtcMeta = const VerificationMeta(
    'archivedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAtUtc =
      GeneratedColumn<DateTime>(
        'archived_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    name,
    method,
    medium,
    location,
    startedAtUtc,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuttings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CuttingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('medium')) {
      context.handle(
        _mediumMeta,
        medium.isAcceptableOrUnknown(data['medium']!, _mediumMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('archived_at_utc')) {
      context.handle(
        _archivedAtUtcMeta,
        archivedAtUtc.isAcceptableOrUnknown(
          data['archived_at_utc']!,
          _archivedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CuttingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CuttingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      medium: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medium'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      archivedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at_utc'],
      ),
    );
  }

  @override
  $CuttingsTable createAlias(String alias) {
    return $CuttingsTable(attachedDatabase, alias);
  }
}

class CuttingRow extends DataClass implements Insertable<CuttingRow> {
  final String id;
  final String parentId;
  final String name;
  final String method;
  final String medium;
  final String location;
  final DateTime startedAtUtc;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? archivedAtUtc;
  const CuttingRow({
    required this.id,
    required this.parentId,
    required this.name,
    required this.method,
    required this.medium,
    required this.location,
    required this.startedAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.archivedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parent_id'] = Variable<String>(parentId);
    map['name'] = Variable<String>(name);
    map['method'] = Variable<String>(method);
    map['medium'] = Variable<String>(medium);
    map['location'] = Variable<String>(location);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || archivedAtUtc != null) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc);
    }
    return map;
  }

  CuttingsCompanion toCompanion(bool nullToAbsent) {
    return CuttingsCompanion(
      id: Value(id),
      parentId: Value(parentId),
      name: Value(name),
      method: Value(method),
      medium: Value(medium),
      location: Value(location),
      startedAtUtc: Value(startedAtUtc),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      archivedAtUtc: archivedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtc),
    );
  }

  factory CuttingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CuttingRow(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      method: serializer.fromJson<String>(json['method']),
      medium: serializer.fromJson<String>(json['medium']),
      location: serializer.fromJson<String>(json['location']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      archivedAtUtc: serializer.fromJson<DateTime?>(json['archivedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String>(parentId),
      'name': serializer.toJson<String>(name),
      'method': serializer.toJson<String>(method),
      'medium': serializer.toJson<String>(medium),
      'location': serializer.toJson<String>(location),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'archivedAtUtc': serializer.toJson<DateTime?>(archivedAtUtc),
    };
  }

  CuttingRow copyWith({
    String? id,
    String? parentId,
    String? name,
    String? method,
    String? medium,
    String? location,
    DateTime? startedAtUtc,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> archivedAtUtc = const Value.absent(),
  }) => CuttingRow(
    id: id ?? this.id,
    parentId: parentId ?? this.parentId,
    name: name ?? this.name,
    method: method ?? this.method,
    medium: medium ?? this.medium,
    location: location ?? this.location,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    archivedAtUtc: archivedAtUtc.present
        ? archivedAtUtc.value
        : this.archivedAtUtc,
  );
  CuttingRow copyWithCompanion(CuttingsCompanion data) {
    return CuttingRow(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      method: data.method.present ? data.method.value : this.method,
      medium: data.medium.present ? data.medium.value : this.medium,
      location: data.location.present ? data.location.value : this.location,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      archivedAtUtc: data.archivedAtUtc.present
          ? data.archivedAtUtc.value
          : this.archivedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CuttingRow(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('medium: $medium, ')
          ..write('location: $location, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    name,
    method,
    medium,
    location,
    startedAtUtc,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CuttingRow &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.method == this.method &&
          other.medium == this.medium &&
          other.location == this.location &&
          other.startedAtUtc == this.startedAtUtc &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.archivedAtUtc == this.archivedAtUtc);
}

class CuttingsCompanion extends UpdateCompanion<CuttingRow> {
  final Value<String> id;
  final Value<String> parentId;
  final Value<String> name;
  final Value<String> method;
  final Value<String> medium;
  final Value<String> location;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> archivedAtUtc;
  final Value<int> rowid;
  const CuttingsCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.method = const Value.absent(),
    this.medium = const Value.absent(),
    this.location = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuttingsCompanion.insert({
    required String id,
    required String parentId,
    required String name,
    required String method,
    this.medium = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime startedAtUtc,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       parentId = Value(parentId),
       name = Value(name),
       method = Value(method),
       startedAtUtc = Value(startedAtUtc),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CuttingRow> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? method,
    Expression<String>? medium,
    Expression<String>? location,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? archivedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (method != null) 'method': method,
      if (medium != null) 'medium': medium,
      if (location != null) 'location': location,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (archivedAtUtc != null) 'archived_at_utc': archivedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuttingsCompanion copyWith({
    Value<String>? id,
    Value<String>? parentId,
    Value<String>? name,
    Value<String>? method,
    Value<String>? medium,
    Value<String>? location,
    Value<DateTime>? startedAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? archivedAtUtc,
    Value<int>? rowid,
  }) {
    return CuttingsCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      method: method ?? this.method,
      medium: medium ?? this.medium,
      location: location ?? this.location,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (medium.present) {
      map['medium'] = Variable<String>(medium.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (archivedAtUtc.present) {
      map['archived_at_utc'] = Variable<DateTime>(archivedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuttingsCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('method: $method, ')
          ..write('medium: $medium, ')
          ..write('location: $location, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuttingTagsTable extends CuttingTags
    with TableInfo<$CuttingTagsTable, CuttingTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuttingTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cuttingIdMeta = const VerificationMeta(
    'cuttingId',
  );
  @override
  late final GeneratedColumn<String> cuttingId = GeneratedColumn<String>(
    'cutting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cuttingId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cutting_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CuttingTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cutting_id')) {
      context.handle(
        _cuttingIdMeta,
        cuttingId.isAcceptableOrUnknown(data['cutting_id']!, _cuttingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuttingIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cuttingId, tag};
  @override
  CuttingTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CuttingTagRow(
      cuttingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cutting_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $CuttingTagsTable createAlias(String alias) {
    return $CuttingTagsTable(attachedDatabase, alias);
  }
}

class CuttingTagRow extends DataClass implements Insertable<CuttingTagRow> {
  final String cuttingId;
  final String tag;
  const CuttingTagRow({required this.cuttingId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cutting_id'] = Variable<String>(cuttingId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  CuttingTagsCompanion toCompanion(bool nullToAbsent) {
    return CuttingTagsCompanion(cuttingId: Value(cuttingId), tag: Value(tag));
  }

  factory CuttingTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CuttingTagRow(
      cuttingId: serializer.fromJson<String>(json['cuttingId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cuttingId': serializer.toJson<String>(cuttingId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  CuttingTagRow copyWith({String? cuttingId, String? tag}) => CuttingTagRow(
    cuttingId: cuttingId ?? this.cuttingId,
    tag: tag ?? this.tag,
  );
  CuttingTagRow copyWithCompanion(CuttingTagsCompanion data) {
    return CuttingTagRow(
      cuttingId: data.cuttingId.present ? data.cuttingId.value : this.cuttingId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CuttingTagRow(')
          ..write('cuttingId: $cuttingId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cuttingId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CuttingTagRow &&
          other.cuttingId == this.cuttingId &&
          other.tag == this.tag);
}

class CuttingTagsCompanion extends UpdateCompanion<CuttingTagRow> {
  final Value<String> cuttingId;
  final Value<String> tag;
  final Value<int> rowid;
  const CuttingTagsCompanion({
    this.cuttingId = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuttingTagsCompanion.insert({
    required String cuttingId,
    required String tag,
    this.rowid = const Value.absent(),
  }) : cuttingId = Value(cuttingId),
       tag = Value(tag);
  static Insertable<CuttingTagRow> custom({
    Expression<String>? cuttingId,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cuttingId != null) 'cutting_id': cuttingId,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuttingTagsCompanion copyWith({
    Value<String>? cuttingId,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return CuttingTagsCompanion(
      cuttingId: cuttingId ?? this.cuttingId,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cuttingId.present) {
      map['cutting_id'] = Variable<String>(cuttingId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuttingTagsCompanion(')
          ..write('cuttingId: $cuttingId, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuttingEventsTable extends CuttingEvents
    with TableInfo<$CuttingEventsTable, CuttingEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuttingEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuttingIdMeta = const VerificationMeta(
    'cuttingId',
  );
  @override
  late final GeneratedColumn<String> cuttingId = GeneratedColumn<String>(
    'cutting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctsEventIdMeta = const VerificationMeta(
    'correctsEventId',
  );
  @override
  late final GeneratedColumn<String> correctsEventId = GeneratedColumn<String>(
    'corrects_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES cutting_events(id) ON DELETE RESTRICT',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuttingId,
    occurredAtUtc,
    createdAtUtc,
    kind,
    note,
    stage,
    outcome,
    correctsEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cutting_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CuttingEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cutting_id')) {
      context.handle(
        _cuttingIdMeta,
        cuttingId.isAcceptableOrUnknown(data['cutting_id']!, _cuttingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuttingIdMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('corrects_event_id')) {
      context.handle(
        _correctsEventIdMeta,
        correctsEventId.isAcceptableOrUnknown(
          data['corrects_event_id']!,
          _correctsEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CuttingEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CuttingEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cuttingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cutting_id'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      correctsEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrects_event_id'],
      ),
    );
  }

  @override
  $CuttingEventsTable createAlias(String alias) {
    return $CuttingEventsTable(attachedDatabase, alias);
  }
}

class CuttingEventRow extends DataClass implements Insertable<CuttingEventRow> {
  final String id;
  final String cuttingId;
  final DateTime occurredAtUtc;
  final DateTime createdAtUtc;
  final String kind;
  final String note;
  final String? stage;
  final String? outcome;
  final String? correctsEventId;
  const CuttingEventRow({
    required this.id,
    required this.cuttingId,
    required this.occurredAtUtc,
    required this.createdAtUtc,
    required this.kind,
    required this.note,
    this.stage,
    this.outcome,
    this.correctsEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cutting_id'] = Variable<String>(cuttingId);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['kind'] = Variable<String>(kind);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || stage != null) {
      map['stage'] = Variable<String>(stage);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || correctsEventId != null) {
      map['corrects_event_id'] = Variable<String>(correctsEventId);
    }
    return map;
  }

  CuttingEventsCompanion toCompanion(bool nullToAbsent) {
    return CuttingEventsCompanion(
      id: Value(id),
      cuttingId: Value(cuttingId),
      occurredAtUtc: Value(occurredAtUtc),
      createdAtUtc: Value(createdAtUtc),
      kind: Value(kind),
      note: Value(note),
      stage: stage == null && nullToAbsent
          ? const Value.absent()
          : Value(stage),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      correctsEventId: correctsEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctsEventId),
    );
  }

  factory CuttingEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CuttingEventRow(
      id: serializer.fromJson<String>(json['id']),
      cuttingId: serializer.fromJson<String>(json['cuttingId']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      kind: serializer.fromJson<String>(json['kind']),
      note: serializer.fromJson<String>(json['note']),
      stage: serializer.fromJson<String?>(json['stage']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      correctsEventId: serializer.fromJson<String?>(json['correctsEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cuttingId': serializer.toJson<String>(cuttingId),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'kind': serializer.toJson<String>(kind),
      'note': serializer.toJson<String>(note),
      'stage': serializer.toJson<String?>(stage),
      'outcome': serializer.toJson<String?>(outcome),
      'correctsEventId': serializer.toJson<String?>(correctsEventId),
    };
  }

  CuttingEventRow copyWith({
    String? id,
    String? cuttingId,
    DateTime? occurredAtUtc,
    DateTime? createdAtUtc,
    String? kind,
    String? note,
    Value<String?> stage = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    Value<String?> correctsEventId = const Value.absent(),
  }) => CuttingEventRow(
    id: id ?? this.id,
    cuttingId: cuttingId ?? this.cuttingId,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    kind: kind ?? this.kind,
    note: note ?? this.note,
    stage: stage.present ? stage.value : this.stage,
    outcome: outcome.present ? outcome.value : this.outcome,
    correctsEventId: correctsEventId.present
        ? correctsEventId.value
        : this.correctsEventId,
  );
  CuttingEventRow copyWithCompanion(CuttingEventsCompanion data) {
    return CuttingEventRow(
      id: data.id.present ? data.id.value : this.id,
      cuttingId: data.cuttingId.present ? data.cuttingId.value : this.cuttingId,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      kind: data.kind.present ? data.kind.value : this.kind,
      note: data.note.present ? data.note.value : this.note,
      stage: data.stage.present ? data.stage.value : this.stage,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      correctsEventId: data.correctsEventId.present
          ? data.correctsEventId.value
          : this.correctsEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CuttingEventRow(')
          ..write('id: $id, ')
          ..write('cuttingId: $cuttingId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('kind: $kind, ')
          ..write('note: $note, ')
          ..write('stage: $stage, ')
          ..write('outcome: $outcome, ')
          ..write('correctsEventId: $correctsEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cuttingId,
    occurredAtUtc,
    createdAtUtc,
    kind,
    note,
    stage,
    outcome,
    correctsEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CuttingEventRow &&
          other.id == this.id &&
          other.cuttingId == this.cuttingId &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.createdAtUtc == this.createdAtUtc &&
          other.kind == this.kind &&
          other.note == this.note &&
          other.stage == this.stage &&
          other.outcome == this.outcome &&
          other.correctsEventId == this.correctsEventId);
}

class CuttingEventsCompanion extends UpdateCompanion<CuttingEventRow> {
  final Value<String> id;
  final Value<String> cuttingId;
  final Value<DateTime> occurredAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<String> kind;
  final Value<String> note;
  final Value<String?> stage;
  final Value<String?> outcome;
  final Value<String?> correctsEventId;
  final Value<int> rowid;
  const CuttingEventsCompanion({
    this.id = const Value.absent(),
    this.cuttingId = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.kind = const Value.absent(),
    this.note = const Value.absent(),
    this.stage = const Value.absent(),
    this.outcome = const Value.absent(),
    this.correctsEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuttingEventsCompanion.insert({
    required String id,
    required String cuttingId,
    required DateTime occurredAtUtc,
    required DateTime createdAtUtc,
    required String kind,
    this.note = const Value.absent(),
    this.stage = const Value.absent(),
    this.outcome = const Value.absent(),
    this.correctsEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cuttingId = Value(cuttingId),
       occurredAtUtc = Value(occurredAtUtc),
       createdAtUtc = Value(createdAtUtc),
       kind = Value(kind);
  static Insertable<CuttingEventRow> custom({
    Expression<String>? id,
    Expression<String>? cuttingId,
    Expression<DateTime>? occurredAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? kind,
    Expression<String>? note,
    Expression<String>? stage,
    Expression<String>? outcome,
    Expression<String>? correctsEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuttingId != null) 'cutting_id': cuttingId,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (kind != null) 'kind': kind,
      if (note != null) 'note': note,
      if (stage != null) 'stage': stage,
      if (outcome != null) 'outcome': outcome,
      if (correctsEventId != null) 'corrects_event_id': correctsEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuttingEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? cuttingId,
    Value<DateTime>? occurredAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<String>? kind,
    Value<String>? note,
    Value<String?>? stage,
    Value<String?>? outcome,
    Value<String?>? correctsEventId,
    Value<int>? rowid,
  }) {
    return CuttingEventsCompanion(
      id: id ?? this.id,
      cuttingId: cuttingId ?? this.cuttingId,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      kind: kind ?? this.kind,
      note: note ?? this.note,
      stage: stage ?? this.stage,
      outcome: outcome ?? this.outcome,
      correctsEventId: correctsEventId ?? this.correctsEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cuttingId.present) {
      map['cutting_id'] = Variable<String>(cuttingId.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (correctsEventId.present) {
      map['corrects_event_id'] = Variable<String>(correctsEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuttingEventsCompanion(')
          ..write('id: $id, ')
          ..write('cuttingId: $cuttingId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('kind: $kind, ')
          ..write('note: $note, ')
          ..write('stage: $stage, ')
          ..write('outcome: $outcome, ')
          ..write('correctsEventId: $correctsEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES cutting_events(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _capturedAtUtcMeta = const VerificationMeta(
    'capturedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAtUtc =
      GeneratedColumn<DateTime>(
        'captured_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _importedAtUtcMeta = const VerificationMeta(
    'importedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> importedAtUtc =
      GeneratedColumn<DateTime>(
        'imported_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    relativePath,
    sha256,
    mediaType,
    caption,
    capturedAtUtc,
    importedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('captured_at_utc')) {
      context.handle(
        _capturedAtUtcMeta,
        capturedAtUtc.isAcceptableOrUnknown(
          data['captured_at_utc']!,
          _capturedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('imported_at_utc')) {
      context.handle(
        _importedAtUtcMeta,
        importedAtUtc.isAcceptableOrUnknown(
          data['imported_at_utc']!,
          _importedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_importedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      )!,
      capturedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at_utc'],
      ),
      importedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at_utc'],
      )!,
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }
}

class MediaAssetRow extends DataClass implements Insertable<MediaAssetRow> {
  final String id;
  final String eventId;
  final String relativePath;
  final String sha256;
  final String mediaType;
  final String caption;
  final DateTime? capturedAtUtc;
  final DateTime importedAtUtc;
  const MediaAssetRow({
    required this.id,
    required this.eventId,
    required this.relativePath,
    required this.sha256,
    required this.mediaType,
    required this.caption,
    this.capturedAtUtc,
    required this.importedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['relative_path'] = Variable<String>(relativePath);
    map['sha256'] = Variable<String>(sha256);
    map['media_type'] = Variable<String>(mediaType);
    map['caption'] = Variable<String>(caption);
    if (!nullToAbsent || capturedAtUtc != null) {
      map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc);
    }
    map['imported_at_utc'] = Variable<DateTime>(importedAtUtc);
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      relativePath: Value(relativePath),
      sha256: Value(sha256),
      mediaType: Value(mediaType),
      caption: Value(caption),
      capturedAtUtc: capturedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAtUtc),
      importedAtUtc: Value(importedAtUtc),
    );
  }

  factory MediaAssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAssetRow(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      caption: serializer.fromJson<String>(json['caption']),
      capturedAtUtc: serializer.fromJson<DateTime?>(json['capturedAtUtc']),
      importedAtUtc: serializer.fromJson<DateTime>(json['importedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'relativePath': serializer.toJson<String>(relativePath),
      'sha256': serializer.toJson<String>(sha256),
      'mediaType': serializer.toJson<String>(mediaType),
      'caption': serializer.toJson<String>(caption),
      'capturedAtUtc': serializer.toJson<DateTime?>(capturedAtUtc),
      'importedAtUtc': serializer.toJson<DateTime>(importedAtUtc),
    };
  }

  MediaAssetRow copyWith({
    String? id,
    String? eventId,
    String? relativePath,
    String? sha256,
    String? mediaType,
    String? caption,
    Value<DateTime?> capturedAtUtc = const Value.absent(),
    DateTime? importedAtUtc,
  }) => MediaAssetRow(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    relativePath: relativePath ?? this.relativePath,
    sha256: sha256 ?? this.sha256,
    mediaType: mediaType ?? this.mediaType,
    caption: caption ?? this.caption,
    capturedAtUtc: capturedAtUtc.present
        ? capturedAtUtc.value
        : this.capturedAtUtc,
    importedAtUtc: importedAtUtc ?? this.importedAtUtc,
  );
  MediaAssetRow copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAssetRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      caption: data.caption.present ? data.caption.value : this.caption,
      capturedAtUtc: data.capturedAtUtc.present
          ? data.capturedAtUtc.value
          : this.capturedAtUtc,
      importedAtUtc: data.importedAtUtc.present
          ? data.importedAtUtc.value
          : this.importedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('mediaType: $mediaType, ')
          ..write('caption: $caption, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('importedAtUtc: $importedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    relativePath,
    sha256,
    mediaType,
    caption,
    capturedAtUtc,
    importedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAssetRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.relativePath == this.relativePath &&
          other.sha256 == this.sha256 &&
          other.mediaType == this.mediaType &&
          other.caption == this.caption &&
          other.capturedAtUtc == this.capturedAtUtc &&
          other.importedAtUtc == this.importedAtUtc);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAssetRow> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> relativePath;
  final Value<String> sha256;
  final Value<String> mediaType;
  final Value<String> caption;
  final Value<DateTime?> capturedAtUtc;
  final Value<DateTime> importedAtUtc;
  final Value<int> rowid;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.caption = const Value.absent(),
    this.capturedAtUtc = const Value.absent(),
    this.importedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    required String id,
    required String eventId,
    required String relativePath,
    required String sha256,
    required String mediaType,
    this.caption = const Value.absent(),
    this.capturedAtUtc = const Value.absent(),
    required DateTime importedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       relativePath = Value(relativePath),
       sha256 = Value(sha256),
       mediaType = Value(mediaType),
       importedAtUtc = Value(importedAtUtc);
  static Insertable<MediaAssetRow> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? relativePath,
    Expression<String>? sha256,
    Expression<String>? mediaType,
    Expression<String>? caption,
    Expression<DateTime>? capturedAtUtc,
    Expression<DateTime>? importedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (relativePath != null) 'relative_path': relativePath,
      if (sha256 != null) 'sha256': sha256,
      if (mediaType != null) 'media_type': mediaType,
      if (caption != null) 'caption': caption,
      if (capturedAtUtc != null) 'captured_at_utc': capturedAtUtc,
      if (importedAtUtc != null) 'imported_at_utc': importedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? relativePath,
    Value<String>? sha256,
    Value<String>? mediaType,
    Value<String>? caption,
    Value<DateTime?>? capturedAtUtc,
    Value<DateTime>? importedAtUtc,
    Value<int>? rowid,
  }) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      relativePath: relativePath ?? this.relativePath,
      sha256: sha256 ?? this.sha256,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
      importedAtUtc: importedAtUtc ?? this.importedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (capturedAtUtc.present) {
      map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc.value);
    }
    if (importedAtUtc.present) {
      map['imported_at_utc'] = Variable<DateTime>(importedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('mediaType: $mediaType, ')
          ..write('caption: $caption, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('importedAtUtc: $importedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuttingIdMeta = const VerificationMeta(
    'cuttingId',
  );
  @override
  late final GeneratedColumn<String> cuttingId = GeneratedColumn<String>(
    'cutting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _scheduledForUtcMeta = const VerificationMeta(
    'scheduledForUtc',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledForUtc =
      GeneratedColumn<DateTime>(
        'scheduled_for_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformNotificationIdMeta =
      const VerificationMeta('platformNotificationId');
  @override
  late final GeneratedColumn<String> platformNotificationId =
      GeneratedColumn<String>(
        'platform_notification_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _snoozedFromUtcMeta = const VerificationMeta(
    'snoozedFromUtc',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedFromUtc =
      GeneratedColumn<DateTime>(
        'snoozed_from_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuttingId,
    scheduledForUtc,
    timeZoneId,
    status,
    platformNotificationId,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    snoozedFromUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cutting_id')) {
      context.handle(
        _cuttingIdMeta,
        cuttingId.isAcceptableOrUnknown(data['cutting_id']!, _cuttingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuttingIdMeta);
    }
    if (data.containsKey('scheduled_for_utc')) {
      context.handle(
        _scheduledForUtcMeta,
        scheduledForUtc.isAcceptableOrUnknown(
          data['scheduled_for_utc']!,
          _scheduledForUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForUtcMeta);
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
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
    if (data.containsKey('platform_notification_id')) {
      context.handle(
        _platformNotificationIdMeta,
        platformNotificationId.isAcceptableOrUnknown(
          data['platform_notification_id']!,
          _platformNotificationIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_from_utc')) {
      context.handle(
        _snoozedFromUtcMeta,
        snoozedFromUtc.isAcceptableOrUnknown(
          data['snoozed_from_utc']!,
          _snoozedFromUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cuttingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cutting_id'],
      )!,
      scheduledForUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for_utc'],
      )!,
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      platformNotificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_notification_id'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      snoozedFromUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_from_utc'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String cuttingId;
  final DateTime scheduledForUtc;
  final String timeZoneId;
  final String status;
  final String? platformNotificationId;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? completedAtUtc;
  final DateTime? snoozedFromUtc;
  const ReminderRow({
    required this.id,
    required this.cuttingId,
    required this.scheduledForUtc,
    required this.timeZoneId,
    required this.status,
    this.platformNotificationId,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.completedAtUtc,
    this.snoozedFromUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cutting_id'] = Variable<String>(cuttingId);
    map['scheduled_for_utc'] = Variable<DateTime>(scheduledForUtc);
    map['time_zone_id'] = Variable<String>(timeZoneId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || platformNotificationId != null) {
      map['platform_notification_id'] = Variable<String>(
        platformNotificationId,
      );
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    if (!nullToAbsent || snoozedFromUtc != null) {
      map['snoozed_from_utc'] = Variable<DateTime>(snoozedFromUtc);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      cuttingId: Value(cuttingId),
      scheduledForUtc: Value(scheduledForUtc),
      timeZoneId: Value(timeZoneId),
      status: Value(status),
      platformNotificationId: platformNotificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(platformNotificationId),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      snoozedFromUtc: snoozedFromUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedFromUtc),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      cuttingId: serializer.fromJson<String>(json['cuttingId']),
      scheduledForUtc: serializer.fromJson<DateTime>(json['scheduledForUtc']),
      timeZoneId: serializer.fromJson<String>(json['timeZoneId']),
      status: serializer.fromJson<String>(json['status']),
      platformNotificationId: serializer.fromJson<String?>(
        json['platformNotificationId'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      snoozedFromUtc: serializer.fromJson<DateTime?>(json['snoozedFromUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cuttingId': serializer.toJson<String>(cuttingId),
      'scheduledForUtc': serializer.toJson<DateTime>(scheduledForUtc),
      'timeZoneId': serializer.toJson<String>(timeZoneId),
      'status': serializer.toJson<String>(status),
      'platformNotificationId': serializer.toJson<String?>(
        platformNotificationId,
      ),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'snoozedFromUtc': serializer.toJson<DateTime?>(snoozedFromUtc),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? cuttingId,
    DateTime? scheduledForUtc,
    String? timeZoneId,
    String? status,
    Value<String?> platformNotificationId = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    Value<DateTime?> snoozedFromUtc = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    cuttingId: cuttingId ?? this.cuttingId,
    scheduledForUtc: scheduledForUtc ?? this.scheduledForUtc,
    timeZoneId: timeZoneId ?? this.timeZoneId,
    status: status ?? this.status,
    platformNotificationId: platformNotificationId.present
        ? platformNotificationId.value
        : this.platformNotificationId,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    snoozedFromUtc: snoozedFromUtc.present
        ? snoozedFromUtc.value
        : this.snoozedFromUtc,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      cuttingId: data.cuttingId.present ? data.cuttingId.value : this.cuttingId,
      scheduledForUtc: data.scheduledForUtc.present
          ? data.scheduledForUtc.value
          : this.scheduledForUtc,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      status: data.status.present ? data.status.value : this.status,
      platformNotificationId: data.platformNotificationId.present
          ? data.platformNotificationId.value
          : this.platformNotificationId,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      snoozedFromUtc: data.snoozedFromUtc.present
          ? data.snoozedFromUtc.value
          : this.snoozedFromUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('cuttingId: $cuttingId, ')
          ..write('scheduledForUtc: $scheduledForUtc, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('status: $status, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('snoozedFromUtc: $snoozedFromUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cuttingId,
    scheduledForUtc,
    timeZoneId,
    status,
    platformNotificationId,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    snoozedFromUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.cuttingId == this.cuttingId &&
          other.scheduledForUtc == this.scheduledForUtc &&
          other.timeZoneId == this.timeZoneId &&
          other.status == this.status &&
          other.platformNotificationId == this.platformNotificationId &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.completedAtUtc == this.completedAtUtc &&
          other.snoozedFromUtc == this.snoozedFromUtc);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> cuttingId;
  final Value<DateTime> scheduledForUtc;
  final Value<String> timeZoneId;
  final Value<String> status;
  final Value<String?> platformNotificationId;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> completedAtUtc;
  final Value<DateTime?> snoozedFromUtc;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.cuttingId = const Value.absent(),
    this.scheduledForUtc = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.status = const Value.absent(),
    this.platformNotificationId = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.snoozedFromUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String cuttingId,
    required DateTime scheduledForUtc,
    this.timeZoneId = const Value.absent(),
    required String status,
    this.platformNotificationId = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.completedAtUtc = const Value.absent(),
    this.snoozedFromUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cuttingId = Value(cuttingId),
       scheduledForUtc = Value(scheduledForUtc),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? cuttingId,
    Expression<DateTime>? scheduledForUtc,
    Expression<String>? timeZoneId,
    Expression<String>? status,
    Expression<String>? platformNotificationId,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? completedAtUtc,
    Expression<DateTime>? snoozedFromUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuttingId != null) 'cutting_id': cuttingId,
      if (scheduledForUtc != null) 'scheduled_for_utc': scheduledForUtc,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (status != null) 'status': status,
      if (platformNotificationId != null)
        'platform_notification_id': platformNotificationId,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (snoozedFromUtc != null) 'snoozed_from_utc': snoozedFromUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? cuttingId,
    Value<DateTime>? scheduledForUtc,
    Value<String>? timeZoneId,
    Value<String>? status,
    Value<String?>? platformNotificationId,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? completedAtUtc,
    Value<DateTime?>? snoozedFromUtc,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      cuttingId: cuttingId ?? this.cuttingId,
      scheduledForUtc: scheduledForUtc ?? this.scheduledForUtc,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      status: status ?? this.status,
      platformNotificationId:
          platformNotificationId ?? this.platformNotificationId,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      snoozedFromUtc: snoozedFromUtc ?? this.snoozedFromUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cuttingId.present) {
      map['cutting_id'] = Variable<String>(cuttingId.value);
    }
    if (scheduledForUtc.present) {
      map['scheduled_for_utc'] = Variable<DateTime>(scheduledForUtc.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (platformNotificationId.present) {
      map['platform_notification_id'] = Variable<String>(
        platformNotificationId.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (snoozedFromUtc.present) {
      map['snoozed_from_utc'] = Variable<DateTime>(snoozedFromUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('cuttingId: $cuttingId, ')
          ..write('scheduledForUtc: $scheduledForUtc, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('status: $status, ')
          ..write('platformNotificationId: $platformNotificationId, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('snoozedFromUtc: $snoozedFromUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ParentPlantsTable parentPlants = $ParentPlantsTable(this);
  late final $CuttingsTable cuttings = $CuttingsTable(this);
  late final $CuttingTagsTable cuttingTags = $CuttingTagsTable(this);
  late final $CuttingEventsTable cuttingEvents = $CuttingEventsTable(this);
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    parentPlants,
    cuttings,
    cuttingTags,
    cuttingEvents,
    mediaAssets,
    reminders,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuttings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cutting_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuttings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cutting_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cutting_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_assets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cuttings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ParentPlantsTableCreateCompanionBuilder =
    ParentPlantsCompanion Function({
      required String id,
      required String nickname,
      Value<String?> speciesText,
      Value<String> notes,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> archivedAtUtc,
      Value<int> rowid,
    });
typedef $$ParentPlantsTableUpdateCompanionBuilder =
    ParentPlantsCompanion Function({
      Value<String> id,
      Value<String> nickname,
      Value<String?> speciesText,
      Value<String> notes,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> archivedAtUtc,
      Value<int> rowid,
    });

final class $$ParentPlantsTableReferences
    extends BaseReferences<_$AppDatabase, $ParentPlantsTable, ParentPlantRow> {
  $$ParentPlantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CuttingsTable, List<CuttingRow>>
  _cuttingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cuttings,
    aliasName: 'parent_plants__id__cuttings__parent_id',
  );

  $$CuttingsTableProcessedTableManager get cuttingsRefs {
    final manager = $$CuttingsTableTableManager(
      $_db,
      $_db.cuttings,
    ).filter((f) => f.parentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cuttingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParentPlantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParentPlantsTable> {
  $$ParentPlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesText => $composableBuilder(
    column: $table.speciesText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cuttingsRefs(
    Expression<bool> Function($$CuttingsTableFilterComposer f) f,
  ) {
    final $$CuttingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableFilterComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParentPlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentPlantsTable> {
  $$ParentPlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesText => $composableBuilder(
    column: $table.speciesText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParentPlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentPlantsTable> {
  $$ParentPlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get speciesText => $composableBuilder(
    column: $table.speciesText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => column,
  );

  Expression<T> cuttingsRefs<T extends Object>(
    Expression<T> Function($$CuttingsTableAnnotationComposer a) f,
  ) {
    final $$CuttingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParentPlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentPlantsTable,
          ParentPlantRow,
          $$ParentPlantsTableFilterComposer,
          $$ParentPlantsTableOrderingComposer,
          $$ParentPlantsTableAnnotationComposer,
          $$ParentPlantsTableCreateCompanionBuilder,
          $$ParentPlantsTableUpdateCompanionBuilder,
          (ParentPlantRow, $$ParentPlantsTableReferences),
          ParentPlantRow,
          PrefetchHooks Function({bool cuttingsRefs})
        > {
  $$ParentPlantsTableTableManager(_$AppDatabase db, $ParentPlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentPlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentPlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentPlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> speciesText = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> archivedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParentPlantsCompanion(
                id: id,
                nickname: nickname,
                speciesText: speciesText,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                archivedAtUtc: archivedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nickname,
                Value<String?> speciesText = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> archivedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParentPlantsCompanion.insert(
                id: id,
                nickname: nickname,
                speciesText: speciesText,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                archivedAtUtc: archivedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParentPlantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cuttingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cuttingsRefs) db.cuttings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cuttingsRefs)
                    await $_getPrefetchedData<
                      ParentPlantRow,
                      $ParentPlantsTable,
                      CuttingRow
                    >(
                      currentTable: table,
                      referencedTable: $$ParentPlantsTableReferences
                          ._cuttingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ParentPlantsTableReferences(
                            db,
                            table,
                            p0,
                          ).cuttingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.parentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ParentPlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentPlantsTable,
      ParentPlantRow,
      $$ParentPlantsTableFilterComposer,
      $$ParentPlantsTableOrderingComposer,
      $$ParentPlantsTableAnnotationComposer,
      $$ParentPlantsTableCreateCompanionBuilder,
      $$ParentPlantsTableUpdateCompanionBuilder,
      (ParentPlantRow, $$ParentPlantsTableReferences),
      ParentPlantRow,
      PrefetchHooks Function({bool cuttingsRefs})
    >;
typedef $$CuttingsTableCreateCompanionBuilder = CuttingsCompanion Function({
  required String id,
  required String parentId,
  required String name,
  required String method,
  Value<String> medium,
  Value<String> location,
  required DateTime startedAtUtc,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<DateTime?> archivedAtUtc,
  Value<int> rowid,
});
typedef $$CuttingsTableUpdateCompanionBuilder = CuttingsCompanion Function({
  Value<String> id,
  Value<String> parentId,
  Value<String> name,
  Value<String> method,
  Value<String> medium,
  Value<String> location,
  Value<DateTime> startedAtUtc,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<DateTime?> archivedAtUtc,
  Value<int> rowid,
});

final class $$CuttingsTableReferences
    extends BaseReferences<_$AppDatabase, $CuttingsTable, CuttingRow> {
  $$CuttingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParentPlantsTable _parentIdTable(_$AppDatabase db) =>
      db.parentPlants.createAlias('cuttings__parent_id__parent_plants__id');

  $$ParentPlantsTableProcessedTableManager get parentId {
    final $_column = $_itemColumn<String>('parent_id')!;

    final manager = $$ParentPlantsTableTableManager(
      $_db,
      $_db.parentPlants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CuttingTagsTable, List<CuttingTagRow>>
  _cuttingTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cuttingTags,
    aliasName: 'cuttings__id__cutting_tags__cutting_id',
  );

  $$CuttingTagsTableProcessedTableManager get cuttingTagsRefs {
    final manager = $$CuttingTagsTableTableManager(
      $_db,
      $_db.cuttingTags,
    ).filter((f) => f.cuttingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cuttingTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CuttingEventsTable, List<CuttingEventRow>>
  _cuttingEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cuttingEvents,
    aliasName: 'cuttings__id__cutting_events__cutting_id',
  );

  $$CuttingEventsTableProcessedTableManager get cuttingEventsRefs {
    final manager = $$CuttingEventsTableTableManager(
      $_db,
      $_db.cuttingEvents,
    ).filter((f) => f.cuttingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cuttingEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'cuttings__id__reminders__cutting_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.cuttingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CuttingsTableFilterComposer
    extends Composer<_$AppDatabase, $CuttingsTable> {
  $$CuttingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$ParentPlantsTableFilterComposer get parentId {
    final $$ParentPlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.parentPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentPlantsTableFilterComposer(
            $db: $db,
            $table: $db.parentPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cuttingTagsRefs(
    Expression<bool> Function($$CuttingTagsTableFilterComposer f) f,
  ) {
    final $$CuttingTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttingTags,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingTagsTableFilterComposer(
            $db: $db,
            $table: $db.cuttingTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cuttingEventsRefs(
    Expression<bool> Function($$CuttingEventsTableFilterComposer f) f,
  ) {
    final $$CuttingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableFilterComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuttingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CuttingsTable> {
  $$CuttingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medium => $composableBuilder(
    column: $table.medium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ParentPlantsTableOrderingComposer get parentId {
    final $$ParentPlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.parentPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentPlantsTableOrderingComposer(
            $db: $db,
            $table: $db.parentPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuttingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuttingsTable> {
  $$CuttingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get medium =>
      $composableBuilder(column: $table.medium, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAtUtc => $composableBuilder(
    column: $table.archivedAtUtc,
    builder: (column) => column,
  );

  $$ParentPlantsTableAnnotationComposer get parentId {
    final $$ParentPlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.parentPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParentPlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.parentPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cuttingTagsRefs<T extends Object>(
    Expression<T> Function($$CuttingTagsTableAnnotationComposer a) f,
  ) {
    final $$CuttingTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttingTags,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttingTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cuttingEventsRefs<T extends Object>(
    Expression<T> Function($$CuttingEventsTableAnnotationComposer a) f,
  ) {
    final $$CuttingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.cuttingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuttingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuttingsTable,
          CuttingRow,
          $$CuttingsTableFilterComposer,
          $$CuttingsTableOrderingComposer,
          $$CuttingsTableAnnotationComposer,
          $$CuttingsTableCreateCompanionBuilder,
          $$CuttingsTableUpdateCompanionBuilder,
          (CuttingRow, $$CuttingsTableReferences),
          CuttingRow,
          PrefetchHooks Function({
            bool parentId,
            bool cuttingTagsRefs,
            bool cuttingEventsRefs,
            bool remindersRefs,
          })
        > {
  $$CuttingsTableTableManager(_$AppDatabase db, $CuttingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuttingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuttingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuttingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> medium = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> archivedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuttingsCompanion(
                id: id,
                parentId: parentId,
                name: name,
                method: method,
                medium: medium,
                location: location,
                startedAtUtc: startedAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                archivedAtUtc: archivedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String parentId,
                required String name,
                required String method,
                Value<String> medium = const Value.absent(),
                Value<String> location = const Value.absent(),
                required DateTime startedAtUtc,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> archivedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuttingsCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                method: method,
                medium: medium,
                location: location,
                startedAtUtc: startedAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                archivedAtUtc: archivedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CuttingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                cuttingTagsRefs = false,
                cuttingEventsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cuttingTagsRefs) db.cuttingTags,
                    if (cuttingEventsRefs) db.cuttingEvents,
                    if (remindersRefs) db.reminders,
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
                        if (parentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $$CuttingsTableReferences
                                ._parentIdTable(db),
                            referencedColumn: $$CuttingsTableReferences
                                ._parentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cuttingTagsRefs)
                        await $_getPrefetchedData<
                          CuttingRow,
                          $CuttingsTable,
                          CuttingTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$CuttingsTableReferences
                              ._cuttingTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuttingsTableReferences(
                                db,
                                table,
                                p0,
                              ).cuttingTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuttingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cuttingEventsRefs)
                        await $_getPrefetchedData<
                          CuttingRow,
                          $CuttingsTable,
                          CuttingEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$CuttingsTableReferences
                              ._cuttingEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuttingsTableReferences(
                                db,
                                table,
                                p0,
                              ).cuttingEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuttingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          CuttingRow,
                          $CuttingsTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$CuttingsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuttingsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cuttingId == item.id,
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

typedef $$CuttingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuttingsTable,
      CuttingRow,
      $$CuttingsTableFilterComposer,
      $$CuttingsTableOrderingComposer,
      $$CuttingsTableAnnotationComposer,
      $$CuttingsTableCreateCompanionBuilder,
      $$CuttingsTableUpdateCompanionBuilder,
      (CuttingRow, $$CuttingsTableReferences),
      CuttingRow,
      PrefetchHooks Function({
        bool parentId,
        bool cuttingTagsRefs,
        bool cuttingEventsRefs,
        bool remindersRefs,
      })
    >;
typedef $$CuttingTagsTableCreateCompanionBuilder =
    CuttingTagsCompanion Function({
      required String cuttingId,
      required String tag,
      Value<int> rowid,
    });
typedef $$CuttingTagsTableUpdateCompanionBuilder =
    CuttingTagsCompanion Function({
      Value<String> cuttingId,
      Value<String> tag,
      Value<int> rowid,
    });

final class $$CuttingTagsTableReferences
    extends BaseReferences<_$AppDatabase, $CuttingTagsTable, CuttingTagRow> {
  $$CuttingTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuttingsTable _cuttingIdTable(_$AppDatabase db) =>
      db.cuttings.createAlias('cutting_tags__cutting_id__cuttings__id');

  $$CuttingsTableProcessedTableManager get cuttingId {
    final $_column = $_itemColumn<String>('cutting_id')!;

    final manager = $$CuttingsTableTableManager(
      $_db,
      $_db.cuttings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuttingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CuttingTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CuttingTagsTable> {
  $$CuttingTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  $$CuttingsTableFilterComposer get cuttingId {
    final $$CuttingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableFilterComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuttingTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CuttingTagsTable> {
  $$CuttingTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuttingsTableOrderingComposer get cuttingId {
    final $$CuttingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableOrderingComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuttingTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuttingTagsTable> {
  $$CuttingTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  $$CuttingsTableAnnotationComposer get cuttingId {
    final $$CuttingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuttingTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuttingTagsTable,
          CuttingTagRow,
          $$CuttingTagsTableFilterComposer,
          $$CuttingTagsTableOrderingComposer,
          $$CuttingTagsTableAnnotationComposer,
          $$CuttingTagsTableCreateCompanionBuilder,
          $$CuttingTagsTableUpdateCompanionBuilder,
          (CuttingTagRow, $$CuttingTagsTableReferences),
          CuttingTagRow,
          PrefetchHooks Function({bool cuttingId})
        > {
  $$CuttingTagsTableTableManager(_$AppDatabase db, $CuttingTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuttingTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuttingTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuttingTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cuttingId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuttingTagsCompanion(
                cuttingId: cuttingId,
                tag: tag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cuttingId,
                required String tag,
                Value<int> rowid = const Value.absent(),
              }) => CuttingTagsCompanion.insert(
                cuttingId: cuttingId,
                tag: tag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CuttingTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cuttingId = false}) {
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
                    if (cuttingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cuttingId,
                        referencedTable: $$CuttingTagsTableReferences
                            ._cuttingIdTable(db),
                        referencedColumn: $$CuttingTagsTableReferences
                            ._cuttingIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CuttingTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuttingTagsTable,
      CuttingTagRow,
      $$CuttingTagsTableFilterComposer,
      $$CuttingTagsTableOrderingComposer,
      $$CuttingTagsTableAnnotationComposer,
      $$CuttingTagsTableCreateCompanionBuilder,
      $$CuttingTagsTableUpdateCompanionBuilder,
      (CuttingTagRow, $$CuttingTagsTableReferences),
      CuttingTagRow,
      PrefetchHooks Function({bool cuttingId})
    >;
typedef $$CuttingEventsTableCreateCompanionBuilder =
    CuttingEventsCompanion Function({
      required String id,
      required String cuttingId,
      required DateTime occurredAtUtc,
      required DateTime createdAtUtc,
      required String kind,
      Value<String> note,
      Value<String?> stage,
      Value<String?> outcome,
      Value<String?> correctsEventId,
      Value<int> rowid,
    });
typedef $$CuttingEventsTableUpdateCompanionBuilder =
    CuttingEventsCompanion Function({
      Value<String> id,
      Value<String> cuttingId,
      Value<DateTime> occurredAtUtc,
      Value<DateTime> createdAtUtc,
      Value<String> kind,
      Value<String> note,
      Value<String?> stage,
      Value<String?> outcome,
      Value<String?> correctsEventId,
      Value<int> rowid,
    });

final class $$CuttingEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CuttingEventsTable, CuttingEventRow> {
  $$CuttingEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CuttingsTable _cuttingIdTable(_$AppDatabase db) =>
      db.cuttings.createAlias('cutting_events__cutting_id__cuttings__id');

  $$CuttingsTableProcessedTableManager get cuttingId {
    final $_column = $_itemColumn<String>('cutting_id')!;

    final manager = $$CuttingsTableTableManager(
      $_db,
      $_db.cuttings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuttingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CuttingEventsTable _correctsEventIdTable(_$AppDatabase db) => db
      .cuttingEvents
      .createAlias('cutting_events__corrects_event_id__cutting_events__id');

  $$CuttingEventsTableProcessedTableManager? get correctsEventId {
    final $_column = $_itemColumn<String>('corrects_event_id');
    if ($_column == null) return null;
    final manager = $$CuttingEventsTableTableManager(
      $_db,
      $_db.cuttingEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_correctsEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAssetRow>>
  _mediaAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: 'cutting_events__id__media_assets__event_id',
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager(
      $_db,
      $_db.mediaAssets,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CuttingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CuttingEventsTable> {
  $$CuttingEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  $$CuttingsTableFilterComposer get cuttingId {
    final $$CuttingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableFilterComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuttingEventsTableFilterComposer get correctsEventId {
    final $$CuttingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsEventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableFilterComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuttingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CuttingEventsTable> {
  $$CuttingEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuttingsTableOrderingComposer get cuttingId {
    final $$CuttingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableOrderingComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuttingEventsTableOrderingComposer get correctsEventId {
    final $$CuttingEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsEventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableOrderingComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuttingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuttingEventsTable> {
  $$CuttingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  $$CuttingsTableAnnotationComposer get cuttingId {
    final $$CuttingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuttingEventsTableAnnotationComposer get correctsEventId {
    final $$CuttingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctsEventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CuttingEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuttingEventsTable,
          CuttingEventRow,
          $$CuttingEventsTableFilterComposer,
          $$CuttingEventsTableOrderingComposer,
          $$CuttingEventsTableAnnotationComposer,
          $$CuttingEventsTableCreateCompanionBuilder,
          $$CuttingEventsTableUpdateCompanionBuilder,
          (CuttingEventRow, $$CuttingEventsTableReferences),
          CuttingEventRow,
          PrefetchHooks Function({
            bool cuttingId,
            bool correctsEventId,
            bool mediaAssetsRefs,
          })
        > {
  $$CuttingEventsTableTableManager(_$AppDatabase db, $CuttingEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuttingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuttingEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuttingEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cuttingId = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> correctsEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuttingEventsCompanion(
                id: id,
                cuttingId: cuttingId,
                occurredAtUtc: occurredAtUtc,
                createdAtUtc: createdAtUtc,
                kind: kind,
                note: note,
                stage: stage,
                outcome: outcome,
                correctsEventId: correctsEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cuttingId,
                required DateTime occurredAtUtc,
                required DateTime createdAtUtc,
                required String kind,
                Value<String> note = const Value.absent(),
                Value<String?> stage = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> correctsEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuttingEventsCompanion.insert(
                id: id,
                cuttingId: cuttingId,
                occurredAtUtc: occurredAtUtc,
                createdAtUtc: createdAtUtc,
                kind: kind,
                note: note,
                stage: stage,
                outcome: outcome,
                correctsEventId: correctsEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CuttingEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cuttingId = false,
                correctsEventId = false,
                mediaAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mediaAssetsRefs) db.mediaAssets,
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
                        if (cuttingId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cuttingId,
                            referencedTable: $$CuttingEventsTableReferences
                                ._cuttingIdTable(db),
                            referencedColumn: $$CuttingEventsTableReferences
                                ._cuttingIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (correctsEventId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.correctsEventId,
                            referencedTable: $$CuttingEventsTableReferences
                                ._correctsEventIdTable(db),
                            referencedColumn: $$CuttingEventsTableReferences
                                ._correctsEventIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mediaAssetsRefs)
                        await $_getPrefetchedData<
                          CuttingEventRow,
                          $CuttingEventsTable,
                          MediaAssetRow
                        >(
                          currentTable: table,
                          referencedTable: $$CuttingEventsTableReferences
                              ._mediaAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CuttingEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
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

typedef $$CuttingEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuttingEventsTable,
      CuttingEventRow,
      $$CuttingEventsTableFilterComposer,
      $$CuttingEventsTableOrderingComposer,
      $$CuttingEventsTableAnnotationComposer,
      $$CuttingEventsTableCreateCompanionBuilder,
      $$CuttingEventsTableUpdateCompanionBuilder,
      (CuttingEventRow, $$CuttingEventsTableReferences),
      CuttingEventRow,
      PrefetchHooks Function({
        bool cuttingId,
        bool correctsEventId,
        bool mediaAssetsRefs,
      })
    >;
typedef $$MediaAssetsTableCreateCompanionBuilder =
    MediaAssetsCompanion Function({
      required String id,
      required String eventId,
      required String relativePath,
      required String sha256,
      required String mediaType,
      Value<String> caption,
      Value<DateTime?> capturedAtUtc,
      required DateTime importedAtUtc,
      Value<int> rowid,
    });
typedef $$MediaAssetsTableUpdateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<String> relativePath,
      Value<String> sha256,
      Value<String> mediaType,
      Value<String> caption,
      Value<DateTime?> capturedAtUtc,
      Value<DateTime> importedAtUtc,
      Value<int> rowid,
    });

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaAssetsTable, MediaAssetRow> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuttingEventsTable _eventIdTable(_$AppDatabase db) => db.cuttingEvents
      .createAlias('media_assets__event_id__cutting_events__id');

  $$CuttingEventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$CuttingEventsTableTableManager(
      $_db,
      $_db.cuttingEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAtUtc => $composableBuilder(
    column: $table.importedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$CuttingEventsTableFilterComposer get eventId {
    final $$CuttingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableFilterComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAtUtc => $composableBuilder(
    column: $table.importedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuttingEventsTableOrderingComposer get eventId {
    final $$CuttingEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableOrderingComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAtUtc => $composableBuilder(
    column: $table.importedAtUtc,
    builder: (column) => column,
  );

  $$CuttingEventsTableAnnotationComposer get eventId {
    final $$CuttingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.cuttingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAssetsTable,
          MediaAssetRow,
          $$MediaAssetsTableFilterComposer,
          $$MediaAssetsTableOrderingComposer,
          $$MediaAssetsTableAnnotationComposer,
          $$MediaAssetsTableCreateCompanionBuilder,
          $$MediaAssetsTableUpdateCompanionBuilder,
          (MediaAssetRow, $$MediaAssetsTableReferences),
          MediaAssetRow,
          PrefetchHooks Function({bool eventId})
        > {
  $$MediaAssetsTableTableManager(_$AppDatabase db, $MediaAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> caption = const Value.absent(),
                Value<DateTime?> capturedAtUtc = const Value.absent(),
                Value<DateTime> importedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion(
                id: id,
                eventId: eventId,
                relativePath: relativePath,
                sha256: sha256,
                mediaType: mediaType,
                caption: caption,
                capturedAtUtc: capturedAtUtc,
                importedAtUtc: importedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required String relativePath,
                required String sha256,
                required String mediaType,
                Value<String> caption = const Value.absent(),
                Value<DateTime?> capturedAtUtc = const Value.absent(),
                required DateTime importedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion.insert(
                id: id,
                eventId: eventId,
                relativePath: relativePath,
                sha256: sha256,
                mediaType: mediaType,
                caption: caption,
                capturedAtUtc: capturedAtUtc,
                importedAtUtc: importedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
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
                    if (eventId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.eventId,
                        referencedTable: $$MediaAssetsTableReferences
                            ._eventIdTable(db),
                        referencedColumn: $$MediaAssetsTableReferences
                            ._eventIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MediaAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAssetsTable,
      MediaAssetRow,
      $$MediaAssetsTableFilterComposer,
      $$MediaAssetsTableOrderingComposer,
      $$MediaAssetsTableAnnotationComposer,
      $$MediaAssetsTableCreateCompanionBuilder,
      $$MediaAssetsTableUpdateCompanionBuilder,
      (MediaAssetRow, $$MediaAssetsTableReferences),
      MediaAssetRow,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String cuttingId,
  required DateTime scheduledForUtc,
  Value<String> timeZoneId,
  required String status,
  Value<String?> platformNotificationId,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<DateTime?> completedAtUtc,
  Value<DateTime?> snoozedFromUtc,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> cuttingId,
  Value<DateTime> scheduledForUtc,
  Value<String> timeZoneId,
  Value<String> status,
  Value<String?> platformNotificationId,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<DateTime?> completedAtUtc,
  Value<DateTime?> snoozedFromUtc,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CuttingsTable _cuttingIdTable(_$AppDatabase db) =>
      db.cuttings.createAlias('reminders__cutting_id__cuttings__id');

  $$CuttingsTableProcessedTableManager get cuttingId {
    final $_column = $_itemColumn<String>('cutting_id')!;

    final manager = $$CuttingsTableTableManager(
      $_db,
      $_db.cuttings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuttingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledForUtc => $composableBuilder(
    column: $table.scheduledForUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedFromUtc => $composableBuilder(
    column: $table.snoozedFromUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$CuttingsTableFilterComposer get cuttingId {
    final $$CuttingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableFilterComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledForUtc => $composableBuilder(
    column: $table.scheduledForUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedFromUtc => $composableBuilder(
    column: $table.snoozedFromUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuttingsTableOrderingComposer get cuttingId {
    final $$CuttingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableOrderingComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledForUtc => $composableBuilder(
    column: $table.scheduledForUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get platformNotificationId => $composableBuilder(
    column: $table.platformNotificationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozedFromUtc => $composableBuilder(
    column: $table.snoozedFromUtc,
    builder: (column) => column,
  );

  $$CuttingsTableAnnotationComposer get cuttingId {
    final $$CuttingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuttingId,
      referencedTable: $db.cuttings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuttingsTableAnnotationComposer(
            $db: $db,
            $table: $db.cuttings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool cuttingId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cuttingId = const Value.absent(),
                Value<DateTime> scheduledForUtc = const Value.absent(),
                Value<String> timeZoneId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> platformNotificationId = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> snoozedFromUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                cuttingId: cuttingId,
                scheduledForUtc: scheduledForUtc,
                timeZoneId: timeZoneId,
                status: status,
                platformNotificationId: platformNotificationId,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                snoozedFromUtc: snoozedFromUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cuttingId,
                required DateTime scheduledForUtc,
                Value<String> timeZoneId = const Value.absent(),
                required String status,
                Value<String?> platformNotificationId = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> snoozedFromUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                cuttingId: cuttingId,
                scheduledForUtc: scheduledForUtc,
                timeZoneId: timeZoneId,
                status: status,
                platformNotificationId: platformNotificationId,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                snoozedFromUtc: snoozedFromUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cuttingId = false}) {
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
                    if (cuttingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cuttingId,
                        referencedTable: $$RemindersTableReferences
                            ._cuttingIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._cuttingIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool cuttingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ParentPlantsTableTableManager get parentPlants =>
      $$ParentPlantsTableTableManager(_db, _db.parentPlants);
  $$CuttingsTableTableManager get cuttings =>
      $$CuttingsTableTableManager(_db, _db.cuttings);
  $$CuttingTagsTableTableManager get cuttingTags =>
      $$CuttingTagsTableTableManager(_db, _db.cuttingTags);
  $$CuttingEventsTableTableManager get cuttingEvents =>
      $$CuttingEventsTableTableManager(_db, _db.cuttingEvents);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
