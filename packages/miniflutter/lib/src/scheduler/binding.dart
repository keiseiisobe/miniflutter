import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:miniflutter/foundation.dart' as miniflutter_foundation;

mixin SchedulerBinding on miniflutter_foundation.BindingBase {
  static SchedulerBinding? _instance;
  static SchedulerBinding get instance =>
      miniflutter_foundation.BindingBase.checkInstance(_instance);

  SchedulerPhase _schedulerPhase = SchedulerPhase.idle;
  SchedulerPhase get schedulerPhase => _schedulerPhase;

  final List<VoidCallback> _persistentFrameCallback = <VoidCallback>[];

  final List<VoidCallback> _postFrameCallback = <VoidCallback>[];

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
    switch (schedulerPhase) {
      case SchedulerPhase.idle:
      case SchedulerPhase.postFrameCallbacks:
        scheduleFrame();
        return;
      default:
        return;
    }
  }

  void scheduleWarmUpFrame() {
    PlatformDispatcher.instance.scheduleWarmUpFrame(
      beginFrame: handleBeginFrame,
      drawFrame: handleDrawFrame,
    );
  }

  void handleBeginFrame() {
    try {
      // Execute transientFrameCallbacks
      _schedulerPhase = SchedulerPhase.transientCallbacks;
    } finally {
      _schedulerPhase = SchedulerPhase.midFrameMicrotasks;
    }
  }

  void handleDrawFrame() {
    try {
      // Execute persistentFrameCallbacks
      _schedulerPhase = SchedulerPhase.persistentCallbacks;
      for (final callback in _persistentFrameCallback) {
        callback();
      }
      // Don't do `_persistentFrameCallback.clear()`!
      // Persistent frame callbacks cannot be unregistered.
      // Once registered, they are called for every frame for the lifetime of the application.

      // Execute postFrameCallbacks
      _schedulerPhase = SchedulerPhase.postFrameCallbacks;
      for (final callback in _postFrameCallback) {
        callback();
      }
      _postFrameCallback.clear();
    } finally {
      _schedulerPhase = SchedulerPhase.idle;
    }
  }

  void scheduleFrame() {
    platformDispatcher.scheduleFrame();
  }

  void addPersistentFrameCallback(VoidCallback callback) {
    _persistentFrameCallback.add(callback);
  }

  void addPostFrameCallback(VoidCallback callback) {
    _postFrameCallback.add(callback);
  }
}
