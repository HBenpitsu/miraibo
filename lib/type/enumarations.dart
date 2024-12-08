enum DisplayContentType {
  dailyAverage,
  dailyQuartileAverage,
  monthlyAverage,
  monthlyQuartileAverage,
  summation
}

enum DisplayTermMode {
  untilToday,
  lastPeriod,
  specificPeriod,
  untilDate;
}

enum DisplayPeriod {
  week,
  month,
  halfYear,
  year;
}

enum EstimationContentType {
  perDay,
  perWeek,
  perMonth,
  perYear,
}

enum ScheduleRepeatType { no, interval, weekly, monthly, anually }

enum MonthlyRepeatType { fromHead, fromTail }

enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

extension WeekdayExtension on Weekday {
  static const List<String> _weekdayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];
  String get shortString => _weekdayNames[index];
  int get number => index + 1;
}

enum DateButtonStyle {
  hasNothing,
  hasTrivialEvent,
  hasNotableEvent,
}
