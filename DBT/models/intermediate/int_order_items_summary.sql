-- Grain: one row per order. Rolls order lines up to order level.
select
    order_id,
    count(*)                                   as item_count,
    count(distinct product_id)                 as distinct_products,
    count(distinct seller_id)                  as seller_count,
    sum(item_price)                            as items_value,
    sum(freight_value)                         as freight_value,
    -- the seller on line 1 is treated as the primary seller for the order
    arg_min(seller_id, order_item_number)      as primary_seller_id,
    max(shipping_limit_at)                     as latest_shipping_limit_at
from {{ ref('stg_order_items') }}
group by order_id
