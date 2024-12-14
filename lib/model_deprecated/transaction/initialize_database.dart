import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/queue_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';

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

class InitMainDatabase extends TransactionProvider {
  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    await createTables(txn);
    await initializeCategories(txn);
  }

  Future<void> createTables(Transaction txn) {
    return Future.wait([
      txn.execute(Categories().createString),
      txn.execute(DisplayTickets().createString),
      txn.execute(DtCatLinker().createString),
      txn.execute(Schedules().createString),
      txn.execute(Estimations().createString),
      txn.execute(EtCatLinker().createString),
      txn.execute(Logs().createString),
      txn.execute(Predictions().createString),
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

class InitQueueDatabase extends TransactionProvider {
  @override
  get dbProvider => QueueDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    await createTables(txn);
  }

  Future<void> createTables(Transaction txn) {
    return Future.wait([
      txn.execute(PredictionTasks().createString),
    ]);
  }
}
