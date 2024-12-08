
> [!success] confirmed
> Dec 8th 2024

# project-design

This document explains that what design pattern this project follows, how directory or files corresponds to layers.

# design pattern

This project follows the MVC design pattern. The project is divided into three layers: Model, View, and Controller.
View and Controller layers are implemented in the `ui` directory. So, they are mentioned as UI-layer below.

Additionally, there is a `commander` layer that is used to invoke event of UI-layer from Model-layer.
Because Model-layer can not call method on UI-layer directly, a mediator is needed.

> [!note]
> Althoguh there are directories named `type` and `util`, they do not represent any layers (of software architecture).

## dependancy-chain

```figure
    View<-Entry point
     |
Controller
|     |
|     Model<- Entry point
|     |   |
commander |
          |
    infrastructure
```

To keep this figure true, there are some specific rules.
Check out `conding-rules.md`.

# details and responsibilities of each layer

The responsibilities of `View` are:

- define appearance of the UI
- define animation of the UI
- show data provided by `Controller`s

The responsibilities of `Controller` are:

- query `Model` a data
- tell `Model` to edit data
- listen to `Commander`

The responsibilities of `Model` are:

- manage data
- return proper data

The responsibilities of `Commander`

- make `Controller` rebuild UI
