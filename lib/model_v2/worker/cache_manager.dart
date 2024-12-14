import 'package:miraibo/model_v2/operations/operations.dart';
import 'package:miraibo/model_v2/data/data.dart';

class CacheManager {
  static const int daysPerStep = 365;

  // prevent interupting cache making
  static bool caching = false;

  /// return if its canceled or completed. if it is completed, it will return true.
  Future<bool> requireCacheUntil(DateTime date) async {
    if (caching) {
      return false;
    } else {
      caching = true;
    }

    // if there is no cache on the date+1 year(step), make cache until the data+ 2 years(steps)
    var oneStepAdvanced = date.add(Duration(days: daysPerStep));
    var cachedUntil = await ndb.cachingStatus.cachedUntil;
    if (cachedUntil.isAfter(oneStepAdvanced)) {
      return true;
    }
    var neededUntil = date.add(Duration(days: daysPerStep * 2));
    await ndb.cachingStatus.setNeededUntil(neededUntil);
    await Operations.cache.insertRepeatCacheBetween(
        cachedUntil.add(Duration(days: 1)), neededUntil);
    await ndb.cachingStatus.setCachedUntil(neededUntil);
    // note that cache is made until `cachedUntil`

    caching = false;
    return true;
  }

  static const Duration cacheSyncInterval = Duration(milliseconds: 100);
  Future<void> waitUntilCachePrepared() async {
    while (true) {
      if (await ndb.cachingStatus.cachedUntil ==
          await ndb.cachingStatus.neededUntil) {
        return;
      }
      await Future.delayed(cacheSyncInterval);
    }
  }
}
