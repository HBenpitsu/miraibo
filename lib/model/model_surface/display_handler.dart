import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/model_obj.dart' as model_obj;
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/model/transaction/display_ticket.dart';

class DisplayHandler {
  Future<void> save(view_obj.DisplayTicket dt) async {
    await SaveDisplayTicket(
            model_obj.DisplayTicket(
              contentType: dt.contentType,
              startDate: dt.periodBegin,
              endDate: dt.periodEnd,
              periodInDays: switch (dt.displayPeriod) {
                DisplayPeriod.week => Duration(days: 7),
                DisplayPeriod.month => Duration(days: 30),
                DisplayPeriod.halfYear => Duration(days: 180),
                DisplayPeriod.year => Duration(days: 365),
              },
            ),
            dt.targetingAllCategories
                ? []
                : List.from(dt.targetCategories.map(
                    (cat) => model_obj.Category(name: cat.name, id: cat.id))))
        .execute();
  }

  Future<void> delete(view_obj.DisplayTicket dt) async {
    if (dt.id == null) return;
    await DeleteDisplayTicket(dt.id!).execute();
  }

  Future<int> calculate(view_obj.DisplayTicket dt) async {
    return CalculateDisplayTicketContent(model_obj.DisplayTicket(
      contentType: dt.contentType,
      startDate:
          dt.termMode == DisplayTermMode.specificPeriod ? dt.periodBegin : null,
      endDate: dt.termMode == DisplayTermMode.specificPeriod ||
              dt.termMode == DisplayTermMode.untilDate
          ? dt.periodEnd
          : null,
      periodInDays: dt.termMode == DisplayTermMode.lastPeriod
          ? switch (dt.displayPeriod) {
              DisplayPeriod.week => Duration(days: 7),
              DisplayPeriod.month => Duration(days: 30),
              DisplayPeriod.halfYear => Duration(days: 180),
              DisplayPeriod.year => Duration(days: 365),
            }
          : null,
    )).execute();
  }

  Future<List<view_obj.DisplayTicket>> belongsTo(DateTime date) async {
    var displayTickets = await FetchDisplayTicketsBelongsTo(date).execute();
    List<view_obj.DisplayTicket> ret = [];
    for (var dt in displayTickets) {
      var cats = await FetchCategoriesForDisplayTicket(dt.id!).execute();
      var catList = [
        for (var cat in cats) view_obj.Category(id: cat.id, name: cat.name)
      ];
      var displayPeriod = dt.periodInDays == null
          ? DisplayPeriod.week
          : switch (dt.periodInDays!) {
              Duration(inDays: 7) => DisplayPeriod.week,
              Duration(inDays: 30) => DisplayPeriod.month,
              Duration(inDays: 180) => DisplayPeriod.halfYear,
              Duration(inDays: 365) => DisplayPeriod.year,
              _ => DisplayPeriod.week,
            };
      var termMode = dt.periodInDays != null
          ? DisplayTermMode.lastPeriod
          : dt.startDate != null && dt.endDate != null
              ? DisplayTermMode.specificPeriod
              : dt.endDate != null
                  ? DisplayTermMode.untilDate
                  : DisplayTermMode.untilToday;
      ret.add(view_obj.DisplayTicket(
        id: dt.id,
        contentType: dt.contentType,
        periodBegin: dt.startDate,
        periodEnd: dt.endDate,
        displayPeriod: displayPeriod,
        targetingAllCategories: catList.isEmpty,
        targetCategories: catList,
        termMode: termMode,
      ));
    }
    return ret;
  }
}
