import 'package:flutter/foundation.dart';
import 'package:miniflutter/foundation.dart' as miniflutter_foundation;
import 'package:miniflutter/scheduler.dart' as miniflutter_scheduler;
import 'package:miniflutter/services.dart' as miniflutter_services;

mixin RendererBinding
    on
        miniflutter_foundation.BindingBase,
        miniflutter_scheduler.SchedulerBinding,
        miniflutter_services.ServicesBinding {
  static RendererBinding? _instance;
  static RendererBinding get instance =>
      miniflutter_foundation.BindingBase.checkInstance(_instance);

  @override
  void initInstances() {
    assert(() {
      debugPrint('RendererBinding.initInstances()');
      return true;
    }());
    super.initInstances();
    _instance = this;
  }
}
