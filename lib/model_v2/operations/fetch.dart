import 'dart:io';

import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/model_v2/data/data.dart';

class FetchOperations {
  Stream<view_obj.Category> _categoryStream(Stream<Category> stream) async* {
    await for (var cat in stream) {
      yield view_obj.Category(name: cat.name, id: cat.id);
    }
  }

  Stream<view_obj.Category> allCategories() {
    var stream = rdb.categoryAccessor.all();
    return _categoryStream(stream);
  }

  Stream<view_obj.Log> _logStream(Stream<(Log, Category)> stream) async* {
    await for (var record in stream) {
      yield view_obj.Log(
        id: record.$1.id,
        date: record.$1.registeredAt,
        category: view_obj.Category(id: record.$2.id, name: record.$2.name),
        amount: record.$1.amount,
        supplement: record.$1.supplement,
        image: record.$1.imageUrl == null ? null : File(record.$1.imageUrl!),
        confirmed: record.$1.confirmed,
      );
    }
  }

  Stream<view_obj.Log> allLogs() {
    var stream = rdb.logAccessor.all();
    return _logStream(stream);
  }

  Stream<view_obj.Log> logsOn(DateTime date) {
    var stream = rdb.logAccessor.on(date);
    return _logStream(stream);
  }

  Stream<view_obj.Log> unconfirmedLogs() {
    var stream = rdb.logAccessor.unconfirmed();
    return _logStream(stream);
  }

  Stream<view_obj.Preset> presets(int limit) async* {
    var stream = rdb.logAccessor.latest(limit);
    await for (var record in stream) {
      yield view_obj.Preset(
        category: view_obj.Category(id: record.$2.id, name: record.$2.name),
        amount: record.$1.amount,
        supplement: record.$1.supplement,
      );
    }
  }

  Stream<view_obj.Display> _displayStream(
      Stream<(Display, List<Category>)> stream) async* {
    await for (var display in stream) {
      DisplayTermMode termMode;
      if (display.$1.periodInDays != null) {
        termMode = DisplayTermMode.lastPeriod;
      } else if (display.$1.periodBegin != null) {
        termMode = DisplayTermMode.specificPeriod;
      } else if (display.$1.periodEnd != null) {
        termMode = DisplayTermMode.untilDate;
      } else {
        termMode = DisplayTermMode.untilToday;
      }
      var period = DisplayPeriod.fromDays(display.$1.periodInDays ?? 0);
      yield view_obj.Display(
        termMode: termMode,
        displayPeriod: period,
        periodBegin: display.$1.periodBegin,
        periodEnd: display.$1.periodEnd,
        contentType: display.$1.contentType,
        targetingAllCategories: display.$2.isEmpty,
        targetCategories: display.$2
            .map((e) => view_obj.Category(id: e.id, name: e.name))
            .toList(),
      );
    }
  }

  Stream<view_obj.Display> displaysOn(DateTime date) {
    var stream = rdb.displayAccessor.on(date);
    return _displayStream(stream);
  }

  Stream<view_obj.Display> displayEdgeOn(DateTime date) {
    var stream = rdb.displayAccessor.edgeOn(date);
    return _displayStream(stream);
  }

  Stream<view_obj.Schedule> _scheduleStream(
      Stream<(Schedule, Category)> stream) async* {
    await for (var schedule in stream) {
      yield view_obj.Schedule(
          id: schedule.$1.id,
          supplement: schedule.$1.supplement,
          category:
              view_obj.Category(id: schedule.$2.id, name: schedule.$2.name),
          amount: schedule.$1.amount,
          originDate: schedule.$1.origin,
          repeatType: schedule.$1.repeatType,
          repeatInterval: Duration(days: schedule.$1.interval ?? 1),
          weeklyRepeatOn: [
            if (schedule.$1.onSunday) Weekday.sunday,
            if (schedule.$1.onMonday) Weekday.monday,
            if (schedule.$1.onTuesday) Weekday.tuesday,
            if (schedule.$1.onWednesday) Weekday.wednesday,
            if (schedule.$1.onThursday) Weekday.thursday,
            if (schedule.$1.onFriday) Weekday.friday,
            if (schedule.$1.onSaturday) Weekday.saturday,
          ],
          monthlyHeadOriginRepeatOffset: schedule.$1.monthlyHeadOrigin != null
              ? Duration(days: schedule.$1.monthlyHeadOrigin!)
              : null,
          monthlyTailOriginRepeatOffset: schedule.$1.monthlyTailOrigin != null
              ? Duration(days: schedule.$1.monthlyTailOrigin!)
              : null,
          periodBegin: schedule.$1.periodBegin,
          periodEnd: schedule.$1.periodEnd);
    }
  }

  Stream<view_obj.Schedule> schedulesOn(DateTime date) {
    var stream = rdb.scheduleAccessor.on(date);
    return _scheduleStream(stream);
  }

  Stream<view_obj.Estimation> _estimationStrem(
      Stream<(Estimation, List<Category>)> stream) async* {
    await for (var estimation in stream) {
      yield view_obj.Estimation(
        id: estimation.$1.id,
        periodBeign: estimation.$1.periodBegin,
        periodEnd: estimation.$1.periodEnd,
        contentType: estimation.$1.contentType,
        targetingAllCategories: estimation.$2.isEmpty,
        targetCategories: estimation.$2
            .map((e) => view_obj.Category(id: e.id, name: e.name))
            .toList(),
      );
    }
  }

  Stream<view_obj.Estimation> estimationsOn(DateTime date) {
    var stream = rdb.estimationAccessor.on(date);
    return _estimationStrem(stream);
  }
}

final fetch = FetchOperations();
