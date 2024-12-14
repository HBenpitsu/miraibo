import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';
import 'package:sqflite/sqflite.dart';

class SaveDisplayTicket extends TransactionProvider {
  final DisplayTicket displayTicket;
  final List<Category> categories;

  SaveDisplayTicket(this.displayTicket, this.categories);

  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future process(Transaction txn) async {
    if (displayTicket.id == null) {
      displayTicket.id = await txn.insert(
          DisplayTickets().tableName, displayTicket.serialize());
    } else {
      await txn.delete(DtCatLinker().tableName,
          where: '${DtCatLinkerFE.display.fn} = ?',
          whereArgs: [displayTicket.id]);
      await txn.update(DtCatLinker().tableName, displayTicket.serialize(),
          where: '${DisplayTicketFE.id.fn} = ?', whereArgs: [displayTicket.id]);
    }
    List<String> linkerValues = [];
    for (var category in categories) {
      linkerValues.add('(${displayTicket.id}, ${category.id})');
    }
    if (linkerValues.isNotEmpty) {
      await txn.rawInsert('INSERT INTO ${DtCatLinker().tableName} ('
          '${DtCatLinkerFE.display.fn}, ${DtCatLinkerFE.category.fn}'
          ') VALUES ${linkerValues.join(', ')};');
    }
  }
}

class DeleteDisplayTicket extends TransactionProvider {
  int displayTicketId;
  DeleteDisplayTicket(this.displayTicketId);
  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future process(Transaction txn) async {
    await txn.delete(DtCatLinker().tableName,
        where: '${DtCatLinkerFE.display.fn} = ?', whereArgs: [displayTicketId]);
    await txn.delete(DisplayTickets().tableName,
        where: '${DisplayTicketFE.id.fn} = ?', whereArgs: [displayTicketId]);
  }
}

class CalculateDisplayTicketContent extends TransactionProvider<int> {
  DisplayTicket displayTicket;
  CalculateDisplayTicketContent(this.displayTicket);
  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future<int> process(Transaction txn) async {
    // TODO: implement
    return 0;
  }
}

class FetchDisplayTicketsBelongsTo
    extends TransactionProvider<List<DisplayTicket>> {
  DateTime date;
  FetchDisplayTicketsBelongsTo(this.date);
  @override
  get dbProvider => MainDatabaseProvider();
  @override
  Future<List<DisplayTicket>> process(Transaction txn) async {
    var queryResult = await txn.query(DisplayTickets().tableName,
        where: '('
            ' ${DisplayTicketFE.periodBegin.fn} IS NULL'
            ' OR'
            ' ${DisplayTicketFE.periodBegin.fn} <= ${DisplayTicketFE.periodBegin.serialize(date)}'
            ') AND ('
            ' ${DisplayTicketFE.periodEnd.fn} IS NULL'
            ' OR'
            ' ${DisplayTicketFE.periodEnd.serialize(date)} <= ${DisplayTicketFE.periodEnd.fn}'
            ')');
    return queryResult.map((e) => DisplayTicket.interpret(e)).toList();
  }
}

class FetchCategoriesForDisplayTicket
    extends TransactionProvider<List<Category>> {
  final int displayTicketId;

  FetchCategoriesForDisplayTicket(this.displayTicketId);

  @override
  RelationalDatabaseProvider get dbProvider => MainDatabaseProvider();

  @override
  Future<List<Category>> process(Transaction txn) async {
    var queryResult = await txn.query(DtCatLinker().tableName,
        where: '${DtCatLinkerFE.display.fn} = ?', whereArgs: [displayTicketId]);
    var categoryIds =
        queryResult.map((e) => e[DtCatLinkerFE.category.fn] as int).toList();
    var categories = <Category>[];
    for (var categoryId in categoryIds) {
      var queryResult = await txn.query(Categories().tableName,
          where: '${CategoryFE.id.fn} = ?', whereArgs: [categoryId]);
      categories.add(Category.interpret(queryResult.first));
    }
    return categories;
  }
}
