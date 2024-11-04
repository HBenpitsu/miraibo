import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/model/infra/keyvalue_db_definition.dart';
import 'package:miraibo/model/subtransaction/insert_predictions.dart';
import 'package:miraibo/model/subtransaction/estimations.dart';
import 'package:miraibo/model/subtransaction/schedules.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model/subtransaction/expand_prediction.dart';

class TentativeExpand extends TransactionProvider {
  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future process(Transaction txn) async {
    await PredictionStatus().setNeededUntil(today().add(Duration(days: 365)));
    await ExpandPrediction().execute(txn);
  }
}
