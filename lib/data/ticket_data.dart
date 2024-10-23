import 'dart:developer' as developer;
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'category_data.dart';
import './database.dart';
import './future_ticket_data.dart';

/* 
This file contains the data classes that define the structure of the data / repository of the data, 
and the methods to basic data-operations: save, delete.

all classes are related to specific 'object' such as single type of ticket, category.

Function to handle the data across objects are defined in the './fecher.dart' file (not included in this file).
*/

/* 
Abstract class to bundle: 

- DisplayTicketConfigData
- ScheduleTicketConfigData
- EstimationTicketConfigData
- LogTicketConfigData
*/
abstract class TicketConfigRecord extends DTO {
  const TicketConfigRecord({super.id});
}

// <Display Ticket>
// <enums>
enum DisplayTicketTermMode {
  untilToday,
  lastDesignatedPeriod,
  untilDesignatedDate;
}

enum DisplayTicketPeriod {
  week,
  month,
  halfYear,
  year;
}

enum DisplayTicketContentType {
  dailyAverage,
  dailyQuartileAverage,
  monthlyAverage,
  monthlyQuartileAverage,
  summation;
}
// </enums>

// <DTO>
class DisplayRecord extends TicketConfigRecord {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final DisplayTicketTermMode termMode;
  final DateTime? designatedDate;
  final DisplayTicketPeriod designatedPeriod;
  final DisplayTicketContentType contentType;

  const DisplayRecord({
    super.id,
    this.targetCategories = const <Category>[],
    this.targetingAllCategories = true,
    this.termMode = DisplayTicketTermMode.untilToday,
    this.designatedDate,
    this.designatedPeriod = DisplayTicketPeriod.week,
    this.contentType = DisplayTicketContentType.summation,
  });

  @override
  Future<void> save() async {
    developer.log('save display ticket config data');
    throw UnimplementedError();
    // in progress
  }

  @override
  Future<void> delete() async {
    developer.log('delete display ticket config data');
    throw UnimplementedError();
    // in progress
  }
}
// </DTO>

// <Repository>
class DisplayTicketTable extends Table<DisplayRecord> {
  @override
  covariant String tableName = 'DisplayTickets';

  // <constructor>
  DisplayTicketTable._internal();
  static final DisplayTicketTable _instance = DisplayTicketTable._internal();
  static Future<DisplayTicketTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory DisplayTicketTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      // null means targeting all categories
      makeLinkerField(DisplayTicketTargetCategoryLinker.ref()),
      makeIntegerField('period_in_days'),
      makeDateField('limit_date'),
      makeEnumField('content_type', DisplayTicketContentType.values),
    ]));
  }

  // <period caster>
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
  // </period caster>

  // <linking handler>
  @override
  Future<void> link(Transaction txn, DisplayRecord data, {int? id}) async {
    var linker = await DisplayTicketTargetCategoryLinker.use();
    id ??= data.id;
    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }
    if (data.targetingAllCategories) {
      await linker.linkValues(id, const [], txn);
    } else {
      await linker.linkValues(id, data.targetCategories, txn);
    }
  }

  @override
  Future<void> unlink(Transaction txn, DisplayRecord data) async {
    var linker = await DisplayTicketTargetCategoryLinker.use();
    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }
    await linker.linkValues(data.id!, const [], txn);
  }
  // </linking handler>

  @override
  Future<DisplayRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
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
      throw InvalidDataException('Both period_in_days and limit_date are set');
    }

    var id = row['id'] as int;

    var linker = await DisplayTicketTargetCategoryLinker.use();
    var targetCategories = await linker.fetchValues(id, txn);

    return DisplayRecord(
      id: id,
      targetCategories: targetCategories,
      targetingAllCategories: targetCategories.isEmpty,
      termMode: termMode,
      designatedDate: intToDate(limitDate),
      designatedPeriod: periodExpressionFromDays(periodInDays),
      contentType: DisplayTicketContentType.values[row['content_type'] as int],
    );
  }

  @override
  void validate(DisplayRecord data) {
    switch (data.termMode) {
      case DisplayTicketTermMode.untilToday:
      case DisplayTicketTermMode.lastDesignatedPeriod:
        break;
      case DisplayTicketTermMode.untilDesignatedDate:
        if (data.designatedDate == null) {
          throw InvalidDataException(
              'designatedDate is null although termMode is [DisplayTicketTermMode.untilDesignatedDate]');
        }
        break;
    }
  }

  @override
  Map<String, Object?> serialize(DisplayRecord data) {
    return {
      'period_in_days':
          data.termMode == DisplayTicketTermMode.lastDesignatedPeriod
              ? daysFromPeriodExpression(data.designatedPeriod)
              : null,
      'limit_date': dateToInt(data.designatedDate),
      'content_type': data.contentType.index,
    };
  }
}

class DisplayTicketTargetCategoryLinker extends Table<Link>
    with Linker<DisplayRecord, Category>, HaveCategoryField, CategoryLinker {
  @override
  covariant String tableName = 'DisplayTicketTargetCategoryLinker';
  @override
  final keyTable = DisplayTicketTable.ref();
  @override
  final valueTable = CategoryTable.ref();

  // <constructor>
  DisplayTicketTargetCategoryLinker._internal();
  static final DisplayTicketTargetCategoryLinker _instance =
      DisplayTicketTargetCategoryLinker._internal();
  static Future<DisplayTicketTargetCategoryLinker> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory DisplayTicketTargetCategoryLinker.ref() => _instance;
  // </constructor>

  @override
  Future<List<Category>> fetchValuesByIds(
      List<int> valueIds, Transaction? txn) async {
    var categories = await CategoryTable.use();
    return categories.fetchByIds(valueIds, txn);
  }
}
// </Repository>
// </Display Ticket>

// <Schedule Ticket>
// <enums>
enum RepeatType { no, interval, weekly, monthly, anually }

enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday
}

enum MonthlyRepeatType { fromHead, fromTail }
// </enums>

// <DTO>
class ScheduleRecord extends TicketConfigRecord {
  final Category? category;
  final String supplement;
  final DateTime? registorationDate;
  final int amount;
  final RepeatType repeatType;
  final Duration repeatInterval;
  final List<DayOfWeek> repeatDayOfWeek;
  final MonthlyRepeatType monthlyRepeatType;
  final int monthlyRepeatOffset;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScheduleRecord({
    super.id,
    this.category,
    this.supplement = '',
    this.registorationDate,
    this.amount = 0,
    this.repeatType = RepeatType.no,
    this.repeatInterval = const Duration(days: 1),
    this.repeatDayOfWeek = const [],
    this.monthlyRepeatType = MonthlyRepeatType.fromHead,
    this.monthlyRepeatOffset = 0,
    this.startDate,
    this.endDate,
  });

  @override
  Future<void> save() async {
    developer.log('save schedule ticket config data');
    throw UnimplementedError();
    // in progress
  }

  @override
  Future<void> delete() async {
    developer.log('delete schedule ticket config data');
    throw UnimplementedError();
    // in progress
  }
}
// </DTO>

// <Repository>
class ScheduleTable extends Table<ScheduleRecord> with HaveCategoryField {
  @override
  covariant String tableName = 'Schedules';

  // <constructor>
  ScheduleTable._internal();
  static final ScheduleTable _instance = ScheduleTable._internal();
  static Future<ScheduleTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory ScheduleTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName 
      SET category = ${replaceWith.id} 
      WHERE category = ${replaced.id}
      ''');
  }

  @override
  Future<void> prepare() async {
    bindCategoryIntegrator();
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('category', CategoryTable.ref(),
          rField: 'id', notNull: true),
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
  Future<ScheduleRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var categories = await CategoryTable.use();
    var monthlyRepeatOffset =
        row['repeat_option_monthly_head_origin_in_days'] as int?;
    monthlyRepeatOffset ??=
        row['repeat_option_monthly_tail_origin_in_days'] as int?;
    return ScheduleRecord(
      id: row['id'] as int,
      category: await categories.fetchById(row['category'] as int, txn),
      supplement: row['supplement'] as String,
      amount: row['amount'] as int,
      registorationDate: intToDate(row['origin_date'] as int)!,
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
      monthlyRepeatOffset: monthlyRepeatOffset ?? 0,
      startDate: intToDate(row['period_option_begin_from'] as int?),
      endDate: intToDate(row['period_option_end_at'] as int?),
    );
  }

  @override
  void validate(ScheduleRecord data) {
    if (data.category == null || data.registorationDate == null) {
      throw InvalidDataException(
          'category and registorationDate must not be null');
    }
  }

  @override
  Map<String, Object?> serialize(ScheduleRecord data) {
    return {
      'category': data.category!.id,
      'supplement': data.supplement,
      'amount': data.amount,
      'origin_date': dateToInt(data.registorationDate)!,
      'repeat_type': data.repeatType.index,
      'repeat_option_interval_in_days': data.repeatInterval.inDays,
      'repeat_option_on_Sunday':
          data.repeatDayOfWeek.contains(DayOfWeek.sunday) ? 1 : 0,
      'repeat_option_on_Monday':
          data.repeatDayOfWeek.contains(DayOfWeek.monday) ? 1 : 0,
      'repeat_option_on_Tuesday':
          data.repeatDayOfWeek.contains(DayOfWeek.tuesday) ? 1 : 0,
      'repeat_option_on_Wednesday':
          data.repeatDayOfWeek.contains(DayOfWeek.wednesday) ? 1 : 0,
      'repeat_option_on_Thursday':
          data.repeatDayOfWeek.contains(DayOfWeek.thursday) ? 1 : 0,
      'repeat_option_on_Friday':
          data.repeatDayOfWeek.contains(DayOfWeek.friday) ? 1 : 0,
      'repeat_option_on_Saturday':
          data.repeatDayOfWeek.contains(DayOfWeek.sunday) ? 1 : 0,
      'repeat_option_monthly_head_origin_in_days':
          data.monthlyRepeatType == MonthlyRepeatType.fromHead
              ? data.monthlyRepeatOffset
              : null,
      'repeat_option_monthly_tail_origin_in_days':
          data.monthlyRepeatType == MonthlyRepeatType.fromTail
              ? data.monthlyRepeatOffset
              : null,
      'period_option_begin_from': dateToInt(data.startDate),
      'period_option_end_at': dateToInt(data.endDate),
    };
  }

  @override
  Future<void> link(Transaction txn, ScheduleRecord data, {int? id}) async {
    var futureTicketFactoryTable = await FutureTicketFactoryTable.use();
    id ??= data.id;
    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }
    await futureTicketFactoryTable.onFactoryUpdated(id, this, txn);
  }

  @override
  Future<void> unlink(Transaction txn, ScheduleRecord data) async {
    var futureTicketFactoryTable = await FutureTicketFactoryTable.use();
    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }
    await futureTicketFactoryTable.onFactoryDeleted(data.id!, this, txn);
  }
}
// </Repository>
// </Schedule Ticket>

// <Estimation Ticket>
// <enums>
enum EstimationTicketContentType {
  perDay,
  perWeek,
  perMonth,
  perYear,
}
// </enums>

// <DTO>
class EstimationRecord extends TicketConfigRecord {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final DateTime? startDate;
  final DateTime? endDate;
  final EstimationTicketContentType contentType;

  @override
  Future<void> save() async {
    developer.log('save estimation ticket config data');
    throw UnimplementedError();
    // in progress
  }

  @override
  Future<void> delete() async {
    developer.log('delete estimation ticket config data');
    throw UnimplementedError();
    // in progress
  }

  const EstimationRecord(
      {super.id,
      this.targetCategories = const <Category>[],
      this.targetingAllCategories = false,
      this.startDate,
      this.endDate,
      this.contentType = EstimationTicketContentType.perMonth});
}
// </DTO>

// <Repository>
class EstimationTable extends Table<EstimationRecord> {
  @override
  covariant String tableName = 'Estimations';

  // <constructor>
  EstimationTable._internal();
  static final EstimationTable _instance = EstimationTable._internal();
  static Future<EstimationTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory EstimationTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeLinkerField(EstimationTargetCategoryLinker.ref()),
      makeDateField('period_option_begin_from'),
      makeDateField('period_option_end_at'),
      makeEnumField('content_type', EstimationTicketContentType.values),
    ]));
  }

  @override
  Future<EstimationRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var linker = await EstimationTargetCategoryLinker.use();
    var targetCategories = await linker.fetchValues(row['id'] as int, txn);
    return EstimationRecord(
      id: row['id'] as int,
      targetCategories: targetCategories,
      targetingAllCategories: targetCategories.isEmpty,
      startDate: intToDate(row['period_option_begin_from'] as int?),
      endDate: intToDate(row['period_option_end_at'] as int?),
      contentType:
          EstimationTicketContentType.values[row['content_type'] as int],
    );
  }

  @override
  void validate(EstimationRecord data) {} // always valid

  @override
  Map<String, Object?> serialize(EstimationRecord data) {
    return {
      'period_option_begin_from': dateToInt(data.startDate),
      'period_option_end_at': dateToInt(data.endDate),
      'content_type': data.contentType.index,
    };
  }

  @override
  Future<void> link(Transaction txn, EstimationRecord data, {int? id}) async {
    // Because following lines are not heavy, execute them in sequence (to simplify).
    var linker = await EstimationTargetCategoryLinker.use();
    var futureTicketFactoryTable = await FutureTicketFactoryTable.use();

    id ??= data.id;
    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }

    // category linking should be done before factory update
    // because factory update may need category information
    if (data.targetingAllCategories) {
      await linker.linkValues(id, const [], txn);
    } else {
      await linker.linkValues(id, data.targetCategories, txn);
    }
    await futureTicketFactoryTable.onFactoryUpdated(id, this, txn);
  }

  @override
  Future<void> unlink(Transaction txn, EstimationRecord data) async {
    // Because following lines are not heavy, execute them in sequence (to simplify).
    var linker = await EstimationTargetCategoryLinker.use();
    var futureTicketFactoryTable = await FutureTicketFactoryTable.use();

    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }

    await Future.wait([
      linker.linkValues(data.id!, const [], txn),
      futureTicketFactoryTable.onFactoryDeleted(data.id!, this, txn),
    ]);
  }
}

class EstimationTargetCategoryLinker extends Table<Link>
    with Linker<EstimationRecord, Category>, HaveCategoryField, CategoryLinker {
  @override
  covariant String tableName = 'EstimationTargetCategoryLinker';
  @override
  final keyTable = EstimationTable.ref();
  @override
  final valueTable = CategoryTable.ref();

  // <constructor>
  EstimationTargetCategoryLinker._internal();
  static final EstimationTargetCategoryLinker _instance =
      EstimationTargetCategoryLinker._internal();
  static Future<EstimationTargetCategoryLinker> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory EstimationTargetCategoryLinker.ref() => _instance;
  // </constructor>

  @override
  Future<List<Category>> fetchValuesByIds(
      List<int> valueIds, Transaction? txn) async {
    var categories = await CategoryTable.use();
    return categories.fetchByIds(valueIds, txn);
  }
}
// </Repository>
// </Estimation Ticket>

// <Log Ticket>
// <enums>
// </enums>
// <DTO>
class LogRecord extends TicketConfigRecord {
  final Category? category;
  final String supplement;
  final DateTime? registorationDate;
  final int amount;
  final File? image;
  final bool confirmed;

  const LogRecord(
      {super.id,
      this.category,
      this.supplement = '',
      this.registorationDate,
      this.amount = 0,
      this.confirmed = false,
      this.image});

  @override
  Future<void> save() async {
    developer.log('save log ticket config data');
    // in progress
  }

  @override
  Future<void> delete() async {
    developer.log('delete log ticket config data');
    // in progress
  }

  LogRecord applyPreset(LogRecord preset) {
    return LogRecord(
      id: id,
      category: preset.category,
      supplement: preset.supplement,
      registorationDate: registorationDate,
      amount: preset.amount,
      confirmed: confirmed,
      image: image,
    );
  }
}
// </DTO>

// <Repository>
class LogRecordTable extends Table<LogRecord> with HaveCategoryField {
  @override
  covariant String tableName = 'Logs';

  // <constructor>
  LogRecordTable._internal();
  static final LogRecordTable _instance = LogRecordTable._internal();
  static Future<LogRecordTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory LogRecordTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName 
      SET category = ${replaceWith.id} 
      WHERE category = ${replaced.id}
      ''');
  }

  @override
  Future<void> prepare() async {
    bindCategoryIntegrator();
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('category', CategoryTable.ref(),
          rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeDateField('registeredAt', notNull: true),
      makeIntegerField('amount', notNull: true),
      makeTextField('imagePath'),
      makeBooleanField('confirmed'),
    ]));
  }

  @override
  Future<LogRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var categories = await CategoryTable.use();
    return LogRecord(
      id: row['id'] as int,
      category: await categories.fetchById(row['category'] as int, txn),
      supplement: row['supplement'] as String,
      registorationDate: intToDate(row['registeredAt'] as int)!,
      amount: row['amount'] as int,
      confirmed: row['confirmed'] as bool,
      image: row['imagePath'] != null ? File(row['imagePath'] as String) : null,
    );
  }

  @override
  void validate(LogRecord data) {
    if (data.category == null || data.registorationDate == null) {
      throw InvalidDataException(
          'category and registorationDate must not be null');
    }
  }

  @override
  Map<String, Object?> serialize(LogRecord data) {
    return {
      'category': data.category!.id,
      'supplement': data.supplement,
      'registeredAt': dateToInt(data.registorationDate)!,
      'amount': data.amount,
      'imagePath': data.image?.path,
      'confirmed': data.confirmed ? 1 : 0,
    };
  }
}
// </Repository>
// </Log Ticket>

// </ticket config data>
