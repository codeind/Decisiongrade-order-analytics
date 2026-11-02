-- Grain: one row per payment instalment record (order_id + payment_sequential).
with source as (
    select * from {{ raw_csv('olist_order_payments_dataset') }}
)
select
    trim(order_id) || '-' || trim(payment_sequential)   as payment_key,
    trim(order_id)                                      as order_id,
    cast(payment_sequential as integer)                 as payment_sequence,
    lower(trim(payment_type))                           as payment_type,
    cast(payment_installments as integer)               as installments,
    cast(payment_value as decimal(12, 2))               as payment_value
from source
