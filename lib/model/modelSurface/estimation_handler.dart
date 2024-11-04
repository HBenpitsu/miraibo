import 'package:miraibo/model/modelSurface/view_obj.dart' as view_obj;

class EstimationHandler {
  Future<void> save(view_obj.Estimation estimation) async {}
  Future<void> delete(view_obj.Estimation estimation) async {}
  Future<void> isSaved(view_obj.Estimation estimation) async {}
  Future<int> calculate(view_obj.Estimation estimation) async {
    return 0;
  }

  Future<List<view_obj.Estimation>> belongsTo(DateTime date) async {
    return [];
  }
}
