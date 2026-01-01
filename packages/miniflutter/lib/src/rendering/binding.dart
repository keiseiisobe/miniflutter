import 'package:flutter/foundation.dart';
import 'package:miniflutter/scheduler.dart';
import 'package:miniflutter/services.dart';

mixin RendererBinding on BindingBase, SchedulerBinding, ServicesBinding {
  static RendererBinding? _instance;
  static RendererBinding get instance => BindingBase.checkInstance(_instance);

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }
}
