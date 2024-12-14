import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';
import 'package:miraibo/model_deprecated/infra/keyvalue_db_definition.dart';
import 'package:miraibo/model_deprecated/subtransaction/insert_predictions.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:sqflite/sqflite.dart';

class NewScheduledPrediction extends SubTransactionProvider<void> {
  final Schedule schedule;
  late DateTime rangeBegin;
  late DateTime rangeEnd;
  NewScheduledPrediction(this.schedule);
  late InsertScheduledPredictions insertScheduledPredictions;
  PredictionStatus status = PredictionStatus();

  @override
  Future<void> process(Transaction txn) async {
    await prepare();
    await insertScheduledPredictions.execute(txn);
  }

  Future<void> prepare() async {
    rangeBegin = today();
    rangeEnd = await status.predictedUntil();
    insertScheduledPredictions = InsertScheduledPredictions(
      schedule,
      rangeBegin,
      rangeEnd,
    );
  }
}

class NewEstimatedPrediction extends SubTransactionProvider<void> {
  final Estimation estimation;
  late DateTime rangeBegin;
  late DateTime rangeEnd;
  NewEstimatedPrediction(this.estimation);
  late InsertEstimatedPredictions insertEstimatedPredictions;
  PredictionStatus status = PredictionStatus();

  @override
  Future<void> process(Transaction txn) async {
    await prepare();
    await insertEstimatedPredictions.execute(txn);
  }

  Future<void> prepare() async {
    rangeBegin = today();
    rangeEnd = await status.predictedUntil();
    insertEstimatedPredictions = InsertEstimatedPredictions(
      estimation,
      rangeBegin,
      rangeEnd,
    );
  }
}
