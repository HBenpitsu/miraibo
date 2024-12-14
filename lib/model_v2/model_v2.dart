import 'package:miraibo/model_v2/operations/operations.dart';
import 'package:miraibo/type/view_obj.dart';
export 'package:miraibo/model_v2/worker/regular_event_dispacher.dart';
import 'package:miraibo/model_v2/worker/cache_manager.dart';

class LogModel {
  /// returns the id
  Future<int> save(Log log, {Category? originalCategory}) =>
      Operations.write.saveLog(log, originalCategory: originalCategory);
  Future<void> confirmUntil(DateTime date) =>
      Operations.write.confirmLogsUntil(date);
  Future<void> delete(Log log) => Operations.delete.deleteLog(log);
  Stream<Log> all() => Operations.fetch.allLogs();
  Stream<Log> on(DateTime date) => Operations.fetch.logsOn(date);
  Stream<Preset> presets(int limit) => Operations.fetch.presets(limit);
  Stream<Log> unconfirmed() => Operations.fetch.unconfirmedLogs();
}

class DisplayModel {
  /// returns the id
  Future<int> save(Display display) => Operations.write.saveDisplay(display);
  Future<void> delete(int id) => Operations.delete.deleteDisplay(id);
  Stream<Display> on(DateTime date) => Operations.fetch.displaysOn(date);
  Stream<Display> edgeOn(DateTime date) => Operations.fetch.displayEdgeOn(date);
  Future<double> content(Display display) =>
      Operations.summ.getDisplayContent(display);
}

class ScheduleModel {
  /// returns the id
  Future<int> save(Schedule schedule) =>
      Operations.write.saveSchedule(schedule);
  Future<void> delete(int id) => Operations.delete.deleteSchedule(id);
  Stream<Schedule> on(DateTime date) => Operations.fetch.schedulesOn(date);
}

class EstimationModel {
  /// returns the id
  Future<int> save(Estimation estimation) =>
      Operations.write.saveEstimation(estimation);
  Future<void> delete(int id) => Operations.delete.deleteEstimation(id);
  Stream<Estimation> on(DateTime date) => Operations.fetch.estimationsOn(date);
  Future<double> content(Estimation estimation) =>
      Operations.summ.getEstimationContent(estimation);
}

class CategoryModel {
  /// returns the id
  Future<int> save(Category category) =>
      Operations.write.saveCategory(category);
  Future<void> integrate(int replaceWith, int replaced) =>
      Operations.delete.integrateCategory(replaceWith, replaced);
  Stream<Category> all() => Operations.fetch.allCategories();
}

class ChartModel {
  Stream<(DateTime, double)> content(ChartQuery query) =>
      Operations.summ.getChartValues(query);
}

class CacheModel {
  static final CacheManager _manager = CacheManager();
  Future<void> notify(DateTime date) => _manager.requireCacheUntil(date);
}

abstract final class Model {
  static LogModel log = LogModel();
  static DisplayModel display = DisplayModel();
  static ScheduleModel schedule = ScheduleModel();
  static EstimationModel estimation = EstimationModel();
  static CategoryModel category = CategoryModel();
  static ChartModel chart = ChartModel();
  static CacheModel cache = CacheModel();
}
