import 'package:miraibo/data_handlers/objects.dart';

import '../page/scheduling_page.dart';

class DateButtonStyleCalculator {
  DateButtonStyleCalculator._internal();

  // Singleton instance
  static final DateButtonStyleCalculator _instance =
      DateButtonStyleCalculator._internal();
  factory DateButtonStyleCalculator() => _instance;

  Future<DateButtonStyle> calcStyle(DateTime date) async {
    return DateButtonStyle.hasNothing;
  }
}

class TicketFetcher {
  TicketFetcher._internal();

  // Singleton instance
  static final TicketFetcher _instance = TicketFetcher._internal();
  factory TicketFetcher() => _instance;

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
}
