import 'package:flutter/foundation.dart';
import 'package:miniflutter/foundation.dart' as miniflutter_foundation;

mixin SchedulerBinding on miniflutter_foundation.BindingBase {
  static SchedulerBinding? _instance;
  static SchedulerBinding get instance =>
      miniflutter_foundation.BindingBase.checkInstance(_instance);

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
