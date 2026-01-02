# Miniflutter Class Diagram

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
title: "MiniFlutter Class Diagram"
---
classDiagram
namespace widget {
    class Widget {
        <<abstract>>    
    }
    class StatelessWidget{
        <<abstract>>    
        +createElement(this)
        #build(context)
    }
    class StatefulWidget {
        <<abstract>>    
        +createElement(this)
        #createState()
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
}

namespace binding {
    class BindingBase {
        <<abstract>>
        platformDispatcher
        #initInstances()
        #checkInstance()
    }
    class SchedulerBinding {
        #initInstances()
        #checkInstance()
    }
    class ServicesBinding {
        #initInstances()
        #checkInstance()
    }
    class RendererBinding {
        #initInstances()
        #checkInstance()
    }
    class WidgetsBinding {
        #initInstances()
        #checkInstance()
    }
    class WidgetsFlutterBinding {
        #initInstances()
        #checkInstance()
    }
}

    %% Widget inheritance
    Widget <|-- StatelessWidget
    Widget <|-- StatefulWidget

    %% Widget dependency
    StatefulWidget ..> State

    %% Element dependency
    StatefulElement ..> State

    %% Element inheritance
    Element <|-- ComponentElement
    ComponentElement <|-- StatelessElement
    ComponentElement <|-- StatefulElement

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
```