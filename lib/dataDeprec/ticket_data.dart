import 'dart:io';
import 'dart:developer' as dev;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:miraibo/dataDeprec/category_data.dart';
import 'package:miraibo/dataDeprec/database.dart';
import 'package:miraibo/dataDeprec/future_ticket_data.dart';
import 'package:miraibo/dataDeprec/general_enum.dart';

import 'package:miraibo/background_worker/future_ticket_preparation.dart';

/* 
This file contains the data classes that define the structure of the data / 1st layer-repositories, 
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
// <ticket config shared traits>
abstract class TicketConfigRecord extends DTO {
  const TicketConfigRecord({super.id});
  Future<TicketConfigRecord> save();
  Future<void> delete();
}

mixin TicketTable<T extends TicketConfigRecord> on Table<T> {
  Future<List<T>> fetchBelongsTo(DateTime date, Transaction? txn);
}
// </ticket config shared traits>

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
class DisplayTicketRecord extends TicketConfigRecord {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final DisplayTicketTermMode termMode;
  final DateTime? designatedDate;
  final DisplayTicketPeriod designatedPeriod;
  final DisplayTicketContentType contentType;

  const DisplayTicketRecord({
    super.id,
    this.targetCategories = const <Category>[],
    this.targetingAllCategories = true,
    this.termMode = DisplayTicketTermMode.untilToday,
    this.designatedDate,
    this.designatedPeriod = DisplayTicketPeriod.week,
    this.contentType = DisplayTicketContentType.summation,
  });

  @override
  Future<DisplayTicketRecord> save() async {
    var table = await DisplayTicketTable.use(null);
    var id = await table.save(this, null);
    return DisplayTicketRecord(
      id: id,
      targetCategories: targetCategories,
      targetingAllCategories: targetingAllCategories,
      termMode: termMode,
      designatedDate: designatedDate,
      designatedPeriod: designatedPeriod,
      contentType: contentType,
    );
  }

  @override
  Future<void> delete() async {
    var table = await DisplayTicketTable.use(null);
    if (id == null) return;
    await table.delete(id!, null);
  }
}
// </DTO>

// <Repository>
class DisplayTicketTable extends Table<DisplayTicketRecord> with TicketTable {
  @override
  covariant String tableName = 'DisplayTickets';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field names>
  static const String periodInDaysField = 'period_in_days';
  static const String limitDateField = 'limit_date';
  static const String contentTypeField = 'content_type';
  // </field names>

  // <constructor>
  DisplayTicketTable._internal();
  static final DisplayTicketTable _instance = DisplayTicketTable._internal();
  static Future<DisplayTicketTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory DisplayTicketTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }
    await txn.execute(makeTable([
      makeIdField(),
      // null means targeting all categories
      makeIntegerField(periodInDaysField),
      makeDateField(limitDateField),
      makeEnumField(contentTypeField, DisplayTicketContentType.values),
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
  Future<void> link(Transaction txn, DisplayTicketRecord data,
      {int? id}) async {
    var linker = await DisplayTicketTargetCategoryLinker.use(txn);
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
  Future<void> unlink(Transaction txn, int id) async {
    var linker = await DisplayTicketTargetCategoryLinker.use(txn);
    await linker.linkValues(id, const [], txn);
  }
  // </linking handler>

  @override
  Future<DisplayTicketRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    int? periodInDays = row[periodInDaysField] as int?;
    int? limitDate = row[limitDateField] as int?;

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

    var id = row[Table.idField] as int;

    var linker = await DisplayTicketTargetCategoryLinker.use(txn);
    var targetCategories = await linker.fetchValues(id, txn);

    return DisplayTicketRecord(
      id: id,
      targetCategories: targetCategories,
      targetingAllCategories: targetCategories.isEmpty,
      termMode: termMode,
      designatedDate: intToDate(limitDate),
      designatedPeriod: periodExpressionFromDays(periodInDays),
      contentType:
          DisplayTicketContentType.values[row[contentTypeField] as int],
    );
  }

  @override
  void validate(DisplayTicketRecord data) {
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
  Map<String, Object?> serialize(DisplayTicketRecord data) {
    return {
      periodInDaysField:
          data.termMode == DisplayTicketTermMode.lastDesignatedPeriod
              ? daysFromPeriodExpression(data.designatedPeriod)
              : null,
      limitDateField: dateToInt(data.designatedDate),
      contentTypeField: data.contentType.index,
    };
  }

  // <tickets fetch methods>
  @override
  Future<List<DisplayTicketRecord>> fetchBelongsTo(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchBelongsTo(date, txn);
      });
    }

    var result = await txn.rawQuery('''
      SELECT * FROM $tableName
      WHERE (
        $limitDateField IS NULL
      ) OR (
        $limitDateField >= ${dateToInt(date)}
      )
    ''');

    return Future.wait([for (var row in result) interpret(row, txn)]);
  }
  // </tickets fetch methods>
}

class DisplayTicketTargetCategoryLinker extends Table<Link>
    with
        Linker<DisplayTicketRecord, Category>,
        HaveCategoryField,
        CategoryLinker {
  @override
  covariant String tableName = 'DisplayTicketTargetCategoryLinker';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();
  @override
  final keyTable = DisplayTicketTable.ref();
  @override
  final valueTable = CategoryTable.ref();

  // <constructor>
  DisplayTicketTargetCategoryLinker._internal();
  static final DisplayTicketTargetCategoryLinker _instance =
      DisplayTicketTargetCategoryLinker._internal();
  static Future<DisplayTicketTargetCategoryLinker> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory DisplayTicketTargetCategoryLinker.ref() => _instance;
  // </constructor>

  @override
  Future<List<Category>> fetchValuesByIds(
      List<int> valueIds, Transaction? txn) async {
    var categories = await CategoryTable.use(txn);
    return categories.fetchByIds(valueIds, txn);
  }
}
// </Repository>
// </Display Ticket>

// <Schedule Ticket>
// <enums>
enum RepeatType { no, interval, weekly, monthly, anually }

enum MonthlyRepeatType { fromHead, fromTail }
// </enums>

// <DTO>
class ScheduleRecord extends TicketConfigRecord with FutureTicketFactory {
  final Category? category;
  final String supplement;
  final DateTime? originDate;
  final int amount;
  final RepeatType repeatType;
  final Duration repeatInterval;
  final List<Weekday> repeatWeekdays;
  final Duration? monthlyRepeatHeadOriginOffset;
  final Duration? monthlyRepeatTailOriginOffset;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScheduleRecord({
    super.id,
    this.category,
    this.supplement = '',
    this.originDate,
    this.amount = 0,
    this.repeatType = RepeatType.no,
    this.repeatInterval = const Duration(days: 1),
    this.repeatWeekdays = const [],
    this.monthlyRepeatHeadOriginOffset,
    this.monthlyRepeatTailOriginOffset,
    this.startDate,
    this.endDate,
  });

  @override
  Future<ScheduleRecord> save() async {
    var table = await ScheduleTable.use(null);
    await table.save(this, null);
    return ScheduleRecord(
      id: id,
      category: category,
      supplement: supplement,
      originDate: originDate,
      amount: amount,
      repeatType: repeatType,
      repeatInterval: repeatInterval,
      repeatWeekdays: repeatWeekdays,
      monthlyRepeatHeadOriginOffset: monthlyRepeatHeadOriginOffset,
      monthlyRepeatTailOriginOffset: monthlyRepeatTailOriginOffset,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> delete() async {
    var table = await ScheduleTable.use(null);
    if (id == null) return;
    await table.delete(id!, null);
  }
}
// </DTO>

// <Repository>
class ScheduleTable extends Table<ScheduleRecord>
    with HaveCategoryField, TicketTable {
  @override
  covariant String tableName = 'Schedules';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field names>
  static const String supplementField = 'supplement';
  static const String categoryField = 'category';
  static const String amountField = 'amount';
  static const String originDateField = 'origin_date';
  static const String repeatTypeField = 'repeat_type';
  static const String repeatIntervalField = 'repeat_option_interval_in_days';
  static const Map<Weekday, String> repeatOnDay = {
    Weekday.sunday: 'repeat_option_on_Sunday',
    Weekday.monday: 'repeat_option_on_Monday',
    Weekday.tuesday: 'repeat_option_on_Tuesday',
    Weekday.wednesday: 'repeat_option_on_Wednesday',
    Weekday.thursday: 'repeat_option_on_Thursday',
    Weekday.friday: 'repeat_option_on_Friday',
    Weekday.saturday: 'repeat_option_on_Saturday',
  };
  static const String monthlyRepeatHeadOriginField =
      'repeat_option_monthly_head_origin_in_days';
  static const String monthlyRepeatTailOriginField =
      'repeat_option_monthly_tail_origin_in_days';
  static const String periodBeginField = 'period_option_begin_from';
  static const String periodEndField = 'period_option_end_at';
  // </field names>

  // <constructor>
  ScheduleTable._internal();
  static final ScheduleTable _instance = ScheduleTable._internal();
  static Future<ScheduleTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory ScheduleTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName 
      SET $categoryField = ${replaceWith.id} 
      WHERE $categoryField = ${replaced.id}
      ''');
  }

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    bindCategoryIntegrator();
    await txn.execute(makeTable([
      makeIdField(),
      makeTextField(supplementField, notNull: true),
      ...makeForeignField(categoryField, CategoryTable.ref(),
          rField: Table.idField, notNull: true),
      makeIntegerField(amountField, notNull: true),
      makeDateField(originDateField, notNull: true),
      makeEnumField(repeatTypeField, RepeatType.values),
      makeIntegerField(repeatIntervalField, notNull: true),
      makeBooleanField(repeatOnDay[Weekday.sunday]!),
      makeBooleanField(repeatOnDay[Weekday.monday]!),
      makeBooleanField(repeatOnDay[Weekday.tuesday]!),
      makeBooleanField(repeatOnDay[Weekday.wednesday]!),
      makeBooleanField(repeatOnDay[Weekday.thursday]!),
      makeBooleanField(repeatOnDay[Weekday.friday]!),
      makeBooleanField(repeatOnDay[Weekday.saturday]!),
      makeIntegerField(monthlyRepeatHeadOriginField),
      makeIntegerField(monthlyRepeatTailOriginField),
      makeDateField(periodBeginField),
      makeDateField(periodEndField),
    ]));
  }

  @override
  Future<ScheduleRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var categories = await CategoryTable.use(txn);
    return ScheduleRecord(
      id: row[Table.idField] as int,
      category: await categories.fetchById(row[categoryField] as int, txn),
      supplement: row[supplementField] as String,
      amount: row[amountField] as int,
      originDate: intToDate(row[originDateField] as int)!,
      repeatType: RepeatType.values[row[repeatTypeField] as int],
      repeatInterval: Duration(days: row[repeatIntervalField] as int),
      repeatWeekdays: [
        if (row[repeatOnDay[Weekday.sunday]!] == 1) Weekday.sunday,
        if (row[repeatOnDay[Weekday.monday]!] == 1) Weekday.monday,
        if (row[repeatOnDay[Weekday.tuesday]!] == 1) Weekday.tuesday,
        if (row[repeatOnDay[Weekday.wednesday]!] == 1) Weekday.wednesday,
        if (row[repeatOnDay[Weekday.thursday]!] == 1) Weekday.thursday,
        if (row[repeatOnDay[Weekday.friday]!] == 1) Weekday.friday,
        if (row[repeatOnDay[Weekday.saturday]!] == 1) Weekday.saturday,
      ],
      monthlyRepeatHeadOriginOffset:
          intToDuration(row[monthlyRepeatHeadOriginField] as int?),
      monthlyRepeatTailOriginOffset:
          intToDuration(row[monthlyRepeatTailOriginField] as int?),
      startDate: intToDate(row[periodBeginField] as int?),
      endDate: intToDate(row[periodEndField] as int?),
    );
  }

  @override
  void validate(ScheduleRecord data) {
    if (data.category == null || data.originDate == null) {
      throw InvalidDataException(
          '[category] and [originDate] of saved schedule ticket must not be null');
    }
    if (data.repeatType == RepeatType.monthly &&
        data.monthlyRepeatHeadOriginOffset == null &&
        data.monthlyRepeatTailOriginOffset == null) {
      throw InvalidDataException(
          'Both head origin and tail origin offset are null.');
    }
    if (data.monthlyRepeatHeadOriginOffset != null &&
        data.monthlyRepeatTailOriginOffset != null) {
      throw InvalidDataException(
          'Both head origin and tail origin offset are set.');
    }
  }

  @override
  Map<String, Object?> serialize(ScheduleRecord data) {
    return {
      categoryField: data.category!.id,
      supplementField: data.supplement,
      amountField: data.amount,
      originDateField: dateToInt(data.originDate)!,
      repeatTypeField: data.repeatType.index,
      repeatIntervalField: data.repeatInterval.inDays,
      repeatOnDay[Weekday.sunday]!:
          data.repeatWeekdays.contains(Weekday.sunday) ? 1 : 0,
      repeatOnDay[Weekday.monday]!:
          data.repeatWeekdays.contains(Weekday.monday) ? 1 : 0,
      repeatOnDay[Weekday.tuesday]!:
          data.repeatWeekdays.contains(Weekday.tuesday) ? 1 : 0,
      repeatOnDay[Weekday.wednesday]!:
          data.repeatWeekdays.contains(Weekday.wednesday) ? 1 : 0,
      repeatOnDay[Weekday.thursday]!:
          data.repeatWeekdays.contains(Weekday.thursday) ? 1 : 0,
      repeatOnDay[Weekday.friday]!:
          data.repeatWeekdays.contains(Weekday.friday) ? 1 : 0,
      repeatOnDay[Weekday.saturday]!:
          data.repeatWeekdays.contains(Weekday.sunday) ? 1 : 0,
      monthlyRepeatHeadOriginField:
          durationToInt(data.monthlyRepeatHeadOriginOffset),
      monthlyRepeatTailOriginField:
          durationToInt(data.monthlyRepeatTailOriginOffset),
      periodBeginField: dateToInt(data.startDate),
      periodEndField: dateToInt(data.endDate),
    };
  }

  // <linking handler>
  @override
  Future<void> link(Transaction txn, ScheduleRecord data, {int? id}) async {
    id ??= data.id;
    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }
    data = ScheduleRecord(
      id: id,
      category: data.category,
      supplement: data.supplement,
      originDate: data.originDate,
      amount: data.amount,
      repeatType: data.repeatType,
      repeatInterval: data.repeatInterval,
      repeatWeekdays: data.repeatWeekdays,
      monthlyRepeatHeadOriginOffset: data.monthlyRepeatHeadOriginOffset,
      monthlyRepeatTailOriginOffset: data.monthlyRepeatTailOriginOffset,
      startDate: data.startDate,
      endDate: data.endDate,
    );
    await FutureTicketPreparationEventHandler().onFactoryUpdated(data, txn);
  }

  @override
  Future<void> unlink(Transaction txn, int id) async {
    await FutureTicketPreparationEventHandler()
        .onFactoryDeleted(id, ScheduleTable.ref(), txn);
  }
  // </linking handler>

  // <tickets fetch methods>
  @override
  Future<List<ScheduleRecord>> fetchBelongsTo(
      DateTime date, Transaction? txn) async {
    var futureTicketTable = await FutureTicketTable.use(txn);
    return futureTicketTable.fetchSchedulesFor(date, txn);
  }
  // </tickets fetch methods>
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
class EstimationRecord extends TicketConfigRecord with FutureTicketFactory {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final DateTime? startDate;
  final DateTime? endDate;
  final EstimationTicketContentType contentType;

  @override
  Future<EstimationRecord> save() async {
    var table = await EstimationTable.use(null);
    var id = await table.save(this, null);
    return EstimationRecord(
      id: id,
      targetCategories: targetCategories,
      targetingAllCategories: targetingAllCategories,
      startDate: startDate,
      endDate: endDate,
      contentType: contentType,
    );
  }

  @override
  Future<void> delete() async {
    var table = await EstimationTable.use(null);
    if (id == null) return;
    await table.delete(id!, null);
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
class EstimationTable extends Table<EstimationRecord> with TicketTable {
  @override
  covariant String tableName = 'Estimations';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field names>
  static const String periodBeginField = 'period_option_begin_from';
  static const String periodEndField = 'period_option_end_at';
  static const String contentTypeField = 'content_type';
  // </field names>

  // <constructor>
  EstimationTable._internal();
  static final EstimationTable _instance = EstimationTable._internal();
  static Future<EstimationTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory EstimationTable.ref() => _instance;
  // </constructor>

  // <initialization>
  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    await txn.execute(makeTable([
      makeIdField(),
      makeDateField(periodBeginField),
      makeDateField(periodEndField),
      makeEnumField(contentTypeField, EstimationTicketContentType.values),
    ]));
  }
  // </initialization>

  // <basic table operation>
  @override
  Future<EstimationRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var linker = await EstimationTargetCategoryLinker.use(txn);
    var targetCategories =
        await linker.fetchValues(row[Table.idField] as int, txn);
    return EstimationRecord(
      id: row[Table.idField] as int,
      targetCategories: targetCategories,
      targetingAllCategories: targetCategories.isEmpty,
      startDate: intToDate(row[periodBeginField] as int?),
      endDate: intToDate(row[periodEndField] as int?),
      contentType:
          EstimationTicketContentType.values[row[contentTypeField] as int],
    );
  }

  @override
  void validate(EstimationRecord data) {} // always valid

  @override
  Map<String, Object?> serialize(EstimationRecord data) {
    return {
      periodBeginField: dateToInt(data.startDate),
      periodEndField: dateToInt(data.endDate),
      contentTypeField: data.contentType.index,
    };
  }
  // </basic table operation>

  // <linking handler>
  @override
  Future<void> link(Transaction txn, EstimationRecord data, {int? id}) async {
    // Because following lines are not heavy, execute them in sequence (to simplify).
    var linker = await EstimationTargetCategoryLinker.use(txn);

    id ??= data.id;

    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }

    data = EstimationRecord(
      id: id,
      targetCategories: data.targetCategories,
      targetingAllCategories: data.targetingAllCategories,
      startDate: data.startDate,
      endDate: data.endDate,
      contentType: data.contentType,
    );

    // category linking should be done before factory update
    // because factory update may need category information
    if (data.targetingAllCategories) {
      await linker.linkValues(id, const [], txn);
    } else {
      await linker.linkValues(id, data.targetCategories, txn);
    }
    await FutureTicketPreparationEventHandler().onFactoryUpdated(data, txn);
  }

  @override
  Future<void> unlink(Transaction txn, int id) async {
    // Because following lines are not heavy, execute them in sequence (to simplify).
    var linker = await EstimationTargetCategoryLinker.use(txn);

    await Future.wait([
      linker.linkValues(id, const [], txn),
      FutureTicketPreparationEventHandler()
          .onFactoryDeleted(id, EstimationTable.ref(), txn),
    ]);
  }
  // </linking handler>

  // <tickets fetch methods>
  @override
  Future<List<EstimationRecord>> fetchBelongsTo(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchBelongsTo(date, txn);
      });
    }

    var result = await txn.rawQuery('''
      SELECT * FROM $tableName
      WHERE (
        $periodBeginField IS NULL 
        OR 
        $periodBeginField <= ${dateToInt(date)}
      ) AND (
        $periodEndField IS NULL 
        OR 
        $periodEndField >= ${dateToInt(date)}
      );
    ''');
    return Future.wait([for (var row in result) interpret(row, txn)]);
  }
  // </tickets fetch methods>
}

class EstimationTargetCategoryLinker extends Table<Link>
    with Linker<EstimationRecord, Category>, HaveCategoryField, CategoryLinker {
  @override
  covariant String tableName = 'EstimationTargetCategoryLinker';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();
  @override
  final keyTable = EstimationTable.ref();
  @override
  final valueTable = CategoryTable.ref();

  // <constructor>
  EstimationTargetCategoryLinker._internal();
  static final EstimationTargetCategoryLinker _instance =
      EstimationTargetCategoryLinker._internal();
  static Future<EstimationTargetCategoryLinker> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory EstimationTargetCategoryLinker.ref() => _instance;
  // </constructor>

  @override
  Future<List<Category>> fetchValuesByIds(
      List<int> valueIds, Transaction? txn) async {
    var categories = await CategoryTable.use(txn);
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
  Future<LogRecord> save() async {
    var table = await LogRecordTable.use(null);
    var id = await table.save(this, null);
    return LogRecord(
      id: id,
      category: category,
      supplement: supplement,
      registorationDate: registorationDate,
      amount: amount,
      confirmed: confirmed,
      image: image,
    );
  }

  @override
  Future<void> delete() async {
    var table = await LogRecordTable.use(null);
    if (id == null) return;
    await table.delete(id!, null);
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
class LogRecordTable extends Table<LogRecord>
    with HaveCategoryField, TicketTable {
  @override
  covariant String tableName = 'Logs';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field names>
  static const String supplementField = 'supplement';
  static const String categoryField = 'category';
  static const String registeredAtField = 'registeredAt';
  static const String amountField = 'amount';
  static const String imagePathField = 'imagePath';
  static const String confirmedField = 'confirmed';
  // </field names>

  // <constructor>
  LogRecordTable._internal();
  static final LogRecordTable _instance = LogRecordTable._internal();
  static Future<LogRecordTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory LogRecordTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName 
      SET $categoryField = ${replaceWith.id} 
      WHERE $categoryField = ${replaced.id}
      ''');
  }

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    bindCategoryIntegrator();
    await txn.execute(makeTable([
      makeIdField(),
      makeTextField(supplementField, notNull: true),
      ...makeForeignField(categoryField, CategoryTable.ref(),
          rField: Table.idField, notNull: true),
      makeDateField(registeredAtField, notNull: true),
      makeIntegerField(amountField, notNull: true),
      makeTextField(imagePathField),
      makeBooleanField(confirmedField),
    ]));
  }

  @override
  Future<LogRecord> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var categories = await CategoryTable.use(txn);
    return LogRecord(
      id: row[Table.idField] as int,
      category: await categories.fetchById(row[categoryField] as int, txn),
      supplement: row[supplementField] as String,
      registorationDate: intToDate(row[registeredAtField] as int)!,
      amount: row[amountField] as int,
      confirmed: (row[confirmedField] as int) == 1,
      image: row[imagePathField] != null
          ? File(row[imagePathField] as String)
          : null,
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
      categoryField: data.category!.id,
      supplementField: data.supplement,
      registeredAtField: dateToInt(data.registorationDate)!,
      amountField: data.amount,
      imagePathField: data.image?.path,
      confirmedField: data.confirmed ? 1 : 0,
    };
  }

  // <query methods>
  Future<int> sumUpAmounts(DateTime? begin, DateTime? end, Category? category,
      Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return sumUpAmounts(begin, end, category, txn);
      });
    }

    var whereConditions = <String>[];

    if (begin != null) {
      whereConditions.add('$registeredAtField >= ${dateToInt(begin)}');
    }

    if (end != null) {
      whereConditions.add('$registeredAtField <= ${dateToInt(end)}');
    }

    if (category != null) {
      whereConditions.add('$categoryField = ${category.id}');
    }

    var query = 'SELECT SUM( $amountField ) FROM $tableName';
    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    var result = await txn.rawQuery(query);

    return result.first.values.first as int;
  }

  Future<double> estimateFor(Category category, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return estimateFor(category, txn);
      });
    }

    // Take the average of records that are in the quartile range
    // only if there are enough records.
    var whole = await recordsCount(txn);
    var quartile = whole ~/ 4;
    String query;

    if (whole == 0) {
      dev.log('No records found for estimation');
      return 0;
    }

    if (quartile == 0) {
      query = '''
        SELECT AVG( $amountField ) 
        FROM $tableName 
        WHERE $categoryField = ${category.id}
      ''';
    } else {
      query = '''
        SELECT SUM AVG( $amountField ) 
        FROM $tableName 
        ORDER BY $registeredAtField 
        OFFSET $quartile 
        LIMIT $quartile * 2
      ''';
    }

    var result = await txn.rawQuery(query);
    return result.first.values.first as double;
  }
  // </query methods>

  // <tickets fetch methods>
  @override
  Future<List<LogRecord>> fetchBelongsTo(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchBelongsTo(date, txn);
      });
    }

    var result = await txn.rawQuery('''
      SELECT * FROM $tableName
      WHERE $registeredAtField = ${dateToInt(date)}
    ''');
    return Future.wait([for (var row in result) interpret(row, txn)]);
  }
  // </tickets fetch methods>
}
// </Repository>
// </Log Ticket>

// </ticket config data>
