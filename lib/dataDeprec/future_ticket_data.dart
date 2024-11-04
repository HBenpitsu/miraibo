import 'package:miraibo/background_worker/future_ticket_preparation.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:miraibo/dataDeprec/database.dart';
import 'package:miraibo/dataDeprec/ticket_data.dart';
import 'package:miraibo/dataDeprec/category_data.dart';
import 'package:miraibo/dataDeprec/general_enum.dart';

// This mixin marks up classes that can be used as a factory for future tickets.
// It is introduced to avoid the use of dynamic types.
mixin FutureTicketFactory on DTO {}

class FutureTicket extends DTO {
  final ScheduleRecord? schedule;
  final EstimationRecord? estimation;
  final Category category;
  final String supplement;
  final DateTime scheduledAt;
  final double amount;

  FutureTicket({
    super.id,
    required this.schedule,
    required this.estimation,
    required this.category,
    required this.supplement,
    required this.scheduledAt,
    required this.amount,
  });
}

class FutureTicketTable extends Table<FutureTicket> with HaveCategoryField {
  @override
  covariant String tableName = 'FutureTickets';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field name>
  static const String scheduleField = 'schedule';
  static const String estimationField = 'estimation';
  static const String categoryField = 'category';
  static const String supplementField = 'supplement';
  static const String scheduledAtField = 'scheduledAt';
  static const String amountField = 'amount';
  // </field name>

  // <constructor>
  FutureTicketTable._internal();
  static final FutureTicketTable _instance = FutureTicketTable._internal();

  static Future<FutureTicketTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory FutureTicketTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    bindCategoryIntegrator();
    await txn.execute(makeTable([
      makeIdField(),
      ...makeForeignField(scheduleField, ScheduleTable.ref(),
          rField: Table.idField),
      ...makeForeignField(estimationField, EstimationTable.ref(),
          rField: Table.idField),
      ...makeForeignField(categoryField, CategoryTable.ref(),
          rField: Table.idField, notNull: true),
      makeTextField(supplementField, notNull: true),
      makeDateField(scheduledAtField, notNull: true),
      makeRealField(amountField, notNull: true),
    ]));
  }

  @override
  Future<FutureTicket> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var scheduleTable = await ScheduleTable.use(txn);
    var estimationTable = await EstimationTable.use(txn);
    var categoryTable = await CategoryTable.use(txn);
    return FutureTicket(
      id: row[Table.idField] as int,
      schedule: await scheduleTable.fetchById(row[scheduleField] as int?, txn),
      estimation:
          await estimationTable.fetchById(row[estimationField] as int?, txn),
      category:
          (await categoryTable.fetchById(row[categoryField] as int, txn))!,
      supplement: row[supplementField] as String,
      scheduledAt: intToDate(row[scheduledAtField] as int)!,
      amount: row[amountField] as double,
    );
  }

  @override
  void validate(FutureTicket data) {
    if (data.schedule == null && data.estimation == null) {
      throw InvalidDataException(
          'The ticket factory should be set for future ticket. But neither schedule nor estimation is set.');
    }
  } // always valid

  @override
  Map<String, Object?> serialize(FutureTicket data) {
    return {
      scheduleField: data.schedule?.id,
      estimationField: data.estimation?.id,
      categoryField: data.category.id,
      supplementField: data.supplement,
      scheduledAtField: dateToInt(data.scheduledAt)!,
      amountField: data.amount,
    };
  }

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    await txn.execute('''
      UPDATE $tableName
      SET $categoryField = ${replaceWith.id}
      WHERE $categoryField = ${replaced.id};
    ''');
  }

  Future<void> eliminateAllByFactory(
      int factoryId, Table<FutureTicketFactory> kind, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return eliminateAllByFactory(factoryId, kind, txn);
      });
    }

    var whereStatement = switch (kind) {
      Table<ScheduleRecord> _ => '$scheduleField = $factoryId',
      Table<EstimationRecord> _ => '$estimationField = $factoryId',
      _ => UnimplementedError('The factory kind $kind is not supported.'),
    };

    return txn.execute('DELETE FROM $tableName WHERE $whereStatement;');
  }

  Future<void> updateAllByFactory(
      int factoryId,
      Table<FutureTicketFactory> kind,
      FutureTicket template,
      Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return updateAllByFactory(factoryId, kind, template, txn);
      });
    }

    var whereStatement = switch (kind) {
      Table<ScheduleRecord> _ => '$scheduleField = $factoryId',
      Table<EstimationRecord> _ => '$estimationField = $factoryId',
      _ => UnimplementedError('The factory kind $kind is not supported.'),
    };

    return txn.execute('''
            UPDATE $tableName
            SET
              $categoryField = ${template.category.id},
              $supplementField = '${template.supplement}',
              $amountField = ${template.amount}
            WHERE $whereStatement;
          ''');
  }

  Future<List<FutureTicket>> fetchAllByFactory(
      int factoryId, Table<FutureTicketFactory> kind, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchAllByFactory(factoryId, kind, txn);
      });
    }

    var whereStatement = switch (kind) {
      Table<ScheduleRecord> _ => '$scheduleField = $factoryId',
      Table<EstimationRecord> _ => '$estimationField = $factoryId',
      _ => UnimplementedError('The factory kind $kind is not supported.'),
    };

    var result = await txn.rawQuery('''
      SELECT * FROM $tableName WHERE $whereStatement;
    ''');
    return Future.wait([for (var row in result) interpret(row, txn)]);
  }

  Future<List<ScheduleRecord>> fetchSchedulesFor(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchSchedulesFor(date, txn);
      });
    }

    var query = '''
      SELECT $scheduleField FROM $tableName
      WHERE $scheduledAtField = ${dateToInt(date)!}
        AND $scheduleField IS NOT NULL;
    ''';
    var result = await txn.rawQuery(query);

    var scheduleTable = await ScheduleTable.use(txn);
    return scheduleTable
        .fetchByIds([for (var rec in result) rec[scheduleField] as int], txn);
  }

  Future<List<FutureTicket>> fetchTicketsFor(
      DateTime date, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchTicketsFor(date, txn);
      });
    }

    var query = '''
      SELECT * FROM $tableName
      WHERE $scheduledAtField = ${dateToInt(date)!};
    ''';
    var result = await txn.rawQuery(query);
    return Future.wait([for (var row in result) interpret(row, txn)]);
  }

  Future<void> cleanUp(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return cleanUp(txn);
      });
    }

    return txn.execute('''
          DELETE FROM $tableName
          WHERE $scheduledAtField < ${dateToInt(today())};
        ''');
  }

  // <repeat schedulers>
  Future<void> _insertTicketsAtOnce(FutureTicket ticketTemplate,
      List<DateTime> schedules, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return _insertTicketsAtOnce(ticketTemplate, schedules, txn);
      });
    }

    if (schedules.isEmpty) {
      return;
    }

    var sql = '''
      INSERT INTO $tableName
        (
          $scheduleField, 
          $estimationField, 
          $categoryField, 
          $supplementField, 
          $scheduledAtField, 
          $amountField
        )
      VALUES
    ''';

    for (var date in schedules) {
      sql += '''
        (
          ${ticketTemplate.schedule?.id}, 
          ${ticketTemplate.estimation?.id}, 
          ${ticketTemplate.category.id}, 
          '${ticketTemplate.supplement}', 
          ${dateToInt(date)}, 
          ${ticketTemplate.amount}
        ),''';
    }

    // remove the last comma and add a semicolon
    sql = '${sql.substring(0, sql.length - 1)};';

    await txn.rawInsert(sql);
  }

  Future<void> makeTicketsEveryday(FutureTicket ticketTemplate, DateTime from,
      DateTime to, Transaction? txn) async {
    var schedules = <DateTime>[];
    for (var current = from;
        current.isBefore(to);
        current = current.add(Duration(days: 1))) {
      schedules.add(current);
    }
    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeWeeklyTickets(FutureTicket ticketTemplate, DateTime from,
      DateTime to, Weekday weekday, Transaction? txn) async {
    var current = from;
    for (var i = 0; i < 7; i++) {
      if (current.weekday == weekday.index + 1) break;
      current = current.add(Duration(days: 1));
    }

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = current.add(Duration(days: 7));
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeHeadOriginMonthlyTickets(FutureTicket ticketTemplate,
      DateTime from, DateTime to, Duration offset, Transaction? txn) async {
    var current = DateTime(from.year, from.month, 1);
    current = current.add(offset);

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = DateTime(current.year, current.month + 1, 1);
      current = current.add(offset);
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeTailOriginMonthlyTickets(FutureTicket ticketTemplate,
      DateTime from, DateTime to, Duration offset, Transaction? txn) async {
    var current = DateTime(from.year, from.month + 1, 0);
    current = current.subtract(offset);

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = DateTime(current.year, current.month + 2, 0);
      current = current.subtract(offset);
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeAnnualTickets(FutureTicket ticketTemplate, DateTime from,
      DateTime to, Transaction? txn) async {
    var schedules = <DateTime>[];
    for (var current = DateTime(from.year, ticketTemplate.scheduledAt.month,
            ticketTemplate.scheduledAt.day);
        current.isBefore(to);
        current = DateTime(current.year + 1, current.month, current.day)) {
      schedules.add(current);
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeTicketsWithInterval(FutureTicket ticketTemplate,
      DateTime from, DateTime to, Duration interval, Transaction? txn) async {
    var current = from;

    // Adjusting the current time for the sequence to contain the scheduled time.
    var desiredOffset = ticketTemplate.scheduledAt.millisecondsSinceEpoch %
        interval.inMilliseconds;
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
      current = current.add(interval);
    }

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = current.add(interval);
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }
  // </repeat schedulers>
}

// holds the state of the future ticket preparation
// background worker is implemented in the another file: see background_worker/future_ticket_preparation.dart
class FutureTicketPreparationState extends NoSQL {
  // <constructor>
  // singleton pattern
  FutureTicketPreparationState._internal();
  static final FutureTicketPreparationState _instance =
      FutureTicketPreparationState._internal();

  static Future<FutureTicketPreparationState> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }
  // </constructor>

  static const String _keyTicketsNeededUntil = 'ticketNeededUntil';
  Future<DateTime> getNeededUntil() async {
    var val = await prefs!.getInt(_keyTicketsNeededUntil);
    if (val == null) {
      return farPast();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  /// This only updates the date if the date is later than the currently stored date.
  Future<void> needsUntil(DateTime date) async {
    var val = await prefs!.getInt(_keyTicketsNeededUntil);
    if (val == null || val < date.millisecondsSinceEpoch) {
      await prefs!.setInt(_keyTicketsNeededUntil, date.millisecondsSinceEpoch);
      var handler = FutureTicketPreparationEventHandler();
      await handler.onExpansionRequired(date, null);
    }
  }

  static const String _keyTicketsPreparedUntil = 'ticketsPreparedUntil';
  Future<DateTime> getPreparedUntil() async {
    var val = await prefs!.getInt(_keyTicketsPreparedUntil);
    if (val == null) {
      return farPast();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> setPreparedUntil(DateTime date) async {
    await prefs!.setInt(_keyTicketsPreparedUntil, date.millisecondsSinceEpoch);
  }

  static const String _keyTicketsPreparing = 'ticketsPreparing';
  Future<DateTime> getPreparingUntil() async {
    var val = await prefs!.getInt(_keyTicketsPreparing);
    if (val == null) {
      return farPast();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> setPreparingUntil(DateTime date) async {
    await prefs!.setInt(_keyTicketsPreparing, date.millisecondsSinceEpoch);
  }

  Future<bool> getTicketsPrepared() async {
    var needed = await getNeededUntil();
    var prepared = await getPreparedUntil();
    return needed.isBefore(prepared);
  }
}

// <dispached tasks>
// <DTO>
class Task extends DTO {
  final DateTime issuedAt;

  Task({super.id, required this.issuedAt});
}

// </DTO>
// <Table>
class PreparationTaskTable extends Table<Task> {
  @override
  covariant String tableName = 'DispatchedPreparationTasks';
  @override
  covariant DatabaseProvider dbProvider = InmemoryDatabaseProvider();

  static const Duration taskLimit = Duration(seconds: 10);

  // <field name>
  static const String issuedAtField = 'issuedAt';
  // </field name>

  // <constructor>
  PreparationTaskTable._internal();
  static final PreparationTaskTable _instance =
      PreparationTaskTable._internal();

  static Future<PreparationTaskTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory PreparationTaskTable.ref() => _instance;
  // </constructor>

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    await txn.execute(makeTable([
      makeIdField(),
      makeDateField(issuedAtField, notNull: true),
    ]));
  }

  @override
  Future<Task> interpret(Map<String, Object?> row, Transaction? txn) async {
    return Task(
      id: row[Table.idField] as int,
      issuedAt: intToDate(row[issuedAtField] as int)!,
    );
  }

  @override
  void validate(Task data) {} // Task is always valid

  @override
  Map<String, Object?> serialize(Task data) {
    return {
      issuedAtField: dateToInt(data.issuedAt)!,
    };
  }

  /// this methods registers a task to inmemory database and  returns the id of the task.
  Future<int> issueTask(DateTime issuedAt, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return issueTask(issuedAt, txn);
      });
    }

    return save(Task(issuedAt: issuedAt), txn);
  }

  /// this method marks the task as done and returns true if the task was in the table.
  /// If the task was not in the table, it returns false.
  /// That means the task is already done or it's kicked out by the [clearOverdueTasks] method.
  Future<bool> markDone(int id, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return markDone(id, txn);
      });
    }

    var isTaskInTable = await fetchById(id, txn) != null;
    if (isTaskInTable) {
      delete(id, txn);
      return true;
    } else {
      return false;
    }
  }

  Future<void> clearOverdueTasks(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return clearOverdueTasks(txn);
      });
    }

    var tasksAllowedOnlyAfter =
        dateToInt(DateTime.now())! - durationToInt(taskLimit)!;

    await txn.execute('''
      DELETE FROM $tableName
      WHERE $tasksAllowedOnlyAfter > $issuedAtField;
    ''');
  }

  Future<bool> doesTaskRemains(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return doesTaskRemains(txn);
      });
    }

    var queryResult = await txn.rawQuery('''
      SELECT COUNT(*) FROM $tableName;
    ''');

    return queryResult.isNotEmpty;
  }
}
// </Table>
// </dispached tasks>
