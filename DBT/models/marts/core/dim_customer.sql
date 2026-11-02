-- Grain: one row per real customer (customer_unique_id).
-- Uses the location from the customer's most recent order.
with orders as (
    select * from {{ ref('int_orders_enriched') }}
),
per_customer as (
    select
        customer_unique_id,
        min(purchased_at)                                   as first_order_at,
        max(purchased_at)                                   as last_order_at,
        count(*)                                            as lifetime_orders,
        count(*) filter (where is_revenue_recognized)       as delivered_orders,
        sum(items_value) filter (where is_revenue_recognized) as lifetime_net_revenue,
        arg_max(customer_state, purchased_at)               as state_code,
        arg_max(customer_zip_prefix, purchased_at)          as zip_prefix
    from orders
    group by customer_unique_id
)
select
    md5(customer_unique_id)                                 as customer_key,
    customer_unique_id,
    state_code,
    zip_prefix,
    first_order_at,
    last_order_at,
    lifetime_orders,
    delivered_orders,
    coalesce(lifetime_net_revenue, 0)                       as lifetime_net_revenue,
    lifetime_orders > 1                                     as is_repeat_customer
from per_customer
