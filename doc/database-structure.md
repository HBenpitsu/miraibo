
> [!todo] refine required 
> (Dec 8th 2024)

> [!warning] Uncorrespondance
> code should be modified (Dec 8th 2024)
# Local Storage Data Definition

## primitive data

LOGS

|  fieldName   | type          |
| :----------: | ------------- |
|      id      | PRIMARY INT   |
|   category   | CATEGORIES/id |
|  supplement  | TEXT          |
| registeredAt | DATE INDEXED  |
|    amount    | SIGNED INT    |
|   imageUrl   | NULLABLE URL  |
|  confirmed   | BOOL          |
CATEGORIES

| fieldName | type        |
| :-------: | ----------- |
|    id     | PRIMARY INT |
|   name    | TEXT        |

DISPLAYS

|  fieldName   | type          |                                                                                    |
| :----------: | ------------- | ---------------------------------------------------------------------------------- |
|      id      | PRIMARY INT   |                                                                                    |
| periodInDays | NULLABLE INT  | =NULL ? untilToday or untilDesignatedDate or specificPeriod : lastDesignatedPeriod |
| periodBegin  | NULLABLE DATE | =NULL ? untilToday or untilDesignatedDate : specificPeriod                         |
|  periodEnd   | NULLABLE DATE | =NULL ? untilToday : untilDesignatedDate                                           |
| contentType  | ENUM          | (dailyMean, dailyQuartileMean, monthlyMean, monthlyQuartileMean, summation)        |
DISPLAY_CATEGORY_LINKS

| fieldName | type               |
| :-------: | ------------------ |
|  display  | DISPLAY_TICKETS/id |
| category  | CATEGORIES/id      |
SCHEDULES

|        fieldName        | type          |                                          |
| :---------------------: | ------------- | ---------------------------------------- |
|           id            | PRIMARY INT   |                                          |
|        category         | CATEGORIES/id |                                          |
|       supplement        | TEXT          |                                          |
|         amount          | SIGNED INT    |                                          |
|         origin          | DATE INDEXED  |                                          |
|       repeatType        | ENUM          | (no, interval, weekly, monthly, annualy) |
|        interval         | NULLABLE INT  | interval                                 |
|        onSunday         | BOOL          | weekly                                   |
|        onMonday         | BOOL          | weekly                                   |
|        onTuesday        | BOOL          | weekly                                   |
|       onWednesday       | BOOL          | weekly                                   |
|       onThursday        | BOOL          | weekly                                   |
|        onFriday         | BOOL          | weekly                                   |
|       onSaturday        | BOOL          | weekly                                   |
| monthlyHeadOriginInDays | NULLABLE INT  | monthly                                  |
| monthlyTailOriginInDays | NULLABLE INT  | monthly                                  |
|       periodBegin       | NULLABLE DATE |                                          |
|        periodEnd        | NULLABLE DATE |                                          |

ESTIMATIONS

|  fieldName  | type          |                                   |
| :---------: | ------------- | --------------------------------- |
|     id      | PRIMARY INT   |                                   |
| periodBegin | NULLABLE DATE |                                   |
|  periodEnd  | NULLABLE DATE |                                   |
| contentType | ENUM          | (perDay,perWeek,perMonth,perYear) |

ESTIMATION_CATEGORY_LINKS

| fieldName  | type           |
| :--------: | -------------- |
| estimation | ESTIMATIONS/id |
|  category  | CATEGORIES/id  |

## cache data

ESTIMATION_CACHE

| fieldName | type          |                                 |
| :-------: | ------------- | ------------------------------- |
| category  | CATEGORIES/id |                                 |
|  amount   | REAL          | estimation per day per category |
REPEAT_CACHE

|  fieldName   | type                    |
| :----------: | ----------------------- |
|   repeatId   | PRIMARY INT             |
| registeredAt | DATE                    |
|   schedule   | NULLABLE SCHEDULES/id   |
|  estimation  | NULLABLE ESTIMATIONS/id |
## non-relational data

> [!todo]
> structure of non-relational database should be refined

META_DATA

|   key    | type |
| :------: | ---- |
| firstLog | DATE |
ESTIMATION_CACHE_STATUS

|    key     | type |
| :--------: | ---- |
| lastUpdate | DATE |
REPEAT_CACHE_STATUS

|      key       | type |
| :------------: | ---- |
|  neededUntil   | DATE |
| preparedUntil  | DATE |
| preparingUntil | DATE |
