-- Net revenue can never be negative or exceed the order's merchandise value.
select order_id, net_revenue, gross_merchandise_value
from {{ ref('fact_order_finance') }}
where net_revenue < 0
   or net_revenue > gross_merchandise_value
