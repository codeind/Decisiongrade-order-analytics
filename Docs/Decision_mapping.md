# Decision mapping

Every KPI in the platform exists to support a decision. Inventory and margin decisions from the original plan are omitted because the source has no inventory or cost data.

| Decision | Metric | Model | What the data showed |
|---|---|---|---|
| Carrier management and peak-season capacity | On-time rate, carrier transit days | `kpi_monthly`, `fact_delivery_performance` | Transit rose from ~8 to 13 days in Feb 2018 while seller handling stayed ~3 days |
| Delivery promise setting | Promised days vs cycle time | `fact_delivery_performance` | Promises average 24.4 days vs 12.6 actual |
| Regional expansion and logistics investment | On-time rate and days to deliver by state | `kpi_delivery_by_state` | Northeast on-time 87.3%; AL, MA, SE below the 85% floor |
| Seller management | Seller tier, on-time rate, review score | `seller_scorecard` | 35 at-risk sellers carry R$533K of revenue |
| Revenue reporting | Net revenue, GMV, AOV | `kpi_monthly`, `fact_order_finance` | R$13.22M net revenue, AOV R$137 |
| Customer experience priorities | Review score by lateness | `kpi_review_by_lateness` | 79% of orders 8+ days late get 1–2 stars |
| Retention strategy | Repeat customer rate | `dim_customer` | 3.1% of customers order twice |
| Category and shipping policy | Revenue share, freight-to-price ratio | `kpi_category_performance` | Freight is 20% of price on light items |

## Ownership

| Metric group | Business owner | Technical owner |
|---|---|---|
| Revenue | Finance | Analytics engineering |
| Delivery and SLA | Operations / Logistics | Analytics engineering |
| Reviews and retention | Customer experience / Marketing | Analytics engineering |
| Seller tiers | Seller success | Analytics engineering |
