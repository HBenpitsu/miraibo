import './database.dart';
import 'ticketData.dart';
import './categoryData.dart';

class FutureTicket extends DTO {
  final ScheduleRecord? schedule;
  final EstimationRecord? estimation;
  final Category category;
  final String supplement;
  final DateTime scheduledAt;
  final int amount;

  FutureTicket({
    super.id,
    this.schedule,
    this.estimation,
    required this.category,
    required this.supplement,
    required this.scheduledAt,
    required this.amount,
  });

  @override
  Future<void> save() {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }
}

class FutureTicketTable extends Table<FutureTicket> {
  @override
  covariant String tableName = 'FutureTickets';

  // <constructor>
  FutureTicketTable._internal();
  static final FutureTicketTable _instance = FutureTicketTable._internal();

  static Future<FutureTicketTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory FutureTicketTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('schedule', ScheduleTable.ref(), rField: 'id'),
      makeForeignField('estimation', EstimationTable.ref(), rField: 'id'),
      makeForeignField('category', CategoryTable.ref(),
          rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeDateField('scheduledAt', notNull: true),
      makeIntegerField('amount', notNull: true),
    ]));
  }

  @override
  Future<FutureTicket> interpret(Map<String, Object?> row) async {
    var scheduleTable = await ScheduleTable.use();
    var estimationTable = await EstimationTable.use();
    var categoryTable = await CategoryTable.use();
    return FutureTicket(
      id: row['id'] as int,
      schedule: await scheduleTable.fetchById(row['schedule'] as int),
      estimation: await estimationTable.fetchById(row['estimation'] as int),
      category: (await categoryTable.fetchById(row['category'] as int))!,
      supplement: row['supplement'] as String,
      scheduledAt: intToDate(row['scheduledAt'] as int)!,
      amount: row['amount'] as int,
    );
  }

  @override
  void validate(FutureTicket data) {} // always valid

  @override
  Map<String, Object?> serialize(FutureTicket data) {
    return {
      'schedule': data.schedule?.id,
      'estimation': data.estimation?.id,
      'category': data.category.id,
      'supplement': data.supplement,
      'scheduledAt': dateToInt(data.scheduledAt)!,
      'amount': data.amount,
    };
  }
}
