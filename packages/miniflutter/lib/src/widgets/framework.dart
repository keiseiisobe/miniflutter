import 'package:flutter/material.dart';

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  @override
  StatelessElement createElement() {
    return StatelessElement(this);
  }

  /// This build method is called in three situations.
  /// 1. The first time this widget is inserted in the tree.
  /// 2. When its parent widget changes its configration
  /// 3. When InheritedWidget it depends on changes
  @protected
  Widget build(BuildContext context);
}

/// The element tree is necessary because the widgets themselves are immutable,
/// which means (among other things), they cannot remember their parent or
/// child relationships with other widgets.
/// https://docs.flutter.dev/resources/inside-flutter#:~:text=The%20element%20tree%20is%20necessary%20because%20the%20widgets%20themselves%20are%20immutable%2C%20which%20means%20(among%20other%20things)%2C%20they%20cannot%20remember%20their%20parent%20or%20child%20relationships%20with%20other%20widgets.
class StatelessElement extends ComponentElement {
  StatelessElement(StatelessWidget super.widget);

  /// As you can see [this] argument in build method, BuildContext is Element.
  /// BuildContext helps user to avoid manipulating Element object directly.
  /// https://api.flutter.dev/flutter/widgets/BuildContext-class.html#:~:text=BuildContext%20objects%20are%20actually%20Element%20objects.%20The%20BuildContext%20interface%20is%20used%20to%20discourage%20direct%20manipulation%20of%20Element%20objects.
  @override
  Widget build() {
    return (widget as StatelessWidget).build(this);
  }
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});

  @override
  StatefulElement createElement() {
    return StatefulElement(this);
  }

  @protected
  @factory
  State createState();
}

abstract class Widget {
  const Widget({this.key});

  final Key? key;

  @protected
  Element createElement();
}

abstract class State<T extends StatefulWidget> {
  /// These properties ([_widget] and [_element]) are initialized by the framework before calling [initState].
  T? _widget;
  StatefulElement? _element;

  T get widget => _widget!;

  BuildContext get context {
    if (_element == null) {
      throw FlutterError("context is null");
    }
    return _element!;
  }

  bool get mounted => _element != null;

  @protected
  void initState();

  @protected
  void didUpdateWidget(covariant T oldWidget);

  @protected
  void dispose();

  /// Thie method is expected to be called at most once per frame,
  @protected
  void setState(VoidCallback fn) {
    fn();
    // TODO(someone): fn must not be async
    _element!.markNeedsBuild();
  }

  @protected
  Widget build(BuildContext context);
}

class StatefulElement extends ComponentElement {
  StatefulElement(StatefulWidget super.widget) : state = widget.createState();

  final State state;

  @override
  Widget build() {
    return state.build(this);
  }
}

abstract class ComponentElement extends Element {
  ComponentElement(super.widget);

  Widget? _child;

  Widget? get renderObjectAttachingChild => _child;

  @protected
  Widget build();

  @override
  void performRebuild() {
    Widget built;
    try {
      built = build();
    } finally {
      // Only after `build()` method finished, we mark the element as clean
      // to ignore `markNeedsBuild()` during `build()`
      super.performRebuild();
    }
    _child = updateChild(_child, built, slot);
  }
}

/// Docs in this page is valuable to understand how Element works.
/// https://api.flutter.dev/flutter/widgets/Element-class.html
abstract class Element implements BuildContext {
  Element(Widget widget) : _widget = widget;

  // `_widget` can be null if unmounted from tree by `unmount()`
  Widget? _widget;

  BuildOwner? _owner;

  bool _dirty = true;

  BuildScope? _parentBuildScope;

  @override
  Widget get widget => _widget!;

  @override
  bool get mounted => _widget != null;

  @override
  BuildOwner? get owner => _owner;

  @override
  bool get dirty => _dirty;

  @override
  BuildScope get buildScope => _parentBuildScope!;

  // For now, we don't implement this method to avoid complexity.
  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  void mount(Element? parent, Object? newSlot) {
    if (parent != null) {
      // When parent == null (When this element is RootElement),
      // `_owner` and `_parentBuildScope` must be initialized by `RootElementMixin.assingOwner()`
      _owner = parent.owner;
      _parentBuildScope = parent.buildScope;
    }
  }

  void markNeedsBuild() {
    _dirty = true;
    owner!.scheduleBuildFor(this);
  }

  void rebuild() {
    performRebuild();
  }

  void performRebuild() {
    // Subclass must call `super.performRebuild()`.
    _dirty = false;
  }
}

mixin RootElementMixin on Element {
  void assignOwner(BuildOwner owner) {
    _owner = owner;
    _parentBuildScope = BuildScope();
  }
}

// BuildContext objects are actually Element objects.
// The BuildContext interface is used to discourage direct manipulation of Element objects.
abstract class BuildContext {
  bool get mounted;
  BuildOwner? get owner;
  Widget get widget;

  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();
}

class BuildOwner {
  BuildOwner({required this.onBuildScheduled});

  VoidCallback onBuildScheduled;

  void scheduleBuildFor(Element element) {
    onBuildScheduled();
    final buildScope = element.buildScope;
    buildScope._scheduleBuildFor(element);
  }

  void buildScope(Element element, [VoidCallback? callback]) {
    final buildScope = element.buildScope;
    if (callback != null) {
      callback();
    }
    buildScope._flushDirtyElement();
  }
}

class BuildScope {
  final List<Element> _dirtyElements = <Element>[];

  void _scheduleBuildFor(Element element) {
    _dirtyElements.add(element);
  }

  void _flushDirtyElement() {
    for (int i = 0; i < _dirtyElements.length; i++) {
      final element = _dirtyElements[i];
      if (identical(element.buildScope, this)) {
        _tryRebuild(element);
      }
    }
    _dirtyElements.clear();
  }

  void _tryRebuild(Element element) {
    element.rebuild();
  }
}
