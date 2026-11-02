-- Grain: one row per review submission.
-- The source has ~800 review_ids that appear on more than one order and ~550
-- orders with more than one review; both are resolved in int_order_reviews.
with source as (
    select * from {{ raw_csv('olist_order_reviews_dataset') }}
)
select
    trim(review_id)                                     as review_id,
    trim(order_id)                                      as order_id,
    cast(review_score as integer)                       as review_score,
    nullif(trim(review_comment_title), '')              as review_title,
    nullif(trim(review_comment_message), '')            as review_message,
    try_cast(review_creation_date as timestamp)         as review_created_at,
    try_cast(review_answer_timestamp as timestamp)      as review_answered_at
from source
where try_cast(review_score as integer) is not null
