import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:sqflite/sqflite.dart';

class FetchAllCategoryIds extends SubTransactionProvider<List<int>> {
  FetchAllCategoryIds();

  @override
  process(Transaction txn) async {
    var queryResult = await txn.query(Categories().tableName, columns: ['id']);
    return queryResult.map((e) => e[CategoryFE.id.fn] as int).toList();
  }
}
