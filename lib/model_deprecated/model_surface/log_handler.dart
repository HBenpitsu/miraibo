import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/model_obj.dart.deprecated' as model_obj;
import 'package:miraibo/model_deprecated/transaction/log.dart';
import 'package:miraibo/model_deprecated/transaction/category.dart';

class LogHandler {
  Future<void> save(view_obj.Log log) async {
    await SaveLog(model_obj.Log(
            categoryId: log.category.id!,
            supplement: log.supplement,
            amount: log.amount,
            date: log.date,
            confirmed: log.confirmed))
        .execute();
  }

  Future<void> delete(view_obj.Log log) async {
    if (log.id == null) return;
    await DeleteLog(log.id!).execute();
  }

  Future<List<view_obj.Log>> belongsTo(DateTime date) async {
    var queryResult = await FetchLogsBelongTo(date).execute();
    List<view_obj.Log> ret = [];
    for (var log in queryResult) {
      var cat = await FindCategory(log.categoryId).execute();
      ret.add(view_obj.Log(
        id: log.id,
        category: view_obj.Category(id: cat.id, name: cat.name),
        supplement: log.supplement,
        amount: log.amount,
        date: log.date,
        confirmed: log.confirmed,
      ));
    }
    return ret;
  }
}
