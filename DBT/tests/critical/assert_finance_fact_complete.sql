-- Every source order must land in fact_order_finance exactly once.
select
    (select count(*) from {{ ref('stg_orders') }})         as source_orders,
    (select count(*) from {{ ref('fact_order_finance') }}) as fact_orders
where (select count(*) from {{ ref('stg_orders') }})
   <> (select count(*) from {{ ref('fact_order_finance') }})
