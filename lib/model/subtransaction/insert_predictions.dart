import 'dart:async';

import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/model/infra/table_components.dart';
import 'package:miraibo/type/model_obj.dart';
import 'package:miraibo/model/subtransaction/estimations.dart';
import 'package:miraibo/model/subtransaction/estimation_category_linker.dart';
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:sqflite/sqflite.dart';

// <shered traits>
mixin RangeValidation<T> on SubTransactionProvider<T> {
  abstract DateTime rangeBegin;
  abstract DateTime rangeEnd;
  bool rangeIsValid(DateTime? periodBegin, DateTime? periodEnd) {
    if (periodBegin != null && periodBegin.isBefore(rangeEnd)) {
      return false; // out of range
    }
    if (periodEnd != null && periodEnd.isAfter(rangeBegin)) {
      return false; // out of range
    }
    if (rangeBegin.isAfter(rangeEnd)) {
      return false; // invalid range
    }
    if (periodBegin != null &&
        periodEnd != null &&
        periodBegin.isAfter(periodEnd)) {
      return false; // invalid period
    }
    return true;
  }

  void ajustRenge(DateTime? periodBegin, DateTime? periodEnd) {
    if (periodBegin != null && periodBegin.isAfter(rangeBegin)) {
      rangeBegin = periodBegin;
    }
    if (periodEnd != null && periodEnd.isBefore(rangeEnd)) {
      rangeEnd = periodEnd;
    }
  }
}

mixin InsertPredictionRecordSQL<T, V> on SubTransactionProvider<T> {
  String base() => '''
      INSERT INTO ${Predictions().tableName}
        (
          ${PredictionFE.schedule.fn}, 
          ${PredictionFE.estimation.fn}, 
          ${PredictionFE.category.fn}, 
          ${PredictionFE.date.fn},
          ${PredictionFE.amount.fn}
        )
      VALUES
    ''';

  String makeSql(List<String> vals) {
    return '${base()} ${vals.join(', ')};';
  }
}
// </shered traits>

// <individual traits>
class InsertScheduledPredictions extends SubTransactionProvider<void>
    with RangeValidation, InsertPredictionRecordSQL {
  // note that the range is inclusive on both ends.
  @override
  DateTime rangeBegin;
  @override
  DateTime rangeEnd;
  final Schedule schedule;
  InsertScheduledPredictions(this.schedule, this.rangeBegin, this.rangeEnd);

  @override
  process(Transaction txn) async {
    if (!rangeIsValid(schedule.periodBegin, schedule.periodEnd)) return;
    ajustRenge(schedule.periodBegin, schedule.periodEnd);
    var vals = values();
    if (vals.isEmpty) return;
    await txn.rawInsert(makeSql(vals));
  }

  List<String> values() {
    var values = <String>[];
    for (var timestamp in timestamps()) {
      values.add('''
        (
          ${schedule.id!}, 
          ${null}, 
          ${schedule.categoryId}, 
          ${PredictionFE.date.serialize(timestamp)}, 
          ${schedule.amount}
        )''');
    }
    return values;
  }

  Iterable<DateTime> timestamps() sync* {
    switch (schedule.repeatType) {
      case ScheduleRepeatType.no:
        yield schedule.originDate;
        break;
      case ScheduleRepeatType.interval:
        yield* DateTimeSequence.withInterval(
            rangeBegin, rangeEnd, schedule.originDate, schedule.repeatInterval);
        break;
      case ScheduleRepeatType.weekly:
        var weekdays = <Weekday>[];
        if (schedule.repeatOnSunday) weekdays.add(Weekday.sunday);
        if (schedule.repeatOnMonday) weekdays.add(Weekday.tuesday);
        if (schedule.repeatOnTuesday) weekdays.add(Weekday.tuesday);
        if (schedule.repeatOnWednesday) weekdays.add(Weekday.wednesday);
        if (schedule.repeatOnThursday) weekdays.add(Weekday.thursday);
        if (schedule.repeatOnFriday) weekdays.add(Weekday.friday);
        if (schedule.repeatOnSaturday) weekdays.add(Weekday.saturday);
        yield* DateTimeSequence.weekly(rangeBegin, rangeEnd, weekdays);
        break;
      case ScheduleRepeatType.monthly:
        if (schedule.monthlyRepeatHeadOriginOffset != null) {
          yield* DateTimeSequence.monthlyHeadOrigin(
              rangeBegin, rangeEnd, schedule.monthlyRepeatHeadOriginOffset!);
        } else if (schedule.monthlyRepeatTailOriginOffset != null) {
          yield* DateTimeSequence.monthlyTailOrigin(
              rangeBegin, rangeEnd, schedule.monthlyRepeatTailOriginOffset!);
        } else {
          assert(false); // unreachable
        }
        break;
      case ScheduleRepeatType.anually:
        yield* DateTimeSequence.anually(
            rangeBegin, rangeEnd, schedule.originDate);
        break;
    }
  }
}

class InsertEstimatedPredictions extends SubTransactionProvider<void>
    with RangeValidation, InsertPredictionRecordSQL {
  // note that the range is inclusive on both ends.
  @override
  DateTime rangeBegin;
  @override
  DateTime rangeEnd;
  final Estimation estimation;
  InsertEstimatedPredictions(this.estimation, this.rangeBegin, this.rangeEnd);
  late FetchLinkedCategoryIdsForEstimation linkedCategoryIds;
  // late EstimateAmountFor estimateFor;

  @override
  process(Transaction txn) async {
    prepare();
    if (!rangeIsValid(estimation.periodBegin, estimation.periodEnd)) return;
    ajustRenge(estimation.periodBegin, estimation.periodEnd);
    var vals = await values(txn);
    if (vals.isEmpty) return;
    await txn.rawInsert(makeSql(vals));
  }

  void prepare() {
    assert(estimation.id != null);
    linkedCategoryIds = FetchLinkedCategoryIdsForEstimation(estimation.id!);
  }

  Future<List<String>> values(txn) async {
    var categoryIds = await linkedCategoryIds.execute(txn);
    var values = <String>[];
    var futureBuffer = <Future<void>>[];
    for (var category in categoryIds) {
      futureBuffer.add((() async {
        var amount = await EstimateAmountFor(category).execute(txn);

        for (var timestamp in DateTimeSequence.daily(rangeBegin, rangeEnd)) {
          values.add('''
        (
          ${null}, 
          ${estimation.id!}, 
          $category, 
          ${PredictionFE.date.serialize(timestamp)}, 
          $amount
        )''');
        }
      })());
    }
    await Future.wait(futureBuffer);
    return values;
  }
}
// </individual traits>
