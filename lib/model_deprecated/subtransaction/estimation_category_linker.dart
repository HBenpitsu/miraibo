import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model_deprecated/subtransaction/category.dart';

class FetchLinkedCategoryIdsForEstimation
    extends SubTransactionProvider<List<int>> {
  final int estimationId;
  FetchLinkedCategoryIdsForEstimation(this.estimationId);
  FetchAllCategoryIds allCategoryIds = FetchAllCategoryIds();

  @override
  process(Transaction txn) async {
    var linkedIds = await this.linkedIds(txn);
    if (linkedIds.isEmpty) {
      return await allCategoryIds.execute(txn);
    } else {
      return linkedIds;
    }
  }

  Future<List<int>> linkedIds(Transaction txn) async {
    var queryResult = await txn.query(EtCatLinker().tableName,
        columns: ['category_id'],
        distinct: true,
        where: '${EtCatLinkerFE.estimation} = ?',
        whereArgs: [estimationId]);
    return queryResult.map((e) => e[EtCatLinkerFE.category.fn] as int).toList();
  }
}
