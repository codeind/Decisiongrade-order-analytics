-- Grain: one row per lateness band. Quantifies how late delivery hurts reviews.
select
    lateness_band,
    count(*)                                                        as delivered_orders,
    round(avg(review_score), 3)                                     as avg_review_score,
    round(avg(case when review_score <= 2 then 1.0 else 0.0 end), 4) as negative_review_rate,
    round(avg(case when review_score = 5 then 1.0 else 0.0 end), 4) as five_star_rate
from {{ ref('fact_delivery_performance') }}
where review_score is not null
group by lateness_band
