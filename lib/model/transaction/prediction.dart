import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/keyvalue_db_definition.dart';
import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model/subtransaction/expand_prediction.dart';

class RequirePrediction extends TransactionProvider {
  DateTime renderedDate;
  PredictionStatus predictionStatus = PredictionStatus();
  RequirePrediction(this.renderedDate);
  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future process(Transaction txn) async {
    var oneYearAdvanced = renderedDate.add(const Duration(days: 365));
    var twoYearsAdvanced = renderedDate.add(const Duration(days: 730));
    if ((await predictionStatus.predictedUntil()).isAfter(oneYearAdvanced)) {
      return;
    }
    await predictionStatus.setNeededUntil(twoYearsAdvanced);
    await ExpandPrediction().execute(txn);
  }
}
