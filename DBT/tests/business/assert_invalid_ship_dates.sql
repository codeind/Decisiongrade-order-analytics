-- Warn: orders whose carrier hand-off date in the source was earlier than the
-- purchase date. These dates were nulled in int_orders_enriched.
select order_id, purchased_at
from {{ ref('int_orders_enriched') }}
where has_invalid_ship_date
