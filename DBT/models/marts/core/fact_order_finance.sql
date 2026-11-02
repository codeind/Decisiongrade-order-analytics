-- Grain: one row per order.
-- Net revenue = item value of delivered orders (revenue is recognised on
-- delivery). Freight is reported separately and is not revenue.
select
    o.order_id,
    md5(o.customer_unique_id)                               as customer_key,
    cast(strftime(o.purchase_date, '%Y%m%d') as integer)    as purchase_date_key,
    o.customer_state                                        as location_key,
    o.order_status,
    o.is_revenue_recognized,
    o.is_lost_order,
    o.item_count,
    o.items_value                                           as gross_merchandise_value,
    case when o.is_revenue_recognized then o.items_value else 0 end as net_revenue,
    o.freight_value,
    o.payment_total,
    o.payment_variance,
    abs(o.payment_variance) > {{ var('payment_tolerance_brl') }} as is_payment_mismatch,
    o.primary_payment_type,
    o.max_installments,
    o.used_voucher
from {{ ref('int_orders_enriched') }} o
