import 'package:miraibo/data/future_ticket_data.dart';
import 'package:miraibo/data/ticket_data.dart';
import 'package:miraibo/data/database.dart';
import 'package:miraibo/data/category_data.dart';
import 'package:sqflite/sqflite.dart';

class FutureTicketPreparationEventHandler {
  FutureTicketPreparationEventHandler._internal();
  static final FutureTicketPreparationEventHandler _instance =
      FutureTicketPreparationEventHandler._internal();
  factory FutureTicketPreparationEventHandler() {
    return _instance;
  }

  Future<void> onFactoryUpdated(
      FutureTicketFactory updatedRecord, Transaction txn) async {
    switch (updatedRecord) {
      case ScheduleRecord schedule:
        return FutureTicketGenerator().generateForSchedule(schedule, txn);
      case EstimationRecord estimation:
        return FutureTicketGenerator().generateForEstimation(estimation, txn);
      default:
        throw UnimplementedError(
            'The factory kind $updatedRecord is not supported.');
    }
  }

  Future<void> onFactoryDeleted(
      int id, Table<FutureTicketFactory> kind, Transaction txn) async {
    var futureTicketTable = await FutureTicketTable.use(txn);
    futureTicketTable.eliminateAllByFactory(id, kind, txn);
  }
}

class FutureTicketGenerator {
  FutureTicketGenerator._internal();
  static final FutureTicketGenerator _instance =
      FutureTicketGenerator._internal();
  factory FutureTicketGenerator() {
    return _instance;
  }

  DatabaseProvider dbProvider = PersistentDatabaseProvider();

  Future<void> generateForSchedule(
      ScheduleRecord schedule, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return generateForSchedule(schedule, txn);
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

    var preparationState = await FutureTicketPreparationState.use();

    switch (schedule.repeatType) {
      case RepeatType.no:
        await futureTicketTable.save(futureTicketTemplate, txn);
        break;
      case RepeatType.interval:
        await futureTicketTable.makeTicketsWithInterval(
            futureTicketTemplate,
            schedule.startDate ?? DateTime.now(),
            schedule.endDate ?? await preparationState.getNeededUntil(),
            schedule.repeatInterval,
            txn);
        break;
      case RepeatType.weekly:
        await Future.wait([
          for (var weekday in schedule.repeatWeekdays)
            futureTicketTable.makeWeeklyTickets(
                futureTicketTemplate,
                schedule.startDate ?? DateTime.now(),
                schedule.endDate ?? await preparationState.getNeededUntil(),
                weekday,
                txn)
        ]);
        break;
      case RepeatType.monthly:
        if (schedule.monthlyRepeatHeadOriginOffset != null) {
          await futureTicketTable.makeHeadOriginMonthlyTickets(
              futureTicketTemplate,
              schedule.startDate ?? DateTime.now(),
              schedule.endDate ?? await preparationState.getNeededUntil(),
              schedule.monthlyRepeatHeadOriginOffset!,
              txn);
        } else if (schedule.monthlyRepeatTailOriginOffset != null) {
          await futureTicketTable.makeTailOriginMonthlyTickets(
              futureTicketTemplate,
              schedule.startDate ?? DateTime.now(),
              schedule.endDate ?? await preparationState.getNeededUntil(),
              schedule.monthlyRepeatTailOriginOffset!,
              txn);
        }
        break;
      case RepeatType.anually:
        await futureTicketTable.makeAnnualTickets(
            futureTicketTemplate,
            schedule.startDate ?? DateTime.now(),
            schedule.endDate ?? await preparationState.getNeededUntil(),
            txn);
        break;
    }
  }

  Future<void> generateForEstimation(
      EstimationRecord estimation, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) {
        return generateForEstimation(estimation, txn);
      });
    }

    EstimationTable.ref().validate(estimation);

    var categoryTable = await CategoryTable.use(txn);

    var targetCategories = estimation.targetCategories;
    if (estimation.targetingAllCategories) {
      targetCategories = await categoryTable.fetchAll(txn);
    }

    var futureTicketTable = await FutureTicketTable.use(txn);
    var logRecordTable = await LogRecordTable.use(txn);
    var preparationState = await FutureTicketPreparationState.use();

    for (var target in targetCategories) {
      var estimatedAmount = await logRecordTable.estimateFor(target, txn);
      var template = FutureTicket(
        schedule: null,
        estimation: estimation,
        category: target,
        supplement: '',
        // scheduledAt field is replaced by [makeTicketsEveryday] method.
        // so, this value is just a placeholder.
        scheduledAt: estimation.startDate ?? DateTime.now(),
        amount: estimatedAmount,
      );
      futureTicketTable.makeTicketsEveryday(
          template,
          estimation.startDate ?? DateTime.now(),
          estimation.endDate ?? await preparationState.getNeededUntil(),
          txn);
    }
  }
}
