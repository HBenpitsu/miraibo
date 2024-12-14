import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_linux/shared_preferences_linux.dart';
// import 'package:shared_preferences_web/shared_preferences_web.dart'; // this package cause compile error
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

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

abstract class Snapshot {
  Map<String, dynamic> toMap();
}

abstract class Companion {
  Map<String, dynamic> toMap();
}

abstract class KeyValueDatabaseAccessObject<S extends Snapshot,
    C extends Companion> {
  KeyValueDatabaseProvider get provider;
  Future<S> get snapshot;
  Future<void> setSnapshot(C state);
}
