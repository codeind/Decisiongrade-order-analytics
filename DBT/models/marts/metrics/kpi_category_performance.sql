-- Grain: one row per product category.
with lines as (
    select i.*, p.category
    from {{ ref('fact_order_items') }} i
    join {{ ref('dim_product') }} p using (product_key)
    where i.is_revenue_recognized
),
order_reviews as (
    select order_id, review_score, is_on_time
    from {{ ref('fact_delivery_performance') }}
)
select
    l.category,
    count(distinct l.order_id)                                      as orders,
    count(*)                                                        as units,
    sum(l.net_revenue)                                              as net_revenue,
    round(sum(l.net_revenue) / sum(sum(l.net_revenue)) over (), 4)  as revenue_share,
    round(avg(l.item_price), 2)                                     as avg_item_price,
    round(sum(l.freight_value) / nullif(sum(l.item_price), 0), 4)   as freight_to_price_ratio,
    round(avg(r.review_score), 3)                                   as avg_review_score,
    round(avg(case when r.is_on_time then 1.0 else 0.0 end), 4)     as on_time_rate
from lines l
left join order_reviews r using (order_id)
group by l.category
