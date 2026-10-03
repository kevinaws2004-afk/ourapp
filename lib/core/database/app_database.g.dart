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
          ..write('deletedAt: $deletedAt')
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
          other.deletedAt == this.deletedAt);
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
          ..write('deletedAt: $deletedAt')
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
          ..write('deletedAt: $deletedAt')
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
          other.deletedAt == this.deletedAt);
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
          ..write('deletedAt: $deletedAt')
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {logId, fieldId},
  ];
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
    'UNIQUE(log_id, field_id)',
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
          ..write('updatedAt: $updatedAt')
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
          other.updatedAt == this.updatedAt);
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
          ..write('updatedAt: $updatedAt')
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
  late final ActivityLogs activityLogs = ActivityLogs(this);
  late final Index idxActivityLogsDay = Index(
    'idx_activity_logs_day',
    'CREATE INDEX idx_activity_logs_day ON activity_logs (local_date, started_at) WHERE deleted_at IS NULL',
  );
  late final Index idxActivityLogsTypeDay = Index(
    'idx_activity_logs_type_day',
    'CREATE INDEX idx_activity_logs_type_day ON activity_logs (activity_type_id, local_date, started_at) WHERE deleted_at IS NULL',
  );
  late final LogValues logValues = LogValues(this);
  late final Index idxLogValuesFieldNormalized = Index(
    'idx_log_values_field_normalized',
    'CREATE INDEX idx_log_values_field_normalized ON log_values (field_id, normalized_value)',
  );
  late final Trigger trgLogValuesInsertCheck = Trigger(
    'CREATE TRIGGER trg_log_values_insert_check BEFORE INSERT ON log_values BEGIN SELECT RAISE (ABORT, \'log_value_field_not_in_log_type\') WHERE (SELECT activity_type_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT activity_type_id FROM activity_logs WHERE internal_id = NEW.log_id);SELECT RAISE (ABORT, \'log_value_column_mismatch\') WHERE NOT COALESCE((SELECT CASE f.field_type WHEN \'text\' THEN NEW.text_value IS NOT NULL WHEN \'single_select\' THEN NEW.text_value IS NOT NULL WHEN \'number\' THEN NEW.number_value IS NOT NULL AND((NEW.unit_code IS NULL)=(f.dimension IS NULL))WHEN \'rating\' THEN NEW.number_value IS NOT NULL AND NEW.unit_code IS NULL WHEN \'boolean\' THEN NEW.boolean_value IS NOT NULL WHEN \'date\' THEN NEW.date_value IS NOT NULL WHEN \'time\' THEN NEW.time_value IS NOT NULL WHEN \'duration\' THEN NEW.duration_ms IS NOT NULL WHEN \'multi_select\' THEN NEW.json_value IS NOT NULL WHEN \'repeating_group\' THEN NEW.json_value IS NOT NULL ELSE 0 END FROM activity_fields AS f WHERE f.internal_id = NEW.field_id), 0);END',
    'trg_log_values_insert_check',
  );
  late final Trigger trgLogValuesUpdateCheck = Trigger(
    'CREATE TRIGGER trg_log_values_update_check BEFORE UPDATE ON log_values BEGIN SELECT RAISE (ABORT, \'log_value_field_not_in_log_type\') WHERE (SELECT activity_type_id FROM activity_fields WHERE internal_id = NEW.field_id) IS NOT (SELECT activity_type_id FROM activity_logs WHERE internal_id = NEW.log_id);SELECT RAISE (ABORT, \'log_value_column_mismatch\') WHERE NOT COALESCE((SELECT CASE f.field_type WHEN \'text\' THEN NEW.text_value IS NOT NULL WHEN \'single_select\' THEN NEW.text_value IS NOT NULL WHEN \'number\' THEN NEW.number_value IS NOT NULL AND((NEW.unit_code IS NULL)=(f.dimension IS NULL))WHEN \'rating\' THEN NEW.number_value IS NOT NULL AND NEW.unit_code IS NULL WHEN \'boolean\' THEN NEW.boolean_value IS NOT NULL WHEN \'date\' THEN NEW.date_value IS NOT NULL WHEN \'time\' THEN NEW.time_value IS NOT NULL WHEN \'duration\' THEN NEW.duration_ms IS NOT NULL WHEN \'multi_select\' THEN NEW.json_value IS NOT NULL WHEN \'repeating_group\' THEN NEW.json_value IS NOT NULL ELSE 0 END FROM activity_fields AS f WHERE f.internal_id = NEW.field_id), 0);END',
    'trg_log_values_update_check',
  );
  late final Trigger trgActivityFieldsSemanticsLocked = Trigger(
    'CREATE TRIGGER trg_activity_fields_semantics_locked BEFORE UPDATE OF field_type, dimension ON activity_fields WHEN(OLD.field_type IS NOT NEW.field_type OR OLD.dimension IS NOT NEW.dimension)AND EXISTS (SELECT 1 FROM log_values WHERE field_id = OLD.internal_id) BEGIN SELECT RAISE (ABORT, \'activity_field_semantics_locked\');END',
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
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activityTypes,
    activityFields,
    idxActivityFieldsTypePosition,
    activityLogs,
    idxActivityLogsDay,
    idxActivityLogsTypeDay,
    logValues,
    idxLogValuesFieldNormalized,
    trgLogValuesInsertCheck,
    trgLogValuesUpdateCheck,
    trgActivityFieldsSemanticsLocked,
    trgActivityFieldsOwnerImmutable,
    trgActivityLogsTypeImmutable,
    trgActivityTypesPublicIdImmutable,
    trgActivityFieldsPublicIdImmutable,
    trgActivityLogsPublicIdImmutable,
    appPreferences,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_logs',
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
            bool activityLogsRefs,
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
              ({activityFieldsRefs = false, activityLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityFieldsRefs) db.activityFields,
                    if (activityLogsRefs) db.activityLogs,
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
      PrefetchHooks Function({bool activityFieldsRefs, bool activityLogsRefs})
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
          PrefetchHooks Function({bool activityTypeId, bool logValuesRefs})
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
              ({activityTypeId = false, logValuesRefs = false}) {
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

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
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
      PrefetchHooks Function({bool activityTypeId, bool logValuesRefs})
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
          PrefetchHooks Function({bool activityTypeId, bool logValuesRefs})
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
              ({activityTypeId = false, logValuesRefs = false}) {
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

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
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
      PrefetchHooks Function({bool activityTypeId, bool logValuesRefs})
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
          PrefetchHooks Function({bool logId, bool fieldId})
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
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LogValues, LogValueRow>(table),
                  $LogValuesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({logId = false, fieldId = false}) {
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
                        referencedTable: $LogValuesReferences._logIdTable(db),
                        referencedColumn: $LogValuesReferences
                            ._logIdTable(db)
                            .internalId,
                      ) as T;
                    }
                    if (fieldId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fieldId,
                        referencedTable: $LogValuesReferences._fieldIdTable(db),
                        referencedColumn: $LogValuesReferences
                            ._fieldIdTable(db)
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
      PrefetchHooks Function({bool logId, bool fieldId})
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
  $ActivityLogsTableManager get activityLogs =>
      $ActivityLogsTableManager(_db, _db.activityLogs);
  $LogValuesTableManager get logValues =>
      $LogValuesTableManager(_db, _db.logValues);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
