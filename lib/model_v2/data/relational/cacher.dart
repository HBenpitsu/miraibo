import 'package:drift/drift.dart';

import 'package:miraibo/model_v2/data/relational/relational.dart';
import 'package:miraibo/model_v2/data/relational/tables.dart';
import 'package:miraibo/util/date_time.dart';

part 'cacher.g.dart';

@DriftAccessor(tables: [EstimationCaches])
class EstimationCacher extends DatabaseAccessor<AppDatabase>
    with _$EstimationCacherMixin {
  EstimationCacher(super.db);

  Future<void> cache(Map<int, double> cache) async {
    await batch((batch) {
      for (var key in cache.keys) {
        batch.insert(
          estimationCaches,
          EstimationCachesCompanion(
            category: Value(key),
            amount: Value(cache[key]!),
          ),
          mode: InsertMode.replace,
        );
      }
    });
  }
}

@DriftAccessor(tables: [RepeatCaches, Schedules, Estimations, Logs])
class RepeatCacher extends DatabaseAccessor<AppDatabase>
    with _$RepeatCacherMixin {
  RepeatCacher(super.db);

  Future<void> clearSchedule(int schedule) async {
    await (delete(repeatCaches)..where((row) => row.schedule.equals(schedule)))
        .go();
  }

  Future<void> clearEstimation(int estimation) async {
    await (delete(repeatCaches)
          ..where((row) => row.estimation.equals(estimation)))
        .go();
  }

  Future<void> cacheSchedule(int schedule, Iterable<DateTime> dates) async {
    await batch((batch) {
      batch.insertAll(repeatCaches, dates.map((date) {
        return RepeatCachesCompanion(
          schedule: Value(schedule),
          registeredAt: Value(date),
        );
      }));
    });
  }

  Future<void> cacheEstimation(int estimation, Iterable<DateTime> dates) async {
    await batch((batch) {
      batch.insertAll(repeatCaches, dates.map((date) {
        return RepeatCachesCompanion(
          estimation: Value(estimation),
          registeredAt: Value(date),
        );
      }));
    });
  }

  Future<void> cleanUp() async {
    await (delete(repeatCaches)
          ..where((row) => row.registeredAt.isSmallerOrEqualValue(today())))
        .go();
  }

  Future<void> transferSchedulesToLogs() async {
    await batch((batch) async {
      var query = select(repeatCaches).join([
        innerJoin(schedules, schedules.id.equalsExp(repeatCaches.schedule))
      ]);
      query.where(repeatCaches.registeredAt.isSmallerOrEqualValue(today()));
      await for (var rows in query.watch()) {
        for (var row in rows) {
          var repeatCache = row.readTable(repeatCaches);
          var schedule = row.readTable(schedules);
          batch.insert(
            logs,
            LogsCompanion(
              category: Value(schedule.category),
              supplement: Value(schedule.supplement),
              registeredAt: Value(repeatCache.registeredAt),
              amount: Value(schedule.amount),
              imageUrl: Value(null),
              confirmed: Value(false),
            ),
          );
        }
      }
    });
  }
}
