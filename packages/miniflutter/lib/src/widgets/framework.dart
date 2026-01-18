import 'package:flutter/material.dart';

// -------------------- Widget --------------------

/// As `@immutable` decorator indicates, all of the instance fields of `Widget` class,
/// whether defined directly or inherited, are `final`.
/// See meta.dart for more details.
@immutable
abstract class Widget extends Object {
  const Widget({this.key});

  final Key? key;

  // Be careful.
  // `@protected` decorator indicates this method is visible not only to other instance members
  // of the class or mixin, and their subtypes (like c++), but also `within the declaring library`,
  @protected
  /// This method must return a newly created element or null.
  @factory
  Element createElement();

  /// This static method is used by `Element.updateChild()`
  /// to determine if the oldWidget can be updated with newWidget configuration.
  /// If not, old child has to be disposed, and create new child.
  static bool canUpdate(Widget newWidget, Widget oldWidget) {
    return newWidget.runtimeType == oldWidget.runtimeType &&
        newWidget.key == oldWidget.key;
  }
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  @override
  StatelessElement createElement() {
    return StatelessElement(this);
  }

  /// This build method is called in three situations.
  /// 1. The first time this widget is inserted in the tree.
  /// 2. When its parent widget changes its configuration
  /// 3. When InheritedWidget it depends on changes
  @protected
  Widget build(
    // Thanks to this parameter, developer can configure widget depending on
    // where instance of this widget is inserted (ex. by using `dependOnInheritedWidgetOfExactType`)
    // and when this widget has multiple instances.
    BuildContext context,
  );
}

/// For compositions that depend only on the configuration information in the object itself
/// and the BuildContext in which the widget is inflated, consider using StatelessWidget.
/// If depend on anything else, consider using StatefulWidget.
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

abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget({super.key});

  @override
  @factory
  Element createElement();

  @protected
  @factory
  RenderObject createRenderObject(BuildContext context);
}

abstract class LeafRenderObjectWidget extends RenderObjectWidget {
  const LeafRenderObjectWidget({super.key});

  @override
  LeafRenderObjectElement createElement() => LeafRenderObjectElement(this);
}

abstract class SingleChildRenderObjectWidget extends RenderObjectWidget {
  const SingleChildRenderObjectWidget({super.key, this.child});

  final Widget? child;

  @override
  SingleChildRenderObjectElement createElement() =>
      SingleChildRenderObjectElement(this);
}

abstract class MultiChildRenderObjectWidget extends RenderObjectWidget {
  const MultiChildRenderObjectWidget({
    super.key,
    this.children = const <Widget>[],
  });

  final List<Widget> children;

  @override
  Element createElement() => MultiChildRenderObjectElement(this);
}

// -------------------- State --------------------

/// BuildContext and State instances share their life cycle.
/// State object never change its BuildContext.
/// ex.
/// When StatefulWidget is removed from tree and inserted into the tree again,
/// framework call StatefulWidget.createState() again to create a fresh State Object.
/// https://api.flutter.dev/flutter/widgets/State-class.html#:~:text=if%20a%20StatefulWidget%20is%20removed%20from%20the%20tree%20and%20later%20inserted%20in%20to%20the%20tree%20again%2C%20the%20framework%20will%20call%20StatefulWidget.createState%20again%20to%20create%20a%20fresh%20State%20object%2C%20simplifying%20the%20lifecycle%20of%20State%20objects.
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
  @mustCallSuper
  void initState() {}

  /// Called whenever the widget configuration changes.
  ///
  /// Subclass of State can override this method.
  ///
  /// ex.
  /// ```
  /// @override
  /// void didUpdateWidget(covariant SomeStatefulWidget oldWidget) {
  ///   super.didUpdateWidget(oldWidget);
  ///   if (widget.stream != oldWidget.stream) {
  ///     _subscription.cancel();
  ///     _subscription = null;
  ///     _subscription = widget.stream.listen(/* some callback here */);
  ///   }
  /// }
  /// ```
  @protected
  @mustCallSuper
  void didUpdateWidget(covariant T oldWidget) {}

  @protected
  @mustCallSuper
  void dispose() {}

  /// This method is expected to be called at most once per frame,
  @protected
  void setState(VoidCallback fn) {
    final result = fn() as dynamic;
    if (result is Future) {
      throw (FlutterError("SetState() callback argument returned Future."));
    }
    _element!.markNeedsBuild();
  }

  @protected
  Widget build(BuildContext context);
}

// -------------------- Element --------------------

/// Docs in this page is valuable to understand how Element works.
/// https://api.flutter.dev/flutter/widgets/Element-class.html
abstract class Element extends Object implements BuildContext {
  Element(Widget widget) : _widget = widget;

  // `_widget` can be null if unmounted from tree by `unmount()`
  // ignore: prefer_final_fields
  Widget? _widget;

  BuildOwner? _owner;

  bool _dirty = true;

  BuildScope? _parentBuildScope;

  Element? _parent;

  Object? _slot;

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

  Object? get slot => _slot;

  // For now, we don't implement this method to avoid complexity.
  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  void mount(Element? parent, Object? newSlot) {
    _parent = parent;
    _slot = newSlot;
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
    // This calls ComponentElement.performRebuild() or RenderObjectElement.performRebuild() first.
    performRebuild();
  }

  @mustCallSuper
  void performRebuild() {
    // Subclass must call `super.performRebuild()`.
    _dirty = false;
  }

  /// See https://api.flutter.dev/flutter/widgets/Element/updateChild.html
  @protected
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    if (newWidget == null) {
      if (child != null) {
        deactivateChild();
      }
      return null;
    }

    final Element newChild;

    if (child != null) {
      if (child.widget == newWidget) {
        newChild = child;
      } else if (Widget.canUpdate(newWidget, child.widget)) {
        child.update(newWidget);
        newChild = child;
      } else {
        deactivateChild();
        newChild = inflateWidget(newWidget, newSlot);
      }
    } else {
      newChild = inflateWidget(newWidget, newSlot);
    }
    return newChild;
  }

  @protected
  @mustCallSuper
  void deactivateChild() {
    // TODO(someone): implement
  }

  @mustCallSuper
  void update(covariant Widget newWidget) {
    _widget = newWidget;
  }

  @protected
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final newChild = newWidget.createElement();
    // This calls ComponentElement.mount() or RenderObjectElement.mount() first.
    newChild.mount(this, newSlot);
    return newChild;
  }

  void attachRenderObject(Object? newSlot) {}
}

/// Contrast with `RenderObjectElement`.
/// When you are wondering why `Element` and `RenderObject` should be separated,
/// see https://docs.flutter.dev/resources/inside-flutter#separation-of-the-element-and-renderobject-trees
///
/// `ComponentElement` does not draw anything.
/// Its job is to define `the combination of classes` as `composition` (how we build UIs).
/// see https://docs.flutter.dev/resources/inside-flutter#conclusion
///
/// Flutter's slogan: "Everything is a widget"
abstract class ComponentElement extends Element {
  ComponentElement(super.widget);

  Element? _child;

  Element? get renderObjectAttachingChild => _child;

  @protected
  Widget build();

  @override
  void performRebuild() {
    Widget built;
    try {
      // `build()` method returns its child widget.
      // When you configure widgets tree like
      // Center --> Column --> Text,
      // Center.build() returns Column, Column.build() returns Text, Text.build() returns RichText.
      // So you can go deeper into the tree.
      built = build();
    } finally {
      // Only after `build()` method finished, we mark the element as clean
      // to ignore `markNeedsBuild()` during `build()`
      super.performRebuild();
    }
    _child = updateChild(_child, built, slot);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _firstBuild();
  }

  void _firstBuild() {
    rebuild();
  }
}

abstract class RenderObjectElement extends Element {
  RenderObjectElement(RenderObjectWidget super.widget);

  RenderObject? _renderObject;

  RenderObjectElement? _ancestorRenderObjectElement;

  RenderObject get renderObject => _renderObject!;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _renderObject = (widget as RenderObjectWidget).createRenderObject(this);
    attachRenderObject(newSlot);
    super.performRebuild();
  }

  @override
  void attachRenderObject(Object? newSlot) {
    _slot = newSlot;
    _ancestorRenderObjectElement = _findAncestorRenderObjectElement();
    if (_ancestorRenderObjectElement == null) {
      throw FlutterError(
        "Cannot find ancestor render object to attach to. Try wrapping your widget in View widget.",
      );
    }
    _ancestorRenderObjectElement!.insertRenderObjectChild(
      renderObject,
      newSlot,
    );
  }

  RenderObjectElement? _findAncestorRenderObjectElement() {
    Element? ancestor = _parent;
    while (ancestor != null && ancestor is! RenderObjectElement) {
      ancestor = ancestor._parent;
    }
    return ancestor as RenderObjectElement?;
  }

  void insertRenderObjectChild(RenderObject renderObject, Object? newSlot);
}

class LeafRenderObjectElement extends RenderObjectElement {
  LeafRenderObjectElement(LeafRenderObjectWidget super.widget);

  @override
  void insertRenderObjectChild(RenderObject renderObject, Object? newSlot) {}

  // There is no `mount()` method override because this is `Leaf` (has no child).
}

class SingleChildRenderObjectElement extends RenderObjectElement {
  SingleChildRenderObjectElement(SingleChildRenderObjectWidget super.widget);

  Element? _child;

  @override
  void insertRenderObjectChild(RenderObject renderObject, Object? newSlot) {}

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _child = updateChild(
      _child,
      (widget as SingleChildRenderObjectWidget).child,
      // Why `null`?
      null,
    );
  }
}

class MultiChildRenderObjectElement extends RenderObjectElement {
  MultiChildRenderObjectElement(MultiChildRenderObjectWidget super.widget);

  @override
  void insertRenderObjectChild(RenderObject renderObject, Object? newSlot) {}

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
  }
}

/// Only root elements may have their owner set explicitly. All other
/// elements inherit their owner from their parent.
/// That why RootElementMixin is in widgets/framework.dart because _owner is private.
mixin RootElementMixin on Element {
  void assignOwner(BuildOwner owner) {
    _owner = owner;
    _parentBuildScope = BuildScope();
  }
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

class StatefulElement extends ComponentElement {
  StatefulElement(StatefulWidget super.widget) : state = widget.createState();

  final State state;

  @override
  Widget build() {
    return state.build(this);
  }
}

// -------------------- Other --------------------

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

  void lockState(VoidCallback callback) {
    // TODO(someone): implement lockState
    callback();
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
