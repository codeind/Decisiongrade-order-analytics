-- The governed KPI table must add up to the fact table to the cent.
-- This is what guarantees the dashboard and finance see the same number.
with kpi as (select sum(net_revenue) as v from {{ ref('kpi_monthly') }}),
     fact as (select sum(net_revenue) as v from {{ ref('fact_order_finance') }})
select kpi.v as kpi_revenue, fact.v as fact_revenue
from kpi, fact
where abs(kpi.v - fact.v) > 0.01
