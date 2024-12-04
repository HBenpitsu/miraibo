import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/model_obj.dart' as model_obj;
import 'package:miraibo/model/transaction/estimation.dart';

class EstimationHandler {
  Future<void> save(view_obj.Estimation estimation) async {
    SaveEstimation(
      model_obj.Estimation(
          contentType: estimation.contentType,
          periodBegin: estimation.periodBeign,
          periodEnd: estimation.periodEnd),
      estimation.targetingAllCategories
          ? []
          : [
              for (var cat in estimation.targetCategories)
                model_obj.Category(id: cat.id, name: cat.name)
            ],
    ).execute();
  }

  Future<void> delete(view_obj.Estimation estimation) async {
    if (estimation.id == null) return;
    DeleteEstimation(estimation.id!).execute();
  }

  Future<int> calculate(view_obj.Estimation estimation) async {
    return await CalculateEstimationContent(model_obj.Estimation(
      id: estimation.id,
      contentType: estimation.contentType,
      periodBegin: estimation.periodBeign,
      periodEnd: estimation.periodEnd,
    )).execute();
  }

  Future<List<view_obj.Estimation>> belongsTo(DateTime date) async {
    var estimations = await FetchEstimationForDate(date).execute();
    List<view_obj.Estimation> ret = [];
    for (var est in estimations) {
      var cats = await FetchCategoriesForEstimation(est.id!).execute();
      var catList = [
        for (var cat in cats) view_obj.Category(id: cat.id, name: cat.name)
      ];
      ret.add(view_obj.Estimation(
        id: est.id,
        contentType: est.contentType,
        periodBeign: est.periodBegin,
        periodEnd: est.periodEnd,
        targetingAllCategories: catList.isEmpty,
        targetCategories: catList,
      ));
    }
    return ret;
  }
}
