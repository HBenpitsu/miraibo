import 'package:miraibo/data/ticket_data.dart';
import 'package:miraibo/data/database.dart';
import 'package:miraibo/data/category_data.dart';

import 'package:flutter_test/flutter_test.dart';

void printTicketList(List<TicketConfigRecord> list) {
  switch (list) {
    case List<DisplayTicketRecord> _:
      print(
        list
            .map((e) =>
                "<${e.id} ${e.contentType} ${e.designatedDate} ${e.designatedPeriod} ${e.targetCategories.map((e) => e.name)}/${e.targetingAllCategories} ${e.termMode}>\n")
            .join(','),
      );
      break;
    case List<ScheduleRecord> _:
      print(
        list
            .map(
              (e) =>
                  "<${e.id} ${e.amount} ${e.category?.name} ${e.supplement}>",
            )
            .join(','),
      );
      break;
    case List<EstimationRecord> _:
      print(
        list
            .map(
              (e) => "<${e.id} ${e.targetCategories.map((e) => e.name)}>",
            )
            .join(','),
      );
      break;
    case List<LogRecord> _:
      print(
        list
            .map((e) =>
                "<${e.id} ${e.amount} ${e.category?.name} ${e.supplement}>")
            .join(','),
      );
      break;
    default:
      print(list);
      break;
  }
}

printCatList(List<Category> list) {
  print(list.map((e) => e.name).join(','));
}

printLinkList(List<Link> list) {
  print(list.map((e) => '#${e.id} ${e.keyId}-${e.valueId}').join(','));
}

void main() async {
  // this is pre-test. I should make neet test later.
  test('ticket config db works?', () async {
    DisplayTicketTable displayTicketTable = await DisplayTicketTable.use(null);
    DisplayTicketTargetCategoryLinker displayTicketTargetCategoryLinker =
        await DisplayTicketTargetCategoryLinker.use(null);
    ScheduleTable scheduleTable = await ScheduleTable.use(null);
    EstimationTable estimationTable = await EstimationTable.use(null);
    EstimationTargetCategoryLinker estimationTargetCategoryLinker =
        await EstimationTargetCategoryLinker.use(null);
    LogRecordTable logRecordTable = await LogRecordTable.use(null);
    CategoryTable categoryTable = await CategoryTable.use(null);

    var res;

    print('DisplayTicketTable: ');
    DisplayTicketRecord newDisplayTicket = DisplayTicketRecord();
    var id = await displayTicketTable.save(newDisplayTicket, null);

    res = await displayTicketTable.fetchAll(null);
    printTicketList(res);

    newDisplayTicket = DisplayTicketRecord(
        id: id,
        targetCategories: [await Category.make('New Category')],
        targetingAllCategories: false);
    await newDisplayTicket.save();

    res = await displayTicketTable.fetchAll(null);
    printTicketList(res);

    res = await categoryTable.fetchAll(null);
    printCatList(res);

    res = await displayTicketTargetCategoryLinker.fetchAll(null);
    printLinkList(res);

    newDisplayTicket =
        DisplayTicketRecord(id: id, targetingAllCategories: true);
    await newDisplayTicket.save();

    res = await displayTicketTargetCategoryLinker.fetchAll(null);
    printLinkList(res);

    print('ScheduleTable: ');

    ScheduleRecord newSchedule = ScheduleRecord(
      originDate: DateTime.now(),
      category: await Category.make('category for schedule'),
    );
    id = await scheduleTable.save(newSchedule, null);

    res = await scheduleTable.fetchAll(null);
    printTicketList(res);

    print('EstimationTable: ');

    EstimationRecord newEstimation = EstimationRecord(
      targetCategories: [
        await Category.make('category for estimation'),
        await Category.make('category for estimation2')
      ],
    );
    id = await estimationTable.save(newEstimation, null);

    res = await estimationTable.fetchAll(null);
    printTicketList(res);

    res = await estimationTargetCategoryLinker.fetchAll(null);
    printLinkList(res);

    print('LogRecordTable: ');

    LogRecord newLogRecord = LogRecord(
      category: await Category.make('category for log'),
      amount: 100,
      registorationDate: DateTime.now(),
    );
    id = await logRecordTable.save(newLogRecord, null);

    res = await logRecordTable.fetchAll(null);
    printTicketList(res);

    await PersistentDatabaseProvider().clear();
  });
}
