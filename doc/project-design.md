
(confirmed on 30th Nov 2024)

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

> [!note]
> Althoguh there are directories named `type` and `util`, they do not represent any layers (of software architecture).

## dependancy-chain

```figure
    View<-Entry point
     |
Controller
|    |
|   Model (Surface)
|    |    |
|    ^    ^
|    |    |
| worker<-|- Entry point
| |  |    |
| | transaction
| |       |
commander |
          |
    infrastructure
```

To keep this figure true, there are some specific rules.
Check out `conding-rules.md`.

# details and responsibilities of each layer

The responsibilities of `View` are:

- define apearance of the UI
- define animation of the UI
- show data provided by `Controller`s

The responsibilities of `Controller` are:

- query `Model` a data
- tell `Model` to edit data
- listen to `Commander`

The responsibilities of `Model Surface` are:

- call necessary implementations (in `Transaction`/`Worker`)

The responsibilities of `Transaction` are:

- Create/Read/Update/Delete data from database using `Infrastructure`
- define batch process on the data
- define calculation method

`Transaction` may be classified into two types:

- Basic transaction:
  - including inserting single record, fetching the oldest record and so on
- Applied transaction:
  - including calculating mean of the field and so on

The responsibilities of `Worker` are:

- dispatch/handle non-UI based events
  - periodic event
  - asyncronous event
- invoke some `Transaction`
- tell commander that UI update is required

The responsibilities of `Commander`

- make `Controller` rebuild UI
