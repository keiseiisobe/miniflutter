import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui show PlatformDispatcher;

abstract class BindingBase {
  BindingBase() {
    initInstances();
  }

  ui.PlatformDispatcher get platformDispatcher =>
      ui.PlatformDispatcher.instance;

  void initInstances() {}

  @protected
  static T checkInstance<T extends BindingBase>(T? instance) {
    if (instance == null) {
      throw FlutterError('Binding mixin instance is null.');
    }
    return instance;
  }
}
