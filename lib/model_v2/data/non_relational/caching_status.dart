import 'package:miraibo/model_v2/data/non_relational/database_provider.dart';
import 'package:miraibo/util/date_time.dart';

class CachingStatus implements Snapshot {
  final DateTime cachedUntil;
  final DateTime neededUntil;

  const CachingStatus({
    required this.cachedUntil,
    required this.neededUntil,
  });

  @override
  Map<String, DateTime> toMap() {
    return {
      'cachedUntil': cachedUntil,
      'neededUntil': neededUntil,
    };
  }
}

class CachingStatusCompanion implements Companion {
  DateTime? cachedUntil;
  DateTime? neededUntil;

  CachingStatusCompanion({
    this.cachedUntil,
    this.neededUntil,
  });

  factory CachingStatusCompanion.fromMap(Map<String, dynamic> map) {
    return CachingStatusCompanion()
      ..cachedUntil = map['cachedUntil']
      ..neededUntil = map['neededUntil'];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'cachedUntil': cachedUntil,
      'neededUntil': neededUntil,
    };
  }
}

class CachingStatusAccessObject
    implements
        KeyValueDatabaseAccessObject<CachingStatus, CachingStatusCompanion> {
  @override
  final provider = KeyValueDatabaseProvider();
  static const String prefix = 'predictionStatus_';

  // <cached until>
  static const String _keyPredictedUntil = '${prefix}predictedUntil';
  Future<DateTime> get cachedUntil async {
    int? value = await provider.db.getInt(_keyPredictedUntil);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setCachedUntil(DateTime value) async {
    await provider.db.setInt(_keyPredictedUntil, value.millisecondsSinceEpoch);
  }
  // </cached until>

  // <needed until>
  static const String _keyNeededUntil = '${prefix}neededUntil';
  Future<DateTime> get neededUntil async {
    int? value = await provider.db.getInt(_keyNeededUntil);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setNeededUntil(DateTime value) async {
    await provider.db.setInt(_keyNeededUntil, value.millisecondsSinceEpoch);
  }
  // </needed until>

  // <snapshot>
  @override
  Future<CachingStatus> get snapshot async {
    return CachingStatus(
      cachedUntil: await cachedUntil,
      neededUntil: await neededUntil,
    );
  }

  @override
  Future<void> setSnapshot(CachingStatusCompanion state) async {
    await Future.wait([
      if (state.cachedUntil != null) setCachedUntil(state.cachedUntil!),
      if (state.neededUntil != null) setNeededUntil(state.neededUntil!),
    ]);
  }
}
