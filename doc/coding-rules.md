
(confirmed on 30th Nov 2024)

# Coding Rules

This document lists up coding rules.
The background of these rules is descripted in `project-design.md`.

# View and Controller

- `View` and `Controller` should always be paired together;
  - They are tightly coupled and heavily dependent on each other.
- `StatefulWidget` (`View`) should not call `setState` by itself;
  - If they call `setState` by themselves, they violate the principle that the controller sets the data of the `View`.
  - Instead of calling `setState` by itself, bind event listeners defined by the corresponding controller.
- The controller should not have an `invokeRebuild` method as a callback placeholder;
  - `invokeRebuild` is too general and does not explain the specific situation when an invocation is required, leading to bloated code and making optimization difficult.
  - Instead of makeing such a method, make more specificated placeholder. Like: `onSelectedDataChanged`.
- Keep `Widget` field only `controller`, especially if they can be modified by external events.
  - If a `Widget`'s appearance or behavior depends on external data, do not pass the data through the `Widget`'s constructor. Instead, use controllers to mediate the data.
  - If data is provided directly, controllers cannot observe it. That is the matter.
  - However, width (of widget) and height should be passed through the `Widget`'s constructor if necessary; they defines frame of Widget. That should not depends on external data.
  - This applies to `StatelessWidget` as well, as they can change behavior without changing appearance.

# Controller and Model

- `Controller` should call methods in `model_surface` to keep UI and logic separated
- Although `model_surface` may not be implemented as interface, it is intended for `UI` defines `surface` (dependency injection).

# Model Surface, Transaction and Worker

- Model Surface should call methods in `Transaction` or `Worker`.
  - Especially, `Worker` is called to handle asyncronous gaps.
  - Otherwise, `Transaction` will called directly.

# Transaction and Infrastructure

- There are two directories for `Transaction`-layer: `transaction` and `subtransaction`. Put files that contain `methods` called by surface directly into `transaction`. Put methods that are called by the other `transaction`-method into `subtransaction`.
- `Transaction`-class and `Subtransaction`-class are defined in `infrastracture`-layer. Use them.

# Commander and Worker

- `Worker` should call `Commander`'s methods.

# Commander and Controller

- `Controllers` should bind callbacks to `Commander`

# DTO

Data Transfer objects are strictly divided between UI layer and Model layer.
UI layer's DTOs are defined in `view_obj.dart` and Model layer's DTOs are defined in `model_obj.dart`.

> [!comment] (30th Nov) it may be better to use the same DTO among the app and for controllers to wrap them
