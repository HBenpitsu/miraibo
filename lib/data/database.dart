import 'dart:io';

import 'package:miraibo/data/ticketData.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;

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

  int? dateToInt(DateTime? date) => date == null
      ? null
      : date.millisecondsSinceEpoch ~/ 1000; // convert millisec to sec
  DateTime? intToDate(int? secondsSinceEpoch) => secondsSinceEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          secondsSinceEpoch * 1000); // convert sec to millisec

  Future<void> clear() async {
    await dbProvider.db.execute('DELETE FROM $tableName');
  }

  Future<T> interpret(Map<String, Object?> row);

  /// throws an exception if the data is invalid
  void validate(T data);
  Map<String, Object?> serialize(T data);

  /// If there is linkerField(s), override this method to update linkerTable.
  /// [id] is specified when the record is newly inserted.
  Future<void> link(T data, {int? id}) async {}

  /// If there is linkerField(s) or linked by some table, override this method to update linkerTable.
  Future<void> unlink(T data) async {}

  Future<List<T>> fetchAll() async {
    await ensureAvailability();
    return [
      for (var row in await dbProvider.db.query(tableName)) await interpret(row)
    ];
  }

  Future<T?> fetchById(int? id) async {
    if (id == null) return null;
    await ensureAvailability();
    var result =
        await dbProvider.db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return interpret(result.first);
  }

  Future<List<T>> fetchByIds(List<int> ids) async {
    await ensureAvailability();
    return [
      for (var row in await dbProvider.db
          .query(tableName, where: 'id IN (${ids.join(', ')})'))
        await interpret(row)
    ];
  }

  Future<int> insert(T data) async {
    await ensureAvailability();
    validate(data);
    if (data.id != null) {
      throw Exception('tried to insert data with id');
    }
    return await dbProvider.db.transaction((txn) async {
      var id = await txn.insert(tableName, serialize(data));
      await link(data, id: id);
      return id;
    });
  }

  Future<int> update(T data) async {
    await ensureAvailability();
    validate(data);
    if (data.id == null) {
      throw Exception('tried to update data without id');
    }
    return await dbProvider.db.transaction((txn) async {
      var id = await dbProvider.db.update(tableName, serialize(data),
          where: 'id = ?', whereArgs: [data.id]);
      await link(data);
      return id;
    });
  }

  Future<int> delete(T data) async {
    await ensureAvailability();
    return await dbProvider.db.transaction((txn) async {
      var id = await dbProvider.db
          .delete(tableName, where: 'id = ?', whereArgs: [data.id]);
      await unlink(data);
      return id;
    });
  }

  Future<int> save(T data) async {
    if (data.id == null) {
      return await insert(data);
    } else {
      return await update(data);
    }
  }
}

class Link extends DTO {
  final int keyId;
  final int valueId;

  const Link({super.id, required this.keyId, required this.valueId});

  @override
  Future<void> save() async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete() async {
    throw UnimplementedError();
  }
}

mixin Linker<Kv extends DTO, Vv extends DTO> on Table<Link> {
  Future<List<Vv>> fetchValues(int keyId) async {
    await ensureAvailability();
    List<int> valueIds = [
      for (var row in await Table.dbProvider.db
          .query(tableName, where: 'keyId = ?', whereArgs: [keyId]))
        row['valueId'] as int
    ];
    return await fetchValuesByIds(valueIds);
  }

  /// Wrapper of [fetchByIds] of `Table<Vv>`
  Future<List<Vv>> fetchValuesByIds(List<int> valueIds);

  Future<void> linkValues(int keyId, List<Vv> values) async {
    await ensureAvailability();
    await Table.dbProvider.db.transaction((txn) async {
      await txn.delete(tableName, where: 'keyId = ?', whereArgs: [keyId]);
      if (values.isEmpty) return;
      await txn.rawInsert('''
        INSERT INTO $tableName (keyId, valueId)
        VALUES ${values.map((val) => val.id == null ? '' : '($keyId, ${val.id})').join(', ')}
      ''');
    });
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
      'id': data.id,
      'key': data.keyId,
      'value': data.valueId,
    };
  }

  @override
  Future<Link> interpret(Map<String, Object?> row) async {
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
// </user exception>