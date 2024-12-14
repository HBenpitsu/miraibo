import 'package:miraibo/type/enumarations.dart';

/// Returns a new [DateTime] object with the same year, month, and day as [date].
/// The time fields are set to 0.
DateTime datize(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime today() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime tomorrow() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1);
}

DateTime farPast() {
  return DateTime(2000);
}

// abstract final == group of functions
abstract final class DateTimeSequence {
  static Iterable<DateTime> daily(DateTime from, DateTime to) sync* {
    for (var current = from; // includes `from`
        !current.isAfter(to); // includes `to`
        current = current.add(Duration(days: 1))) {
      yield current;
    }
  }

  static Iterable<DateTime> withInterval(
      DateTime from, DateTime to, DateTime origin, Duration interval) sync* {
    var current = from;

    // Adjusting the current time for the sequence to contain the scheduled time.
    var desiredOffset = origin.millisecondsSinceEpoch % interval.inMilliseconds;
    var currentOffset =
        current.millisecondsSinceEpoch % interval.inMilliseconds;
    current = DateTime.fromMillisecondsSinceEpoch(
        current.millisecondsSinceEpoch -
            currentOffset +
            desiredOffset -
            interval.inMilliseconds);
    // now, current is surely before the scheduled time.
    // and ajusted.

    while (current.isBefore(from)) {
      // includes `from`
      current = current.add(interval);
    }

    while (!current.isAfter(to)) {
      // includes `to`
      yield current;
      current = current.add(interval);
    }
  }

  static Iterable<DateTime> weekly(
      DateTime from, DateTime to, List<Weekday> weekday) sync* {
    List<int> weekdayInts = weekday.map((e) => e.number).toList();
    for (var current = from; // includes `from`
        !current.isAfter(to); // includes `to`
        current = current.add(Duration(days: 7))) {
      if (weekdayInts.contains(current.weekday)) {
        yield current;
      }
    }
  }

  static Iterable<DateTime> monthlyHeadOrigin(
      DateTime from, DateTime to, Duration offset) sync* {
    var current = DateTime(from.year, from.month, 1);
    current = current.add(offset);

    while (current.isBefore(from)) {
      // includes `from`
      current = DateTime(current.year, current.month + 1, 1);
      current = current.add(offset);
    }

    while (!current.isAfter(to)) {
      // includes `to`
      yield current;
      current = DateTime(current.year, current.month + 1, 1);
      current = current.add(offset);
    }
  }

  static Iterable<DateTime> monthlyTailOrigin(
      DateTime from, DateTime to, Duration offset) sync* {
    var current = DateTime(from.year, from.month + 1, 0);
    current = current.subtract(offset);

    while (current.isBefore(from)) {
      // includes `from`
      var oldMonth = current.month; // to avoid infinite loop
      current = DateTime(current.year, current.month + 2, 0);
      current = current.subtract(offset);
      if (oldMonth == current.month) {
        current = current.add(Duration(days: 31));
      }
    }

    while (!current.isAfter(to)) {
      // includes `to`
      yield current;
      var oldMonth = current.month; // to avoid infinite loop
      current = DateTime(current.year, current.month + 2, 0);
      current = current.subtract(offset);
      if (oldMonth == current.month) {
        current = current.add(Duration(days: 31));
      }
    }
  }

  static Iterable<DateTime> anually(
      DateTime from, DateTime to, DateTime origin) sync* {
    for (var current = DateTime(from.year, origin.month, origin.day);
        !current.isAfter(to);
        current = DateTime(current.year + 1, current.month, current.day)) {
      yield current;
    }
  }
}
