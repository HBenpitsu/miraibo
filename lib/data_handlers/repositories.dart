class DisplayTicketRepository {
  DisplayTicketRepository._internal();

  // Singleton instance
  static final DisplayTicketRepository _instance =
      DisplayTicketRepository._internal();
  factory DisplayTicketRepository() => _instance;
}

class ScheduleTicketRepository {
  ScheduleTicketRepository._internal();

  // Singleton instance
  static final ScheduleTicketRepository _instance =
      ScheduleTicketRepository._internal();
  factory ScheduleTicketRepository() => _instance;
}

class LogTicketRepository {
  LogTicketRepository._internal();

  // Singleton instance
  static final LogTicketRepository _instance = LogTicketRepository._internal();
  factory LogTicketRepository() => _instance;
}

class EstimationTicketRepository {
  EstimationTicketRepository._internal();

  // Singleton instance
  static final EstimationTicketRepository _instance =
      EstimationTicketRepository._internal();
  factory EstimationTicketRepository() => _instance;
}

class CategoryRepository {
  CategoryRepository._internal();

  // Singleton instance
  static final CategoryRepository _instance = CategoryRepository._internal();
  factory CategoryRepository() => _instance;
}
