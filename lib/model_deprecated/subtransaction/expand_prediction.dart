import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';
import 'package:miraibo/model_deprecated/infra/keyvalue_db_definition.dart';
import 'package:miraibo/model_deprecated/subtransaction/insert_predictions.dart';
import 'package:miraibo/model_deprecated/subtransaction/estimations.dart';
import 'package:miraibo/model_deprecated/subtransaction/schedules.dart';
import 'package:sqflite/sqflite.dart';

class ExpandPrediction extends SubTransactionProvider<void> {
  late FetchAllEstimations fetchAllEstimations;
  late List<Estimation> estimations;
  late FetchAllSchedules fetchAllSchedules;
  late List<Schedule> schedules;
  late DateTime rangeBegin;
  late DateTime rangeEnd;
  late DateTime neededUntil;
  late DateTime predictedUntil;
  PredictionStatus status = PredictionStatus();

  Future<bool> expansionIsNeeded() async {
    var [needed, predicted, predicting] = await Future.wait([
      status.neededUntil(),
      status.predictedUntil(),
      status.predictingUntil()
    ]);
    neededUntil = needed;
    predictedUntil = predicted;
    if (predicted.isAtSameMomentAs(predicting)) {
      // if we are predicting right now, we should not touch it.
      return false;
    } else if (needed.isAfter(predicted)) {
      // if we are out of date, we should predict.
      return true;
    } else {
      return false;
    }
  }

  Future<void> prepare() async {
    fetchAllEstimations = FetchAllEstimations();
    fetchAllSchedules = FetchAllSchedules();

    // make it ovious that we are predicting right now
    await status.setPredictingUntil(neededUntil);

    rangeBegin = predictedUntil.add(Duration(days: 1));
    rangeEnd = neededUntil;
  }

  Future<void> completed() async {
    await status.setPredictedUntil(rangeEnd);
  }

  @override
  Future<void> process(Transaction txn) async {
    if (!await expansionIsNeeded()) return;
    await prepare();
    await getAllPredictSource(txn);
    await Future.wait([
      for (var estimation in estimations)
        InsertEstimatedPredictions(estimation, rangeBegin, rangeEnd)
            .execute(txn),
      for (var schedule in schedules)
        InsertScheduledPredictions(schedule, rangeBegin, rangeEnd).execute(txn),
    ]);
  }

  Future<void> getAllPredictSource(Transaction txn) async {
    var [res1, res2] = await Future.wait(
        [fetchAllEstimations.execute(txn), fetchAllSchedules.execute(txn)]);
    estimations = res1 as List<Estimation>;
    schedules = res2 as List<Schedule>;
  }
}
