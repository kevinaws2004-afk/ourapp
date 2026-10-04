// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class ActivityTypes extends Table
    with TableInfo<ActivityTypes, ActivityTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActivityTypes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _iconIdMeta = const VerificationMeta('iconId');
  late final GeneratedColumn<String> iconId = GeneratedColumn<String>(
    'icon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(icon_id) > 0)',
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(color_key) > 0)',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _supportsTimerMeta = const VerificationMeta(
    'supportsTimer',
  );
  late final GeneratedColumn<int> supportsTimer = GeneratedColumn<int>(
    'supports_timer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (supports_timer IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _supportsPlanningMeta = const VerificationMeta(
    'supportsPlanning',
  );
  late final GeneratedColumn<int> supportsPlanning = GeneratedColumn<int>(
    'supports_planning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 1 CHECK (supports_planning IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    name,
    iconId,
    colorKey,
    description,
    supportsTimer,
    supportsPlanning,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_id')) {
      context.handle(
        _iconIdMeta,
        iconId.isAcceptableOrUnknown(data['icon_id']!, _iconIdMeta),
      );
    } else if (isInserting) {
      context.missing(_iconIdMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_colorKeyMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('supports_timer')) {
      context.handle(
        _supportsTimerMeta,
        supportsTimer.isAcceptableOrUnknown(
          data['supports_timer']!,
          _supportsTimerMeta,
        ),
      );
    }
    if (data.containsKey('supports_planning')) {
      context.handle(
        _supportsPlanningMeta,
        supportsPlanning.isAcceptableOrUnknown(
          data['supports_planning']!,
          _supportsPlanningMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  ActivityTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityTypeRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_id'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      supportsTimer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supports_timer'],
      )!,
      supportsPlanning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supports_planning'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  ActivityTypes createAlias(String alias) {
    return ActivityTypes(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class ActivityTypeRow extends DataClass implements Insertable<ActivityTypeRow> {
  final int internalId;
  final String publicId;
  final String name;
  final String iconId;
  final String colorKey;
  final String? description;
  final int supportsTimer;
  final int supportsPlanning;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const ActivityTypeRow({
    required this.internalId,
    required this.publicId,
    required this.name,
    required this.iconId,
    required this.colorKey,
    this.description,
    required this.supportsTimer,
    required this.supportsPlanning,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['name'] = Variable<String>(name);
    map['icon_id'] = Variable<String>(iconId);
    map['color_key'] = Variable<String>(colorKey);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['supports_timer'] = Variable<int>(supportsTimer);
    map['supports_planning'] = Variable<int>(supportsPlanning);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  ActivityTypesCompanion toCompanion(bool nullToAbsent) {
    return ActivityTypesCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      name: Value(name),
      iconId: Value(iconId),
      colorKey: Value(colorKey),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      supportsTimer: Value(supportsTimer),
      supportsPlanning: Value(supportsPlanning),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ActivityTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityTypeRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      name: serializer.fromJson<String>(json['name']),
      iconId: serializer.fromJson<String>(json['icon_id']),
      colorKey: serializer.fromJson<String>(json['color_key']),
      description: serializer.fromJson<String?>(json['description']),
      supportsTimer: serializer.fromJson<int>(json['supports_timer']),
      supportsPlanning: serializer.fromJson<int>(json['supports_planning']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'name': serializer.toJson<String>(name),
      'icon_id': serializer.toJson<String>(iconId),
      'color_key': serializer.toJson<String>(colorKey),
      'description': serializer.toJson<String?>(description),
      'supports_timer': serializer.toJson<int>(supportsTimer),
      'supports_planning': serializer.toJson<int>(supportsPlanning),
      'sort_order': serializer.toJson<int>(sortOrder),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
    };
  }

  ActivityTypeRow copyWith({
    int? internalId,
    String? publicId,
    String? name,
    String? iconId,
    String? colorKey,
    Value<String?> description = const Value.absent(),
    int? supportsTimer,
    int? supportsPlanning,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => ActivityTypeRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    name: name ?? this.name,
    iconId: iconId ?? this.iconId,
    colorKey: colorKey ?? this.colorKey,
    description: description.present ? description.value : this.description,
    supportsTimer: supportsTimer ?? this.supportsTimer,
    supportsPlanning: supportsPlanning ?? this.supportsPlanning,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ActivityTypeRow copyWithCompanion(ActivityTypesCompanion data) {
    return ActivityTypeRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      name: data.name.present ? data.name.value : this.name,
      iconId: data.iconId.present ? data.iconId.value : this.iconId,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      description: data.description.present
          ? data.description.value
          : this.description,
      supportsTimer: data.supportsTimer.present
          ? data.supportsTimer.value
          : this.supportsTimer,
      supportsPlanning: data.supportsPlanning.present
          ? data.supportsPlanning.value
          : this.supportsPlanning,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityTypeRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('iconId: $iconId, ')
          ..write('colorKey: $colorKey, ')
          ..write('description: $description, ')
          ..write('supportsTimer: $supportsTimer, ')
          ..write('supportsPlanning: $supportsPlanning, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    name,
    iconId,
    colorKey,
    description,
    supportsTimer,
    supportsPlanning,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityTypeRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.name == this.name &&
          other.iconId == this.iconId &&
          other.colorKey == this.colorKey &&
          other.description == this.description &&
          other.supportsTimer == this.supportsTimer &&
          other.supportsPlanning == this.supportsPlanning &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ActivityTypesCompanion extends UpdateCompanion<ActivityTypeRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<String> name;
  final Value<String> iconId;
  final Value<String> colorKey;
  final Value<String?> description;
  final Value<int> supportsTimer;
  final Value<int> supportsPlanning;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  const ActivityTypesCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconId = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.description = const Value.absent(),
    this.supportsTimer = const Value.absent(),
    this.supportsPlanning = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ActivityTypesCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required String name,
    required String iconId,
    required String colorKey,
    this.description = const Value.absent(),
    this.supportsTimer = const Value.absent(),
    this.supportsPlanning = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
  }) : publicId = Value(publicId),
       name = Value(name),
       iconId = Value(iconId),
       colorKey = Value(colorKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityTypeRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<String>? name,
    Expression<String>? iconId,
    Expression<String>? colorKey,
    Expression<String>? description,
    Expression<int>? supportsTimer,
    Expression<int>? supportsPlanning,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (name != null) 'name': name,
      if (iconId != null) 'icon_id': iconId,
      if (colorKey != null) 'color_key': colorKey,
      if (description != null) 'description': description,
      if (supportsTimer != null) 'supports_timer': supportsTimer,
      if (supportsPlanning != null) 'supports_planning': supportsPlanning,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ActivityTypesCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<String>? name,
    Value<String>? iconId,
    Value<String>? colorKey,
    Value<String?>? description,
    Value<int>? supportsTimer,
    Value<int>? supportsPlanning,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return ActivityTypesCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      iconId: iconId ?? this.iconId,
      colorKey: colorKey ?? this.colorKey,
      description: description ?? this.description,
      supportsTimer: supportsTimer ?? this.supportsTimer,
      supportsPlanning: supportsPlanning ?? this.supportsPlanning,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconId.present) {
      map['icon_id'] = Variable<String>(iconId.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (supportsTimer.present) {
      map['supports_timer'] = Variable<int>(supportsTimer.value);
    }
    if (supportsPlanning.present) {
      map['supports_planning'] = Variable<int>(supportsPlanning.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityTypesCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('iconId: $iconId, ')
          ..write('colorKey: $colorKey, ')
          ..write('description: $description, ')
          ..write('supportsTimer: $supportsTimer, ')
          ..write('supportsPlanning: $supportsPlanning, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class ActivityFields extends Table
    with TableInfo<ActivityFields, ActivityFieldRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActivityFields(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _activityTypeIdMeta = const VerificationMeta(
    'activityTypeId',
  );
  late final GeneratedColumn<int> activityTypeId = GeneratedColumn<int>(
    'activity_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_types(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _fieldTypeMeta = const VerificationMeta(
    'fieldType',
  );
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
    'field_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (field_type IN (\'text\', \'number\', \'boolean\', \'single_select\', \'multi_select\', \'date\', \'time\', \'duration\', \'rating\', \'repeating_group\'))',
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  late final GeneratedColumn<String> dimension = GeneratedColumn<String>(
    'dimension',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (dimension IS NULL OR field_type = \'number\')',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (position >= 0)',
  );
  static const VerificationMeta _requiredMeta = const VerificationMeta(
    'required',
  );
  late final GeneratedColumn<int> required = GeneratedColumn<int>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (required IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _measurableMeta = const VerificationMeta(
    'measurable',
  );
  late final GeneratedColumn<int> measurable = GeneratedColumn<int>(
    'measurable',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (measurable IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'{}\' CHECK (json_valid(config_json))',
    defaultValue: const CustomExpression('\'{}\''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _parentFieldIdMeta = const VerificationMeta(
    'parentFieldId',
  );
  late final GeneratedColumn<int> parentFieldId = GeneratedColumn<int>(
    'parent_field_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES activity_fields(internal_id)ON DELETE RESTRICT',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    activityTypeId,
    name,
    fieldType,
    dimension,
    position,
    required,
    measurable,
    configJson,
    createdAt,
    updatedAt,
    deletedAt,
    parentFieldId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityFieldRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('activity_type_id')) {
      context.handle(
        _activityTypeIdMeta,
        activityTypeId.isAcceptableOrUnknown(
          data['activity_type_id']!,
          _activityTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(
        _fieldTypeMeta,
        fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('required')) {
      context.handle(
        _requiredMeta,
        required.isAcceptableOrUnknown(data['required']!, _requiredMeta),
      );
    }
    if (data.containsKey('measurable')) {
      context.handle(
        _measurableMeta,
        measurable.isAcceptableOrUnknown(data['measurable']!, _measurableMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('parent_field_id')) {
      context.handle(
        _parentFieldIdMeta,
        parentFieldId.isAcceptableOrUnknown(
          data['parent_field_id']!,
          _parentFieldIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  ActivityFieldRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityFieldRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      activityTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fieldType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_type'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      required: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required'],
      )!,
      measurable: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurable'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      parentFieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_field_id'],
      ),
    );
  }

  @override
  ActivityFields createAlias(String alias) {
    return ActivityFields(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(measurable = 0 OR field_type IN (\'number\', \'rating\', \'duration\', \'boolean\'))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ActivityFieldRow extends DataClass
    implements Insertable<ActivityFieldRow> {
  final int internalId;
  final String publicId;
  final int activityTypeId;
  final String name;
  final String fieldType;
  final String? dimension;
  final int position;
  final int required;
  final int measurable;
  final String configJson;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  /// v3: sub-field of a Repeating Group (ADR-027). Added with ALTER TABLE, so it is last.
  final int? parentFieldId;
  const ActivityFieldRow({
    required this.internalId,
    required this.publicId,
    required this.activityTypeId,
    required this.name,
    required this.fieldType,
    this.dimension,
    required this.position,
    required this.required,
    required this.measurable,
    required this.configJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.parentFieldId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['activity_type_id'] = Variable<int>(activityTypeId);
    map['name'] = Variable<String>(name);
    map['field_type'] = Variable<String>(fieldType);
    if (!nullToAbsent || dimension != null) {
      map['dimension'] = Variable<String>(dimension);
    }
    map['position'] = Variable<int>(position);
    map['required'] = Variable<int>(required);
    map['measurable'] = Variable<int>(measurable);
    map['config_json'] = Variable<String>(configJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || parentFieldId != null) {
      map['parent_field_id'] = Variable<int>(parentFieldId);
    }
    return map;
  }

  ActivityFieldsCompanion toCompanion(bool nullToAbsent) {
    return ActivityFieldsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      activityTypeId: Value(activityTypeId),
      name: Value(name),
      fieldType: Value(fieldType),
      dimension: dimension == null && nullToAbsent
          ? const Value.absent()
          : Value(dimension),
      position: Value(position),
      required: Value(required),
      measurable: Value(measurable),
      configJson: Value(configJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      parentFieldId: parentFieldId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFieldId),
    );
  }

  factory ActivityFieldRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityFieldRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      activityTypeId: serializer.fromJson<int>(json['activity_type_id']),
      name: serializer.fromJson<String>(json['name']),
      fieldType: serializer.fromJson<String>(json['field_type']),
      dimension: serializer.fromJson<String?>(json['dimension']),
      position: serializer.fromJson<int>(json['position']),
      required: serializer.fromJson<int>(json['required']),
      measurable: serializer.fromJson<int>(json['measurable']),
      configJson: serializer.fromJson<String>(json['config_json']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      parentFieldId: serializer.fromJson<int?>(json['parent_field_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'activity_type_id': serializer.toJson<int>(activityTypeId),
      'name': serializer.toJson<String>(name),
      'field_type': serializer.toJson<String>(fieldType),
      'dimension': serializer.toJson<String?>(dimension),
      'position': serializer.toJson<int>(position),
      'required': serializer.toJson<int>(required),
      'measurable': serializer.toJson<int>(measurable),
      'config_json': serializer.toJson<String>(configJson),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'parent_field_id': serializer.toJson<int?>(parentFieldId),
    };
  }

  ActivityFieldRow copyWith({
    int? internalId,
    String? publicId,
    int? activityTypeId,
    String? name,
    String? fieldType,
    Value<String?> dimension = const Value.absent(),
    int? position,
    int? required,
    int? measurable,
    String? configJson,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> parentFieldId = const Value.absent(),
  }) => ActivityFieldRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    activityTypeId: activityTypeId ?? this.activityTypeId,
    name: name ?? this.name,
    fieldType: fieldType ?? this.fieldType,
    dimension: dimension.present ? dimension.value : this.dimension,
    position: position ?? this.position,
    required: required ?? this.required,
    measurable: measurable ?? this.measurable,
    configJson: configJson ?? this.configJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    parentFieldId: parentFieldId.present
        ? parentFieldId.value
        : this.parentFieldId,
  );
  ActivityFieldRow copyWithCompanion(ActivityFieldsCompanion data) {
    return ActivityFieldRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      activityTypeId: data.activityTypeId.present
          ? data.activityTypeId.value
          : this.activityTypeId,
      name: data.name.present ? data.name.value : this.name,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      position: data.position.present ? data.position.value : this.position,
      required: data.required.present ? data.required.value : this.required,
      measurable: data.measurable.present
          ? data.measurable.value
          : this.measurable,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      parentFieldId: data.parentFieldId.present
          ? data.parentFieldId.value
          : this.parentFieldId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityFieldRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('dimension: $dimension, ')
          ..write('position: $position, ')
          ..write('required: $required, ')
          ..write('measurable: $measurable, ')
          ..write('configJson: $configJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('parentFieldId: $parentFieldId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    activityTypeId,
    name,
    fieldType,
    dimension,
    position,
    required,
    measurable,
    configJson,
    createdAt,
    updatedAt,
    deletedAt,
    parentFieldId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityFieldRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.activityTypeId == this.activityTypeId &&
          other.name == this.name &&
          other.fieldType == this.fieldType &&
          other.dimension == this.dimension &&
          other.position == this.position &&
          other.required == this.required &&
          other.measurable == this.measurable &&
          other.configJson == this.configJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.parentFieldId == this.parentFieldId);
}

class ActivityFieldsCompanion extends UpdateCompanion<ActivityFieldRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int> activityTypeId;
  final Value<String> name;
  final Value<String> fieldType;
  final Value<String?> dimension;
  final Value<int> position;
  final Value<int> required;
  final Value<int> measurable;
  final Value<String> configJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> parentFieldId;
  const ActivityFieldsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.activityTypeId = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.dimension = const Value.absent(),
    this.position = const Value.absent(),
    this.required = const Value.absent(),
    this.measurable = const Value.absent(),
    this.configJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.parentFieldId = const Value.absent(),
  });
  ActivityFieldsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required int activityTypeId,
    required String name,
    required String fieldType,
    this.dimension = const Value.absent(),
    required int position,
    this.required = const Value.absent(),
    this.measurable = const Value.absent(),
    this.configJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.parentFieldId = const Value.absent(),
  }) : publicId = Value(publicId),
       activityTypeId = Value(activityTypeId),
       name = Value(name),
       fieldType = Value(fieldType),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityFieldRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? activityTypeId,
    Expression<String>? name,
    Expression<String>? fieldType,
    Expression<String>? dimension,
    Expression<int>? position,
    Expression<int>? required,
    Expression<int>? measurable,
    Expression<String>? configJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? parentFieldId,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      if (name != null) 'name': name,
      if (fieldType != null) 'field_type': fieldType,
      if (dimension != null) 'dimension': dimension,
      if (position != null) 'position': position,
      if (required != null) 'required': required,
      if (measurable != null) 'measurable': measurable,
      if (configJson != null) 'config_json': configJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (parentFieldId != null) 'parent_field_id': parentFieldId,
    });
  }

  ActivityFieldsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int>? activityTypeId,
    Value<String>? name,
    Value<String>? fieldType,
    Value<String?>? dimension,
    Value<int>? position,
    Value<int>? required,
    Value<int>? measurable,
    Value<String>? configJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? parentFieldId,
  }) {
    return ActivityFieldsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      dimension: dimension ?? this.dimension,
      position: position ?? this.position,
      required: required ?? this.required,
      measurable: measurable ?? this.measurable,
      configJson: configJson ?? this.configJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      parentFieldId: parentFieldId ?? this.parentFieldId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (activityTypeId.present) {
      map['activity_type_id'] = Variable<int>(activityTypeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<String>(dimension.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (required.present) {
      map['required'] = Variable<int>(required.value);
    }
    if (measurable.present) {
      map['measurable'] = Variable<int>(measurable.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (parentFieldId.present) {
      map['parent_field_id'] = Variable<int>(parentFieldId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityFieldsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('dimension: $dimension, ')
          ..write('position: $position, ')
          ..write('required: $required, ')
          ..write('measurable: $measurable, ')
          ..write('configJson: $configJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('parentFieldId: $parentFieldId')
          ..write(')'))
        .toString();
  }
}

class PlanSeries extends Table with TableInfo<PlanSeries, PlanSeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlanSeries(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _activityTypeIdMeta = const VerificationMeta(
    'activityTypeId',
  );
  late final GeneratedColumn<int> activityTypeId = GeneratedColumn<int>(
    'activity_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES activity_types(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(title)) > 0)',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (start_minute IS NULL OR start_minute BETWEEN 0 AND 1439)',
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (duration_ms IS NULL OR duration_ms > 0)',
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (weekdays BETWEEN 1 AND 127)',
  );
  static const VerificationMeta _intervalWeeksMeta = const VerificationMeta(
    'intervalWeeks',
  );
  late final GeneratedColumn<int> intervalWeeks = GeneratedColumn<int>(
    'interval_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 1 CHECK (interval_weeks BETWEEN 1 AND 52)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (start_date GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\')',
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (end_date IS NULL OR end_date >= start_date)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    activityTypeId,
    title,
    notes,
    startMinute,
    durationMs,
    weekdays,
    intervalWeeks,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanSeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('activity_type_id')) {
      context.handle(
        _activityTypeIdMeta,
        activityTypeId.isAcceptableOrUnknown(
          data['activity_type_id']!,
          _activityTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdaysMeta);
    }
    if (data.containsKey('interval_weeks')) {
      context.handle(
        _intervalWeeksMeta,
        intervalWeeks.isAcceptableOrUnknown(
          data['interval_weeks']!,
          _intervalWeeksMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  PlanSeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanSeriesRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      activityTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_type_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
      intervalWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_weeks'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  PlanSeries createAlias(String alias) {
    return PlanSeries(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class PlanSeriesRow extends DataClass implements Insertable<PlanSeriesRow> {
  final int internalId;
  final String publicId;
  final int? activityTypeId;
  final String title;
  final String? notes;

  /// Local wall-clock start (minute of day), if timed.
  final int? startMinute;
  final int? durationMs;

  /// Bit 0 = Monday … bit 6 = Sunday.
  final int weekdays;
  final int intervalWeeks;
  final String startDate;
  final String? endDate;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const PlanSeriesRow({
    required this.internalId,
    required this.publicId,
    this.activityTypeId,
    required this.title,
    this.notes,
    this.startMinute,
    this.durationMs,
    required this.weekdays,
    required this.intervalWeeks,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    if (!nullToAbsent || activityTypeId != null) {
      map['activity_type_id'] = Variable<int>(activityTypeId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || startMinute != null) {
      map['start_minute'] = Variable<int>(startMinute);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['weekdays'] = Variable<int>(weekdays);
    map['interval_weeks'] = Variable<int>(intervalWeeks);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  PlanSeriesCompanion toCompanion(bool nullToAbsent) {
    return PlanSeriesCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      activityTypeId: activityTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityTypeId),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      startMinute: startMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinute),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      weekdays: Value(weekdays),
      intervalWeeks: Value(intervalWeeks),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PlanSeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanSeriesRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      activityTypeId: serializer.fromJson<int?>(json['activity_type_id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      startMinute: serializer.fromJson<int?>(json['start_minute']),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      weekdays: serializer.fromJson<int>(json['weekdays']),
      intervalWeeks: serializer.fromJson<int>(json['interval_weeks']),
      startDate: serializer.fromJson<String>(json['start_date']),
      endDate: serializer.fromJson<String?>(json['end_date']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'activity_type_id': serializer.toJson<int?>(activityTypeId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'start_minute': serializer.toJson<int?>(startMinute),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'weekdays': serializer.toJson<int>(weekdays),
      'interval_weeks': serializer.toJson<int>(intervalWeeks),
      'start_date': serializer.toJson<String>(startDate),
      'end_date': serializer.toJson<String?>(endDate),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
    };
  }

  PlanSeriesRow copyWith({
    int? internalId,
    String? publicId,
    Value<int?> activityTypeId = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<int?> startMinute = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    int? weekdays,
    int? intervalWeeks,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => PlanSeriesRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    activityTypeId: activityTypeId.present
        ? activityTypeId.value
        : this.activityTypeId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    startMinute: startMinute.present ? startMinute.value : this.startMinute,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    weekdays: weekdays ?? this.weekdays,
    intervalWeeks: intervalWeeks ?? this.intervalWeeks,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PlanSeriesRow copyWithCompanion(PlanSeriesCompanion data) {
    return PlanSeriesRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      activityTypeId: data.activityTypeId.present
          ? data.activityTypeId.value
          : this.activityTypeId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      intervalWeeks: data.intervalWeeks.present
          ? data.intervalWeeks.value
          : this.intervalWeeks,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanSeriesRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMs: $durationMs, ')
          ..write('weekdays: $weekdays, ')
          ..write('intervalWeeks: $intervalWeeks, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    activityTypeId,
    title,
    notes,
    startMinute,
    durationMs,
    weekdays,
    intervalWeeks,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanSeriesRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.activityTypeId == this.activityTypeId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.startMinute == this.startMinute &&
          other.durationMs == this.durationMs &&
          other.weekdays == this.weekdays &&
          other.intervalWeeks == this.intervalWeeks &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlanSeriesCompanion extends UpdateCompanion<PlanSeriesRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int?> activityTypeId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int?> startMinute;
  final Value<int?> durationMs;
  final Value<int> weekdays;
  final Value<int> intervalWeeks;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  const PlanSeriesCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.activityTypeId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.intervalWeeks = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PlanSeriesCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    this.activityTypeId = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int weekdays,
    this.intervalWeeks = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
  }) : publicId = Value(publicId),
       title = Value(title),
       weekdays = Value(weekdays),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlanSeriesRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? activityTypeId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? startMinute,
    Expression<int>? durationMs,
    Expression<int>? weekdays,
    Expression<int>? intervalWeeks,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (startMinute != null) 'start_minute': startMinute,
      if (durationMs != null) 'duration_ms': durationMs,
      if (weekdays != null) 'weekdays': weekdays,
      if (intervalWeeks != null) 'interval_weeks': intervalWeeks,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PlanSeriesCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int?>? activityTypeId,
    Value<String>? title,
    Value<String?>? notes,
    Value<int?>? startMinute,
    Value<int?>? durationMs,
    Value<int>? weekdays,
    Value<int>? intervalWeeks,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return PlanSeriesCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startMinute: startMinute ?? this.startMinute,
      durationMs: durationMs ?? this.durationMs,
      weekdays: weekdays ?? this.weekdays,
      intervalWeeks: intervalWeeks ?? this.intervalWeeks,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (activityTypeId.present) {
      map['activity_type_id'] = Variable<int>(activityTypeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (intervalWeeks.present) {
      map['interval_weeks'] = Variable<int>(intervalWeeks.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanSeriesCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMs: $durationMs, ')
          ..write('weekdays: $weekdays, ')
          ..write('intervalWeeks: $intervalWeeks, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class Plans extends Table with TableInfo<Plans, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Plans(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _planDateMeta = const VerificationMeta(
    'planDate',
  );
  late final GeneratedColumn<String> planDate = GeneratedColumn<String>(
    'plan_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (plan_date GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\')',
  );
  static const VerificationMeta _activityTypeIdMeta = const VerificationMeta(
    'activityTypeId',
  );
  late final GeneratedColumn<int> activityTypeId = GeneratedColumn<int>(
    'activity_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES activity_types(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(title)) > 0)',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedStartAtMeta = const VerificationMeta(
    'plannedStartAt',
  );
  late final GeneratedColumn<int> plannedStartAt = GeneratedColumn<int>(
    'planned_start_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedEndAtMeta = const VerificationMeta(
    'plannedEndAt',
  );
  late final GeneratedColumn<int> plannedEndAt = GeneratedColumn<int>(
    'planned_end_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedDurationMsMeta = const VerificationMeta(
    'plannedDurationMs',
  );
  late final GeneratedColumn<int> plannedDurationMs = GeneratedColumn<int>(
    'planned_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'planned\' CHECK (status IN (\'planned\', \'completed\', \'skipped\', \'cancelled\'))',
    defaultValue: const CustomExpression('\'planned\''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES plan_series(internal_id)ON DELETE RESTRICT',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    planDate,
    activityTypeId,
    title,
    notes,
    plannedStartAt,
    plannedEndAt,
    plannedDurationMs,
    sortOrder,
    status,
    createdAt,
    updatedAt,
    deletedAt,
    seriesId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('plan_date')) {
      context.handle(
        _planDateMeta,
        planDate.isAcceptableOrUnknown(data['plan_date']!, _planDateMeta),
      );
    } else if (isInserting) {
      context.missing(_planDateMeta);
    }
    if (data.containsKey('activity_type_id')) {
      context.handle(
        _activityTypeIdMeta,
        activityTypeId.isAcceptableOrUnknown(
          data['activity_type_id']!,
          _activityTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('planned_start_at')) {
      context.handle(
        _plannedStartAtMeta,
        plannedStartAt.isAcceptableOrUnknown(
          data['planned_start_at']!,
          _plannedStartAtMeta,
        ),
      );
    }
    if (data.containsKey('planned_end_at')) {
      context.handle(
        _plannedEndAtMeta,
        plannedEndAt.isAcceptableOrUnknown(
          data['planned_end_at']!,
          _plannedEndAtMeta,
        ),
      );
    }
    if (data.containsKey('planned_duration_ms')) {
      context.handle(
        _plannedDurationMsMeta,
        plannedDurationMs.isAcceptableOrUnknown(
          data['planned_duration_ms']!,
          _plannedDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      planDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_date'],
      )!,
      activityTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_type_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      plannedStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_start_at'],
      ),
      plannedEndAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_end_at'],
      ),
      plannedDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_ms'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
    );
  }

  @override
  Plans createAlias(String alias) {
    return Plans(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(planned_end_at IS NULL OR planned_start_at IS NOT NULL)',
    'CHECK(planned_end_at IS NULL OR planned_end_at >= planned_start_at)',
    'CHECK(planned_duration_ms IS NULL OR(planned_duration_ms > 0 AND planned_end_at IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final int internalId;
  final String publicId;
  final String planDate;
  final int? activityTypeId;
  final String title;
  final String? notes;
  final int? plannedStartAt;
  final int? plannedEndAt;
  final int? plannedDurationMs;
  final int sortOrder;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  /// v7: the repeating plan this is an occurrence of (ADR-036).
  final int? seriesId;
  const PlanRow({
    required this.internalId,
    required this.publicId,
    required this.planDate,
    this.activityTypeId,
    required this.title,
    this.notes,
    this.plannedStartAt,
    this.plannedEndAt,
    this.plannedDurationMs,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.seriesId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['plan_date'] = Variable<String>(planDate);
    if (!nullToAbsent || activityTypeId != null) {
      map['activity_type_id'] = Variable<int>(activityTypeId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || plannedStartAt != null) {
      map['planned_start_at'] = Variable<int>(plannedStartAt);
    }
    if (!nullToAbsent || plannedEndAt != null) {
      map['planned_end_at'] = Variable<int>(plannedEndAt);
    }
    if (!nullToAbsent || plannedDurationMs != null) {
      map['planned_duration_ms'] = Variable<int>(plannedDurationMs);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      planDate: Value(planDate),
      activityTypeId: activityTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityTypeId),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      plannedStartAt: plannedStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedStartAt),
      plannedEndAt: plannedEndAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedEndAt),
      plannedDurationMs: plannedDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationMs),
      sortOrder: Value(sortOrder),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      planDate: serializer.fromJson<String>(json['plan_date']),
      activityTypeId: serializer.fromJson<int?>(json['activity_type_id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      plannedStartAt: serializer.fromJson<int?>(json['planned_start_at']),
      plannedEndAt: serializer.fromJson<int?>(json['planned_end_at']),
      plannedDurationMs: serializer.fromJson<int?>(json['planned_duration_ms']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      seriesId: serializer.fromJson<int?>(json['series_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'plan_date': serializer.toJson<String>(planDate),
      'activity_type_id': serializer.toJson<int?>(activityTypeId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'planned_start_at': serializer.toJson<int?>(plannedStartAt),
      'planned_end_at': serializer.toJson<int?>(plannedEndAt),
      'planned_duration_ms': serializer.toJson<int?>(plannedDurationMs),
      'sort_order': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'series_id': serializer.toJson<int?>(seriesId),
    };
  }

  PlanRow copyWith({
    int? internalId,
    String? publicId,
    String? planDate,
    Value<int?> activityTypeId = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<int?> plannedStartAt = const Value.absent(),
    Value<int?> plannedEndAt = const Value.absent(),
    Value<int?> plannedDurationMs = const Value.absent(),
    int? sortOrder,
    String? status,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> seriesId = const Value.absent(),
  }) => PlanRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    planDate: planDate ?? this.planDate,
    activityTypeId: activityTypeId.present
        ? activityTypeId.value
        : this.activityTypeId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    plannedStartAt: plannedStartAt.present
        ? plannedStartAt.value
        : this.plannedStartAt,
    plannedEndAt: plannedEndAt.present ? plannedEndAt.value : this.plannedEndAt,
    plannedDurationMs: plannedDurationMs.present
        ? plannedDurationMs.value
        : this.plannedDurationMs,
    sortOrder: sortOrder ?? this.sortOrder,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      planDate: data.planDate.present ? data.planDate.value : this.planDate,
      activityTypeId: data.activityTypeId.present
          ? data.activityTypeId.value
          : this.activityTypeId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      plannedStartAt: data.plannedStartAt.present
          ? data.plannedStartAt.value
          : this.plannedStartAt,
      plannedEndAt: data.plannedEndAt.present
          ? data.plannedEndAt.value
          : this.plannedEndAt,
      plannedDurationMs: data.plannedDurationMs.present
          ? data.plannedDurationMs.value
          : this.plannedDurationMs,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('planDate: $planDate, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('plannedStartAt: $plannedStartAt, ')
          ..write('plannedEndAt: $plannedEndAt, ')
          ..write('plannedDurationMs: $plannedDurationMs, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seriesId: $seriesId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    planDate,
    activityTypeId,
    title,
    notes,
    plannedStartAt,
    plannedEndAt,
    plannedDurationMs,
    sortOrder,
    status,
    createdAt,
    updatedAt,
    deletedAt,
    seriesId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.planDate == this.planDate &&
          other.activityTypeId == this.activityTypeId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.plannedStartAt == this.plannedStartAt &&
          other.plannedEndAt == this.plannedEndAt &&
          other.plannedDurationMs == this.plannedDurationMs &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.seriesId == this.seriesId);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<String> planDate;
  final Value<int?> activityTypeId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int?> plannedStartAt;
  final Value<int?> plannedEndAt;
  final Value<int?> plannedDurationMs;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> seriesId;
  const PlansCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.planDate = const Value.absent(),
    this.activityTypeId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.plannedStartAt = const Value.absent(),
    this.plannedEndAt = const Value.absent(),
    this.plannedDurationMs = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
  });
  PlansCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required String planDate,
    this.activityTypeId = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.plannedStartAt = const Value.absent(),
    this.plannedEndAt = const Value.absent(),
    this.plannedDurationMs = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.seriesId = const Value.absent(),
  }) : publicId = Value(publicId),
       planDate = Value(planDate),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlanRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<String>? planDate,
    Expression<int>? activityTypeId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? plannedStartAt,
    Expression<int>? plannedEndAt,
    Expression<int>? plannedDurationMs,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? seriesId,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (planDate != null) 'plan_date': planDate,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (plannedStartAt != null) 'planned_start_at': plannedStartAt,
      if (plannedEndAt != null) 'planned_end_at': plannedEndAt,
      if (plannedDurationMs != null) 'planned_duration_ms': plannedDurationMs,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (seriesId != null) 'series_id': seriesId,
    });
  }

  PlansCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<String>? planDate,
    Value<int?>? activityTypeId,
    Value<String>? title,
    Value<String?>? notes,
    Value<int?>? plannedStartAt,
    Value<int?>? plannedEndAt,
    Value<int?>? plannedDurationMs,
    Value<int>? sortOrder,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? seriesId,
  }) {
    return PlansCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      planDate: planDate ?? this.planDate,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      plannedStartAt: plannedStartAt ?? this.plannedStartAt,
      plannedEndAt: plannedEndAt ?? this.plannedEndAt,
      plannedDurationMs: plannedDurationMs ?? this.plannedDurationMs,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      seriesId: seriesId ?? this.seriesId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (planDate.present) {
      map['plan_date'] = Variable<String>(planDate.value);
    }
    if (activityTypeId.present) {
      map['activity_type_id'] = Variable<int>(activityTypeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (plannedStartAt.present) {
      map['planned_start_at'] = Variable<int>(plannedStartAt.value);
    }
    if (plannedEndAt.present) {
      map['planned_end_at'] = Variable<int>(plannedEndAt.value);
    }
    if (plannedDurationMs.present) {
      map['planned_duration_ms'] = Variable<int>(plannedDurationMs.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('planDate: $planDate, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('plannedStartAt: $plannedStartAt, ')
          ..write('plannedEndAt: $plannedEndAt, ')
          ..write('plannedDurationMs: $plannedDurationMs, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('seriesId: $seriesId')
          ..write(')'))
        .toString();
  }
}

class ActivityLogs extends Table with TableInfo<ActivityLogs, ActivityLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActivityLogs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _activityTypeIdMeta = const VerificationMeta(
    'activityTypeId',
  );
  late final GeneratedColumn<int> activityTypeId = GeneratedColumn<int>(
    'activity_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_types(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (duration_ms IS NULL OR duration_ms >= 0)',
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tz_offset_minutes BETWEEN -1080 AND 1080)',
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (local_date GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\')',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES plans(internal_id)ON DELETE RESTRICT',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    activityTypeId,
    startedAt,
    endedAt,
    durationMs,
    tzOffsetMinutes,
    localDate,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    planId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('activity_type_id')) {
      context.handle(
        _activityTypeIdMeta,
        activityTypeId.isAcceptableOrUnknown(
          data['activity_type_id']!,
          _activityTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tzOffsetMinutesMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  ActivityLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      activityTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_type_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
    );
  }

  @override
  ActivityLogs createAlias(String alias) {
    return ActivityLogs(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(ended_at IS NULL OR ended_at >= started_at)',
    'CHECK(duration_ms IS NULL OR ended_at IS NULL OR duration_ms <= ended_at - started_at)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ActivityLogRow extends DataClass implements Insertable<ActivityLogRow> {
  final int internalId;
  final String publicId;
  final int activityTypeId;
  final int startedAt;
  final int? endedAt;
  final int? durationMs;
  final int tzOffsetMinutes;
  final String localDate;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int? planId;
  const ActivityLogRow({
    required this.internalId,
    required this.publicId,
    required this.activityTypeId,
    required this.startedAt,
    this.endedAt,
    this.durationMs,
    required this.tzOffsetMinutes,
    required this.localDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.planId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['activity_type_id'] = Variable<int>(activityTypeId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      activityTypeId: Value(activityTypeId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
    );
  }

  factory ActivityLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      activityTypeId: serializer.fromJson<int>(json['activity_type_id']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      endedAt: serializer.fromJson<int?>(json['ended_at']),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tz_offset_minutes']),
      localDate: serializer.fromJson<String>(json['local_date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      planId: serializer.fromJson<int?>(json['plan_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'activity_type_id': serializer.toJson<int>(activityTypeId),
      'started_at': serializer.toJson<int>(startedAt),
      'ended_at': serializer.toJson<int?>(endedAt),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'tz_offset_minutes': serializer.toJson<int>(tzOffsetMinutes),
      'local_date': serializer.toJson<String>(localDate),
      'notes': serializer.toJson<String?>(notes),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'plan_id': serializer.toJson<int?>(planId),
    };
  }

  ActivityLogRow copyWith({
    int? internalId,
    String? publicId,
    int? activityTypeId,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    int? tzOffsetMinutes,
    String? localDate,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<int?> planId = const Value.absent(),
  }) => ActivityLogRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    activityTypeId: activityTypeId ?? this.activityTypeId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    planId: planId.present ? planId.value : this.planId,
  );
  ActivityLogRow copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityLogRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      activityTypeId: data.activityTypeId.present
          ? data.activityTypeId.value
          : this.activityTypeId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      planId: data.planId.present ? data.planId.value : this.planId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('planId: $planId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    activityTypeId,
    startedAt,
    endedAt,
    durationMs,
    tzOffsetMinutes,
    localDate,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    planId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.activityTypeId == this.activityTypeId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.planId == this.planId);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityLogRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int> activityTypeId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int?> durationMs;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int?> planId;
  const ActivityLogsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.activityTypeId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.planId = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required int activityTypeId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int tzOffsetMinutes,
    required String localDate,
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.planId = const Value.absent(),
  }) : publicId = Value(publicId),
       activityTypeId = Value(activityTypeId),
       startedAt = Value(startedAt),
       tzOffsetMinutes = Value(tzOffsetMinutes),
       localDate = Value(localDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityLogRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? activityTypeId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationMs,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? planId,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (planId != null) 'plan_id': planId,
    });
  }

  ActivityLogsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int>? activityTypeId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int?>? durationMs,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int?>? planId,
  }) {
    return ActivityLogsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      planId: planId ?? this.planId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (activityTypeId.present) {
      map['activity_type_id'] = Variable<int>(activityTypeId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('planId: $planId')
          ..write(')'))
        .toString();
  }
}

class LogGroupItems extends Table
    with TableInfo<LogGroupItems, LogGroupItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LogGroupItems(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  late final GeneratedColumn<int> logId = GeneratedColumn<int>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_logs(internal_id)ON DELETE CASCADE',
  );
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  late final GeneratedColumn<int> fieldId = GeneratedColumn<int>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_fields(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _parentItemIdMeta = const VerificationMeta(
    'parentItemId',
  );
  late final GeneratedColumn<int> parentItemId = GeneratedColumn<int>(
    'parent_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES log_group_items(internal_id)ON DELETE CASCADE',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (position >= 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    logId,
    fieldId,
    parentItemId,
    position,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_group_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogGroupItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('parent_item_id')) {
      context.handle(
        _parentItemIdMeta,
        parentItemId.isAcceptableOrUnknown(
          data['parent_item_id']!,
          _parentItemIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  LogGroupItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogGroupItemRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}log_id'],
      )!,
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}field_id'],
      )!,
      parentItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_item_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  LogGroupItems createAlias(String alias) {
    return LogGroupItems(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class LogGroupItemRow extends DataClass implements Insertable<LogGroupItemRow> {
  final int internalId;
  final String publicId;
  final int logId;
  final int fieldId;
  final int? parentItemId;
  final int position;
  final int createdAt;
  final int updatedAt;
  const LogGroupItemRow({
    required this.internalId,
    required this.publicId,
    required this.logId,
    required this.fieldId,
    this.parentItemId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['log_id'] = Variable<int>(logId);
    map['field_id'] = Variable<int>(fieldId);
    if (!nullToAbsent || parentItemId != null) {
      map['parent_item_id'] = Variable<int>(parentItemId);
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LogGroupItemsCompanion toCompanion(bool nullToAbsent) {
    return LogGroupItemsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      logId: Value(logId),
      fieldId: Value(fieldId),
      parentItemId: parentItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentItemId),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LogGroupItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogGroupItemRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      logId: serializer.fromJson<int>(json['log_id']),
      fieldId: serializer.fromJson<int>(json['field_id']),
      parentItemId: serializer.fromJson<int?>(json['parent_item_id']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'log_id': serializer.toJson<int>(logId),
      'field_id': serializer.toJson<int>(fieldId),
      'parent_item_id': serializer.toJson<int?>(parentItemId),
      'position': serializer.toJson<int>(position),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  LogGroupItemRow copyWith({
    int? internalId,
    String? publicId,
    int? logId,
    int? fieldId,
    Value<int?> parentItemId = const Value.absent(),
    int? position,
    int? createdAt,
    int? updatedAt,
  }) => LogGroupItemRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    logId: logId ?? this.logId,
    fieldId: fieldId ?? this.fieldId,
    parentItemId: parentItemId.present ? parentItemId.value : this.parentItemId,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LogGroupItemRow copyWithCompanion(LogGroupItemsCompanion data) {
    return LogGroupItemRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      logId: data.logId.present ? data.logId.value : this.logId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      parentItemId: data.parentItemId.present
          ? data.parentItemId.value
          : this.parentItemId,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogGroupItemRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('logId: $logId, ')
          ..write('fieldId: $fieldId, ')
          ..write('parentItemId: $parentItemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    logId,
    fieldId,
    parentItemId,
    position,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogGroupItemRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.logId == this.logId &&
          other.fieldId == this.fieldId &&
          other.parentItemId == this.parentItemId &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LogGroupItemsCompanion extends UpdateCompanion<LogGroupItemRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int> logId;
  final Value<int> fieldId;
  final Value<int?> parentItemId;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const LogGroupItemsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.logId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.parentItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LogGroupItemsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required int logId,
    required int fieldId,
    this.parentItemId = const Value.absent(),
    required int position,
    required int createdAt,
    required int updatedAt,
  }) : publicId = Value(publicId),
       logId = Value(logId),
       fieldId = Value(fieldId),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LogGroupItemRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? logId,
    Expression<int>? fieldId,
    Expression<int>? parentItemId,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (logId != null) 'log_id': logId,
      if (fieldId != null) 'field_id': fieldId,
      if (parentItemId != null) 'parent_item_id': parentItemId,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LogGroupItemsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int>? logId,
    Value<int>? fieldId,
    Value<int?>? parentItemId,
    Value<int>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return LogGroupItemsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      logId: logId ?? this.logId,
      fieldId: fieldId ?? this.fieldId,
      parentItemId: parentItemId ?? this.parentItemId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<int>(logId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<int>(fieldId.value);
    }
    if (parentItemId.present) {
      map['parent_item_id'] = Variable<int>(parentItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogGroupItemsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('logId: $logId, ')
          ..write('fieldId: $fieldId, ')
          ..write('parentItemId: $parentItemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class LogValues extends Table with TableInfo<LogValues, LogValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LogValues(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  late final GeneratedColumn<int> logId = GeneratedColumn<int>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_logs(internal_id)ON DELETE CASCADE',
  );
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  late final GeneratedColumn<int> fieldId = GeneratedColumn<int>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_fields(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _numberValueMeta = const VerificationMeta(
    'numberValue',
  );
  late final GeneratedColumn<double> numberValue = GeneratedColumn<double>(
    'number_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _normalizedValueMeta = const VerificationMeta(
    'normalizedValue',
  );
  late final GeneratedColumn<double> normalizedValue = GeneratedColumn<double>(
    'normalized_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _booleanValueMeta = const VerificationMeta(
    'booleanValue',
  );
  late final GeneratedColumn<int> booleanValue = GeneratedColumn<int>(
    'boolean_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (boolean_value IS NULL OR boolean_value IN (0, 1))',
  );
  static const VerificationMeta _dateValueMeta = const VerificationMeta(
    'dateValue',
  );
  late final GeneratedColumn<String> dateValue = GeneratedColumn<String>(
    'date_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (date_value IS NULL OR date_value GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\')',
  );
  static const VerificationMeta _timeValueMeta = const VerificationMeta(
    'timeValue',
  );
  late final GeneratedColumn<int> timeValue = GeneratedColumn<int>(
    'time_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (time_value IS NULL OR time_value BETWEEN 0 AND 1439)',
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (duration_ms IS NULL OR duration_ms >= 0)',
  );
  static const VerificationMeta _jsonValueMeta = const VerificationMeta(
    'jsonValue',
  );
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
    'json_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (json_value IS NULL OR json_valid(json_value))',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _groupItemIdMeta = const VerificationMeta(
    'groupItemId',
  );
  late final GeneratedColumn<int> groupItemId = GeneratedColumn<int>(
    'group_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES log_group_items(internal_id)ON DELETE CASCADE',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    logId,
    fieldId,
    textValue,
    numberValue,
    unitCode,
    normalizedValue,
    booleanValue,
    dateValue,
    timeValue,
    durationMs,
    jsonValue,
    createdAt,
    updatedAt,
    groupItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('number_value')) {
      context.handle(
        _numberValueMeta,
        numberValue.isAcceptableOrUnknown(
          data['number_value']!,
          _numberValueMeta,
        ),
      );
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    }
    if (data.containsKey('normalized_value')) {
      context.handle(
        _normalizedValueMeta,
        normalizedValue.isAcceptableOrUnknown(
          data['normalized_value']!,
          _normalizedValueMeta,
        ),
      );
    }
    if (data.containsKey('boolean_value')) {
      context.handle(
        _booleanValueMeta,
        booleanValue.isAcceptableOrUnknown(
          data['boolean_value']!,
          _booleanValueMeta,
        ),
      );
    }
    if (data.containsKey('date_value')) {
      context.handle(
        _dateValueMeta,
        dateValue.isAcceptableOrUnknown(data['date_value']!, _dateValueMeta),
      );
    }
    if (data.containsKey('time_value')) {
      context.handle(
        _timeValueMeta,
        timeValue.isAcceptableOrUnknown(data['time_value']!, _timeValueMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('json_value')) {
      context.handle(
        _jsonValueMeta,
        jsonValue.isAcceptableOrUnknown(data['json_value']!, _jsonValueMeta),
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
    if (data.containsKey('group_item_id')) {
      context.handle(
        _groupItemIdMeta,
        groupItemId.isAcceptableOrUnknown(
          data['group_item_id']!,
          _groupItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  LogValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogValueRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}log_id'],
      )!,
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}field_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      numberValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number_value'],
      ),
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      ),
      normalizedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_value'],
      ),
      booleanValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boolean_value'],
      ),
      dateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_value'],
      ),
      timeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_value'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      jsonValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_value'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      groupItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_item_id'],
      ),
    );
  }

  @override
  LogValues createAlias(String alias) {
    return LogValues(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK((text_value IS NOT NULL)+(number_value IS NOT NULL)+(boolean_value IS NOT NULL)+(date_value IS NOT NULL)+(time_value IS NOT NULL)+(duration_ms IS NOT NULL)+(json_value IS NOT NULL)= 1)',
    'CHECK((number_value IS NULL)=(normalized_value IS NULL))',
    'CHECK(unit_code IS NULL OR number_value IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LogValueRow extends DataClass implements Insertable<LogValueRow> {
  final int internalId;
  final int logId;
  final int fieldId;
  final String? textValue;
  final double? numberValue;
  final String? unitCode;
  final double? normalizedValue;
  final int? booleanValue;
  final String? dateValue;
  final int? timeValue;
  final int? durationMs;
  final String? jsonValue;
  final int createdAt;
  final int updatedAt;

  /// v3: the Repeating Group item this value belongs to (NULL = top-level value).
  final int? groupItemId;
  const LogValueRow({
    required this.internalId,
    required this.logId,
    required this.fieldId,
    this.textValue,
    this.numberValue,
    this.unitCode,
    this.normalizedValue,
    this.booleanValue,
    this.dateValue,
    this.timeValue,
    this.durationMs,
    this.jsonValue,
    required this.createdAt,
    required this.updatedAt,
    this.groupItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['log_id'] = Variable<int>(logId);
    map['field_id'] = Variable<int>(fieldId);
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || numberValue != null) {
      map['number_value'] = Variable<double>(numberValue);
    }
    if (!nullToAbsent || unitCode != null) {
      map['unit_code'] = Variable<String>(unitCode);
    }
    if (!nullToAbsent || normalizedValue != null) {
      map['normalized_value'] = Variable<double>(normalizedValue);
    }
    if (!nullToAbsent || booleanValue != null) {
      map['boolean_value'] = Variable<int>(booleanValue);
    }
    if (!nullToAbsent || dateValue != null) {
      map['date_value'] = Variable<String>(dateValue);
    }
    if (!nullToAbsent || timeValue != null) {
      map['time_value'] = Variable<int>(timeValue);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || jsonValue != null) {
      map['json_value'] = Variable<String>(jsonValue);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || groupItemId != null) {
      map['group_item_id'] = Variable<int>(groupItemId);
    }
    return map;
  }

  LogValuesCompanion toCompanion(bool nullToAbsent) {
    return LogValuesCompanion(
      internalId: Value(internalId),
      logId: Value(logId),
      fieldId: Value(fieldId),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      numberValue: numberValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numberValue),
      unitCode: unitCode == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCode),
      normalizedValue: normalizedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedValue),
      booleanValue: booleanValue == null && nullToAbsent
          ? const Value.absent()
          : Value(booleanValue),
      dateValue: dateValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValue),
      timeValue: timeValue == null && nullToAbsent
          ? const Value.absent()
          : Value(timeValue),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      jsonValue: jsonValue == null && nullToAbsent
          ? const Value.absent()
          : Value(jsonValue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      groupItemId: groupItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupItemId),
    );
  }

  factory LogValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogValueRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      logId: serializer.fromJson<int>(json['log_id']),
      fieldId: serializer.fromJson<int>(json['field_id']),
      textValue: serializer.fromJson<String?>(json['text_value']),
      numberValue: serializer.fromJson<double?>(json['number_value']),
      unitCode: serializer.fromJson<String?>(json['unit_code']),
      normalizedValue: serializer.fromJson<double?>(json['normalized_value']),
      booleanValue: serializer.fromJson<int?>(json['boolean_value']),
      dateValue: serializer.fromJson<String?>(json['date_value']),
      timeValue: serializer.fromJson<int?>(json['time_value']),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      jsonValue: serializer.fromJson<String?>(json['json_value']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      groupItemId: serializer.fromJson<int?>(json['group_item_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'log_id': serializer.toJson<int>(logId),
      'field_id': serializer.toJson<int>(fieldId),
      'text_value': serializer.toJson<String?>(textValue),
      'number_value': serializer.toJson<double?>(numberValue),
      'unit_code': serializer.toJson<String?>(unitCode),
      'normalized_value': serializer.toJson<double?>(normalizedValue),
      'boolean_value': serializer.toJson<int?>(booleanValue),
      'date_value': serializer.toJson<String?>(dateValue),
      'time_value': serializer.toJson<int?>(timeValue),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'json_value': serializer.toJson<String?>(jsonValue),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'group_item_id': serializer.toJson<int?>(groupItemId),
    };
  }

  LogValueRow copyWith({
    int? internalId,
    int? logId,
    int? fieldId,
    Value<String?> textValue = const Value.absent(),
    Value<double?> numberValue = const Value.absent(),
    Value<String?> unitCode = const Value.absent(),
    Value<double?> normalizedValue = const Value.absent(),
    Value<int?> booleanValue = const Value.absent(),
    Value<String?> dateValue = const Value.absent(),
    Value<int?> timeValue = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> jsonValue = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> groupItemId = const Value.absent(),
  }) => LogValueRow(
    internalId: internalId ?? this.internalId,
    logId: logId ?? this.logId,
    fieldId: fieldId ?? this.fieldId,
    textValue: textValue.present ? textValue.value : this.textValue,
    numberValue: numberValue.present ? numberValue.value : this.numberValue,
    unitCode: unitCode.present ? unitCode.value : this.unitCode,
    normalizedValue: normalizedValue.present
        ? normalizedValue.value
        : this.normalizedValue,
    booleanValue: booleanValue.present ? booleanValue.value : this.booleanValue,
    dateValue: dateValue.present ? dateValue.value : this.dateValue,
    timeValue: timeValue.present ? timeValue.value : this.timeValue,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    jsonValue: jsonValue.present ? jsonValue.value : this.jsonValue,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    groupItemId: groupItemId.present ? groupItemId.value : this.groupItemId,
  );
  LogValueRow copyWithCompanion(LogValuesCompanion data) {
    return LogValueRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      logId: data.logId.present ? data.logId.value : this.logId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      numberValue: data.numberValue.present
          ? data.numberValue.value
          : this.numberValue,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      normalizedValue: data.normalizedValue.present
          ? data.normalizedValue.value
          : this.normalizedValue,
      booleanValue: data.booleanValue.present
          ? data.booleanValue.value
          : this.booleanValue,
      dateValue: data.dateValue.present ? data.dateValue.value : this.dateValue,
      timeValue: data.timeValue.present ? data.timeValue.value : this.timeValue,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      jsonValue: data.jsonValue.present ? data.jsonValue.value : this.jsonValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      groupItemId: data.groupItemId.present
          ? data.groupItemId.value
          : this.groupItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogValueRow(')
          ..write('internalId: $internalId, ')
          ..write('logId: $logId, ')
          ..write('fieldId: $fieldId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('unitCode: $unitCode, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('timeValue: $timeValue, ')
          ..write('durationMs: $durationMs, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupItemId: $groupItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    logId,
    fieldId,
    textValue,
    numberValue,
    unitCode,
    normalizedValue,
    booleanValue,
    dateValue,
    timeValue,
    durationMs,
    jsonValue,
    createdAt,
    updatedAt,
    groupItemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogValueRow &&
          other.internalId == this.internalId &&
          other.logId == this.logId &&
          other.fieldId == this.fieldId &&
          other.textValue == this.textValue &&
          other.numberValue == this.numberValue &&
          other.unitCode == this.unitCode &&
          other.normalizedValue == this.normalizedValue &&
          other.booleanValue == this.booleanValue &&
          other.dateValue == this.dateValue &&
          other.timeValue == this.timeValue &&
          other.durationMs == this.durationMs &&
          other.jsonValue == this.jsonValue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.groupItemId == this.groupItemId);
}

class LogValuesCompanion extends UpdateCompanion<LogValueRow> {
  final Value<int> internalId;
  final Value<int> logId;
  final Value<int> fieldId;
  final Value<String?> textValue;
  final Value<double?> numberValue;
  final Value<String?> unitCode;
  final Value<double?> normalizedValue;
  final Value<int?> booleanValue;
  final Value<String?> dateValue;
  final Value<int?> timeValue;
  final Value<int?> durationMs;
  final Value<String?> jsonValue;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> groupItemId;
  const LogValuesCompanion({
    this.internalId = const Value.absent(),
    this.logId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    this.timeValue = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupItemId = const Value.absent(),
  });
  LogValuesCompanion.insert({
    this.internalId = const Value.absent(),
    required int logId,
    required int fieldId,
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    this.timeValue = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.jsonValue = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.groupItemId = const Value.absent(),
  }) : logId = Value(logId),
       fieldId = Value(fieldId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LogValueRow> custom({
    Expression<int>? internalId,
    Expression<int>? logId,
    Expression<int>? fieldId,
    Expression<String>? textValue,
    Expression<double>? numberValue,
    Expression<String>? unitCode,
    Expression<double>? normalizedValue,
    Expression<int>? booleanValue,
    Expression<String>? dateValue,
    Expression<int>? timeValue,
    Expression<int>? durationMs,
    Expression<String>? jsonValue,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? groupItemId,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (logId != null) 'log_id': logId,
      if (fieldId != null) 'field_id': fieldId,
      if (textValue != null) 'text_value': textValue,
      if (numberValue != null) 'number_value': numberValue,
      if (unitCode != null) 'unit_code': unitCode,
      if (normalizedValue != null) 'normalized_value': normalizedValue,
      if (booleanValue != null) 'boolean_value': booleanValue,
      if (dateValue != null) 'date_value': dateValue,
      if (timeValue != null) 'time_value': timeValue,
      if (durationMs != null) 'duration_ms': durationMs,
      if (jsonValue != null) 'json_value': jsonValue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (groupItemId != null) 'group_item_id': groupItemId,
    });
  }

  LogValuesCompanion copyWith({
    Value<int>? internalId,
    Value<int>? logId,
    Value<int>? fieldId,
    Value<String?>? textValue,
    Value<double?>? numberValue,
    Value<String?>? unitCode,
    Value<double?>? normalizedValue,
    Value<int?>? booleanValue,
    Value<String?>? dateValue,
    Value<int?>? timeValue,
    Value<int?>? durationMs,
    Value<String?>? jsonValue,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? groupItemId,
  }) {
    return LogValuesCompanion(
      internalId: internalId ?? this.internalId,
      logId: logId ?? this.logId,
      fieldId: fieldId ?? this.fieldId,
      textValue: textValue ?? this.textValue,
      numberValue: numberValue ?? this.numberValue,
      unitCode: unitCode ?? this.unitCode,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      booleanValue: booleanValue ?? this.booleanValue,
      dateValue: dateValue ?? this.dateValue,
      timeValue: timeValue ?? this.timeValue,
      durationMs: durationMs ?? this.durationMs,
      jsonValue: jsonValue ?? this.jsonValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupItemId: groupItemId ?? this.groupItemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<int>(logId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<int>(fieldId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (numberValue.present) {
      map['number_value'] = Variable<double>(numberValue.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (normalizedValue.present) {
      map['normalized_value'] = Variable<double>(normalizedValue.value);
    }
    if (booleanValue.present) {
      map['boolean_value'] = Variable<int>(booleanValue.value);
    }
    if (dateValue.present) {
      map['date_value'] = Variable<String>(dateValue.value);
    }
    if (timeValue.present) {
      map['time_value'] = Variable<int>(timeValue.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (jsonValue.present) {
      map['json_value'] = Variable<String>(jsonValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (groupItemId.present) {
      map['group_item_id'] = Variable<int>(groupItemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogValuesCompanion(')
          ..write('internalId: $internalId, ')
          ..write('logId: $logId, ')
          ..write('fieldId: $fieldId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('unitCode: $unitCode, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('timeValue: $timeValue, ')
          ..write('durationMs: $durationMs, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupItemId: $groupItemId')
          ..write(')'))
        .toString();
  }
}

class FocusSessions extends Table
    with TableInfo<FocusSessions, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FocusSessions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _activityTypeIdMeta = const VerificationMeta(
    'activityTypeId',
  );
  late final GeneratedColumn<int> activityTypeId = GeneratedColumn<int>(
    'activity_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES activity_types(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES plans(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _activityLogIdMeta = const VerificationMeta(
    'activityLogId',
  );
  late final GeneratedColumn<int> activityLogId = GeneratedColumn<int>(
    'activity_log_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES activity_logs(internal_id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (state IN (\'running\', \'paused\', \'finished\', \'discarded\'))',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  late final GeneratedColumn<int> pausedAt = GeneratedColumn<int>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pausedDurationMsMeta = const VerificationMeta(
    'pausedDurationMs',
  );
  late final GeneratedColumn<int> pausedDurationMs = GeneratedColumn<int>(
    'paused_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (paused_duration_ms >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (duration_ms IS NULL OR duration_ms >= 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    activityTypeId,
    planId,
    activityLogId,
    state,
    startedAt,
    pausedAt,
    pausedDurationMs,
    endedAt,
    durationMs,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('activity_type_id')) {
      context.handle(
        _activityTypeIdMeta,
        activityTypeId.isAcceptableOrUnknown(
          data['activity_type_id']!,
          _activityTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeIdMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('activity_log_id')) {
      context.handle(
        _activityLogIdMeta,
        activityLogId.isAcceptableOrUnknown(
          data['activity_log_id']!,
          _activityLogIdMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('paused_duration_ms')) {
      context.handle(
        _pausedDurationMsMeta,
        pausedDurationMs.isAcceptableOrUnknown(
          data['paused_duration_ms']!,
          _pausedDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      activityTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_type_id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      activityLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_log_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at'],
      ),
      pausedDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_duration_ms'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  FocusSessions createAlias(String alias) {
    return FocusSessions(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK((state = \'paused\')=(paused_at IS NOT NULL))',
    'CHECK((state = \'finished\')=(activity_log_id IS NOT NULL AND ended_at IS NOT NULL AND duration_ms IS NOT NULL))',
    'CHECK(ended_at IS NULL OR ended_at >= started_at)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final int internalId;
  final String publicId;
  final int activityTypeId;
  final int? planId;
  final int? activityLogId;
  final String state;
  final int startedAt;
  final int? pausedAt;
  final int pausedDurationMs;
  final int? endedAt;
  final int? durationMs;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const FocusSessionRow({
    required this.internalId,
    required this.publicId,
    required this.activityTypeId,
    this.planId,
    this.activityLogId,
    required this.state,
    required this.startedAt,
    this.pausedAt,
    required this.pausedDurationMs,
    this.endedAt,
    this.durationMs,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['activity_type_id'] = Variable<int>(activityTypeId);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    if (!nullToAbsent || activityLogId != null) {
      map['activity_log_id'] = Variable<int>(activityLogId);
    }
    map['state'] = Variable<String>(state);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<int>(pausedAt);
    }
    map['paused_duration_ms'] = Variable<int>(pausedDurationMs);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      activityTypeId: Value(activityTypeId),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      activityLogId: activityLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLogId),
      state: Value(state),
      startedAt: Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      pausedDurationMs: Value(pausedDurationMs),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      activityTypeId: serializer.fromJson<int>(json['activity_type_id']),
      planId: serializer.fromJson<int?>(json['plan_id']),
      activityLogId: serializer.fromJson<int?>(json['activity_log_id']),
      state: serializer.fromJson<String>(json['state']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      pausedAt: serializer.fromJson<int?>(json['paused_at']),
      pausedDurationMs: serializer.fromJson<int>(json['paused_duration_ms']),
      endedAt: serializer.fromJson<int?>(json['ended_at']),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'activity_type_id': serializer.toJson<int>(activityTypeId),
      'plan_id': serializer.toJson<int?>(planId),
      'activity_log_id': serializer.toJson<int?>(activityLogId),
      'state': serializer.toJson<String>(state),
      'started_at': serializer.toJson<int>(startedAt),
      'paused_at': serializer.toJson<int?>(pausedAt),
      'paused_duration_ms': serializer.toJson<int>(pausedDurationMs),
      'ended_at': serializer.toJson<int?>(endedAt),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
    };
  }

  FocusSessionRow copyWith({
    int? internalId,
    String? publicId,
    int? activityTypeId,
    Value<int?> planId = const Value.absent(),
    Value<int?> activityLogId = const Value.absent(),
    String? state,
    int? startedAt,
    Value<int?> pausedAt = const Value.absent(),
    int? pausedDurationMs,
    Value<int?> endedAt = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => FocusSessionRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    activityTypeId: activityTypeId ?? this.activityTypeId,
    planId: planId.present ? planId.value : this.planId,
    activityLogId: activityLogId.present
        ? activityLogId.value
        : this.activityLogId,
    state: state ?? this.state,
    startedAt: startedAt ?? this.startedAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    pausedDurationMs: pausedDurationMs ?? this.pausedDurationMs,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      activityTypeId: data.activityTypeId.present
          ? data.activityTypeId.value
          : this.activityTypeId,
      planId: data.planId.present ? data.planId.value : this.planId,
      activityLogId: data.activityLogId.present
          ? data.activityLogId.value
          : this.activityLogId,
      state: data.state.present ? data.state.value : this.state,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      pausedDurationMs: data.pausedDurationMs.present
          ? data.pausedDurationMs.value
          : this.pausedDurationMs,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('planId: $planId, ')
          ..write('activityLogId: $activityLogId, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('pausedDurationMs: $pausedDurationMs, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    activityTypeId,
    planId,
    activityLogId,
    state,
    startedAt,
    pausedAt,
    pausedDurationMs,
    endedAt,
    durationMs,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.activityTypeId == this.activityTypeId &&
          other.planId == this.planId &&
          other.activityLogId == this.activityLogId &&
          other.state == this.state &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.pausedDurationMs == this.pausedDurationMs &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int> activityTypeId;
  final Value<int?> planId;
  final Value<int?> activityLogId;
  final Value<String> state;
  final Value<int> startedAt;
  final Value<int?> pausedAt;
  final Value<int> pausedDurationMs;
  final Value<int?> endedAt;
  final Value<int?> durationMs;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  const FocusSessionsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.activityTypeId = const Value.absent(),
    this.planId = const Value.absent(),
    this.activityLogId = const Value.absent(),
    this.state = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.pausedDurationMs = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required int activityTypeId,
    this.planId = const Value.absent(),
    this.activityLogId = const Value.absent(),
    required String state,
    required int startedAt,
    this.pausedAt = const Value.absent(),
    this.pausedDurationMs = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
  }) : publicId = Value(publicId),
       activityTypeId = Value(activityTypeId),
       state = Value(state),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FocusSessionRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? activityTypeId,
    Expression<int>? planId,
    Expression<int>? activityLogId,
    Expression<String>? state,
    Expression<int>? startedAt,
    Expression<int>? pausedAt,
    Expression<int>? pausedDurationMs,
    Expression<int>? endedAt,
    Expression<int>? durationMs,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (activityTypeId != null) 'activity_type_id': activityTypeId,
      if (planId != null) 'plan_id': planId,
      if (activityLogId != null) 'activity_log_id': activityLogId,
      if (state != null) 'state': state,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (pausedDurationMs != null) 'paused_duration_ms': pausedDurationMs,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int>? activityTypeId,
    Value<int?>? planId,
    Value<int?>? activityLogId,
    Value<String>? state,
    Value<int>? startedAt,
    Value<int?>? pausedAt,
    Value<int>? pausedDurationMs,
    Value<int?>? endedAt,
    Value<int?>? durationMs,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return FocusSessionsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      planId: planId ?? this.planId,
      activityLogId: activityLogId ?? this.activityLogId,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      pausedDurationMs: pausedDurationMs ?? this.pausedDurationMs,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (activityTypeId.present) {
      map['activity_type_id'] = Variable<int>(activityTypeId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (activityLogId.present) {
      map['activity_log_id'] = Variable<int>(activityLogId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<int>(pausedAt.value);
    }
    if (pausedDurationMs.present) {
      map['paused_duration_ms'] = Variable<int>(pausedDurationMs.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('activityTypeId: $activityTypeId, ')
          ..write('planId: $planId, ')
          ..write('activityLogId: $activityLogId, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('pausedDurationMs: $pausedDurationMs, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class Measurements extends Table with TableInfo<Measurements, MeasurementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Measurements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _measurementTypeMeta = const VerificationMeta(
    'measurementType',
  );
  late final GeneratedColumn<String> measurementType = GeneratedColumn<String>(
    'measurement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(measurement_type) > 0)',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _normalizedValueMeta = const VerificationMeta(
    'normalizedValue',
  );
  late final GeneratedColumn<double> normalizedValue = GeneratedColumn<double>(
    'normalized_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tzOffsetMinutesMeta = const VerificationMeta(
    'tzOffsetMinutes',
  );
  late final GeneratedColumn<int> tzOffsetMinutes = GeneratedColumn<int>(
    'tz_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tz_offset_minutes BETWEEN -1080 AND 1080)',
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (local_date GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\')',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    measurementType,
    value,
    unitCode,
    normalizedValue,
    recordedAt,
    tzOffsetMinutes,
    localDate,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('measurement_type')) {
      context.handle(
        _measurementTypeMeta,
        measurementType.isAcceptableOrUnknown(
          data['measurement_type']!,
          _measurementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measurementTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('normalized_value')) {
      context.handle(
        _normalizedValueMeta,
        normalizedValue.isAcceptableOrUnknown(
          data['normalized_value']!,
          _normalizedValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedValueMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('tz_offset_minutes')) {
      context.handle(
        _tzOffsetMinutesMeta,
        tzOffsetMinutes.isAcceptableOrUnknown(
          data['tz_offset_minutes']!,
          _tzOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tzOffsetMinutesMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  MeasurementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      measurementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      normalizedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_value'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      tzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_minutes'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  Measurements createAlias(String alias) {
    return Measurements(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class MeasurementRow extends DataClass implements Insertable<MeasurementRow> {
  final int internalId;
  final String publicId;
  final String measurementType;
  final double value;
  final String unitCode;
  final double normalizedValue;
  final int recordedAt;
  final int tzOffsetMinutes;
  final String localDate;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const MeasurementRow({
    required this.internalId,
    required this.publicId,
    required this.measurementType,
    required this.value,
    required this.unitCode,
    required this.normalizedValue,
    required this.recordedAt,
    required this.tzOffsetMinutes,
    required this.localDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['measurement_type'] = Variable<String>(measurementType);
    map['value'] = Variable<double>(value);
    map['unit_code'] = Variable<String>(unitCode);
    map['normalized_value'] = Variable<double>(normalizedValue);
    map['recorded_at'] = Variable<int>(recordedAt);
    map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      measurementType: Value(measurementType),
      value: Value(value),
      unitCode: Value(unitCode),
      normalizedValue: Value(normalizedValue),
      recordedAt: Value(recordedAt),
      tzOffsetMinutes: Value(tzOffsetMinutes),
      localDate: Value(localDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MeasurementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      measurementType: serializer.fromJson<String>(json['measurement_type']),
      value: serializer.fromJson<double>(json['value']),
      unitCode: serializer.fromJson<String>(json['unit_code']),
      normalizedValue: serializer.fromJson<double>(json['normalized_value']),
      recordedAt: serializer.fromJson<int>(json['recorded_at']),
      tzOffsetMinutes: serializer.fromJson<int>(json['tz_offset_minutes']),
      localDate: serializer.fromJson<String>(json['local_date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'measurement_type': serializer.toJson<String>(measurementType),
      'value': serializer.toJson<double>(value),
      'unit_code': serializer.toJson<String>(unitCode),
      'normalized_value': serializer.toJson<double>(normalizedValue),
      'recorded_at': serializer.toJson<int>(recordedAt),
      'tz_offset_minutes': serializer.toJson<int>(tzOffsetMinutes),
      'local_date': serializer.toJson<String>(localDate),
      'notes': serializer.toJson<String?>(notes),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
    };
  }

  MeasurementRow copyWith({
    int? internalId,
    String? publicId,
    String? measurementType,
    double? value,
    String? unitCode,
    double? normalizedValue,
    int? recordedAt,
    int? tzOffsetMinutes,
    String? localDate,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => MeasurementRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    measurementType: measurementType ?? this.measurementType,
    value: value ?? this.value,
    unitCode: unitCode ?? this.unitCode,
    normalizedValue: normalizedValue ?? this.normalizedValue,
    recordedAt: recordedAt ?? this.recordedAt,
    tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
    localDate: localDate ?? this.localDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MeasurementRow copyWithCompanion(MeasurementsCompanion data) {
    return MeasurementRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      measurementType: data.measurementType.present
          ? data.measurementType.value
          : this.measurementType,
      value: data.value.present ? data.value.value : this.value,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      normalizedValue: data.normalizedValue.present
          ? data.normalizedValue.value
          : this.normalizedValue,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      tzOffsetMinutes: data.tzOffsetMinutes.present
          ? data.tzOffsetMinutes.value
          : this.tzOffsetMinutes,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('measurementType: $measurementType, ')
          ..write('value: $value, ')
          ..write('unitCode: $unitCode, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    measurementType,
    value,
    unitCode,
    normalizedValue,
    recordedAt,
    tzOffsetMinutes,
    localDate,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.measurementType == this.measurementType &&
          other.value == this.value &&
          other.unitCode == this.unitCode &&
          other.normalizedValue == this.normalizedValue &&
          other.recordedAt == this.recordedAt &&
          other.tzOffsetMinutes == this.tzOffsetMinutes &&
          other.localDate == this.localDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class MeasurementsCompanion extends UpdateCompanion<MeasurementRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<String> measurementType;
  final Value<double> value;
  final Value<String> unitCode;
  final Value<double> normalizedValue;
  final Value<int> recordedAt;
  final Value<int> tzOffsetMinutes;
  final Value<String> localDate;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  const MeasurementsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.measurementType = const Value.absent(),
    this.value = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.tzOffsetMinutes = const Value.absent(),
    this.localDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    required String measurementType,
    required double value,
    required String unitCode,
    required double normalizedValue,
    required int recordedAt,
    required int tzOffsetMinutes,
    required String localDate,
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
  }) : publicId = Value(publicId),
       measurementType = Value(measurementType),
       value = Value(value),
       unitCode = Value(unitCode),
       normalizedValue = Value(normalizedValue),
       recordedAt = Value(recordedAt),
       tzOffsetMinutes = Value(tzOffsetMinutes),
       localDate = Value(localDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MeasurementRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<String>? measurementType,
    Expression<double>? value,
    Expression<String>? unitCode,
    Expression<double>? normalizedValue,
    Expression<int>? recordedAt,
    Expression<int>? tzOffsetMinutes,
    Expression<String>? localDate,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (measurementType != null) 'measurement_type': measurementType,
      if (value != null) 'value': value,
      if (unitCode != null) 'unit_code': unitCode,
      if (normalizedValue != null) 'normalized_value': normalizedValue,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (tzOffsetMinutes != null) 'tz_offset_minutes': tzOffsetMinutes,
      if (localDate != null) 'local_date': localDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  MeasurementsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<String>? measurementType,
    Value<double>? value,
    Value<String>? unitCode,
    Value<double>? normalizedValue,
    Value<int>? recordedAt,
    Value<int>? tzOffsetMinutes,
    Value<String>? localDate,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return MeasurementsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      measurementType: measurementType ?? this.measurementType,
      value: value ?? this.value,
      unitCode: unitCode ?? this.unitCode,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      recordedAt: recordedAt ?? this.recordedAt,
      tzOffsetMinutes: tzOffsetMinutes ?? this.tzOffsetMinutes,
      localDate: localDate ?? this.localDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (measurementType.present) {
      map['measurement_type'] = Variable<String>(measurementType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (normalizedValue.present) {
      map['normalized_value'] = Variable<double>(normalizedValue.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (tzOffsetMinutes.present) {
      map['tz_offset_minutes'] = Variable<int>(tzOffsetMinutes.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('measurementType: $measurementType, ')
          ..write('value: $value, ')
          ..write('unitCode: $unitCode, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('tzOffsetMinutes: $tzOffsetMinutes, ')
          ..write('localDate: $localDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class InsightCharts extends Table
    with TableInfo<InsightCharts, InsightChartRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  InsightCharts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  late final GeneratedColumn<int> internalId = GeneratedColumn<int>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (length(public_id) = 36)',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (position >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(config_json))',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    publicId,
    position,
    configJson,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insight_charts';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsightChartRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  InsightChartRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsightChartRow(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_id'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  InsightCharts createAlias(String alias) {
    return InsightCharts(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class InsightChartRow extends DataClass implements Insertable<InsightChartRow> {
  final int internalId;
  final String publicId;
  final int position;
  final String configJson;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const InsightChartRow({
    required this.internalId,
    required this.publicId,
    required this.position,
    required this.configJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<int>(internalId);
    map['public_id'] = Variable<String>(publicId);
    map['position'] = Variable<int>(position);
    map['config_json'] = Variable<String>(configJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  InsightChartsCompanion toCompanion(bool nullToAbsent) {
    return InsightChartsCompanion(
      internalId: Value(internalId),
      publicId: Value(publicId),
      position: Value(position),
      configJson: Value(configJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InsightChartRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsightChartRow(
      internalId: serializer.fromJson<int>(json['internal_id']),
      publicId: serializer.fromJson<String>(json['public_id']),
      position: serializer.fromJson<int>(json['position']),
      configJson: serializer.fromJson<String>(json['config_json']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internal_id': serializer.toJson<int>(internalId),
      'public_id': serializer.toJson<String>(publicId),
      'position': serializer.toJson<int>(position),
      'config_json': serializer.toJson<String>(configJson),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
    };
  }

  InsightChartRow copyWith({
    int? internalId,
    String? publicId,
    int? position,
    String? configJson,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => InsightChartRow(
    internalId: internalId ?? this.internalId,
    publicId: publicId ?? this.publicId,
    position: position ?? this.position,
    configJson: configJson ?? this.configJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InsightChartRow copyWithCompanion(InsightChartsCompanion data) {
    return InsightChartRow(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      position: data.position.present ? data.position.value : this.position,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsightChartRow(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('position: $position, ')
          ..write('configJson: $configJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    publicId,
    position,
    configJson,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsightChartRow &&
          other.internalId == this.internalId &&
          other.publicId == this.publicId &&
          other.position == this.position &&
          other.configJson == this.configJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InsightChartsCompanion extends UpdateCompanion<InsightChartRow> {
  final Value<int> internalId;
  final Value<String> publicId;
  final Value<int> position;
  final Value<String> configJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  const InsightChartsCompanion({
    this.internalId = const Value.absent(),
    this.publicId = const Value.absent(),
    this.position = const Value.absent(),
    this.configJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  InsightChartsCompanion.insert({
    this.internalId = const Value.absent(),
    required String publicId,
    this.position = const Value.absent(),
    required String configJson,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
  }) : publicId = Value(publicId),
       configJson = Value(configJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InsightChartRow> custom({
    Expression<int>? internalId,
    Expression<String>? publicId,
    Expression<int>? position,
    Expression<String>? configJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (publicId != null) 'public_id': publicId,
      if (position != null) 'position': position,
      if (configJson != null) 'config_json': configJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  InsightChartsCompanion copyWith({
    Value<int>? internalId,
    Value<String>? publicId,
    Value<int>? position,
    Value<String>? configJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
  }) {
    return InsightChartsCompanion(
      internalId: internalId ?? this.internalId,
      publicId: publicId ?? this.publicId,
      position: position ?? this.position,
      configJson: configJson ?? this.configJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<int>(internalId.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightChartsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('publicId: $publicId, ')
          ..write('position: $position, ')
          ..write('configJson: $configJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String valueJson;

  /// UTC epoch milliseconds (ADR-013).
  final int updatedAt;
  const AppPreferenceRow({
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppPreferenceRow copyWith({String? key, String? valueJson, int? updatedAt}) =>
      AppPreferenceRow(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String valueJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final ActivityTypes activityTypes = ActivityTypes(this);
  late final ActivityFields activityFields = ActivityFields(this);
  late final Index idxActivityFieldsTypePosition = Index(
    'idx_activity_fields_type_position',
    'CREATE INDEX idx_activity_fields_type_position ON activity_fields (activity_type_id, position)',
  );
  late final Index idxActivityFieldsParent = Index(
    'idx_activity_fields_parent',
    'CREATE INDEX idx_activity_fields_parent ON activity_fields (parent_field_id) WHERE parent_field_id IS NOT NULL',
  );
  late final PlanSeries planSeries = PlanSeries(this);
  late final Plans plans = Plans(this);
  late final Index uxPlansSeriesDate = Index(
    'ux_plans_series_date',
    'CREATE UNIQUE INDEX ux_plans_series_date ON plans (series_id, plan_date) WHERE series_id IS NOT NULL',
  );
  late final Index idxPlansDay = Index(
    'idx_plans_day',
    'CREATE INDEX idx_plans_day ON plans (plan_date, sort_order) WHERE deleted_at IS NULL',
  );
  late final Index idxPlansTypeDay = Index(
    'idx_plans_type_day',
    'CREATE INDEX idx_plans_type_day ON plans (activity_type_id, plan_date) WHERE deleted_at IS NULL AND activity_type_id IS NOT NULL',
  );
  late final ActivityLogs activityLogs = ActivityLogs(this);
  late final Index idxActivityLogsDay = Index(
    'idx_activity_logs_day',
    'CREATE INDEX idx_activity_logs_day ON activity_logs (local_date, started_at) WHERE deleted_at IS NULL',
  );
  late final Index idxActivityLogsTypeDay = Index(
    'idx_activity_logs_type_day',
    'CREATE INDEX idx_activity_logs_type_day ON activity_logs (activity_type_id, local_date, started_at) WHERE deleted_at IS NULL',
  );
  late final Index idxActivityLogsPlan = Index(
    'idx_activity_logs_plan',
    'CREATE INDEX idx_activity_logs_plan ON activity_logs (plan_id) WHERE plan_id IS NOT NULL',
  );
  late final LogGroupItems logGroupItems = LogGroupItems(this);
  late final Index idxLogGroupItemsLog = Index(
    'idx_log_group_items_log',
    'CREATE INDEX idx_log_group_items_log ON log_group_items (log_id, parent_item_id, position)',
  );
  late final LogValues logValues = LogValues(this);
  late final Index idxLogValuesLog = Index(
    'idx_log_values_log',
    'CREATE INDEX idx_log_values_log ON log_values (log_id, field_id)',
  );
  late final Index uxLogValuesTopLevel = Index(
    'ux_log_values_top_level',
    'CREATE UNIQUE INDEX ux_log_values_top_level ON log_values (log_id, field_id) WHERE group_item_id IS NULL',
  );
  late final Index uxLogValuesItem = Index(
    'ux_log_values_item',
    'CREATE UNIQUE INDEX ux_log_values_item ON log_values (group_item_id, field_id) WHERE group_item_id IS NOT NULL',
  );
  late final Index idxLogValuesFieldNormalized = Index(
    'idx_log_values_field_normalized',
    'CREATE INDEX idx_log_values_field_normalized ON log_values (field_id, normalized_value)',
  );
  late final Trigger trgLogValuesInsertCheck = Trigger(
    'CREATE TRIGGER trg_log_values_insert_check BEFORE INSERT ON log_values BEGIN SELECT RAISE (ABORT, \'log_value_field_not_in_log_type\') WHERE (SELECT activity_type_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT activity_type_id FROM activity_logs WHERE internal_id = NEW.log_id);SELECT RAISE (ABORT, \'log_value_scope_mismatch\') WHERE (SELECT parent_field_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT field_id FROM log_group_items WHERE internal_id = NEW.group_item_id) OR(NEW.group_item_id IS NOT NULL AND (SELECT log_id FROM log_group_items WHERE internal_id = NEW.group_item_id) IS NOT NEW.log_id);SELECT RAISE (ABORT, \'log_value_column_mismatch\') WHERE NOT COALESCE((SELECT CASE f.field_type WHEN \'text\' THEN NEW.text_value IS NOT NULL WHEN \'single_select\' THEN NEW.text_value IS NOT NULL WHEN \'number\' THEN NEW.number_value IS NOT NULL AND((NEW.unit_code IS NULL)=(f.dimension IS NULL))WHEN \'rating\' THEN NEW.number_value IS NOT NULL AND NEW.unit_code IS NULL WHEN \'boolean\' THEN NEW.boolean_value IS NOT NULL WHEN \'date\' THEN NEW.date_value IS NOT NULL WHEN \'time\' THEN NEW.time_value IS NOT NULL WHEN \'duration\' THEN NEW.duration_ms IS NOT NULL WHEN \'multi_select\' THEN NEW.json_value IS NOT NULL ELSE 0 END FROM activity_fields AS f WHERE f.internal_id = NEW.field_id), 0);END',
    'trg_log_values_insert_check',
  );
  late final Trigger trgLogValuesUpdateCheck = Trigger(
    'CREATE TRIGGER trg_log_values_update_check BEFORE UPDATE ON log_values BEGIN SELECT RAISE (ABORT, \'log_value_field_not_in_log_type\') WHERE (SELECT activity_type_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT activity_type_id FROM activity_logs WHERE internal_id = NEW.log_id);SELECT RAISE (ABORT, \'log_value_scope_mismatch\') WHERE (SELECT parent_field_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT field_id FROM log_group_items WHERE internal_id = NEW.group_item_id) OR(NEW.group_item_id IS NOT NULL AND (SELECT log_id FROM log_group_items WHERE internal_id = NEW.group_item_id) IS NOT NEW.log_id);SELECT RAISE (ABORT, \'log_value_column_mismatch\') WHERE NOT COALESCE((SELECT CASE f.field_type WHEN \'text\' THEN NEW.text_value IS NOT NULL WHEN \'single_select\' THEN NEW.text_value IS NOT NULL WHEN \'number\' THEN NEW.number_value IS NOT NULL AND((NEW.unit_code IS NULL)=(f.dimension IS NULL))WHEN \'rating\' THEN NEW.number_value IS NOT NULL AND NEW.unit_code IS NULL WHEN \'boolean\' THEN NEW.boolean_value IS NOT NULL WHEN \'date\' THEN NEW.date_value IS NOT NULL WHEN \'time\' THEN NEW.time_value IS NOT NULL WHEN \'duration\' THEN NEW.duration_ms IS NOT NULL WHEN \'multi_select\' THEN NEW.json_value IS NOT NULL ELSE 0 END FROM activity_fields AS f WHERE f.internal_id = NEW.field_id), 0);END',
    'trg_log_values_update_check',
  );
  late final Trigger trgActivityFieldsSemanticsLocked = Trigger(
    'CREATE TRIGGER trg_activity_fields_semantics_locked BEFORE UPDATE OF field_type, dimension ON activity_fields WHEN(OLD.field_type IS NOT NEW.field_type OR OLD.dimension IS NOT NEW.dimension)AND(EXISTS (SELECT 1 FROM log_values WHERE field_id = OLD.internal_id) OR EXISTS (SELECT 1 FROM log_group_items WHERE field_id = OLD.internal_id) OR EXISTS (SELECT 1 FROM activity_fields AS c WHERE c.parent_field_id = OLD.internal_id))BEGIN SELECT RAISE (ABORT, \'activity_field_semantics_locked\');END',
    'trg_activity_fields_semantics_locked',
  );
  late final Trigger trgActivityFieldsOwnerImmutable = Trigger(
    'CREATE TRIGGER trg_activity_fields_owner_immutable BEFORE UPDATE OF activity_type_id ON activity_fields WHEN OLD.activity_type_id IS NOT NEW.activity_type_id BEGIN SELECT RAISE (ABORT, \'activity_field_owner_immutable\');END',
    'trg_activity_fields_owner_immutable',
  );
  late final Trigger trgActivityLogsTypeImmutable = Trigger(
    'CREATE TRIGGER trg_activity_logs_type_immutable BEFORE UPDATE OF activity_type_id ON activity_logs WHEN OLD.activity_type_id IS NOT NEW.activity_type_id BEGIN SELECT RAISE (ABORT, \'activity_log_type_immutable\');END',
    'trg_activity_logs_type_immutable',
  );
  late final Trigger trgActivityTypesPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_activity_types_public_id_immutable BEFORE UPDATE OF public_id ON activity_types WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_activity_types_public_id_immutable',
  );
  late final Trigger trgActivityFieldsPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_activity_fields_public_id_immutable BEFORE UPDATE OF public_id ON activity_fields WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_activity_fields_public_id_immutable',
  );
  late final Trigger trgActivityLogsPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_activity_logs_public_id_immutable BEFORE UPDATE OF public_id ON activity_logs WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_activity_logs_public_id_immutable',
  );
  late final Trigger trgActivityFieldsParentCheck = Trigger(
    'CREATE TRIGGER trg_activity_fields_parent_check BEFORE INSERT ON activity_fields WHEN NEW.parent_field_id IS NOT NULL BEGIN SELECT RAISE (ABORT, \'activity_field_parent_invalid\') WHERE COALESCE((SELECT p.field_type = \'repeating_group\' AND p.activity_type_id = NEW.activity_type_id AND(p.parent_field_id IS NULL OR NEW.field_type <> \'repeating_group\')FROM activity_fields AS p WHERE p.internal_id = NEW.parent_field_id), 0) = 0;END',
    'trg_activity_fields_parent_check',
  );
  late final Trigger trgActivityFieldsParentImmutable = Trigger(
    'CREATE TRIGGER trg_activity_fields_parent_immutable BEFORE UPDATE OF parent_field_id ON activity_fields WHEN OLD.parent_field_id IS NOT NEW.parent_field_id BEGIN SELECT RAISE (ABORT, \'activity_field_parent_immutable\');END',
    'trg_activity_fields_parent_immutable',
  );
  late final Trigger trgLogGroupItemsInsertCheck = Trigger(
    'CREATE TRIGGER trg_log_group_items_insert_check BEFORE INSERT ON log_group_items BEGIN SELECT RAISE (ABORT, \'group_item_field_invalid\') WHERE COALESCE((SELECT f.field_type = \'repeating_group\' AND f.activity_type_id = (SELECT activity_type_id FROM activity_logs WHERE internal_id = NEW.log_id) FROM activity_fields AS f WHERE f.internal_id = NEW.field_id), 0) = 0;SELECT RAISE (ABORT, \'group_item_parent_invalid\') WHERE (SELECT parent_field_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT field_id FROM log_group_items WHERE internal_id = NEW.parent_item_id) OR(NEW.parent_item_id IS NOT NULL AND (SELECT log_id FROM log_group_items WHERE internal_id = NEW.parent_item_id) IS NOT NEW.log_id);END',
    'trg_log_group_items_insert_check',
  );
  late final Trigger trgLogGroupItemsStructureImmutable = Trigger(
    'CREATE TRIGGER trg_log_group_items_structure_immutable BEFORE UPDATE OF log_id, field_id, parent_item_id, public_id ON log_group_items WHEN OLD.log_id IS NOT NEW.log_id OR OLD.field_id IS NOT NEW.field_id OR OLD.parent_item_id IS NOT NEW.parent_item_id OR OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'group_item_structure_immutable\');END',
    'trg_log_group_items_structure_immutable',
  );
  late final Trigger trgActivityLogsPlanCheckInsert = Trigger(
    'CREATE TRIGGER trg_activity_logs_plan_check_insert BEFORE INSERT ON activity_logs WHEN NEW.plan_id IS NOT NULL BEGIN SELECT RAISE (ABORT, \'log_plan_mismatch\') WHERE (SELECT activity_type_id FROM plans WHERE internal_id = NEW.plan_id) IS NOT NEW.activity_type_id;END',
    'trg_activity_logs_plan_check_insert',
  );
  late final Trigger trgActivityLogsPlanCheckUpdate = Trigger(
    'CREATE TRIGGER trg_activity_logs_plan_check_update BEFORE UPDATE OF plan_id ON activity_logs WHEN NEW.plan_id IS NOT NULL BEGIN SELECT RAISE (ABORT, \'log_plan_mismatch\') WHERE (SELECT activity_type_id FROM plans WHERE internal_id = NEW.plan_id) IS NOT NEW.activity_type_id;END',
    'trg_activity_logs_plan_check_update',
  );
  late final Trigger trgPlansTypeLocked = Trigger(
    'CREATE TRIGGER trg_plans_type_locked BEFORE UPDATE OF activity_type_id ON plans WHEN OLD.activity_type_id IS NOT NEW.activity_type_id AND EXISTS (SELECT 1 FROM activity_logs WHERE plan_id = OLD.internal_id) BEGIN SELECT RAISE (ABORT, \'plan_type_locked\');END',
    'trg_plans_type_locked',
  );
  late final Trigger trgPlansPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_plans_public_id_immutable BEFORE UPDATE OF public_id ON plans WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_plans_public_id_immutable',
  );
  late final FocusSessions focusSessions = FocusSessions(this);
  late final Index uxFocusSessionsOneActive = Index(
    'ux_focus_sessions_one_active',
    'CREATE UNIQUE INDEX ux_focus_sessions_one_active ON focus_sessions (state IN (\'running\', \'paused\')) WHERE state IN (\'running\', \'paused\') AND deleted_at IS NULL',
  );
  late final Index idxFocusSessionsPlan = Index(
    'idx_focus_sessions_plan',
    'CREATE INDEX idx_focus_sessions_plan ON focus_sessions (plan_id) WHERE plan_id IS NOT NULL',
  );
  late final Trigger trgFocusSessionsPlanCheck = Trigger(
    'CREATE TRIGGER trg_focus_sessions_plan_check BEFORE INSERT ON focus_sessions WHEN NEW.plan_id IS NOT NULL BEGIN SELECT RAISE (ABORT, \'focus_plan_mismatch\') WHERE (SELECT activity_type_id FROM plans WHERE internal_id = NEW.plan_id) IS NOT NEW.activity_type_id;END',
    'trg_focus_sessions_plan_check',
  );
  late final Trigger trgFocusSessionsPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_focus_sessions_public_id_immutable BEFORE UPDATE OF public_id ON focus_sessions WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_focus_sessions_public_id_immutable',
  );
  late final Measurements measurements = Measurements(this);
  late final Index idxMeasurementsTypeDay = Index(
    'idx_measurements_type_day',
    'CREATE INDEX idx_measurements_type_day ON measurements (measurement_type, local_date, recorded_at) WHERE deleted_at IS NULL',
  );
  late final InsightCharts insightCharts = InsightCharts(this);
  late final Trigger trgMeasurementsPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_measurements_public_id_immutable BEFORE UPDATE OF public_id ON measurements WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_measurements_public_id_immutable',
  );
  late final Trigger trgPlanSeriesPublicIdImmutable = Trigger(
    'CREATE TRIGGER trg_plan_series_public_id_immutable BEFORE UPDATE OF public_id ON plan_series WHEN OLD.public_id IS NOT NEW.public_id BEGIN SELECT RAISE (ABORT, \'public_id_immutable\');END',
    'trg_plan_series_public_id_immutable',
  );
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activityTypes,
    activityFields,
    idxActivityFieldsTypePosition,
    idxActivityFieldsParent,
    planSeries,
    plans,
    uxPlansSeriesDate,
    idxPlansDay,
    idxPlansTypeDay,
    activityLogs,
    idxActivityLogsDay,
    idxActivityLogsTypeDay,
    idxActivityLogsPlan,
    logGroupItems,
    idxLogGroupItemsLog,
    logValues,
    idxLogValuesLog,
    uxLogValuesTopLevel,
    uxLogValuesItem,
    idxLogValuesFieldNormalized,
    trgLogValuesInsertCheck,
    trgLogValuesUpdateCheck,
    trgActivityFieldsSemanticsLocked,
    trgActivityFieldsOwnerImmutable,
    trgActivityLogsTypeImmutable,
    trgActivityTypesPublicIdImmutable,
    trgActivityFieldsPublicIdImmutable,
    trgActivityLogsPublicIdImmutable,
    trgActivityFieldsParentCheck,
    trgActivityFieldsParentImmutable,
    trgLogGroupItemsInsertCheck,
    trgLogGroupItemsStructureImmutable,
    trgActivityLogsPlanCheckInsert,
    trgActivityLogsPlanCheckUpdate,
    trgPlansTypeLocked,
    trgPlansPublicIdImmutable,
    focusSessions,
    uxFocusSessionsOneActive,
    idxFocusSessionsPlan,
    trgFocusSessionsPlanCheck,
    trgFocusSessionsPublicIdImmutable,
    measurements,
    idxMeasurementsTypeDay,
    insightCharts,
    trgMeasurementsPublicIdImmutable,
    trgPlanSeriesPublicIdImmutable,
    appPreferences,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_group_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_group_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_group_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_group_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_values',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_values',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_fields',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_fields',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_types',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_fields',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_fields',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_fields',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_group_items',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'log_group_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'focus_sessions',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'focus_sessions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'measurements',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_series',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
  ]);
}

typedef $ActivityTypesCreateCompanionBuilder = ActivityTypesCompanion Function({
  Value<int> internalId,
  required String publicId,
  required String name,
  required String iconId,
  required String colorKey,
  Value<String?> description,
  Value<int> supportsTimer,
  Value<int> supportsPlanning,
  Value<int> sortOrder,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
});
typedef $ActivityTypesUpdateCompanionBuilder = ActivityTypesCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<String> name,
  Value<String> iconId,
  Value<String> colorKey,
  Value<String?> description,
  Value<int> supportsTimer,
  Value<int> supportsPlanning,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
});

final class $ActivityTypesReferences
    extends BaseReferences<_$AppDatabase, ActivityTypes, ActivityTypeRow> {
  $ActivityTypesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<ActivityFields, List<ActivityFieldRow>>
  _activityFieldsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityFields,
    aliasName: 'activity_types__internal_id__activity_fields__activity_type_id',
  );

  $ActivityFieldsProcessedTableManager get activityFieldsRefs {
    final manager = $ActivityFieldsTableManager($_db, $_db.activityFields)
        .filter(
          (f) => f.activityTypeId.internalId.sqlEquals(
            $_itemColumn<int>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_activityFieldsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PlanSeries, List<PlanSeriesRow>>
  _planSeriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planSeries,
    aliasName: 'activity_types__internal_id__plan_series__activity_type_id',
  );

  $PlanSeriesProcessedTableManager get planSeriesRefs {
    final manager = $PlanSeriesTableManager($_db, $_db.planSeries).filter(
      (f) => f.activityTypeId.internalId.sqlEquals(
        $_itemColumn<int>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_planSeriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Plans, List<PlanRow>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: 'activity_types__internal_id__plans__activity_type_id',
  );

  $PlansProcessedTableManager get plansRefs {
    final manager = $PlansTableManager($_db, $_db.plans).filter(
      (f) => f.activityTypeId.internalId.sqlEquals(
        $_itemColumn<int>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ActivityLogs, List<ActivityLogRow>>
  _activityLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityLogs,
    aliasName: 'activity_types__internal_id__activity_logs__activity_type_id',
  );

  $ActivityLogsProcessedTableManager get activityLogsRefs {
    final manager = $ActivityLogsTableManager($_db, $_db.activityLogs).filter(
      (f) => f.activityTypeId.internalId.sqlEquals(
        $_itemColumn<int>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_activityLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FocusSessions, List<FocusSessionRow>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'activity_types__internal_id__focus_sessions__activity_type_id',
  );

  $FocusSessionsProcessedTableManager get focusSessionsRefs {
    final manager = $FocusSessionsTableManager($_db, $_db.focusSessions).filter(
      (f) => f.activityTypeId.internalId.sqlEquals(
        $_itemColumn<int>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ActivityTypesFilterComposer
    extends Composer<_$AppDatabase, ActivityTypes> {
  $ActivityTypesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconId => $composableBuilder(
    column: $table.iconId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supportsTimer => $composableBuilder(
    column: $table.supportsTimer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supportsPlanning => $composableBuilder(
    column: $table.supportsPlanning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activityFieldsRefs(
    Expression<bool> Function($ActivityFieldsFilterComposer f) f,
  ) {
    final $ActivityFieldsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsFilterComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planSeriesRefs(
    Expression<bool> Function($PlanSeriesFilterComposer f) f,
  ) {
    final $PlanSeriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.planSeries,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlanSeriesFilterComposer(
            $db: $db,
            $table: $db.planSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plansRefs(
    Expression<bool> Function($PlansFilterComposer f) f,
  ) {
    final $PlansFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityLogsRefs(
    Expression<bool> Function($ActivityLogsFilterComposer f) f,
  ) {
    final $ActivityLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsFilterComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($FocusSessionsFilterComposer f) f,
  ) {
    final $FocusSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityTypesOrderingComposer
    extends Composer<_$AppDatabase, ActivityTypes> {
  $ActivityTypesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconId => $composableBuilder(
    column: $table.iconId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supportsTimer => $composableBuilder(
    column: $table.supportsTimer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supportsPlanning => $composableBuilder(
    column: $table.supportsPlanning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ActivityTypesAnnotationComposer
    extends Composer<_$AppDatabase, ActivityTypes> {
  $ActivityTypesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconId =>
      $composableBuilder(column: $table.iconId, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supportsTimer => $composableBuilder(
    column: $table.supportsTimer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supportsPlanning => $composableBuilder(
    column: $table.supportsPlanning,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> activityFieldsRefs<T extends Object>(
    Expression<T> Function($ActivityFieldsAnnotationComposer a) f,
  ) {
    final $ActivityFieldsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsAnnotationComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planSeriesRefs<T extends Object>(
    Expression<T> Function($PlanSeriesAnnotationComposer a) f,
  ) {
    final $PlanSeriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.planSeries,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlanSeriesAnnotationComposer(
            $db: $db,
            $table: $db.planSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($PlansAnnotationComposer a) f,
  ) {
    final $PlansAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityLogsRefs<T extends Object>(
    Expression<T> Function($ActivityLogsAnnotationComposer a) f,
  ) {
    final $ActivityLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsAnnotationComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($FocusSessionsAnnotationComposer a) f,
  ) {
    final $FocusSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.activityTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityTypesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ActivityTypes,
          ActivityTypeRow,
          $ActivityTypesFilterComposer,
          $ActivityTypesOrderingComposer,
          $ActivityTypesAnnotationComposer,
          $ActivityTypesCreateCompanionBuilder,
          $ActivityTypesUpdateCompanionBuilder,
          (ActivityTypeRow, $ActivityTypesReferences),
          ActivityTypeRow,
          PrefetchHooks Function({
            bool activityFieldsRefs,
            bool planSeriesRefs,
            bool plansRefs,
            bool activityLogsRefs,
            bool focusSessionsRefs,
          })
        > {
  $ActivityTypesTableManager(_$AppDatabase db, ActivityTypes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActivityTypesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActivityTypesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActivityTypesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconId = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> supportsTimer = const Value.absent(),
                Value<int> supportsPlanning = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => ActivityTypesCompanion(
                internalId: internalId,
                publicId: publicId,
                name: name,
                iconId: iconId,
                colorKey: colorKey,
                description: description,
                supportsTimer: supportsTimer,
                supportsPlanning: supportsPlanning,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required String name,
                required String iconId,
                required String colorKey,
                Value<String?> description = const Value.absent(),
                Value<int> supportsTimer = const Value.absent(),
                Value<int> supportsPlanning = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
              }) => ActivityTypesCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                name: name,
                iconId: iconId,
                colorKey: colorKey,
                description: description,
                supportsTimer: supportsTimer,
                supportsPlanning: supportsPlanning,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActivityTypes, ActivityTypeRow>(table),
                  $ActivityTypesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activityFieldsRefs = false,
                planSeriesRefs = false,
                plansRefs = false,
                activityLogsRefs = false,
                focusSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityFieldsRefs) db.activityFields,
                    if (planSeriesRefs) db.planSeries,
                    if (plansRefs) db.plans,
                    if (activityLogsRefs) db.activityLogs,
                    if (focusSessionsRefs) db.focusSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityFieldsRefs)
                        await $_getPrefetchedData<
                          ActivityTypeRow,
                          ActivityTypes,
                          ActivityFieldRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityTypesReferences
                              ._activityFieldsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityTypesReferences(
                                db,
                                table,
                                p0,
                              ).activityFieldsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityTypeId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (planSeriesRefs)
                        await $_getPrefetchedData<
                          ActivityTypeRow,
                          ActivityTypes,
                          PlanSeriesRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityTypesReferences
                              ._planSeriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityTypesReferences(
                                db,
                                table,
                                p0,
                              ).planSeriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityTypeId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (plansRefs)
                        await $_getPrefetchedData<
                          ActivityTypeRow,
                          ActivityTypes,
                          PlanRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityTypesReferences
                              ._plansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityTypesReferences(db, table, p0).plansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityTypeId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (activityLogsRefs)
                        await $_getPrefetchedData<
                          ActivityTypeRow,
                          ActivityTypes,
                          ActivityLogRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityTypesReferences
                              ._activityLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityTypesReferences(
                                db,
                                table,
                                p0,
                              ).activityLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityTypeId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          ActivityTypeRow,
                          ActivityTypes,
                          FocusSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityTypesReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityTypesReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityTypeId == item.internalId,
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

typedef $ActivityTypesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ActivityTypes,
      ActivityTypeRow,
      $ActivityTypesFilterComposer,
      $ActivityTypesOrderingComposer,
      $ActivityTypesAnnotationComposer,
      $ActivityTypesCreateCompanionBuilder,
      $ActivityTypesUpdateCompanionBuilder,
      (ActivityTypeRow, $ActivityTypesReferences),
      ActivityTypeRow,
      PrefetchHooks Function({
        bool activityFieldsRefs,
        bool planSeriesRefs,
        bool plansRefs,
        bool activityLogsRefs,
        bool focusSessionsRefs,
      })
    >;
typedef $ActivityFieldsCreateCompanionBuilder =
    ActivityFieldsCompanion Function({
      Value<int> internalId,
      required String publicId,
      required int activityTypeId,
      required String name,
      required String fieldType,
      Value<String?> dimension,
      required int position,
      Value<int> required,
      Value<int> measurable,
      Value<String> configJson,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int?> parentFieldId,
    });
typedef $ActivityFieldsUpdateCompanionBuilder =
    ActivityFieldsCompanion Function({
      Value<int> internalId,
      Value<String> publicId,
      Value<int> activityTypeId,
      Value<String> name,
      Value<String> fieldType,
      Value<String?> dimension,
      Value<int> position,
      Value<int> required,
      Value<int> measurable,
      Value<String> configJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int?> parentFieldId,
    });

final class $ActivityFieldsReferences
    extends BaseReferences<_$AppDatabase, ActivityFields, ActivityFieldRow> {
  $ActivityFieldsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityTypes _activityTypeIdTable(_$AppDatabase db) =>
      db.activityTypes.createAlias(
        'activity_fields__activity_type_id__activity_types__internal_id',
      );

  $ActivityTypesProcessedTableManager get activityTypeId {
    final $_column = $_itemColumn<int>('activity_type_id')!;

    final manager = $ActivityTypesTableManager(
      $_db,
      $_db.activityTypes,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ActivityFields _parentFieldIdTable(_$AppDatabase db) =>
      db.activityFields.createAlias(
        'activity_fields__parent_field_id__activity_fields__internal_id',
      );

  $ActivityFieldsProcessedTableManager? get parentFieldId {
    final $_column = $_itemColumn<int>('parent_field_id');
    if ($_column == null) return null;
    final manager = $ActivityFieldsTableManager(
      $_db,
      $_db.activityFields,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentFieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LogGroupItems, List<LogGroupItemRow>>
  _logGroupItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.logGroupItems,
    aliasName: 'activity_fields__internal_id__log_group_items__field_id',
  );

  $LogGroupItemsProcessedTableManager get logGroupItemsRefs {
    final manager = $LogGroupItemsTableManager($_db, $_db.logGroupItems).filter(
      (f) => f.fieldId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_logGroupItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LogValues, List<LogValueRow>> _logValuesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.logValues,
    aliasName: 'activity_fields__internal_id__log_values__field_id',
  );

  $LogValuesProcessedTableManager get logValuesRefs {
    final manager = $LogValuesTableManager($_db, $_db.logValues).filter(
      (f) => f.fieldId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_logValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ActivityFieldsFilterComposer
    extends Composer<_$AppDatabase, ActivityFields> {
  $ActivityFieldsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityTypesFilterComposer get activityTypeId {
    final $ActivityTypesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesFilterComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsFilterComposer get parentFieldId {
    final $ActivityFieldsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentFieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsFilterComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> logGroupItemsRefs(
    Expression<bool> Function($LogGroupItemsFilterComposer f) f,
  ) {
    final $LogGroupItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsFilterComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logValuesRefs(
    Expression<bool> Function($LogValuesFilterComposer f) f,
  ) {
    final $LogValuesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesFilterComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityFieldsOrderingComposer
    extends Composer<_$AppDatabase, ActivityFields> {
  $ActivityFieldsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ActivityTypesOrderingComposer get activityTypeId {
    final $ActivityTypesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesOrderingComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsOrderingComposer get parentFieldId {
    final $ActivityFieldsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentFieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsOrderingComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActivityFieldsAnnotationComposer
    extends Composer<_$AppDatabase, ActivityFields> {
  $ActivityFieldsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<String> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  GeneratedColumn<int> get measurable => $composableBuilder(
    column: $table.measurable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $ActivityTypesAnnotationComposer get activityTypeId {
    final $ActivityTypesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesAnnotationComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsAnnotationComposer get parentFieldId {
    final $ActivityFieldsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentFieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsAnnotationComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> logGroupItemsRefs<T extends Object>(
    Expression<T> Function($LogGroupItemsAnnotationComposer a) f,
  ) {
    final $LogGroupItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsAnnotationComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> logValuesRefs<T extends Object>(
    Expression<T> Function($LogValuesAnnotationComposer a) f,
  ) {
    final $LogValuesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesAnnotationComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityFieldsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ActivityFields,
          ActivityFieldRow,
          $ActivityFieldsFilterComposer,
          $ActivityFieldsOrderingComposer,
          $ActivityFieldsAnnotationComposer,
          $ActivityFieldsCreateCompanionBuilder,
          $ActivityFieldsUpdateCompanionBuilder,
          (ActivityFieldRow, $ActivityFieldsReferences),
          ActivityFieldRow,
          PrefetchHooks Function({
            bool activityTypeId,
            bool parentFieldId,
            bool logGroupItemsRefs,
            bool logValuesRefs,
          })
        > {
  $ActivityFieldsTableManager(_$AppDatabase db, ActivityFields table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActivityFieldsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActivityFieldsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActivityFieldsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int> activityTypeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fieldType = const Value.absent(),
                Value<String?> dimension = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> required = const Value.absent(),
                Value<int> measurable = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> parentFieldId = const Value.absent(),
              }) => ActivityFieldsCompanion(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                name: name,
                fieldType: fieldType,
                dimension: dimension,
                position: position,
                required: required,
                measurable: measurable,
                configJson: configJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                parentFieldId: parentFieldId,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required int activityTypeId,
                required String name,
                required String fieldType,
                Value<String?> dimension = const Value.absent(),
                required int position,
                Value<int> required = const Value.absent(),
                Value<int> measurable = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> parentFieldId = const Value.absent(),
              }) => ActivityFieldsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                name: name,
                fieldType: fieldType,
                dimension: dimension,
                position: position,
                required: required,
                measurable: measurable,
                configJson: configJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                parentFieldId: parentFieldId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActivityFields, ActivityFieldRow>(table),
                  $ActivityFieldsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activityTypeId = false,
                parentFieldId = false,
                logGroupItemsRefs = false,
                logValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (logGroupItemsRefs) db.logGroupItems,
                    if (logValuesRefs) db.logValues,
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
                        if (activityTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityTypeId,
                            referencedTable: $ActivityFieldsReferences
                                ._activityTypeIdTable(db),
                            referencedColumn: $ActivityFieldsReferences
                                ._activityTypeIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (parentFieldId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentFieldId,
                            referencedTable: $ActivityFieldsReferences
                                ._parentFieldIdTable(db),
                            referencedColumn: $ActivityFieldsReferences
                                ._parentFieldIdTable(db)
                                .internalId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (logGroupItemsRefs)
                        await $_getPrefetchedData<
                          ActivityFieldRow,
                          ActivityFields,
                          LogGroupItemRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityFieldsReferences
                              ._logGroupItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityFieldsReferences(
                                db,
                                table,
                                p0,
                              ).logGroupItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fieldId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (logValuesRefs)
                        await $_getPrefetchedData<
                          ActivityFieldRow,
                          ActivityFields,
                          LogValueRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityFieldsReferences
                              ._logValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityFieldsReferences(
                                db,
                                table,
                                p0,
                              ).logValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fieldId == item.internalId,
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

typedef $ActivityFieldsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ActivityFields,
      ActivityFieldRow,
      $ActivityFieldsFilterComposer,
      $ActivityFieldsOrderingComposer,
      $ActivityFieldsAnnotationComposer,
      $ActivityFieldsCreateCompanionBuilder,
      $ActivityFieldsUpdateCompanionBuilder,
      (ActivityFieldRow, $ActivityFieldsReferences),
      ActivityFieldRow,
      PrefetchHooks Function({
        bool activityTypeId,
        bool parentFieldId,
        bool logGroupItemsRefs,
        bool logValuesRefs,
      })
    >;
typedef $PlanSeriesCreateCompanionBuilder = PlanSeriesCompanion Function({
  Value<int> internalId,
  required String publicId,
  Value<int?> activityTypeId,
  required String title,
  Value<String?> notes,
  Value<int?> startMinute,
  Value<int?> durationMs,
  required int weekdays,
  Value<int> intervalWeeks,
  required String startDate,
  Value<String?> endDate,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
});
typedef $PlanSeriesUpdateCompanionBuilder = PlanSeriesCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<int?> activityTypeId,
  Value<String> title,
  Value<String?> notes,
  Value<int?> startMinute,
  Value<int?> durationMs,
  Value<int> weekdays,
  Value<int> intervalWeeks,
  Value<String> startDate,
  Value<String?> endDate,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
});

final class $PlanSeriesReferences
    extends BaseReferences<_$AppDatabase, PlanSeries, PlanSeriesRow> {
  $PlanSeriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityTypes _activityTypeIdTable(_$AppDatabase db) =>
      db.activityTypes.createAlias(
        'plan_series__activity_type_id__activity_types__internal_id',
      );

  $ActivityTypesProcessedTableManager? get activityTypeId {
    final $_column = $_itemColumn<int>('activity_type_id');
    if ($_column == null) return null;
    final manager = $ActivityTypesTableManager(
      $_db,
      $_db.activityTypes,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Plans, List<PlanRow>> _plansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plans,
    aliasName: 'plan_series__internal_id__plans__series_id',
  );

  $PlansProcessedTableManager get plansRefs {
    final manager = $PlansTableManager($_db, $_db.plans).filter(
      (f) => f.seriesId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_plansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PlanSeriesFilterComposer extends Composer<_$AppDatabase, PlanSeries> {
  $PlanSeriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalWeeks => $composableBuilder(
    column: $table.intervalWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityTypesFilterComposer get activityTypeId {
    final $ActivityTypesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesFilterComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> plansRefs(
    Expression<bool> Function($PlansFilterComposer f) f,
  ) {
    final $PlansFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PlanSeriesOrderingComposer extends Composer<_$AppDatabase, PlanSeries> {
  $PlanSeriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalWeeks => $composableBuilder(
    column: $table.intervalWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ActivityTypesOrderingComposer get activityTypeId {
    final $ActivityTypesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesOrderingComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PlanSeriesAnnotationComposer
    extends Composer<_$AppDatabase, PlanSeries> {
  $PlanSeriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get intervalWeeks => $composableBuilder(
    column: $table.intervalWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $ActivityTypesAnnotationComposer get activityTypeId {
    final $ActivityTypesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesAnnotationComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> plansRefs<T extends Object>(
    Expression<T> Function($PlansAnnotationComposer a) f,
  ) {
    final $PlansAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PlanSeriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PlanSeries,
          PlanSeriesRow,
          $PlanSeriesFilterComposer,
          $PlanSeriesOrderingComposer,
          $PlanSeriesAnnotationComposer,
          $PlanSeriesCreateCompanionBuilder,
          $PlanSeriesUpdateCompanionBuilder,
          (PlanSeriesRow, $PlanSeriesReferences),
          PlanSeriesRow,
          PrefetchHooks Function({bool activityTypeId, bool plansRefs})
        > {
  $PlanSeriesTableManager(_$AppDatabase db, PlanSeries table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlanSeriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlanSeriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlanSeriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int?> activityTypeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<int> intervalWeeks = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => PlanSeriesCompanion(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                title: title,
                notes: notes,
                startMinute: startMinute,
                durationMs: durationMs,
                weekdays: weekdays,
                intervalWeeks: intervalWeeks,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                Value<int?> activityTypeId = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required int weekdays,
                Value<int> intervalWeeks = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
              }) => PlanSeriesCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                title: title,
                notes: notes,
                startMinute: startMinute,
                durationMs: durationMs,
                weekdays: weekdays,
                intervalWeeks: intervalWeeks,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlanSeries, PlanSeriesRow>(table),
                  $PlanSeriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityTypeId = false, plansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plansRefs) db.plans],
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
                    if (activityTypeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.activityTypeId,
                        referencedTable: $PlanSeriesReferences
                            ._activityTypeIdTable(db),
                        referencedColumn: $PlanSeriesReferences
                            ._activityTypeIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plansRefs)
                    await $_getPrefetchedData<
                      PlanSeriesRow,
                      PlanSeries,
                      PlanRow
                    >(
                      currentTable: table,
                      referencedTable: $PlanSeriesReferences._plansRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $PlanSeriesReferences(db, table, p0).plansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.seriesId == item.internalId,
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

typedef $PlanSeriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PlanSeries,
      PlanSeriesRow,
      $PlanSeriesFilterComposer,
      $PlanSeriesOrderingComposer,
      $PlanSeriesAnnotationComposer,
      $PlanSeriesCreateCompanionBuilder,
      $PlanSeriesUpdateCompanionBuilder,
      (PlanSeriesRow, $PlanSeriesReferences),
      PlanSeriesRow,
      PrefetchHooks Function({bool activityTypeId, bool plansRefs})
    >;
typedef $PlansCreateCompanionBuilder = PlansCompanion Function({
  Value<int> internalId,
  required String publicId,
  required String planDate,
  Value<int?> activityTypeId,
  required String title,
  Value<String?> notes,
  Value<int?> plannedStartAt,
  Value<int?> plannedEndAt,
  Value<int?> plannedDurationMs,
  Value<int> sortOrder,
  Value<String> status,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int?> seriesId,
});
typedef $PlansUpdateCompanionBuilder = PlansCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<String> planDate,
  Value<int?> activityTypeId,
  Value<String> title,
  Value<String?> notes,
  Value<int?> plannedStartAt,
  Value<int?> plannedEndAt,
  Value<int?> plannedDurationMs,
  Value<int> sortOrder,
  Value<String> status,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int?> seriesId,
});

final class $PlansReferences
    extends BaseReferences<_$AppDatabase, Plans, PlanRow> {
  $PlansReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityTypes _activityTypeIdTable(_$AppDatabase db) => db
      .activityTypes
      .createAlias('plans__activity_type_id__activity_types__internal_id');

  $ActivityTypesProcessedTableManager? get activityTypeId {
    final $_column = $_itemColumn<int>('activity_type_id');
    if ($_column == null) return null;
    final manager = $ActivityTypesTableManager(
      $_db,
      $_db.activityTypes,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static PlanSeries _seriesIdTable(_$AppDatabase db) =>
      db.planSeries.createAlias('plans__series_id__plan_series__internal_id');

  $PlanSeriesProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<int>('series_id');
    if ($_column == null) return null;
    final manager = $PlanSeriesTableManager(
      $_db,
      $_db.planSeries,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ActivityLogs, List<ActivityLogRow>>
  _activityLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityLogs,
    aliasName: 'plans__internal_id__activity_logs__plan_id',
  );

  $ActivityLogsProcessedTableManager get activityLogsRefs {
    final manager = $ActivityLogsTableManager($_db, $_db.activityLogs).filter(
      (f) => f.planId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_activityLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FocusSessions, List<FocusSessionRow>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'plans__internal_id__focus_sessions__plan_id',
  );

  $FocusSessionsProcessedTableManager get focusSessionsRefs {
    final manager = $FocusSessionsTableManager($_db, $_db.focusSessions).filter(
      (f) => f.planId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PlansFilterComposer extends Composer<_$AppDatabase, Plans> {
  $PlansFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planDate => $composableBuilder(
    column: $table.planDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedStartAt => $composableBuilder(
    column: $table.plannedStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityTypesFilterComposer get activityTypeId {
    final $ActivityTypesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesFilterComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlanSeriesFilterComposer get seriesId {
    final $PlanSeriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.planSeries,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlanSeriesFilterComposer(
            $db: $db,
            $table: $db.planSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activityLogsRefs(
    Expression<bool> Function($ActivityLogsFilterComposer f) f,
  ) {
    final $ActivityLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsFilterComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($FocusSessionsFilterComposer f) f,
  ) {
    final $FocusSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PlansOrderingComposer extends Composer<_$AppDatabase, Plans> {
  $PlansOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planDate => $composableBuilder(
    column: $table.planDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedStartAt => $composableBuilder(
    column: $table.plannedStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ActivityTypesOrderingComposer get activityTypeId {
    final $ActivityTypesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesOrderingComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlanSeriesOrderingComposer get seriesId {
    final $PlanSeriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.planSeries,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlanSeriesOrderingComposer(
            $db: $db,
            $table: $db.planSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PlansAnnotationComposer extends Composer<_$AppDatabase, Plans> {
  $PlansAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get planDate =>
      $composableBuilder(column: $table.planDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get plannedStartAt => $composableBuilder(
    column: $table.plannedStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $ActivityTypesAnnotationComposer get activityTypeId {
    final $ActivityTypesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesAnnotationComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlanSeriesAnnotationComposer get seriesId {
    final $PlanSeriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.planSeries,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlanSeriesAnnotationComposer(
            $db: $db,
            $table: $db.planSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activityLogsRefs<T extends Object>(
    Expression<T> Function($ActivityLogsAnnotationComposer a) f,
  ) {
    final $ActivityLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsAnnotationComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($FocusSessionsAnnotationComposer a) f,
  ) {
    final $FocusSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PlansTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Plans,
          PlanRow,
          $PlansFilterComposer,
          $PlansOrderingComposer,
          $PlansAnnotationComposer,
          $PlansCreateCompanionBuilder,
          $PlansUpdateCompanionBuilder,
          (PlanRow, $PlansReferences),
          PlanRow,
          PrefetchHooks Function({
            bool activityTypeId,
            bool seriesId,
            bool activityLogsRefs,
            bool focusSessionsRefs,
          })
        > {
  $PlansTableManager(_$AppDatabase db, Plans table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlansFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlansOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlansAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> planDate = const Value.absent(),
                Value<int?> activityTypeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> plannedStartAt = const Value.absent(),
                Value<int?> plannedEndAt = const Value.absent(),
                Value<int?> plannedDurationMs = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
              }) => PlansCompanion(
                internalId: internalId,
                publicId: publicId,
                planDate: planDate,
                activityTypeId: activityTypeId,
                title: title,
                notes: notes,
                plannedStartAt: plannedStartAt,
                plannedEndAt: plannedEndAt,
                plannedDurationMs: plannedDurationMs,
                sortOrder: sortOrder,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seriesId: seriesId,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required String planDate,
                Value<int?> activityTypeId = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<int?> plannedStartAt = const Value.absent(),
                Value<int?> plannedEndAt = const Value.absent(),
                Value<int?> plannedDurationMs = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
              }) => PlansCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                planDate: planDate,
                activityTypeId: activityTypeId,
                title: title,
                notes: notes,
                plannedStartAt: plannedStartAt,
                plannedEndAt: plannedEndAt,
                plannedDurationMs: plannedDurationMs,
                sortOrder: sortOrder,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                seriesId: seriesId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Plans, PlanRow>(table),
                  $PlansReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activityTypeId = false,
                seriesId = false,
                activityLogsRefs = false,
                focusSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityLogsRefs) db.activityLogs,
                    if (focusSessionsRefs) db.focusSessions,
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
                        if (activityTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityTypeId,
                            referencedTable: $PlansReferences
                                ._activityTypeIdTable(db),
                            referencedColumn: $PlansReferences
                                ._activityTypeIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (seriesId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seriesId,
                            referencedTable: $PlansReferences._seriesIdTable(
                              db,
                            ),
                            referencedColumn: $PlansReferences
                                ._seriesIdTable(db)
                                .internalId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityLogsRefs)
                        await $_getPrefetchedData<
                          PlanRow,
                          Plans,
                          ActivityLogRow
                        >(
                          currentTable: table,
                          referencedTable: $PlansReferences
                              ._activityLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PlansReferences(db, table, p0).activityLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          PlanRow,
                          Plans,
                          FocusSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $PlansReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PlansReferences(db, table, p0).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.internalId,
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

typedef $PlansProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Plans,
      PlanRow,
      $PlansFilterComposer,
      $PlansOrderingComposer,
      $PlansAnnotationComposer,
      $PlansCreateCompanionBuilder,
      $PlansUpdateCompanionBuilder,
      (PlanRow, $PlansReferences),
      PlanRow,
      PrefetchHooks Function({
        bool activityTypeId,
        bool seriesId,
        bool activityLogsRefs,
        bool focusSessionsRefs,
      })
    >;
typedef $ActivityLogsCreateCompanionBuilder = ActivityLogsCompanion Function({
  Value<int> internalId,
  required String publicId,
  required int activityTypeId,
  required int startedAt,
  Value<int?> endedAt,
  Value<int?> durationMs,
  required int tzOffsetMinutes,
  required String localDate,
  Value<String?> notes,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int?> planId,
});
typedef $ActivityLogsUpdateCompanionBuilder = ActivityLogsCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<int> activityTypeId,
  Value<int> startedAt,
  Value<int?> endedAt,
  Value<int?> durationMs,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int?> planId,
});

final class $ActivityLogsReferences
    extends BaseReferences<_$AppDatabase, ActivityLogs, ActivityLogRow> {
  $ActivityLogsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityTypes _activityTypeIdTable(_$AppDatabase db) =>
      db.activityTypes.createAlias(
        'activity_logs__activity_type_id__activity_types__internal_id',
      );

  $ActivityTypesProcessedTableManager get activityTypeId {
    final $_column = $_itemColumn<int>('activity_type_id')!;

    final manager = $ActivityTypesTableManager(
      $_db,
      $_db.activityTypes,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Plans _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('activity_logs__plan_id__plans__internal_id');

  $PlansProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $PlansTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LogGroupItems, List<LogGroupItemRow>>
  _logGroupItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.logGroupItems,
    aliasName: 'activity_logs__internal_id__log_group_items__log_id',
  );

  $LogGroupItemsProcessedTableManager get logGroupItemsRefs {
    final manager = $LogGroupItemsTableManager($_db, $_db.logGroupItems).filter(
      (f) => f.logId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_logGroupItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LogValues, List<LogValueRow>> _logValuesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.logValues,
    aliasName: 'activity_logs__internal_id__log_values__log_id',
  );

  $LogValuesProcessedTableManager get logValuesRefs {
    final manager = $LogValuesTableManager($_db, $_db.logValues).filter(
      (f) => f.logId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_logValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FocusSessions, List<FocusSessionRow>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'activity_logs__internal_id__focus_sessions__activity_log_id',
  );

  $FocusSessionsProcessedTableManager get focusSessionsRefs {
    final manager = $FocusSessionsTableManager($_db, $_db.focusSessions).filter(
      (f) => f.activityLogId.internalId.sqlEquals(
        $_itemColumn<int>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ActivityLogsFilterComposer
    extends Composer<_$AppDatabase, ActivityLogs> {
  $ActivityLogsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityTypesFilterComposer get activityTypeId {
    final $ActivityTypesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesFilterComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansFilterComposer get planId {
    final $PlansFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> logGroupItemsRefs(
    Expression<bool> Function($LogGroupItemsFilterComposer f) f,
  ) {
    final $LogGroupItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsFilterComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logValuesRefs(
    Expression<bool> Function($LogValuesFilterComposer f) f,
  ) {
    final $LogValuesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesFilterComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($FocusSessionsFilterComposer f) f,
  ) {
    final $FocusSessionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.activityLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityLogsOrderingComposer
    extends Composer<_$AppDatabase, ActivityLogs> {
  $ActivityLogsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ActivityTypesOrderingComposer get activityTypeId {
    final $ActivityTypesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesOrderingComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansOrderingComposer get planId {
    final $PlansOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActivityLogsAnnotationComposer
    extends Composer<_$AppDatabase, ActivityLogs> {
  $ActivityLogsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $ActivityTypesAnnotationComposer get activityTypeId {
    final $ActivityTypesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesAnnotationComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansAnnotationComposer get planId {
    final $PlansAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> logGroupItemsRefs<T extends Object>(
    Expression<T> Function($LogGroupItemsAnnotationComposer a) f,
  ) {
    final $LogGroupItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsAnnotationComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> logValuesRefs<T extends Object>(
    Expression<T> Function($LogValuesAnnotationComposer a) f,
  ) {
    final $LogValuesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesAnnotationComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($FocusSessionsAnnotationComposer a) f,
  ) {
    final $FocusSessionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.activityLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FocusSessionsAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActivityLogsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ActivityLogs,
          ActivityLogRow,
          $ActivityLogsFilterComposer,
          $ActivityLogsOrderingComposer,
          $ActivityLogsAnnotationComposer,
          $ActivityLogsCreateCompanionBuilder,
          $ActivityLogsUpdateCompanionBuilder,
          (ActivityLogRow, $ActivityLogsReferences),
          ActivityLogRow,
          PrefetchHooks Function({
            bool activityTypeId,
            bool planId,
            bool logGroupItemsRefs,
            bool logValuesRefs,
            bool focusSessionsRefs,
          })
        > {
  $ActivityLogsTableManager(_$AppDatabase db, ActivityLogs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActivityLogsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActivityLogsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActivityLogsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int> activityTypeId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> planId = const Value.absent(),
              }) => ActivityLogsCompanion(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                planId: planId,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required int activityTypeId,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required int tzOffsetMinutes,
                required String localDate,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int?> planId = const Value.absent(),
              }) => ActivityLogsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                planId: planId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActivityLogs, ActivityLogRow>(table),
                  $ActivityLogsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activityTypeId = false,
                planId = false,
                logGroupItemsRefs = false,
                logValuesRefs = false,
                focusSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (logGroupItemsRefs) db.logGroupItems,
                    if (logValuesRefs) db.logValues,
                    if (focusSessionsRefs) db.focusSessions,
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
                        if (activityTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityTypeId,
                            referencedTable: $ActivityLogsReferences
                                ._activityTypeIdTable(db),
                            referencedColumn: $ActivityLogsReferences
                                ._activityTypeIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $ActivityLogsReferences
                                ._planIdTable(db),
                            referencedColumn: $ActivityLogsReferences
                                ._planIdTable(db)
                                .internalId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (logGroupItemsRefs)
                        await $_getPrefetchedData<
                          ActivityLogRow,
                          ActivityLogs,
                          LogGroupItemRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityLogsReferences
                              ._logGroupItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityLogsReferences(
                                db,
                                table,
                                p0,
                              ).logGroupItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.logId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (logValuesRefs)
                        await $_getPrefetchedData<
                          ActivityLogRow,
                          ActivityLogs,
                          LogValueRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityLogsReferences
                              ._logValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityLogsReferences(
                                db,
                                table,
                                p0,
                              ).logValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.logId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          ActivityLogRow,
                          ActivityLogs,
                          FocusSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $ActivityLogsReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActivityLogsReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityLogId == item.internalId,
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

typedef $ActivityLogsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ActivityLogs,
      ActivityLogRow,
      $ActivityLogsFilterComposer,
      $ActivityLogsOrderingComposer,
      $ActivityLogsAnnotationComposer,
      $ActivityLogsCreateCompanionBuilder,
      $ActivityLogsUpdateCompanionBuilder,
      (ActivityLogRow, $ActivityLogsReferences),
      ActivityLogRow,
      PrefetchHooks Function({
        bool activityTypeId,
        bool planId,
        bool logGroupItemsRefs,
        bool logValuesRefs,
        bool focusSessionsRefs,
      })
    >;
typedef $LogGroupItemsCreateCompanionBuilder = LogGroupItemsCompanion Function({
  Value<int> internalId,
  required String publicId,
  required int logId,
  required int fieldId,
  Value<int?> parentItemId,
  required int position,
  required int createdAt,
  required int updatedAt,
});
typedef $LogGroupItemsUpdateCompanionBuilder = LogGroupItemsCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<int> logId,
  Value<int> fieldId,
  Value<int?> parentItemId,
  Value<int> position,
  Value<int> createdAt,
  Value<int> updatedAt,
});

final class $LogGroupItemsReferences
    extends BaseReferences<_$AppDatabase, LogGroupItems, LogGroupItemRow> {
  $LogGroupItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityLogs _logIdTable(_$AppDatabase db) => db.activityLogs
      .createAlias('log_group_items__log_id__activity_logs__internal_id');

  $ActivityLogsProcessedTableManager get logId {
    final $_column = $_itemColumn<int>('log_id')!;

    final manager = $ActivityLogsTableManager(
      $_db,
      $_db.activityLogs,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ActivityFields _fieldIdTable(_$AppDatabase db) => db.activityFields
      .createAlias('log_group_items__field_id__activity_fields__internal_id');

  $ActivityFieldsProcessedTableManager get fieldId {
    final $_column = $_itemColumn<int>('field_id')!;

    final manager = $ActivityFieldsTableManager(
      $_db,
      $_db.activityFields,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static LogGroupItems _parentItemIdTable(_$AppDatabase db) =>
      db.logGroupItems.createAlias(
        'log_group_items__parent_item_id__log_group_items__internal_id',
      );

  $LogGroupItemsProcessedTableManager? get parentItemId {
    final $_column = $_itemColumn<int>('parent_item_id');
    if ($_column == null) return null;
    final manager = $LogGroupItemsTableManager(
      $_db,
      $_db.logGroupItems,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LogValues, List<LogValueRow>> _logValuesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.logValues,
    aliasName: 'log_group_items__internal_id__log_values__group_item_id',
  );

  $LogValuesProcessedTableManager get logValuesRefs {
    final manager = $LogValuesTableManager($_db, $_db.logValues).filter(
      (f) =>
          f.groupItemId.internalId.sqlEquals($_itemColumn<int>('internal_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_logValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $LogGroupItemsFilterComposer
    extends Composer<_$AppDatabase, LogGroupItems> {
  $LogGroupItemsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityLogsFilterComposer get logId {
    final $ActivityLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsFilterComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsFilterComposer get fieldId {
    final $ActivityFieldsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsFilterComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsFilterComposer get parentItemId {
    final $LogGroupItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsFilterComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> logValuesRefs(
    Expression<bool> Function($LogValuesFilterComposer f) f,
  ) {
    final $LogValuesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.groupItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesFilterComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LogGroupItemsOrderingComposer
    extends Composer<_$AppDatabase, LogGroupItems> {
  $LogGroupItemsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
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

  $ActivityLogsOrderingComposer get logId {
    final $ActivityLogsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsOrderingComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsOrderingComposer get fieldId {
    final $ActivityFieldsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsOrderingComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsOrderingComposer get parentItemId {
    final $LogGroupItemsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsOrderingComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LogGroupItemsAnnotationComposer
    extends Composer<_$AppDatabase, LogGroupItems> {
  $LogGroupItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $ActivityLogsAnnotationComposer get logId {
    final $ActivityLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsAnnotationComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsAnnotationComposer get fieldId {
    final $ActivityFieldsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsAnnotationComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsAnnotationComposer get parentItemId {
    final $LogGroupItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsAnnotationComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> logValuesRefs<T extends Object>(
    Expression<T> Function($LogValuesAnnotationComposer a) f,
  ) {
    final $LogValuesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.logValues,
      getReferencedColumn: (t) => t.groupItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogValuesAnnotationComposer(
            $db: $db,
            $table: $db.logValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LogGroupItemsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LogGroupItems,
          LogGroupItemRow,
          $LogGroupItemsFilterComposer,
          $LogGroupItemsOrderingComposer,
          $LogGroupItemsAnnotationComposer,
          $LogGroupItemsCreateCompanionBuilder,
          $LogGroupItemsUpdateCompanionBuilder,
          (LogGroupItemRow, $LogGroupItemsReferences),
          LogGroupItemRow,
          PrefetchHooks Function({
            bool logId,
            bool fieldId,
            bool parentItemId,
            bool logValuesRefs,
          })
        > {
  $LogGroupItemsTableManager(_$AppDatabase db, LogGroupItems table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LogGroupItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LogGroupItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LogGroupItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int> logId = const Value.absent(),
                Value<int> fieldId = const Value.absent(),
                Value<int?> parentItemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => LogGroupItemsCompanion(
                internalId: internalId,
                publicId: publicId,
                logId: logId,
                fieldId: fieldId,
                parentItemId: parentItemId,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required int logId,
                required int fieldId,
                Value<int?> parentItemId = const Value.absent(),
                required int position,
                required int createdAt,
                required int updatedAt,
              }) => LogGroupItemsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                logId: logId,
                fieldId: fieldId,
                parentItemId: parentItemId,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LogGroupItems, LogGroupItemRow>(table),
                  $LogGroupItemsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                logId = false,
                fieldId = false,
                parentItemId = false,
                logValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (logValuesRefs) db.logValues],
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
                        if (logId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.logId,
                            referencedTable: $LogGroupItemsReferences
                                ._logIdTable(db),
                            referencedColumn: $LogGroupItemsReferences
                                ._logIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (fieldId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fieldId,
                            referencedTable: $LogGroupItemsReferences
                                ._fieldIdTable(db),
                            referencedColumn: $LogGroupItemsReferences
                                ._fieldIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (parentItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentItemId,
                            referencedTable: $LogGroupItemsReferences
                                ._parentItemIdTable(db),
                            referencedColumn: $LogGroupItemsReferences
                                ._parentItemIdTable(db)
                                .internalId,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (logValuesRefs)
                        await $_getPrefetchedData<
                          LogGroupItemRow,
                          LogGroupItems,
                          LogValueRow
                        >(
                          currentTable: table,
                          referencedTable: $LogGroupItemsReferences
                              ._logValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LogGroupItemsReferences(
                                db,
                                table,
                                p0,
                              ).logValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupItemId == item.internalId,
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

typedef $LogGroupItemsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LogGroupItems,
      LogGroupItemRow,
      $LogGroupItemsFilterComposer,
      $LogGroupItemsOrderingComposer,
      $LogGroupItemsAnnotationComposer,
      $LogGroupItemsCreateCompanionBuilder,
      $LogGroupItemsUpdateCompanionBuilder,
      (LogGroupItemRow, $LogGroupItemsReferences),
      LogGroupItemRow,
      PrefetchHooks Function({
        bool logId,
        bool fieldId,
        bool parentItemId,
        bool logValuesRefs,
      })
    >;
typedef $LogValuesCreateCompanionBuilder = LogValuesCompanion Function({
  Value<int> internalId,
  required int logId,
  required int fieldId,
  Value<String?> textValue,
  Value<double?> numberValue,
  Value<String?> unitCode,
  Value<double?> normalizedValue,
  Value<int?> booleanValue,
  Value<String?> dateValue,
  Value<int?> timeValue,
  Value<int?> durationMs,
  Value<String?> jsonValue,
  required int createdAt,
  required int updatedAt,
  Value<int?> groupItemId,
});
typedef $LogValuesUpdateCompanionBuilder = LogValuesCompanion Function({
  Value<int> internalId,
  Value<int> logId,
  Value<int> fieldId,
  Value<String?> textValue,
  Value<double?> numberValue,
  Value<String?> unitCode,
  Value<double?> normalizedValue,
  Value<int?> booleanValue,
  Value<String?> dateValue,
  Value<int?> timeValue,
  Value<int?> durationMs,
  Value<String?> jsonValue,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> groupItemId,
});

final class $LogValuesReferences
    extends BaseReferences<_$AppDatabase, LogValues, LogValueRow> {
  $LogValuesReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityLogs _logIdTable(_$AppDatabase db) => db.activityLogs
      .createAlias('log_values__log_id__activity_logs__internal_id');

  $ActivityLogsProcessedTableManager get logId {
    final $_column = $_itemColumn<int>('log_id')!;

    final manager = $ActivityLogsTableManager(
      $_db,
      $_db.activityLogs,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ActivityFields _fieldIdTable(_$AppDatabase db) => db.activityFields
      .createAlias('log_values__field_id__activity_fields__internal_id');

  $ActivityFieldsProcessedTableManager get fieldId {
    final $_column = $_itemColumn<int>('field_id')!;

    final manager = $ActivityFieldsTableManager(
      $_db,
      $_db.activityFields,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static LogGroupItems _groupItemIdTable(_$AppDatabase db) => db.logGroupItems
      .createAlias('log_values__group_item_id__log_group_items__internal_id');

  $LogGroupItemsProcessedTableManager? get groupItemId {
    final $_column = $_itemColumn<int>('group_item_id');
    if ($_column == null) return null;
    final manager = $LogGroupItemsTableManager(
      $_db,
      $_db.logGroupItems,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LogValuesFilterComposer extends Composer<_$AppDatabase, LogValues> {
  $LogValuesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeValue => $composableBuilder(
    column: $table.timeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityLogsFilterComposer get logId {
    final $ActivityLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsFilterComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsFilterComposer get fieldId {
    final $ActivityFieldsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsFilterComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsFilterComposer get groupItemId {
    final $LogGroupItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsFilterComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LogValuesOrderingComposer extends Composer<_$AppDatabase, LogValues> {
  $LogValuesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeValue => $composableBuilder(
    column: $table.timeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonValue => $composableBuilder(
    column: $table.jsonValue,
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

  $ActivityLogsOrderingComposer get logId {
    final $ActivityLogsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsOrderingComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsOrderingComposer get fieldId {
    final $ActivityFieldsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsOrderingComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsOrderingComposer get groupItemId {
    final $LogGroupItemsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsOrderingComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LogValuesAnnotationComposer extends Composer<_$AppDatabase, LogValues> {
  $LogValuesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateValue =>
      $composableBuilder(column: $table.dateValue, builder: (column) => column);

  GeneratedColumn<int> get timeValue =>
      $composableBuilder(column: $table.timeValue, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonValue =>
      $composableBuilder(column: $table.jsonValue, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $ActivityLogsAnnotationComposer get logId {
    final $ActivityLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsAnnotationComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityFieldsAnnotationComposer get fieldId {
    final $ActivityFieldsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.activityFields,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityFieldsAnnotationComposer(
            $db: $db,
            $table: $db.activityFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogGroupItemsAnnotationComposer get groupItemId {
    final $LogGroupItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupItemId,
      referencedTable: $db.logGroupItems,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogGroupItemsAnnotationComposer(
            $db: $db,
            $table: $db.logGroupItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LogValuesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LogValues,
          LogValueRow,
          $LogValuesFilterComposer,
          $LogValuesOrderingComposer,
          $LogValuesAnnotationComposer,
          $LogValuesCreateCompanionBuilder,
          $LogValuesUpdateCompanionBuilder,
          (LogValueRow, $LogValuesReferences),
          LogValueRow,
          PrefetchHooks Function({bool logId, bool fieldId, bool groupItemId})
        > {
  $LogValuesTableManager(_$AppDatabase db, LogValues table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LogValuesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LogValuesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LogValuesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<int> logId = const Value.absent(),
                Value<int> fieldId = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<String?> unitCode = const Value.absent(),
                Value<double?> normalizedValue = const Value.absent(),
                Value<int?> booleanValue = const Value.absent(),
                Value<String?> dateValue = const Value.absent(),
                Value<int?> timeValue = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> jsonValue = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> groupItemId = const Value.absent(),
              }) => LogValuesCompanion(
                internalId: internalId,
                logId: logId,
                fieldId: fieldId,
                textValue: textValue,
                numberValue: numberValue,
                unitCode: unitCode,
                normalizedValue: normalizedValue,
                booleanValue: booleanValue,
                dateValue: dateValue,
                timeValue: timeValue,
                durationMs: durationMs,
                jsonValue: jsonValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                groupItemId: groupItemId,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required int logId,
                required int fieldId,
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<String?> unitCode = const Value.absent(),
                Value<double?> normalizedValue = const Value.absent(),
                Value<int?> booleanValue = const Value.absent(),
                Value<String?> dateValue = const Value.absent(),
                Value<int?> timeValue = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> jsonValue = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> groupItemId = const Value.absent(),
              }) => LogValuesCompanion.insert(
                internalId: internalId,
                logId: logId,
                fieldId: fieldId,
                textValue: textValue,
                numberValue: numberValue,
                unitCode: unitCode,
                normalizedValue: normalizedValue,
                booleanValue: booleanValue,
                dateValue: dateValue,
                timeValue: timeValue,
                durationMs: durationMs,
                jsonValue: jsonValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                groupItemId: groupItemId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LogValues, LogValueRow>(table),
                  $LogValuesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({logId = false, fieldId = false, groupItemId = false}) {
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
                        if (logId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.logId,
                            referencedTable: $LogValuesReferences._logIdTable(
                              db,
                            ),
                            referencedColumn: $LogValuesReferences
                                ._logIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (fieldId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fieldId,
                            referencedTable: $LogValuesReferences._fieldIdTable(
                              db,
                            ),
                            referencedColumn: $LogValuesReferences
                                ._fieldIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (groupItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupItemId,
                            referencedTable: $LogValuesReferences
                                ._groupItemIdTable(db),
                            referencedColumn: $LogValuesReferences
                                ._groupItemIdTable(db)
                                .internalId,
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

typedef $LogValuesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LogValues,
      LogValueRow,
      $LogValuesFilterComposer,
      $LogValuesOrderingComposer,
      $LogValuesAnnotationComposer,
      $LogValuesCreateCompanionBuilder,
      $LogValuesUpdateCompanionBuilder,
      (LogValueRow, $LogValuesReferences),
      LogValueRow,
      PrefetchHooks Function({bool logId, bool fieldId, bool groupItemId})
    >;
typedef $FocusSessionsCreateCompanionBuilder = FocusSessionsCompanion Function({
  Value<int> internalId,
  required String publicId,
  required int activityTypeId,
  Value<int?> planId,
  Value<int?> activityLogId,
  required String state,
  required int startedAt,
  Value<int?> pausedAt,
  Value<int> pausedDurationMs,
  Value<int?> endedAt,
  Value<int?> durationMs,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
});
typedef $FocusSessionsUpdateCompanionBuilder = FocusSessionsCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<int> activityTypeId,
  Value<int?> planId,
  Value<int?> activityLogId,
  Value<String> state,
  Value<int> startedAt,
  Value<int?> pausedAt,
  Value<int> pausedDurationMs,
  Value<int?> endedAt,
  Value<int?> durationMs,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
});

final class $FocusSessionsReferences
    extends BaseReferences<_$AppDatabase, FocusSessions, FocusSessionRow> {
  $FocusSessionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActivityTypes _activityTypeIdTable(_$AppDatabase db) =>
      db.activityTypes.createAlias(
        'focus_sessions__activity_type_id__activity_types__internal_id',
      );

  $ActivityTypesProcessedTableManager get activityTypeId {
    final $_column = $_itemColumn<int>('activity_type_id')!;

    final manager = $ActivityTypesTableManager(
      $_db,
      $_db.activityTypes,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Plans _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('focus_sessions__plan_id__plans__internal_id');

  $PlansProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $PlansTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ActivityLogs _activityLogIdTable(_$AppDatabase db) =>
      db.activityLogs.createAlias(
        'focus_sessions__activity_log_id__activity_logs__internal_id',
      );

  $ActivityLogsProcessedTableManager? get activityLogId {
    final $_column = $_itemColumn<int>('activity_log_id');
    if ($_column == null) return null;
    final manager = $ActivityLogsTableManager(
      $_db,
      $_db.activityLogs,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $FocusSessionsFilterComposer
    extends Composer<_$AppDatabase, FocusSessions> {
  $FocusSessionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedDurationMs => $composableBuilder(
    column: $table.pausedDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $ActivityTypesFilterComposer get activityTypeId {
    final $ActivityTypesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesFilterComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansFilterComposer get planId {
    final $PlansFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityLogsFilterComposer get activityLogId {
    final $ActivityLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityLogId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsFilterComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FocusSessionsOrderingComposer
    extends Composer<_$AppDatabase, FocusSessions> {
  $FocusSessionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedDurationMs => $composableBuilder(
    column: $table.pausedDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ActivityTypesOrderingComposer get activityTypeId {
    final $ActivityTypesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesOrderingComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansOrderingComposer get planId {
    final $PlansOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityLogsOrderingComposer get activityLogId {
    final $ActivityLogsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityLogId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsOrderingComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FocusSessionsAnnotationComposer
    extends Composer<_$AppDatabase, FocusSessions> {
  $FocusSessionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get pausedDurationMs => $composableBuilder(
    column: $table.pausedDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $ActivityTypesAnnotationComposer get activityTypeId {
    final $ActivityTypesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityTypeId,
      referencedTable: $db.activityTypes,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityTypesAnnotationComposer(
            $db: $db,
            $table: $db.activityTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PlansAnnotationComposer get planId {
    final $PlansAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PlansAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ActivityLogsAnnotationComposer get activityLogId {
    final $ActivityLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityLogId,
      referencedTable: $db.activityLogs,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActivityLogsAnnotationComposer(
            $db: $db,
            $table: $db.activityLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FocusSessionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FocusSessions,
          FocusSessionRow,
          $FocusSessionsFilterComposer,
          $FocusSessionsOrderingComposer,
          $FocusSessionsAnnotationComposer,
          $FocusSessionsCreateCompanionBuilder,
          $FocusSessionsUpdateCompanionBuilder,
          (FocusSessionRow, $FocusSessionsReferences),
          FocusSessionRow,
          PrefetchHooks Function({
            bool activityTypeId,
            bool planId,
            bool activityLogId,
          })
        > {
  $FocusSessionsTableManager(_$AppDatabase db, FocusSessions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FocusSessionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FocusSessionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FocusSessionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int> activityTypeId = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int?> activityLogId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> pausedAt = const Value.absent(),
                Value<int> pausedDurationMs = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => FocusSessionsCompanion(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                planId: planId,
                activityLogId: activityLogId,
                state: state,
                startedAt: startedAt,
                pausedAt: pausedAt,
                pausedDurationMs: pausedDurationMs,
                endedAt: endedAt,
                durationMs: durationMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required int activityTypeId,
                Value<int?> planId = const Value.absent(),
                Value<int?> activityLogId = const Value.absent(),
                required String state,
                required int startedAt,
                Value<int?> pausedAt = const Value.absent(),
                Value<int> pausedDurationMs = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                activityTypeId: activityTypeId,
                planId: planId,
                activityLogId: activityLogId,
                state: state,
                startedAt: startedAt,
                pausedAt: pausedAt,
                pausedDurationMs: pausedDurationMs,
                endedAt: endedAt,
                durationMs: durationMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FocusSessions, FocusSessionRow>(table),
                  $FocusSessionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                activityTypeId = false,
                planId = false,
                activityLogId = false,
              }) {
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
                        if (activityTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityTypeId,
                            referencedTable: $FocusSessionsReferences
                                ._activityTypeIdTable(db),
                            referencedColumn: $FocusSessionsReferences
                                ._activityTypeIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $FocusSessionsReferences
                                ._planIdTable(db),
                            referencedColumn: $FocusSessionsReferences
                                ._planIdTable(db)
                                .internalId,
                          ) as T;
                        }
                        if (activityLogId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityLogId,
                            referencedTable: $FocusSessionsReferences
                                ._activityLogIdTable(db),
                            referencedColumn: $FocusSessionsReferences
                                ._activityLogIdTable(db)
                                .internalId,
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

typedef $FocusSessionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FocusSessions,
      FocusSessionRow,
      $FocusSessionsFilterComposer,
      $FocusSessionsOrderingComposer,
      $FocusSessionsAnnotationComposer,
      $FocusSessionsCreateCompanionBuilder,
      $FocusSessionsUpdateCompanionBuilder,
      (FocusSessionRow, $FocusSessionsReferences),
      FocusSessionRow,
      PrefetchHooks Function({
        bool activityTypeId,
        bool planId,
        bool activityLogId,
      })
    >;
typedef $MeasurementsCreateCompanionBuilder = MeasurementsCompanion Function({
  Value<int> internalId,
  required String publicId,
  required String measurementType,
  required double value,
  required String unitCode,
  required double normalizedValue,
  required int recordedAt,
  required int tzOffsetMinutes,
  required String localDate,
  Value<String?> notes,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
});
typedef $MeasurementsUpdateCompanionBuilder = MeasurementsCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<String> measurementType,
  Value<double> value,
  Value<String> unitCode,
  Value<double> normalizedValue,
  Value<int> recordedAt,
  Value<int> tzOffsetMinutes,
  Value<String> localDate,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
});

class $MeasurementsFilterComposer
    extends Composer<_$AppDatabase, Measurements> {
  $MeasurementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementType => $composableBuilder(
    column: $table.measurementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $MeasurementsOrderingComposer
    extends Composer<_$AppDatabase, Measurements> {
  $MeasurementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementType => $composableBuilder(
    column: $table.measurementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MeasurementsAnnotationComposer
    extends Composer<_$AppDatabase, Measurements> {
  $MeasurementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get measurementType => $composableBuilder(
    column: $table.measurementType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tzOffsetMinutes => $composableBuilder(
    column: $table.tzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $MeasurementsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Measurements,
          MeasurementRow,
          $MeasurementsFilterComposer,
          $MeasurementsOrderingComposer,
          $MeasurementsAnnotationComposer,
          $MeasurementsCreateCompanionBuilder,
          $MeasurementsUpdateCompanionBuilder,
          (
            MeasurementRow,
            BaseReferences<_$AppDatabase, Measurements, MeasurementRow>,
          ),
          MeasurementRow,
          PrefetchHooks Function()
        > {
  $MeasurementsTableManager(_$AppDatabase db, Measurements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MeasurementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MeasurementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MeasurementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> measurementType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<double> normalizedValue = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int> tzOffsetMinutes = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => MeasurementsCompanion(
                internalId: internalId,
                publicId: publicId,
                measurementType: measurementType,
                value: value,
                unitCode: unitCode,
                normalizedValue: normalizedValue,
                recordedAt: recordedAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                required String measurementType,
                required double value,
                required String unitCode,
                required double normalizedValue,
                required int recordedAt,
                required int tzOffsetMinutes,
                required String localDate,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                measurementType: measurementType,
                value: value,
                unitCode: unitCode,
                normalizedValue: normalizedValue,
                recordedAt: recordedAt,
                tzOffsetMinutes: tzOffsetMinutes,
                localDate: localDate,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Measurements, MeasurementRow>(table),
                  BaseReferences<_$AppDatabase, Measurements, MeasurementRow>(
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

typedef $MeasurementsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Measurements,
      MeasurementRow,
      $MeasurementsFilterComposer,
      $MeasurementsOrderingComposer,
      $MeasurementsAnnotationComposer,
      $MeasurementsCreateCompanionBuilder,
      $MeasurementsUpdateCompanionBuilder,
      (
        MeasurementRow,
        BaseReferences<_$AppDatabase, Measurements, MeasurementRow>,
      ),
      MeasurementRow,
      PrefetchHooks Function()
    >;
typedef $InsightChartsCreateCompanionBuilder = InsightChartsCompanion Function({
  Value<int> internalId,
  required String publicId,
  Value<int> position,
  required String configJson,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
});
typedef $InsightChartsUpdateCompanionBuilder = InsightChartsCompanion Function({
  Value<int> internalId,
  Value<String> publicId,
  Value<int> position,
  Value<String> configJson,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
});

class $InsightChartsFilterComposer
    extends Composer<_$AppDatabase, InsightCharts> {
  $InsightChartsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $InsightChartsOrderingComposer
    extends Composer<_$AppDatabase, InsightCharts> {
  $InsightChartsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $InsightChartsAnnotationComposer
    extends Composer<_$AppDatabase, InsightCharts> {
  $InsightChartsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $InsightChartsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          InsightCharts,
          InsightChartRow,
          $InsightChartsFilterComposer,
          $InsightChartsOrderingComposer,
          $InsightChartsAnnotationComposer,
          $InsightChartsCreateCompanionBuilder,
          $InsightChartsUpdateCompanionBuilder,
          (
            InsightChartRow,
            BaseReferences<_$AppDatabase, InsightCharts, InsightChartRow>,
          ),
          InsightChartRow,
          PrefetchHooks Function()
        > {
  $InsightChartsTableManager(_$AppDatabase db, InsightCharts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $InsightChartsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $InsightChartsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $InsightChartsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => InsightChartsCompanion(
                internalId: internalId,
                publicId: publicId,
                position: position,
                configJson: configJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> internalId = const Value.absent(),
                required String publicId,
                Value<int> position = const Value.absent(),
                required String configJson,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
              }) => InsightChartsCompanion.insert(
                internalId: internalId,
                publicId: publicId,
                position: position,
                configJson: configJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<InsightCharts, InsightChartRow>(table),
                  BaseReferences<_$AppDatabase, InsightCharts, InsightChartRow>(
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

typedef $InsightChartsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      InsightCharts,
      InsightChartRow,
      $InsightChartsFilterComposer,
      $InsightChartsOrderingComposer,
      $InsightChartsAnnotationComposer,
      $InsightChartsCreateCompanionBuilder,
      $InsightChartsUpdateCompanionBuilder,
      (
        InsightChartRow,
        BaseReferences<_$AppDatabase, InsightCharts, InsightChartRow>,
      ),
      InsightChartRow,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String valueJson,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreferenceRow,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $AppPreferencesTable,
              AppPreferenceRow
            >,
          ),
          AppPreferenceRow,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppPreferencesTable, AppPreferenceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppPreferencesTable,
                    AppPreferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreferenceRow,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreferenceRow,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>,
      ),
      AppPreferenceRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $ActivityTypesTableManager get activityTypes =>
      $ActivityTypesTableManager(_db, _db.activityTypes);
  $ActivityFieldsTableManager get activityFields =>
      $ActivityFieldsTableManager(_db, _db.activityFields);
  $PlanSeriesTableManager get planSeries =>
      $PlanSeriesTableManager(_db, _db.planSeries);
  $PlansTableManager get plans => $PlansTableManager(_db, _db.plans);
  $ActivityLogsTableManager get activityLogs =>
      $ActivityLogsTableManager(_db, _db.activityLogs);
  $LogGroupItemsTableManager get logGroupItems =>
      $LogGroupItemsTableManager(_db, _db.logGroupItems);
  $LogValuesTableManager get logValues =>
      $LogValuesTableManager(_db, _db.logValues);
  $FocusSessionsTableManager get focusSessions =>
      $FocusSessionsTableManager(_db, _db.focusSessions);
  $MeasurementsTableManager get measurements =>
      $MeasurementsTableManager(_db, _db.measurements);
  $InsightChartsTableManager get insightCharts =>
      $InsightChartsTableManager(_db, _db.insightCharts);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
