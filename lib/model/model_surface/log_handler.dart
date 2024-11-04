import 'package:miraibo/type/view_obj.dart' as view_obj;

class LogHandler {
  Future<void> save(view_obj.Log log) async {}
  Future<void> delete(view_obj.Log log) async {}
  Future<List<view_obj.Log>> belongsTo(DateTime date) async {
    return [];
  }
}
