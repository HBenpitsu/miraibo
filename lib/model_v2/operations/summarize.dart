import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/model_v2/data/data.dart';
import 'package:miraibo/util/date_time.dart';

class Analyzer {
  final DateTime? periodBegin;
  final DateTime? periodEnd;
  final Iterable<int>? categories;
  late Stream<(DateTime, double)> recordStream;

  /// Watch out not to pass phantom categories
  Analyzer(this.periodBegin, this.periodEnd, this.categories) {
    // if id is null, it will throw an error
    recordStream = rdb.recordCollector
        .collect(periodBegin, periodEnd, categories)
        .asBroadcastStream();
  }

  void refresh() {
    // re-assign stream
    recordStream = rdb.recordCollector
        .collect(periodBegin, periodEnd, categories)
        .asBroadcastStream();
  }

  Future<List<(DateTime, double)>> get recordList {
    return recordStream.toList();
  }

  /// return mean per day
  Future<double> get mean async {
    // validate
    if (periodBegin == null || periodEnd == null) {
      throw Exception('mean cannot be calculated without period');
    }
    // calculate
    var total = await sum;
    var days = periodEnd!.difference(periodBegin!).inDays;

    return total / days;
  }

  /// return quartile range mean per day. quartile range mean is calculated by excluding the lowest and highest 25% of the data.
  Future<double> get quartileRangeMean async {
    // validate
    if (periodBegin == null || periodEnd == null) {
      throw Exception('quartileRangeMean cannot be calculated without period');
    }
    // calculate
    var subTotal = await subtotal.toList();

    if (subTotal.length < 4) {
      return mean;
    }

    subTotal.sort((a, b) => a.$2.compareTo(b.$2));
    var total = 0.0;
    var cutoff = subTotal.length ~/ 4;
    for (var i = cutoff; i < subTotal.length - cutoff; i++) {
      total += subTotal[i].$2;
    }

    return total / (subTotal.length - 2 * cutoff);
  }

  Future<double> get sum async {
    // calculate
    var total = 0.0;
    await for (var record in recordStream) {
      total += record.$2;
    }

    return total;
  }

  Stream<(DateTime, double)> get subtotal async* {
    // validate
    if (periodBegin == null || periodEnd == null) {
      throw Exception('subtotal cannot be calculated without period');
    }
    // calculate
    Map<DateTime, double> buf = {};
    await for (var record in recordStream) {
      buf[record.$1] ??= 0;
      buf[record.$1] = buf[record.$1]! + record.$2;
    }

    for (var date in DateTimeSequence.daily(periodBegin!, periodEnd!)) {
      yield (date, buf[date] ?? 0);
    }
  }

  Stream<(DateTime, double)> get accumulate async* {
    var total = 0.0;
    await for (var record in subtotal) {
      total += record.$2;
      yield (record.$1, total);
    }
  }
  // </statistics caluclation>
}

class SummarizingOperations {
  Stream<(DateTime, double)> getChartValues(view_obj.ChartQuery query) async* {
    var analyzer = Analyzer(
        query.periodBegin, query.periodEnd, query.categories.map((e) => e.id!));
    switch (query.chartType) {
      case ChartType.subtotal:
        // sum up subtotals for each interval
        int count = 0;
        double sum = 0;
        DateTime? label;
        await for (var rec in analyzer.subtotal) {
          label ??= rec.$1;
          sum += rec.$2;
          count++;
          if (count >= query.axesInterval.inDays) {
            yield (label, sum);
            count = 0;
            sum = 0;
            label = null;
          }
        }
        break;
      case ChartType.accumulate:
        // return accumulated values for each interval
        int count = 0;
        await for (var rec in analyzer.subtotal) {
          if (count % query.axesInterval.inDays == 0) {
            yield (rec.$1, rec.$2);
          }
          count++;
        }
        break;
    }
  }

  Future<double> getDisplayContent(view_obj.Display display) async {
    DateTime? periodBegin;
    DateTime? periodEnd;

    switch (display.termMode) {
      case DisplayTermMode.specificPeriod:
        periodBegin = display.periodBegin;
        periodEnd = display.periodEnd;
        break;
      case DisplayTermMode.lastPeriod:
        periodBegin =
            today().subtract(Duration(days: display.displayPeriod.inDays));
        periodEnd = today();
        break;
      case DisplayTermMode.untilDate:
        periodEnd = display.periodEnd;
        break;
      case DisplayTermMode.untilToday:
        periodEnd = today();
        break;
    }

    var analyzer = Analyzer(
        periodBegin, periodEnd, display.targetCategories.map((e) => e.id!));

    switch (display.contentType) {
      case DisplayContentType.dailyAverage:
        return analyzer.mean;
      case DisplayContentType.dailyQuartileAverage:
        return analyzer.quartileRangeMean;
      case DisplayContentType.monthlyAverage:
        return (await analyzer.mean) * 30;
      case DisplayContentType.monthlyQuartileAverage:
        return (await analyzer.quartileRangeMean) * 30;
      case DisplayContentType.summation:
        return analyzer.sum;
    }
  }

  Future<double> getEstimationContent(view_obj.Estimation est) async {
    if (est.targetingAllCategories) {
      var perDay = await rdb.estimationContent.getSumOfCachedValues([]);
      return perDay * est.contentType.perDayScaleFactor;
    } else {
      var perDay = await rdb.estimationContent
          .getSumOfCachedValues(est.targetCategories.map((e) => e.id!));
      return perDay * est.contentType.perDayScaleFactor;
    }
  }

  Future<double> estimateFor(int categoryId) async {
    var analyzer = Analyzer(
        today().subtract(const Duration(days: 30)), today(), [categoryId]);
    return analyzer.quartileRangeMean;
  }
}

final summ = SummarizingOperations();
