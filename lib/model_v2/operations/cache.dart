import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/model_v2/data/data.dart';
import 'package:miraibo/model_v2/operations/summarize.dart';
import 'package:miraibo/util/date_time.dart';

class CachingOperations {
  /// pass null to refresh all categories
  Future<void> refreshEstimationCache(Iterable<int>? categories) async {
    await rdb.transaction(() async {
      Map<int, double> buf = {};
      if (categories == null) {
        var categories = rdb.categoryAccessor.all();
        await for (var cat in categories) {
          buf[cat.id] = await summ.estimateFor(cat.id);
        }
      } else {
        for (var cat in categories) {
          buf[cat] = await summ.estimateFor(cat);
        }
      }
      await rdb.estimationCacher.cache(buf);
    });
  }

  Future<void> clearRepeatCacheForEstimation(int id) async {
    await rdb.repeatCacher.clearEstimation(id);
  }

  Future<void> clearRepeatCacheForSchedule(int id) async {
    await rdb.repeatCacher.clearSchedule(id);
  }

  Future<void> _setRepeatCacheForEstimation(
    int estimationId,
    DateTime? estimationPeriodBegin,
    DateTime? estimationPeriodEnd,
    DateTime rangeBegin,
    DateTime rangeEnd,
  ) async {
    // cut off out-of-range period
    var periodBegin = estimationPeriodBegin ?? rangeBegin;
    if (periodBegin.isBefore(rangeBegin)) {
      periodBegin = rangeBegin;
    }
    var periodEnd = estimationPeriodEnd ?? rangeEnd;
    if (periodEnd.isAfter(rangeEnd)) {
      periodEnd = rangeEnd;
    }
    await rdb.repeatCacher.cacheEstimation(
        estimationId, DateTimeSequence.daily(periodBegin, periodEnd));
  }

  Future<void> setRepeatCacheForEstimation(
      view_obj.Estimation estimation) async {
    await rdb.transaction(() async {
      await clearRepeatCacheForEstimation(estimation.id!);
      await _setRepeatCacheForEstimation(
          estimation.id!,
          estimation.periodBeign,
          estimation.periodEnd,
          tomorrow(),
          await ndb.cachingStatus.cachedUntil);
    });
  }

  Future<void> _setRepeatCacheForScheduleInRange(
    int scheduleId,
    DateTime? schedulePeriodBegin,
    DateTime? schedulePeriodEnd,
    DateTime scheduleOriginDate,
    ScheduleRepeatType scheduleRepeatType,
    Duration scheduleRepeatInterval,
    List<Weekday> scheduleWeeklyRepeatOn,
    Duration? scheduleHeadOffset,
    Duration? scheduleTailOffset,
    DateTime rangeBegin,
    DateTime rangeEnd,
  ) async {
    // cut off out-of-range period
    var periodBegin = schedulePeriodBegin ?? rangeBegin;
    if (periodBegin.isBefore(rangeBegin)) {
      periodBegin = rangeBegin;
    }
    var periodEnd = schedulePeriodEnd ?? rangeEnd;
    if (periodEnd.isAfter(rangeEnd)) {
      periodEnd = rangeEnd;
    }
    // cache
    switch (scheduleRepeatType) {
      case ScheduleRepeatType.no:
        if (scheduleOriginDate.isBefore(rangeBegin) ||
            scheduleOriginDate.isAfter(rangeEnd)) {
          return;
        }
        rdb.repeatCacher.cacheSchedule(scheduleId, [scheduleOriginDate]);
        break;
      case ScheduleRepeatType.interval:
        rdb.repeatCacher.cacheSchedule(
            scheduleId,
            DateTimeSequence.withInterval(periodBegin, periodEnd,
                scheduleOriginDate, scheduleRepeatInterval));
        break;
      case ScheduleRepeatType.weekly:
        rdb.repeatCacher.cacheSchedule(
            scheduleId,
            DateTimeSequence.weekly(
                periodBegin, periodEnd, scheduleWeeklyRepeatOn));
        break;
      case ScheduleRepeatType.monthly:
        if (scheduleHeadOffset != null) {
          rdb.repeatCacher.cacheSchedule(
              scheduleId,
              DateTimeSequence.monthlyHeadOrigin(
                  periodBegin, periodEnd, scheduleHeadOffset));
        }
        if (scheduleTailOffset != null) {
          rdb.repeatCacher.cacheSchedule(
              scheduleId,
              DateTimeSequence.monthlyTailOrigin(
                  periodBegin, periodEnd, scheduleTailOffset));
        }
        break;
      case ScheduleRepeatType.anually:
        rdb.repeatCacher.cacheSchedule(
            scheduleId,
            DateTimeSequence.anually(
                periodBegin, periodEnd, scheduleOriginDate));
        break;
    }
  }

  Future<void> setRepeatCacheForSchedule(view_obj.Schedule schedule) async {
    await rdb.transaction(() async {
      await clearRepeatCacheForSchedule(schedule.id!);
      await _setRepeatCacheForScheduleInRange(
          schedule.id!,
          schedule.periodBegin,
          schedule.periodEnd,
          schedule.originDate,
          schedule.repeatType,
          schedule.repeatInterval,
          schedule.weeklyRepeatOn,
          schedule.monthlyHeadOriginRepeatOffset,
          schedule.monthlyTailOriginRepeatOffset,
          tomorrow(),
          await ndb.cachingStatus.cachedUntil);
    });
  }

  Future<void> cleanUpRepeatCache() async {
    await rdb.transaction(() async {
      await rdb.repeatCacher.transferSchedulesToLogs();
      await rdb.repeatCacher.cleanUp();
    });
  }

  Future<void> insertRepeatCacheBetween(DateTime from, DateTime to) async {
    await rdb.transaction(() async {
      // insert repeat cache for all schedules and estimations
      List<Future> buf = [];
      var schedules = rdb.scheduleAccessor.all();
      await for (var schedule in schedules) {
        // note: there is no need to clear cache in advance
        // because the caching should be going onto uncached range.
        buf.add(_setRepeatCacheForScheduleInRange(
            schedule.id,
            schedule.periodBegin,
            schedule.periodEnd,
            schedule.origin,
            schedule.repeatType,
            Duration(days: schedule.interval ?? 1),
            [
              if (schedule.onSunday) Weekday.sunday,
              if (schedule.onMonday) Weekday.monday,
              if (schedule.onTuesday) Weekday.tuesday,
              if (schedule.onWednesday) Weekday.wednesday,
              if (schedule.onThursday) Weekday.thursday,
              if (schedule.onFriday) Weekday.friday,
              if (schedule.onSaturday) Weekday.saturday,
            ],
            schedule.monthlyHeadOrigin != null
                ? Duration(days: schedule.monthlyHeadOrigin!)
                : null,
            schedule.monthlyTailOrigin != null
                ? Duration(days: schedule.monthlyTailOrigin!)
                : null,
            from,
            to));
      }
      var estimations = rdb.estimationAccessor.all();
      await for (var estimation in estimations) {
        buf.add(_setRepeatCacheForEstimation(estimation.id,
            estimation.periodBegin, estimation.periodEnd, from, to));
      }
      await Future.wait(buf);
    });
  }
}

final cache = CachingOperations();
