import 'package:miraibo/data/ticket_data.dart';
import 'package:miraibo/data/database.dart';
import 'package:miraibo/data/category_data.dart';
import 'package:flutter/foundation.dart' as dev;

import 'package:flutter_test/flutter_test.dart';

void printList(List list) {
  switch (list) {
    case List<DisplayTicketRecord> _:
      dev.debugPrint(
        list
            .map((e) =>
                "<#${e.id} ${e.contentType} ${e.designatedDate} ${e.designatedPeriod} ${e.targetCategories.map((e) => e.name)}/${e.targetingAllCategories} ${e.termMode}>\n")
            .join(','),
      );
      break;
    case List<ScheduleRecord> _:
      dev.debugPrint(
        list
            .map(
              (e) =>
                  "<#${e.id} ${e.amount} ${e.category?.name} ${e.supplement}>",
            )
            .join(','),
      );
      break;
    case List<EstimationRecord> _:
      dev.debugPrint(
        list
            .map(
              (e) => "<#${e.id} ${e.targetCategories.map((e) => e.name)}>",
            )
            .join(','),
      );
      break;
    case List<LogRecord> _:
      dev.debugPrint(
        list
            .map((e) =>
                "<#${e.id} ${e.amount} ${e.category?.name} ${e.supplement}>")
            .join(','),
      );
      break;
    case List<Category> _:
      dev.debugPrint(list.map((e) => e.name).join(','));
      break;
    case List<Link> _:
      dev.debugPrint(
          list.map((e) => '<#${e.id} ${e.keyId}-${e.valueId}>').join(','));
      break;
    default:
      dev.debugPrint(list.toString());
      break;
  }
}

void main() async {
  test('display ticket table', () async {
    DisplayTicketTable displayTicketTable = await DisplayTicketTable.use(null);
    var res = await displayTicketTable.fetchAll(null);
    printList(res);
  });
  test('new display ticket', () async {
    DisplayTicketTable displayTicketTable = await DisplayTicketTable.use(null);
    DisplayTicketRecord newDisplayTicket = DisplayTicketRecord();
    var displayTickets = await displayTicketTable.fetchAll(null);
    var count = displayTickets.length;
    await displayTicketTable.save(newDisplayTicket, null);
    displayTickets = await displayTicketTable.fetchAll(null);
    printList(displayTickets);
    DisplayTicketTargetCategoryLinker displayTicketTargetCategoryLinker =
        await DisplayTicketTargetCategoryLinker.use(null);
    var linkers = await displayTicketTargetCategoryLinker.fetchAll(null);
    printList(linkers);
    expect(displayTickets.length, count + 1);
  });
  test('update display ticket', () async {
    DisplayTicketTable displayTicketTable = await DisplayTicketTable.use(null);
    DisplayTicketRecord newDisplayTicket = DisplayTicketRecord();
    var id = await displayTicketTable.save(newDisplayTicket, null);
    newDisplayTicket = DisplayTicketRecord(
        id: id,
        targetCategories: [await Category.make('New Category')],
        targetingAllCategories: false);
    await newDisplayTicket.save();
    var displayTickets = await displayTicketTable.fetchAll(null);
    printList(displayTickets);
    DisplayTicketTargetCategoryLinker displayTicketTargetCategoryLinker =
        await DisplayTicketTargetCategoryLinker.use(null);
    var linkers = await displayTicketTargetCategoryLinker.fetchAll(null);
    printList(linkers);
  });
  test('delete display ticket', () async {
    DisplayTicketTable displayTicketTable = await DisplayTicketTable.use(null);
    DisplayTicketRecord newDisplayTicket = DisplayTicketRecord();
    var id = await displayTicketTable.save(newDisplayTicket, null);
    var res = await displayTicketTable.fetchAll(null);
    var count = res.length;
    await displayTicketTable.delete(id, null);
    res = await displayTicketTable.fetchAll(null);
    expect(res.length, count - 1);
    DisplayTicketTargetCategoryLinker displayTicketTargetCategoryLinker =
        await DisplayTicketTargetCategoryLinker.use(null);
    var linkers = await displayTicketTargetCategoryLinker.fetchAll(null);
    printList(linkers);
  });
  test('schedule table', () async {
    ScheduleTable scheduleTable = await ScheduleTable.use(null);
    var res = await scheduleTable.fetchAll(null);
    printList(res);
  });
  test('new schedule', () async {
    ScheduleTable scheduleTable = await ScheduleTable.use(null);
    var res = await scheduleTable.fetchAll(null);
    var count = res.length;
    Category cat = await Category.make('category for schedule');
    ScheduleRecord newSchedule = ScheduleRecord(
      originDate: DateTime.now(),
      category: cat,
    );
    await scheduleTable.save(newSchedule, null);
    res = await scheduleTable.fetchAll(null);
    printList(res);
    expect(res.length, count + 1);
  });
  test('update schedule', () async {
    ScheduleTable scheduleTable = await ScheduleTable.use(null);
    Category cat = await Category.make('category for schedule');
    ScheduleRecord newSchedule = ScheduleRecord(
      originDate: DateTime.now(),
      category: cat,
    );
    var id = await scheduleTable.save(newSchedule, null);

    newSchedule = ScheduleRecord(
      id: id,
      originDate: DateTime.now(),
      supplement: 'updated',
      category: cat,
    );
    await newSchedule.save();

    var res = await scheduleTable.fetchAll(null);
    printList(res);
  });
  test('delete schedule', () async {
    ScheduleTable scheduleTable = await ScheduleTable.use(null);
    Category cat = await Category.make('category for schedule');
    ScheduleRecord newSchedule = ScheduleRecord(
      originDate: DateTime.now(),
      category: cat,
    );
    var id = await scheduleTable.save(newSchedule, null);

    var res = await scheduleTable.fetchAll(null);
    var count = res.length;

    newSchedule = ScheduleRecord(
      id: id,
      originDate: DateTime.now(),
      category: cat,
    );
    await newSchedule.delete();

    res = await scheduleTable.fetchAll(null);
    printList(res);
    expect(res.length, count - 1);
  });

  test('estimation table', () async {
    EstimationTable estimationTable = await EstimationTable.use(null);
    var res = await estimationTable.fetchAll(null);
    printList(res);
  });
  test('new estimation', () async {
    EstimationTable estimationTable = await EstimationTable.use(null);
    var res = await estimationTable.fetchAll(null);
    var count = res.length;
    Category cat = await Category.make('category for new estimation');
    EstimationRecord newEstimation = EstimationRecord(
      targetCategories: [cat],
    );
    await estimationTable.save(newEstimation, null);
    res = await estimationTable.fetchAll(null);
    printList(res);
    expect(res.length, count + 1);
  });
  test('update estimation', () async {
    EstimationTable estimationTable = await EstimationTable.use(null);
    EstimationRecord newEstimation = EstimationRecord(
      targetCategories: [],
      targetingAllCategories: true,
    );
    var id = await estimationTable.save(newEstimation, null);

    newEstimation = EstimationRecord(
      id: id,
      targetCategories: [await Category.make('estimation updated')],
      targetingAllCategories: false,
    );
    await newEstimation.save();

    var res = await estimationTable.fetchAll(null);
    printList(res);
  });
  test('delete estimation', () async {
    EstimationTable estimationTable = await EstimationTable.use(null);
    EstimationRecord newEstimation = EstimationRecord(
      targetCategories: [],
      targetingAllCategories: true,
    );
    var id = await estimationTable.save(newEstimation, null);

    var res = await estimationTable.fetchAll(null);
    var count = res.length;

    newEstimation = EstimationRecord(
      id: id,
      targetCategories: [],
      targetingAllCategories: true,
    );
    await newEstimation.delete();

    res = await estimationTable.fetchAll(null);
    printList(res);
    expect(res.length, count - 1);
  });
  test('log record table', () async {
    LogRecordTable logRecordTable = await LogRecordTable.use(null);
    var res = await logRecordTable.fetchAll(null);
    printList(res);
  });
  test('new log record', () async {
    LogRecordTable logRecordTable = await LogRecordTable.use(null);
    var res = await logRecordTable.fetchAll(null);
    var count = res.length;
    Category cat = await Category.make('category for new log record');
    LogRecord newLogRecord = LogRecord(
      category: cat,
      amount: 100,
      registorationDate: DateTime.now(),
    );
    await logRecordTable.save(newLogRecord, null);
    res = await logRecordTable.fetchAll(null);
    printList(res);
    expect(res.length, count + 1);
  });
  test('update log record', () async {
    LogRecordTable logRecordTable = await LogRecordTable.use(null);
    Category cat = await Category.make('category for log record');
    LogRecord newLogRecord = LogRecord(
      category: cat,
      amount: 100,
      registorationDate: DateTime.now(),
    );
    var id = await logRecordTable.save(newLogRecord, null);

    newLogRecord = LogRecord(
      id: id,
      category: cat,
      amount: 200,
      registorationDate: DateTime.now(),
    );
    await newLogRecord.save();

    var res = await logRecordTable.fetchAll(null);
    printList(res);
  });
  test('delete log record', () async {
    LogRecordTable logRecordTable = await LogRecordTable.use(null);
    Category cat = await Category.make('category for log record');
    LogRecord newLogRecord = LogRecord(
      category: cat,
      amount: 100,
      registorationDate: DateTime.now(),
    );
    var id = await logRecordTable.save(newLogRecord, null);

    var res = await logRecordTable.fetchAll(null);
    var count = res.length;

    newLogRecord = LogRecord(
      id: id,
      category: cat,
      amount: 100,
      registorationDate: DateTime.now(),
    );
    await newLogRecord.delete();

    res = await logRecordTable.fetchAll(null);
    printList(res);
    expect(res.length, count - 1);
  });
  tearDownAll(() async {
    PersistentDatabaseProvider dbProvider = PersistentDatabaseProvider();
    await dbProvider.clear();
  });
}
