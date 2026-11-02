-- Grain: one row per order. When an order has several reviews, keep the
-- most recent one (the customer's latest opinion).
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by review_answered_at desc nulls last, review_created_at desc, review_id
        ) as rn,
        count(*) over (partition by order_id) as review_count
    from {{ ref('stg_reviews') }}
)
select
    order_id,
    review_id,
    review_score,
    review_message is not null as has_comment,
    review_created_at,
    review_count
from ranked
where rn = 1
