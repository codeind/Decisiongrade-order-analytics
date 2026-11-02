-- Grain: one row per order. Central business-logic model: lifecycle timings,
-- delivery SLA, revenue recognition and review outcome are all decided here,
-- once, so every downstream mart and dashboard uses identical rules.
with orders as (
    -- Quarantine rule: a carrier hand-off dated before the purchase is a
    -- source-system error (166 orders). The bad value is nulled so it cannot
    -- distort handling/transit times, and the order is flagged for review.
    select
        * replace (case when shipped_at < purchased_at then null else shipped_at end as shipped_at),
        shipped_at < purchased_at as has_invalid_ship_date
    from {{ ref('stg_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
),
items as (
    select * from {{ ref('int_order_items_summary') }}
),
payments as (
    select * from {{ ref('int_order_payments_summary') }}
),
reviews as (
    select * from {{ ref('int_order_reviews') }}
)
select
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.state_code                                    as customer_state,
    c.zip_prefix                                    as customer_zip_prefix,
    i.primary_seller_id,
    o.order_status,

    -- timestamps
    o.purchased_at,
    cast(o.purchased_at as date)                    as purchase_date,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,

    -- basket
    coalesce(i.item_count, 0)                       as item_count,
    coalesce(i.seller_count, 0)                     as seller_count,
    coalesce(i.items_value, 0)                      as items_value,
    coalesce(i.freight_value, 0)                    as freight_value,
    coalesce(p.payment_total, 0)                    as payment_total,
    p.primary_payment_type,
    coalesce(p.max_installments, 0)                 as max_installments,
    coalesce(p.used_voucher, false)                 as used_voucher,

    -- business rules
    o.order_status = 'delivered'                    as is_revenue_recognized,
    o.order_status in ('canceled', 'unavailable')   as is_lost_order,
    (o.order_status = 'delivered' and o.delivered_at is not null) as is_delivered,

    -- lifecycle durations (hours / days)
    date_diff('minute', o.purchased_at, o.approved_at) / 60.0         as approval_hours,
    date_diff('minute', o.approved_at, o.shipped_at) / 1440.0         as handling_days,
    date_diff('minute', o.shipped_at, o.delivered_at) / 1440.0        as transit_days,
    date_diff('minute', o.purchased_at, o.delivered_at) / 1440.0      as cycle_time_days,
    date_diff('day', cast(o.purchased_at as date), cast(o.estimated_delivery_at as date)) as promised_days,

    -- SLA: delivered on or before the promised date (date-level comparison)
    case
        when o.delivered_at is null or o.estimated_delivery_at is null then null
        else cast(o.delivered_at as date) <= cast(o.estimated_delivery_at as date)
    end                                             as is_on_time,
    case
        when o.delivered_at is null or o.estimated_delivery_at is null then null
        else greatest(date_diff('day', cast(o.estimated_delivery_at as date), cast(o.delivered_at as date)), 0)
    end                                             as days_late,

    -- reconciliation: what the customer paid vs. what the order lines say
    coalesce(p.payment_total, 0) - (coalesce(i.items_value, 0) + coalesce(i.freight_value, 0)) as payment_variance,

    o.has_invalid_ship_date,
    r.review_score,
    r.has_comment                                   as review_has_comment
from orders o
left join customers c on o.customer_id = c.customer_id
left join items     i on o.order_id = i.order_id
left join payments  p on o.order_id = p.order_id
left join reviews   r on o.order_id = r.order_id
