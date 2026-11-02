-- Warn on orders marked "delivered" with no delivery timestamp. These are
-- kept as revenue but excluded from delivery KPIs.
select order_id, order_status, delivered_at
from {{ ref('int_orders_enriched') }}
where order_status = 'delivered' and delivered_at is null
