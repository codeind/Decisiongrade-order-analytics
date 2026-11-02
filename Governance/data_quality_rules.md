# Data quality rules

DecisionGrade runs **90 automated tests** on every `dbt build`: 85 at error severity and 5 at warn severity. The full list is generated into [test_catalog.md](test_catalog.md).

## How a failure is handled

| Severity | What happens in `dbt build` | What happens in CI |
|---|---|---|
| **error** | The test fails and dbt **skips every model downstream of it**, so bad data never reaches the marts or dashboards | The GitHub Actions job fails; with branch protection on, the pull request cannot merge |
| **warn** | Reported in the log; the build continues | Listed in the job summary under "Tests needing attention" |

## Technical controls (generic dbt tests)

| Control | Count | Applied to |
|---|---|---|
| `unique` | 26 | Every primary key and surrogate key, in every layer |
| `not_null` | 37 | Keys, timestamps that drive metrics, review scores |
| `relationships` | 11 | Foreign keys: order → customer, line → product/seller, fact → every dimension |
| `accepted_values` | 7 | Order status, payment type, review score 1–5, lateness bands, seller tiers, regions |

## Business controls (custom tests in `DBT/tests/`)

| Test | Severity | Rule | Why it matters |
|---|---|---|---|
| `assert_delivery_not_before_purchase` | error | No order is delivered or shipped before it was bought | Negative durations would corrupt cycle-time KPIs |
| `assert_net_revenue_valid` | error | Net revenue is never negative and never exceeds order GMV | Protects revenue recognition logic |
| `assert_finance_fact_complete` | error | Every source order appears in `fact_order_finance` exactly once | Detects orders lost or duplicated by joins |
| `assert_kpi_revenue_reconciles` | error | `kpi_monthly` revenue equals `fact_order_finance` revenue to the cent | Guarantees dashboard and finance figures match |
| `assert_payment_reconciliation_rate` | warn | ≤ 2% of orders may differ from items + freight by more than R$1 | Catches payment feed problems |
| `assert_on_time_rate_floor` | warn | No complete month below the 85% on-time floor | SLA monitoring |
| `assert_revenue_mom_swing` | warn | Monthly revenue may not move more than 60% month over month | Revenue anomaly detection |
| `assert_invalid_ship_dates` | warn | Counts orders whose carrier date was earlier than purchase | Monitors the quarantine rule below |
| `assert_delivered_status_has_date` | warn | Delivered orders should have a delivery date | Source system completeness |

## Results on the full dataset

`dbt build` on 99,441 orders: **87 pass, 3 warn, 0 fail.**

| Warning | Result | Interpretation |
|---|---|---|
| `assert_invalid_ship_dates` | 166 orders | Source error: carrier hand-off dated before purchase. Dates quarantined (set to null) in `int_orders_enriched` |
| `assert_delivered_status_has_date` | 8 orders | Marked delivered with no delivery date; kept in revenue, excluded from delivery KPIs |
| `assert_on_time_rate_floor` | 1 month | March 2018 at 81.0%, a real SLA breach (see `analysis/findings.md`) |

## Quarantine rule

When the source has an impossible value that would distort a metric but the rest of the record is valid, the model nulls the bad field and sets a flag (for example `has_invalid_ship_date`) instead of dropping the order. Revenue stays complete, the metric stays clean, and the flagged rows can be reported back to the source owner.
