import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'category_data.dart';
import './database.dart';
import './future_ticket_data.dart';
import './general_enum.dart';

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
// <ticket config shared traits>
abstract class TicketConfigRecord extends DTO {
  const TicketConfigRecord({super.id});
  Future<void> save();
  Future<void> delete();
}

mixin TicketTable<T extends DTO> on Table<T> {
  Future<List<T>> fetchTicketsRegisteredAt(DateTime date, Transaction? txn);
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
  Future<void> save() async {
    var table = await DisplayTicketTable.use(null);
    await table.save(this, null);
  }

  @override
  Future<void> delete() async {
    var table = await DisplayTicketTable.use(null);
    await table.delete(this, null);
  }
}
// </DTO>

// <Repository>
class DisplayTicketTable extends Table<DisplayTicketRecord> with TicketTable {
  @override
  covariant String tableName = 'DisplayTickets';

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
      return Table.dbProvider.db.transaction((txn) async {
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
  Future<void> unlink(Transaction txn, DisplayTicketRecord data) async {
    var linker = await DisplayTicketTargetCategoryLinker.use(txn);
    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }
    await linker.linkValues(data.id!, const [], txn);
  }

  @override
  Future<void> clear() {
    DisplayTicketTargetCategoryLinker.ref().clear();
    return super.clear();
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
  Future<List<DisplayTicketRecord>> fetchTicketsRegisteredAt(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return fetchTicketsRegisteredAt(date, txn);
      });
    }

    await ensureAvailability(txn);
    var result = await txn.rawQuery('''
      SELECT * FROM $tableName
      WHERE DATE( $limitDateField ) <= DATE( ${dateToInt(date)} ) OR $limitDateField IS NULL
    ''');
    return [for (var row in result) await interpret(row, txn)];
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
  final List<DayOfWeek> repeatDayOfWeek;
  final MonthlyRepeatType monthlyRepeatType;
  final int monthlyRepeatOffset;
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
    this.repeatDayOfWeek = const [],
    this.monthlyRepeatType = MonthlyRepeatType.fromHead,
    this.monthlyRepeatOffset = 0,
    this.startDate,
    this.endDate,
  });

  @override
  Future<void> save() async {
    var table = await ScheduleTable.use(null);
    await table.save(this, null);
  }

  @override
  Future<void> delete() async {
    var table = await ScheduleTable.use(null);
    await table.delete(this, null);
  }
}
// </DTO>

// <Repository>
class ScheduleTable extends Table<ScheduleRecord> with HaveCategoryField {
  @override
  covariant String tableName = 'Schedules';

  // <field names>
  static const String supplementField = 'supplement';
  static const String categoryField = 'category';
  static const String amountField = 'amount';
  static const String originDateField = 'origin_date';
  static const String repeatTypeField = 'repeat_type';
  static const String repeatIntervalField = 'repeat_option_interval_in_days';
  static const Map<DayOfWeek, String> repeatOnDay = {
    DayOfWeek.sunday: 'repeat_option_on_Sunday',
    DayOfWeek.monday: 'repeat_option_on_Monday',
    DayOfWeek.tuesday: 'repeat_option_on_Tuesday',
    DayOfWeek.wednesday: 'repeat_option_on_Wednesday',
    DayOfWeek.thursday: 'repeat_option_on_Thursday',
    DayOfWeek.friday: 'repeat_option_on_Friday',
    DayOfWeek.saturday: 'repeat_option_on_Saturday',
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
      return Table.dbProvider.db.transaction((txn) async {
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
      makeBooleanField(repeatOnDay[DayOfWeek.sunday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.monday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.tuesday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.wednesday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.thursday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.friday]!),
      makeBooleanField(repeatOnDay[DayOfWeek.saturday]!),
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
    var monthlyRepeatOffset = row[monthlyRepeatHeadOriginField] as int?;
    monthlyRepeatOffset ??= row[monthlyRepeatTailOriginField] as int?;
    return ScheduleRecord(
      id: row[Table.idField] as int,
      category: await categories.fetchById(row[categoryField] as int, txn),
      supplement: row[supplementField] as String,
      amount: row[amountField] as int,
      originDate: intToDate(row[originDateField] as int)!,
      repeatType: RepeatType.values[row[repeatTypeField] as int],
      repeatInterval: Duration(days: row[repeatIntervalField] as int),
      repeatDayOfWeek: [
        if (row[repeatOnDay[DayOfWeek.sunday]!] == 1) DayOfWeek.sunday,
        if (row[repeatOnDay[DayOfWeek.monday]!] == 1) DayOfWeek.monday,
        if (row[repeatOnDay[DayOfWeek.tuesday]!] == 1) DayOfWeek.tuesday,
        if (row[repeatOnDay[DayOfWeek.wednesday]!] == 1) DayOfWeek.wednesday,
        if (row[repeatOnDay[DayOfWeek.thursday]!] == 1) DayOfWeek.thursday,
        if (row[repeatOnDay[DayOfWeek.friday]!] == 1) DayOfWeek.friday,
        if (row[repeatOnDay[DayOfWeek.saturday]!] == 1) DayOfWeek.saturday,
      ],
      monthlyRepeatType: row[monthlyRepeatHeadOriginField] != null
          ? MonthlyRepeatType.fromHead
          : MonthlyRepeatType.fromTail,
      monthlyRepeatOffset: monthlyRepeatOffset ?? 0,
      startDate: intToDate(row[periodBeginField] as int?),
      endDate: intToDate(row[periodEndField] as int?),
    );
  }

  @override
  void validate(ScheduleRecord data) {
    if (data.category == null || data.originDate == null) {
      throw InvalidDataException(
          'category and registorationDate must not be null');
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
      repeatOnDay[DayOfWeek.sunday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.sunday) ? 1 : 0,
      repeatOnDay[DayOfWeek.monday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.monday) ? 1 : 0,
      repeatOnDay[DayOfWeek.tuesday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.tuesday) ? 1 : 0,
      repeatOnDay[DayOfWeek.wednesday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.wednesday) ? 1 : 0,
      repeatOnDay[DayOfWeek.thursday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.thursday) ? 1 : 0,
      repeatOnDay[DayOfWeek.friday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.friday) ? 1 : 0,
      repeatOnDay[DayOfWeek.saturday]!:
          data.repeatDayOfWeek.contains(DayOfWeek.sunday) ? 1 : 0,
      monthlyRepeatHeadOriginField:
          data.monthlyRepeatType == MonthlyRepeatType.fromHead
              ? data.monthlyRepeatOffset
              : null,
      monthlyRepeatTailOriginField:
          data.monthlyRepeatType == MonthlyRepeatType.fromTail
              ? data.monthlyRepeatOffset
              : null,
      periodBeginField: dateToInt(data.startDate),
      periodEndField: dateToInt(data.endDate),
    };
  }

  // <linking handler>
  @override
  Future<void> link(Transaction txn, ScheduleRecord data, {int? id}) async {
    var futureTicketFactoryTable =
        await FutureTicketFactoryAbstractorTable.use(txn);
    id ??= data.id;
    if (id == null) {
      throw IlligalUsageException('Tried to link with null id');
    }
    await futureTicketFactoryTable.onFactoryUpdated(data, txn);
  }

  @override
  Future<void> unlink(Transaction txn, ScheduleRecord data) async {
    var futureTicketFactoryTable =
        await FutureTicketFactoryAbstractorTable.use(txn);
    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }
    await futureTicketFactoryTable.onFactoryDeleted(data, txn);
  }

  @override
  Future<void> clear() {
    FutureTicketFactoryAbstractorTable.ref().clear();
    FutureTicketTable.ref().clear();
    return super.clear();
  }
  // </linking handler>
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
  Future<void> save() async {
    var table = await EstimationTable.use(null);
    await table.save(this, null);
  }

  @override
  Future<void> delete() async {
    var table = await EstimationTable.use(null);
    await table.delete(this, null);
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
      return Table.dbProvider.db.transaction((txn) async {
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
    var futureTicketFactoryTable =
        await FutureTicketFactoryAbstractorTable.use(txn);

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
    await futureTicketFactoryTable.onFactoryUpdated(data, txn);
  }

  @override
  Future<void> unlink(Transaction txn, EstimationRecord data) async {
    // Because following lines are not heavy, execute them in sequence (to simplify).
    var linker = await EstimationTargetCategoryLinker.use(txn);
    var futureTicketFactoryTable =
        await FutureTicketFactoryAbstractorTable.use(txn);

    if (data.id == null) {
      throw IlligalUsageException('Tried to unlink with null id');
    }

    await Future.wait([
      linker.linkValues(data.id!, const [], txn),
      futureTicketFactoryTable.onFactoryDeleted(data, txn),
    ]);
  }

  @override
  Future<void> clear() {
    EstimationTargetCategoryLinker.ref().clear();
    FutureTicketFactoryAbstractorTable.ref().clear();
    FutureTicketTable.ref().clear();
    return super.clear();
  }
  // </linking handler>
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
  static Future<EstimationTargetCategoryLinker> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory EstimationTargetCategoryLinker.ref() => _instance;
  // </constructor>

  @override
  Future<List<Category>> fetchValuesByIds(
      List<int> valueIds, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return fetchValuesByIds(valueIds, txn);
      });
    }

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
  Future<void> save() async {
    var table = await LogRecordTable.use(null);
    await table.save(this, null);
  }

  @override
  Future<void> delete() async {
    var table = await LogRecordTable.use(null);
    await table.delete(this, null);
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
      return Table.dbProvider.db.transaction((txn) async {
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
}
// </Repository>
// </Log Ticket>

// </ticket config data>
