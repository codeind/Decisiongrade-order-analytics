-- Revenue anomaly check: warn when net revenue moves more than the allowed
-- share month over month. The first three complete months are excluded
-- because the marketplace was still ramping up.
with m as (
    select
        month_start,
        net_revenue,
        lag(net_revenue) over (order by month_start)  as prev_revenue,
        row_number() over (order by month_start)      as month_number
    from {{ ref('kpi_monthly') }}
    where is_complete_month
)
select month_start, prev_revenue, net_revenue,
       round(net_revenue / prev_revenue - 1, 4) as mom_change
from m
where month_number > 3
  and abs(net_revenue / prev_revenue - 1) > {{ var('revenue_mom_swing_limit') }}
