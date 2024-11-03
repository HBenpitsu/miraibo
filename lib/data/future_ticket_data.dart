import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:miraibo/data/database.dart';
import 'package:miraibo/data/ticket_data.dart';
import 'package:miraibo/data/category_data.dart';
import 'package:miraibo/data/general_enum.dart';

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

  LogRecord asLogPreset() {
    return LogRecord(
        category: category,
        supplement: supplement,
        registorationDate: scheduledAt,
        amount: amount.toInt());
  }
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
      int id, Table<FutureTicketFactory> kind, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return eliminateAllByFactory(id, kind, txn);
      });
    }

    var whereStatement = switch (kind) {
      Table<ScheduleRecord> _ => '$scheduleField = $id',
      Table<EstimationRecord> _ => '$estimationField = $id',
      _ => UnimplementedError('The factory kind $kind is not supported.'),
    };

    return txn.execute('DELETE FROM $tableName WHERE $whereStatement;');
  }

  Future<void> updateAllByFactory(FutureTicketFactory factoryTicket,
      FutureTicket template, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return updateAllByFactory(factoryTicket, template, txn);
      });
    }

    var whereStatement = switch (factoryTicket) {
      ScheduleRecord schedule => '$scheduleField = ${schedule.id}',
      EstimationRecord estimation => '$estimationField = ${estimation.id}',
      _ =>
        UnimplementedError('The factory kind $factoryTicket is not supported.'),
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

  Future<List<ScheduleRecord>> fetchTodaysSchedule(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchTodaysSchedule(txn);
      });
    }

    var today = dateToInt(DateTime.now())!;

    var query = '''
      SELECT $scheduleField FROM $tableName
      WHERE DATE($scheduledAtField) = DATE($today)
        AND $scheduleField IS NOT NULL;
    ''';
    var result = await txn.rawQuery(query);

    var scheduleTable = await ScheduleTable.use(txn);
    return scheduleTable
        .fetchByIds([for (var rec in result) rec[scheduleField] as int], txn);
  }

  Future<void> cleanUp(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return cleanUp(txn);
      });
    }

    return txn.execute('''
          DELETE FROM $tableName
          WHERE $scheduledAtField < ${dateToInt(DateTime.now())};
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
        ),
      ''';
    }

    // remove the last comma and add a semicolon
    sql = '${sql.substring(0, sql.length - 1)};';

    await txn.rawInsert(sql);
  }

  Future<void> makeTicketsEveryday(FutureTicket ticketTemplate, DateTime from,
      DateTime to, Transaction? txn) async {
    await makeTicketsWithInterval(
        ticketTemplate, from, to, Duration(days: 1), txn);
  }

  Future<void> makeWeeklyTickets(FutureTicket ticketTemplate, DateTime from,
      DateTime to, Weekday weekday, Transaction? txn) async {
    var current = from;
    for (var i = 0; i < 7; i++) {
      if (current.weekday == weekday.index + 1) break;
      current = current.add(Duration(days: 1));
    }

    await makeTicketsWithInterval(
        ticketTemplate, current, to, Duration(days: 7), txn);
  }

  Future<void> makeHeadOriginMonthlyTickets(FutureTicket ticketTemplate,
      DateTime from, DateTime to, Duration offset, Transaction? txn) async {
    var current = DateTime(from.year, from.month, 1);
    current.add(offset);

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = DateTime(current.year, current.month + 1, 1);
      current.add(offset);
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
    var current = DateTime(from.year, ticketTemplate.scheduledAt.month,
        ticketTemplate.scheduledAt.day);

    var schedules = <DateTime>[];
    while (current.isBefore(to)) {
      schedules.add(current);
      current = DateTime(current.year + 1, current.month, current.day);
    }

    await _insertTicketsAtOnce(ticketTemplate, schedules, txn);
  }

  Future<void> makeTicketsWithInterval(FutureTicket ticketTemplate,
      DateTime from, DateTime to, Duration interval, Transaction? txn) async {
    var current = from;
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

  // <tickets needed until>
  static const String _keyTicketsNeededUntil = 'ticketNeededUntil';

  Future<DateTime> getNeededUntil() async {
    var val = await prefs.getInt(_keyTicketsNeededUntil);
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  /// This only updates the date if the date is later than the currently stored date.
  Future<void> updateNeededUntil(DateTime date) async {
    var val = await prefs.getInt(_keyTicketsNeededUntil);
    if (val == null || val < date.millisecondsSinceEpoch) {
      await prefs.setInt(_keyTicketsNeededUntil, date.millisecondsSinceEpoch);
    }
  }
  // </tickets needed until>

  // <tickets prepared until>
  static const String _keyTicketsPreparedUntil = 'ticketsPreparedUntil';

  Future<DateTime> getPreparedUntil() async {
    var val = await prefs.getInt(_keyTicketsPreparedUntil);
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> setPreparedUntil(DateTime date) async {
    await prefs.setInt(_keyTicketsPreparedUntil, date.millisecondsSinceEpoch);
  }
  // </tickets prepared until>

  // <tickets preparing>
  static const String _keyTicketsPreparing = 'ticketsPreparing';
  Future<DateTime> getPreparingUntil() async {
    var val = await prefs.getInt(_keyTicketsPreparing);
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> setPreparingUntil(DateTime date) async {
    await prefs.setInt(_keyTicketsPreparing, date.millisecondsSinceEpoch);
  }
  // </tickets preparing>

  // <tickets prepared>
  static const String _keyTicketsPrepared = 'ticketsPrepared';
  // TODO: rewrite this to return the value according to preparingUntil and preparedUntil
  Future<bool> getTicketsPrepared() async {
    return await prefs.getBool(_keyTicketsPrepared) ?? false;
  }

  Future<void> setTicketsPrepared(bool val) async {
    await prefs.setBool(_keyTicketsPrepared, val);
  }
  // </tickets prepared>
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
