-- Grain: one row per customer state.
select
    f.customer_location_key                                     as state_code,
    l.state_name,
    l.region,
    count(*)                                                    as delivered_orders,
    round(avg(case when f.is_on_time then 1.0 else 0.0 end), 4) as on_time_rate,
    round(avg(f.cycle_time_days), 2)                            as avg_cycle_time_days,
    round(avg(f.promised_days), 2)                              as avg_promised_days,
    round(avg(f.freight_value), 2)                              as avg_freight,
    round(avg(f.review_score), 3)                               as avg_review_score,
    round(avg(case when f.is_same_state then 1.0 else 0.0 end), 4) as same_state_share
from {{ ref('fact_delivery_performance') }} f
left join {{ ref('dim_location') }} l on f.customer_location_key = l.location_key
group by 1, 2, 3
