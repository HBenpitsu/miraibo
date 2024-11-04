enum DTContentType {
  dailyAverage,
  dailyQuartileAverage,
  monthlyAverage,
  monthlyQuartileAverage,
  summation
}

enum DTTermMode {
  untilToday,
  lastPeriod,
  specificPeriod,
  untilDate;
}

enum DTPeriod {
  week,
  month,
  halfYear,
  year;
}

enum ETContentType {
  perDay,
  perWeek,
  perMonth,
  perYear,
}

enum SCRepeatType { no, interval, weekly, monthly, anually }

enum MonthlyRepeatType { fromHead, fromTail }

enum Weekday { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

enum DateButtonStyle {
  hasNothing,
  hasTrivialEvent,
  hasNotableEvent,
}
