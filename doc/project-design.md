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

Note:
Althoguh there are directories named `type` and `util`, they do not represent any layers (of software architecture).

## dependancy-chain

    View<-Entry point
     |
Controller
|    |
|   Model (Surface)
|         |
|         ^
|         |
| worker<-|- Entry point
| |  |    |
| | transaction
| |       |
commander |
          |
    infrastructure

To keep this figure true, there are some specific rules.
Check out `conding-rules.md`.

# details and responsibilities of each layer


