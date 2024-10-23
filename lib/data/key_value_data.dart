import 'package:shared_preferences/shared_preferences.dart';

class SystemData {
  // <constructor>
  // singleton pattern
  SystemData._internal();
  static final SystemData _instance = SystemData._internal();

  // ensure that the instance is available
  static Future<SystemData> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  // get the instance anyway
  factory SystemData.ref() => _instance;
  // </constructor>

  // <initialization>
  SharedPreferences? _prefs;
  Future<void> ensureAvailability() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  // </initialization>

  Future<void> clear() async {
    await ensureAvailability();
    await _prefs!.clear();
  }

  Future<DateTime> ticketsNeededUntil() async {
    await ensureAvailability();
    var val = _prefs!.getInt('ticketNeededUntil');
    if (val == null) {
      return DateTime.now();
    } else {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
  }

  Future<void> ticketsWasNeededFor(DateTime date) async {
    await ensureAvailability();
    var val = _prefs!.getInt('ticketNeededUntil');
    if (val == null || val < date.millisecondsSinceEpoch) {
      await _prefs!.setInt('ticketNeededUntil', date.millisecondsSinceEpoch);
    }
  }

  Future<void> ticketsWasPreparedUntil
}
