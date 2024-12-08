import 'package:drift/drift.dart';

import 'package:miraibo/modelV2/data/database.dart';
import 'package:miraibo/modelV2/data/tables.dart';
import 'package:miraibo/util/date_time.dart';

part 'basic_accessors.g.dart';

@DriftAccessor(tables: [
  Categories,
  Logs,
  DisplayCategoryLinks,
  Schedules,
  EstimationCategoryLinks,
  EstimationCaches
])
class CategoryAccessor extends DatabaseAccessor<AppDatabase>
    with _$CategoryAccessorMixin {
  CategoryAccessor(super.db);

  Stream<List<Category>> all() => select(categories).watch();

  Future<int> saveCategory(CategoriesCompanion entry) async {
    return into(categories).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future integrateCategories(int replaceWithId, int replacedId) async {
    await Future.wait([
      // replaceCategories
      (update(logs)..where((tbl) => tbl.categoryId.equals(replacedId)))
          .write(LogsCompanion(categoryId: Value(replaceWithId))),
      (update(displayCategoryLinks)
            ..where((tbl) => tbl.category.equals(replacedId)))
          .write(DisplayCategoryLinksCompanion(category: Value(replaceWithId))),
      (update(schedules)..where((tbl) => tbl.category.equals(replacedId)))
          .write(SchedulesCompanion(category: Value(replaceWithId))),
      (update(estimationCategoryLinks)
            ..where((tbl) => tbl.category.equals(replacedId)))
          .write(
              EstimationCategoryLinksCompanion(category: Value(replaceWithId))),
      // sum amounts of two estimations
      (() async {
        final [replacedRec, replaceRec] = await Future.wait([
          (select(estimationCaches)
                ..where((tbl) => tbl.category.equals(replacedId)))
              .getSingle(),
          (select(estimationCaches)
                ..where((tbl) => tbl.category.equals(replaceWithId)))
              .getSingle()
        ]);
        final amount = replaceRec.amount + replacedRec.amount;
        await Future.wait([
          (update(estimationCaches)
                ..where((tbl) => tbl.category.equals(replaceWithId)))
              .write(EstimationCachesCompanion(amount: Value(amount))),
          (delete(estimationCaches)
                ..where((tbl) => tbl.category.equals(replacedId)))
              .go()
        ]);
      })(),
      // deleteCategory
      (delete(categories)..where((tbl) => tbl.id.equals(replacedId))).go()
    ]);
  }
}

@DriftAccessor(tables: [Categories, EstimationCategoryLinks, EstimationCaches])
class EstimationAccessor extends DatabaseAccessor<AppDatabase>
    with _$EstimationAccessorMixin {
  EstimationAccessor(super.db);

  Future<int> saveEstimation(
      EstimationsCompanion entry, List<Category> categories) async {
    var ret = await Future.wait([
      (() async {
        // delete all links
        await (delete(estimationCategoryLinks)
              ..where((tbl) => tbl.estimation.equals(entry.id.value)))
            .go();
        // insert links
        await batch((b) => b.insertAll(
            estimationCategoryLinks,
            categories.map((cat) => EstimationCategoryLinksCompanion(
                estimation: entry.id, category: Value(cat.id)))));
      })(),
      // insert estimation
      into(estimations).insert(entry, mode: InsertMode.insertOrReplace),
    ]);
    return ret[1]!;
    // cache will be updated by cacheManager
  }

  Future deleteEstimation(int id) async {
    await Future.wait([
      (delete(estimations)..where((tbl) => tbl.id.equals(id))).go(),
      (delete(estimationCategoryLinks)
            ..where((tbl) => tbl.estimation.equals(id)))
          .go(),
    ]);
    // cache will be updated by cacheManager
  }

  Future<Map<Estimation, List<Category>>> on(DateTime date) async {
    // From Estimations and Categories
    var query = select(estimationCategoryLinks).join([
      innerJoin(categories,
          estimationCategoryLinks.category.equalsExp(categories.id)),
      innerJoin(estimations,
          estimationCategoryLinks.estimation.equalsExp(estimations.id)),
    ]);
    // where date is in period
    query.where((estimations.periodBegin.isNull() |
            estimations.periodBegin.isSmallerOrEqualValue(date)) &
        (estimations.periodEnd.isNull() |
            estimations.periodEnd.isBiggerOrEqualValue(date)));
    // group by estimation
    Map<Estimation, List<Category>> buf = {};
    for (var row in await query.get()) {
      var est = row.readTable(estimations);
      buf[est] ??= [];
      buf[est]!.add(row.readTable(categories));
    }
    return buf;
  }
}

@DriftAccessor(tables: [Schedules, Categories, RepeatCaches])
class ScheduleAccessor extends DatabaseAccessor<AppDatabase>
    with _$ScheduleAccessorMixin {
  ScheduleAccessor(super.db);

  Future<int> saveSchedule(SchedulesCompanion entry) async {
    return into(schedules).insert(entry, mode: InsertMode.insertOrReplace);
    // cache will be updated by cacheManager
  }

  Future deleteSchedule(int id) async {
    await (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();
    // cache will be updated by cacheManager
  }

  Future<Map<Schedule, Category>> on(DateTime date) async {
    // fetch schedules and categories based on repeat caches
    var query = select(repeatCaches).join([
      innerJoin(schedules, repeatCaches.schedule.equalsExp(schedules.id)),
      innerJoin(categories, schedules.category.equalsExp(categories.id)),
    ]);
    // repeatCaches should be on the date
    query.where(repeatCaches.registeredAt.equals(date));
    // format
    Map<Schedule, Category> buf = {};
    for (var row in await query.get()) {
      buf[row.readTable(schedules)] = row.readTable(categories);
    }
    return buf;
  }

  Future<Map<Schedule, Category>> untilToday() async {
    // fetch schedules and categories based on repeat caches
    var query = select(repeatCaches).join([
      innerJoin(schedules, repeatCaches.schedule.equalsExp(schedules.id)),
      innerJoin(categories, schedules.category.equalsExp(categories.id)),
    ]);
    // repeatCaches should be today or before
    query.where(repeatCaches.registeredAt.isSmallerOrEqualValue(today()));
    // format
    Map<Schedule, Category> buf = {};
    for (var row in await query.get()) {
      buf[row.readTable(schedules)] = row.readTable(categories);
    }
    return buf;
  }
}

@DriftAccessor(tables: [Displays, DisplayCategoryLinks, Categories])
class DisplayAccessor extends DatabaseAccessor<AppDatabase>
    with _$DisplayAccessorMixin {
  DisplayAccessor(super.db);

  Future<int> saveDisplay(
      DisplaysCompanion entry, List<Category> categories) async {
    var ret = await Future.wait([
      (() async {
        // delete all links
        await (delete(displayCategoryLinks)
              ..where((tbl) => tbl.display.equals(entry.id.value)))
            .go();
        // insert links
        await batch((b) => b.insertAll(
            displayCategoryLinks,
            categories.map((cat) => DisplayCategoryLinksCompanion(
                display: entry.id, category: Value(cat.id)))));
      })(),
      // insert estimation
      into(displays).insert(entry, mode: InsertMode.insertOrReplace),
    ]);
    return ret[1]!;
  }

  Future<void> deleteDisplay(int id) async {
    await (delete(displays)..where((tbl) => tbl.id.equals(id))).go();
    await (delete(displayCategoryLinks)..where((tbl) => tbl.display.equals(id)))
        .go();
  }

  Future<Map<Display, List<Category>>> on(DateTime date) async {
    // From Displays and Categories
    var query = select(displayCategoryLinks).join([
      innerJoin(displays, displayCategoryLinks.display.equalsExp(displays.id)),
      innerJoin(
          categories, displayCategoryLinks.category.equalsExp(categories.id)),
    ]);
    // where date is in period
    query.where((displays.periodBegin.isNull() |
            displays.periodBegin.isSmallerOrEqualValue(date)) &
        (displays.periodEnd.isNull() |
            displays.periodEnd.isBiggerOrEqualValue(date)));
    // group by display
    Map<Display, List<Category>> buf = {};
    for (var row in await query.get()) {
      var display = row.readTable(displays);
      buf[display] ??= [];
      buf[display]!.add(row.readTable(categories));
    }
    return buf;
  }

  Future<Map<Display, List<Category>>> edgeOn(DateTime date) async {
    // From Displays and Categories
    var query = select(displayCategoryLinks).join([
      innerJoin(displays, displayCategoryLinks.display.equalsExp(displays.id)),
      innerJoin(
          categories, displayCategoryLinks.category.equalsExp(categories.id)),
    ]);
    // where the date is on the edge of the period
    query.where(
        displays.periodBegin.equals(date) | displays.periodEnd.equals(date));
    // format
    Map<Display, List<Category>> buf = {};
    for (var row in await query.get()) {
      var display = row.readTable(displays);
      buf[display] ??= [];
      buf[display]!.add(row.readTable(categories));
    }
    return buf;
  }
}

@DriftAccessor(tables: [Logs, Categories])
class LogAccessor extends DatabaseAccessor<AppDatabase>
    with _$LogAccessorMixin {
  LogAccessor(super.db);

  Future<int> saveLog(LogsCompanion entry) async {
    return into(logs).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteLog(int id) async {
    await (delete(logs)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<Map<Log, Category>> all() async* {
    // FROM Logs
    var query = select(logs).join([
      // JOIN Categories
      innerJoin(categories, logs.categoryId.equalsExp(categories.id)),
    ]);
    for (var row in await query.get()) {
      yield {row.readTable(logs): row.readTable(categories)};
    }
  }

  Future<Map<Log, Category>> on(DateTime date) async {
    // FROM Logs
    var query = select(logs).join([
      // JOIN Categories
      innerJoin(categories, logs.categoryId.equalsExp(categories.id)),
    ]);
    query.where(logs.registeredAt.equals(date));
    Map<Log, Category> buf = {};
    for (var row in await query.get()) {
      buf[row.readTable(logs)] = row.readTable(categories);
    }
    return buf;
  }
}
