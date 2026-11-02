-- Grain: one row per calendar day covering the full order history.
with bounds as (
    select
        date_trunc('year', min(purchase_date))                      as start_date,
        date_trunc('year', max(purchase_date)) + interval 1 year    as end_date
    from {{ ref('int_orders_enriched') }}
),
days as (
    select cast(unnest(generate_series(start_date, end_date - interval 1 day, interval 1 day)) as date) as date_day
    from bounds
)
select
    cast(strftime(date_day, '%Y%m%d') as integer)   as date_key,
    date_day,
    year(date_day)                                  as year,
    quarter(date_day)                               as quarter,
    month(date_day)                                 as month,
    strftime(date_day, '%b')                        as month_name,
    cast(date_trunc('month', date_day) as date)     as month_start,
    week(date_day)                                  as iso_week,
    dayofweek(date_day)                             as day_of_week,
    strftime(date_day, '%a')                        as day_name,
    dayofweek(date_day) in (0, 6)                   as is_weekend
from days
