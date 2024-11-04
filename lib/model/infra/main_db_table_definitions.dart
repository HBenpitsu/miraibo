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
