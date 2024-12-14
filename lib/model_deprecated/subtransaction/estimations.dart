import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/type/model_obj.dart.deprecated';
import 'package:miraibo/model_deprecated/infra/main_db_table_definitions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:miraibo/model_deprecated/subtransaction/log_statistics_between.dart';

class FetchAllEstimations extends SubTransactionProvider<List<Estimation>> {
  FetchAllEstimations();

  @override
  process(Transaction txn) async {
    var queryResult = await txn.query(Estimations().tableName);
    return queryResult.map((e) => Estimation.interpret(e)).toList();
  }
}

class EstimateAmountFor extends SubTransactionProvider<double> {
  final int? categoryId;
  EstimateAmountFor(this.categoryId);
  late QuartileRangeAverageLoggedAmountBetween average;

  @override
  process(Transaction txn) {
    // take quartile range average in all period for this category.
    average = QuartileRangeAverageLoggedAmountBetween(categoryId, null, null);
    return average.execute(txn);
  }
}
