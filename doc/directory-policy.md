
> [!warning] Uncorrespondance
> code should be modified (Dec 8th 2024)

> [!todo] refine required
> Dec 8th 2024

To keep the project organized, we need to arrange files in a consistent way. The specific method for organizing files in the `lib` directory and the abstractions of these directories are explained below.

In `lib`, there are several entities;

- main.dart
- util
- ui
- type
- model
- commander

Note that other entries are deprecated and will be removed from the source in the future.

main.dart is an entry point of the project. Take care not to write too much in the file.

The `util` directory is intended for utility files. It is important to avoid cluttering this directory with too many files; only include isolated and concise pieces of code. For instance, DateTime utilities are currently located here because they are independent of any specific context, and not too large.

The `ui` directory contains UI definitions and has two sub-directories: `component`,`modal` and `page`. In accordance with the MVC model, it includes both Views and Controllers. Pairs of view and controller are placed sequentially in the same file.
In `page` directory, there are four files each of that represents a single `page`. Detail of each page are described in `miraibo.md`.
The `modal` directory contains definitions of modal-window.
The `component` directory contains reusable components that are used across multiple pages or included by other components.

The `type` directory contains small and simple type definitions.
Currently, this directory includes:

- enumerations with basic extensions.
- date transfer objects for UI layer.
- date transfer objects for Model layer.

Note that the UI-layer DTOs and Model-layer DTOs are separated even though they have shared name.
Especially, even though two Category DTO shares the same structure, they are separated because they are used in different layers.

The `model` directory represents the model layer. When methods are called from outside the model, the `model_surface` is used.
Methods in `model_surface` should not be huge. I calls methods in `transaction` or `worker`.
`transaction` is a unit of process. They are implemented using `infra` and `subtransaction`.

The `commander` directory holds `commander`s. A commander commands something to `ui`-layer and `model`-layer.
It is installed because make it possible for model-layer to invoke event of ui-layer.
Because `model` layer should not dependent on the `ui` layer, it is impossible to invoke event of `ui`-layer without `commander`.
When `model` layer want to invoke `ui` event, it requires a `commander` to invoke event.

For more detail of features and responsibilities of each sublayer, check out `project-design.md`.
