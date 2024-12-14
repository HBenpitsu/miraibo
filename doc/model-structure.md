
> [!success] confirmed
> Dec 8th 2024

# layers

At first `Model` is divided into four(+1) layers:

- `Surface`
- `Worker`
- `Operation`
- `Data`
- (`Infra`)

Surface calls Worker, Worker invokes Operations, and Operations consults Data.
# Surface

`Surface`-layer consists of some components. And each component has their methods.
methods are classified into 5 types based on the operations which they requires.

| component  | SAVE-type            | DELETE-type | FETCH-type                | SUMMARY-type             | CACHE-type |
| :--------: | -------------------- | ----------- | ------------------------- | ------------------------ | ---------- |
|    log     | save<br>confirmUntil | delete      | all<br>on <br>unconfirmed |                          |            |
|  display   | save                 | delete      | on<br>edgeOn              | content                  |            |
|  schedule  | save                 | delete      | on                        |                          |            |
| estimation | save                 | delete      | on                        | content                  |            |
|  category  | save                 | integrate   | all                       |                          |            |
|   chart    |                      |             |                           | Accumulation<br>Subtotal |            |
|   cache    |                      |             |                           |                          | notify     |

Although the `type` roughly corresponds with the `operation kind` they will use, it is not radical. For example, only `notify` is classified into CACHE-type though, all of SAVE-type/DELETE-type methods also requires `CACHE operation`.

# Worker

`Worker` consists of following components:

- TransactionIssuer
- RegularEventDispathcer
- CacheManager
- PlugGuard
- Notifier

Worker is a unique layer in that it interact with outside Model.
`RegularEventDispathcer` will be invoked by `EntryPoint`, and dispatch regular event periodically/on every booting up.
`Notifier` notifies `Commander` occurrence and detail of modification.

`TransactionIssuer` issues transaction (of database). `TransactionIssuer` is located in `Worker`-layer so that worker can combine some `Operations`.

`CacheManager` calls CACHE operations on proper time.

`PlugGuard` is called by all methods except CACHE-type method. The responsibility of the `PlugGuard` is following:

- refresh cache before fetch and make methods await while caching is going
- invoke cache update after some modification via `CacheManager`

## Operation

`Operation`-layer consists of a lot of methods. But they are classified into

- SAVE-type
- DELETE-type
- FETCH-type
- SUMMARY-type
- CACHE-type

SAVE-type, DELETE-type and FETCH-type are called basic operations.
On the other hand, SUMMARY-type and CACHE-type are applied operations.

And there are some extracted operations.

SAVE: 
DISPLAY and ESTIMATION requires `CategoryLinker`. It updates `ObjectCategoryLinks`Table.

FETCH: 
Log, ESTIMATION, DISPLAY and SCHEDULE needs `CategoryBundler`. On top of that, `RepeatBundler` is needed when they fetch ESTIMATION/SCHEDULE. `RepeatBundler` consults repeat cache.

DELETE:
DISPLAY and ESTIMATION requires `CategoryUnlinker`. It clean up `ObjectCategoryLinks`Table. To integrate category, `CategoryReplacer` will be called.

SUMMARY:
When be tried to get summary of estimation, it consults `ESTIMATION_CACHE` table. And when general summary: sum,mean,quartileRangeMean,accumulation,subtotal is required, it calls `PeriodSpecifier` and `Simplifier`. `PeriodSpecifier` literally specifies period of the statistical process, like, "after Dec 5th and before Dec 9th". `Simplefier`simplifies data from LOG, ESTIMATION, SCHEDULE, ESTIMATION_CACHE and REPEAT_CACHE table, and makes it possible that `Analyzer` process the data consistent way.

CACHING:
CACHE-operation may handle META_DATA directly. On the other hand, `EstimationCacher` and `RepeatCacher` are span off because of their complexity. As name shows, `EstimationCacher` make/clean up ESTIMATION_CACHE. `RepeatCacher` make/clean up REPEAT_CACHE.