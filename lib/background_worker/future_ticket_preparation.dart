import 'package:miraibo/dataDeprec/future_ticket_data.dart';
import 'package:miraibo/dataDeprec/ticket_data.dart';
import 'package:miraibo/dataDeprec/database.dart';
import 'package:miraibo/dataDeprec/category_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:miraibo/util/date_time.dart';

class FutureTicketPreparationEventHandler {
  FutureTicketPreparationEventHandler._internal();
  static final FutureTicketPreparationEventHandler _instance =
      FutureTicketPreparationEventHandler._internal();
  factory FutureTicketPreparationEventHandler() {
    return _instance;
  }

  DatabaseProvider dbProvider = PersistentDatabaseProvider();

  Future<void> onFactoryUpdated(
      FutureTicketFactory updatedRecord, Transaction txn) async {
    await FutureTicketGenerator.update(updatedRecord, txn);
  }

  Future<void> onExpansionRequired(DateTime until, Transaction? txn) async {
    if (txn == null) {
      await dbProvider.ensureAvailability();
      return dbProvider.db.transaction((txn) {
        return onExpansionRequired(until, txn);
      });
    }
    await FutureTicketGenerator.expand(until, txn);
  }

  Future<void> onFactoryDeleted(
      int id, Table<FutureTicketFactory> kind, Transaction txn) async {
    var futureTicketTable = await FutureTicketTable.use(txn);
    futureTicketTable.eliminateAllByFactory(id, kind, txn);
  }
}

abstract final class FutureTicketGenerator {
  static DatabaseProvider dbProvider = PersistentDatabaseProvider();

  static Future<void> update(
      FutureTicketFactory updatedRecord, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return update(updatedRecord, txn);
      });
    }

    var futureTicketTable = await FutureTicketTable.use(txn);
    var futureTicketPreparationState = await FutureTicketPreparationState.use();
    var from = today();
    var to = await futureTicketPreparationState.getPreparedUntil();
    switch (updatedRecord) {
      case ScheduleRecord schedule:
        await futureTicketTable.eliminateAllByFactory(
            schedule.id!, ScheduleTable.ref(), txn);
        return FutureTicketGenerator.generateForSchedule(
            schedule, from, to, txn);
      case EstimationRecord estimation:
        await futureTicketTable.eliminateAllByFactory(
            estimation.id!, EstimationTable.ref(), txn);
        return FutureTicketGenerator.generateForEstimation(
            estimation, from, to, txn);
      default:
        throw UnimplementedError(
            'The factory kind $updatedRecord is not supported.');
    }
  }

  static Future<void> expand(DateTime until, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return expand(until, txn);
      });
    }

    late DateTime from;

    await Future.wait([
      (() async {
        var futureTicketPreparationState =
            await FutureTicketPreparationState.use();
        from = await futureTicketPreparationState.getPreparedUntil();
      })(),
      (() async {
        var futureTicketPreparationState =
            await FutureTicketPreparationState.use();
        futureTicketPreparationState.setPreparingUntil(until);
      })(),
    ]);

    var scheduleTable = await ScheduleTable.use(txn);
    var estimationTable = await EstimationTable.use(txn);

    late List<ScheduleRecord> schedules;
    late List<EstimationRecord> estimations;
    List<Future<void>> futureBuffer = [];

    await Future.wait([
      (() async {
        schedules = await scheduleTable.fetchAll(txn);
        for (var schedule in schedules) {
          futureBuffer.add(generateForSchedule(schedule, from, until, txn));
        }
      })(),
      (() async {
        estimations = await estimationTable.fetchAll(txn);
        for (var estimation in estimations) {
          futureBuffer.add(generateForEstimation(estimation, from, until, txn));
        }
      })(),
    ]);

    await Future.wait(futureBuffer);

    var futureTicketPreparationState = await FutureTicketPreparationState.use();
    await futureTicketPreparationState.setPreparedUntil(until);
  }

  static Future<void> generateForSchedule(ScheduleRecord schedule,
      DateTime from, DateTime to, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return generateForSchedule(schedule, from, to, txn);
      });
    }

    ScheduleTable.ref().validate(schedule);

    var futureTicketTable = await FutureTicketTable.use(txn);
    var futureTicketTemplate = FutureTicket(
      schedule: schedule,
      estimation: null,
      category: schedule.category!,
      supplement: schedule.supplement,
      scheduledAt: schedule.originDate!,
      amount: schedule.amount.toDouble(),
    );

    if (schedule.startDate != null && from.isBefore(schedule.startDate!)) {
      from = schedule.startDate!;
    }
    if (schedule.endDate != null && to.isAfter(schedule.endDate!)) {
      to = schedule.endDate!.add(Duration(days: 1));
    }
    if ((schedule.endDate != null && from.isAfter(schedule.endDate!)) ||
        (schedule.startDate != null &&
            (to.isBefore(schedule.startDate!) ||
                to.isAtSameMomentAs(schedule.startDate!)))) {
      return;
    }

    switch (schedule.repeatType) {
      case RepeatType.no:
        if (schedule.originDate!.isBefore(from) ||
            schedule.originDate!.isAfter(to) ||
            schedule.originDate!.isAtSameMomentAs(to)) {
          return;
        }
        await futureTicketTable.save(futureTicketTemplate, txn);
        break;
      case RepeatType.interval:
        await futureTicketTable.makeTicketsWithInterval(
            futureTicketTemplate, from, to, schedule.repeatInterval, txn);
        break;
      case RepeatType.weekly:
        await Future.wait([
          for (var weekday in schedule.repeatWeekdays)
            futureTicketTable.makeWeeklyTickets(
                futureTicketTemplate, from, to, weekday, txn)
        ]);
        break;
      case RepeatType.monthly:
        if (schedule.monthlyRepeatHeadOriginOffset != null) {
          await futureTicketTable.makeHeadOriginMonthlyTickets(
              futureTicketTemplate,
              from,
              to,
              schedule.monthlyRepeatHeadOriginOffset!,
              txn);
        } else if (schedule.monthlyRepeatTailOriginOffset != null) {
          await futureTicketTable.makeTailOriginMonthlyTickets(
              futureTicketTemplate,
              from,
              to,
              schedule.monthlyRepeatTailOriginOffset!,
              txn);
        }
        break;
      case RepeatType.anually:
        await futureTicketTable.makeAnnualTickets(
            futureTicketTemplate, from, to, txn);
        break;
    }
  }

  static Future<void> generateForEstimation(EstimationRecord estimation,
      DateTime from, DateTime to, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return generateForEstimation(estimation, from, to, txn);
      });
    }

    EstimationTable.ref().validate(estimation);

    var categoryTable = await CategoryTable.use(txn);

    var targetCategories = estimation.targetCategories;
    if (estimation.targetingAllCategories) {
      targetCategories = await categoryTable.fetchAll(txn);
    }

    if (estimation.startDate != null && from.isBefore(estimation.startDate!)) {
      from = estimation.startDate!;
    }

    if (estimation.endDate != null && to.isAfter(estimation.endDate!)) {
      to = estimation.endDate!;
    }

    var futureTicketTable = await FutureTicketTable.use(txn);
    var logRecordTable = await LogRecordTable.use(txn);

    var futureBuffer = <Future<void>>[];

    for (var target in targetCategories) {
      futureBuffer.add((() async {
        var estimatedAmount = await logRecordTable.estimateFor(target, txn);
        var template = FutureTicket(
          schedule: null,
          estimation: estimation,
          category: target,
          supplement: '',
          // scheduledAt field is replaced by [makeTicketsEveryday] method.
          // so, this value is just a placeholder.
          scheduledAt: today(),
          amount: estimatedAmount,
        );

        await futureTicketTable.makeTicketsEveryday(template, from, to, txn);
      })());
    }

    await Future.wait(futureBuffer);
  }
}
