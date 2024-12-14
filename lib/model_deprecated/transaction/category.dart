import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';

class SaveCategory extends TransactionProvider<int> {
  final Category category;
  SaveCategory(this.category);

  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<int> process(Transaction txn) async {
    if (category.id == null) {
      return await txn.insert(Categories().tableName, category.serialize());
    } else {
      await txn.update(Categories().tableName, category.serialize(),
          where: '${CategoryFE.id.fn} = ?', whereArgs: [category.id]);
      return category.id!;
    }
  }
}

class ReplaceCategory extends TransactionProvider<void> {
  final Category replaced;
  final Category replaceWith;
  ReplaceCategory(this.replaced, this.replaceWith);

  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<void> process(Transaction txn) async {
    await replaceRelatedCategories(txn);
    await deleteCategory(txn);
  }

  Future<void> replaceRelatedCategories(Transaction txn) {
    return Future.wait([
      txn.update(
          DtCatLinker().tableName, {DtCatLinkerFE.category.fn: replaceWith.id},
          where: '${DtCatLinkerFE.category.fn} = ?', whereArgs: [replaced.id]),
      txn.update(
          EtCatLinker().tableName, {EtCatLinkerFE.category.fn: replaceWith.id},
          where: '${EtCatLinkerFE.category.fn} = ?', whereArgs: [replaced.id]),
      txn.update(
          Schedules().tableName, {ScheduleFE.category.fn: replaceWith.id},
          where: '${ScheduleFE.category.fn} = ?', whereArgs: [replaced.id]),
      txn.update(Logs().tableName, {LogFE.category.fn: replaceWith.id},
          where: '${LogFE.category.fn} = ?', whereArgs: [replaced.id]),
      txn.update(
          Predictions().tableName, {PredictionFE.category.fn: replaceWith.id},
          where: '${PredictionFE.category.fn} = ?', whereArgs: [replaced.id]),
    ]);
  }

  Future<void> deleteCategory(Transaction txn) async {
    await txn.delete(
      Categories().tableName,
      where: '${CategoryFE.id.fn} = ?',
      whereArgs: [replaced.id],
    );
  }
}

class FetchAllCategories extends TransactionProvider<List<Category>> {
  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<List<Category>> process(Transaction txn) async {
    var queryResult = await txn.query(Categories().tableName);
    return queryResult.map((e) => Category.interpret(e)).toList();
  }
}

class FetchFirstCategory extends TransactionProvider<Category> {
  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<Category> process(Transaction txn) async {
    // If the database is prepared, there should be at least one category.
    var queryResult = await txn.query(Categories().tableName, limit: 1);
    return Category.interpret(queryResult.first);
  }
}

class FindCategory extends TransactionProvider<Category> {
  final int id;
  FindCategory(this.id);

  @override
  get dbProvider => MainDatabaseProvider();

  @override
  Future<Category> process(Transaction txn) async {
    var queryResult = await txn.query(Categories().tableName,
        where: '${CategoryFE.id.fn} = ?', whereArgs: [id]);
    return Category.interpret(queryResult.first);
  }
}
