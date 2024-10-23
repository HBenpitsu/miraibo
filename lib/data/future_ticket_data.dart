import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './database.dart';
import 'ticket_data.dart';
import 'category_data.dart';

class FutureTicketFactory extends DTO {
  final ScheduleRecord? schedule;
  final EstimationRecord? estimation;
  const FutureTicketFactory({this.schedule, this.estimation});
}

class FutureTicketFactoryTable extends Table<FutureTicketFactory> {
  @override
  covariant String tableName = 'FutureTicketFactories';

  // <constructor>
  FutureTicketFactoryTable._internal();
  static final FutureTicketFactoryTable _instance =
      FutureTicketFactoryTable._internal();

  static Future<FutureTicketFactoryTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory FutureTicketFactoryTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('schedule', ScheduleTable.ref(), rField: 'id'),
      makeForeignField('estimation', EstimationTable.ref(), rField: 'id'),
    ]));
  }

  @override
  Future<FutureTicketFactory> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var scheduleTable = await ScheduleTable.use();
    var estimationTable = await EstimationTable.use();
    return FutureTicketFactory(
      schedule: await scheduleTable.fetchById(row['schedule'] as int, txn),
      estimation:
          await estimationTable.fetchById(row['estimation'] as int, txn),
    );
  }

  @override
  void validate(FutureTicketFactory data) {
    if (data.schedule?.id == null && data.estimation?.id == null) {
      throw InvalidDataException(
          'However schedule or estimation should be set for future ticket factory, both do not exist in the database. ');
    } else if (data.schedule != null && data.estimation != null) {
      throw InvalidDataException(
          'schedule and estimation cannot be set at the same time for future ticket factory.');
    }
  }

  @override
  Map<String, Object?> serialize(FutureTicketFactory data) {
    return {
      'schedule': data.schedule?.id,
      'estimation': data.estimation?.id,
    };
  }

  Future<void> onFactoryUpdated(
      int updatedFactoryId, Table<DTO> factoryKind, Transaction txn) async {
    // TODO: implement onFactoryUpdated
    throw UnimplementedError();
  }

  Future<void> onFactoryDeleted(
      int deletedFactoryId, Table<DTO> factoryKind, Transaction txn) async {
    // TODO: implement onFactoryDeleted
    throw UnimplementedError();
  }
}

class FutureTicket extends DTO {
  final FutureTicketFactory ticketFactory;
  final Category category;
  final String supplement;
  final DateTime scheduledAt;
  final int amount;

  FutureTicket({
    super.id,
    required this.ticketFactory,
    required this.category,
    required this.supplement,
    required this.scheduledAt,
    required this.amount,
  });
}

class FutureTicketTable extends Table<FutureTicket> with HaveCategoryField {
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
    bindCategoryIntegrator();
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('factory', FutureTicketFactoryTable.ref(),
          rField: 'id', notNull: true),
      makeForeignField('category', CategoryTable.ref(),
          rField: 'id', notNull: true),
      makeTextField('supplement', notNull: true),
      makeDateField('scheduledAt', notNull: true),
      makeIntegerField('amount', notNull: true),
    ]));
  }

  @override
  Future<FutureTicket> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var factoryTable = await FutureTicketFactoryTable.use();
    var categoryTable = await CategoryTable.use();
    return FutureTicket(
      id: row['id'] as int,
      ticketFactory:
          (await factoryTable.fetchById(row['factory'] as int, txn))!,
      category: (await categoryTable.fetchById(row['category'] as int, txn))!,
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
      'factory': data.ticketFactory.id,
      'category': data.category.id,
      'supplement': data.supplement,
      'scheduledAt': dateToInt(data.scheduledAt)!,
      'amount': data.amount,
    };
  }

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName
      SET category = ${replaceWith.id}
      WHERE category = ${replaced.id};
    ''');
  }
}
