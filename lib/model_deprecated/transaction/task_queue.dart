import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/queue_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:sqflite/sqflite.dart';

class AddTask extends TransactionProvider<int> {
  Future<void> Function() task;
  AddTask(this.task);

  @override
  get dbProvider => QueueDatabaseProvider();

  @override
  Future<int> process(Transaction txn) {
    return txn.insert(PredictionTasks().tableName, {
      PredictionTaskFE.createdAt.fn:
          PredictionTaskFE.createdAt.serialize(DateTime.now())
    });
  }
}

class IsTaskExists extends TransactionProvider<bool> {
  @override
  get dbProvider => QueueDatabaseProvider();

  @override
  Future<bool> process(Transaction txn) async {
    var queryResult =
        await txn.query(PredictionTasks().tableName, columns: ['COUNT (*)']);
    return queryResult.isNotEmpty;
  }
}
