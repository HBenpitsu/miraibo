import 'dart:developer';
import 'dart:io';

import 'package:uuid/uuid.dart';

// <Display Ticket>
enum DisplayTicketTermMode {
  untilToday,
  lastDesignatedPeriod,
  untilDesignatedDate
}

enum DisplayTicketPeriod { week, month, halfYear, year }

enum DisplayTicketContentType {
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
  final DisplayTicketContentType contentType;

  const DisplayTicketConfigurationData({
    this.id,
    this.targetCategories = const <Category>[],
    this.targetingAllCategories = true,
    this.termMode = DisplayTicketTermMode.untilToday,
    this.designatedDate,
    this.designatedPeriod = DisplayTicketPeriod.week,
    this.contentType = DisplayTicketContentType.summation,
  });

  DisplayTicketConfigurationData copyWith({
    String? id,
    List<Category>? targetCategories,
    bool? targetingAllCategories,
    DisplayTicketTermMode? termMode,
    DateTime? designatedDate,
    DisplayTicketPeriod? designatedPeriod,
    DisplayTicketContentType? contentType,
  }) {
    return DisplayTicketConfigurationData(
      id: id ?? this.id,
      targetCategories: targetCategories ?? this.targetCategories,
      targetingAllCategories:
          targetingAllCategories ?? this.targetingAllCategories,
      termMode: termMode ?? this.termMode,
      designatedDate: designatedDate ?? this.designatedDate,
      designatedPeriod: designatedPeriod ?? this.designatedPeriod,
      contentType: contentType ?? this.contentType,
    );
  }
}

// </Display Ticket>

// <Schedule Ticket>
enum RepeatType { no, interval, weekly, monthly, anually }

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
  final List<DayOfWeek> repeatDayOfWeek;
  final MonthlyRepeatType monthlyRepeatType;
  final DateTime? _startDate;
  DateTime? get startDate => _startDateDesignated ? _startDate : null;
  final bool _startDateDesignated;
  bool get startDateDesignated => (_startDate != null) && _startDateDesignated;

  final DateTime? _endDate;
  DateTime? get endDate => _endDateDesignated ? _endDate : null;
  final bool _endDateDesignated;
  bool get endDateDesignated => (_endDate != null) && _endDateDesignated;

  const ScheduleTicketConfigurationData({
    this.id,
    this.category,
    this.supplement = '',
    this.registorationDate,
    this.amount = 0,
    this.repeatType = RepeatType.no,
    this.repeatInterval = const Duration(days: 1),
    this.repeatDayOfWeek = const [],
    this.monthlyRepeatType = MonthlyRepeatType.fromHead,
    DateTime? startDate,
    bool startDateDesignated = false,
    DateTime? endDate,
    bool endDateDesignated = false,
  })  : _startDateDesignated = startDateDesignated,
        _endDateDesignated = endDateDesignated,
        _startDate = startDate,
        _endDate = endDate;

  ScheduleTicketConfigurationData copyWith({
    String? id,
    Category? category,
    String? supplement,
    DateTime? registorationDate,
    int? amount,
    RepeatType? repeatType,
    Duration? repeatInterval,
    List<DayOfWeek>? repeatDayOfWeek,
    MonthlyRepeatType? monthlyRepeatType,
    DateTime? startDate,
    bool? startDateDesignated,
    DateTime? endDate,
    bool? endDateDesignated,
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
      startDate: startDate ?? _startDate,
      startDateDesignated: startDateDesignated ?? _startDateDesignated,
      endDate: endDate ?? _endDate,
      endDateDesignated: endDateDesignated ?? _endDateDesignated,
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
  final List<Category> selectedCategories;
  final bool selectingAllCategories;
  final DateTime? _startDate;
  DateTime? get startDate => _startDateDesignated ? _startDate : null;
  final bool _startDateDesignated;
  bool get startDateDesignated => (_startDate != null) && _startDateDesignated;
  final DateTime? _endDate;
  DateTime? get endDate => _endDateDesignated ? _endDate : null;
  final bool _endDateDesignated;
  bool get endDateDesignated => (_endDate != null) && _endDateDesignated;
  final EstimationTicketContentType contentType;

  const EstimationTicketConfigurationData(
      {this.id,
      this.selectedCategories = const <Category>[],
      this.selectingAllCategories = false,
      DateTime? startDate,
      bool startDateDesignated = false,
      DateTime? endDate,
      bool endDateDesignated = false,
      this.contentType = EstimationTicketContentType.perMonth})
      : _startDate = startDate,
        _startDateDesignated = startDateDesignated,
        _endDate = endDate,
        _endDateDesignated = endDateDesignated;

  EstimationTicketConfigurationData copyWith({
    String? id,
    List<Category>? selectedCategories,
    bool? selectingAllCategories,
    DateTime? startDate,
    bool? startDateDesignated,
    DateTime? endDate,
    bool? endDateDesignated,
    EstimationTicketContentType? contentType,
  }) {
    return EstimationTicketConfigurationData(
      id: id ?? this.id,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectingAllCategories:
          selectingAllCategories ?? this.selectingAllCategories,
      startDate: startDate ?? this.startDate,
      startDateDesignated: startDateDesignated ?? this.startDateDesignated,
      endDate: endDate ?? this.endDate,
      endDateDesignated: endDateDesignated ?? this.endDateDesignated,
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
  final File? _image;
  File? get image => _isImageAttached ? _image : null;
  final bool _isImageAttached;
  bool get isImageAttached => _image != null && _isImageAttached;

  const LogTicketConfigurationData(
      {this.id,
      this.category,
      this.supplementation = '',
      this.registorationDate,
      this.amount = 0,
      File? image,
      bool isImageAttached = false})
      : _image = image,
        _isImageAttached = isImageAttached;

  LogTicketConfigurationData copyWith({
    String? id,
    Category? category,
    String? supplementation,
    DateTime? registorationDate,
    int? amount,
    File? image,
    bool? isImageAttached,
  }) {
    return LogTicketConfigurationData(
      id: id ?? this.id,
      category: category ?? this.category,
      supplementation: supplementation ?? this.supplementation,
      registorationDate: registorationDate ?? this.registorationDate,
      amount: amount ?? this.amount,
      image: image ?? this.image,
      isImageAttached: isImageAttached ?? this.isImageAttached,
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
