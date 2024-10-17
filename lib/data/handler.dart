import 'package:miraibo/data/objects.dart';

import '../page/scheduling_page.dart';

/* 
This fetches lists of ticket config data.
*/
class TicketDataManager {
  TicketDataManager._internal();

  // Singleton instance
  static final TicketDataManager _instance = TicketDataManager._internal();
  factory TicketDataManager() => _instance;

  /*
  This is called by TicketContainer of DailyScreen in scheduling_page.
  This returns the list of tickets that belong to the given date.
  */
  Future<List<TicketConfigData>> fetchTicketConfigsFor(DateTime date) async {
    return [];
  }

  /*
  This is called by TicketContainer of TicketPage.
  Notable tickets are followings:
  - Display Tickets
  - Schedule Tickets whose schedule is today or before today
  - Recent Log Tickets
  */
  Future<List<TicketConfigData>> fetchNotableTicketConfigs() async {
    return [];
  }

  /* This method is invoked by `LogTicketConfigSectionWithPreset`.
  
  Its primary purpose is to fetch and return a list of `preset`s for log tickets.
  The number of presets to be fetched is specified by `nPresets`.
  
  `Preset`s are instances of `LogTicketConfigData`. When a preset is applied to a `logTicketConfigData`,
  certain necessary fields are copied from the preset, while other fields are ignored.
  The functionality for applying presets is implemented in `objects.dart` within the `LogTicketConfigData` class.
  */ 
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
  The style of a date button (on monthly_calendar in monthly_screen in scheduling_page) varies 
  depending on existance of tickets that belong to the date.
  This method calculates the style of the date button for the given date consulting the data store.
  */
  Future<DateButtonStyle> calcStyleForDateButton(DateTime date) async {
    return DateButtonStyle.hasNothing;
  }
}

/*
Consulting multiple data sources, this class calculate the number to be displayed.
*/
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
