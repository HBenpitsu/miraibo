# Local Storage Data Definition

- LOG_RECORD
  - id ( PRIMAL INT )
  - category ( CATEGORIES/id )
  - supplement ( TEXT )
  - registeredAt ( DATE )
  - amount ( SIGNED INT )
  - image_url ( NULLABLE URL )
  - confirmed ( BOOL )

- CATEGORIES
  - id ( PRIMAL INT )
  - name ( TEXT )

- DISPLAY_TICKETS
  - id ( PRIMAL INT )
  - target_category_map_linker ( NULLABLE DISPLAY_TICKET_TARGET_CATEGORY_MAP/target_category_map_linker )
    - NULL = all
  - period_in_days ( NULLABLE INT )
    - NULL = untilToday or untilDesignatedDate
  - limit_date ( NULLABLE DATE )
    - NULL = untilToday or lastDesignatedPeriod
  - content_type (
    - ENUM
      - daily_average,
      - daily_quartile_average,
      - monthly_average,
      - monthly_quartile_average
      - summation
  - )

- DISPLAY_TICKET_TARGET_CATEGORY_MAP
  - id ( PRIMAL INT )
  - target_category_map_linker ( INT )
  - category ( CATEGORIES/id )

- SCHEDULES
  - id ( PRIMAL INT )
  - category ( CATEGORIES/id )
  - supplement ( TEXT )
  - amount ( SIGNED INT )
  - origin_date ( DATE )
  - repeat_type ( ENUM ( no, interval, weekly, monthly, annualy ) )
  - repeat_option_interval_in_days ( NULLABLE INT )
  - repeat_option_on_Sunday ( BOOL )
  - repeat_option_on_Monday ( BOOL )
  - repeat_option_on_Tuesday ( BOOL )
  - repeat_option_on_Wednesday ( BOOL )
  - repeat_option_on_Thursday ( BOOL )
  - repeat_option_on_Friday ( BOOL )
  - repeat_option_on_Saturday ( BOOL )
  - repeat_option_monthly_head_origin_in_days ( NULLABLE INT )
  - repeat_option_monthly_tail_origin_in_days ( NULLABLE INT )
  - period_option_begin_from ( NULLABLE DATE )
  - period_option_end_at ( NULLABLE DATE )

- ESTIMATIONS
  - id ( PRIMAL INT )
  - target_category_map_linker ( NULLABLER ESTIMATION_TARGET_CATEGORY_MAP/target_category_map_linker )
    - NULL = all
  - period_option_begin_from ( NULLABLE DATE )
  - period_option_end_at ( NULLABLE DATE )
  - content_type ( ENUM
    - perDay
    - perWeek
    - perMonth
    - perYear
  - )

- ESTIMATION_TARGET_CATEGORY_MAP
  - id ( PRIMAL INT )
  - target_category_map_linker ( INT )
  - category ( CATEGORIES/id )

- FUTURE_TICKETS
  - id ( PRIMAL INT )
  - schedule ( NULLABLE SCHEDULES/id )
  - estimation ( NULLABLE ESTIMATIONS/id )
  - category ( CATEGORIES/id )
  - supplement ( TEXT )
  - scheduledAt ( DATE )
  - amount ( SIGNED INT )
