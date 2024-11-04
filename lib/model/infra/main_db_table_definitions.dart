import 'package:miraibo/model/infra/table_components.dart';
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/model/infra/fields.dart';

// this file defines concreate classes for the database tables

// <category>
enum CategoryFE<T> implements FieldEnum {
  id(IdField()),
  name(TextField('name'));

  const CategoryFE(this.val);
  @override
  final Field<T> val;
}

class Category extends Record {
  int? id;
  String name;

  Category({this.id, required this.name});

  factory Category.interpret(Map<String, Object?> row) {
    return Category(
      id: CategoryFE.id.interpret(row[CategoryFE.id.fn]),
      name: CategoryFE.name.interpret(row[CategoryFE.name.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      CategoryFE.name.fn: CategoryFE.name.serialize(name),
    };
  }
}

class Categories extends Table {
  @override
  List<FieldEnum> get fieldEnums => CategoryFE.values;
  @override
  String get tableName => 'Categories';
}
// </category>

// <display ticket>
enum DTFE<T> implements FieldEnum {
  id(IdField()),
  lastInDays(NullableDaysField('lastInDays')),
  periodBegin(NullableDateField('periodBegin')),
  periodEnd(NullableDateField('periodEnd')),
  contentType(EnumField('contentType', DTContentType.values));

  const DTFE(this.val);
  @override
  final Field<T> val;
}

class DisplayTicket extends Record {
  int? id;
  Duration? periodInDays;
  DateTime? startDate;
  DateTime? endDate;
  DTContentType contentType;

  DisplayTicket({
    this.id,
    this.periodInDays,
    this.startDate,
    this.endDate,
    required this.contentType,
  });

  factory DisplayTicket.interpret(Map<String, Object?> row) {
    return DisplayTicket(
      id: DTFE.id.interpret(row[DTFE.id.fn]),
      periodInDays: DTFE.lastInDays.interpret(row[DTFE.lastInDays.fn]),
      startDate: DTFE.periodBegin.interpret(row[DTFE.periodBegin.fn]),
      endDate: DTFE.periodEnd.interpret(row[DTFE.periodEnd.fn]),
      contentType: DTFE.contentType.interpret(row[DTFE.contentType.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      DTFE.lastInDays.fn: DTFE.lastInDays.serialize(periodInDays),
      DTFE.periodBegin.fn: DTFE.periodBegin.serialize(startDate),
      DTFE.periodEnd.fn: DTFE.periodEnd.serialize(endDate),
      DTFE.contentType.fn: DTFE.contentType.serialize(contentType),
    };
  }
}

class DisplayTickets extends Table {
  @override
  List<FieldEnum> get fieldEnums => DTFE.values;
  @override
  String get tableName => 'DisplayTickets';
}

enum DtCatLinkerFE<T> implements FieldEnum {
  display(ForeignIdField('displayTicket', 'DisplayTickets', isIndexed: true)),
  category(ForeignIdField('category', 'Categories'));

  const DtCatLinkerFE(this.val);
  @override
  final Field<T> val;
}

class DtCatLinker extends Table {
  @override
  List<FieldEnum> get fieldEnums => DtCatLinkerFE.values;
  @override
  String get tableName => 'DisplayTicketCategoryLinker';
}

// </display ticket>

// <Schedule Ticket>
enum ScheduleFE<T> implements FieldEnum {
  id(IdField()),
  supplement(TextField('supplement')),
  category(ForeignIdField('category', 'Categories')),
  amount(IntField('amount')),
  originDate(DateField('originDate', isIndexed: true)),
  repeatType(EnumField('repeatType', SCRepeatType.values)),
  repeatInterval(DaysField('repeatInterval')),
  repeatOnSunday(BoolField('repeatOnSunday')),
  repeatOnMonday(BoolField('repeatOnMonday')),
  repeatOnTuesday(BoolField('repeatOnTuesday')),
  repeatOnWednesday(BoolField('repeatOnWednesday')),
  repeatOnThursday(BoolField('repeatOnThursday')),
  repeatOnFriday(BoolField('repeatOnFriday')),
  repeatOnSaturday(BoolField('repeatOnSaturday')),
  monthlyRepeatHeadOrigin(DaysField('monthlyRepeatHeadOrigin')),
  monthlyRepeatTailOrigin(DaysField('monthlyRepeatTailOrigin')),
  periodBegin(DateField('periodBegin')),
  periodEnd(DateField('periodEnd'));

  const ScheduleFE(this.val);
  @override
  final Field<T> val;
}

class Schedule extends Record {
  int? id;
  int categoryId;
  String supplement;
  DateTime originDate;
  int amount;
  SCRepeatType repeatType;
  Duration repeatInterval;
  bool repeatOnSunday;
  bool repeatOnMonday;
  bool repeatOnTuesday;
  bool repeatOnWednesday;
  bool repeatOnThursday;
  bool repeatOnFriday;
  bool repeatOnSaturday;
  Duration? monthlyRepeatHeadOriginOffset;
  Duration? monthlyRepeatTailOriginOffset;
  DateTime? startDate;
  DateTime? endDate;

  Schedule({
    this.id,
    required this.categoryId,
    required this.supplement,
    required this.originDate,
    required this.amount,
    required this.repeatType,
    required this.repeatInterval,
    required this.repeatOnSunday,
    required this.repeatOnMonday,
    required this.repeatOnTuesday,
    required this.repeatOnWednesday,
    required this.repeatOnThursday,
    required this.repeatOnFriday,
    required this.repeatOnSaturday,
    this.monthlyRepeatHeadOriginOffset,
    this.monthlyRepeatTailOriginOffset,
    this.startDate,
    this.endDate,
  });

  factory Schedule.interpret(Map<String, Object?> row) {
    return Schedule(
      id: ScheduleFE.id.interpret(row[ScheduleFE.id.fn]),
      categoryId: ScheduleFE.category.interpret(row[ScheduleFE.category.fn]),
      supplement:
          ScheduleFE.supplement.interpret(row[ScheduleFE.supplement.fn]),
      originDate:
          ScheduleFE.originDate.interpret(row[ScheduleFE.originDate.fn]),
      amount: ScheduleFE.amount.interpret(row[ScheduleFE.amount.fn]),
      repeatType:
          ScheduleFE.repeatType.interpret(row[ScheduleFE.repeatType.fn]),
      repeatInterval: ScheduleFE.repeatInterval
          .interpret(row[ScheduleFE.repeatInterval.fn]),
      repeatOnSunday: ScheduleFE.repeatOnSunday
          .interpret(row[ScheduleFE.repeatOnSunday.fn]),
      repeatOnMonday: ScheduleFE.repeatOnMonday
          .interpret(row[ScheduleFE.repeatOnMonday.fn]),
      repeatOnTuesday: ScheduleFE.repeatOnTuesday
          .interpret(row[ScheduleFE.repeatOnTuesday.fn]),
      repeatOnWednesday: ScheduleFE.repeatOnWednesday
          .interpret(row[ScheduleFE.repeatOnWednesday.fn]),
      repeatOnThursday: ScheduleFE.repeatOnThursday
          .interpret(row[ScheduleFE.repeatOnThursday.fn]),
      repeatOnFriday: ScheduleFE.repeatOnFriday
          .interpret(row[ScheduleFE.repeatOnFriday.fn]),
      repeatOnSaturday: ScheduleFE.repeatOnSaturday
          .interpret(row[ScheduleFE.repeatOnSaturday.fn]),
      monthlyRepeatHeadOriginOffset: ScheduleFE.monthlyRepeatHeadOrigin
          .interpret(row[ScheduleFE.monthlyRepeatHeadOrigin.fn]),
      monthlyRepeatTailOriginOffset: ScheduleFE.monthlyRepeatTailOrigin
          .interpret(row[ScheduleFE.monthlyRepeatTailOrigin.fn]),
      startDate:
          ScheduleFE.periodBegin.interpret(row[ScheduleFE.periodBegin.fn]),
      endDate: ScheduleFE.periodEnd.interpret(row[ScheduleFE.periodEnd.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      ScheduleFE.category.fn: ScheduleFE.category.serialize(categoryId),
      ScheduleFE.supplement.fn: ScheduleFE.supplement.serialize(supplement),
      ScheduleFE.originDate.fn: ScheduleFE.originDate.serialize(originDate),
      ScheduleFE.amount.fn: ScheduleFE.amount.serialize(amount),
      ScheduleFE.repeatType.fn: ScheduleFE.repeatType.serialize(repeatType),
      ScheduleFE.repeatInterval.fn:
          ScheduleFE.repeatInterval.serialize(repeatInterval),
      ScheduleFE.repeatOnSunday.fn:
          ScheduleFE.repeatOnSunday.serialize(repeatOnSunday),
      ScheduleFE.repeatOnMonday.fn:
          ScheduleFE.repeatOnMonday.serialize(repeatOnMonday),
      ScheduleFE.repeatOnTuesday.fn:
          ScheduleFE.repeatOnTuesday.serialize(repeatOnTuesday),
      ScheduleFE.repeatOnWednesday.fn:
          ScheduleFE.repeatOnWednesday.serialize(repeatOnWednesday),
      ScheduleFE.repeatOnThursday.fn:
          ScheduleFE.repeatOnThursday.serialize(repeatOnThursday),
      ScheduleFE.repeatOnFriday.fn:
          ScheduleFE.repeatOnFriday.serialize(repeatOnFriday),
      ScheduleFE.repeatOnSaturday.fn:
          ScheduleFE.repeatOnSaturday.serialize(repeatOnSaturday),
      ScheduleFE.monthlyRepeatHeadOrigin.fn: ScheduleFE.monthlyRepeatHeadOrigin
          .serialize(monthlyRepeatHeadOriginOffset),
      ScheduleFE.monthlyRepeatTailOrigin.fn: ScheduleFE.monthlyRepeatTailOrigin
          .serialize(monthlyRepeatTailOriginOffset),
      ScheduleFE.periodBegin.fn: ScheduleFE.periodBegin.serialize(startDate),
      ScheduleFE.periodEnd.fn: ScheduleFE.periodEnd.serialize(endDate),
    };
  }
}

class Schedules extends Table {
  @override
  List<FieldEnum> get fieldEnums => ScheduleFE.values;
  @override
  String get tableName => 'Schedules';
}
// </Schedule Ticket>

// <Estimation Ticket>
enum EstimationFE<T> implements FieldEnum {
  id(IdField()),
  periodBegin(NullableDateField('periodBegin')),
  periodEnd(NullableDateField('periodEnd')),
  contentType(EnumField('contentType', ETContentType.values));

  const EstimationFE(this.val);
  @override
  final Field<T> val;
}

class Estimation extends Record {
  int? id;
  DateTime? periodBegin;
  DateTime? periodEnd;
  ETContentType contentType;

  Estimation({
    this.id,
    this.periodBegin,
    this.periodEnd,
    required this.contentType,
  });

  factory Estimation.interpret(Map<String, Object?> row) {
    return Estimation(
      id: EstimationFE.id.interpret(row[EstimationFE.id.fn]),
      periodBegin:
          EstimationFE.periodBegin.interpret(row[EstimationFE.periodBegin.fn]),
      periodEnd:
          EstimationFE.periodEnd.interpret(row[EstimationFE.periodEnd.fn]),
      contentType:
          EstimationFE.contentType.interpret(row[EstimationFE.contentType.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      EstimationFE.periodBegin.fn:
          EstimationFE.periodBegin.serialize(periodBegin),
      EstimationFE.periodEnd.fn: EstimationFE.periodEnd.serialize(periodEnd),
      EstimationFE.contentType.fn:
          EstimationFE.contentType.serialize(contentType),
    };
  }
}

class Estimations extends Table {
  @override
  List<FieldEnum> get fieldEnums => EstimationFE.values;
  @override
  String get tableName => 'Estimations';
}

enum EtCatLinkerFE implements FieldEnum {
  estimation(ForeignIdField('estimation', 'Estimations', isIndexed: true)),
  category(ForeignIdField('category', 'Categories'));

  const EtCatLinkerFE(this.val);
  @override
  final Field val;
}

class EtCatLinker extends Table {
  @override
  List<FieldEnum> get fieldEnums => EtCatLinkerFE.values;
  @override
  String get tableName => 'EstimationCategoryLinker';
}
// </Estimation Ticket>

// <Log Ticket>
enum LogFE<T> implements FieldEnum {
  id(IdField()),
  category(ForeignIdField('category', 'Categories')),
  supplement(TextField('supplement')),
  amount(IntField('amount')),
  date(DateField('date', isIndexed: true)),
  imagePath(NullableTextField('imagePath')),
  confirmed(BoolField('confirmed'));

  const LogFE(this.val);
  @override
  final Field<T> val;
}

class Log extends Record {
  int? id;
  int categoryId;
  String supplement;
  int amount;
  DateTime date;
  String? imagePath;
  bool confirmed;

  Log({
    this.id,
    required this.categoryId,
    required this.supplement,
    required this.amount,
    required this.date,
    this.imagePath,
    required this.confirmed,
  });

  factory Log.interpret(Map<String, Object?> row) {
    return Log(
      id: LogFE.id.interpret(row[LogFE.id.fn]),
      categoryId: LogFE.category.interpret(row[LogFE.category.fn]),
      supplement: LogFE.supplement.interpret(row[LogFE.supplement.fn]),
      amount: LogFE.amount.interpret(row[LogFE.amount.fn]),
      date: LogFE.date.interpret(row[LogFE.date.fn]),
      imagePath: LogFE.imagePath.interpret(row[LogFE.imagePath.fn]),
      confirmed: LogFE.confirmed.interpret(row[LogFE.confirmed.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      LogFE.category.fn: LogFE.category.serialize(categoryId),
      LogFE.supplement.fn: LogFE.supplement.serialize(supplement),
      LogFE.amount.fn: LogFE.amount.serialize(amount),
      LogFE.date.fn: LogFE.date.serialize(date),
      LogFE.imagePath.fn: LogFE.imagePath.serialize(imagePath),
      LogFE.confirmed.fn: LogFE.confirmed.serialize(confirmed),
    };
  }
}

class Logs extends Table {
  @override
  List<FieldEnum> get fieldEnums => LogFE.values;
  @override
  String get tableName => 'Logs';
}
// </Log Ticket>

// <Predictions>
enum PredictionFE<T> implements FieldEnum {
  id(IdField()),
  date(DateField('date', isIndexed: true)),
  schedule(NullableForeignIdField('schedule', 'Schedules')),
  estimation(NullableForeignIdField('estimation', 'Estimations')),
  category(ForeignIdField('category', 'Categories')),
  amount(RealField('amount'));

  const PredictionFE(this.val);
  @override
  final Field<T> val;
}

class Predictions extends Table {
  @override
  List<FieldEnum> get fieldEnums => PredictionFE.values;
  @override
  String get tableName => 'Predictions';
}
// </Predictions>