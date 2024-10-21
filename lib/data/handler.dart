import 'package:miraibo/data/categoryConfig.dart';

import '../page/scheduling_page.dart';
import './repository.dart';

class TicketDataManager {
  TicketDataManager._internal();

  // Singleton instance
  static final TicketDataManager _instance = TicketDataManager._internal();
  factory TicketDataManager() => _instance;

  /// Returns ticket configs for the given [date].
  Future<List<TicketConfigData>> fetchTicketConfigsFor(DateTime date) async {
    return [];
  }

  Future<List<TicketConfigData>> fetchNotableTicketConfigs() async {
    return [];
  }

  Future<List<LogTicketConfigData>> fetchLogTicketPresets(int nPresets) async {
    return List.generate(
        nPresets,
        (index) => LogTicketConfigData(
            category: Category.make('preset $index'),
            supplement: 'preset $index',
            registorationDate: DateTime.now(),
            amount: 1000,
            image: null,
            isImageAttached: false));
  }

  /* 
  The style of a date button (on monthly_calendar in monthly_screen in scheduling_page) varies depending on existance of tickets that belong to the date.
  This method calculates the style of the date button for the given date consulting the data store.
  */
  Future<DateButtonStyle> calcStyleForDateButton(DateTime date) async {
    return DateButtonStyle.hasNothing;
  }
}

class StatisticalAnalyzer {
  StatisticalAnalyzer._internal();

  // Singleton instance
  static final StatisticalAnalyzer _instance = StatisticalAnalyzer._internal();
  factory StatisticalAnalyzer() => _instance;

  Future<int> calcValueForDisplayTicket(DisplayTicketConfigData data) async {
    return 0;
  }

  Future<int> calcValueForEstimationTicket(
      EstimationTicketConfigData data) async {
    return 0;
  }
}
