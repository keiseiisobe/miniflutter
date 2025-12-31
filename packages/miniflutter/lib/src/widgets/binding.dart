import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:miniflutter/scheduler.dart' as miniflutter;

void runApp(Widget app) {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  _runWidget(binding.wrapWithDefaultView(app), binding);
}

void _runWidget(Widget app, WidgetsBinding binding) {
  binding
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}

mixin WidgetsBinding on BindingBase, miniflutter.SchedulerBinding {
  static WidgetsBinding? _instance;
  static WidgetsBinding get instance => BindingBase.checkInstance(_instance);

  BuildOwner? _buildOwner;
  BuildOwner? get buildOwner => _buildOwner;

  RootElement? _rootElement;
  RootElement? get rootElement => _rootElement;

  @override
  void initInstances() {
    super.initInstances();
    // When you use `this` keyword inside a mixin, it behaves exactly as it does in a normal class.
    // It represents the object that the mixin has been applied to.
    _instance = this;
    _buildOwner = BuildOwner();
  }

  Widget wrapWithDefaultView(Widget rootWidget) {
    return View(view: platformDispatcher.implicitView!, child: rootWidget);
  }

  @protected
  void scheduleAttachRootWidget(Widget rootWidget) {
    Timer.run(() => attachRootWidget(rootWidget));
  }

  void scheduleWarmUpFrame() {
    // throw UnimplementedError();
  }

  void attachRootWidget(Widget widget) {
    attachToBuildOwner(RootWidget(child: widget));
  }

  void attachToBuildOwner(RootWidget widget) {
    final isBootstrapFrame = rootElement == null;
    _rootElement = widget.attach(buildOwner!, rootElement);
    if (isBootstrapFrame) {
      /// This line can only be `ensureVisualUpdate();`
      /// But I suppose `SchedulerBinding.instance` makes it immediately obvious
      /// to a contributor that we are triggering the scheduler,
      /// rather than calling a local helper method.
      SchedulerBinding.instance.ensureVisualUpdate();
    }
  }
}

/// The on clause (in *Binding mixin) forces any class that uses a mixin to also be a subclass of the type in the on clause.
/// https://dart.dev/language/mixins#use-the-on-clause-to-declare-a-superclass:~:text=The%20on%20clause%20forces%20any%20class%20that%20uses%20a%20mixin%20to%20also%20be%20a%20subclass%20of%20the%20type%20in%20the%20on%20clause.
class WidgetsFlutterBinding extends BindingBase
    with miniflutter.SchedulerBinding, WidgetsBinding {
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding._instance == null) {
      return WidgetsFlutterBinding();
    }
    return WidgetsBinding.instance;
  }
}
