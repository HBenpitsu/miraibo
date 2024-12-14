import 'package:miraibo/model_deprecated/infra/database_provider.dart';
import 'package:miraibo/util/date_time.dart';

class PredictionStatus {
  final KeyValueDatabaseProvider _provider = KeyValueDatabaseProvider();

  static const String prefix = 'predictionStatus_';

  static const String _keyPredictingUntil = '${prefix}predictingUntil';
  Future<DateTime> predictingUntil() async {
    int? value = await _provider.db.getInt(_keyPredictingUntil);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setPredictingUntil(DateTime value) async {
    await _provider.db
        .setInt(_keyPredictingUntil, value.millisecondsSinceEpoch);
  }

  static const String _keyPredictedUntil = '${prefix}predictedUntil';
  Future<DateTime> predictedUntil() async {
    int? value = await _provider.db.getInt(_keyPredictedUntil);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setPredictedUntil(DateTime value) async {
    await _provider.db.setInt(_keyPredictedUntil, value.millisecondsSinceEpoch);
  }

  static const String _keyNeededUntil = '${prefix}neededUntil';
  Future<DateTime> neededUntil() async {
    int? value = await _provider.db.getInt(_keyNeededUntil);
    if (value == null) {
      return today();
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setNeededUntil(DateTime value) async {
    await _provider.db.setInt(_keyNeededUntil, value.millisecondsSinceEpoch);
  }

  Future<Map<String, DateTime>> wholeState() async {
    return {
      _keyPredictingUntil: await predictingUntil(),
      _keyPredictedUntil: await predictedUntil(),
      _keyNeededUntil: await neededUntil(),
    };
  }

  Future<void> setWholeState(Map<String, DateTime> state) async {
    await setPredictingUntil(state[_keyPredictingUntil]!);
    await setPredictedUntil(state[_keyPredictedUntil]!);
    await setNeededUntil(state[_keyNeededUntil]!);
  }
}
