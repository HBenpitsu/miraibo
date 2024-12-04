import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/model/infra/table_components.dart';
import 'package:miraibo/type/model_obj.dart';
import 'package:sqflite/sqflite.dart';

class SaveLog extends TransactionProvider<void> {
  final Log log;
  SaveLog(this.log);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();
  @override
  Future<void> process(Transaction txn) async {
    if (log.id == null) {
      await txn.insert(Logs().tableName, log.serialize());
    } else {
      await txn.update(Logs().tableName, log.serialize(),
          where: '${LogFE.id.fn} = ?', whereArgs: [log.id]);
    }
  }
}

class DeleteLog extends TransactionProvider<void> {
  final int LogId;
  DeleteLog(this.LogId);
  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();
  @override
  Future<void> process(Transaction txn) {
    return txn.delete(Logs().tableName,
        where: '${LogFE.id.fn} = ?', whereArgs: [LogId]);
  }
}

class FetchLogsBelongTo extends TransactionProvider<List<Log>> {
  final DateTime date;
  FetchLogsBelongTo(this.date);
  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();
  @override
  Future<List<Log>> process(Transaction txn) async {
    var result = await txn.query(Logs().tableName,
        where: '${LogFE.date.fn} = ?', whereArgs: [LogFE.date.serialize(date)]);
    return result.map((e) => Log.interpret(e)).toList();
  }
}
