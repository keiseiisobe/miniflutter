import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
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

  late PipelineOwner _rootPipelineOwner;
  PipelineOwner get rootPipelineOwner => _rootPipelineOwner;

  final Map<Object, RenderView> _viewIdToRenderView = <Object, RenderView>{};
  Iterable<RenderView> get renderViews => _viewIdToRenderView.values;

  @override
  void initInstances() {
    assert(() {
      debugPrint('RendererBinding.initInstances()');
      return true;
    }());
    super.initInstances();
    _instance = this;
    _rootPipelineOwner = PipelineOwner();
    addPersistentFrameCallback(_handlePersistentFrameCallback);
  }

  void _handlePersistentFrameCallback() {
    drawFrame();
  }

  void drawFrame() {
    _rootPipelineOwner.flushLayout();
    _rootPipelineOwner.flushCompositingBits();
    _rootPipelineOwner.flushPaint();
    for (final renderView in renderViews) {
      renderView.compositeFrame();
    }
    _rootPipelineOwner.flushSemantics();
  }

  void addRenderView(RenderView renderView) {
    final viewId = renderView.flutterView.viewId;
    _viewIdToRenderView[viewId] = renderView;
  }

  void removeRenderView(RenderView renderView) {
    final viewId = renderView.flutterView.viewId;
    _viewIdToRenderView.remove(viewId);
  }
}
