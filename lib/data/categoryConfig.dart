import 'dart:developer' as developer;
import 'dart:io';

import './repository.dart';

/* 
This file contains the data classes that define the structure of the data, 
and the methods to basic data-operations: save, delete, copyWith, etc.

all classes are related to specific 'object' such as single type of ticket, category.

Function to handle the data across objects are defined in the './fecher.dart' file (not included in this file).
*/

/* 
Abstract class to bundle: 

- DisplayTicketConfigData
- ScheduleTicketConfigData
- EstimationTicketConfigData
- LogTicketConfigData
*/
abstract class TicketConfigData {
  final int? id;

  const TicketConfigData({this.id});

  void save();
  void delete();

  TicketConfigData copyWith({int? id});
}

// <Display Ticket>
enum DisplayTicketTermMode {
  untilToday,
  lastDesignatedPeriod,
  untilDesignatedDate;
}

enum DisplayTicketPeriod {
  week,
  month,
  halfYear,
  year;
}

enum DisplayTicketContentType {
  dailyAverage,
  dailyQuartileAverage,
  monthlyAverage,
  monthlyQuartileAverage,
  summation;
}

class DisplayTicketConfigData extends TicketConfigData {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final int linker;
  final DisplayTicketTermMode termMode;
  final DateTime? designatedDate;
  final DisplayTicketPeriod designatedPeriod;
  final DisplayTicketContentType contentType;

  const DisplayTicketConfigData({
    super.id,
    this.targetCategories = const <Category>[],
    this.targetingAllCategories = true,
    this.linker = 0,
    this.termMode = DisplayTicketTermMode.untilToday,
    this.designatedDate,
    this.designatedPeriod = DisplayTicketPeriod.week,
    this.contentType = DisplayTicketContentType.summation,
  });

  @override
  void save() {
    developer.log('save display ticket config data');
    // in progress
  }

  @override
  void delete() {
    developer.log('delete display ticket config data');
    // in progress
  }

  @override
  DisplayTicketConfigData copyWith({
    int? id,
    List<Category>? targetCategories,
    bool? targetingAllCategories,
    int? linker,
    DisplayTicketTermMode? termMode,
    DateTime? designatedDate,
    DisplayTicketPeriod? designatedPeriod,
    DisplayTicketContentType? contentType,
  }) {
    return DisplayTicketConfigData(
      id: id ?? this.id,
      targetCategories: targetCategories ?? this.targetCategories,
      targetingAllCategories:
          targetingAllCategories ?? this.targetingAllCategories,
      linker: linker ?? this.linker,
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

class ScheduleTicketConfigData extends TicketConfigData {
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

  const ScheduleTicketConfigData({
    super.id,
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

  @override
  void save() {
    developer.log('save schedule ticket config data');
    // in progress
  }

  @override
  void delete() {
    developer.log('delete schedule ticket config data');
    // in progress
  }

  @override
  ScheduleTicketConfigData copyWith({
    int? id,
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
    return ScheduleTicketConfigData(
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

class EstimationTicketConfigData extends TicketConfigData {
  final List<Category> targetCategories;
  final bool targetingAllCategories;
  final int? linker;
  final DateTime? _startDate;
  DateTime? get startDate => _startDateDesignated ? _startDate : null;
  final bool _startDateDesignated;
  bool get startDateDesignated => (_startDate != null) && _startDateDesignated;
  final DateTime? _endDate;
  DateTime? get endDate => _endDateDesignated ? _endDate : null;
  final bool _endDateDesignated;
  bool get endDateDesignated => (_endDate != null) && _endDateDesignated;
  final EstimationTicketContentType contentType;

  @override
  void save() {
    developer.log('save estimation ticket config data');
    // in progress
  }

  @override
  void delete() {
    developer.log('delete estimation ticket config data');
    // in progress
  }

  const EstimationTicketConfigData(
      {super.id,
      this.targetCategories = const <Category>[],
      this.targetingAllCategories = false,
      this.linker,
      DateTime? startDate,
      bool startDateDesignated = false,
      DateTime? endDate,
      bool endDateDesignated = false,
      this.contentType = EstimationTicketContentType.perMonth})
      : _startDate = startDate,
        _startDateDesignated = startDateDesignated,
        _endDate = endDate,
        _endDateDesignated = endDateDesignated;

  @override
  EstimationTicketConfigData copyWith({
    int? id,
    List<Category>? selectedCategories,
    bool? selectingAllCategories,
    int? linker,
    DateTime? startDate,
    bool? startDateDesignated,
    DateTime? endDate,
    bool? endDateDesignated,
    EstimationTicketContentType? contentType,
  }) {
    return EstimationTicketConfigData(
      id: id ?? this.id,
      targetCategories: selectedCategories ?? targetCategories,
      targetingAllCategories: selectingAllCategories ?? targetingAllCategories,
      linker: linker ?? this.linker,
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
class LogTicketConfigData extends TicketConfigData {
  final Category? category;
  final String supplement;
  final DateTime? registorationDate;
  final int amount;
  final File? _image;
  File? get image => _isImageAttached ? _image : null;
  final bool _isImageAttached;
  bool get isImageAttached => _image != null && _isImageAttached;
  final bool confirmed;

  const LogTicketConfigData(
      {super.id,
      this.category,
      this.supplement = '',
      this.registorationDate,
      this.amount = 0,
      this.confirmed = false,
      File? image,
      bool isImageAttached = false})
      : _image = image,
        _isImageAttached = isImageAttached;

  @override
  void save() {
    developer.log('save log ticket config data');
    // in progress
  }

  @override
  void delete() {
    developer.log('delete log ticket config data');
    // in progress
  }

  @override
  LogTicketConfigData copyWith({
    int? id,
    Category? category,
    String? supplement,
    DateTime? registorationDate,
    int? amount,
    File? image,
    bool? isImageAttached,
  }) {
    return LogTicketConfigData(
      id: id ?? this.id,
      category: category ?? this.category,
      supplement: supplement ?? this.supplement,
      registorationDate: registorationDate ?? this.registorationDate,
      amount: amount ?? this.amount,
      image: image ?? this.image,
      isImageAttached: isImageAttached ?? this.isImageAttached,
    );
  }

  LogTicketConfigData applyPreset(LogTicketConfigData preset) {
    return LogTicketConfigData(
      category: preset.category,
      supplement: preset.supplement,
      amount: preset.amount,
    );
  }
}
// </Log Ticket>

// </ticket config data>
