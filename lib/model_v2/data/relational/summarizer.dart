import 'package:drift/drift.dart';

import 'package:miraibo/model_v2/data/relational/relational.dart';
import 'package:miraibo/model_v2/data/relational/tables.dart';

part 'summarizer.g.dart';

@DriftAccessor(tables: [EstimationCaches])
class EstimationContent extends DatabaseAccessor<AppDatabase>
    with _$EstimationContentMixin {
  EstimationContent(super.db);

  /// pass [] to sum up all categories
  Future<double> getSumOfCachedValues(Iterable<int> categories) async {
    var summedAmount = estimationCaches.amount.sum();
    var query = select(estimationCaches).addColumns([summedAmount]);
    if (categories.isNotEmpty) {
      query.where(estimationCaches.category.isIn(categories));
    }
    var ret = await query.getSingle();
    return ret.read(summedAmount)!;
  }
}

@DriftAccessor(tables: [
  Logs,
  Estimations,
  EstimationCategoryLinks,
  Schedules,
  EstimationCaches,
  RepeatCaches
])
class RecordCollector extends DatabaseAccessor<AppDatabase>
    with _$RecordCollectorMixin {
  RecordCollector(super.db);

  /// Collects the records of the specified categories within the specified period.
  /// The period is specified by the [periodBegin] and [periodEnd] parameters.
  /// The [categoryIds] parameter specifies the categories to collect.
  /// Pass null to intentionally leave the parameter unspecified.
  Stream<(DateTime, double)> collect(DateTime? periodBegin, DateTime? periodEnd,
      Iterable<int>? categoryIds) async* {
    // this method does not change the contents of the database, so it is not necessary to use a transaction.
    var logRecordsQuery = select(logs);
    var repeatCacheRecordsQuery = select(repeatCaches).join([
      leftOuterJoin(schedules, repeatCaches.schedule.equalsExp(schedules.id)),
      leftOuterJoin(
          estimations, repeatCaches.estimation.equalsExp(estimations.id)),
      leftOuterJoin(estimationCategoryLinks,
          estimations.id.equalsExp(estimationCategoryLinks.estimation)),
      leftOuterJoin(estimationCaches,
          estimationCategoryLinks.category.equalsExp(estimationCaches.category))
    ]);
    if (categoryIds != null) {
      logRecordsQuery.where((row) => row.category.isIn(categoryIds));
      repeatCacheRecordsQuery.where(schedules.category.isIn(categoryIds) |
          estimationCategoryLinks.category.isIn(categoryIds));
    }

    if (periodBegin != null) {
      logRecordsQuery
          .where((row) => row.registeredAt.isBiggerOrEqualValue(periodBegin));
      repeatCacheRecordsQuery
          .where(repeatCaches.registeredAt.isBiggerOrEqualValue(periodBegin));
    }
    if (periodEnd != null) {
      logRecordsQuery
          .where((row) => row.registeredAt.isSmallerOrEqualValue(periodEnd));
      repeatCacheRecordsQuery
          .where(repeatCaches.registeredAt.isSmallerOrEqualValue(periodEnd));
    }

    await for (var rows in logRecordsQuery.watch()) {
      for (var row in rows) {
        yield (row.registeredAt, row.amount.toDouble());
      }
    }
    await for (var rows in repeatCacheRecordsQuery.watch()) {
      for (var row in rows) {
        var repeatCache = row.readTable(repeatCaches);
        var schedule = row.readTableOrNull(schedules);
        var estimation = row.readTableOrNull(estimationCaches);

        if (schedule == null && estimation != null) {
          yield (repeatCache.registeredAt, estimation.amount);
        } else if (schedule != null && estimation == null) {
          yield (repeatCache.registeredAt, schedule.amount.toDouble());
        } else {
          throw Exception('Invalid record exists in repeatCaches table.');
        }
      }
    }
  }
}
