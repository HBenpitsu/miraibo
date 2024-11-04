import 'package:miraibo/model/modelSurface/view_obj.dart' as view_obj;

class DisplayHandler {
  Future<void> save(view_obj.DisplayTicket dt) async {}
  Future<void> delete(view_obj.DisplayTicket dt) async {}
  Future<void> isSaved(view_obj.DisplayTicket dt) async {}
  Future<int> calculate(view_obj.DisplayTicket dt) async {
    return 0;
  }

  Future<List<view_obj.DisplayTicket>> belongsTo(DateTime date) async {
    return [];
  }
}
