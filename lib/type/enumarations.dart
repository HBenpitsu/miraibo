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

  static DisplayPeriod fromDays(int days) {
    if (days < 30) {
      return DisplayPeriod.week;
    } else if (days < 180) {
      return DisplayPeriod.month;
    } else if (days < 365) {
      return DisplayPeriod.halfYear;
    } else {
      return DisplayPeriod.year;
    }
  }
}

extension DisplayPeriodInDays on DisplayPeriod {
  int get inDays {
    switch (this) {
      case DisplayPeriod.week:
        return 7;
      case DisplayPeriod.month:
        return 30;
      case DisplayPeriod.halfYear:
        return 180;
      case DisplayPeriod.year:
        return 365;
    }
  }
}

enum EstimationContentType {
  perDay,
  perWeek,
  perMonth,
  perYear,
}

extension ScaleFactor on EstimationContentType {
  int get perDayScaleFactor {
    switch (this) {
      case EstimationContentType.perDay:
        return 1;
      case EstimationContentType.perWeek:
        return 7;
      case EstimationContentType.perMonth:
        return 30;
      case EstimationContentType.perYear:
        return 365;
    }
  }
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

enum ChartType {
  subtotal,
  accumulate,
}

enum ChartAxesInterval {
  day,
  week,
  month,
}

extension ChartAxesIntervalInDays on ChartAxesInterval {
  int get inDays {
    switch (this) {
      case ChartAxesInterval.day:
        return 1;
      case ChartAxesInterval.week:
        return 7;
      case ChartAxesInterval.month:
        return 30;
    }
  }
}
