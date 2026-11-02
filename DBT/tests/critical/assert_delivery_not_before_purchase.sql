-- Fails if any order was delivered or handed to the carrier before it was
-- bought. Runs on the cleaned model, so it proves the quarantine rule in
-- int_orders_enriched works (see assert_invalid_ship_dates for the count).
select order_id, purchased_at, shipped_at, delivered_at
from {{ ref('int_orders_enriched') }}
where delivered_at < purchased_at
   or shipped_at < purchased_at
