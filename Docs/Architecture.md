# Architecture

## Medallion layers

| Layer | dbt folder / schema | Materialisation | Purpose |
|---|---|---|---|
| **Bronze** (raw) | `Data/raw/*.csv` | files, read with `read_csv(all_varchar)` | Untouched source files, preserved for audit and reprocessing |
| **Silver** (staging) | `models/staging` → `staging` | tables | Type casting, renaming, trimming, zip-code padding, category translation. One row per source record |
| **Silver** (intermediate) | `models/intermediate` → `intermediate` | views | Business rules: order roll-ups, latest review, revenue recognition, SLA, quarantine |
| **Gold** (core) | `models/marts/core` → `core` | tables | Star schema: 3 facts, 5 dimensions |
| **Gold** (metrics) | `models/marts/metrics` → `metrics` | tables | Governed KPI tables read by dashboards |
| BI | `Dashboards/` | — | Presentation only; no metric logic |

Reference data (Brazilian states and regions) is a dbt seed in the `reference` schema.

## Warehouse targets

| Target | Engine | Data | Used for |
|---|---|---|---|
| `dev` | DuckDB file `warehouse/decisiongrade.duckdb` | full dataset | development and analysis |
| `cloud` | MotherDuck (`md:decisiongrade`) | full dataset | cloud warehouse, deployed by GitHub Actions on every merge to `main` |
| `ci` | DuckDB file `warehouse/ci.duckdb` | 3% sample in `Data/sample` | GitHub Actions on every pull request |

The SQL is the same for all three; only `profiles.yml` changes.

## Lineage

```mermaid
flowchart LR
  subgraph Bronze
    R1[orders.csv]; R2[order_items.csv]; R3[payments.csv]; R4[reviews.csv]
    R5[customers.csv]; R6[products.csv]; R7[sellers.csv]; R8[geolocation.csv]
  end
  subgraph Silver
    S1[stg_orders]; S2[stg_order_items]; S3[stg_payments]; S4[stg_reviews]
    S5[stg_customers]; S6[stg_products]; S7[stg_sellers]; S8[stg_geolocation]
    I1[int_order_items_summary]; I2[int_order_payments_summary]; I3[int_order_reviews]
    I4[int_orders_enriched]
  end
  subgraph Gold
    F1[fact_order_finance]; F2[fact_order_items]; F3[fact_delivery_performance]
    D1[dim_customer]; D2[dim_product]; D3[dim_seller]; D4[dim_location]; D5[dim_date]
    K1[kpi_monthly]; K2[kpi_delivery_by_state]; K3[kpi_review_by_lateness]
    K4[kpi_category_performance]; K5[seller_scorecard]
  end
  R1-->S1; R2-->S2; R3-->S3; R4-->S4; R5-->S5; R6-->S6; R7-->S7; R8-->S8
  S2-->I1; S3-->I2; S4-->I3
  S1-->I4; S5-->I4; I1-->I4; I2-->I4; I3-->I4
  I4-->F1; I4-->F2; S2-->F2; I4-->F3; S7-->F3
  I4-->D1; S6-->D2; S7-->D3; S8-->D3; I4-->D5
  F1-->K1; F3-->K1; D1-->K1; D5-->K1
  F3-->K2; D4-->K2; F3-->K3
  F2-->K4; D2-->K4; F3-->K4
  F2-->K5; D3-->K5; F3-->K5
```

The interactive, column-level version is the dbt docs site in [`dbt_docs/index.html`](dbt_docs/index.html).

## Star schema

| Table | Grain | Keys |
|---|---|---|
| `fact_order_finance` | one order | `customer_key`, `purchase_date_key`, `location_key` |
| `fact_order_items` | one order line | `product_key`, `seller_key`, `customer_key`, `purchase_date_key` |
| `fact_delivery_performance` | one delivered order | `customer_key`, `seller_key`, `purchase_date_key`, customer and seller `location_key` |
| `dim_customer` | one real customer | `customer_key` = md5(`customer_unique_id`) |
| `dim_product` | one product | `product_key` = md5(`product_id`) |
| `dim_seller` | one seller | `seller_key` = md5(`seller_id`) |
| `dim_location` | one state | `location_key` = state code |
| `dim_date` | one day | `date_key` = yyyymmdd integer |

Surrogate keys are generated in the warehouse so facts join to dimensions the same way regardless of how the source identifies the entity.

## Design rules

- Business logic is written once, in the intermediate layer.
- Dashboards do not define metrics.
- Every model has tests in its `.yml` file; keys are tested for uniqueness and referential integrity.
- Thresholds are dbt variables, so changing one is a reviewed code change.
