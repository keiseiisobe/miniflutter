import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:miniflutter/foundation.dart' as miniflutter_foundation;
import 'package:miniflutter/scheduler.dart' as miniflutter_scheduler;
import 'package:miniflutter/services.dart' as miniflutter_services;
import 'package:miniflutter/rendering.dart' as miniflutter_rendering;
import 'package:miniflutter/widgets.dart' as miniflutter_widgets;

void runApp(Widget app) {
  /// Binding concept is similar to cloud computing model(Saas, Paas, Iaas).
  /// WidgetsBinding is a most user friendly interface (like Saas) for your app to communicate with Flutter Engine.
  /// If you want to customize your own widgets framework,
  /// you can do that by using RendererBinding and lower layer bindings (ServicesBinding, SchedulerBinding) and create MyWidgetsBinding.
  ///
  /// low level --> high level
  /// Binding:
  /// SchedulerBinding --> ServicesBinding --> RendererBinding --> WidgetsBinding
  /// Cloud Computing Model:
  /// Iaas --> Paas --> Saas
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  _runWidget(binding.wrapWithDefaultView(app), binding);
}

void _runWidget(Widget app, WidgetsBinding binding) {
  binding
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}

mixin WidgetsBinding
    on
        miniflutter_foundation.BindingBase,
        miniflutter_services.ServicesBinding,
        miniflutter_scheduler.SchedulerBinding,
        miniflutter_rendering.RendererBinding {
  static WidgetsBinding? _instance;
  static WidgetsBinding get instance =>
      miniflutter_foundation.BindingBase.checkInstance(_instance);

  miniflutter_widgets.BuildOwner? _buildOwner;
  miniflutter_widgets.BuildOwner? get buildOwner => _buildOwner;

  RootElement? _rootElement;
  RootElement? get rootElement => _rootElement;

  @override
  void initInstances() {
    assert(() {
      debugPrint('WidgetsBinding.initInstances()');
      return true;
    }());
    super.initInstances();
    // When you use `this` keyword inside a mixin, it behaves exactly as it does in a normal class.
    // It represents the object that the mixin has been applied to.
    _instance = this;
    _buildOwner = miniflutter_widgets.BuildOwner(
      onBuildScheduled: _handleBuildScheduled,
    );
  }

  Widget wrapWithDefaultView(Widget rootWidget) {
    return View(view: platformDispatcher.implicitView!, child: rootWidget);
  }

  @protected
  void scheduleAttachRootWidget(Widget rootWidget) {
    Timer.run(() => attachRootWidget(rootWidget));
  }

  void attachRootWidget(Widget widget) {
    attachToBuildOwner(RootWidget(child: widget));
  }

  void attachToBuildOwner(RootWidget widget) {
    final isBootstrapFrame = rootElement == null;
    // I don't know why do 'widget.attach(buildOwner)', not 'buildOwner.attach(widget)'
    _rootElement = widget.attach(buildOwner!, rootElement);
    if (isBootstrapFrame) {
      /// This line can only be `ensureVisualUpdate();`
      /// But I suppose `SchedulerBinding.instance` makes it immediately obvious
      /// to a contributor that we are triggering the scheduler,
      /// rather than calling a local helper method.
      miniflutter_scheduler.SchedulerBinding.instance.ensureVisualUpdate();
    }
  }

  void _handleBuildScheduled() {
    ensureVisualUpdate();
  }
}

class RootWidget extends miniflutter_widgets.Widget {
  const RootWidget({super.key, this.child});

  final Widget? child;

  @override
  RootElement createElement() {
    return RootElement(this);
  }

  RootElement attach(
    miniflutter_widgets.BuildOwner owner,
    RootElement? element,
  ) {
    if (element == null) {
      // This `lockState` is for preventing re-entrant calls.
      // For example,
      // @override
      // Widget build(BuildContext context) {
      //  setState(() {}); <-- Calling setState() during build is forbidden.
      //  return Container();
      // }
      owner.lockState(() {
        element = createElement();
        element!.assignOwner(owner);
      });
      owner.buildScope(element);
    } else {}
    return element;
  }
}

class RootElement extends miniflutter_widgets.Element
    with miniflutter_widgets.RootElementMixin {
  RootElement(super.widget);
}

/// Multiple Mixin:
/// If there is more than one mixin (n > 1), then let X be the class defined by
/// S with M1, ..., Mn−1 with name F, where F is a fresh name, and make X
/// abstract. Then S with M1, ..., Mn defines the class yielded by the mixin
/// application of the mixin of Mn to the class X with name N.
/// https://dart.dev/resources/language/spec/versions/DartLangSpec-v2.10.pdf
///
///
/// The on clause (in *Binding mixin) forces any class that uses a mixin to also be a subclass of the type in the on clause.
/// https://dart.dev/language/mixins#use-the-on-clause-to-declare-a-superclass:~:text=The%20on%20clause%20forces%20any%20class%20that%20uses%20a%20mixin%20to%20also%20be%20a%20subclass%20of%20the%20type%20in%20the%20on%20clause.
class WidgetsFlutterBinding extends miniflutter_foundation.BindingBase
    with
        miniflutter_scheduler.SchedulerBinding,
        miniflutter_services.ServicesBinding,
        miniflutter_rendering.RendererBinding,
        WidgetsBinding {
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding._instance == null) {
      assert(() {
        debugPrint('WidgetsFlutterBinding is initialized');
        return true;
      }());
      WidgetsFlutterBinding();
    }
    return WidgetsBinding.instance;
  }
}
