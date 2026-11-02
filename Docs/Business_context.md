# Business context

## The business

Olist is a Brazilian marketplace that connects small and mid-size merchants to large online stores. A customer buys from a seller through Olist; the seller ships through a carrier; Olist collects payment and a review. This project uses Olist's public dataset of **99,441 orders placed between September 2016 and October 2018**, covering 96,096 customers and 3,095 sellers across all 27 Brazilian states.

## Order-to-delivery process in the data

| Step | Field in source | Model field |
|---|---|---|
| Customer places order | `order_purchase_timestamp` | `purchased_at` |
| Payment approved | `order_approved_at` | `approved_at` |
| Seller hands parcel to carrier | `order_delivered_carrier_date` | `shipped_at` |
| Carrier delivers | `order_delivered_customer_date` | `delivered_at` |
| Date promised at checkout | `order_estimated_delivery_date` | `estimated_delivery_at` |
| Customer reviews | `review_score` | `review_score` |

## Reporting problems the platform addresses

These are the problems that come up when teams query raw marketplace data independently. Each one has a concrete fix in the models.

| Problem | Example in the raw data | Fix |
|---|---|---|
| Inconsistent revenue | Should canceled or in-transit orders count? Is freight revenue? | Revenue recognised at delivery, item value only (`int_orders_enriched`) |
| Double-counted customers | A new `customer_id` is issued for every order | All customer metrics use `customer_unique_id` (`dim_customer`) |
| Conflicting SLA numbers | "Late" measured against different dates | One rule: delivered date vs. promised date, compared at date level |
| Duplicate reviews | ~550 orders have several reviews | Latest review per order (`int_order_reviews`) |
| Bad source timestamps | 166 carrier dates earlier than the purchase | Quarantined and flagged, monitored by a test |
| Payment mismatches | Payments can differ from items + freight (instalment interest, vouchers) | Reconciliation column and a threshold test |

## Decisions supported

See [Decision_mapping.md](Decision_mapping.md).

## Not covered by this data

The dataset has no inventory, stock, product cost or marketing data. Inventory and margin metrics from the original plan are therefore out of scope.
