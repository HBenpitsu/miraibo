import 'package:flutter/foundation.dart';
import 'package:miraibo/model_v2/operations/operations.dart';

class RegularEventDispacher {
  static bool _isDispatched = false;

  /// This method should be executed at every app start. In other words, this is called "regularly".
  Future<void> initApp() async {
    await Operations.initialize.ensureInilialized();
    await Operations.cache.refreshEstimationCache(null);
    if (!_isDispatched) {
      _dispatch();
      _isDispatched = true;
    }
  }

  /// This method shoulb executed through initApp
  void _dispatch() {}
}

RegularEventDispacher regularEventDispacher = RegularEventDispacher();
