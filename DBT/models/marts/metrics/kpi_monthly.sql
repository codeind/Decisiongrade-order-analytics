-- Grain: one row per purchase month. This is the governed KPI table:
-- dashboards read these numbers and do not recalculate them.
with finance as (
    select f.*, d.month_start
    from {{ ref('fact_order_finance') }} f
    join {{ ref('dim_date') }} d on f.purchase_date_key = d.date_key
),
delivery as (
    select f.*, d.month_start
    from {{ ref('fact_delivery_performance') }} f
    join {{ ref('dim_date') }} d on f.purchase_date_key = d.date_key
),
first_orders as (
    select customer_key, cast(date_trunc('month', first_order_at) as date) as first_month
    from {{ ref('dim_customer') }}
),
fin as (
    select
        month_start,
        count(*)                                                    as orders_placed,
        count(*) filter (where is_revenue_recognized)               as orders_delivered,
        count(*) filter (where is_lost_order)                       as orders_lost,
        sum(gross_merchandise_value)                                as gmv,
        sum(net_revenue)                                            as net_revenue,
        sum(freight_value) filter (where is_revenue_recognized)     as freight_collected,
        count(distinct customer_key)                                as active_customers,
        count(distinct customer_key) filter (where fo.first_month = finance.month_start) as new_customers
    from finance
    left join first_orders fo using (customer_key)
    group by month_start
),
dlv as (
    select
        month_start,
        avg(case when is_on_time then 1.0 else 0.0 end)             as on_time_rate,
        avg(cycle_time_days)                                        as avg_cycle_time_days,
        median(cycle_time_days)                                     as median_cycle_time_days,
        avg(review_score)                                           as avg_review_score
    from delivery
    group by month_start
)
select
    fin.month_start,
    fin.orders_placed,
    fin.orders_delivered,
    fin.orders_lost,
    round(fin.orders_lost / fin.orders_placed, 4)                   as lost_order_rate,
    fin.gmv,
    fin.net_revenue,
    fin.freight_collected,
    round(fin.net_revenue / nullif(fin.orders_delivered, 0), 2)     as avg_order_value,
    fin.active_customers,
    fin.new_customers,
    round(dlv.on_time_rate, 4)                                      as on_time_rate,
    round(dlv.avg_cycle_time_days, 2)                               as avg_cycle_time_days,
    round(dlv.median_cycle_time_days, 2)                            as median_cycle_time_days,
    round(dlv.avg_review_score, 3)                                  as avg_review_score,
    -- months with fewer than 500 orders (start-up / data cut-off) are flagged
    -- so trend charts and anomaly checks can exclude them
    fin.orders_placed >= 500                                        as is_complete_month
from fin
left join dlv using (month_start)
order by fin.month_start
