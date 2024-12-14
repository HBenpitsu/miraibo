import 'package:drift/drift.dart';
import 'package:miraibo/type/enumarations.dart';

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'date', columns: {#registeredAt})
class Logs extends Table {
  IntColumn get id => integer()();
  IntColumn get category => integer().references(Categories, #id)();
  TextColumn get supplement => text()();
  DateTimeColumn get registeredAt => dateTime()();
  IntColumn get amount => integer()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get confirmed => boolean()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'period', columns: {#periodBegin, #periodEnd})
class Displays extends Table {
  IntColumn get id => integer()();
  IntColumn get periodInDays => integer().nullable()();
  DateTimeColumn get periodBegin => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  IntColumn get contentType => intEnum<DisplayContentType>()();
  @override
  Set<Column> get primaryKey => {id};
}

class DisplayCategoryLinks extends Table {
  IntColumn get display => integer().references(Displays, #id)();
  IntColumn get category => integer().references(Categories, #id)();
  @override
  Set<Column> get primaryKey => {display, category};
}

@TableIndex(name: 'date', columns: {#origin})
class Schedules extends Table {
  IntColumn get id => integer()();
  IntColumn get category => integer().references(Categories, #id)();
  TextColumn get supplement => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get origin => dateTime()();
  IntColumn get repeatType => intEnum<ScheduleRepeatType>()();
  IntColumn get interval => integer().nullable()();
  BoolColumn get onSunday => boolean()();
  BoolColumn get onMonday => boolean()();
  BoolColumn get onTuesday => boolean()();
  BoolColumn get onWednesday => boolean()();
  BoolColumn get onThursday => boolean()();
  BoolColumn get onFriday => boolean()();
  BoolColumn get onSaturday => boolean()();
  IntColumn get monthlyHeadOrigin => integer().nullable()();
  IntColumn get monthlyTailOrigin => integer().nullable()();
  DateTimeColumn get periodBegin => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'period', columns: {#periodBegin, #periodEnd})
class Estimations extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get periodBegin => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  IntColumn get contentType => intEnum<EstimationContentType>()();
  @override
  Set<Column> get primaryKey => {id};
}

class EstimationCategoryLinks extends Table {
  IntColumn get estimation => integer().references(Estimations, #id)();
  IntColumn get category => integer().references(Categories, #id)();
  @override
  Set<Column> get primaryKey => {estimation, category};
}

class EstimationCaches extends Table {
  IntColumn get category => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  @override
  Set<Column> get primaryKey => {category};
}

@TableIndex(name: 'date', columns: {#registeredAt})
class RepeatCaches extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get registeredAt => dateTime()();
  IntColumn get schedule => integer().nullable().references(Schedules, #id)();
  IntColumn get estimation =>
      integer().nullable().references(Estimations, #id)();
  @override
  Set<Column> get primaryKey => {id};
}
