import 'package:drift/drift.dart';

import 'package:miraibo/model_v2/data/relational/relational.dart';
import 'package:miraibo/model_v2/data/relational/tables.dart';
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

  Stream<Category> all() async* {
    await for (var rows in select(categories).watch()) {
      for (var row in rows) {
        yield row;
      }
    }
  }

  Future<int> saveCategory(CategoriesCompanion entry) async {
    return into(categories).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> integrateCategories(int replaceWithId, int replacedId) async {
    // make process concurrent
    await transaction(() async {
      await Future.wait([
        // replaceCategories
        (update(logs)..where((tbl) => tbl.category.equals(replacedId)))
            .write(LogsCompanion(category: Value(replaceWithId))),
        (update(displayCategoryLinks)
              ..where((tbl) => tbl.category.equals(replacedId)))
            .write(
                DisplayCategoryLinksCompanion(category: Value(replaceWithId))),
        (update(schedules)..where((tbl) => tbl.category.equals(replacedId)))
            .write(SchedulesCompanion(category: Value(replaceWithId))),
        (update(estimationCategoryLinks)
              ..where((tbl) => tbl.category.equals(replacedId)))
            .write(EstimationCategoryLinksCompanion(
                category: Value(replaceWithId))),
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
    });
  }

  Future<void> bulkInsert(Iterable<String> categoryNames) async {
    return batch((b) => b.insertAll(categories,
        categoryNames.map((name) => CategoriesCompanion.insert(name: name))));
  }
}

@DriftAccessor(tables: [Categories, EstimationCategoryLinks, EstimationCaches])
class EstimationAccessor extends DatabaseAccessor<AppDatabase>
    with _$EstimationAccessorMixin {
  EstimationAccessor(super.db);

  Future<int> saveEstimation(
      EstimationsCompanion entry, Iterable<int> categoryIds) async {
    return transaction(() async {
      var ret = await Future.wait([
        (() async {
          // delete all links
          await (delete(estimationCategoryLinks)
                ..where((tbl) => tbl.estimation.equals(entry.id.value)))
              .go();
          // insert links
          await batch((b) => b.insertAll(
              estimationCategoryLinks,
              categoryIds.map((catId) => EstimationCategoryLinksCompanion(
                  estimation: entry.id, category: Value(catId)))));
        })(),
        // insert estimation
        into(estimations).insert(entry, mode: InsertMode.insertOrReplace),
      ]);
      return ret[1]!;
    });
  }

  Future<void> deleteEstimation(int id) async {
    await transaction(() async {
      await Future.wait([
        (delete(estimations)..where((tbl) => tbl.id.equals(id))).go(),
        (delete(estimationCategoryLinks)
              ..where((tbl) => tbl.estimation.equals(id)))
            .go(),
      ]);
    });
  }

  /// returns the basic select statement that bundles all necessary tables
  JoinedSelectStatement<HasResultSet, dynamic> _bundled() {
    return select(estimations).join([
      leftOuterJoin(estimationCategoryLinks,
          estimationCategoryLinks.estimation.equalsExp(estimations.id)),
      leftOuterJoin(
          categories, estimationCategoryLinks.category.equalsExp(categories.id))
    ]);
  }

  Stream<(Estimation, List<Category>)> _executeQuery(
      JoinedSelectStatement<HasResultSet, dynamic> query) async* {
    // group by estimation
    Map<Estimation, List<Category>> buf = {};
    for (var row in await query.get()) {
      var est = row.readTable(estimations);
      buf[est] ??= [];
      var cat = row.readTableOrNull(categories);
      if (cat != null) {
        buf[est]!.add(cat);
      }
    }
    // yield them as tuple stream
    for (var key in buf.keys) {
      yield (key, buf[key]!);
    }
  }

  Stream<(Estimation, List<Category>)> on(DateTime date) {
    var query = _bundled();
    // where date is in period
    query.where((estimations.periodBegin.isNull() |
            estimations.periodBegin.isSmallerOrEqualValue(date)) &
        (estimations.periodEnd.isNull() |
            estimations.periodEnd.isBiggerOrEqualValue(date)));
    return _executeQuery(query);
  }

  Stream<Estimation> all() async* {
    await for (var rows in select(estimations).watch()) {
      for (var row in rows) {
        yield row;
      }
    }
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

  Future<void> deleteSchedule(int id) async {
    await (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();
    // cache will be updated by cacheManager
  }

  /// returns the basic select statement that bundles all necessary tables
  JoinedSelectStatement<HasResultSet, dynamic> _bundled() {
    // fetch schedules and categories based on repeat caches
    return select(repeatCaches).join([
      innerJoin(schedules, repeatCaches.schedule.equalsExp(schedules.id)),
      innerJoin(categories, schedules.category.equalsExp(categories.id)),
    ]);
  }

  Stream<(Schedule, Category)> _executeQuery(
      JoinedSelectStatement<HasResultSet, dynamic> query) async* {
    await for (var rows in query.watch()) {
      for (var row in rows) {
        yield (row.readTable(schedules), row.readTable(categories));
      }
    }
  }

  Stream<(Schedule, Category)> on(DateTime date) {
    var query = _bundled();
    // where date matches
    query.where(repeatCaches.registeredAt.equals(date));
    return _executeQuery(query);
  }

  Stream<(Schedule, Category)> untilToday() {
    var query = _bundled();
    // past/todays schedules
    query.where(repeatCaches.registeredAt.isSmallerOrEqualValue(today()));
    return _executeQuery(query);
  }

  Stream<Schedule> all() async* {
    await for (var rows in select(schedules).watch()) {
      for (var row in rows) {
        yield row;
      }
    }
  }
}

@DriftAccessor(tables: [Displays, DisplayCategoryLinks, Categories])
class DisplayAccessor extends DatabaseAccessor<AppDatabase>
    with _$DisplayAccessorMixin {
  DisplayAccessor(super.db);

  Future<int> saveDisplay(
      DisplaysCompanion entry, Iterable<int> categoryIds) async {
    return transaction(() async {
      var ret = await Future.wait([
        (() async {
          // delete all links
          await (delete(displayCategoryLinks)
                ..where((tbl) => tbl.display.equals(entry.id.value)))
              .go();
          // insert links
          await batch((b) => b.insertAll(
              displayCategoryLinks,
              categoryIds.map((catId) => DisplayCategoryLinksCompanion(
                  display: entry.id, category: Value(catId)))));
        })(),
        // insert estimation
        into(displays).insert(entry, mode: InsertMode.insertOrReplace),
      ]);
      return ret[1]!;
    });
  }

  Future<void> deleteDisplay(int id) async {
    await transaction(() async {
      await (delete(displays)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(displayCategoryLinks)
            ..where((tbl) => tbl.display.equals(id)))
          .go();
    });
  }

  /// returns the basic select statement that bundles all necessary tables
  JoinedSelectStatement<HasResultSet, dynamic> _bundled() {
    return select(displays).join([
      leftOuterJoin(displayCategoryLinks,
          displayCategoryLinks.display.equalsExp(displays.id)),
      leftOuterJoin(
          categories, displayCategoryLinks.category.equalsExp(categories.id))
    ]);
  }

  Stream<(Display, List<Category>)> _executeQuery(
      JoinedSelectStatement<HasResultSet, dynamic> query) async* {
    // group by display
    Map<Display, List<Category>> buf = {};
    for (var row in await query.get()) {
      var display = row.readTable(displays);
      buf[display] ??= [];
      var cat = row.readTableOrNull(categories);
      if (cat != null) {
        buf[display]!.add(cat);
      }
    }
    // yield them as tuple stream
    for (var key in buf.keys) {
      yield (key, buf[key]!);
    }
  }

  Stream<(Display, List<Category>)> on(DateTime date) {
    var query = _bundled();
    // where date is in period
    query.where((displays.periodBegin.isNull() |
            displays.periodBegin.isSmallerOrEqualValue(date)) &
        (displays.periodEnd.isNull() |
            displays.periodEnd.isBiggerOrEqualValue(date)));
    return _executeQuery(query);
  }

  Stream<(Display, List<Category>)> edgeOn(DateTime date) {
    var query = _bundled();
    // where the date is on the edge of the period
    query.where(
        displays.periodBegin.equals(date) | displays.periodEnd.equals(date));
    return _executeQuery(query);
  }
}

@DriftAccessor(tables: [Logs, Categories])
class LogAccessor extends DatabaseAccessor<AppDatabase>
    with _$LogAccessorMixin {
  LogAccessor(super.db);

  Future<int> saveLog(LogsCompanion entry) async {
    return into(logs).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> confirmUntil(DateTime date) async {
    await (update(logs)
          ..where((tbl) => tbl.registeredAt.isSmallerOrEqualValue(date)))
        .write(LogsCompanion(confirmed: Value(true)));
  }

  Future<void> deleteLog(int id) async {
    await (delete(logs)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// returns the basic select statement that bundles all necessary tables
  JoinedSelectStatement<HasResultSet, dynamic> _bundled() {
    return select(logs).join([
      innerJoin(categories, logs.category.equalsExp(categories.id)),
    ]);
  }

  Stream<(Log, Category)> _executeQuery(
      JoinedSelectStatement<HasResultSet, dynamic> query) async* {
    await for (var rows in query.watch()) {
      for (var row in rows) {
        yield (row.readTable(logs), row.readTable(categories));
      }
    }
  }

  Stream<(Log, Category)> all() {
    var query = _bundled();
    query.orderBy(
        [OrderingTerm(expression: logs.registeredAt, mode: OrderingMode.desc)]);

    return _executeQuery(query);
  }

  Stream<(Log, Category)> on(DateTime date) {
    var query = _bundled();
    query.where(logs.registeredAt.equals(date));

    return _executeQuery(query);
  }

  Stream<(Log, Category)> unconfirmed() {
    var query = _bundled();
    query.where(logs.confirmed.equals(false));

    return _executeQuery(query);
  }

  Stream<(Log, Category)> latest(int limit) {
    var query = _bundled();
    query.orderBy(
        [OrderingTerm(expression: logs.updatedAt, mode: OrderingMode.desc)]);
    query.limit(limit);

    return _executeQuery(query);
  }
}
