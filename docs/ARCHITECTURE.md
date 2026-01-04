# Miniflutter Architecture

## Rules
Arrow type | Description
--- | ---
<\|-- | Inheritance
..> | Dependency

Member visibility | Description
--- | ---
\+ | Public
\- | Private
\# | Protected

## Diagram
```mermaid
---
title: MiniFlutter Class Diagram
---
classDiagram
namespace widgets {
    class Object {
        runtimeType
    }    
    class Widget {
        <<abstract>>
        key
        +createElement()
    }
    class StatelessWidget{
        <<abstract>>    
        +createElement()
        #build(context)
    }
    class StatefulWidget {
        <<abstract>>    
        +createElement()
        #createState()
    }
    class RootWidget {
        +createElement()
        +attach()
    }
    class State {
        <<abstract>>
        widget
        context
        mouted
        #initDispose()
        #didUpdateWidget(oldWidget)
        #dispose()
        #setState(fn)
        #build(context)
    }
    class Element {
        <<abstract>>
        dirty
        +mount()
        +unmount()
        +update()
        +markNeedsBuild()
    }
    class ComponentElement {
        <<abstract>>
    }
    class StatelessElement {
        #build(this)
    }
    class StatefulElement {
        state
        #build(this)    
    }
    class RootElement {
        owner
        +assignOwner()
    }
    class RenderObject {
        constraints
        parent
        parentData
        +attach()
    }
    class RenderView {
        +compositeFrame()
    }
    class BindingBase {
        <<abstract>>
        platformDispatcher
        #initInstances()
        #checkInstance()
    }
    class SchedulerBinding {
        schedulerPhase
        #initInstances()
        #checkInstance()
        +addPersistentFrameCallback(callback)
        +addPostFrameCallback(callback)
        +ensureVisualUpdate()
        +scheduleWarmUpFrame()
        +scheduleFrame()
    }
    class ServicesBinding {
        defaultBinaryMessanger
        #initInstances()
        #checkInstance()
        #createBinaryMessanger()
    }
    class RendererBinding {
        rootPipelineOwner
        renderViews
        #initInstances()
        #checkInstance()
        #drawFrame()
        +addRenderView()
        +removeRenderView()
    }
    class WidgetsBinding {
        instance
        buildOwner
        observers
        #initInstances()
        #checkInstance()
        +drawFrame()
        +addObserver(observer)
        +removeObserver(observer)
        +wrapWithDefaultView(rootWidget)
        #scheduleAttachRootWidget(rootWidget)
        +attachRootWidget(rootWidget)
        +attachToBuildOwner(widget)
    }
    class WidgetsFlutterBinding {
        +ensureInitialized()
    }

    class BuildOwner {
        onBuildScheduled
        _globalKeyRegistry[]
        +buildScope(element, callback)
        +reassemble(element)
    }
    class PipelineOwner {
        +flushLayout()
        +flushCompositingBits()
        +flushPaint()
        +flushSemantics()
    }
    class ui["dart:ui"] {
    }
}

    %% Object inheritance
    Object <|-- Widget
    Object <|-- Element
    Object <|-- RenderObject

    %% Widget inheritance
    Widget <|-- StatelessWidget
    Widget <|-- StatefulWidget
    Widget <|-- RootWidget

    %% Widget dependency
    StatefulWidget ..> State

    %% Element dependency
    StatefulElement ..> State
    RootElement ..> BuildOwner

    %% Element inheritance
    Element <|-- ComponentElement
    Element <|-- RootElement
    ComponentElement <|-- StatelessElement
    ComponentElement <|-- StatefulElement

    %% RenderObject inheritance
    RenderObject <|-- RenderView

    %% Binding inheritance
    BindingBase <|-- SchedulerBinding
    BindingBase <|-- ServicesBinding
    BindingBase <|-- RendererBinding
    BindingBase <|-- WidgetsBinding
    BindingBase <|-- WidgetsFlutterBinding
    SchedulerBinding <|-- ServicesBinding
    SchedulerBinding <|-- RendererBinding
    SchedulerBinding <|-- WidgetsBinding
    SchedulerBinding <|-- WidgetsFlutterBinding
    ServicesBinding <|-- RendererBinding
    ServicesBinding <|-- WidgetsBinding
    ServicesBinding <|-- WidgetsFlutterBinding
    RendererBinding <|-- WidgetsBinding
    RendererBinding <|-- WidgetsFlutterBinding
    WidgetsBinding <|-- WidgetsFlutterBinding

    %% Binding dependency
    WidgetsBinding ..> BuildOwner
    RendererBinding ..> PipelineOwner
    SchedulerBinding ..> ui

    %% Owner dependency
    BuildOwner ..> RootElement

    %% Ui dependency
    RenderView ..> ui

```

## Flow
```mermaid
flowchart TD
    start --> A["call *Binding.initInstances() in WidgetsFlutterBinding()"] --> B["call addPersistentFrameCallback which call drawFrame() in RendererBinding.initInstances()"] --> B2["call WidgetsBinding.attachRootWidget"] --> B3["call WidgetsBinding.attachToBuildOwner"] --> B4["call RootWidget.attach(buildOwner)"] --> B5["call element.assignOwner() and mount() in previous attach() method"] --> C["call RendererBinding.scheduleWarmUpFrame()"] --> D["engine call SchedulerBinding.handleBeginFrame() when OS sends Vsync signal"] --> E["call SchedulerBinding.handleDrawFram()"] --> F["call drawFrame() reserved by previous addPersistentFrameCallback"] --> G["call setState() when user tap button"] --> H["element.markNeedsBuild"] --> I["call owner.scheduleBuildFor()"] --> J["call owner.onBuildScheduled()"] --> K["call SchedulerBinding.ensureVisualUpate()"] --> D
```