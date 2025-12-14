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
