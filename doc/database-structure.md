# Local Storage Data Definition

- RECEIPTS
  - id ( PRIMAL INT )
  - category ( CATEGORIES/id )
  - supplement ( NULLABLE TEXT )
  - registeredAt ( DATE )
  - amount ( SIGNED INT )
  - image_url ( NULLABLE URL )
  - confirmed ( BOOL )

- CATEGORIES
  - id ( PRIMAL INT )
  - name ( TEXT )

- DISPLAY_TICKETS
  - id ( PRIMAL INT )
  - target_category_map_linker ( INT )
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
  - target_category_map_linker ( NULLABLE INT )
    - NULL = all
  - category_id ( CATEGORIES/id )

- SCHEDULES
  - id ( PRIMAL INT )
  - category ( CATEGORIES/id )
  - supplement ( TEXT )
  - scheduledAt ( DATE )
  - amount ( SIGNED INT )
  - origin_date ( DATE )
  - repeat_option_interval_in_days ( NULLABLE INT )
  - repeat_option_weekly ( ENUM 'Sun','Mon','Tue','Wed','Thu','Fri','Sat' )
  - repeat_option_monthly_head_origin_in_days ( NULLABLE INT )
  - repeat_option_monthly_tail_origin_in_days ( NULLABLE INT )
  - repeat_option_annualy ( BOOL )
  - period_option_begin_from ( NULLABLE DATE )
  - period_option_end_at ( NULLABLE DATE )

- ESTIMATIONS
  - id ( PRIMAL INT )
  - category ( CATEGORIES/id )
  - period_option_begin_from ( NULLABLE DATE )
  - period_option_end_at ( NULLABLE DATE )

- FUTURE_TICKET_FACTORIES
  - id ( PRIMAL INT )
  - schedule_id ( NULLABLE SCHEDULES/id )
  - estimation_id ( NULLABLE ESTIMATIONS/id )
  - display_mode ( ENUM
    - perDay
    - perWeek
    - perMonth
    - perYear
  - )

- FUTURE_TICKETS
  - id ( PRIMAL INT )
  - foctory_id ( INT FUTURE_TICKET_FACTORIES/id )
  - category ( CATEGORIES/id )
  - supplement ( NULLABLE TEXT )
  - scheduledAt ( DATE )
  - amount ( SIGNED INT )
