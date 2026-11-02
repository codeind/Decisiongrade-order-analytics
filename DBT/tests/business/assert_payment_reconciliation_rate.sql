-- Warn if more than 2% of orders have payments that differ from
-- items + freight by more than the configured tolerance.
select
    count(*) filter (where is_payment_mismatch)        as mismatched_orders,
    count(*)                                           as orders,
    count(*) filter (where is_payment_mismatch) * 1.0 / count(*) as mismatch_rate
from {{ ref('fact_order_finance') }}
where order_status <> 'canceled'
having count(*) filter (where is_payment_mismatch) * 1.0 / count(*) > 0.02
