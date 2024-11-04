import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/model/infra/table_components.dart';
import 'package:sqflite/sqflite.dart';

class ClearEstimatedPrediction extends SubTransactionProvider<void> {
  final int estimationId;
  ClearEstimatedPrediction(this.estimationId);

  @override
  process(Transaction txn) async {
    await txn.delete(Predictions().tableName,
        where: '${PredictionFE.estimation.fn} = ?', whereArgs: [estimationId]);
  }
}

class ClearScheduledPrediction extends SubTransactionProvider<void> {
  final int scheduleId;
  ClearScheduledPrediction(this.scheduleId);

  @override
  process(Transaction txn) async {
    await txn.delete(Predictions().tableName,
        where: '${PredictionFE.schedule.fn} = ?', whereArgs: [scheduleId]);
  }
}
