import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './database.dart';
import 'ticket_data.dart';
import 'category_data.dart';
import './general_enum.dart';

// <future ticket factory abstractor>
// The Future Ticket Factory is responsible for producing future tickets.
// Since both schedules and estimations serve as sources for future tickets, this abstraction is used to represent them.

// This mixin marks up classes that can be used as a factory for future tickets.
// It is introduced to avoid the use of dynamic types.
mixin FutureTicketFactory on DTO {}

class FutureTicketFactoryAbstractor extends DTO {
  final ScheduleRecord? schedule;
  final EstimationRecord? estimation;
  const FutureTicketFactoryAbstractor({this.schedule, this.estimation});
}

class FutureTicketFactoryAbstractorTable
    extends Table<FutureTicketFactoryAbstractor> {
  @override
  covariant String tableName = 'FutureTicketFactories';

  // <field name>
  static const String scheduleField = 'schedule';
  static const String estimationField = 'estimation';
  // </field name>

  // <constructor>
  FutureTicketFactoryAbstractorTable._internal();
  static final FutureTicketFactoryAbstractorTable _instance =
      FutureTicketFactoryAbstractorTable._internal();

  static Future<FutureTicketFactoryAbstractorTable> use(
      Transaction? txn) async {
    await _instance.ensureAvailability(txn);
    return _instance;
  }

  factory FutureTicketFactoryAbstractorTable.ref() => _instance;
  // </constructor>

  // <shared features>
  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    await txn.execute(makeTable([
      makeIdField(),
      ...makeForeignField(scheduleField, ScheduleTable.ref(),
          rField: Table.idField),
      ...makeForeignField(estimationField, EstimationTable.ref(),
          rField: Table.idField),
    ]));
  }

  @override
  Future<void> clear() {
    FutureTicketTable.ref().clear();
    return super.clear();
  }

  @override
  Future<FutureTicketFactoryAbstractor> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var scheduleTable = await ScheduleTable.use(txn);
    var estimationTable = await EstimationTable.use(txn);
    return FutureTicketFactoryAbstractor(
      schedule: await scheduleTable.fetchById(row[scheduleField] as int, txn),
      estimation:
          await estimationTable.fetchById(row[estimationField] as int, txn),
    );
  }

  @override
  void validate(FutureTicketFactoryAbstractor data) {
    if (data.schedule?.id == null && data.estimation?.id == null) {
      throw InvalidDataException(
          'However schedule or estimation should be set for future ticket factory, both do not exist in the database. ');
    } else if (data.schedule != null && data.estimation != null) {
      throw InvalidDataException(
          'schedule and estimation cannot be set at the same time for future ticket factory.');
    }
  }

  @override
  Map<String, Object?> serialize(FutureTicketFactoryAbstractor data) {
    return {
      scheduleField: data.schedule?.id,
      estimationField: data.estimation?.id,
    };
  }
  // </shared features>

  /// return null when not found
  Future<int?> getFactoryIdOf(
      String fieldName, int factoryInstanceId, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return getFactoryIdOf(fieldName, factoryInstanceId, txn);
      });
    }

    await ensureAvailability(txn);

    var res = await txn.rawQuery('''
      SELECT ${Table.idField} FROM $tableName
      WHERE $fieldName = $factoryInstanceId;
    ''');
    if (res.isEmpty) {
      return null;
    }
    return res.first[Table.idField] as int;
  }

  // <factory update handlers>
  Future<void> _loadScheduleAsFactory(
      ScheduleRecord schedule, Transaction txn) async {}

  Future<void> _loadEstimationAsFactory(
      EstimationRecord estimation, Transaction txn) async {}

  Future<void> onFactoryUpdated(
      FutureTicketFactory updatedRecord, Transaction txn) async {
    switch (updatedRecord) {
      case ScheduleRecord schedule:
        return _loadScheduleAsFactory(schedule, txn);
      case EstimationRecord estimation:
        return _loadEstimationAsFactory(estimation, txn);
      default:
        throw UnimplementedError(
            'The factory kind $updatedRecord is not supported.');
    }
  }

  Future<void> _deleteScheduleAsFactory(
      ScheduleRecord schedule, Transaction txn) async {
    await ensureAvailability(txn);

    if (schedule.id == null) {
      throw InvalidDataException(
          'The schedule should have an id to be deleted as a factory.');
    }

    var id = await getFactoryIdOf(scheduleField, schedule.id!, txn);

    if (id == null) {
      throw InvalidDataException(
          'The schedule is not found in the factory table.');
    }

    var futureTicketTable = await FutureTicketTable.use(txn);
    await futureTicketTable.eliminateAllByFactory(id, txn);
    await txn.execute('''
      DELETE FROM $tableName
      WHERE ${Table.idField} = $id;
    ''');
  }

  Future<void> _deleteEstimationAsFactory(
      EstimationRecord estimation, Transaction txn) async {}

  Future<void> onFactoryDeleted(
      FutureTicketFactory deletedRecord, Transaction txn) async {
    switch (deletedRecord) {
      case ScheduleRecord schedule:
        return _deleteScheduleAsFactory(schedule, txn);
      case EstimationRecord estimation:
        return _deleteEstimationAsFactory(estimation, txn);
      default:
        throw UnimplementedError(
            'The factory kind $deletedRecord is not supported.');
    }
  }
  // </factory update handlers>
}

class FutureTicket extends DTO {
  final FutureTicketFactoryAbstractor? ticketFactory;
  final Category category;
  final String supplement;
  final DateTime scheduledAt;
  final int amount;

  FutureTicket({
    super.id,
    this.ticketFactory,
    required this.category,
    required this.supplement,
    required this.scheduledAt,
    required this.amount,
  });
}

class FutureTicketTable extends Table<FutureTicket> with HaveCategoryField {
  @override
  covariant String tableName = 'FutureTickets';

  // <field name>
  static const String factoryField = 'factory';
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
      return Table.dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    bindCategoryIntegrator();
    await txn.execute(makeTable([
      makeIdField(),
      ...makeForeignField(
          factoryField, FutureTicketFactoryAbstractorTable.ref(),
          rField: Table.idField, notNull: true),
      ...makeForeignField(categoryField, CategoryTable.ref(),
          rField: Table.idField, notNull: true),
      makeTextField(supplementField, notNull: true),
      makeDateField(scheduledAtField, notNull: true),
      makeIntegerField(amountField, notNull: true),
    ]));
  }

  @override
  Future<void> clear() {
    FutureTicketFactoryAbstractorTable.ref().clear();
    FutureTicketPreparationState.ref().clear();
    return super.clear();
  }

  @override
  Future<FutureTicket> interpret(
      Map<String, Object?> row, Transaction? txn) async {
    var factoryTable = await FutureTicketFactoryAbstractorTable.use(txn);
    var categoryTable = await CategoryTable.use(txn);
    return FutureTicket(
      id: row[Table.idField] as int,
      ticketFactory:
          (await factoryTable.fetchById(row[factoryField] as int, txn))!,
      category:
          (await categoryTable.fetchById(row[categoryField] as int, txn))!,
      supplement: row[supplementField] as String,
      scheduledAt: intToDate(row[scheduledAtField] as int)!,
      amount: row[amountField] as int,
    );
  }

  @override
  void validate(FutureTicket data) {
    if (data.ticketFactory == null) {
      throw InvalidDataException(
          'The ticket factory should be set for future ticket.');
    }
  } // always valid

  @override
  Map<String, Object?> serialize(FutureTicket data) {
    return {
      factoryField: data.ticketFactory!.id,
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

  Future<void> eliminateAllByFactory(int factoryId, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return eliminateAllByFactory(factoryId, txn);
      });
    }

    await ensureAvailability(txn);

    return txn.execute('''
            DELETE FROM $tableName
            WHERE $factoryField = $factoryId;
          ''');
  }

  Future<void> updateAllByFactory(
      int factoryId, FutureTicket template, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return updateAllByFactory(factoryId, template, txn);
      });
    }

    await ensureAvailability(txn);

    return txn.execute('''
            UPDATE $tableName
            SET
              $categoryField = ${template.category.id},
              $supplementField = '${template.supplement}',
              $amountField = ${template.amount}
            WHERE $factoryField = $factoryId;
          ''');
  }

  Future<void> makeWeeklyTickets(FutureTicket ticketTemplate, DateTime from,
      DateTime to, DayOfWeek dayOfWeek, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return makeWeeklyTickets(ticketTemplate, from, to, dayOfWeek, txn);
      });
    }

    await ensureAvailability(txn);

    throw UnimplementedError();
  }

  Future<void> cleanUp(Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return cleanUp(txn);
      });
    }

    await ensureAvailability(txn);

    return txn.execute('''
          DELETE FROM $tableName
          WHERE $scheduledAtField < ${dateToInt(DateTime.now())};
        ''');
  }
}

class FutureTicketPreparationState {
  // <constructor>
  // singleton pattern
  FutureTicketPreparationState._internal();
  static final FutureTicketPreparationState _instance =
      FutureTicketPreparationState._internal();

  // ensure that the instance is available
  static Future<FutureTicketPreparationState> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  // get the instance anyway
  factory FutureTicketPreparationState.ref() => _instance;
  // </constructor>

  // <initialization>
  SharedPreferences? _prefs;
  Future<void> ensureAvailability() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  // </initialization>

  Future<void> clear() async {
    await ensureAvailability();
    await _prefs!.clear();
  }

  // <tickets needed until>
  static const String _keyTicketsNeededUntil = 'ticketNeededUntil';

  Future<DateTime> getNeededUntil() async {
    await ensureAvailability();
    var val = _prefs!.getInt(_keyTicketsNeededUntil);
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  /// This only updates the date if the date is later than the currently stored date.
  Future<void> updateNeededUntil(DateTime date) async {
    await ensureAvailability();
    var val = _prefs!.getInt(_keyTicketsNeededUntil);
    if (val == null || val < date.millisecondsSinceEpoch) {
      await _prefs!.setInt(_keyTicketsNeededUntil, date.millisecondsSinceEpoch);
    }
  }
  // </tickets needed until>

  // <tickets prepared until>
  static const String _keyTicketsPreparedUntil = 'ticketsPreparedUntil';

  Future<DateTime> getPreparedUntil() async {
    await ensureAvailability();
    var val = _prefs!.getInt(_keyTicketsPreparedUntil);
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> setPreparedUntil(DateTime date) async {
    await ensureAvailability();
    await _prefs!.setInt(_keyTicketsPreparedUntil, date.millisecondsSinceEpoch);
  }
  // </tickets prepared until>
}
