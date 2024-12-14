import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:sqflite/sqflite.dart';

mixin InPeriodClause<T> on SubTransactionProvider<T> {
  DateTime? get rangeBegin;
  DateTime? get rangeEnd;
  int? get categoryId;

  String inPeriod() {
    var conditions = <String>[];
    if (categoryId != null) {
      conditions.add('${LogFE.category.fn} = $categoryId');
    }
    if (rangeBegin != null) {
      conditions
          .add('${LogFE.date.fn} >= ${LogFE.date.serialize(rangeBegin!)}');
    }
    if (rangeEnd != null) {
      conditions.add('${LogFE.date.fn} <= ${LogFE.date.serialize(rangeEnd!)}');
    }
    return conditions.join(' AND ');
  }
}

class SumUpLoggedAmountBetween extends SubTransactionProvider<double>
    with InPeriodClause {
  @override
  final DateTime? rangeBegin;
  @override
  final DateTime? rangeEnd;
  @override
  final int? categoryId;
  SumUpLoggedAmountBetween(this.categoryId, this.rangeBegin, this.rangeEnd);

  @override
  process(Transaction txn) async {
    var queryResult = await txn.query(Logs().tableName,
        columns: ['SUM(${LogFE.amount.fn})'], where: inPeriod());
    return queryResult.first.values.first as double;
  }
}

class AverageLoggedAmountBetween extends SubTransactionProvider<double>
    with InPeriodClause {
  @override
  final DateTime? rangeBegin;
  @override
  final DateTime? rangeEnd;
  @override
  final int? categoryId;
  AverageLoggedAmountBetween(this.categoryId, this.rangeBegin, this.rangeEnd);

  @override
  process(Transaction txn) async {
    var queryResult = await txn.query(Logs().tableName,
        columns: ['AVG(${LogFE.amount.fn})'], where: inPeriod());
    return queryResult.first.values.first as double;
  }
}

class QuartileRangeAverageLoggedAmountBetween
    extends SubTransactionProvider<double> with InPeriodClause {
  @override
  final DateTime? rangeBegin;
  @override
  final DateTime? rangeEnd;
  @override
  final int? categoryId;
  QuartileRangeAverageLoggedAmountBetween(
      this.categoryId, this.rangeBegin, this.rangeEnd);

  @override
  process(Transaction txn) async {
    var count = await recordCount(txn);
    if (count == 0) {
      return 0.0;
    } else if (count < 4) {
      var queryResult = await txn.query(Logs().tableName,
          columns: ['AVG(${LogFE.amount.fn})'], where: inPeriod());
      return queryResult.first.values.first as double;
    } else {
      var queryResult = await txn.query(Logs().tableName,
          columns: ['AVG(${LogFE.amount.fn})'],
          where: inPeriod(),
          orderBy: '${LogFE.amount.fn} ASC',
          offset: count ~/ 4,
          limit: count ~/ 2);
      return queryResult.first.values.first as double;
    }
  }

  Future<int> recordCount(Transaction txn) async {
    var queryResult = await txn.query(Logs().tableName,
        columns: ['COUNT(*)'], where: inPeriod());
    return queryResult.first.values.first as int;
  }
}
