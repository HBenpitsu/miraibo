import 'package:miraibo/model_v2/data/non_relational/database_provider.dart';
import 'package:miraibo/util/date_time.dart';

class MetaData implements Snapshot {
  final bool appInitialized;
  final DateTime firstLaunch;
  final DateTime firstRecord;

  const MetaData({
    required this.appInitialized,
    required this.firstLaunch,
    required this.firstRecord,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'appInitialized': appInitialized,
      'firstLaunch': firstLaunch,
      'firstRecord': firstRecord,
    };
  }
}

class MetaDataCompanion implements Companion {
  bool? appInitialized;
  DateTime? firstLaunch;
  DateTime? firstRecord;

  MetaDataCompanion({
    this.appInitialized,
    this.firstLaunch,
    this.firstRecord,
  });

  factory MetaDataCompanion.fromMap(Map<String, dynamic> map) {
    return MetaDataCompanion()
      ..appInitialized = map['appInitialized']
      ..firstLaunch = map['firstLaunch']
      ..firstRecord = map['firstRecord'];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'appInitialized': appInitialized,
      'firstLaunch': firstLaunch,
      'firstRecord': firstRecord,
    };
  }
}

class MetaDataAccessObject
    implements KeyValueDatabaseAccessObject<MetaData, MetaDataCompanion> {
  @override
  final provider = KeyValueDatabaseProvider();

  static const String prefix = 'metaData_';

  // <app initialized>
  static const String _keyAppInitialized = '${prefix}appInitialized';
  Future<bool> get appInitialized async {
    return await provider.db.getBool(_keyAppInitialized) ?? false;
  }

  Future<void> setAppInitialized(bool value) async {
    await provider.db.setBool(_keyAppInitialized, value);
  }
  // </app initialized>

  // <first launch>
  static const String _keyFirstLaunch = '${prefix}firstLaunch';
  Future<DateTime> get firstLaunch async {
    int? value = await provider.db.getInt(_keyFirstLaunch);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setFirstLaunch(DateTime value) async {
    await provider.db.setInt(_keyFirstLaunch, value.millisecondsSinceEpoch);
  }
  // </first launch>

  // <first record>
  static const String _keyFirstRecord = '${prefix}firstRecord';
  Future<DateTime> get firstRecord async {
    int? value = await provider.db.getInt(_keyFirstRecord);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setFirstRecord(DateTime value) async {
    await provider.db.setInt(_keyFirstRecord, value.millisecondsSinceEpoch);
  }
  // </first record>

  // <snapshot>
  @override
  Future<MetaData> get snapshot async {
    return MetaData(
      appInitialized: await appInitialized,
      firstLaunch: await firstLaunch,
      firstRecord: await firstRecord,
    );
  }

  @override
  Future<void> setSnapshot(MetaDataCompanion state) async {
    await Future.wait([
      if (state.appInitialized != null)
        setAppInitialized(state.appInitialized!),
      if (state.firstLaunch != null) setFirstLaunch(state.firstLaunch!),
      if (state.firstRecord != null) setFirstRecord(state.firstRecord!),
    ]);
  }
  // </snapshot>
}
