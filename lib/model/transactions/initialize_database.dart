import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model/infra/persistent_db_table_definitions.dart';
import 'package:miraibo/model/infra/database_provider.dart';
import 'package:miraibo/model/infra/table_components.dart';

const initialCategories = [
  'Food',
  'Gas',
  'Water',
  'Electricity',
  'Transportation',
  'EducationFee',
  'EducationMaterials',
  'Medication',
  'Amusument',
  'Furniture',
  'Necessities',
  'OtherExpense',
  'Scholarship',
  'Payment',
  'OtherIncome',
  'Ajustment',
];

class InitPersistentDatabase extends TransactionProvider {
  @override
  get dbProvider => PersistentDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    await createTables(txn);
    await initializeCategories(txn);
  }

  Future<void> createTables(Transaction txn) {
    return Future.wait([
      txn.execute(Categories().createString),
      txn.execute(DisplayTickets().createString),
      txn.execute(Schedules().createString),
      txn.execute(Estimations().createString),
      txn.execute(Logs().createString),
    ]);
  }

  Future<void> initializeCategories(Transaction txn) async {
    var queryResult =
        await txn.query(Categories().tableName, columns: ['COUNT (*)']);
    if (queryResult.first.values.first == 0) {
      await txn.rawInsert('''
          INSERT INTO ${Categories().tableName} (${CategoryFE.name.fn}) VALUES (${initialCategories.map((e) => '"$e"').join('), (')})
          ''');
    }
  }
}
