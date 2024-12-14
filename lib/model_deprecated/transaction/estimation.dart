import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';
import 'package:sqflite/sqflite.dart';

class SaveEstimation extends TransactionProvider<void> {
  final Estimation estimation;
  final List<Category> categories;

  SaveEstimation(this.estimation, this.categories);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    if (estimation.id == null) {
      estimation.id =
          await txn.insert(Estimations().tableName, estimation.serialize());
    } else {
      await txn.delete(EtCatLinker().tableName,
          where: '${EtCatLinkerFE.estimation.fn} = ?',
          whereArgs: [estimation.id]);
      await txn.update(Estimations().tableName, estimation.serialize(),
          where: '${EstimationFE.id.fn} = ?', whereArgs: [estimation.id]);
    }
    List<String> linkerValues = [];
    for (var category in categories) {
      linkerValues.add('(${estimation.id}, ${category.id})');
    }
    if (linkerValues.isNotEmpty) {
      await txn.rawInsert('INSERT INTO ${EtCatLinker().tableName} ('
          '${EtCatLinkerFE.estimation.fn}, ${EtCatLinkerFE.category.fn}'
          ') VALUES ${linkerValues.join(', ')};');
    }
  }
}

class DeleteEstimation extends TransactionProvider<void> {
  final int estimationId;

  DeleteEstimation(this.estimationId);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    await txn.delete(Estimations().tableName,
        where: '${EstimationFE.id.fn} = ?', whereArgs: [estimationId]);
    await txn.delete(EtCatLinker().tableName,
        where: '${EtCatLinkerFE.estimation.fn} = ?', whereArgs: [estimationId]);
  }
}

class FetchEstimationForDate extends TransactionProvider<List<Estimation>> {
  final DateTime date;

  FetchEstimationForDate(this.date);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<List<Estimation>> process(Transaction txn) async {
    var queryResult = await txn.query(Estimations().tableName,
        where: '('
            ' ${EstimationFE.periodBegin.fn} IS NULL'
            ' OR'
            ' ${EstimationFE.periodBegin.fn} <= ${EstimationFE.periodBegin.serialize(date)}'
            ') AND ('
            ' ${EstimationFE.periodEnd.fn} IS NULL'
            ' OR'
            ' ${EstimationFE.periodEnd.serialize(date)} <= ${EstimationFE.periodEnd.fn}'
            ')');
    return queryResult.map((e) => Estimation.interpret(e)).toList();
  }
}

class FetchCategoriesForEstimation extends TransactionProvider<List<Category>> {
  final int estimationId;

  FetchCategoriesForEstimation(this.estimationId);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<List<Category>> process(Transaction txn) async {
    var queryResult = await txn.query(EtCatLinker().tableName,
        where: '${EtCatLinkerFE.estimation.fn} = ?', whereArgs: [estimationId]);
    var categoryIds =
        queryResult.map((e) => e[EtCatLinkerFE.category.fn] as int).toList();
    var categories = <Category>[];
    for (var categoryId in categoryIds) {
      var queryResult = await txn.query(Categories().tableName,
          where: '${CategoryFE.id.fn} = ?', whereArgs: [categoryId]);
      categories.add(Category.interpret(queryResult.first));
    }
    return categories;
  }
}

class CalculateEstimationContent extends TransactionProvider<int> {
  final Estimation estimation;

  CalculateEstimationContent(this.estimation);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<int> process(Transaction txn) async {
    // TODO: implement
    return 0;
  }
}
