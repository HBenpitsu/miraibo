# project-design

This document explains that what design pattern this project follows, how directory or files corresponds to layers.

# design pattern

This project follows the MVC design pattern. The project is divided into three layers: Model, View, and Controller.
View and Controller layers are implemented in the `ui` directory. So, they are mentioned as UI-layer below.

Model layer is devided into sublayers:

- infrastructure
- transaction
- worker
- surface

Addtionaly, there is a `commander` layer that is used to invoke event of UI-layer from Model-layer.
Because Model-layer can not call method on UI-layer directly, a mediator is needed.

## List up all layers

- commander
- view
- controller
- model
  - model-surface
  - worker
  - transaction
  - infrastructure

## depend/call-chain

commander <-bind- controller
view <-passed- controller
view -call-> controller
view -call-> model-surface
controller -call-> model-surface
model-surface -call-> worker
model-surface -call-> transaction
worket -call-> transaction
transaction -expand-> infrastructure

# note

Data Transfer objects are strictly divided between UI layer and Model layer.
UI layer's DTOs are defined in `view_obj.dart` and Model layer's DTOs are defined in `model_obj.dart`.
