import 'package:drift/drift.dart';
import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/model_v2/data/data.dart';
import 'package:miraibo/model_v2/operations/cache.dart';

class WriteOperations {
  Future<int> saveCategory(view_obj.Category cat) async {
    return rdb.categoryAccessor.saveCategory(CategoriesCompanion(
      id: cat.id == null ? const Value.absent() : Value(cat.id!),
      name: Value(cat.name),
    ));
  }

  Future<int> saveLog(view_obj.Log log,
      {view_obj.Category? originalCategory}) async {
    await updateOldestRecordDate(log.date);
    return rdb.transaction(() async {
      var id = await rdb.logAccessor.saveLog(LogsCompanion(
          id: log.id == null ? const Value.absent() : Value(log.id!),
          category: Value(log.category.id!),
          supplement: Value(log.supplement),
          registeredAt: Value(log.date),
          amount: Value(log.amount),
          imageUrl: Value(log.image?.path),
          confirmed: Value(log.confirmed),
          updatedAt: Value(DateTime.now())));
      await cache.refreshEstimationCache([
        log.category.id!,
        if (originalCategory != null) originalCategory.id!
      ]);
      return id;
    });
  }

  Future<void> confirmLogsUntil(DateTime date) async {
    await rdb.logAccessor.confirmUntil(date);
  }

  Future<int> saveEstimation(view_obj.Estimation estimation) async {
    return rdb.transaction(() async {
      var id = await rdb.estimationAccessor.saveEstimation(
          EstimationsCompanion(
            id: estimation.id == null
                ? const Value.absent()
                : Value(estimation.id!),
            periodBegin: Value(estimation.periodBeign),
            periodEnd: Value(estimation.periodEnd),
            contentType: Value(estimation.contentType),
          ),
          estimation.targetingAllCategories
              ? []
              : estimation.targetCategories.map((e) => e.id!));
      estimation.id = id;
      await cache.setRepeatCacheForEstimation(estimation);
      return id;
    });
  }

  Future<int> saveSchedule(view_obj.Schedule schedule) async {
    return rdb.transaction(() async {
      var id = await rdb.scheduleAccessor.saveSchedule(SchedulesCompanion(
        id: schedule.id == null ? const Value.absent() : Value(schedule.id!),
        category: Value(schedule.category.id!),
        supplement: Value(schedule.supplement),
        amount: Value(schedule.amount),
        origin: Value(schedule.originDate),
        repeatType: Value(schedule.repeatType),
        interval: Value(schedule.repeatInterval.inDays),
        onSunday: Value(schedule.weeklyRepeatOn.contains(Weekday.sunday)),
        onMonday: Value(schedule.weeklyRepeatOn.contains(Weekday.monday)),
        onTuesday: Value(schedule.weeklyRepeatOn.contains(Weekday.tuesday)),
        onWednesday: Value(schedule.weeklyRepeatOn.contains(Weekday.wednesday)),
        onThursday: Value(schedule.weeklyRepeatOn.contains(Weekday.thursday)),
        onFriday: Value(schedule.weeklyRepeatOn.contains(Weekday.friday)),
        onSaturday: Value(schedule.weeklyRepeatOn.contains(Weekday.saturday)),
        monthlyHeadOrigin:
            Value(schedule.monthlyHeadOriginRepeatOffset?.inDays),
        monthlyTailOrigin:
            Value(schedule.monthlyTailOriginRepeatOffset?.inDays),
        periodBegin: Value(schedule.periodBegin),
        periodEnd: Value(schedule.periodEnd),
      ));
      schedule.id = id;
      await cache.setRepeatCacheForSchedule(schedule);
      return id;
    });
  }

  Future<int> saveDisplay(view_obj.Display display) async {
    return rdb.displayAccessor.saveDisplay(
        DisplaysCompanion(
            id: display.id == null ? const Value.absent() : Value(display.id!),
            periodInDays: Value(display.termMode == DisplayTermMode.lastPeriod
                ? display.displayPeriod.inDays
                : null),
            periodBegin: Value(
                display.termMode == DisplayTermMode.specificPeriod
                    ? display.periodBegin
                    : null),
            periodEnd: Value([
              DisplayTermMode.specificPeriod,
              DisplayTermMode.untilDate
            ].contains(display.termMode)
                ? display.periodEnd
                : null),
            contentType: Value(display.contentType)),
        display.targetingAllCategories
            ? []
            : display.targetCategories.map((e) => e.id!));
  }

  /// Returns true if the meta-data is updated
  Future<bool> updateOldestRecordDate(DateTime date) async {
    if ((await ndb.metaData.firstRecord).isAfter(date)) {
      await ndb.metaData.setFirstRecord(date);
      return true;
    } else {
      return false;
    }
  }
}

final write = WriteOperations();
