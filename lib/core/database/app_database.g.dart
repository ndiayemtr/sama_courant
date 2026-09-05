// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppliancesTable extends Appliances
    with TableInfo<$AppliancesTable, Appliance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppliancesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerWattsMeta = const VerificationMeta(
    'powerWatts',
  );
  @override
  late final GeneratedColumn<double> powerWatts = GeneratedColumn<double>(
    'power_watts',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _hoursPerDayMeta = const VerificationMeta(
    'hoursPerDay',
  );
  @override
  late final GeneratedColumn<double> hoursPerDay = GeneratedColumn<double>(
    'hours_per_day',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysPerMonthMeta = const VerificationMeta(
    'daysPerMonth',
  );
  @override
  late final GeneratedColumn<int> daysPerMonth = GeneratedColumn<int>(
    'days_per_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
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
    defaultValue: const Constant(true),
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
    name,
    category,
    powerWatts,
    quantity,
    hoursPerDay,
    daysPerMonth,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appliances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appliance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('power_watts')) {
      context.handle(
        _powerWattsMeta,
        powerWatts.isAcceptableOrUnknown(data['power_watts']!, _powerWattsMeta),
      );
    } else if (isInserting) {
      context.missing(_powerWattsMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('hours_per_day')) {
      context.handle(
        _hoursPerDayMeta,
        hoursPerDay.isAcceptableOrUnknown(
          data['hours_per_day']!,
          _hoursPerDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hoursPerDayMeta);
    }
    if (data.containsKey('days_per_month')) {
      context.handle(
        _daysPerMonthMeta,
        daysPerMonth.isAcceptableOrUnknown(
          data['days_per_month']!,
          _daysPerMonthMeta,
        ),
      );
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
  Appliance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appliance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      powerWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_watts'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      hoursPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours_per_day'],
      )!,
      daysPerMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_month'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  $AppliancesTable createAlias(String alias) {
    return $AppliancesTable(attachedDatabase, alias);
  }
}

class Appliance extends DataClass implements Insertable<Appliance> {
  final int id;
  final String name;
  final String category;
  final double powerWatts;
  final int quantity;
  final double hoursPerDay;
  final int daysPerMonth;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Appliance({
    required this.id,
    required this.name,
    required this.category,
    required this.powerWatts,
    required this.quantity,
    required this.hoursPerDay,
    required this.daysPerMonth,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['power_watts'] = Variable<double>(powerWatts);
    map['quantity'] = Variable<int>(quantity);
    map['hours_per_day'] = Variable<double>(hoursPerDay);
    map['days_per_month'] = Variable<int>(daysPerMonth);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppliancesCompanion toCompanion(bool nullToAbsent) {
    return AppliancesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      powerWatts: Value(powerWatts),
      quantity: Value(quantity),
      hoursPerDay: Value(hoursPerDay),
      daysPerMonth: Value(daysPerMonth),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Appliance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appliance(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      powerWatts: serializer.fromJson<double>(json['powerWatts']),
      quantity: serializer.fromJson<int>(json['quantity']),
      hoursPerDay: serializer.fromJson<double>(json['hoursPerDay']),
      daysPerMonth: serializer.fromJson<int>(json['daysPerMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'powerWatts': serializer.toJson<double>(powerWatts),
      'quantity': serializer.toJson<int>(quantity),
      'hoursPerDay': serializer.toJson<double>(hoursPerDay),
      'daysPerMonth': serializer.toJson<int>(daysPerMonth),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Appliance copyWith({
    int? id,
    String? name,
    String? category,
    double? powerWatts,
    int? quantity,
    double? hoursPerDay,
    int? daysPerMonth,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Appliance(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    powerWatts: powerWatts ?? this.powerWatts,
    quantity: quantity ?? this.quantity,
    hoursPerDay: hoursPerDay ?? this.hoursPerDay,
    daysPerMonth: daysPerMonth ?? this.daysPerMonth,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Appliance copyWithCompanion(AppliancesCompanion data) {
    return Appliance(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      powerWatts: data.powerWatts.present
          ? data.powerWatts.value
          : this.powerWatts,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      hoursPerDay: data.hoursPerDay.present
          ? data.hoursPerDay.value
          : this.hoursPerDay,
      daysPerMonth: data.daysPerMonth.present
          ? data.daysPerMonth.value
          : this.daysPerMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appliance(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('powerWatts: $powerWatts, ')
          ..write('quantity: $quantity, ')
          ..write('hoursPerDay: $hoursPerDay, ')
          ..write('daysPerMonth: $daysPerMonth, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    powerWatts,
    quantity,
    hoursPerDay,
    daysPerMonth,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appliance &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.powerWatts == this.powerWatts &&
          other.quantity == this.quantity &&
          other.hoursPerDay == this.hoursPerDay &&
          other.daysPerMonth == this.daysPerMonth &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppliancesCompanion extends UpdateCompanion<Appliance> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<double> powerWatts;
  final Value<int> quantity;
  final Value<double> hoursPerDay;
  final Value<int> daysPerMonth;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AppliancesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.powerWatts = const Value.absent(),
    this.quantity = const Value.absent(),
    this.hoursPerDay = const Value.absent(),
    this.daysPerMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppliancesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    required double powerWatts,
    this.quantity = const Value.absent(),
    required double hoursPerDay,
    this.daysPerMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       category = Value(category),
       powerWatts = Value(powerWatts),
       hoursPerDay = Value(hoursPerDay),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Appliance> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? powerWatts,
    Expression<int>? quantity,
    Expression<double>? hoursPerDay,
    Expression<int>? daysPerMonth,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (powerWatts != null) 'power_watts': powerWatts,
      if (quantity != null) 'quantity': quantity,
      if (hoursPerDay != null) 'hours_per_day': hoursPerDay,
      if (daysPerMonth != null) 'days_per_month': daysPerMonth,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppliancesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<double>? powerWatts,
    Value<int>? quantity,
    Value<double>? hoursPerDay,
    Value<int>? daysPerMonth,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppliancesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      powerWatts: powerWatts ?? this.powerWatts,
      quantity: quantity ?? this.quantity,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      daysPerMonth: daysPerMonth ?? this.daysPerMonth,
      isActive: isActive ?? this.isActive,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (powerWatts.present) {
      map['power_watts'] = Variable<double>(powerWatts.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (hoursPerDay.present) {
      map['hours_per_day'] = Variable<double>(hoursPerDay.value);
    }
    if (daysPerMonth.present) {
      map['days_per_month'] = Variable<int>(daysPerMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('AppliancesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('powerWatts: $powerWatts, ')
          ..write('quantity: $quantity, ')
          ..write('hoursPerDay: $hoursPerDay, ')
          ..write('daysPerMonth: $daysPerMonth, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TariffConfigurationsTable extends TariffConfigurations
    with TableInfo<$TariffConfigurationsTable, TariffConfiguration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TariffConfigurationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _effectiveToMeta = const VerificationMeta(
    'effectiveTo',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveTo = GeneratedColumn<DateTime>(
    'effective_to',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    defaultValue: const Constant(true),
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
    name,
    effectiveFrom,
    effectiveTo,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tariff_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TariffConfiguration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_to')) {
      context.handle(
        _effectiveToMeta,
        effectiveTo.isAcceptableOrUnknown(
          data['effective_to']!,
          _effectiveToMeta,
        ),
      );
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
  TariffConfiguration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TariffConfiguration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
      effectiveTo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_to'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  $TariffConfigurationsTable createAlias(String alias) {
    return $TariffConfigurationsTable(attachedDatabase, alias);
  }
}

class TariffConfiguration extends DataClass
    implements Insertable<TariffConfiguration> {
  final int id;
  final String name;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TariffConfiguration({
    required this.id,
    required this.name,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<DateTime>(effectiveTo);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TariffConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return TariffConfigurationsCompanion(
      id: Value(id),
      name: Value(name),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TariffConfiguration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TariffConfiguration(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      effectiveTo: serializer.fromJson<DateTime?>(json['effectiveTo']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'effectiveTo': serializer.toJson<DateTime?>(effectiveTo),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TariffConfiguration copyWith({
    int? id,
    String? name,
    DateTime? effectiveFrom,
    Value<DateTime?> effectiveTo = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TariffConfiguration(
    id: id ?? this.id,
    name: name ?? this.name,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TariffConfiguration copyWithCompanion(TariffConfigurationsCompanion data) {
    return TariffConfiguration(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present
          ? data.effectiveTo.value
          : this.effectiveTo,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TariffConfiguration(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    effectiveFrom,
    effectiveTo,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TariffConfiguration &&
          other.id == this.id &&
          other.name == this.name &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TariffConfigurationsCompanion
    extends UpdateCompanion<TariffConfiguration> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> effectiveFrom;
  final Value<DateTime?> effectiveTo;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TariffConfigurationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TariffConfigurationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime effectiveFrom,
    this.effectiveTo = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       effectiveFrom = Value(effectiveFrom),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TariffConfiguration> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? effectiveFrom,
    Expression<DateTime>? effectiveTo,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TariffConfigurationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? effectiveFrom,
    Value<DateTime?>? effectiveTo,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TariffConfigurationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      isActive: isActive ?? this.isActive,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<DateTime>(effectiveTo.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('TariffConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TariffTiersTable extends TariffTiers
    with TableInfo<$TariffTiersTable, TariffTier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TariffTiersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tariffConfigurationIdMeta =
      const VerificationMeta('tariffConfigurationId');
  @override
  late final GeneratedColumn<int> tariffConfigurationId = GeneratedColumn<int>(
    'tariff_configuration_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minKwhMeta = const VerificationMeta('minKwh');
  @override
  late final GeneratedColumn<double> minKwh = GeneratedColumn<double>(
    'min_kwh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxKwhMeta = const VerificationMeta('maxKwh');
  @override
  late final GeneratedColumn<double> maxKwh = GeneratedColumn<double>(
    'max_kwh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePerKwhMeta = const VerificationMeta(
    'pricePerKwh',
  );
  @override
  late final GeneratedColumn<double> pricePerKwh = GeneratedColumn<double>(
    'price_per_kwh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierOrderMeta = const VerificationMeta(
    'tierOrder',
  );
  @override
  late final GeneratedColumn<int> tierOrder = GeneratedColumn<int>(
    'tier_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    tariffConfigurationId,
    minKwh,
    maxKwh,
    pricePerKwh,
    tierOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tariff_tiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TariffTier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tariff_configuration_id')) {
      context.handle(
        _tariffConfigurationIdMeta,
        tariffConfigurationId.isAcceptableOrUnknown(
          data['tariff_configuration_id']!,
          _tariffConfigurationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tariffConfigurationIdMeta);
    }
    if (data.containsKey('min_kwh')) {
      context.handle(
        _minKwhMeta,
        minKwh.isAcceptableOrUnknown(data['min_kwh']!, _minKwhMeta),
      );
    } else if (isInserting) {
      context.missing(_minKwhMeta);
    }
    if (data.containsKey('max_kwh')) {
      context.handle(
        _maxKwhMeta,
        maxKwh.isAcceptableOrUnknown(data['max_kwh']!, _maxKwhMeta),
      );
    }
    if (data.containsKey('price_per_kwh')) {
      context.handle(
        _pricePerKwhMeta,
        pricePerKwh.isAcceptableOrUnknown(
          data['price_per_kwh']!,
          _pricePerKwhMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKwhMeta);
    }
    if (data.containsKey('tier_order')) {
      context.handle(
        _tierOrderMeta,
        tierOrder.isAcceptableOrUnknown(data['tier_order']!, _tierOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_tierOrderMeta);
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
  TariffTier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TariffTier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tariffConfigurationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tariff_configuration_id'],
      )!,
      minKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_kwh'],
      )!,
      maxKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_kwh'],
      ),
      pricePerKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_kwh'],
      )!,
      tierOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier_order'],
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
  $TariffTiersTable createAlias(String alias) {
    return $TariffTiersTable(attachedDatabase, alias);
  }
}

class TariffTier extends DataClass implements Insertable<TariffTier> {
  final int id;
  final int tariffConfigurationId;
  final double minKwh;
  final double? maxKwh;
  final double pricePerKwh;
  final int tierOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TariffTier({
    required this.id,
    required this.tariffConfigurationId,
    required this.minKwh,
    this.maxKwh,
    required this.pricePerKwh,
    required this.tierOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tariff_configuration_id'] = Variable<int>(tariffConfigurationId);
    map['min_kwh'] = Variable<double>(minKwh);
    if (!nullToAbsent || maxKwh != null) {
      map['max_kwh'] = Variable<double>(maxKwh);
    }
    map['price_per_kwh'] = Variable<double>(pricePerKwh);
    map['tier_order'] = Variable<int>(tierOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TariffTiersCompanion toCompanion(bool nullToAbsent) {
    return TariffTiersCompanion(
      id: Value(id),
      tariffConfigurationId: Value(tariffConfigurationId),
      minKwh: Value(minKwh),
      maxKwh: maxKwh == null && nullToAbsent
          ? const Value.absent()
          : Value(maxKwh),
      pricePerKwh: Value(pricePerKwh),
      tierOrder: Value(tierOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TariffTier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TariffTier(
      id: serializer.fromJson<int>(json['id']),
      tariffConfigurationId: serializer.fromJson<int>(
        json['tariffConfigurationId'],
      ),
      minKwh: serializer.fromJson<double>(json['minKwh']),
      maxKwh: serializer.fromJson<double?>(json['maxKwh']),
      pricePerKwh: serializer.fromJson<double>(json['pricePerKwh']),
      tierOrder: serializer.fromJson<int>(json['tierOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tariffConfigurationId': serializer.toJson<int>(tariffConfigurationId),
      'minKwh': serializer.toJson<double>(minKwh),
      'maxKwh': serializer.toJson<double?>(maxKwh),
      'pricePerKwh': serializer.toJson<double>(pricePerKwh),
      'tierOrder': serializer.toJson<int>(tierOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TariffTier copyWith({
    int? id,
    int? tariffConfigurationId,
    double? minKwh,
    Value<double?> maxKwh = const Value.absent(),
    double? pricePerKwh,
    int? tierOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TariffTier(
    id: id ?? this.id,
    tariffConfigurationId: tariffConfigurationId ?? this.tariffConfigurationId,
    minKwh: minKwh ?? this.minKwh,
    maxKwh: maxKwh.present ? maxKwh.value : this.maxKwh,
    pricePerKwh: pricePerKwh ?? this.pricePerKwh,
    tierOrder: tierOrder ?? this.tierOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TariffTier copyWithCompanion(TariffTiersCompanion data) {
    return TariffTier(
      id: data.id.present ? data.id.value : this.id,
      tariffConfigurationId: data.tariffConfigurationId.present
          ? data.tariffConfigurationId.value
          : this.tariffConfigurationId,
      minKwh: data.minKwh.present ? data.minKwh.value : this.minKwh,
      maxKwh: data.maxKwh.present ? data.maxKwh.value : this.maxKwh,
      pricePerKwh: data.pricePerKwh.present
          ? data.pricePerKwh.value
          : this.pricePerKwh,
      tierOrder: data.tierOrder.present ? data.tierOrder.value : this.tierOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TariffTier(')
          ..write('id: $id, ')
          ..write('tariffConfigurationId: $tariffConfigurationId, ')
          ..write('minKwh: $minKwh, ')
          ..write('maxKwh: $maxKwh, ')
          ..write('pricePerKwh: $pricePerKwh, ')
          ..write('tierOrder: $tierOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tariffConfigurationId,
    minKwh,
    maxKwh,
    pricePerKwh,
    tierOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TariffTier &&
          other.id == this.id &&
          other.tariffConfigurationId == this.tariffConfigurationId &&
          other.minKwh == this.minKwh &&
          other.maxKwh == this.maxKwh &&
          other.pricePerKwh == this.pricePerKwh &&
          other.tierOrder == this.tierOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TariffTiersCompanion extends UpdateCompanion<TariffTier> {
  final Value<int> id;
  final Value<int> tariffConfigurationId;
  final Value<double> minKwh;
  final Value<double?> maxKwh;
  final Value<double> pricePerKwh;
  final Value<int> tierOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TariffTiersCompanion({
    this.id = const Value.absent(),
    this.tariffConfigurationId = const Value.absent(),
    this.minKwh = const Value.absent(),
    this.maxKwh = const Value.absent(),
    this.pricePerKwh = const Value.absent(),
    this.tierOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TariffTiersCompanion.insert({
    this.id = const Value.absent(),
    required int tariffConfigurationId,
    required double minKwh,
    this.maxKwh = const Value.absent(),
    required double pricePerKwh,
    required int tierOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : tariffConfigurationId = Value(tariffConfigurationId),
       minKwh = Value(minKwh),
       pricePerKwh = Value(pricePerKwh),
       tierOrder = Value(tierOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TariffTier> custom({
    Expression<int>? id,
    Expression<int>? tariffConfigurationId,
    Expression<double>? minKwh,
    Expression<double>? maxKwh,
    Expression<double>? pricePerKwh,
    Expression<int>? tierOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tariffConfigurationId != null)
        'tariff_configuration_id': tariffConfigurationId,
      if (minKwh != null) 'min_kwh': minKwh,
      if (maxKwh != null) 'max_kwh': maxKwh,
      if (pricePerKwh != null) 'price_per_kwh': pricePerKwh,
      if (tierOrder != null) 'tier_order': tierOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TariffTiersCompanion copyWith({
    Value<int>? id,
    Value<int>? tariffConfigurationId,
    Value<double>? minKwh,
    Value<double?>? maxKwh,
    Value<double>? pricePerKwh,
    Value<int>? tierOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TariffTiersCompanion(
      id: id ?? this.id,
      tariffConfigurationId:
          tariffConfigurationId ?? this.tariffConfigurationId,
      minKwh: minKwh ?? this.minKwh,
      maxKwh: maxKwh ?? this.maxKwh,
      pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      tierOrder: tierOrder ?? this.tierOrder,
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
    if (tariffConfigurationId.present) {
      map['tariff_configuration_id'] = Variable<int>(
        tariffConfigurationId.value,
      );
    }
    if (minKwh.present) {
      map['min_kwh'] = Variable<double>(minKwh.value);
    }
    if (maxKwh.present) {
      map['max_kwh'] = Variable<double>(maxKwh.value);
    }
    if (pricePerKwh.present) {
      map['price_per_kwh'] = Variable<double>(pricePerKwh.value);
    }
    if (tierOrder.present) {
      map['tier_order'] = Variable<int>(tierOrder.value);
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
    return (StringBuffer('TariffTiersCompanion(')
          ..write('id: $id, ')
          ..write('tariffConfigurationId: $tariffConfigurationId, ')
          ..write('minKwh: $minKwh, ')
          ..write('maxKwh: $maxKwh, ')
          ..write('pricePerKwh: $pricePerKwh, ')
          ..write('tierOrder: $tierOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppliancesTable appliances = $AppliancesTable(this);
  late final $TariffConfigurationsTable tariffConfigurations =
      $TariffConfigurationsTable(this);
  late final $TariffTiersTable tariffTiers = $TariffTiersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appliances,
    tariffConfigurations,
    tariffTiers,
  ];
}

typedef $$AppliancesTableCreateCompanionBuilder =
    AppliancesCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      required double powerWatts,
      Value<int> quantity,
      required double hoursPerDay,
      Value<int> daysPerMonth,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$AppliancesTableUpdateCompanionBuilder =
    AppliancesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<double> powerWatts,
      Value<int> quantity,
      Value<double> hoursPerDay,
      Value<int> daysPerMonth,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AppliancesTableFilterComposer
    extends Composer<_$AppDatabase, $AppliancesTable> {
  $$AppliancesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hoursPerDay => $composableBuilder(
    column: $table.hoursPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerMonth => $composableBuilder(
    column: $table.daysPerMonth,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppliancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppliancesTable> {
  $$AppliancesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hoursPerDay => $composableBuilder(
    column: $table.hoursPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerMonth => $composableBuilder(
    column: $table.daysPerMonth,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppliancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppliancesTable> {
  $$AppliancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get hoursPerDay => $composableBuilder(
    column: $table.hoursPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysPerMonth => $composableBuilder(
    column: $table.daysPerMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppliancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppliancesTable,
          Appliance,
          $$AppliancesTableFilterComposer,
          $$AppliancesTableOrderingComposer,
          $$AppliancesTableAnnotationComposer,
          $$AppliancesTableCreateCompanionBuilder,
          $$AppliancesTableUpdateCompanionBuilder,
          (
            Appliance,
            BaseReferences<_$AppDatabase, $AppliancesTable, Appliance>,
          ),
          Appliance,
          PrefetchHooks Function()
        > {
  $$AppliancesTableTableManager(_$AppDatabase db, $AppliancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppliancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppliancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppliancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> powerWatts = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> hoursPerDay = const Value.absent(),
                Value<int> daysPerMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppliancesCompanion(
                id: id,
                name: name,
                category: category,
                powerWatts: powerWatts,
                quantity: quantity,
                hoursPerDay: hoursPerDay,
                daysPerMonth: daysPerMonth,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                required double powerWatts,
                Value<int> quantity = const Value.absent(),
                required double hoursPerDay,
                Value<int> daysPerMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => AppliancesCompanion.insert(
                id: id,
                name: name,
                category: category,
                powerWatts: powerWatts,
                quantity: quantity,
                hoursPerDay: hoursPerDay,
                daysPerMonth: daysPerMonth,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppliancesTable, Appliance>(table),
                  BaseReferences<_$AppDatabase, $AppliancesTable, Appliance>(
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

typedef $$AppliancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppliancesTable,
      Appliance,
      $$AppliancesTableFilterComposer,
      $$AppliancesTableOrderingComposer,
      $$AppliancesTableAnnotationComposer,
      $$AppliancesTableCreateCompanionBuilder,
      $$AppliancesTableUpdateCompanionBuilder,
      (Appliance, BaseReferences<_$AppDatabase, $AppliancesTable, Appliance>),
      Appliance,
      PrefetchHooks Function()
    >;
typedef $$TariffConfigurationsTableCreateCompanionBuilder =
    TariffConfigurationsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime effectiveFrom,
      Value<DateTime?> effectiveTo,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TariffConfigurationsTableUpdateCompanionBuilder =
    TariffConfigurationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> effectiveFrom,
      Value<DateTime?> effectiveTo,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$TariffConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $TariffConfigurationsTable> {
  $$TariffConfigurationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TariffConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TariffConfigurationsTable> {
  $$TariffConfigurationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TariffConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TariffConfigurationsTable> {
  $$TariffConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TariffConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TariffConfigurationsTable,
          TariffConfiguration,
          $$TariffConfigurationsTableFilterComposer,
          $$TariffConfigurationsTableOrderingComposer,
          $$TariffConfigurationsTableAnnotationComposer,
          $$TariffConfigurationsTableCreateCompanionBuilder,
          $$TariffConfigurationsTableUpdateCompanionBuilder,
          (
            TariffConfiguration,
            BaseReferences<
              _$AppDatabase,
              $TariffConfigurationsTable,
              TariffConfiguration
            >,
          ),
          TariffConfiguration,
          PrefetchHooks Function()
        > {
  $$TariffConfigurationsTableTableManager(
    _$AppDatabase db,
    $TariffConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TariffConfigurationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TariffConfigurationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TariffConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<DateTime?> effectiveTo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TariffConfigurationsCompanion(
                id: id,
                name: name,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime effectiveFrom,
                Value<DateTime?> effectiveTo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TariffConfigurationsCompanion.insert(
                id: id,
                name: name,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TariffConfigurationsTable, TariffConfiguration>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TariffConfigurationsTable,
                    TariffConfiguration
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TariffConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TariffConfigurationsTable,
      TariffConfiguration,
      $$TariffConfigurationsTableFilterComposer,
      $$TariffConfigurationsTableOrderingComposer,
      $$TariffConfigurationsTableAnnotationComposer,
      $$TariffConfigurationsTableCreateCompanionBuilder,
      $$TariffConfigurationsTableUpdateCompanionBuilder,
      (
        TariffConfiguration,
        BaseReferences<
          _$AppDatabase,
          $TariffConfigurationsTable,
          TariffConfiguration
        >,
      ),
      TariffConfiguration,
      PrefetchHooks Function()
    >;
typedef $$TariffTiersTableCreateCompanionBuilder =
    TariffTiersCompanion Function({
      Value<int> id,
      required int tariffConfigurationId,
      required double minKwh,
      Value<double?> maxKwh,
      required double pricePerKwh,
      required int tierOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TariffTiersTableUpdateCompanionBuilder =
    TariffTiersCompanion Function({
      Value<int> id,
      Value<int> tariffConfigurationId,
      Value<double> minKwh,
      Value<double?> maxKwh,
      Value<double> pricePerKwh,
      Value<int> tierOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$TariffTiersTableFilterComposer
    extends Composer<_$AppDatabase, $TariffTiersTable> {
  $$TariffTiersTableFilterComposer({
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

  ColumnFilters<int> get tariffConfigurationId => $composableBuilder(
    column: $table.tariffConfigurationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minKwh => $composableBuilder(
    column: $table.minKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxKwh => $composableBuilder(
    column: $table.maxKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerKwh => $composableBuilder(
    column: $table.pricePerKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tierOrder => $composableBuilder(
    column: $table.tierOrder,
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

class $$TariffTiersTableOrderingComposer
    extends Composer<_$AppDatabase, $TariffTiersTable> {
  $$TariffTiersTableOrderingComposer({
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

  ColumnOrderings<int> get tariffConfigurationId => $composableBuilder(
    column: $table.tariffConfigurationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minKwh => $composableBuilder(
    column: $table.minKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxKwh => $composableBuilder(
    column: $table.maxKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerKwh => $composableBuilder(
    column: $table.pricePerKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tierOrder => $composableBuilder(
    column: $table.tierOrder,
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

class $$TariffTiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TariffTiersTable> {
  $$TariffTiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tariffConfigurationId => $composableBuilder(
    column: $table.tariffConfigurationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minKwh =>
      $composableBuilder(column: $table.minKwh, builder: (column) => column);

  GeneratedColumn<double> get maxKwh =>
      $composableBuilder(column: $table.maxKwh, builder: (column) => column);

  GeneratedColumn<double> get pricePerKwh => $composableBuilder(
    column: $table.pricePerKwh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tierOrder =>
      $composableBuilder(column: $table.tierOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TariffTiersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TariffTiersTable,
          TariffTier,
          $$TariffTiersTableFilterComposer,
          $$TariffTiersTableOrderingComposer,
          $$TariffTiersTableAnnotationComposer,
          $$TariffTiersTableCreateCompanionBuilder,
          $$TariffTiersTableUpdateCompanionBuilder,
          (
            TariffTier,
            BaseReferences<_$AppDatabase, $TariffTiersTable, TariffTier>,
          ),
          TariffTier,
          PrefetchHooks Function()
        > {
  $$TariffTiersTableTableManager(_$AppDatabase db, $TariffTiersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TariffTiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TariffTiersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TariffTiersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tariffConfigurationId = const Value.absent(),
                Value<double> minKwh = const Value.absent(),
                Value<double?> maxKwh = const Value.absent(),
                Value<double> pricePerKwh = const Value.absent(),
                Value<int> tierOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TariffTiersCompanion(
                id: id,
                tariffConfigurationId: tariffConfigurationId,
                minKwh: minKwh,
                maxKwh: maxKwh,
                pricePerKwh: pricePerKwh,
                tierOrder: tierOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tariffConfigurationId,
                required double minKwh,
                Value<double?> maxKwh = const Value.absent(),
                required double pricePerKwh,
                required int tierOrder,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TariffTiersCompanion.insert(
                id: id,
                tariffConfigurationId: tariffConfigurationId,
                minKwh: minKwh,
                maxKwh: maxKwh,
                pricePerKwh: pricePerKwh,
                tierOrder: tierOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TariffTiersTable, TariffTier>(table),
                  BaseReferences<_$AppDatabase, $TariffTiersTable, TariffTier>(
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

typedef $$TariffTiersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TariffTiersTable,
      TariffTier,
      $$TariffTiersTableFilterComposer,
      $$TariffTiersTableOrderingComposer,
      $$TariffTiersTableAnnotationComposer,
      $$TariffTiersTableCreateCompanionBuilder,
      $$TariffTiersTableUpdateCompanionBuilder,
      (
        TariffTier,
        BaseReferences<_$AppDatabase, $TariffTiersTable, TariffTier>,
      ),
      TariffTier,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppliancesTableTableManager get appliances =>
      $$AppliancesTableTableManager(_db, _db.appliances);
  $$TariffConfigurationsTableTableManager get tariffConfigurations =>
      $$TariffConfigurationsTableTableManager(_db, _db.tariffConfigurations);
  $$TariffTiersTableTableManager get tariffTiers =>
      $$TariffTiersTableTableManager(_db, _db.tariffTiers);
}
