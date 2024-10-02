import 'dart:developer';

import 'package:uuid/uuid.dart';

// <Display Ticket>
enum DisplayTicketTermMode {
  untilToday,
  lastDesignatedPeriod,
  untilDesignatedDate
}

enum DisplayTicketPeriod { week, month, halfYear, year }

enum DisplayTicketContentTypes {
  dailyAverage,
  dailyQuartileAverage,
  monthlyAverage,
  monthlyQuartileAverage,
  summation,
}

class DisplayTicketConfigurationData {
  final String? id;
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final DisplayTicketTermMode termMode;
  final DateTime? designatedDate;
  final DisplayTicketPeriod designatedPeriod;
  final DisplayTicketContentTypes contentType;

  const DisplayTicketConfigurationData({
    this.id,
    this.targetCategories = const <Category>[],
    this.targetingAllCategories = true,
    this.termMode = DisplayTicketTermMode.untilToday,
    this.designatedDate,
    this.designatedPeriod = DisplayTicketPeriod.week,
    this.contentType = DisplayTicketContentTypes.summation,
  });

  DisplayTicketConfigurationData copyWith({
    String? id,
    List<Category>? targetCategories,
    bool? targetingAllCategories,
    DisplayTicketTermMode? termMode,
    DateTime? designatedDate,
    DisplayTicketPeriod? designatedPeriod,
    DisplayTicketContentTypes? contentTypes,
  }) {
    return DisplayTicketConfigurationData(
      id: id ?? this.id,
      targetCategories: targetCategories ?? this.targetCategories,
      targetingAllCategories:
          targetingAllCategories ?? this.targetingAllCategories,
      termMode: termMode ?? this.termMode,
      designatedDate: designatedDate ?? this.designatedDate,
      designatedPeriod: designatedPeriod ?? this.designatedPeriod,
      contentType: contentTypes ?? this.contentType,
    );
  }
}

// </Display Ticket>

// <Schedule Ticket>
enum RepeatType { no, interval, week, month }

enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday
}

enum MonthlyRepeatType { fromHead, fromTail }

class ScheduleTicketConfigurationData {
  final String? id;
  final Category? category;
  final String supplement;
  final DateTime? registorationDate;
  final int amount;
  final RepeatType repeatType;
  final Duration repeatInterval;
  final DayOfWeek repeatDayOfWeek;
  final MonthlyRepeatType monthlyRepeatType;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScheduleTicketConfigurationData({
    this.id,
    this.category,
    this.supplement = '',
    this.registorationDate,
    this.amount = 0,
    this.repeatType = RepeatType.no,
    this.repeatInterval = const Duration(days: 1),
    this.repeatDayOfWeek = DayOfWeek.sunday,
    this.monthlyRepeatType = MonthlyRepeatType.fromHead,
    this.startDate,
    this.endDate,
  });

  ScheduleTicketConfigurationData copyWith({
    String? id,
    Category? category,
    String? supplement,
    DateTime? registorationDate,
    int? amount,
    RepeatType? repeatType,
    Duration? repeatInterval,
    DayOfWeek? repeatDayOfWeek,
    MonthlyRepeatType? monthlyRepeatType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ScheduleTicketConfigurationData(
      id: id ?? this.id,
      category: category ?? this.category,
      supplement: supplement ?? this.supplement,
      registorationDate: registorationDate ?? this.registorationDate,
      amount: amount ?? this.amount,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      repeatDayOfWeek: repeatDayOfWeek ?? this.repeatDayOfWeek,
      monthlyRepeatType: monthlyRepeatType ?? this.monthlyRepeatType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
// </Schedule Ticket>

// <Estimation Ticket>
enum EstimationTicketContentType {
  perDay,
  perWeek,
  perMonth,
  perYear,
}

class EstimationTicketConfigurationData {
  final String? id;
  final Category? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final EstimationTicketContentType contentType;

  const EstimationTicketConfigurationData(
      {this.id,
      this.category,
      this.startDate,
      this.endDate,
      this.contentType = EstimationTicketContentType.perMonth});

  EstimationTicketConfigurationData copyWith({
    String? id,
    Category? category,
    DateTime? startDate,
    DateTime? endDate,
    EstimationTicketContentType? contentType,
  }) {
    return EstimationTicketConfigurationData(
      id: id ?? this.id,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contentType: contentType ?? this.contentType,
    );
  }
}
// </Estimation Ticket>

// <Log Ticket>
class LogTicketConfigurationData {
  final String? id;
  final Category? category;
  final String supplementation;
  final DateTime? registorationDate;
  final int amount;
  final Uri? image;

  const LogTicketConfigurationData(
      {this.id,
      this.category,
      this.supplementation = '',
      this.registorationDate,
      this.amount = 0,
      this.image});

  LogTicketConfigurationData copyWith({
    String? id,
    Category? category,
    String? supplementation,
    DateTime? registorationDate,
    int? amount,
    Uri? image,
  }) {
    return LogTicketConfigurationData(
      id: id ?? this.id,
      category: category ?? this.category,
      supplementation: supplementation ?? this.supplementation,
      registorationDate: registorationDate ?? this.registorationDate,
      amount: amount ?? this.amount,
      image: image ?? this.image,
    );
  }
}
// </Log Ticket>

class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  static Future<List<Category>> fetchAll() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Category.make('food'),
      Category.make('hobby'),
      Category.make('housing')
    ];
    // in progress
  }

  factory Category.make(String name) {
    return Category(id: const Uuid().v4(), name: name);
  }

  void rename(String newName) {
    name = newName;
  }

  void integrateWith(Category other) {
    log('integrate $name with ${other.name}');
    // in progress
  }
}
