import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:miniflutter/foundation.dart' as miniflutter_foundation;
import 'package:miniflutter/scheduler.dart' as miniflutter_scheduler;

mixin ServicesBinding
    on
        miniflutter_foundation.BindingBase,
        miniflutter_scheduler.SchedulerBinding {
  static ServicesBinding? _instance;
  static ServicesBinding get instance =>
      miniflutter_foundation.BindingBase.checkInstance(_instance);

  late final BinaryMessenger _defaultBinaryMessanger;
  BinaryMessenger get defaultBinaryMessanger => _defaultBinaryMessanger;

  @override
  void initInstances() {
    assert(() {
      debugPrint('ServicesBinding.initInstances()');
      return true;
    }());
    super.initInstances();
    _instance = this;
    _defaultBinaryMessanger = createBinaryMessanger();
  }

  @protected
  BinaryMessenger createBinaryMessanger() {
    return const _DefaultBinaryMessanger._();
  }
}

class _DefaultBinaryMessanger extends BinaryMessenger {
  const _DefaultBinaryMessanger._();

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    // TODO: implement send
    throw UnimplementedError();
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    // TODO: implement setMessageHandler
    throw UnimplementedError();
  }
}
