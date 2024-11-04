import 'package:flutter_test/flutter_test.dart';
import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/transactions/initialize_database.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';

void main() {
  test('initialize', () async {
    RelationalDatabaseProvider dbProvider = MainDatabaseProvider();
    InitMainDatabase initializer = InitMainDatabase();
    await initializer.execute();
    await dbProvider.db.transaction((txn) async {
      var queryResult =
          await txn.query(Categories().tableName, columns: ['COUNT (*)']);
      expect(queryResult.first.values.first, initialCategories.length);
    });
  });
}
