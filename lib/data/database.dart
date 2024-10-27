import 'dart:io';
import 'dart:developer' as dev;

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

  Future<void> clear() async {
    await ensureAvailability();
    await _database!.close();
    File file = File(_database!.path);
    file.deleteSync();
  }
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

  /// [id] is null if the data is not yet saved in the database.
  /// do not generate [id] by yourself. [id] is assigned by the database.
  const DTO({this.id});
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
/// static Future<Table> use(Transaction? txn) async {
///   await _instance.ensureAvailability(txn);
///   return _instance;
/// }
/// // factory method to provide the singleton instance which is not granted to be initialized
/// factory Table.ref() => _instance;
/// ```
///
abstract class Table<T extends DTO> {
  // <field name>
  static const String idField = 'id';
  // </field name>

  // <initialization>
  abstract String tableName;
  static final DatabaseProvider dbProvider = DatabaseProvider();

  bool prepared = false;

  /// prepare the table. this method is called after the database availability is ensured.
  Future<void> prepare(Transaction? txn);
  Future<void> ensureAvailability(Transaction? txn) async {
    if (!prepared) {
      await Table.dbProvider.ensureAvailability();
      await prepare(txn);
      prepared = true;
    }
  }
  // </initialization>

  // <reseter>
  Future<void> clear() async {
    try {
      await dbProvider.db.execute('DROP TABLE $tableName');
    } catch (e) {
      dev.log(e.toString(), name: 'DatabaseProvider clear failed info: ');
    }
  }
  // </reseter>

  // <SQL generator>
  /// returns SQL query to create table
  String makeTable(List<String> fields) {
    var foreignKeys = fields.where((field) => field.startsWith('FOREIGN KEY'));
    var otherFields = fields.where((field) => !field.startsWith('FOREIGN KEY'));
    return '''CREATE TABLE IF NOT EXISTS '$tableName'(
          ${[
      ...otherFields,
      ...foreignKeys,
    ].join(', ')}
          )
        ''';
  }

  String makeIntegerField(String name, {bool notNull = false}) =>
      "$name INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeIdField({String? name}) =>
      "${name ?? idField} INTEGER PRIMARY KEY AUTOINCREMENT";
  String makeTEXTKeyField(String name) => "$name TEXT PRIMARY KEY";
  String makeTextField(String name, {bool notNull = false}) =>
      "$name TEXT ${notNull ? ' NOT NULL' : ''}";
  String makeDateField(String name, {bool notNull = false}) =>
      "$name INTEGER${notNull ? ' NOT NULL' : ''}";
  String makeBooleanField(String name) =>
      "$name INTEGER NOT NULL CHECK ($name = 0 OR $name = 1)";
  String makeEnumField(String name, List<Enum> values) =>
      "$name INTEGER NOT NULL CHECK (0 <= $name AND $name <= ${values.length})";
  List<String> makeForeignField(String name, Table referenceTable,
          {String? rField, bool notNull = false}) =>
      [
        "$name INTEGER${notNull ? ' NOT NULL' : ''}",
        "FOREIGN KEY ($name) REFERENCES ${referenceTable.tableName}(${rField ?? name})"
      ];
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

  // <basic methods>
  Future<T> interpret(Map<String, Object?> row, Transaction? txn);

  /// throws an exception if the data is invalid
  void validate(T data);

  /// do not include id field
  Map<String, Object?> serialize(T data);
  // </basic methods>

  // <linking handlers>
  /// If there is some table that should be modified when the record is inserted or updated (such as LinkerTable), override this method.
  /// [id] is specified when the record is newly inserted. Otherwise (on update), [id] is null. Instead, [data] contains the id.
  Future<void> link(Transaction txn, T data, {int? id}) async {}

  /// If there is some table that should be modified when the record is deleted (such as LinkerTable), override this method.
  Future<void> unlink(Transaction txn, T data) async {}
  // </linking handlers>

  // <operations>
  Future<List<T>> fetchAll(Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchAll(txn);
      });
    }

    await ensureAvailability(txn);

    return [
      for (var row in await txn.query(tableName)) await interpret(row, txn)
    ];
  }

  Future<T?> fetchById(int? id, Transaction? txn) async {
    if (id == null) return null;

    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchById(id, txn);
      });
    }

    await ensureAvailability(txn);

    var result =
        await txn.query(tableName, where: '$idField = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return interpret(result.first, txn);
  }

  Future<List<T>> fetchByIds(List<int> ids, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return fetchByIds(ids, txn);
      });
    }

    await ensureAvailability(txn);

    return [
      for (var row in await txn.query(tableName,
          where: '$idField IN (${ids.join(', ')})'))
        await interpret(row, txn)
    ];
  }

  Future<int> insert(T data, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return insert(data, txn);
      });
    }

    await ensureAvailability(txn);

    validate(data);
    if (data.id != null) {
      throw IlligalUsageException('tried to insert data with id');
    }
    var id = await txn.insert(tableName, serialize(data));
    await link(txn, data, id: id);

    return id;
  }

  Future<int> update(T data, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return update(data, txn);
      });
    }

    await ensureAvailability(txn);

    validate(data);
    if (data.id == null) {
      throw IlligalUsageException('tried to update data without id');
    }
    var id = await txn.update(tableName, serialize(data),
        where: '$idField = ?', whereArgs: [data.id]);
    await link(txn, data);
    return id;
  }

  // TODO: whole data is unnecessary. only id is enough.
  Future<int> delete(T data, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return delete(data, txn);
      });
    }

    // TODO: calling ensureAvailability is redundant. check if it is really necessary.
    await ensureAvailability(txn);

    validate(data);
    if (data.id == null) {
      throw IlligalUsageException('tried to delete data without id');
    }
    var id = await txn
        .delete(tableName, where: '$idField = ?', whereArgs: [data.id]);
    await unlink(txn, data);
    return id;
  }

  Future<int> save(T data, Transaction? txn) async {
    if (data.id == null) {
      return insert(data, txn);
    } else {
      return update(data, txn);
    }
  }
  // </operations>

  // <helper/>
  Future<void> query(
      Future<void> Function(Transaction txn, String tableName) query) async {
    await ensureAvailability(null);
    await dbProvider.db.transaction((txn) => query(txn, tableName));
  }
}

class Link extends DTO {
  final int keyId;
  final int valueId;

  const Link({super.id, required this.keyId, required this.valueId});
}

mixin Linker<Kv extends DTO, Vv extends DTO> on Table<Link> {
  // <field name>
  static const String keyIdField = 'keyId';
  static const String valueIdField = 'valueId';
  // </field name>

  Future<List<Vv>> fetchValues(int keyId, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return fetchValues(keyId, txn);
      });
    }

    await ensureAvailability(txn);

    // In terms of performance, it is better to use a single query to fetch all values. (instead of calling [fetchValuesByIds])
    // However, it is not possible to know what table should be queried for abstract [Linker]-mixin.
    // It is trade-off between performance and maintainability. (I chose maintainability)
    List<int> valueIds = [
      for (var row in await txn.query(tableName,
          // eliminate duplicates
          distinct: true,
          columns: [valueIdField],
          where: '$keyIdField = ?',
          whereArgs: [keyId]))
        row[valueIdField] as int
    ];

    return fetchValuesByIds(valueIds, txn);
  }

  /// Wrapper of [fetchByIds] of `Table<Vv>`
  Future<List<Vv>> fetchValuesByIds(List<int> valueIds, Transaction? txn);

  Future<void> linkValues(int keyId, List<Vv> values, Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return linkValues(keyId, values, txn);
      });
    }

    await ensureAvailability(txn);

    await txn.delete(tableName, where: '$keyIdField = ?', whereArgs: [keyId]);
    if (values.isEmpty) return;
    await txn.execute('''
        INSERT INTO $tableName ($keyIdField, $valueIdField)
        VALUES ${values.map((val) => val.id == null ? '' : '($keyId, ${val.id})').join(', ')};
      ''');
    return;
  }

  Table<Kv> get keyTable;
  Table<Vv> get valueTable;

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return Table.dbProvider.db.transaction((txn) async {
        return prepare(txn);
      });
    }

    await txn.execute(makeTable([
      makeIdField(),
      ...makeForeignField(keyIdField, keyTable,
          rField: Table.idField, notNull: true),
      ...makeForeignField(valueIdField, valueTable,
          rField: Table.idField, notNull: true),
    ]));
  }

  @override
  void validate(Link data) {} // always valid

  @override
  Map<String, Object?> serialize(Link data) {
    return {
      keyIdField: data.keyId,
      valueIdField: data.valueId,
    };
  }

  @override
  Future<Link> interpret(Map<String, Object?> row, Transaction? txn) async {
    return Link(
        id: row[Table.idField] as int,
        keyId: row[keyIdField] as int,
        valueId: row[valueIdField] as int);
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
Future<void> useTables(List<Table> tables,
    Future<void> Function(Transaction txn) query, Transaction? txn) async {
  if (txn == null) {
    return Table.dbProvider.db.transaction((txn) async {
      return useTables(tables, query, txn);
    });
  }

  await Future.wait(tables.map((table) => table.ensureAvailability(txn)));
  await query(txn);
}
// </helper>
