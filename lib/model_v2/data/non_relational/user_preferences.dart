import 'package:miraibo/model_v2/data/non_relational/database_provider.dart';

class UserPreferences implements Snapshot {
  final bool allowImageUpload;

  const UserPreferences({
    required this.allowImageUpload,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'allowImageUpload': allowImageUpload,
    };
  }
}

class UserPreferencesCompanion implements Companion {
  bool? allowImageUpload;

  UserPreferencesCompanion({
    this.allowImageUpload,
  });

  factory UserPreferencesCompanion.fromMap(Map<String, dynamic> map) {
    return UserPreferencesCompanion()
      ..allowImageUpload = map['allowImageUpload'];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'allowImageUpload': allowImageUpload,
    };
  }
}

class UserPreferencesAccessObject
    implements
        KeyValueDatabaseAccessObject<UserPreferences,
            UserPreferencesCompanion> {
  @override
  final provider = KeyValueDatabaseProvider();

  static const String prefix = 'userPref_';

  // <allow image upload>
  static const String _keyAllowImageUpload = '${prefix}allowImageUpload';
  Future<bool> get allowImageUpload async {
    return await provider.db.getBool(_keyAllowImageUpload) ?? false;
  }

  Future<void> setAllowImageUpload(bool value) async {
    await provider.db.setBool(_keyAllowImageUpload, value);
  }
  // </allow image upload>

  // <snapshot>
  @override
  Future<UserPreferences> get snapshot async {
    return UserPreferences(
      allowImageUpload: await allowImageUpload,
    );
  }

  @override
  Future<void> setSnapshot(UserPreferencesCompanion state) async {
    await Future.wait([
      if (state.allowImageUpload != null)
        setAllowImageUpload(state.allowImageUpload!),
    ]);
  }
  // </snapshot>
}
