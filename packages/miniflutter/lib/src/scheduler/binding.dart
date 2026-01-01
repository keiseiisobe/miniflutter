import 'package:flutter/foundation.dart';

mixin SchedulerBinding on BindingBase {
  static SchedulerBinding? _instance;
  static SchedulerBinding get instance => BindingBase.checkInstance(_instance);

  @override
  void initInstances() {
    assert(() {
      debugPrint('SchedulerBinding.initInstances()');
      return true;
    }());
    super.initInstances();
    _instance = this;
  }

  void ensureVisualUpdate() {
    throw UnimplementedError();
  }
}
