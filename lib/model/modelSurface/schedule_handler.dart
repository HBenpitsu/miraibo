import 'package:miraibo/model/modelSurface/view_obj.dart' as view_obj;

class ScheduleHandler {
  Future<void> save(view_obj.Schedule schedule) async {}
  Future<void> delete(view_obj.Schedule schedule) async {}
  Future<void> isSaved(view_obj.Schedule schedule) async {}

  Future<List<view_obj.Schedule>> belongsTo(DateTime date) async {
    return [];
  }
}
