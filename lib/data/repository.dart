import 'dart:io';

import 'package:miraibo/data/categoryConfig.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;

class DatabaseProvider {
  // Singleton
  static final String dbName = 'miraibo.db';

  DatabaseProvider._internal();
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;

  Database? _database;

  Future<void> init() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    _database ??= await openDatabase(dbName);
    await Future.wait([
      // Make linker available
      _database!.execute('PRAGMA foreign_keys=true;'),
      createTables(),
    ]);
  }

  Database get instance {
    if (_database == null) throw Exception('Database is not opend yet');
    return _database!;
  }

  final List<Table> tables = [
    LogRecord(),
    Categories(),
    DisplayTickets(),
  ];

  Future<void> createTables() async {
    await Future.wait(tables.map((table) => table.prepare()));
  }

  Future<void> clearTables() async {
    await Future.wait(tables.map((table) => table.clear()));
  }
}

abstract class Table<T> {
  abstract String tableName;
  static final DatabaseProvider dbProvider = DatabaseProvider();
  bool prepared = false;

  /// returns SQL query to create table
  String makeTable(List<String> fields) =>
      '''CREATE TABLE IF NOT EXISTS '$tableName'(
          ${fields.join(', ')}
          )
        ''';
  String makeIntegerField(String name, {bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeIdField({String? name}) =>
      "'${name ?? 'id'}' INTEGER PRIMARY KEY AUTOINCREMENT";
  String makeTEXTKeyField(String name) => "'$name' TEXT PRIMARY KEY";
  String makeTextField(String name, {bool notNull = false}) =>
      "'$name' TEXT${notNull ? ' NOT NULL' : ''}";
  String makeDateField(String name, {bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeBooleanField(String name) =>
      "'$name' INTEGER NOT NULL, CHECK ($name = 0 OR $name = 1)";
  String makeForeignField(String name, Table referenceTable,
          {String? rField, bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}, FOREIGN KEY ($name) REFERENCES ${referenceTable.tableName}(${rField ?? name})";
  String makeEnumField(String name, List<Enum> values) =>
      "'$name' TEXT NOT NULL, CHECK (0 <= $name <= ${values.length})";

  int dateToInt(DateTime date) =>
      date.millisecondsSinceEpoch ~/ 1000; // convert millisec to sec
  DateTime intToDate(int dateInt) => DateTime.fromMillisecondsSinceEpoch(
      dateInt * 1000); // convert sec to millisec

  void assertPrepared() {
    if (!prepared) throw Exception('Table $tableName is not prepared');
  }

  Future<void> prepare();
  Future<void> clear() async {
    await dbProvider.instance.execute('DELETE FROM $tableName');
  }

  Future<T> interpret(Map<String, Object?> row);

  Future<List<T>> fetchAll() async {
    assertPrepared();
    return [
      for (var row in await dbProvider.instance.query(tableName))
        await interpret(row)
    ];
  }

  Future<T?> fetchById(int? id) async {
    if (id == null) return null;
    assertPrepared();
    var result = await dbProvider.instance
        .query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return interpret(result.first);
  }

  Future<int> insert(dynamic data);
}

class Linker<R> {
  final int id;
  final int linker;
  final R? value;
  const Linker(this.id, this.linker, this.value);
}

mixin Linking<T> on Table<Linker<T>> {
  /// linkerFieldName should be binded by linkerValues
  Future<List<T>> _linkedValues(String linkerFieldName, int linker) async {
    assertPrepared();
    List<T> buf = [];
    for (var row in await Table.dbProvider.instance
        .query(tableName, where: '$linkerFieldName = ?', whereArgs: [linker])) {
      var linked = (await interpret(row)).value;
      if (linked != null) {
        buf.add(linked);
      }
    }
    return buf;
  }

  Future<List<T?>> linkedValues(int linker);
}

class LogRecord extends Table<LogTicketConfigData> {
  @override
  covariant String tableName = 'Receipts';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeForeignField('category', Categories(), rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeDateField('registeredAt', notNull: true),
      makeIntegerField('amount', notNull: true),
      makeTextField('imagePath'),
      makeBooleanField('confirmed'),
    ]));
  }

  @override
  Future<LogTicketConfigData> interpret(Map<String, Object?> row) async {
    return LogTicketConfigData(
      id: row['id'] as int,
      category: await Categories().fetchById(row['category'] as int),
      supplement: row['supplement'] as String,
      registorationDate: intToDate(row['registeredAt'] as int),
      amount: row['amount'] as int,
      image: row['imagePath'] != null ? File(row['imagePath'] as String) : null,
      isImageAttached: row['imagePath'] != null,
      confirmed: row['confirmed'] as bool,
    );
  }

  @override
  Future<int> insert(covariant LogTicketConfigData data) async {
    return await Table.dbProvider.instance.insert(tableName, {
      'category': data.category,
      'supplement': data.supplement,
      'registeredAt': data.registorationDate == null
          ? dateToInt(DateTime.now())
          : dateToInt(data.registorationDate!),
      'amount': data.amount,
      'imagePath': data.image?.path,
      'confirmed': data.confirmed,
    });
  }
}

class Category {
  final int id;
  String name;

  Category({required this.id, required this.name});

  factory Category.make(String name) {
    return Category(id: 0, name: name);
  }

  void rename(String newName) {
    name = newName;
  }

  void integrateWith(Category other) {
    developer.log('integrate $name with ${other.name}');
    // in progress
  }

  bool isVaild() {
    // TODO: implement isVaild
    return name.isNotEmpty;
  }
}

class Categories extends Table<Category> {
  @override
  covariant String tableName = 'Receipts';

  static final List<String> initialCategories = [
    'Food',
    'Gas',
    'Water',
    'Electricity',
    'Transportation',
    'EducationFee',
    'EducationMaterials',
    'Amusument',
    'Furniture',
    'Necessities',
    'OtherExpense',
    'Scholarship',
    'Payment',
    'Ajustment',
  ];

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeTextField('name', notNull: true),
    ]));
    var queryResult = await Table.dbProvider.instance.query(tableName);
    if (queryResult.isEmpty) {
      Table.dbProvider.instance.execute('''
        INSERT INTO $tableName (name) VALUES
        ${initialCategories.map((cat) => "('$cat')").join(", ")}
      '''); // ('xxx'), ('yyy'), ('zzz')
    }
  }

  @override
  Future<Category> interpret(Map<String, Object?> row) async {
    return Category(id: row['id'] as int, name: row['name'] as String);
  }

  @override
  Future<int> insert(covariant Category data) async {
    return await Table.dbProvider.instance
        .insert(tableName, {'name': data.name});
  }

  Future<Category> makeNewCategory(String name) async {
    var id = await Table.dbProvider.instance.insert(tableName, {'name': name});
    return Category(id: id, name: name);
  }
}

class DisplayTickets extends Table<DisplayTicketConfigData> {
  @override
  covariant String tableName = 'DisplayTickets';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeForeignField(
          'target_category_map_linker', DisplayTicketTargetCategoryMap()),
      // null means targeting all categories
      makeIntegerField('period_in_days'),
      makeDateField('limit_date'),
      makeEnumField('content_type', DisplayTicketContentType.values),
    ]));
  }

  DisplayTicketPeriod periodExpressionFromDays(int? days) {
    if (days == null) {
      return DisplayTicketPeriod.week;
    } else if (0 <= days && days <= 7) {
      return DisplayTicketPeriod.week;
    } else if (7 < days && days <= 30) {
      return DisplayTicketPeriod.month;
    } else if (30 < days && days <= 180) {
      return DisplayTicketPeriod.halfYear;
    } else {
      return DisplayTicketPeriod.year;
    }
  }

  int daysFromPeriodExpression(DisplayTicketPeriod period) {
    switch (period) {
      case DisplayTicketPeriod.week:
        return 7;
      case DisplayTicketPeriod.month:
        return 30;
      case DisplayTicketPeriod.halfYear:
        return 180;
      case DisplayTicketPeriod.year:
        return 365;
    }
  }

  @override
  Future<DisplayTicketConfigData> interpret(Map<String, Object?> row) async {
    int? periodInDays = row['period_in_days'] as int?;
    int? limitDate = row['limit_date'] as int?;

    DisplayTicketTermMode termMode;
    if (periodInDays == null && limitDate == null) {
      termMode = DisplayTicketTermMode.untilToday;
    } else if (periodInDays != null && limitDate == null) {
      termMode = DisplayTicketTermMode.lastDesignatedPeriod;
    } else if (periodInDays == null && limitDate != null) {
      termMode = DisplayTicketTermMode.untilDesignatedDate;
    } else {
      throw Exception('Both period_in_days and limit_date are set');
    }

    return DisplayTicketConfigData(
      id: row['id'] as int,
      targetCategories: row['target_category_map_linker'] != null
          ? await DisplayTicketTargetCategoryMap()
              .linkedValues(row['target_category_map_linker'] as int)
          : const [],
      targetingAllCategories: row['target_category_map_linker'] == null,
      // null means targeting all categories
      termMode: termMode,
      designatedDate: limitDate != null ? intToDate(limitDate) : null,
      designatedPeriod: periodExpressionFromDays(periodInDays),
      contentType: DisplayTicketContentType.values[row['content_type'] as int],
    );
  }

  @override
  Future<int> insert(covariant DisplayTicketConfigData data) async {
    int? periodInDays;
    int? limitDate;
    switch (data.termMode) {
      case DisplayTicketTermMode.untilToday:
        break;
      case DisplayTicketTermMode.lastDesignatedPeriod:
        periodInDays = daysFromPeriodExpression(data.designatedPeriod);
        break;
      case DisplayTicketTermMode.untilDesignatedDate:
        limitDate = dateToInt(data.designatedDate!);
        break;
    }
    return await Table.dbProvider.instance.insert(tableName, {
      'target_category_map_linker':
          data.targetingAllCategories ? null : data.targetCategories.first.id,
      'period_in_days': periodInDays,
      'limit_date': limitDate,
      'content_type': data.contentType.index,
    });
  }
}

class DisplayTicketTargetCategoryMap extends Table<Linker<Category>>
    with Linking<Category> {
  @override
  covariant String tableName = 'DisplayTicketTargetCategoryMap';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeIntegerField('target_category_map_linker', notNull: true),
      makeForeignField('category', Categories(), rField: 'id', notNull: true),
    ]));
  }

  @override
  Future<Linker<Category>> interpret(Map<String, Object?> row) async {
    return Linker(row['id'] as int, row['target_category_map_linker'] as int,
        await Categories().fetchById(row['category'] as int));
  }

  @override
  Future<List<Category>> linkedValues(int linker) async {
    return _linkedValues('target_category_map_linker', linker);
  }
}

class Schedules extends Table<ScheduleTicketConfigData> {
  @override
  covariant String tableName = 'Schedules';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeForeignField('category', Categories(), rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeIntegerField('amount', notNull: true),
      makeDateField('origin_date', notNull: true),
      makeEnumField('repeat_type', RepeatType.values),
      makeIntegerField('repeat_option_interval_in_days', notNull: true),
      makeBooleanField('repeat_option_on_Sunday'),
      makeBooleanField('repeat_option_on_Monday'),
      makeBooleanField('repeat_option_on_Tuesday'),
      makeBooleanField('repeat_option_on_Wednesday'),
      makeBooleanField('repeat_option_on_Thursday'),
      makeBooleanField('repeat_option_on_Friday'),
      makeBooleanField('repeat_option_on_Saturday'),
      makeIntegerField('repeat_option_monthly_head_origin_in_days'),
      makeIntegerField('repeat_option_monthly_tail_origin_in_days'),
      makeDateField('period_option_begin_from'),
      makeDateField('period_option_end_at'),
    ]));
  }

  @override
  Future<ScheduleTicketConfigData> interpret(Map<String, Object?> row) async {
    return ScheduleTicketConfigData(
      id: row['id'] as int,
      category: await Categories().fetchById(row['category'] as int),
      supplement: row['supplement'] as String,
      amount: row['amount'] as int,
      registorationDate: intToDate(row['origin_date'] as int),
      repeatType: RepeatType.values[row['repeat_type'] as int],
      repeatInterval:
          Duration(days: row['repeat_option_interval_in_days'] as int),
      repeatDayOfWeek: [
        if (row['repeat_option_on_Sunday'] == 1) DayOfWeek.sunday,
        if (row['repeat_option_on_Monday'] == 1) DayOfWeek.monday,
        if (row['repeat_option_on_Tuesday'] == 1) DayOfWeek.tuesday,
        if (row['repeat_option_on_Wednesday'] == 1) DayOfWeek.wednesday,
        if (row['repeat_option_on_Thursday'] == 1) DayOfWeek.thursday,
        if (row['repeat_option_on_Friday'] == 1) DayOfWeek.friday,
        if (row['repeat_option_on_Saturday'] == 1) DayOfWeek.saturday,
      ],
      monthlyRepeatType:
          row['repeat_option_monthly_head_origin_in_days'] != null
              ? MonthlyRepeatType.fromHead
              : MonthlyRepeatType.fromTail,
      startDate: row['period_option_begin_from'] != null
          ? intToDate(row['period_option_begin_from'] as int)
          : null,
      startDateDesignated: true,
      endDate: row['period_option_end_at'] != null
          ? intToDate(row['period_option_end_at'] as int)
          : null,
      endDateDesignated: true,
    );
  }
}

class Estimations extends Table<EstimationTicketConfigData> {
  @override
  covariant String tableName = 'Estimations';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeForeignField(
          'target_category_map_linker', EstimationTargetCategoryMap()),
      // null means targeting all categories
      makeDateField('period_option_begin_from'),
      makeDateField('period_option_end_at'),
      makeEnumField('content_type', EstimationTicketContentType.values),
    ]));
  }

  @override
  Future<EstimationTicketConfigData> interpret(Map<String, Object?> row) async {
    return EstimationTicketConfigData(
      id: row['id'] as int,
      targetCategories: row['target_category_map_linker'] != null
          ? await EstimationTargetCategoryMap()
              .linkedValues(row['target_category_map_linker'] as int)
          : const [],
      targetingAllCategories: row['target_category_map_linker'] == null,
      // null means targeting all categories
      startDate: row['period_option_begin_from'] != null
          ? intToDate(row['period_option_begin_from'] as int)
          : null,
      startDateDesignated: true,
      endDate: row['period_option_end_at'] != null
          ? intToDate(row['period_option_end_at'] as int)
          : null,
      endDateDesignated: true,
      contentType:
          EstimationTicketContentType.values[row['content_type'] as int],
    );
  }
}

class EstimationTargetCategoryMap extends Table<Linker<Category>>
    with Linking<Category> {
  @override
  covariant String tableName = 'EstimationTargetCategoryMap';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeIntegerField('target_category_map_linker', notNull: true),
      makeForeignField('category', Categories(), rField: 'id', notNull: true),
    ]));
  }

  @override
  Future<Linker<Category>> interpret(Map<String, Object?> row) async {
    return Linker(row['id'] as int, row['target_category_map_linker'] as int,
        await Categories().fetchById(row['category'] as int));
  }

  @override
  Future<List<Category>> linkedValues(int linker) async {
    return _linkedValues('target_category_map_linker', linker);
  }
}

class FutureTicket {
  final int id;
  final ScheduleTicketConfigData? schedule;
  final EstimationTicketConfigData? estimation;
  final Category category;
  final String supplement;
  final DateTime scheduledAt;
  final int amount;

  FutureTicket({
    required this.id,
    this.schedule,
    this.estimation,
    required this.category,
    required this.supplement,
    required this.scheduledAt,
    required this.amount,
  });
}

class FutureTickets extends Table<FutureTicket> {
  @override
  covariant String tableName = 'FutureTickets';

  @override
  Future<void> prepare() async {
    await Table.dbProvider.instance.execute(makeTable([
      makeIdField(),
      makeForeignField('schedule', Schedules(), rField: 'id'),
      makeForeignField('estimation', Estimations(), rField: 'id'),
      makeForeignField('category', Categories(), rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeDateField('scheduledAt', notNull: true),
      makeIntegerField('amount', notNull: true),
    ]));
  }

  @override
  Future<FutureTicket> interpret(Map<String, Object?> row) async {
    return FutureTicket(
      id: row['id'] as int,
      schedule: await Schedules().fetchById(row['schedule'] as int),
      estimation: await Estimations().fetchById(row['estimation'] as int),
      category: (await Categories().fetchById(row['category'] as int))!,
      supplement: row['supplement'] as String,
      scheduledAt: intToDate(row['scheduledAt'] as int),
      amount: row['amount'] as int,
    );
  }
}
