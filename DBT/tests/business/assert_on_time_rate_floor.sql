-- Warn for any complete month where on-time delivery fell below the agreed floor.
select month_start, orders_delivered, on_time_rate
from {{ ref('kpi_monthly') }}
where is_complete_month
  and on_time_rate < {{ var('on_time_rate_floor') }}
