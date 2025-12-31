import 'package:flutter/foundation.dart';

mixin SchedulerBinding on BindingBase {
  static SchedulerBinding? _instance;
  static SchedulerBinding get instance => BindingBase.checkInstance(_instance);

  @override
  void initInstances() {
    super.initInstances();
    // When you use `this` keyword inside a mixin, it behaves exactly as it does in a normal class.
    // It represents the object that the mixin has been applied to.
    _instance = this;
  }

  void ensureVisualUpdate() {
    throw UnimplementedError();
  }
}
