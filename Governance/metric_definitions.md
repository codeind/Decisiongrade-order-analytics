# Metric definitions

The single source of truth for every KPI shown in the dashboards. Any change to a formula below needs a pull request that updates this file, the model, and `change_log.md` together.

Owners describe the role that would own the metric in a real organisation.

| Metric | Definition | Formula | Grain / model | Owner |
|---|---|---|---|---|
| Net revenue | Item value of orders that were delivered. Revenue is recognised at delivery. | `sum(item_price)` where `order_status = 'delivered'` | `fact_order_finance.net_revenue` → `kpi_monthly.net_revenue` | Finance |
| Gross merchandise value (GMV) | Item value of all orders, any status | `sum(item_price)` | `fact_order_finance.gross_merchandise_value` | Finance |
| Freight collected | Shipping charged on delivered orders. Not revenue. | `sum(freight_value)` where delivered | `kpi_monthly.freight_collected` | Finance |
| Average order value (AOV) | Revenue per delivered order | `net_revenue / orders_delivered` | `kpi_monthly.avg_order_value` | Finance |
| Lost order rate | Share of orders canceled or unavailable | `orders_lost / orders_placed` | `kpi_monthly.lost_order_rate` | Operations |
| On-time delivery rate | Share of delivered orders that arrived on or before the promised date | `avg(delivered_date <= estimated_date)` on delivered orders with both dates | `fact_delivery_performance.is_on_time` → `kpi_monthly.on_time_rate` | Operations |
| Order cycle time | Days from purchase to delivery | `avg(delivered_at - purchased_at)` in days | `fact_delivery_performance.cycle_time_days` | Operations |
| Seller handling time | Days from payment approval to carrier hand-off | `avg(shipped_at - approved_at)` | `fact_delivery_performance.handling_days` | Seller success |
| Carrier transit time | Days from carrier hand-off to delivery | `avg(delivered_at - shipped_at)` | `fact_delivery_performance.transit_days` | Logistics |
| Promised days | Days between purchase and the date promised at checkout | `estimated_date - purchase_date` | `fact_delivery_performance.promised_days` | Logistics |
| Average review score | Mean of the latest review per delivered order (1–5) | `avg(review_score)` | `kpi_monthly.avg_review_score` | Customer experience |
| Negative review rate | Share of reviews scoring 1 or 2 | `avg(review_score <= 2)` | `kpi_review_by_lateness` | Customer experience |
| Repeat customer rate | Share of customers (by `customer_unique_id`) with more than one order | `avg(lifetime_orders > 1)` | `dim_customer.is_repeat_customer` | Marketing |
| New customers | Customers whose first order falls in the month | count of customers with `first_order_at` in month | `kpi_monthly.new_customers` | Marketing |
| Seller tier | Classification of sellers with 20+ delivered orders | at risk: review < 3.5 or on time < 80%; top: review ≥ 4.3 and on time ≥ 93%; otherwise standard | `seller_scorecard.seller_tier` | Seller success |

## Rules that apply to every metric

- **Customer identity**: Olist issues a new `customer_id` per order. All customer counts use `customer_unique_id`.
- **Time attribution**: every metric is attributed to the **purchase month** of the order.
- **Complete months**: trend views use months with at least 500 orders (`is_complete_month`). This excludes Sep–Dec 2016 and Sep–Oct 2018.
- **Thresholds** used by tests are dbt variables in `DBT/dbt_project.yml` (`on_time_rate_floor = 0.85`, `payment_tolerance_brl = 1.00`, `revenue_mom_swing_limit = 0.60`), so changing a threshold is a reviewed code change.

## Out of scope

Inventory turnover and GMROI were in the original plan. The Olist dataset has no inventory, stock or cost data, so these metrics are not calculated rather than estimated from assumptions.
