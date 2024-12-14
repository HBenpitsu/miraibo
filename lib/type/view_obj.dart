import 'package:miraibo/type/enumarations.dart';
import 'dart:io';

// intermediate date types. they are used among the database and the viewer.

class Category {
  int? id;
  String name;

  Category({
    this.id,
    required this.name,
  });
}

class Display {
  int? id;
  DisplayTermMode termMode;
  DisplayPeriod displayPeriod;
  DateTime? periodBegin;
  DateTime? periodEnd;
  DisplayContentType contentType;
  bool targetingAllCategories;
  List<Category> targetCategories;

  Display({
    this.id,
    required this.termMode,
    required this.displayPeriod,
    this.periodBegin,
    this.periodEnd,
    required this.contentType,
    required this.targetingAllCategories,
    required this.targetCategories,
  });
}

class Estimation {
  int? id;
  DateTime? periodBeign;
  DateTime? periodEnd;
  EstimationContentType contentType;
  bool targetingAllCategories;
  List<Category> targetCategories;

  Estimation({
    this.id,
    this.periodBeign,
    this.periodEnd,
    required this.contentType,
    required this.targetingAllCategories,
    required this.targetCategories,
  });
}

class Schedule {
  int? id;
  String supplement;
  Category category;
  int amount;
  DateTime originDate;
  ScheduleRepeatType repeatType;
  Duration repeatInterval;
  List<Weekday> weeklyRepeatOn;
  Duration? monthlyHeadOriginRepeatOffset;
  Duration? monthlyTailOriginRepeatOffset;
  DateTime? periodBegin;
  DateTime? periodEnd;

  Schedule({
    this.id,
    required this.supplement,
    required this.category,
    required this.amount,
    required this.originDate,
    required this.repeatType,
    required this.repeatInterval,
    required this.weeklyRepeatOn,
    this.monthlyHeadOriginRepeatOffset,
    this.monthlyTailOriginRepeatOffset,
    this.periodBegin,
    this.periodEnd,
  });
}

class Log {
  int? id;
  DateTime date;
  Category category;
  int amount;
  String supplement;
  File? image;
  bool confirmed;

  Log({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.supplement,
    this.image,
    required this.confirmed,
  });
}

class Preset {
  Category category;
  int amount;
  String supplement;

  Preset({
    required this.category,
    required this.amount,
    required this.supplement,
  });
}

class ChartQuery {
  DateTime periodBegin;
  DateTime periodEnd;
  ChartType chartType;
  ChartAxesInterval axesInterval;
  List<Category> categories;

  ChartQuery({
    required this.periodBegin,
    required this.periodEnd,
    required this.chartType,
    required this.axesInterval,
    required this.categories,
  });
}
