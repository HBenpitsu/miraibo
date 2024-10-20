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
    await Future.wait([
      // Make linker available
      _database!.execute('PRAGMA foreign_keys=true;'),
      createTables(),
    ]);
  }

  Future<void> createTables() async {
    final tables = [
      Receipts(),
      Categories(),
      DisplayTickets(),
    ];
    await Future.wait(tables.map((table) => table.prepare(_database!)));
  }
}

abstract class Table {
  abstract final String tableName;
  bool prepared = false;

  String makeTable(List<String> fields) {
    return '''CREATE TABLE IF NOT EXISTS '$tableName'(
          ${fields.join(', ')}
          )
        ''';
  }

  String makeIntegerField(String name, {bool notNull = false}) {
    return "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  }

  String makeIdField(String name) {
    return "'$name' INTEGER PRIMARY KEY AUTOINCREMENT";
  }

  String makeTextField(String name, {bool notNull = false}) {
    return "'$name' TEXT${notNull ? ' NOT NULL' : ''}";
  }

  String makeDateTimeField(String name, {bool notNull = false}) {
    return "'$name' INTEGER${notNull ? ' NOT NULL' : ''}";
  }

  String makeBooleanField(String name) {
    return "'$name' INTEGER NOT NULL, CHECK ($name = 0 OR $name = 1)";
  }

  String makeLinkerField(String name, String referenceTable) {
    return "'$name' INTEGER NOT NULL, FOREIGN KEY ($name) REFERENCES $referenceTable($name)";
  }

  Future<void> prepare(Database db);
}

class Receipts extends Table {
  @override
  covariant String tableName = 'Receipts';

  @override
  Future<void> prepare(Database db) async {
    await db.execute(makeTable([
      makeIdField('id'),
      makeTextField('category', notNull: true),
      makeTextField('supplement'),
      makeDateTimeField('registeredAt', notNull: true),
      makeIntegerField('amount', notNull: true),
      makeTextField('imageUrl'),
      makeBooleanField('confirmed'),
    ]));
  }
}

class Categories extends Table {
  @override
  covariant String tableName = 'Receipts';

  @override
  Future<void> prepare(Database db) async {
    await db.execute(makeTable([
      makeIdField('id'),
      makeTextField('name', notNull: true),
    ]));
  }
}

class DisplayTickets extends Table {
  @override
  covariant String tableName = 'DisplayTickets';

  @override
  Future<void> prepare(Database db) async {
    await db.execute(makeTable([
      makeIdField('id'),
      makeLinkerField(
        'target_category_map_linker',
        'CaDISPLAY_TICKET_TARGET_CATEGORY_MAP',
      ),
    ]));
  }
}
