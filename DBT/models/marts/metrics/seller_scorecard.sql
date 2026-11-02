-- Grain: one row per seller with at least one delivered order.
with lines as (
    select seller_key, order_id, net_revenue
    from {{ ref('fact_order_items') }}
    where is_revenue_recognized
),
seller_orders as (
    select seller_key, order_id, sum(net_revenue) as revenue
    from lines
    group by 1, 2
),
delivery as (
    select order_id, is_on_time, review_score, handling_days
    from {{ ref('fact_delivery_performance') }}
)
select
    so.seller_key,
    s.seller_id,
    s.state_code,
    count(*)                                                        as delivered_orders,
    sum(so.revenue)                                                 as net_revenue,
    round(avg(case when d.is_on_time then 1.0 else 0.0 end), 4)     as on_time_rate,
    round(avg(d.review_score), 3)                                   as avg_review_score,
    round(avg(d.handling_days), 2)                                  as avg_handling_days,
    case
        when count(*) < 20 then 'insufficient volume'
        when avg(d.review_score) < 3.5 or avg(case when d.is_on_time then 1.0 else 0.0 end) < 0.80 then 'at risk'
        when avg(d.review_score) >= 4.3 and avg(case when d.is_on_time then 1.0 else 0.0 end) >= 0.93 then 'top performer'
        else 'standard'
    end                                                             as seller_tier
from seller_orders so
join {{ ref('dim_seller') }} s using (seller_key)
left join delivery d using (order_id)
group by 1, 2, 3
