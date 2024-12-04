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
                DTPeriod.week => Duration(days: 7),
                DTPeriod.month => Duration(days: 30),
                DTPeriod.halfYear => Duration(days: 180),
                DTPeriod.year => Duration(days: 365),
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
          dt.termMode == DTTermMode.specificPeriod ? dt.periodBegin : null,
      endDate: dt.termMode == DTTermMode.specificPeriod ||
              dt.termMode == DTTermMode.untilDate
          ? dt.periodEnd
          : null,
      periodInDays: dt.termMode == DTTermMode.lastPeriod
          ? switch (dt.displayPeriod) {
              DTPeriod.week => Duration(days: 7),
              DTPeriod.month => Duration(days: 30),
              DTPeriod.halfYear => Duration(days: 180),
              DTPeriod.year => Duration(days: 365),
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
          ? DTPeriod.week
          : switch (dt.periodInDays!) {
              Duration(inDays: 7) => DTPeriod.week,
              Duration(inDays: 30) => DTPeriod.month,
              Duration(inDays: 180) => DTPeriod.halfYear,
              Duration(inDays: 365) => DTPeriod.year,
              _ => DTPeriod.week,
            };
      var termMode = dt.periodInDays != null
          ? DTTermMode.lastPeriod
          : dt.startDate != null && dt.endDate != null
              ? DTTermMode.specificPeriod
              : dt.endDate != null
                  ? DTTermMode.untilDate
                  : DTTermMode.untilToday;
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
