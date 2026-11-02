# Data

| Folder | Contents | In git? |
|---|---|---|
| `raw/` | The 9 original Olist CSV files (~120 MB), never edited | **No.** Download with `python scripts/download_data.py` |
| `sample/` | 3% referentially complete sample (3,049 orders, ~2.6 MB) used by CI | Yes. Rebuild with `python scripts/make_sample.py` |
| `processed/` | Governed KPI tables exported from the warehouse for Power BI / Excel | Yes. Rebuilt by `python analysis/run_analysis.py` |

## Source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle, licensed CC BY-NC-SA 4.0. Real, anonymised commercial data; company names in reviews were replaced with Game of Thrones house names by Olist.

| File | Rows | Grain |
|---|---|---|
| olist_orders_dataset | 99,441 | order |
| olist_order_items_dataset | 112,650 | order line |
| olist_order_payments_dataset | 103,886 | payment record |
| olist_order_reviews_dataset | 99,224 | review |
| olist_customers_dataset | 99,441 | customer_id (one per order) |
| olist_sellers_dataset | 3,095 | seller |
| olist_products_dataset | 32,951 | product |
| olist_geolocation_dataset | 1,000,163 | geocoded point |
| product_category_name_translation | 71 | category |

## Rules

1. Raw files are immutable. All cleaning happens in dbt staging models.
2. Everything outside `raw/` can be regenerated from code.
