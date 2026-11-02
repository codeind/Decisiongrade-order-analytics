-- Grain: one row per order line. Used for product, category and seller analysis.
select
    i.order_item_key,
    i.order_id,
    md5(i.product_id)                                       as product_key,
    md5(i.seller_id)                                        as seller_key,
    md5(o.customer_unique_id)                               as customer_key,
    cast(strftime(o.purchase_date, '%Y%m%d') as integer)    as purchase_date_key,
    o.order_status,
    o.is_revenue_recognized,
    i.item_price,
    i.freight_value,
    case when o.is_revenue_recognized then i.item_price else 0 end as net_revenue
from {{ ref('stg_order_items') }} i
join {{ ref('int_orders_enriched') }} o on i.order_id = o.order_id
