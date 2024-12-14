import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
// import 'package:shared_preferences_web/shared_preferences_web.dart'; // this package cause compile error
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

// <relational database>
// <database provider>
abstract class RelationalDatabaseProvider {
  Database? _database;
  String get dbName;
  Future<void> ensureAvailability() async {
    if (_database != null) {
      return;
    }
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    _database ??= await openDatabase(dbName);
  }

  Future<void> clear() async {
    await ensureAvailability();
    await _database!.close();
    File file = File(_database!.path);
    await file.delete();
    _database = null;
  }

  Database get db => _database!;
}

class MainDatabaseProvider extends RelationalDatabaseProvider {
  // Singleton
  MainDatabaseProvider._internal();
  static final MainDatabaseProvider _instance =
      MainDatabaseProvider._internal();
  factory MainDatabaseProvider() => _instance;

  @override
  String get dbName => 'miraibo.db';
}

class QueueDatabaseProvider extends RelationalDatabaseProvider {
  // Singleton
  QueueDatabaseProvider._internal();
  static final QueueDatabaseProvider _instance =
      QueueDatabaseProvider._internal();
  factory QueueDatabaseProvider() => _instance;

  @override
  String get dbName => 'miraibo_queue.db';
}
// </database provider>

// <transaction provider>
abstract class TransactionProvider<T> {
  RelationalDatabaseProvider get dbProvider;

  Future<T> execute() async {
    await dbProvider.ensureAvailability();
    return dbProvider.db.transaction((txn) async {
      return process(txn);
    });
  }

  Future<T> process(Transaction txn);
}

abstract class SubTransactionProvider<T> {
  Future<T> execute(Transaction txn) {
    return process(txn);
  }

  Future<T> process(Transaction txn);
}
// </transaction provider>
// </relational database>

// <no relational database>
class KeyValueDatabaseProvider {
  KeyValueDatabaseProvider._internal();
  static final KeyValueDatabaseProvider _instance =
      KeyValueDatabaseProvider._internal();
  factory KeyValueDatabaseProvider() {
    _instance.ensureAvailability();
    return _instance;
  }
  SharedPreferencesAsync get db => _prefs!;

  SharedPreferencesAsync? _prefs;
  void ensureAvailability() {
    if (_prefs != null) {
      return;
    }
    if (kIsWeb) {
      // throw Exception('unable to use SharedPreferencesAsync in this platform');
      // just do nothing. It's fine.
    } else if (Platform.isLinux) {
      SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncLinux();
    } else if (Platform.isAndroid) {
      SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncAndroid();
    } else if (Platform.isWindows) {
      SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncWindows();
    } else {
      throw Exception('unable to use SharedPreferencesAsync in this platform');
    }
    _prefs = SharedPreferencesAsync();
  }

  Future<void> clear() async {
    ensureAvailability();
    await _prefs!.clear();
  }
}

// </no relational database>
