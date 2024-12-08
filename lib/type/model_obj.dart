import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/model/infra/table_components.dart';
import 'package:miraibo/model/infra/main_db_table_definitions.dart';
import 'package:miraibo/model/infra/queue_db_table_definitions.dart';

// <main>

class Category extends Record {
  int? id;
  String name;

  Category({this.id, required this.name});

  factory Category.interpret(Map<String, Object?> row) {
    return Category(
      id: CategoryFE.id.interpret(row[CategoryFE.id.fn]),
      name: CategoryFE.name.interpret(row[CategoryFE.name.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      CategoryFE.name.fn: CategoryFE.name.serialize(name),
    };
  }
}

class DisplayTicket extends Record {
  int? id;
  Duration? periodInDays;
  DateTime? startDate;
  DateTime? endDate;
  DisplayContentType contentType;

  DisplayTicket({
    this.id,
    this.periodInDays,
    this.startDate,
    this.endDate,
    required this.contentType,
  });

  factory DisplayTicket.interpret(Map<String, Object?> row) {
    return DisplayTicket(
      id: DisplayTicketFE.id.interpret(row[DisplayTicketFE.id.fn]),
      periodInDays: DisplayTicketFE.lastInDays
          .interpret(row[DisplayTicketFE.lastInDays.fn]),
      startDate: DisplayTicketFE.periodBegin
          .interpret(row[DisplayTicketFE.periodBegin.fn]),
      endDate: DisplayTicketFE.periodEnd
          .interpret(row[DisplayTicketFE.periodEnd.fn]),
      contentType: DisplayTicketFE.contentType
          .interpret(row[DisplayTicketFE.contentType.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      DisplayTicketFE.lastInDays.fn:
          DisplayTicketFE.lastInDays.serialize(periodInDays),
      DisplayTicketFE.periodBegin.fn:
          DisplayTicketFE.periodBegin.serialize(startDate),
      DisplayTicketFE.periodEnd.fn:
          DisplayTicketFE.periodEnd.serialize(endDate),
      DisplayTicketFE.contentType.fn:
          DisplayTicketFE.contentType.serialize(contentType),
    };
  }
}

class Schedule extends Record {
  int? id;
  int categoryId;
  String supplement;
  DateTime originDate;
  int amount;
  ScheduleRepeatType repeatType;
  Duration repeatInterval;
  bool repeatOnSunday;
  bool repeatOnMonday;
  bool repeatOnTuesday;
  bool repeatOnWednesday;
  bool repeatOnThursday;
  bool repeatOnFriday;
  bool repeatOnSaturday;
  Duration? monthlyRepeatHeadOriginOffset;
  Duration? monthlyRepeatTailOriginOffset;
  DateTime? periodBegin;
  DateTime? periodEnd;

  Schedule({
    this.id,
    required this.categoryId,
    required this.supplement,
    required this.originDate,
    required this.amount,
    required this.repeatType,
    required this.repeatInterval,
    required this.repeatOnSunday,
    required this.repeatOnMonday,
    required this.repeatOnTuesday,
    required this.repeatOnWednesday,
    required this.repeatOnThursday,
    required this.repeatOnFriday,
    required this.repeatOnSaturday,
    this.monthlyRepeatHeadOriginOffset,
    this.monthlyRepeatTailOriginOffset,
    this.periodBegin,
    this.periodEnd,
  });

  factory Schedule.interpret(Map<String, Object?> row) {
    return Schedule(
      id: ScheduleFE.id.interpret(row[ScheduleFE.id.fn]),
      categoryId: ScheduleFE.category.interpret(row[ScheduleFE.category.fn]),
      supplement:
          ScheduleFE.supplement.interpret(row[ScheduleFE.supplement.fn]),
      originDate:
          ScheduleFE.originDate.interpret(row[ScheduleFE.originDate.fn]),
      amount: ScheduleFE.amount.interpret(row[ScheduleFE.amount.fn]),
      repeatType:
          ScheduleFE.repeatType.interpret(row[ScheduleFE.repeatType.fn]),
      repeatInterval: ScheduleFE.repeatInterval
          .interpret(row[ScheduleFE.repeatInterval.fn]),
      repeatOnSunday: ScheduleFE.repeatOnSunday
          .interpret(row[ScheduleFE.repeatOnSunday.fn]),
      repeatOnMonday: ScheduleFE.repeatOnMonday
          .interpret(row[ScheduleFE.repeatOnMonday.fn]),
      repeatOnTuesday: ScheduleFE.repeatOnTuesday
          .interpret(row[ScheduleFE.repeatOnTuesday.fn]),
      repeatOnWednesday: ScheduleFE.repeatOnWednesday
          .interpret(row[ScheduleFE.repeatOnWednesday.fn]),
      repeatOnThursday: ScheduleFE.repeatOnThursday
          .interpret(row[ScheduleFE.repeatOnThursday.fn]),
      repeatOnFriday: ScheduleFE.repeatOnFriday
          .interpret(row[ScheduleFE.repeatOnFriday.fn]),
      repeatOnSaturday: ScheduleFE.repeatOnSaturday
          .interpret(row[ScheduleFE.repeatOnSaturday.fn]),
      monthlyRepeatHeadOriginOffset: ScheduleFE.monthlyRepeatHeadOrigin
          .interpret(row[ScheduleFE.monthlyRepeatHeadOrigin.fn]),
      monthlyRepeatTailOriginOffset: ScheduleFE.monthlyRepeatTailOrigin
          .interpret(row[ScheduleFE.monthlyRepeatTailOrigin.fn]),
      periodBegin:
          ScheduleFE.periodBegin.interpret(row[ScheduleFE.periodBegin.fn]),
      periodEnd: ScheduleFE.periodEnd.interpret(row[ScheduleFE.periodEnd.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      ScheduleFE.category.fn: ScheduleFE.category.serialize(categoryId),
      ScheduleFE.supplement.fn: ScheduleFE.supplement.serialize(supplement),
      ScheduleFE.originDate.fn: ScheduleFE.originDate.serialize(originDate),
      ScheduleFE.amount.fn: ScheduleFE.amount.serialize(amount),
      ScheduleFE.repeatType.fn: ScheduleFE.repeatType.serialize(repeatType),
      ScheduleFE.repeatInterval.fn:
          ScheduleFE.repeatInterval.serialize(repeatInterval),
      ScheduleFE.repeatOnSunday.fn:
          ScheduleFE.repeatOnSunday.serialize(repeatOnSunday),
      ScheduleFE.repeatOnMonday.fn:
          ScheduleFE.repeatOnMonday.serialize(repeatOnMonday),
      ScheduleFE.repeatOnTuesday.fn:
          ScheduleFE.repeatOnTuesday.serialize(repeatOnTuesday),
      ScheduleFE.repeatOnWednesday.fn:
          ScheduleFE.repeatOnWednesday.serialize(repeatOnWednesday),
      ScheduleFE.repeatOnThursday.fn:
          ScheduleFE.repeatOnThursday.serialize(repeatOnThursday),
      ScheduleFE.repeatOnFriday.fn:
          ScheduleFE.repeatOnFriday.serialize(repeatOnFriday),
      ScheduleFE.repeatOnSaturday.fn:
          ScheduleFE.repeatOnSaturday.serialize(repeatOnSaturday),
      ScheduleFE.monthlyRepeatHeadOrigin.fn: ScheduleFE.monthlyRepeatHeadOrigin
          .serialize(monthlyRepeatHeadOriginOffset),
      ScheduleFE.monthlyRepeatTailOrigin.fn: ScheduleFE.monthlyRepeatTailOrigin
          .serialize(monthlyRepeatTailOriginOffset),
      ScheduleFE.periodBegin.fn: ScheduleFE.periodBegin.serialize(periodBegin),
      ScheduleFE.periodEnd.fn: ScheduleFE.periodEnd.serialize(periodEnd),
    };
  }
}

class Estimation extends Record {
  int? id;
  DateTime? periodBegin;
  DateTime? periodEnd;
  EstimationContentType contentType;

  Estimation({
    this.id,
    this.periodBegin,
    this.periodEnd,
    required this.contentType,
  });

  factory Estimation.interpret(Map<String, Object?> row) {
    return Estimation(
      id: EstimationFE.id.interpret(row[EstimationFE.id.fn]),
      periodBegin:
          EstimationFE.periodBegin.interpret(row[EstimationFE.periodBegin.fn]),
      periodEnd:
          EstimationFE.periodEnd.interpret(row[EstimationFE.periodEnd.fn]),
      contentType:
          EstimationFE.contentType.interpret(row[EstimationFE.contentType.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      EstimationFE.periodBegin.fn:
          EstimationFE.periodBegin.serialize(periodBegin),
      EstimationFE.periodEnd.fn: EstimationFE.periodEnd.serialize(periodEnd),
      EstimationFE.contentType.fn:
          EstimationFE.contentType.serialize(contentType),
    };
  }
}

class Log extends Record {
  int? id;
  int categoryId;
  String supplement;
  int amount;
  DateTime date;
  String? imagePath;
  bool confirmed;

  Log({
    this.id,
    required this.categoryId,
    required this.supplement,
    required this.amount,
    required this.date,
    this.imagePath,
    required this.confirmed,
  });

  factory Log.interpret(Map<String, Object?> row) {
    return Log(
      id: LogFE.id.interpret(row[LogFE.id.fn]),
      categoryId: LogFE.category.interpret(row[LogFE.category.fn]),
      supplement: LogFE.supplement.interpret(row[LogFE.supplement.fn]),
      amount: LogFE.amount.interpret(row[LogFE.amount.fn]),
      date: LogFE.date.interpret(row[LogFE.date.fn]),
      imagePath: LogFE.imagePath.interpret(row[LogFE.imagePath.fn]),
      confirmed: LogFE.confirmed.interpret(row[LogFE.confirmed.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      LogFE.category.fn: LogFE.category.serialize(categoryId),
      LogFE.supplement.fn: LogFE.supplement.serialize(supplement),
      LogFE.amount.fn: LogFE.amount.serialize(amount),
      LogFE.date.fn: LogFE.date.serialize(date),
      LogFE.imagePath.fn: LogFE.imagePath.serialize(imagePath),
      LogFE.confirmed.fn: LogFE.confirmed.serialize(confirmed),
    };
  }
}

// </main>

// <queue>
class Task extends Record {
  int? id;
  DateTime createdAt;

  Task({this.id, required this.createdAt});

  factory Task.interpret(Map<String, Object?> row) {
    return Task(
      id: PredictionTaskFE.id.interpret(row[PredictionTaskFE.id.fn]),
      createdAt: PredictionTaskFE.createdAt
          .interpret(row[PredictionTaskFE.createdAt.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      PredictionTaskFE.id.fn: PredictionTaskFE.id.serialize(id),
      PredictionTaskFE.createdAt.fn:
          PredictionTaskFE.createdAt.serialize(createdAt),
    };
  }
}

// </queue>
