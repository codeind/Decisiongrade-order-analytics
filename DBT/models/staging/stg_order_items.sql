-- Grain: one row per order line (order_id + order_item_id).
with source as (
    select * from {{ raw_csv('olist_order_items_dataset') }}
)
select
    trim(order_id) || '-' || trim(order_item_id)        as order_item_key,
    trim(order_id)                                      as order_id,
    cast(order_item_id as integer)                      as order_item_number,
    trim(product_id)                                    as product_id,
    trim(seller_id)                                     as seller_id,
    try_cast(shipping_limit_date as timestamp)          as shipping_limit_at,
    cast(price as decimal(12, 2))                       as item_price,
    cast(freight_value as decimal(12, 2))               as freight_value
from source
