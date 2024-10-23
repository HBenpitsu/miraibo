import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseProvider {
  // Singleton
  static final String dbName = 'miraibo.db';

  DatabaseProvider._internal();
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;

  Database? _database;

  Future<void> init() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    _database ??= await openDatabase(dbName);
  }

  Future<void> ensureAvailability() async {
    if (_database == null) {
      await init();
    }
  }

  Database get db => _database!;
}

// <general data structure>

/// DTO is a class that represents a data transfer object.
///
/// if the data is not yet saved in the database, [id] is null.
/// save method inserts the data into the database if [id] is null, otherwise updates the data.
///
/// delete method removes the data from the database.
///
abstract class DTO {
  final int? id;
  const DTO({this.id});

  Future<void> save();
  Future<void> delete();
}

/// Table is a class that represents a table in the database.
///
/// define constructor of subclasses following the pattern below:
///
/// ```
/// // singleton pattern
/// Table._internal();
/// static final Table _instance = Table._internal();
/// // asyncronous constructor which ensures the availability of the database
/// static Future<Table> use() async {
///   await _instance.ensureAvailability();
///   return _instance;
/// }
/// // factory method to provide the singleton instance which is not granted to be initialized
/// factory Table.ref() => _instance;
/// ```
///
abstract class Table<T extends DTO> {
  // <initialization>
  abstract String tableName;
  static final DatabaseProvider dbProvider = DatabaseProvider();

  bool prepared = false;

  /// prepare the table. this method is called after the database availability is ensured.
  Future<void> prepare();
  Future<void> ensureAvailability() async {
    if (!prepared) {
      await Table.dbProvider.ensureAvailability();
      await prepare();
      prepared = true;
    }
  }
  // </initialization>

  // <SQL generator>
  /// returns SQL query to create table
  String makeTable(List<String> fields) =>
      '''CREATE TABLE IF NOT EXISTS '$tableName'(
          ${fields.join(', ')}
          )
        ''';
  String makeIntegerField(String name, {bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeIdField({String? name}) =>
      "'${name ?? 'id'}' INTEGER PRIMARY KEY AUTOINCREMENT";
  String makeTEXTKeyField(String name) => "'$name' TEXT PRIMARY KEY";
  String makeTextField(String name, {bool notNull = false}) =>
      "'$name' TEXT${notNull ? ' NOT NULL' : ''}";
  String makeDateField(String name, {bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeBooleanField(String name) =>
      "'$name' INTEGER NOT NULL, CHECK ($name = 0 OR $name = 1)";
  String makeForeignField(String name, Table referenceTable,
          {String? rField, bool notNull = false}) =>
      "'$name' INTEGER${notNull ? ' NOT NULL' : ''}, FOREIGN KEY ($name) REFERENCES ${referenceTable.tableName}(${rField ?? name})";

  /// dummy function. linking feature is implemented in [linkerTable].
  /// No field is needed in the [keyTable] (that calls this method in the preparation phase) and [valueTable].
  /// Instead, the [linkerTable] has two foreign fields corresponds to ids of [keyTable] and value [valueTable].
  /// When interpreting the table which calls this method, the [linkerTable] is queried to fetch the values.
  String makeLinkerField(Linker linkerTable, {bool notNull = false}) => '';
  String makeEnumField(String name, List<Enum> values) =>
      "'$name' TEXT NOT NULL, CHECK (0 <= $name <= ${values.length})";
  // </SQL generator>

  // <(de)serializer>
  int? dateToInt(DateTime? date) => date == null
      ? null
      : date.millisecondsSinceEpoch ~/ 1000; // convert millisec to sec
  DateTime? intToDate(int? secondsSinceEpoch) => secondsSinceEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          secondsSinceEpoch * 1000); // convert sec to millisec
  // </(de)serializer>

  // <operations>
  Future<void> clear() async {
    await dbProvider.db.execute('DELETE FROM $tableName');
  }

  Future<T> interpret(Map<String, Object?> row, Transaction? txn);

  /// throws an exception if the data is invalid
  void validate(T data);

  /// do not include id field
  Map<String, Object?> serialize(T data);

  /// If there is some table that should be modified when the record is inserted or updated (such as LinkerTable), override this method.
  /// [id] is specified when the record is newly inserted. Otherwise (on update), [id] is null. Instead, [data] contains the id.
  Future<void> link(Transaction txn, T data, {int? id}) async {}

  /// If there is some table that should be modified when the record is deleted (such as LinkerTable), override this method.
  Future<void> unlink(Transaction txn, T data) async {}

  Future<List<T>> fetchAll(Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchAll(txn);
      });
    } else {
      return [
        for (var row in await txn.query(tableName)) await interpret(row, txn)
      ];
    }
  }

  Future<T?> fetchById(int? id, Transaction? txn) async {
    await ensureAvailability();
    if (id == null) return null;
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchById(id, txn);
      });
    } else {
      var result = await txn.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (result.isEmpty) return null;
      return interpret(result.first, txn);
    }
  }

  Future<List<T>> fetchByIds(List<int> ids, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchByIds(ids, txn);
      });
    } else {
      return [
        for (var row
            in await txn.query(tableName, where: 'id IN (${ids.join(', ')})'))
          await interpret(row, txn)
      ];
    }
  }

  Future<int> insert(T data, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return insert(data, txn);
      });
    } else {
      validate(data);
      if (data.id != null) {
        throw IlligalUsageException('tried to insert data with id');
      }
      var id = await txn.insert(tableName, serialize(data));
      await link(txn, data, id: id);
      return id;
    }
  }

  Future<int> update(T data, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return update(data, txn);
      });
    } else {
      validate(data);
      if (data.id == null) {
        throw IlligalUsageException('tried to update data without id');
      }
      var id = await txn.update(tableName, serialize(data),
          where: 'id = ?', whereArgs: [data.id]);
      await link(txn, data);
      return id;
    }
  }

  Future<int> delete(T data, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return delete(data, txn);
      });
    } else {
      validate(data);
      if (data.id == null) {
        throw IlligalUsageException('tried to delete data without id');
      }
      var id =
          await txn.delete(tableName, where: 'id = ?', whereArgs: [data.id]);
      await unlink(txn, data);
      return id;
    }
  }

  Future<int> save(T data) async {
    if (data.id == null) {
      return insert(data, null);
    } else {
      return update(data, null);
    }
  }
  // </operations>

  // <helper/>
  Future<void> query(
      Future<void> Function(Transaction txn, String tableName) query) async {
    await ensureAvailability();
    await dbProvider.db.transaction((txn) => query(txn, tableName));
  }
}

class Link extends DTO {
  final int keyId;
  final int valueId;

  const Link({super.id, required this.keyId, required this.valueId});

  @override
  Future<void> save() async {
    throw ShouldNotBeCalledException('Link should not be saved directly');
  }

  @override
  Future<void> delete() async {
    throw ShouldNotBeCalledException('Link should not be deleted directly');
  }
}

mixin Linker<Kv extends DTO, Vv extends DTO> on Table<Link> {
  Future<List<Vv>> fetchValues(int keyId, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return fetchValues(keyId, txn);
      });
    } else {
      // In terms of performance, it is better to use a single query to fetch all values. (instead of calling [fetchValuesByIds])
      // However, it is not possible to know what table should be queried for abstract [Linker]-mixin.
      // It is trade-off between performance and maintainability. (I chose maintainability)
      List<int> valueIds = [
        for (var row in await txn.query(tableName,
            // eliminate duplicates
            distinct: true,
            columns: ['valueId'],
            where: 'keyId = ?',
            whereArgs: [keyId]))
          row['valueId'] as int
      ];
      return fetchValuesByIds(valueIds, txn);
    }
  }

  /// Wrapper of [fetchByIds] of `Table<Vv>`
  Future<List<Vv>> fetchValuesByIds(List<int> valueIds, Transaction? txn);

  Future<void> linkValues(int keyId, List<Vv> values, Transaction? txn) async {
    await ensureAvailability();
    if (txn == null) {
      // if transaction is not provided, create a new one and use it.
      await Table.dbProvider.db.transaction((txn) async {
        await linkValues(keyId, values, txn);
      });
    } else {
      await txn.delete(tableName, where: 'keyId = ?', whereArgs: [keyId]);
      if (values.isEmpty) return;
      await txn.execute('''
        INSERT INTO $tableName (keyId, valueId)
        VALUES ${values.map((val) => val.id == null ? '' : '($keyId, ${val.id})').join(', ')};
      ''');
    }
  }

  Table<Kv> get keyTable;
  Table<Vv> get valueTable;

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeForeignField('keyId', keyTable, rField: 'id', notNull: true),
      makeForeignField('valueId', valueTable, rField: 'id', notNull: true),
    ]));
  }

  @override
  void validate(Link data) {} // always valid

  @override
  Map<String, Object?> serialize(Link data) {
    return {
      'key': data.keyId,
      'value': data.valueId,
    };
  }

  @override
  Future<Link> interpret(Map<String, Object?> row, Transaction? txn) async {
    return Link(
        id: row['id'] as int,
        keyId: row['key'] as int,
        valueId: row['value'] as int);
  }
}

// </general data structure>

// <user exception>
class ShouldNotBeCalledException implements Exception {
  final String message;
  const ShouldNotBeCalledException(this.message);
  @override
  String toString() => message;
}

class InvalidDataException implements Exception {
  final String message;
  const InvalidDataException(this.message);
  @override
  String toString() => message;
}

class IlligalUsageException implements Exception {
  final String message;
  const IlligalUsageException(this.message);
  @override
  String toString() => message;
}
// </user exception>

// <helper>
Future<void> useTables(
    List<Table> tables, Future<void> Function(Database db) query) async {
  await Future.wait(tables.map((table) => table.ensureAvailability()));
  await query(DatabaseProvider().db);
}
// </helper>
