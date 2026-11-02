-- Grain: one row per order.
select
    order_id,
    sum(payment_value)                                   as payment_total,
    count(*)                                             as payment_records,
    max(installments)                                    as max_installments,
    -- payment method that carried the largest share of the order value
    arg_max(payment_type, payment_value)                 as primary_payment_type,
    bool_or(payment_type = 'voucher')                    as used_voucher
from {{ ref('stg_payments') }}
group by order_id
