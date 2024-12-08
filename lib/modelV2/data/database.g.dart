// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  const Category({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Category copyWith({int? id, String? name}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $LogsTable extends Logs with TableInfo<$LogsTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _supplementMeta =
      const VerificationMeta('supplement');
  @override
  late final GeneratedColumn<String> supplement = GeneratedColumn<String>(
      'supplement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registeredAtMeta =
      const VerificationMeta('registeredAt');
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
      'registered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confirmedMeta =
      const VerificationMeta('confirmed');
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
      'confirmed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("confirmed" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryId, supplement, registeredAt, amount, imageUrl, confirmed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs';
  @override
  VerificationContext validateIntegrity(Insertable<Log> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('supplement')) {
      context.handle(
          _supplementMeta,
          supplement.isAcceptableOrUnknown(
              data['supplement']!, _supplementMeta));
    } else if (isInserting) {
      context.missing(_supplementMeta);
    }
    if (data.containsKey('registered_at')) {
      context.handle(
          _registeredAtMeta,
          registeredAt.isAcceptableOrUnknown(
              data['registered_at']!, _registeredAtMeta));
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('confirmed')) {
      context.handle(_confirmedMeta,
          confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta));
    } else if (isInserting) {
      context.missing(_confirmedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      supplement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplement'])!,
      registeredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}registered_at'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      confirmed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}confirmed'])!,
    );
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }
}

class Log extends DataClass implements Insertable<Log> {
  final int id;
  final int categoryId;
  final String supplement;
  final DateTime registeredAt;
  final int amount;
  final String? imageUrl;
  final bool confirmed;
  const Log(
      {required this.id,
      required this.categoryId,
      required this.supplement,
      required this.registeredAt,
      required this.amount,
      this.imageUrl,
      required this.confirmed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['supplement'] = Variable<String>(supplement);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['confirmed'] = Variable<bool>(confirmed);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      supplement: Value(supplement),
      registeredAt: Value(registeredAt),
      amount: Value(amount),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      confirmed: Value(confirmed),
    );
  }

  factory Log.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      supplement: serializer.fromJson<String>(json['supplement']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      amount: serializer.fromJson<int>(json['amount']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'supplement': serializer.toJson<String>(supplement),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'amount': serializer.toJson<int>(amount),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'confirmed': serializer.toJson<bool>(confirmed),
    };
  }

  Log copyWith(
          {int? id,
          int? categoryId,
          String? supplement,
          DateTime? registeredAt,
          int? amount,
          Value<String?> imageUrl = const Value.absent(),
          bool? confirmed}) =>
      Log(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        supplement: supplement ?? this.supplement,
        registeredAt: registeredAt ?? this.registeredAt,
        amount: amount ?? this.amount,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        confirmed: confirmed ?? this.confirmed,
      );
  Log copyWithCompanion(LogsCompanion data) {
    return Log(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      supplement:
          data.supplement.present ? data.supplement.value : this.supplement,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      amount: data.amount.present ? data.amount.value : this.amount,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('supplement: $supplement, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('amount: $amount, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('confirmed: $confirmed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, categoryId, supplement, registeredAt, amount, imageUrl, confirmed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.supplement == this.supplement &&
          other.registeredAt == this.registeredAt &&
          other.amount == this.amount &&
          other.imageUrl == this.imageUrl &&
          other.confirmed == this.confirmed);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> supplement;
  final Value<DateTime> registeredAt;
  final Value<int> amount;
  final Value<String?> imageUrl;
  final Value<bool> confirmed;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.supplement = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.amount = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.confirmed = const Value.absent(),
  });
  LogsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String supplement,
    required DateTime registeredAt,
    required int amount,
    this.imageUrl = const Value.absent(),
    required bool confirmed,
  })  : categoryId = Value(categoryId),
        supplement = Value(supplement),
        registeredAt = Value(registeredAt),
        amount = Value(amount),
        confirmed = Value(confirmed);
  static Insertable<Log> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? supplement,
    Expression<DateTime>? registeredAt,
    Expression<int>? amount,
    Expression<String>? imageUrl,
    Expression<bool>? confirmed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (supplement != null) 'supplement': supplement,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (amount != null) 'amount': amount,
      if (imageUrl != null) 'image_url': imageUrl,
      if (confirmed != null) 'confirmed': confirmed,
    });
  }

  LogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? supplement,
      Value<DateTime>? registeredAt,
      Value<int>? amount,
      Value<String?>? imageUrl,
      Value<bool>? confirmed}) {
    return LogsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      supplement: supplement ?? this.supplement,
      registeredAt: registeredAt ?? this.registeredAt,
      amount: amount ?? this.amount,
      imageUrl: imageUrl ?? this.imageUrl,
      confirmed: confirmed ?? this.confirmed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (supplement.present) {
      map['supplement'] = Variable<String>(supplement.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('supplement: $supplement, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('amount: $amount, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('confirmed: $confirmed')
          ..write(')'))
        .toString();
  }
}

class $DisplaysTable extends Displays with TableInfo<$DisplaysTable, Display> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisplaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _periodInDaysMeta =
      const VerificationMeta('periodInDays');
  @override
  late final GeneratedColumn<int> periodInDays = GeneratedColumn<int>(
      'period_in_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _periodBeginMeta =
      const VerificationMeta('periodBegin');
  @override
  late final GeneratedColumn<DateTime> periodBegin = GeneratedColumn<DateTime>(
      'period_begin', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumnWithTypeConverter<DisplayContentType, int>
      contentType = GeneratedColumn<int>('content_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DisplayContentType>(
              $DisplaysTable.$convertercontentType);
  @override
  List<GeneratedColumn> get $columns =>
      [id, periodInDays, periodBegin, periodEnd, contentType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'displays';
  @override
  VerificationContext validateIntegrity(Insertable<Display> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_in_days')) {
      context.handle(
          _periodInDaysMeta,
          periodInDays.isAcceptableOrUnknown(
              data['period_in_days']!, _periodInDaysMeta));
    }
    if (data.containsKey('period_begin')) {
      context.handle(
          _periodBeginMeta,
          periodBegin.isAcceptableOrUnknown(
              data['period_begin']!, _periodBeginMeta));
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    }
    context.handle(_contentTypeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Display map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Display(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      periodInDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_in_days']),
      periodBegin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_begin']),
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end']),
      contentType: $DisplaysTable.$convertercontentType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}content_type'])!),
    );
  }

  @override
  $DisplaysTable createAlias(String alias) {
    return $DisplaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DisplayContentType, int, int>
      $convertercontentType =
      const EnumIndexConverter<DisplayContentType>(DisplayContentType.values);
}

class Display extends DataClass implements Insertable<Display> {
  final int id;
  final int? periodInDays;
  final DateTime? periodBegin;
  final DateTime? periodEnd;
  final DisplayContentType contentType;
  const Display(
      {required this.id,
      this.periodInDays,
      this.periodBegin,
      this.periodEnd,
      required this.contentType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || periodInDays != null) {
      map['period_in_days'] = Variable<int>(periodInDays);
    }
    if (!nullToAbsent || periodBegin != null) {
      map['period_begin'] = Variable<DateTime>(periodBegin);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    {
      map['content_type'] = Variable<int>(
          $DisplaysTable.$convertercontentType.toSql(contentType));
    }
    return map;
  }

  DisplaysCompanion toCompanion(bool nullToAbsent) {
    return DisplaysCompanion(
      id: Value(id),
      periodInDays: periodInDays == null && nullToAbsent
          ? const Value.absent()
          : Value(periodInDays),
      periodBegin: periodBegin == null && nullToAbsent
          ? const Value.absent()
          : Value(periodBegin),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      contentType: Value(contentType),
    );
  }

  factory Display.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Display(
      id: serializer.fromJson<int>(json['id']),
      periodInDays: serializer.fromJson<int?>(json['periodInDays']),
      periodBegin: serializer.fromJson<DateTime?>(json['periodBegin']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      contentType: $DisplaysTable.$convertercontentType
          .fromJson(serializer.fromJson<int>(json['contentType'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodInDays': serializer.toJson<int?>(periodInDays),
      'periodBegin': serializer.toJson<DateTime?>(periodBegin),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'contentType': serializer.toJson<int>(
          $DisplaysTable.$convertercontentType.toJson(contentType)),
    };
  }

  Display copyWith(
          {int? id,
          Value<int?> periodInDays = const Value.absent(),
          Value<DateTime?> periodBegin = const Value.absent(),
          Value<DateTime?> periodEnd = const Value.absent(),
          DisplayContentType? contentType}) =>
      Display(
        id: id ?? this.id,
        periodInDays:
            periodInDays.present ? periodInDays.value : this.periodInDays,
        periodBegin: periodBegin.present ? periodBegin.value : this.periodBegin,
        periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
        contentType: contentType ?? this.contentType,
      );
  Display copyWithCompanion(DisplaysCompanion data) {
    return Display(
      id: data.id.present ? data.id.value : this.id,
      periodInDays: data.periodInDays.present
          ? data.periodInDays.value
          : this.periodInDays,
      periodBegin:
          data.periodBegin.present ? data.periodBegin.value : this.periodBegin,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Display(')
          ..write('id: $id, ')
          ..write('periodInDays: $periodInDays, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('contentType: $contentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, periodInDays, periodBegin, periodEnd, contentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Display &&
          other.id == this.id &&
          other.periodInDays == this.periodInDays &&
          other.periodBegin == this.periodBegin &&
          other.periodEnd == this.periodEnd &&
          other.contentType == this.contentType);
}

class DisplaysCompanion extends UpdateCompanion<Display> {
  final Value<int> id;
  final Value<int?> periodInDays;
  final Value<DateTime?> periodBegin;
  final Value<DateTime?> periodEnd;
  final Value<DisplayContentType> contentType;
  const DisplaysCompanion({
    this.id = const Value.absent(),
    this.periodInDays = const Value.absent(),
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.contentType = const Value.absent(),
  });
  DisplaysCompanion.insert({
    this.id = const Value.absent(),
    this.periodInDays = const Value.absent(),
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
    required DisplayContentType contentType,
  }) : contentType = Value(contentType);
  static Insertable<Display> custom({
    Expression<int>? id,
    Expression<int>? periodInDays,
    Expression<DateTime>? periodBegin,
    Expression<DateTime>? periodEnd,
    Expression<int>? contentType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodInDays != null) 'period_in_days': periodInDays,
      if (periodBegin != null) 'period_begin': periodBegin,
      if (periodEnd != null) 'period_end': periodEnd,
      if (contentType != null) 'content_type': contentType,
    });
  }

  DisplaysCompanion copyWith(
      {Value<int>? id,
      Value<int?>? periodInDays,
      Value<DateTime?>? periodBegin,
      Value<DateTime?>? periodEnd,
      Value<DisplayContentType>? contentType}) {
    return DisplaysCompanion(
      id: id ?? this.id,
      periodInDays: periodInDays ?? this.periodInDays,
      periodBegin: periodBegin ?? this.periodBegin,
      periodEnd: periodEnd ?? this.periodEnd,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodInDays.present) {
      map['period_in_days'] = Variable<int>(periodInDays.value);
    }
    if (periodBegin.present) {
      map['period_begin'] = Variable<DateTime>(periodBegin.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<int>(
          $DisplaysTable.$convertercontentType.toSql(contentType.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisplaysCompanion(')
          ..write('id: $id, ')
          ..write('periodInDays: $periodInDays, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('contentType: $contentType')
          ..write(')'))
        .toString();
  }
}

class $DisplayCategoryLinksTable extends DisplayCategoryLinks
    with TableInfo<$DisplayCategoryLinksTable, DisplayCategoryLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisplayCategoryLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _displayMeta =
      const VerificationMeta('display');
  @override
  late final GeneratedColumn<int> display = GeneratedColumn<int>(
      'display', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES displays (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  @override
  List<GeneratedColumn> get $columns => [display, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'display_category_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<DisplayCategoryLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('display')) {
      context.handle(_displayMeta,
          display.isAcceptableOrUnknown(data['display']!, _displayMeta));
    } else if (isInserting) {
      context.missing(_displayMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {display, category};
  @override
  DisplayCategoryLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DisplayCategoryLink(
      display: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
    );
  }

  @override
  $DisplayCategoryLinksTable createAlias(String alias) {
    return $DisplayCategoryLinksTable(attachedDatabase, alias);
  }
}

class DisplayCategoryLink extends DataClass
    implements Insertable<DisplayCategoryLink> {
  final int display;
  final int category;
  const DisplayCategoryLink({required this.display, required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['display'] = Variable<int>(display);
    map['category'] = Variable<int>(category);
    return map;
  }

  DisplayCategoryLinksCompanion toCompanion(bool nullToAbsent) {
    return DisplayCategoryLinksCompanion(
      display: Value(display),
      category: Value(category),
    );
  }

  factory DisplayCategoryLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DisplayCategoryLink(
      display: serializer.fromJson<int>(json['display']),
      category: serializer.fromJson<int>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'display': serializer.toJson<int>(display),
      'category': serializer.toJson<int>(category),
    };
  }

  DisplayCategoryLink copyWith({int? display, int? category}) =>
      DisplayCategoryLink(
        display: display ?? this.display,
        category: category ?? this.category,
      );
  DisplayCategoryLink copyWithCompanion(DisplayCategoryLinksCompanion data) {
    return DisplayCategoryLink(
      display: data.display.present ? data.display.value : this.display,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DisplayCategoryLink(')
          ..write('display: $display, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(display, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DisplayCategoryLink &&
          other.display == this.display &&
          other.category == this.category);
}

class DisplayCategoryLinksCompanion
    extends UpdateCompanion<DisplayCategoryLink> {
  final Value<int> display;
  final Value<int> category;
  final Value<int> rowid;
  const DisplayCategoryLinksCompanion({
    this.display = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DisplayCategoryLinksCompanion.insert({
    required int display,
    required int category,
    this.rowid = const Value.absent(),
  })  : display = Value(display),
        category = Value(category);
  static Insertable<DisplayCategoryLink> custom({
    Expression<int>? display,
    Expression<int>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (display != null) 'display': display,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DisplayCategoryLinksCompanion copyWith(
      {Value<int>? display, Value<int>? category, Value<int>? rowid}) {
    return DisplayCategoryLinksCompanion(
      display: display ?? this.display,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (display.present) {
      map['display'] = Variable<int>(display.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisplayCategoryLinksCompanion(')
          ..write('display: $display, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _supplementMeta =
      const VerificationMeta('supplement');
  @override
  late final GeneratedColumn<String> supplement = GeneratedColumn<String>(
      'supplement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<DateTime> origin = GeneratedColumn<DateTime>(
      'origin', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _repeatTypeMeta =
      const VerificationMeta('repeatType');
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleRepeatType, int>
      repeatType = GeneratedColumn<int>('repeat_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ScheduleRepeatType>(
              $SchedulesTable.$converterrepeatType);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _onSundayMeta =
      const VerificationMeta('onSunday');
  @override
  late final GeneratedColumn<bool> onSunday = GeneratedColumn<bool>(
      'on_sunday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("on_sunday" IN (0, 1))'));
  static const VerificationMeta _onMondayMeta =
      const VerificationMeta('onMonday');
  @override
  late final GeneratedColumn<bool> onMonday = GeneratedColumn<bool>(
      'on_monday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("on_monday" IN (0, 1))'));
  static const VerificationMeta _onTuesdayMeta =
      const VerificationMeta('onTuesday');
  @override
  late final GeneratedColumn<bool> onTuesday = GeneratedColumn<bool>(
      'on_tuesday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("on_tuesday" IN (0, 1))'));
  static const VerificationMeta _onWednesdayMeta =
      const VerificationMeta('onWednesday');
  @override
  late final GeneratedColumn<bool> onWednesday = GeneratedColumn<bool>(
      'on_wednesday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("on_wednesday" IN (0, 1))'));
  static const VerificationMeta _onThursdayMeta =
      const VerificationMeta('onThursday');
  @override
  late final GeneratedColumn<bool> onThursday = GeneratedColumn<bool>(
      'on_thursday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("on_thursday" IN (0, 1))'));
  static const VerificationMeta _onFridayMeta =
      const VerificationMeta('onFriday');
  @override
  late final GeneratedColumn<bool> onFriday = GeneratedColumn<bool>(
      'on_friday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("on_friday" IN (0, 1))'));
  static const VerificationMeta _onSaturdayMeta =
      const VerificationMeta('onSaturday');
  @override
  late final GeneratedColumn<bool> onSaturday = GeneratedColumn<bool>(
      'on_saturday', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("on_saturday" IN (0, 1))'));
  static const VerificationMeta _monthlyHeadOriginMeta =
      const VerificationMeta('monthlyHeadOrigin');
  @override
  late final GeneratedColumn<int> monthlyHeadOrigin = GeneratedColumn<int>(
      'monthly_head_origin', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthlyTailOriginMeta =
      const VerificationMeta('monthlyTailOrigin');
  @override
  late final GeneratedColumn<int> monthlyTailOrigin = GeneratedColumn<int>(
      'monthly_tail_origin', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodBeginMeta =
      const VerificationMeta('periodBegin');
  @override
  late final GeneratedColumn<DateTime> periodBegin = GeneratedColumn<DateTime>(
      'period_begin', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        supplement,
        amount,
        origin,
        repeatType,
        interval,
        onSunday,
        onMonday,
        onTuesday,
        onWednesday,
        onThursday,
        onFriday,
        onSaturday,
        monthlyHeadOrigin,
        monthlyTailOrigin,
        periodBegin,
        periodEnd
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('supplement')) {
      context.handle(
          _supplementMeta,
          supplement.isAcceptableOrUnknown(
              data['supplement']!, _supplementMeta));
    } else if (isInserting) {
      context.missing(_supplementMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    context.handle(_repeatTypeMeta, const VerificationResult.success());
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('on_sunday')) {
      context.handle(_onSundayMeta,
          onSunday.isAcceptableOrUnknown(data['on_sunday']!, _onSundayMeta));
    } else if (isInserting) {
      context.missing(_onSundayMeta);
    }
    if (data.containsKey('on_monday')) {
      context.handle(_onMondayMeta,
          onMonday.isAcceptableOrUnknown(data['on_monday']!, _onMondayMeta));
    } else if (isInserting) {
      context.missing(_onMondayMeta);
    }
    if (data.containsKey('on_tuesday')) {
      context.handle(_onTuesdayMeta,
          onTuesday.isAcceptableOrUnknown(data['on_tuesday']!, _onTuesdayMeta));
    } else if (isInserting) {
      context.missing(_onTuesdayMeta);
    }
    if (data.containsKey('on_wednesday')) {
      context.handle(
          _onWednesdayMeta,
          onWednesday.isAcceptableOrUnknown(
              data['on_wednesday']!, _onWednesdayMeta));
    } else if (isInserting) {
      context.missing(_onWednesdayMeta);
    }
    if (data.containsKey('on_thursday')) {
      context.handle(
          _onThursdayMeta,
          onThursday.isAcceptableOrUnknown(
              data['on_thursday']!, _onThursdayMeta));
    } else if (isInserting) {
      context.missing(_onThursdayMeta);
    }
    if (data.containsKey('on_friday')) {
      context.handle(_onFridayMeta,
          onFriday.isAcceptableOrUnknown(data['on_friday']!, _onFridayMeta));
    } else if (isInserting) {
      context.missing(_onFridayMeta);
    }
    if (data.containsKey('on_saturday')) {
      context.handle(
          _onSaturdayMeta,
          onSaturday.isAcceptableOrUnknown(
              data['on_saturday']!, _onSaturdayMeta));
    } else if (isInserting) {
      context.missing(_onSaturdayMeta);
    }
    if (data.containsKey('monthly_head_origin')) {
      context.handle(
          _monthlyHeadOriginMeta,
          monthlyHeadOrigin.isAcceptableOrUnknown(
              data['monthly_head_origin']!, _monthlyHeadOriginMeta));
    } else if (isInserting) {
      context.missing(_monthlyHeadOriginMeta);
    }
    if (data.containsKey('monthly_tail_origin')) {
      context.handle(
          _monthlyTailOriginMeta,
          monthlyTailOrigin.isAcceptableOrUnknown(
              data['monthly_tail_origin']!, _monthlyTailOriginMeta));
    } else if (isInserting) {
      context.missing(_monthlyTailOriginMeta);
    }
    if (data.containsKey('period_begin')) {
      context.handle(
          _periodBeginMeta,
          periodBegin.isAcceptableOrUnknown(
              data['period_begin']!, _periodBeginMeta));
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
      supplement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplement'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}origin'])!,
      repeatType: $SchedulesTable.$converterrepeatType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repeat_type'])!),
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval']),
      onSunday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_sunday'])!,
      onMonday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_monday'])!,
      onTuesday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_tuesday'])!,
      onWednesday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_wednesday'])!,
      onThursday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_thursday'])!,
      onFriday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_friday'])!,
      onSaturday: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}on_saturday'])!,
      monthlyHeadOrigin: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}monthly_head_origin'])!,
      monthlyTailOrigin: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}monthly_tail_origin'])!,
      periodBegin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_begin']),
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end']),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleRepeatType, int, int> $converterrepeatType =
      const EnumIndexConverter<ScheduleRepeatType>(ScheduleRepeatType.values);
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final int category;
  final String supplement;
  final int amount;
  final DateTime origin;
  final ScheduleRepeatType repeatType;
  final int? interval;
  final bool onSunday;
  final bool onMonday;
  final bool onTuesday;
  final bool onWednesday;
  final bool onThursday;
  final bool onFriday;
  final bool onSaturday;
  final int monthlyHeadOrigin;
  final int monthlyTailOrigin;
  final DateTime? periodBegin;
  final DateTime? periodEnd;
  const Schedule(
      {required this.id,
      required this.category,
      required this.supplement,
      required this.amount,
      required this.origin,
      required this.repeatType,
      this.interval,
      required this.onSunday,
      required this.onMonday,
      required this.onTuesday,
      required this.onWednesday,
      required this.onThursday,
      required this.onFriday,
      required this.onSaturday,
      required this.monthlyHeadOrigin,
      required this.monthlyTailOrigin,
      this.periodBegin,
      this.periodEnd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<int>(category);
    map['supplement'] = Variable<String>(supplement);
    map['amount'] = Variable<int>(amount);
    map['origin'] = Variable<DateTime>(origin);
    {
      map['repeat_type'] =
          Variable<int>($SchedulesTable.$converterrepeatType.toSql(repeatType));
    }
    if (!nullToAbsent || interval != null) {
      map['interval'] = Variable<int>(interval);
    }
    map['on_sunday'] = Variable<bool>(onSunday);
    map['on_monday'] = Variable<bool>(onMonday);
    map['on_tuesday'] = Variable<bool>(onTuesday);
    map['on_wednesday'] = Variable<bool>(onWednesday);
    map['on_thursday'] = Variable<bool>(onThursday);
    map['on_friday'] = Variable<bool>(onFriday);
    map['on_saturday'] = Variable<bool>(onSaturday);
    map['monthly_head_origin'] = Variable<int>(monthlyHeadOrigin);
    map['monthly_tail_origin'] = Variable<int>(monthlyTailOrigin);
    if (!nullToAbsent || periodBegin != null) {
      map['period_begin'] = Variable<DateTime>(periodBegin);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      category: Value(category),
      supplement: Value(supplement),
      amount: Value(amount),
      origin: Value(origin),
      repeatType: Value(repeatType),
      interval: interval == null && nullToAbsent
          ? const Value.absent()
          : Value(interval),
      onSunday: Value(onSunday),
      onMonday: Value(onMonday),
      onTuesday: Value(onTuesday),
      onWednesday: Value(onWednesday),
      onThursday: Value(onThursday),
      onFriday: Value(onFriday),
      onSaturday: Value(onSaturday),
      monthlyHeadOrigin: Value(monthlyHeadOrigin),
      monthlyTailOrigin: Value(monthlyTailOrigin),
      periodBegin: periodBegin == null && nullToAbsent
          ? const Value.absent()
          : Value(periodBegin),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<int>(json['category']),
      supplement: serializer.fromJson<String>(json['supplement']),
      amount: serializer.fromJson<int>(json['amount']),
      origin: serializer.fromJson<DateTime>(json['origin']),
      repeatType: $SchedulesTable.$converterrepeatType
          .fromJson(serializer.fromJson<int>(json['repeatType'])),
      interval: serializer.fromJson<int?>(json['interval']),
      onSunday: serializer.fromJson<bool>(json['onSunday']),
      onMonday: serializer.fromJson<bool>(json['onMonday']),
      onTuesday: serializer.fromJson<bool>(json['onTuesday']),
      onWednesday: serializer.fromJson<bool>(json['onWednesday']),
      onThursday: serializer.fromJson<bool>(json['onThursday']),
      onFriday: serializer.fromJson<bool>(json['onFriday']),
      onSaturday: serializer.fromJson<bool>(json['onSaturday']),
      monthlyHeadOrigin: serializer.fromJson<int>(json['monthlyHeadOrigin']),
      monthlyTailOrigin: serializer.fromJson<int>(json['monthlyTailOrigin']),
      periodBegin: serializer.fromJson<DateTime?>(json['periodBegin']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<int>(category),
      'supplement': serializer.toJson<String>(supplement),
      'amount': serializer.toJson<int>(amount),
      'origin': serializer.toJson<DateTime>(origin),
      'repeatType': serializer
          .toJson<int>($SchedulesTable.$converterrepeatType.toJson(repeatType)),
      'interval': serializer.toJson<int?>(interval),
      'onSunday': serializer.toJson<bool>(onSunday),
      'onMonday': serializer.toJson<bool>(onMonday),
      'onTuesday': serializer.toJson<bool>(onTuesday),
      'onWednesday': serializer.toJson<bool>(onWednesday),
      'onThursday': serializer.toJson<bool>(onThursday),
      'onFriday': serializer.toJson<bool>(onFriday),
      'onSaturday': serializer.toJson<bool>(onSaturday),
      'monthlyHeadOrigin': serializer.toJson<int>(monthlyHeadOrigin),
      'monthlyTailOrigin': serializer.toJson<int>(monthlyTailOrigin),
      'periodBegin': serializer.toJson<DateTime?>(periodBegin),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
    };
  }

  Schedule copyWith(
          {int? id,
          int? category,
          String? supplement,
          int? amount,
          DateTime? origin,
          ScheduleRepeatType? repeatType,
          Value<int?> interval = const Value.absent(),
          bool? onSunday,
          bool? onMonday,
          bool? onTuesday,
          bool? onWednesday,
          bool? onThursday,
          bool? onFriday,
          bool? onSaturday,
          int? monthlyHeadOrigin,
          int? monthlyTailOrigin,
          Value<DateTime?> periodBegin = const Value.absent(),
          Value<DateTime?> periodEnd = const Value.absent()}) =>
      Schedule(
        id: id ?? this.id,
        category: category ?? this.category,
        supplement: supplement ?? this.supplement,
        amount: amount ?? this.amount,
        origin: origin ?? this.origin,
        repeatType: repeatType ?? this.repeatType,
        interval: interval.present ? interval.value : this.interval,
        onSunday: onSunday ?? this.onSunday,
        onMonday: onMonday ?? this.onMonday,
        onTuesday: onTuesday ?? this.onTuesday,
        onWednesday: onWednesday ?? this.onWednesday,
        onThursday: onThursday ?? this.onThursday,
        onFriday: onFriday ?? this.onFriday,
        onSaturday: onSaturday ?? this.onSaturday,
        monthlyHeadOrigin: monthlyHeadOrigin ?? this.monthlyHeadOrigin,
        monthlyTailOrigin: monthlyTailOrigin ?? this.monthlyTailOrigin,
        periodBegin: periodBegin.present ? periodBegin.value : this.periodBegin,
        periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      supplement:
          data.supplement.present ? data.supplement.value : this.supplement,
      amount: data.amount.present ? data.amount.value : this.amount,
      origin: data.origin.present ? data.origin.value : this.origin,
      repeatType:
          data.repeatType.present ? data.repeatType.value : this.repeatType,
      interval: data.interval.present ? data.interval.value : this.interval,
      onSunday: data.onSunday.present ? data.onSunday.value : this.onSunday,
      onMonday: data.onMonday.present ? data.onMonday.value : this.onMonday,
      onTuesday: data.onTuesday.present ? data.onTuesday.value : this.onTuesday,
      onWednesday:
          data.onWednesday.present ? data.onWednesday.value : this.onWednesday,
      onThursday:
          data.onThursday.present ? data.onThursday.value : this.onThursday,
      onFriday: data.onFriday.present ? data.onFriday.value : this.onFriday,
      onSaturday:
          data.onSaturday.present ? data.onSaturday.value : this.onSaturday,
      monthlyHeadOrigin: data.monthlyHeadOrigin.present
          ? data.monthlyHeadOrigin.value
          : this.monthlyHeadOrigin,
      monthlyTailOrigin: data.monthlyTailOrigin.present
          ? data.monthlyTailOrigin.value
          : this.monthlyTailOrigin,
      periodBegin:
          data.periodBegin.present ? data.periodBegin.value : this.periodBegin,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('supplement: $supplement, ')
          ..write('amount: $amount, ')
          ..write('origin: $origin, ')
          ..write('repeatType: $repeatType, ')
          ..write('interval: $interval, ')
          ..write('onSunday: $onSunday, ')
          ..write('onMonday: $onMonday, ')
          ..write('onTuesday: $onTuesday, ')
          ..write('onWednesday: $onWednesday, ')
          ..write('onThursday: $onThursday, ')
          ..write('onFriday: $onFriday, ')
          ..write('onSaturday: $onSaturday, ')
          ..write('monthlyHeadOrigin: $monthlyHeadOrigin, ')
          ..write('monthlyTailOrigin: $monthlyTailOrigin, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      supplement,
      amount,
      origin,
      repeatType,
      interval,
      onSunday,
      onMonday,
      onTuesday,
      onWednesday,
      onThursday,
      onFriday,
      onSaturday,
      monthlyHeadOrigin,
      monthlyTailOrigin,
      periodBegin,
      periodEnd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.category == this.category &&
          other.supplement == this.supplement &&
          other.amount == this.amount &&
          other.origin == this.origin &&
          other.repeatType == this.repeatType &&
          other.interval == this.interval &&
          other.onSunday == this.onSunday &&
          other.onMonday == this.onMonday &&
          other.onTuesday == this.onTuesday &&
          other.onWednesday == this.onWednesday &&
          other.onThursday == this.onThursday &&
          other.onFriday == this.onFriday &&
          other.onSaturday == this.onSaturday &&
          other.monthlyHeadOrigin == this.monthlyHeadOrigin &&
          other.monthlyTailOrigin == this.monthlyTailOrigin &&
          other.periodBegin == this.periodBegin &&
          other.periodEnd == this.periodEnd);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<int> category;
  final Value<String> supplement;
  final Value<int> amount;
  final Value<DateTime> origin;
  final Value<ScheduleRepeatType> repeatType;
  final Value<int?> interval;
  final Value<bool> onSunday;
  final Value<bool> onMonday;
  final Value<bool> onTuesday;
  final Value<bool> onWednesday;
  final Value<bool> onThursday;
  final Value<bool> onFriday;
  final Value<bool> onSaturday;
  final Value<int> monthlyHeadOrigin;
  final Value<int> monthlyTailOrigin;
  final Value<DateTime?> periodBegin;
  final Value<DateTime?> periodEnd;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.supplement = const Value.absent(),
    this.amount = const Value.absent(),
    this.origin = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.interval = const Value.absent(),
    this.onSunday = const Value.absent(),
    this.onMonday = const Value.absent(),
    this.onTuesday = const Value.absent(),
    this.onWednesday = const Value.absent(),
    this.onThursday = const Value.absent(),
    this.onFriday = const Value.absent(),
    this.onSaturday = const Value.absent(),
    this.monthlyHeadOrigin = const Value.absent(),
    this.monthlyTailOrigin = const Value.absent(),
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int category,
    required String supplement,
    required int amount,
    required DateTime origin,
    required ScheduleRepeatType repeatType,
    this.interval = const Value.absent(),
    required bool onSunday,
    required bool onMonday,
    required bool onTuesday,
    required bool onWednesday,
    required bool onThursday,
    required bool onFriday,
    required bool onSaturday,
    required int monthlyHeadOrigin,
    required int monthlyTailOrigin,
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
  })  : category = Value(category),
        supplement = Value(supplement),
        amount = Value(amount),
        origin = Value(origin),
        repeatType = Value(repeatType),
        onSunday = Value(onSunday),
        onMonday = Value(onMonday),
        onTuesday = Value(onTuesday),
        onWednesday = Value(onWednesday),
        onThursday = Value(onThursday),
        onFriday = Value(onFriday),
        onSaturday = Value(onSaturday),
        monthlyHeadOrigin = Value(monthlyHeadOrigin),
        monthlyTailOrigin = Value(monthlyTailOrigin);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<int>? category,
    Expression<String>? supplement,
    Expression<int>? amount,
    Expression<DateTime>? origin,
    Expression<int>? repeatType,
    Expression<int>? interval,
    Expression<bool>? onSunday,
    Expression<bool>? onMonday,
    Expression<bool>? onTuesday,
    Expression<bool>? onWednesday,
    Expression<bool>? onThursday,
    Expression<bool>? onFriday,
    Expression<bool>? onSaturday,
    Expression<int>? monthlyHeadOrigin,
    Expression<int>? monthlyTailOrigin,
    Expression<DateTime>? periodBegin,
    Expression<DateTime>? periodEnd,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (supplement != null) 'supplement': supplement,
      if (amount != null) 'amount': amount,
      if (origin != null) 'origin': origin,
      if (repeatType != null) 'repeat_type': repeatType,
      if (interval != null) 'interval': interval,
      if (onSunday != null) 'on_sunday': onSunday,
      if (onMonday != null) 'on_monday': onMonday,
      if (onTuesday != null) 'on_tuesday': onTuesday,
      if (onWednesday != null) 'on_wednesday': onWednesday,
      if (onThursday != null) 'on_thursday': onThursday,
      if (onFriday != null) 'on_friday': onFriday,
      if (onSaturday != null) 'on_saturday': onSaturday,
      if (monthlyHeadOrigin != null) 'monthly_head_origin': monthlyHeadOrigin,
      if (monthlyTailOrigin != null) 'monthly_tail_origin': monthlyTailOrigin,
      if (periodBegin != null) 'period_begin': periodBegin,
      if (periodEnd != null) 'period_end': periodEnd,
    });
  }

  SchedulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? category,
      Value<String>? supplement,
      Value<int>? amount,
      Value<DateTime>? origin,
      Value<ScheduleRepeatType>? repeatType,
      Value<int?>? interval,
      Value<bool>? onSunday,
      Value<bool>? onMonday,
      Value<bool>? onTuesday,
      Value<bool>? onWednesday,
      Value<bool>? onThursday,
      Value<bool>? onFriday,
      Value<bool>? onSaturday,
      Value<int>? monthlyHeadOrigin,
      Value<int>? monthlyTailOrigin,
      Value<DateTime?>? periodBegin,
      Value<DateTime?>? periodEnd}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      supplement: supplement ?? this.supplement,
      amount: amount ?? this.amount,
      origin: origin ?? this.origin,
      repeatType: repeatType ?? this.repeatType,
      interval: interval ?? this.interval,
      onSunday: onSunday ?? this.onSunday,
      onMonday: onMonday ?? this.onMonday,
      onTuesday: onTuesday ?? this.onTuesday,
      onWednesday: onWednesday ?? this.onWednesday,
      onThursday: onThursday ?? this.onThursday,
      onFriday: onFriday ?? this.onFriday,
      onSaturday: onSaturday ?? this.onSaturday,
      monthlyHeadOrigin: monthlyHeadOrigin ?? this.monthlyHeadOrigin,
      monthlyTailOrigin: monthlyTailOrigin ?? this.monthlyTailOrigin,
      periodBegin: periodBegin ?? this.periodBegin,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (supplement.present) {
      map['supplement'] = Variable<String>(supplement.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (origin.present) {
      map['origin'] = Variable<DateTime>(origin.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<int>(
          $SchedulesTable.$converterrepeatType.toSql(repeatType.value));
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (onSunday.present) {
      map['on_sunday'] = Variable<bool>(onSunday.value);
    }
    if (onMonday.present) {
      map['on_monday'] = Variable<bool>(onMonday.value);
    }
    if (onTuesday.present) {
      map['on_tuesday'] = Variable<bool>(onTuesday.value);
    }
    if (onWednesday.present) {
      map['on_wednesday'] = Variable<bool>(onWednesday.value);
    }
    if (onThursday.present) {
      map['on_thursday'] = Variable<bool>(onThursday.value);
    }
    if (onFriday.present) {
      map['on_friday'] = Variable<bool>(onFriday.value);
    }
    if (onSaturday.present) {
      map['on_saturday'] = Variable<bool>(onSaturday.value);
    }
    if (monthlyHeadOrigin.present) {
      map['monthly_head_origin'] = Variable<int>(monthlyHeadOrigin.value);
    }
    if (monthlyTailOrigin.present) {
      map['monthly_tail_origin'] = Variable<int>(monthlyTailOrigin.value);
    }
    if (periodBegin.present) {
      map['period_begin'] = Variable<DateTime>(periodBegin.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('supplement: $supplement, ')
          ..write('amount: $amount, ')
          ..write('origin: $origin, ')
          ..write('repeatType: $repeatType, ')
          ..write('interval: $interval, ')
          ..write('onSunday: $onSunday, ')
          ..write('onMonday: $onMonday, ')
          ..write('onTuesday: $onTuesday, ')
          ..write('onWednesday: $onWednesday, ')
          ..write('onThursday: $onThursday, ')
          ..write('onFriday: $onFriday, ')
          ..write('onSaturday: $onSaturday, ')
          ..write('monthlyHeadOrigin: $monthlyHeadOrigin, ')
          ..write('monthlyTailOrigin: $monthlyTailOrigin, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd')
          ..write(')'))
        .toString();
  }
}

class $EstimationsTable extends Estimations
    with TableInfo<$EstimationsTable, Estimation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstimationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _periodBeginMeta =
      const VerificationMeta('periodBegin');
  @override
  late final GeneratedColumn<DateTime> periodBegin = GeneratedColumn<DateTime>(
      'period_begin', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumnWithTypeConverter<EstimationContentType, int>
      contentType = GeneratedColumn<int>('content_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<EstimationContentType>(
              $EstimationsTable.$convertercontentType);
  @override
  List<GeneratedColumn> get $columns =>
      [id, periodBegin, periodEnd, contentType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estimations';
  @override
  VerificationContext validateIntegrity(Insertable<Estimation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_begin')) {
      context.handle(
          _periodBeginMeta,
          periodBegin.isAcceptableOrUnknown(
              data['period_begin']!, _periodBeginMeta));
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    }
    context.handle(_contentTypeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Estimation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Estimation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      periodBegin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_begin']),
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end']),
      contentType: $EstimationsTable.$convertercontentType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}content_type'])!),
    );
  }

  @override
  $EstimationsTable createAlias(String alias) {
    return $EstimationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EstimationContentType, int, int>
      $convertercontentType = const EnumIndexConverter<EstimationContentType>(
          EstimationContentType.values);
}

class Estimation extends DataClass implements Insertable<Estimation> {
  final int id;
  final DateTime? periodBegin;
  final DateTime? periodEnd;
  final EstimationContentType contentType;
  const Estimation(
      {required this.id,
      this.periodBegin,
      this.periodEnd,
      required this.contentType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || periodBegin != null) {
      map['period_begin'] = Variable<DateTime>(periodBegin);
    }
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    {
      map['content_type'] = Variable<int>(
          $EstimationsTable.$convertercontentType.toSql(contentType));
    }
    return map;
  }

  EstimationsCompanion toCompanion(bool nullToAbsent) {
    return EstimationsCompanion(
      id: Value(id),
      periodBegin: periodBegin == null && nullToAbsent
          ? const Value.absent()
          : Value(periodBegin),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
      contentType: Value(contentType),
    );
  }

  factory Estimation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Estimation(
      id: serializer.fromJson<int>(json['id']),
      periodBegin: serializer.fromJson<DateTime?>(json['periodBegin']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
      contentType: $EstimationsTable.$convertercontentType
          .fromJson(serializer.fromJson<int>(json['contentType'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodBegin': serializer.toJson<DateTime?>(periodBegin),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
      'contentType': serializer.toJson<int>(
          $EstimationsTable.$convertercontentType.toJson(contentType)),
    };
  }

  Estimation copyWith(
          {int? id,
          Value<DateTime?> periodBegin = const Value.absent(),
          Value<DateTime?> periodEnd = const Value.absent(),
          EstimationContentType? contentType}) =>
      Estimation(
        id: id ?? this.id,
        periodBegin: periodBegin.present ? periodBegin.value : this.periodBegin,
        periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
        contentType: contentType ?? this.contentType,
      );
  Estimation copyWithCompanion(EstimationsCompanion data) {
    return Estimation(
      id: data.id.present ? data.id.value : this.id,
      periodBegin:
          data.periodBegin.present ? data.periodBegin.value : this.periodBegin,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Estimation(')
          ..write('id: $id, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('contentType: $contentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodBegin, periodEnd, contentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Estimation &&
          other.id == this.id &&
          other.periodBegin == this.periodBegin &&
          other.periodEnd == this.periodEnd &&
          other.contentType == this.contentType);
}

class EstimationsCompanion extends UpdateCompanion<Estimation> {
  final Value<int> id;
  final Value<DateTime?> periodBegin;
  final Value<DateTime?> periodEnd;
  final Value<EstimationContentType> contentType;
  const EstimationsCompanion({
    this.id = const Value.absent(),
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.contentType = const Value.absent(),
  });
  EstimationsCompanion.insert({
    this.id = const Value.absent(),
    this.periodBegin = const Value.absent(),
    this.periodEnd = const Value.absent(),
    required EstimationContentType contentType,
  }) : contentType = Value(contentType);
  static Insertable<Estimation> custom({
    Expression<int>? id,
    Expression<DateTime>? periodBegin,
    Expression<DateTime>? periodEnd,
    Expression<int>? contentType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodBegin != null) 'period_begin': periodBegin,
      if (periodEnd != null) 'period_end': periodEnd,
      if (contentType != null) 'content_type': contentType,
    });
  }

  EstimationsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? periodBegin,
      Value<DateTime?>? periodEnd,
      Value<EstimationContentType>? contentType}) {
    return EstimationsCompanion(
      id: id ?? this.id,
      periodBegin: periodBegin ?? this.periodBegin,
      periodEnd: periodEnd ?? this.periodEnd,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodBegin.present) {
      map['period_begin'] = Variable<DateTime>(periodBegin.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<int>(
          $EstimationsTable.$convertercontentType.toSql(contentType.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstimationsCompanion(')
          ..write('id: $id, ')
          ..write('periodBegin: $periodBegin, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('contentType: $contentType')
          ..write(')'))
        .toString();
  }
}

class $EstimationCategoryLinksTable extends EstimationCategoryLinks
    with TableInfo<$EstimationCategoryLinksTable, EstimationCategoryLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstimationCategoryLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _estimationMeta =
      const VerificationMeta('estimation');
  @override
  late final GeneratedColumn<int> estimation = GeneratedColumn<int>(
      'estimation', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES estimations (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  @override
  List<GeneratedColumn> get $columns => [estimation, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estimation_category_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<EstimationCategoryLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('estimation')) {
      context.handle(
          _estimationMeta,
          estimation.isAcceptableOrUnknown(
              data['estimation']!, _estimationMeta));
    } else if (isInserting) {
      context.missing(_estimationMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {estimation, category};
  @override
  EstimationCategoryLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EstimationCategoryLink(
      estimation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimation'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
    );
  }

  @override
  $EstimationCategoryLinksTable createAlias(String alias) {
    return $EstimationCategoryLinksTable(attachedDatabase, alias);
  }
}

class EstimationCategoryLink extends DataClass
    implements Insertable<EstimationCategoryLink> {
  final int estimation;
  final int category;
  const EstimationCategoryLink(
      {required this.estimation, required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['estimation'] = Variable<int>(estimation);
    map['category'] = Variable<int>(category);
    return map;
  }

  EstimationCategoryLinksCompanion toCompanion(bool nullToAbsent) {
    return EstimationCategoryLinksCompanion(
      estimation: Value(estimation),
      category: Value(category),
    );
  }

  factory EstimationCategoryLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EstimationCategoryLink(
      estimation: serializer.fromJson<int>(json['estimation']),
      category: serializer.fromJson<int>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'estimation': serializer.toJson<int>(estimation),
      'category': serializer.toJson<int>(category),
    };
  }

  EstimationCategoryLink copyWith({int? estimation, int? category}) =>
      EstimationCategoryLink(
        estimation: estimation ?? this.estimation,
        category: category ?? this.category,
      );
  EstimationCategoryLink copyWithCompanion(
      EstimationCategoryLinksCompanion data) {
    return EstimationCategoryLink(
      estimation:
          data.estimation.present ? data.estimation.value : this.estimation,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EstimationCategoryLink(')
          ..write('estimation: $estimation, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(estimation, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EstimationCategoryLink &&
          other.estimation == this.estimation &&
          other.category == this.category);
}

class EstimationCategoryLinksCompanion
    extends UpdateCompanion<EstimationCategoryLink> {
  final Value<int> estimation;
  final Value<int> category;
  final Value<int> rowid;
  const EstimationCategoryLinksCompanion({
    this.estimation = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EstimationCategoryLinksCompanion.insert({
    required int estimation,
    required int category,
    this.rowid = const Value.absent(),
  })  : estimation = Value(estimation),
        category = Value(category);
  static Insertable<EstimationCategoryLink> custom({
    Expression<int>? estimation,
    Expression<int>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (estimation != null) 'estimation': estimation,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EstimationCategoryLinksCompanion copyWith(
      {Value<int>? estimation, Value<int>? category, Value<int>? rowid}) {
    return EstimationCategoryLinksCompanion(
      estimation: estimation ?? this.estimation,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (estimation.present) {
      map['estimation'] = Variable<int>(estimation.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstimationCategoryLinksCompanion(')
          ..write('estimation: $estimation, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EstimationCachesTable extends EstimationCaches
    with TableInfo<$EstimationCachesTable, EstimationCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstimationCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [category, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estimation_caches';
  @override
  VerificationContext validateIntegrity(Insertable<EstimationCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category};
  @override
  EstimationCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EstimationCache(
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
    );
  }

  @override
  $EstimationCachesTable createAlias(String alias) {
    return $EstimationCachesTable(attachedDatabase, alias);
  }
}

class EstimationCache extends DataClass implements Insertable<EstimationCache> {
  final int category;
  final int amount;
  const EstimationCache({required this.category, required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<int>(category);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  EstimationCachesCompanion toCompanion(bool nullToAbsent) {
    return EstimationCachesCompanion(
      category: Value(category),
      amount: Value(amount),
    );
  }

  factory EstimationCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EstimationCache(
      category: serializer.fromJson<int>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<int>(category),
      'amount': serializer.toJson<int>(amount),
    };
  }

  EstimationCache copyWith({int? category, int? amount}) => EstimationCache(
        category: category ?? this.category,
        amount: amount ?? this.amount,
      );
  EstimationCache copyWithCompanion(EstimationCachesCompanion data) {
    return EstimationCache(
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EstimationCache(')
          ..write('category: $category, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EstimationCache &&
          other.category == this.category &&
          other.amount == this.amount);
}

class EstimationCachesCompanion extends UpdateCompanion<EstimationCache> {
  final Value<int> category;
  final Value<int> amount;
  const EstimationCachesCompanion({
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
  });
  EstimationCachesCompanion.insert({
    this.category = const Value.absent(),
    required int amount,
  }) : amount = Value(amount);
  static Insertable<EstimationCache> custom({
    Expression<int>? category,
    Expression<int>? amount,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
    });
  }

  EstimationCachesCompanion copyWith(
      {Value<int>? category, Value<int>? amount}) {
    return EstimationCachesCompanion(
      category: category ?? this.category,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstimationCachesCompanion(')
          ..write('category: $category, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $RepeatCachesTable extends RepeatCaches
    with TableInfo<$RepeatCachesTable, RepeatCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepeatCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _registeredAtMeta =
      const VerificationMeta('registeredAt');
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
      'registered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _scheduleMeta =
      const VerificationMeta('schedule');
  @override
  late final GeneratedColumn<int> schedule = GeneratedColumn<int>(
      'schedule', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES schedules (id)'));
  static const VerificationMeta _estimationMeta =
      const VerificationMeta('estimation');
  @override
  late final GeneratedColumn<int> estimation = GeneratedColumn<int>(
      'estimation', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES estimations (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, registeredAt, schedule, estimation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repeat_caches';
  @override
  VerificationContext validateIntegrity(Insertable<RepeatCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('registered_at')) {
      context.handle(
          _registeredAtMeta,
          registeredAt.isAcceptableOrUnknown(
              data['registered_at']!, _registeredAtMeta));
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    if (data.containsKey('schedule')) {
      context.handle(_scheduleMeta,
          schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta));
    }
    if (data.containsKey('estimation')) {
      context.handle(
          _estimationMeta,
          estimation.isAcceptableOrUnknown(
              data['estimation']!, _estimationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepeatCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepeatCache(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      registeredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}registered_at'])!,
      schedule: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule']),
      estimation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimation']),
    );
  }

  @override
  $RepeatCachesTable createAlias(String alias) {
    return $RepeatCachesTable(attachedDatabase, alias);
  }
}

class RepeatCache extends DataClass implements Insertable<RepeatCache> {
  final int id;
  final DateTime registeredAt;
  final int? schedule;
  final int? estimation;
  const RepeatCache(
      {required this.id,
      required this.registeredAt,
      this.schedule,
      this.estimation});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    if (!nullToAbsent || schedule != null) {
      map['schedule'] = Variable<int>(schedule);
    }
    if (!nullToAbsent || estimation != null) {
      map['estimation'] = Variable<int>(estimation);
    }
    return map;
  }

  RepeatCachesCompanion toCompanion(bool nullToAbsent) {
    return RepeatCachesCompanion(
      id: Value(id),
      registeredAt: Value(registeredAt),
      schedule: schedule == null && nullToAbsent
          ? const Value.absent()
          : Value(schedule),
      estimation: estimation == null && nullToAbsent
          ? const Value.absent()
          : Value(estimation),
    );
  }

  factory RepeatCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepeatCache(
      id: serializer.fromJson<int>(json['id']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      schedule: serializer.fromJson<int?>(json['schedule']),
      estimation: serializer.fromJson<int?>(json['estimation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'schedule': serializer.toJson<int?>(schedule),
      'estimation': serializer.toJson<int?>(estimation),
    };
  }

  RepeatCache copyWith(
          {int? id,
          DateTime? registeredAt,
          Value<int?> schedule = const Value.absent(),
          Value<int?> estimation = const Value.absent()}) =>
      RepeatCache(
        id: id ?? this.id,
        registeredAt: registeredAt ?? this.registeredAt,
        schedule: schedule.present ? schedule.value : this.schedule,
        estimation: estimation.present ? estimation.value : this.estimation,
      );
  RepeatCache copyWithCompanion(RepeatCachesCompanion data) {
    return RepeatCache(
      id: data.id.present ? data.id.value : this.id,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      estimation:
          data.estimation.present ? data.estimation.value : this.estimation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepeatCache(')
          ..write('id: $id, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('schedule: $schedule, ')
          ..write('estimation: $estimation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, registeredAt, schedule, estimation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepeatCache &&
          other.id == this.id &&
          other.registeredAt == this.registeredAt &&
          other.schedule == this.schedule &&
          other.estimation == this.estimation);
}

class RepeatCachesCompanion extends UpdateCompanion<RepeatCache> {
  final Value<int> id;
  final Value<DateTime> registeredAt;
  final Value<int?> schedule;
  final Value<int?> estimation;
  const RepeatCachesCompanion({
    this.id = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.schedule = const Value.absent(),
    this.estimation = const Value.absent(),
  });
  RepeatCachesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime registeredAt,
    this.schedule = const Value.absent(),
    this.estimation = const Value.absent(),
  }) : registeredAt = Value(registeredAt);
  static Insertable<RepeatCache> custom({
    Expression<int>? id,
    Expression<DateTime>? registeredAt,
    Expression<int>? schedule,
    Expression<int>? estimation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (schedule != null) 'schedule': schedule,
      if (estimation != null) 'estimation': estimation,
    });
  }

  RepeatCachesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? registeredAt,
      Value<int?>? schedule,
      Value<int?>? estimation}) {
    return RepeatCachesCompanion(
      id: id ?? this.id,
      registeredAt: registeredAt ?? this.registeredAt,
      schedule: schedule ?? this.schedule,
      estimation: estimation ?? this.estimation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<int>(schedule.value);
    }
    if (estimation.present) {
      map['estimation'] = Variable<int>(estimation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepeatCachesCompanion(')
          ..write('id: $id, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('schedule: $schedule, ')
          ..write('estimation: $estimation')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $LogsTable logs = $LogsTable(this);
  late final $DisplaysTable displays = $DisplaysTable(this);
  late final $DisplayCategoryLinksTable displayCategoryLinks =
      $DisplayCategoryLinksTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $EstimationsTable estimations = $EstimationsTable(this);
  late final $EstimationCategoryLinksTable estimationCategoryLinks =
      $EstimationCategoryLinksTable(this);
  late final $EstimationCachesTable estimationCaches =
      $EstimationCachesTable(this);
  late final $RepeatCachesTable repeatCaches = $RepeatCachesTable(this);
  late final Index date =
      Index('date', 'CREATE INDEX date ON logs (registered_at)');
  late final Index period = Index(
      'period', 'CREATE INDEX period ON displays (period_begin, period_end)');
  late final CategoryAccessor categoryAccessor =
      CategoryAccessor(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        logs,
        displays,
        displayCategoryLinks,
        schedules,
        estimations,
        estimationCategoryLinks,
        estimationCaches,
        repeatCaches,
        date,
        period
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LogsTable, List<Log>> _logsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.logs,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.logs.categoryId));

  $$LogsTableProcessedTableManager get logsRefs {
    final manager = $$LogsTableTableManager($_db, $_db.logs)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_logsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DisplayCategoryLinksTable,
      List<DisplayCategoryLink>> _displayCategoryLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.displayCategoryLinks,
          aliasName: $_aliasNameGenerator(
              db.categories.id, db.displayCategoryLinks.category));

  $$DisplayCategoryLinksTableProcessedTableManager
      get displayCategoryLinksRefs {
    final manager =
        $$DisplayCategoryLinksTableTableManager($_db, $_db.displayCategoryLinks)
            .filter((f) => f.category.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_displayCategoryLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
      _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.schedules,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.schedules.category));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.category.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EstimationCategoryLinksTable,
      List<EstimationCategoryLink>> _estimationCategoryLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.estimationCategoryLinks,
          aliasName: $_aliasNameGenerator(
              db.categories.id, db.estimationCategoryLinks.category));

  $$EstimationCategoryLinksTableProcessedTableManager
      get estimationCategoryLinksRefs {
    final manager = $$EstimationCategoryLinksTableTableManager(
            $_db, $_db.estimationCategoryLinks)
        .filter((f) => f.category.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_estimationCategoryLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EstimationCachesTable, List<EstimationCache>>
      _estimationCachesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.estimationCaches,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.estimationCaches.category));

  $$EstimationCachesTableProcessedTableManager get estimationCachesRefs {
    final manager =
        $$EstimationCachesTableTableManager($_db, $_db.estimationCaches)
            .filter((f) => f.category.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_estimationCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> logsRefs(
      Expression<bool> Function($$LogsTableFilterComposer f) f) {
    final $$LogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.logs,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LogsTableFilterComposer(
              $db: $db,
              $table: $db.logs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> displayCategoryLinksRefs(
      Expression<bool> Function($$DisplayCategoryLinksTableFilterComposer f)
          f) {
    final $$DisplayCategoryLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.displayCategoryLinks,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DisplayCategoryLinksTableFilterComposer(
              $db: $db,
              $table: $db.displayCategoryLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> estimationCategoryLinksRefs(
      Expression<bool> Function($$EstimationCategoryLinksTableFilterComposer f)
          f) {
    final $$EstimationCategoryLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.estimationCategoryLinks,
            getReferencedColumn: (t) => t.category,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$EstimationCategoryLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.estimationCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> estimationCachesRefs(
      Expression<bool> Function($$EstimationCachesTableFilterComposer f) f) {
    final $$EstimationCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.estimationCaches,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationCachesTableFilterComposer(
              $db: $db,
              $table: $db.estimationCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  Expression<T> logsRefs<T extends Object>(
      Expression<T> Function($$LogsTableAnnotationComposer a) f) {
    final $$LogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.logs,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LogsTableAnnotationComposer(
              $db: $db,
              $table: $db.logs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> displayCategoryLinksRefs<T extends Object>(
      Expression<T> Function($$DisplayCategoryLinksTableAnnotationComposer a)
          f) {
    final $$DisplayCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.displayCategoryLinks,
            getReferencedColumn: (t) => t.category,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DisplayCategoryLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.displayCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> estimationCategoryLinksRefs<T extends Object>(
      Expression<T> Function($$EstimationCategoryLinksTableAnnotationComposer a)
          f) {
    final $$EstimationCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.estimationCategoryLinks,
            getReferencedColumn: (t) => t.category,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$EstimationCategoryLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.estimationCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> estimationCachesRefs<T extends Object>(
      Expression<T> Function($$EstimationCachesTableAnnotationComposer a) f) {
    final $$EstimationCachesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.estimationCaches,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationCachesTableAnnotationComposer(
              $db: $db,
              $table: $db.estimationCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool logsRefs,
        bool displayCategoryLinksRefs,
        bool schedulesRefs,
        bool estimationCategoryLinksRefs,
        bool estimationCachesRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {logsRefs = false,
              displayCategoryLinksRefs = false,
              schedulesRefs = false,
              estimationCategoryLinksRefs = false,
              estimationCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (logsRefs) db.logs,
                if (displayCategoryLinksRefs) db.displayCategoryLinks,
                if (schedulesRefs) db.schedules,
                if (estimationCategoryLinksRefs) db.estimationCategoryLinks,
                if (estimationCachesRefs) db.estimationCaches
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (logsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._logsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0).logsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (displayCategoryLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._displayCategoryLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .displayCategoryLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.category == item.id),
                        typedResults: items),
                  if (schedulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .schedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.category == item.id),
                        typedResults: items),
                  if (estimationCategoryLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._estimationCategoryLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .estimationCategoryLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.category == item.id),
                        typedResults: items),
                  if (estimationCachesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._estimationCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .estimationCachesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.category == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool logsRefs,
        bool displayCategoryLinksRefs,
        bool schedulesRefs,
        bool estimationCategoryLinksRefs,
        bool estimationCachesRefs})>;
typedef $$LogsTableCreateCompanionBuilder = LogsCompanion Function({
  Value<int> id,
  required int categoryId,
  required String supplement,
  required DateTime registeredAt,
  required int amount,
  Value<String?> imageUrl,
  required bool confirmed,
});
typedef $$LogsTableUpdateCompanionBuilder = LogsCompanion Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> supplement,
  Value<DateTime> registeredAt,
  Value<int> amount,
  Value<String?> imageUrl,
  Value<bool> confirmed,
});

final class $$LogsTableReferences
    extends BaseReferences<_$AppDatabase, $LogsTable, Log> {
  $$LogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.logs.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LogsTableFilterComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get confirmed => $composableBuilder(
      column: $table.confirmed, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogsTableOrderingComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get confirmed => $composableBuilder(
      column: $table.confirmed, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LogsTable,
    Log,
    $$LogsTableFilterComposer,
    $$LogsTableOrderingComposer,
    $$LogsTableAnnotationComposer,
    $$LogsTableCreateCompanionBuilder,
    $$LogsTableUpdateCompanionBuilder,
    (Log, $$LogsTableReferences),
    Log,
    PrefetchHooks Function({bool categoryId})> {
  $$LogsTableTableManager(_$AppDatabase db, $LogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> supplement = const Value.absent(),
            Value<DateTime> registeredAt = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<bool> confirmed = const Value.absent(),
          }) =>
              LogsCompanion(
            id: id,
            categoryId: categoryId,
            supplement: supplement,
            registeredAt: registeredAt,
            amount: amount,
            imageUrl: imageUrl,
            confirmed: confirmed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String supplement,
            required DateTime registeredAt,
            required int amount,
            Value<String?> imageUrl = const Value.absent(),
            required bool confirmed,
          }) =>
              LogsCompanion.insert(
            id: id,
            categoryId: categoryId,
            supplement: supplement,
            registeredAt: registeredAt,
            amount: amount,
            imageUrl: imageUrl,
            confirmed: confirmed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LogsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$LogsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$LogsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LogsTable,
    Log,
    $$LogsTableFilterComposer,
    $$LogsTableOrderingComposer,
    $$LogsTableAnnotationComposer,
    $$LogsTableCreateCompanionBuilder,
    $$LogsTableUpdateCompanionBuilder,
    (Log, $$LogsTableReferences),
    Log,
    PrefetchHooks Function({bool categoryId})>;
typedef $$DisplaysTableCreateCompanionBuilder = DisplaysCompanion Function({
  Value<int> id,
  Value<int?> periodInDays,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
  required DisplayContentType contentType,
});
typedef $$DisplaysTableUpdateCompanionBuilder = DisplaysCompanion Function({
  Value<int> id,
  Value<int?> periodInDays,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
  Value<DisplayContentType> contentType,
});

final class $$DisplaysTableReferences
    extends BaseReferences<_$AppDatabase, $DisplaysTable, Display> {
  $$DisplaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DisplayCategoryLinksTable,
      List<DisplayCategoryLink>> _displayCategoryLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.displayCategoryLinks,
          aliasName: $_aliasNameGenerator(
              db.displays.id, db.displayCategoryLinks.display));

  $$DisplayCategoryLinksTableProcessedTableManager
      get displayCategoryLinksRefs {
    final manager =
        $$DisplayCategoryLinksTableTableManager($_db, $_db.displayCategoryLinks)
            .filter((f) => f.display.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_displayCategoryLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DisplaysTableFilterComposer
    extends Composer<_$AppDatabase, $DisplaysTable> {
  $$DisplaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodInDays => $composableBuilder(
      column: $table.periodInDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DisplayContentType, DisplayContentType, int>
      get contentType => $composableBuilder(
          column: $table.contentType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> displayCategoryLinksRefs(
      Expression<bool> Function($$DisplayCategoryLinksTableFilterComposer f)
          f) {
    final $$DisplayCategoryLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.displayCategoryLinks,
        getReferencedColumn: (t) => t.display,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DisplayCategoryLinksTableFilterComposer(
              $db: $db,
              $table: $db.displayCategoryLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DisplaysTableOrderingComposer
    extends Composer<_$AppDatabase, $DisplaysTable> {
  $$DisplaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodInDays => $composableBuilder(
      column: $table.periodInDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnOrderings(column));
}

class $$DisplaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $DisplaysTable> {
  $$DisplaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get periodInDays => $composableBuilder(
      column: $table.periodInDays, builder: (column) => column);

  GeneratedColumn<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DisplayContentType, int> get contentType =>
      $composableBuilder(
          column: $table.contentType, builder: (column) => column);

  Expression<T> displayCategoryLinksRefs<T extends Object>(
      Expression<T> Function($$DisplayCategoryLinksTableAnnotationComposer a)
          f) {
    final $$DisplayCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.displayCategoryLinks,
            getReferencedColumn: (t) => t.display,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DisplayCategoryLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.displayCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$DisplaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DisplaysTable,
    Display,
    $$DisplaysTableFilterComposer,
    $$DisplaysTableOrderingComposer,
    $$DisplaysTableAnnotationComposer,
    $$DisplaysTableCreateCompanionBuilder,
    $$DisplaysTableUpdateCompanionBuilder,
    (Display, $$DisplaysTableReferences),
    Display,
    PrefetchHooks Function({bool displayCategoryLinksRefs})> {
  $$DisplaysTableTableManager(_$AppDatabase db, $DisplaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisplaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisplaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisplaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> periodInDays = const Value.absent(),
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            Value<DisplayContentType> contentType = const Value.absent(),
          }) =>
              DisplaysCompanion(
            id: id,
            periodInDays: periodInDays,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
            contentType: contentType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> periodInDays = const Value.absent(),
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            required DisplayContentType contentType,
          }) =>
              DisplaysCompanion.insert(
            id: id,
            periodInDays: periodInDays,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
            contentType: contentType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DisplaysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({displayCategoryLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (displayCategoryLinksRefs) db.displayCategoryLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (displayCategoryLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DisplaysTableReferences
                            ._displayCategoryLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DisplaysTableReferences(db, table, p0)
                                .displayCategoryLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.display == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DisplaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DisplaysTable,
    Display,
    $$DisplaysTableFilterComposer,
    $$DisplaysTableOrderingComposer,
    $$DisplaysTableAnnotationComposer,
    $$DisplaysTableCreateCompanionBuilder,
    $$DisplaysTableUpdateCompanionBuilder,
    (Display, $$DisplaysTableReferences),
    Display,
    PrefetchHooks Function({bool displayCategoryLinksRefs})>;
typedef $$DisplayCategoryLinksTableCreateCompanionBuilder
    = DisplayCategoryLinksCompanion Function({
  required int display,
  required int category,
  Value<int> rowid,
});
typedef $$DisplayCategoryLinksTableUpdateCompanionBuilder
    = DisplayCategoryLinksCompanion Function({
  Value<int> display,
  Value<int> category,
  Value<int> rowid,
});

final class $$DisplayCategoryLinksTableReferences extends BaseReferences<
    _$AppDatabase, $DisplayCategoryLinksTable, DisplayCategoryLink> {
  $$DisplayCategoryLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DisplaysTable _displayTable(_$AppDatabase db) =>
      db.displays.createAlias($_aliasNameGenerator(
          db.displayCategoryLinks.display, db.displays.id));

  $$DisplaysTableProcessedTableManager get display {
    final manager = $$DisplaysTableTableManager($_db, $_db.displays)
        .filter((f) => f.id($_item.display!));
    final item = $_typedResult.readTableOrNull(_displayTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.displayCategoryLinks.category, db.categories.id));

  $$CategoriesTableProcessedTableManager get category {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.category!));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DisplayCategoryLinksTableFilterComposer
    extends Composer<_$AppDatabase, $DisplayCategoryLinksTable> {
  $$DisplayCategoryLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DisplaysTableFilterComposer get display {
    final $$DisplaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.display,
        referencedTable: $db.displays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DisplaysTableFilterComposer(
              $db: $db,
              $table: $db.displays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get category {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DisplayCategoryLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $DisplayCategoryLinksTable> {
  $$DisplayCategoryLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DisplaysTableOrderingComposer get display {
    final $$DisplaysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.display,
        referencedTable: $db.displays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DisplaysTableOrderingComposer(
              $db: $db,
              $table: $db.displays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get category {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DisplayCategoryLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DisplayCategoryLinksTable> {
  $$DisplayCategoryLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$DisplaysTableAnnotationComposer get display {
    final $$DisplaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.display,
        referencedTable: $db.displays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DisplaysTableAnnotationComposer(
              $db: $db,
              $table: $db.displays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get category {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DisplayCategoryLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DisplayCategoryLinksTable,
    DisplayCategoryLink,
    $$DisplayCategoryLinksTableFilterComposer,
    $$DisplayCategoryLinksTableOrderingComposer,
    $$DisplayCategoryLinksTableAnnotationComposer,
    $$DisplayCategoryLinksTableCreateCompanionBuilder,
    $$DisplayCategoryLinksTableUpdateCompanionBuilder,
    (DisplayCategoryLink, $$DisplayCategoryLinksTableReferences),
    DisplayCategoryLink,
    PrefetchHooks Function({bool display, bool category})> {
  $$DisplayCategoryLinksTableTableManager(
      _$AppDatabase db, $DisplayCategoryLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisplayCategoryLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisplayCategoryLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisplayCategoryLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> display = const Value.absent(),
            Value<int> category = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DisplayCategoryLinksCompanion(
            display: display,
            category: category,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int display,
            required int category,
            Value<int> rowid = const Value.absent(),
          }) =>
              DisplayCategoryLinksCompanion.insert(
            display: display,
            category: category,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DisplayCategoryLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({display = false, category = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (display) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.display,
                    referencedTable:
                        $$DisplayCategoryLinksTableReferences._displayTable(db),
                    referencedColumn: $$DisplayCategoryLinksTableReferences
                        ._displayTable(db)
                        .id,
                  ) as T;
                }
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable: $$DisplayCategoryLinksTableReferences
                        ._categoryTable(db),
                    referencedColumn: $$DisplayCategoryLinksTableReferences
                        ._categoryTable(db)
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
        ));
}

typedef $$DisplayCategoryLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DisplayCategoryLinksTable,
        DisplayCategoryLink,
        $$DisplayCategoryLinksTableFilterComposer,
        $$DisplayCategoryLinksTableOrderingComposer,
        $$DisplayCategoryLinksTableAnnotationComposer,
        $$DisplayCategoryLinksTableCreateCompanionBuilder,
        $$DisplayCategoryLinksTableUpdateCompanionBuilder,
        (DisplayCategoryLink, $$DisplayCategoryLinksTableReferences),
        DisplayCategoryLink,
        PrefetchHooks Function({bool display, bool category})>;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required int category,
  required String supplement,
  required int amount,
  required DateTime origin,
  required ScheduleRepeatType repeatType,
  Value<int?> interval,
  required bool onSunday,
  required bool onMonday,
  required bool onTuesday,
  required bool onWednesday,
  required bool onThursday,
  required bool onFriday,
  required bool onSaturday,
  required int monthlyHeadOrigin,
  required int monthlyTailOrigin,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<int> category,
  Value<String> supplement,
  Value<int> amount,
  Value<DateTime> origin,
  Value<ScheduleRepeatType> repeatType,
  Value<int?> interval,
  Value<bool> onSunday,
  Value<bool> onMonday,
  Value<bool> onTuesday,
  Value<bool> onWednesday,
  Value<bool> onThursday,
  Value<bool> onFriday,
  Value<bool> onSaturday,
  Value<int> monthlyHeadOrigin,
  Value<int> monthlyTailOrigin,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.schedules.category, db.categories.id));

  $$CategoriesTableProcessedTableManager get category {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.category!));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RepeatCachesTable, List<RepeatCache>>
      _repeatCachesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.repeatCaches,
          aliasName:
              $_aliasNameGenerator(db.schedules.id, db.repeatCaches.schedule));

  $$RepeatCachesTableProcessedTableManager get repeatCachesRefs {
    final manager = $$RepeatCachesTableTableManager($_db, $_db.repeatCaches)
        .filter((f) => f.schedule.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_repeatCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ScheduleRepeatType, ScheduleRepeatType, int>
      get repeatType => $composableBuilder(
          column: $table.repeatType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onSunday => $composableBuilder(
      column: $table.onSunday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onMonday => $composableBuilder(
      column: $table.onMonday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onTuesday => $composableBuilder(
      column: $table.onTuesday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onWednesday => $composableBuilder(
      column: $table.onWednesday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onThursday => $composableBuilder(
      column: $table.onThursday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onFriday => $composableBuilder(
      column: $table.onFriday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onSaturday => $composableBuilder(
      column: $table.onSaturday, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyHeadOrigin => $composableBuilder(
      column: $table.monthlyHeadOrigin,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyTailOrigin => $composableBuilder(
      column: $table.monthlyTailOrigin,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get category {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> repeatCachesRefs(
      Expression<bool> Function($$RepeatCachesTableFilterComposer f) f) {
    final $$RepeatCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.repeatCaches,
        getReferencedColumn: (t) => t.schedule,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RepeatCachesTableFilterComposer(
              $db: $db,
              $table: $db.repeatCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repeatType => $composableBuilder(
      column: $table.repeatType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onSunday => $composableBuilder(
      column: $table.onSunday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onMonday => $composableBuilder(
      column: $table.onMonday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onTuesday => $composableBuilder(
      column: $table.onTuesday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onWednesday => $composableBuilder(
      column: $table.onWednesday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onThursday => $composableBuilder(
      column: $table.onThursday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onFriday => $composableBuilder(
      column: $table.onFriday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onSaturday => $composableBuilder(
      column: $table.onSaturday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyHeadOrigin => $composableBuilder(
      column: $table.monthlyHeadOrigin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyTailOrigin => $composableBuilder(
      column: $table.monthlyTailOrigin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get category {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplement => $composableBuilder(
      column: $table.supplement, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleRepeatType, int> get repeatType =>
      $composableBuilder(
          column: $table.repeatType, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<bool> get onSunday =>
      $composableBuilder(column: $table.onSunday, builder: (column) => column);

  GeneratedColumn<bool> get onMonday =>
      $composableBuilder(column: $table.onMonday, builder: (column) => column);

  GeneratedColumn<bool> get onTuesday =>
      $composableBuilder(column: $table.onTuesday, builder: (column) => column);

  GeneratedColumn<bool> get onWednesday => $composableBuilder(
      column: $table.onWednesday, builder: (column) => column);

  GeneratedColumn<bool> get onThursday => $composableBuilder(
      column: $table.onThursday, builder: (column) => column);

  GeneratedColumn<bool> get onFriday =>
      $composableBuilder(column: $table.onFriday, builder: (column) => column);

  GeneratedColumn<bool> get onSaturday => $composableBuilder(
      column: $table.onSaturday, builder: (column) => column);

  GeneratedColumn<int> get monthlyHeadOrigin => $composableBuilder(
      column: $table.monthlyHeadOrigin, builder: (column) => column);

  GeneratedColumn<int> get monthlyTailOrigin => $composableBuilder(
      column: $table.monthlyTailOrigin, builder: (column) => column);

  GeneratedColumn<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get category {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> repeatCachesRefs<T extends Object>(
      Expression<T> Function($$RepeatCachesTableAnnotationComposer a) f) {
    final $$RepeatCachesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.repeatCaches,
        getReferencedColumn: (t) => t.schedule,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RepeatCachesTableAnnotationComposer(
              $db: $db,
              $table: $db.repeatCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool category, bool repeatCachesRefs})> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> category = const Value.absent(),
            Value<String> supplement = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<DateTime> origin = const Value.absent(),
            Value<ScheduleRepeatType> repeatType = const Value.absent(),
            Value<int?> interval = const Value.absent(),
            Value<bool> onSunday = const Value.absent(),
            Value<bool> onMonday = const Value.absent(),
            Value<bool> onTuesday = const Value.absent(),
            Value<bool> onWednesday = const Value.absent(),
            Value<bool> onThursday = const Value.absent(),
            Value<bool> onFriday = const Value.absent(),
            Value<bool> onSaturday = const Value.absent(),
            Value<int> monthlyHeadOrigin = const Value.absent(),
            Value<int> monthlyTailOrigin = const Value.absent(),
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            category: category,
            supplement: supplement,
            amount: amount,
            origin: origin,
            repeatType: repeatType,
            interval: interval,
            onSunday: onSunday,
            onMonday: onMonday,
            onTuesday: onTuesday,
            onWednesday: onWednesday,
            onThursday: onThursday,
            onFriday: onFriday,
            onSaturday: onSaturday,
            monthlyHeadOrigin: monthlyHeadOrigin,
            monthlyTailOrigin: monthlyTailOrigin,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int category,
            required String supplement,
            required int amount,
            required DateTime origin,
            required ScheduleRepeatType repeatType,
            Value<int?> interval = const Value.absent(),
            required bool onSunday,
            required bool onMonday,
            required bool onTuesday,
            required bool onWednesday,
            required bool onThursday,
            required bool onFriday,
            required bool onSaturday,
            required int monthlyHeadOrigin,
            required int monthlyTailOrigin,
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            category: category,
            supplement: supplement,
            amount: amount,
            origin: origin,
            repeatType: repeatType,
            interval: interval,
            onSunday: onSunday,
            onMonday: onMonday,
            onTuesday: onTuesday,
            onWednesday: onWednesday,
            onThursday: onThursday,
            onFriday: onFriday,
            onSaturday: onSaturday,
            monthlyHeadOrigin: monthlyHeadOrigin,
            monthlyTailOrigin: monthlyTailOrigin,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {category = false, repeatCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repeatCachesRefs) db.repeatCaches],
              addJoins: <
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
                      dynamic>>(state) {
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable:
                        $$SchedulesTableReferences._categoryTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._categoryTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repeatCachesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SchedulesTableReferences
                            ._repeatCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SchedulesTableReferences(db, table, p0)
                                .repeatCachesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.schedule == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool category, bool repeatCachesRefs})>;
typedef $$EstimationsTableCreateCompanionBuilder = EstimationsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
  required EstimationContentType contentType,
});
typedef $$EstimationsTableUpdateCompanionBuilder = EstimationsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> periodBegin,
  Value<DateTime?> periodEnd,
  Value<EstimationContentType> contentType,
});

final class $$EstimationsTableReferences
    extends BaseReferences<_$AppDatabase, $EstimationsTable, Estimation> {
  $$EstimationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EstimationCategoryLinksTable,
      List<EstimationCategoryLink>> _estimationCategoryLinksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.estimationCategoryLinks,
          aliasName: $_aliasNameGenerator(
              db.estimations.id, db.estimationCategoryLinks.estimation));

  $$EstimationCategoryLinksTableProcessedTableManager
      get estimationCategoryLinksRefs {
    final manager = $$EstimationCategoryLinksTableTableManager(
            $_db, $_db.estimationCategoryLinks)
        .filter((f) => f.estimation.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_estimationCategoryLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RepeatCachesTable, List<RepeatCache>>
      _repeatCachesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.repeatCaches,
              aliasName: $_aliasNameGenerator(
                  db.estimations.id, db.repeatCaches.estimation));

  $$RepeatCachesTableProcessedTableManager get repeatCachesRefs {
    final manager = $$RepeatCachesTableTableManager($_db, $_db.repeatCaches)
        .filter((f) => f.estimation.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_repeatCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EstimationsTableFilterComposer
    extends Composer<_$AppDatabase, $EstimationsTable> {
  $$EstimationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EstimationContentType, EstimationContentType,
          int>
      get contentType => $composableBuilder(
          column: $table.contentType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> estimationCategoryLinksRefs(
      Expression<bool> Function($$EstimationCategoryLinksTableFilterComposer f)
          f) {
    final $$EstimationCategoryLinksTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.estimationCategoryLinks,
            getReferencedColumn: (t) => t.estimation,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$EstimationCategoryLinksTableFilterComposer(
                  $db: $db,
                  $table: $db.estimationCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> repeatCachesRefs(
      Expression<bool> Function($$RepeatCachesTableFilterComposer f) f) {
    final $$RepeatCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.repeatCaches,
        getReferencedColumn: (t) => t.estimation,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RepeatCachesTableFilterComposer(
              $db: $db,
              $table: $db.repeatCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EstimationsTableOrderingComposer
    extends Composer<_$AppDatabase, $EstimationsTable> {
  $$EstimationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnOrderings(column));
}

class $$EstimationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstimationsTable> {
  $$EstimationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get periodBegin => $composableBuilder(
      column: $table.periodBegin, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstimationContentType, int>
      get contentType => $composableBuilder(
          column: $table.contentType, builder: (column) => column);

  Expression<T> estimationCategoryLinksRefs<T extends Object>(
      Expression<T> Function($$EstimationCategoryLinksTableAnnotationComposer a)
          f) {
    final $$EstimationCategoryLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.estimationCategoryLinks,
            getReferencedColumn: (t) => t.estimation,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$EstimationCategoryLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.estimationCategoryLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> repeatCachesRefs<T extends Object>(
      Expression<T> Function($$RepeatCachesTableAnnotationComposer a) f) {
    final $$RepeatCachesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.repeatCaches,
        getReferencedColumn: (t) => t.estimation,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RepeatCachesTableAnnotationComposer(
              $db: $db,
              $table: $db.repeatCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EstimationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EstimationsTable,
    Estimation,
    $$EstimationsTableFilterComposer,
    $$EstimationsTableOrderingComposer,
    $$EstimationsTableAnnotationComposer,
    $$EstimationsTableCreateCompanionBuilder,
    $$EstimationsTableUpdateCompanionBuilder,
    (Estimation, $$EstimationsTableReferences),
    Estimation,
    PrefetchHooks Function(
        {bool estimationCategoryLinksRefs, bool repeatCachesRefs})> {
  $$EstimationsTableTableManager(_$AppDatabase db, $EstimationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstimationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstimationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstimationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            Value<EstimationContentType> contentType = const Value.absent(),
          }) =>
              EstimationsCompanion(
            id: id,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
            contentType: contentType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> periodBegin = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
            required EstimationContentType contentType,
          }) =>
              EstimationsCompanion.insert(
            id: id,
            periodBegin: periodBegin,
            periodEnd: periodEnd,
            contentType: contentType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EstimationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {estimationCategoryLinksRefs = false, repeatCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (estimationCategoryLinksRefs) db.estimationCategoryLinks,
                if (repeatCachesRefs) db.repeatCaches
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (estimationCategoryLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$EstimationsTableReferences
                            ._estimationCategoryLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EstimationsTableReferences(db, table, p0)
                                .estimationCategoryLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.estimation == item.id),
                        typedResults: items),
                  if (repeatCachesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$EstimationsTableReferences
                            ._repeatCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EstimationsTableReferences(db, table, p0)
                                .repeatCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.estimation == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EstimationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EstimationsTable,
    Estimation,
    $$EstimationsTableFilterComposer,
    $$EstimationsTableOrderingComposer,
    $$EstimationsTableAnnotationComposer,
    $$EstimationsTableCreateCompanionBuilder,
    $$EstimationsTableUpdateCompanionBuilder,
    (Estimation, $$EstimationsTableReferences),
    Estimation,
    PrefetchHooks Function(
        {bool estimationCategoryLinksRefs, bool repeatCachesRefs})>;
typedef $$EstimationCategoryLinksTableCreateCompanionBuilder
    = EstimationCategoryLinksCompanion Function({
  required int estimation,
  required int category,
  Value<int> rowid,
});
typedef $$EstimationCategoryLinksTableUpdateCompanionBuilder
    = EstimationCategoryLinksCompanion Function({
  Value<int> estimation,
  Value<int> category,
  Value<int> rowid,
});

final class $$EstimationCategoryLinksTableReferences extends BaseReferences<
    _$AppDatabase, $EstimationCategoryLinksTable, EstimationCategoryLink> {
  $$EstimationCategoryLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EstimationsTable _estimationTable(_$AppDatabase db) =>
      db.estimations.createAlias($_aliasNameGenerator(
          db.estimationCategoryLinks.estimation, db.estimations.id));

  $$EstimationsTableProcessedTableManager get estimation {
    final manager = $$EstimationsTableTableManager($_db, $_db.estimations)
        .filter((f) => f.id($_item.estimation!));
    final item = $_typedResult.readTableOrNull(_estimationTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.estimationCategoryLinks.category, db.categories.id));

  $$CategoriesTableProcessedTableManager get category {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.category!));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EstimationCategoryLinksTableFilterComposer
    extends Composer<_$AppDatabase, $EstimationCategoryLinksTable> {
  $$EstimationCategoryLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EstimationsTableFilterComposer get estimation {
    final $$EstimationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableFilterComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get category {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCategoryLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $EstimationCategoryLinksTable> {
  $$EstimationCategoryLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EstimationsTableOrderingComposer get estimation {
    final $$EstimationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableOrderingComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get category {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCategoryLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstimationCategoryLinksTable> {
  $$EstimationCategoryLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EstimationsTableAnnotationComposer get estimation {
    final $$EstimationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableAnnotationComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get category {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCategoryLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EstimationCategoryLinksTable,
    EstimationCategoryLink,
    $$EstimationCategoryLinksTableFilterComposer,
    $$EstimationCategoryLinksTableOrderingComposer,
    $$EstimationCategoryLinksTableAnnotationComposer,
    $$EstimationCategoryLinksTableCreateCompanionBuilder,
    $$EstimationCategoryLinksTableUpdateCompanionBuilder,
    (EstimationCategoryLink, $$EstimationCategoryLinksTableReferences),
    EstimationCategoryLink,
    PrefetchHooks Function({bool estimation, bool category})> {
  $$EstimationCategoryLinksTableTableManager(
      _$AppDatabase db, $EstimationCategoryLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstimationCategoryLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$EstimationCategoryLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstimationCategoryLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> estimation = const Value.absent(),
            Value<int> category = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EstimationCategoryLinksCompanion(
            estimation: estimation,
            category: category,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int estimation,
            required int category,
            Value<int> rowid = const Value.absent(),
          }) =>
              EstimationCategoryLinksCompanion.insert(
            estimation: estimation,
            category: category,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EstimationCategoryLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({estimation = false, category = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (estimation) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.estimation,
                    referencedTable: $$EstimationCategoryLinksTableReferences
                        ._estimationTable(db),
                    referencedColumn: $$EstimationCategoryLinksTableReferences
                        ._estimationTable(db)
                        .id,
                  ) as T;
                }
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable: $$EstimationCategoryLinksTableReferences
                        ._categoryTable(db),
                    referencedColumn: $$EstimationCategoryLinksTableReferences
                        ._categoryTable(db)
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
        ));
}

typedef $$EstimationCategoryLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $EstimationCategoryLinksTable,
        EstimationCategoryLink,
        $$EstimationCategoryLinksTableFilterComposer,
        $$EstimationCategoryLinksTableOrderingComposer,
        $$EstimationCategoryLinksTableAnnotationComposer,
        $$EstimationCategoryLinksTableCreateCompanionBuilder,
        $$EstimationCategoryLinksTableUpdateCompanionBuilder,
        (EstimationCategoryLink, $$EstimationCategoryLinksTableReferences),
        EstimationCategoryLink,
        PrefetchHooks Function({bool estimation, bool category})>;
typedef $$EstimationCachesTableCreateCompanionBuilder
    = EstimationCachesCompanion Function({
  Value<int> category,
  required int amount,
});
typedef $$EstimationCachesTableUpdateCompanionBuilder
    = EstimationCachesCompanion Function({
  Value<int> category,
  Value<int> amount,
});

final class $$EstimationCachesTableReferences extends BaseReferences<
    _$AppDatabase, $EstimationCachesTable, EstimationCache> {
  $$EstimationCachesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.estimationCaches.category, db.categories.id));

  $$CategoriesTableProcessedTableManager get category {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.category!));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EstimationCachesTableFilterComposer
    extends Composer<_$AppDatabase, $EstimationCachesTable> {
  $$EstimationCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get category {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $EstimationCachesTable> {
  $$EstimationCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get category {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstimationCachesTable> {
  $$EstimationCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get category {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EstimationCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EstimationCachesTable,
    EstimationCache,
    $$EstimationCachesTableFilterComposer,
    $$EstimationCachesTableOrderingComposer,
    $$EstimationCachesTableAnnotationComposer,
    $$EstimationCachesTableCreateCompanionBuilder,
    $$EstimationCachesTableUpdateCompanionBuilder,
    (EstimationCache, $$EstimationCachesTableReferences),
    EstimationCache,
    PrefetchHooks Function({bool category})> {
  $$EstimationCachesTableTableManager(
      _$AppDatabase db, $EstimationCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstimationCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstimationCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstimationCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> category = const Value.absent(),
            Value<int> amount = const Value.absent(),
          }) =>
              EstimationCachesCompanion(
            category: category,
            amount: amount,
          ),
          createCompanionCallback: ({
            Value<int> category = const Value.absent(),
            required int amount,
          }) =>
              EstimationCachesCompanion.insert(
            category: category,
            amount: amount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EstimationCachesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({category = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable:
                        $$EstimationCachesTableReferences._categoryTable(db),
                    referencedColumn:
                        $$EstimationCachesTableReferences._categoryTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EstimationCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EstimationCachesTable,
    EstimationCache,
    $$EstimationCachesTableFilterComposer,
    $$EstimationCachesTableOrderingComposer,
    $$EstimationCachesTableAnnotationComposer,
    $$EstimationCachesTableCreateCompanionBuilder,
    $$EstimationCachesTableUpdateCompanionBuilder,
    (EstimationCache, $$EstimationCachesTableReferences),
    EstimationCache,
    PrefetchHooks Function({bool category})>;
typedef $$RepeatCachesTableCreateCompanionBuilder = RepeatCachesCompanion
    Function({
  Value<int> id,
  required DateTime registeredAt,
  Value<int?> schedule,
  Value<int?> estimation,
});
typedef $$RepeatCachesTableUpdateCompanionBuilder = RepeatCachesCompanion
    Function({
  Value<int> id,
  Value<DateTime> registeredAt,
  Value<int?> schedule,
  Value<int?> estimation,
});

final class $$RepeatCachesTableReferences
    extends BaseReferences<_$AppDatabase, $RepeatCachesTable, RepeatCache> {
  $$RepeatCachesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchedulesTable _scheduleTable(_$AppDatabase db) =>
      db.schedules.createAlias(
          $_aliasNameGenerator(db.repeatCaches.schedule, db.schedules.id));

  $$SchedulesTableProcessedTableManager? get schedule {
    if ($_item.schedule == null) return null;
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.id($_item.schedule!));
    final item = $_typedResult.readTableOrNull(_scheduleTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EstimationsTable _estimationTable(_$AppDatabase db) =>
      db.estimations.createAlias(
          $_aliasNameGenerator(db.repeatCaches.estimation, db.estimations.id));

  $$EstimationsTableProcessedTableManager? get estimation {
    if ($_item.estimation == null) return null;
    final manager = $$EstimationsTableTableManager($_db, $_db.estimations)
        .filter((f) => f.id($_item.estimation!));
    final item = $_typedResult.readTableOrNull(_estimationTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RepeatCachesTableFilterComposer
    extends Composer<_$AppDatabase, $RepeatCachesTable> {
  $$RepeatCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => ColumnFilters(column));

  $$SchedulesTableFilterComposer get schedule {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.schedule,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EstimationsTableFilterComposer get estimation {
    final $$EstimationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableFilterComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RepeatCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $RepeatCachesTable> {
  $$RepeatCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt,
      builder: (column) => ColumnOrderings(column));

  $$SchedulesTableOrderingComposer get schedule {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.schedule,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableOrderingComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EstimationsTableOrderingComposer get estimation {
    final $$EstimationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableOrderingComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RepeatCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepeatCachesTable> {
  $$RepeatCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => column);

  $$SchedulesTableAnnotationComposer get schedule {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.schedule,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EstimationsTableAnnotationComposer get estimation {
    final $$EstimationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.estimation,
        referencedTable: $db.estimations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EstimationsTableAnnotationComposer(
              $db: $db,
              $table: $db.estimations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RepeatCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RepeatCachesTable,
    RepeatCache,
    $$RepeatCachesTableFilterComposer,
    $$RepeatCachesTableOrderingComposer,
    $$RepeatCachesTableAnnotationComposer,
    $$RepeatCachesTableCreateCompanionBuilder,
    $$RepeatCachesTableUpdateCompanionBuilder,
    (RepeatCache, $$RepeatCachesTableReferences),
    RepeatCache,
    PrefetchHooks Function({bool schedule, bool estimation})> {
  $$RepeatCachesTableTableManager(_$AppDatabase db, $RepeatCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepeatCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepeatCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepeatCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> registeredAt = const Value.absent(),
            Value<int?> schedule = const Value.absent(),
            Value<int?> estimation = const Value.absent(),
          }) =>
              RepeatCachesCompanion(
            id: id,
            registeredAt: registeredAt,
            schedule: schedule,
            estimation: estimation,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime registeredAt,
            Value<int?> schedule = const Value.absent(),
            Value<int?> estimation = const Value.absent(),
          }) =>
              RepeatCachesCompanion.insert(
            id: id,
            registeredAt: registeredAt,
            schedule: schedule,
            estimation: estimation,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RepeatCachesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({schedule = false, estimation = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (schedule) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.schedule,
                    referencedTable:
                        $$RepeatCachesTableReferences._scheduleTable(db),
                    referencedColumn:
                        $$RepeatCachesTableReferences._scheduleTable(db).id,
                  ) as T;
                }
                if (estimation) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.estimation,
                    referencedTable:
                        $$RepeatCachesTableReferences._estimationTable(db),
                    referencedColumn:
                        $$RepeatCachesTableReferences._estimationTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RepeatCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RepeatCachesTable,
    RepeatCache,
    $$RepeatCachesTableFilterComposer,
    $$RepeatCachesTableOrderingComposer,
    $$RepeatCachesTableAnnotationComposer,
    $$RepeatCachesTableCreateCompanionBuilder,
    $$RepeatCachesTableUpdateCompanionBuilder,
    (RepeatCache, $$RepeatCachesTableReferences),
    RepeatCache,
    PrefetchHooks Function({bool schedule, bool estimation})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
  $$DisplaysTableTableManager get displays =>
      $$DisplaysTableTableManager(_db, _db.displays);
  $$DisplayCategoryLinksTableTableManager get displayCategoryLinks =>
      $$DisplayCategoryLinksTableTableManager(_db, _db.displayCategoryLinks);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$EstimationsTableTableManager get estimations =>
      $$EstimationsTableTableManager(_db, _db.estimations);
  $$EstimationCategoryLinksTableTableManager get estimationCategoryLinks =>
      $$EstimationCategoryLinksTableTableManager(
          _db, _db.estimationCategoryLinks);
  $$EstimationCachesTableTableManager get estimationCaches =>
      $$EstimationCachesTableTableManager(_db, _db.estimationCaches);
  $$RepeatCachesTableTableManager get repeatCaches =>
      $$RepeatCachesTableTableManager(_db, _db.repeatCaches);
}
