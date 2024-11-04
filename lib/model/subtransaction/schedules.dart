import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/type/model_obj.dart';
import 'package:sqflite/sqflite.dart';

class FetchAllSchedules extends SubTransactionProvider<List<Schedule>> {
  FetchAllSchedules();

  @override
  process(Transaction txn) async {
    var queryResult = await txn.query(Schedules().tableName);
    return queryResult.map((e) => Schedule.interpret(e)).toList();
  }
}
