import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/model_v2/data/data.dart';
import 'package:miraibo/model_v2/operations/cache.dart';

class DeleteOperations {
  Future<void> deleteLog(view_obj.Log log) async {
    if (log.id == null) {
      return;
    }
    await rdb.transaction(() async {
      await rdb.logAccessor.deleteLog(log.id!);
      await cache.refreshEstimationCache([log.category.id!]);
    });
  }

  Future<void> deleteDisplay(int id) async {
    await rdb.displayAccessor.deleteDisplay(id);
  }

  Future<void> deleteSchedule(int id) async {
    await rdb.transaction(() async {
      await rdb.scheduleAccessor.deleteSchedule(id);
      await cache.clearRepeatCacheForSchedule(id);
    });
  }

  Future<void> deleteEstimation(int id) async {
    await rdb.transaction(() async {
      await rdb.estimationAccessor.deleteEstimation(id);
      await cache.clearRepeatCacheForEstimation(id);
    });
  }

  Future<void> integrateCategory(int replaceWith, int replaced) async {
    await rdb.categoryAccessor.integrateCategories(replaceWith, replaced);
  }
}

final delete = DeleteOperations();
