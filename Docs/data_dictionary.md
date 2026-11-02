# Data dictionary

Generated from dbt metadata by `scripts/generate_catalog_docs.py`. Row counts are from the full dataset build.

## Reference data (seeds)

### `reference.br_states`
Reference list of the 27 Brazilian federative units and their IBGE macro-region.

Rows: 27

| Column | Type | Description |
|---|---|---|
| `state_code` | varchar |  |
| `state_name` | varchar |  |
| `region` | varchar |  |

## Silver — staging (cleaned, typed, one row per source record)

### `staging.stg_customers`
One row per customer_id (a new id per order); customer_unique_id is the person.

Rows: 99,441

| Column | Type | Description |
|---|---|---|
| `customer_id` | varchar |  |
| `customer_unique_id` | varchar |  |
| `zip_prefix` | varchar |  |
| `city` | varchar |  |
| `state_code` | varchar |  |

### `staging.stg_geolocation`
One coordinate per zip prefix (median of the raw points inside Brazil).

Rows: 19,010

| Column | Type | Description |
|---|---|---|
| `zip_prefix` | varchar |  |
| `latitude` | double |  |
| `longitude` | double |  |
| `state_code` | varchar |  |
| `raw_point_count` | bigint |  |

### `staging.stg_order_items`
Order lines. order_item_number is the line position inside the order.

Rows: 112,650

| Column | Type | Description |
|---|---|---|
| `order_item_key` | varchar |  |
| `order_id` | varchar |  |
| `order_item_number` | integer |  |
| `product_id` | varchar |  |
| `seller_id` | varchar |  |
| `shipping_limit_at` | timestamp |  |
| `item_price` | decimal(12,2) |  |
| `freight_value` | decimal(12,2) |  |

### `staging.stg_orders`
Orders, one row per order, with timestamps cast from text.

Rows: 99,441

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `customer_id` | varchar |  |
| `order_status` | varchar |  |
| `purchased_at` | timestamp |  |
| `approved_at` | timestamp |  |
| `shipped_at` | timestamp |  |
| `delivered_at` | timestamp |  |
| `estimated_delivery_at` | timestamp |  |

### `staging.stg_payments`
Payment records; one order can be paid with several methods.

Rows: 103,886

| Column | Type | Description |
|---|---|---|
| `payment_key` | varchar |  |
| `order_id` | varchar |  |
| `payment_sequence` | integer |  |
| `payment_type` | varchar |  |
| `installments` | integer |  |
| `payment_value` | decimal(12,2) |  |

### `staging.stg_products`
Products with English category names; source spelling errors in column names fixed.

Rows: 32,951

| Column | Type | Description |
|---|---|---|
| `product_id` | varchar |  |
| `category_pt` | varchar |  |
| `category` | varchar |  |
| `name_length` | integer |  |
| `description_length` | integer |  |
| `photo_count` | integer |  |
| `weight_g` | integer |  |
| `length_cm` | integer |  |
| `height_cm` | integer |  |
| `width_cm` | integer |  |

### `staging.stg_reviews`
Customer review submissions (not yet deduplicated to one per order).

Rows: 99,224

| Column | Type | Description |
|---|---|---|
| `review_id` | varchar |  |
| `order_id` | varchar |  |
| `review_score` | integer |  |
| `review_title` | varchar |  |
| `review_message` | varchar |  |
| `review_created_at` | timestamp |  |
| `review_answered_at` | timestamp |  |

### `staging.stg_sellers`

Rows: 3,095

| Column | Type | Description |
|---|---|---|
| `seller_id` | varchar |  |
| `zip_prefix` | varchar |  |
| `city` | varchar |  |
| `state_code` | varchar |  |

## Silver — intermediate (business rules)

### `intermediate.int_order_items_summary`

Rows: 98,666

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `item_count` | bigint |  |
| `distinct_products` | bigint |  |
| `seller_count` | bigint |  |
| `items_value` | decimal(38,2) |  |
| `freight_value` | decimal(38,2) |  |
| `primary_seller_id` | varchar |  |
| `latest_shipping_limit_at` | timestamp |  |

### `intermediate.int_order_payments_summary`

Rows: 99,440

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `payment_total` | decimal(38,2) |  |
| `payment_records` | bigint |  |
| `max_installments` | integer |  |
| `primary_payment_type` | varchar |  |
| `used_voucher` | boolean |  |

### `intermediate.int_order_reviews`
Latest review per order.

Rows: 98,673

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `review_id` | varchar |  |
| `review_score` | integer |  |
| `has_comment` | boolean |  |
| `review_created_at` | timestamp |  |
| `review_count` | bigint |  |

### `intermediate.int_orders_enriched`
The single place where order business rules live: revenue recognition (delivered orders only), lost orders (canceled/unavailable), delivery SLA (delivered on or before the promised date) and payment reconciliation.

Rows: 99,441

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `customer_id` | varchar |  |
| `customer_unique_id` | varchar |  |
| `customer_state` | varchar |  |
| `customer_zip_prefix` | varchar |  |
| `primary_seller_id` | varchar |  |
| `order_status` | varchar |  |
| `purchased_at` | timestamp |  |
| `purchase_date` | date |  |
| `approved_at` | timestamp |  |
| `shipped_at` | timestamp |  |
| `delivered_at` | timestamp |  |
| `estimated_delivery_at` | timestamp |  |
| `item_count` | bigint |  |
| `seller_count` | bigint |  |
| `items_value` | decimal(38,2) |  |
| `freight_value` | decimal(38,2) |  |
| `payment_total` | decimal(38,2) |  |
| `primary_payment_type` | varchar |  |
| `max_installments` | integer |  |
| `used_voucher` | boolean |  |
| `is_revenue_recognized` | boolean |  |
| `is_lost_order` | boolean |  |
| `is_delivered` | boolean |  |
| `approval_hours` | double |  |
| `handling_days` | double |  |
| `transit_days` | double |  |
| `cycle_time_days` | double |  |
| `promised_days` | bigint |  |
| `is_on_time` | boolean |  |
| `days_late` | bigint |  |
| `payment_variance` | decimal(38,2) |  |
| `has_invalid_ship_date` | boolean |  |
| `review_score` | integer |  |
| `review_has_comment` | boolean |  |

## Gold — star schema (facts and dimensions)

### `core.dim_customer`
One row per real customer (customer_unique_id), keyed by an md5 surrogate key.

Rows: 96,096

| Column | Type | Description |
|---|---|---|
| `customer_key` | varchar |  |
| `customer_unique_id` | varchar |  |
| `state_code` | varchar |  |
| `zip_prefix` | varchar |  |
| `first_order_at` | timestamp |  |
| `last_order_at` | timestamp |  |
| `lifetime_orders` | bigint |  |
| `delivered_orders` | bigint |  |
| `lifetime_net_revenue` | decimal(38,2) |  |
| `is_repeat_customer` | boolean |  |

### `core.dim_date`
Calendar dimension. date_key is an integer yyyymmdd surrogate key.

Rows: 1,096

| Column | Type | Description |
|---|---|---|
| `date_key` | integer |  |
| `date_day` | date |  |
| `year` | bigint |  |
| `quarter` | bigint |  |
| `month` | bigint |  |
| `month_name` | varchar |  |
| `month_start` | date |  |
| `iso_week` | bigint |  |
| `day_of_week` | bigint |  |
| `day_name` | varchar |  |
| `is_weekend` | boolean |  |

### `core.dim_location`
Brazilian states with macro-region.

Rows: 27

| Column | Type | Description |
|---|---|---|
| `location_key` | varchar |  |
| `state_code` | varchar |  |
| `state_name` | varchar |  |
| `region` | varchar |  |

### `core.dim_product`

Rows: 32,951

| Column | Type | Description |
|---|---|---|
| `product_key` | varchar |  |
| `product_id` | varchar |  |
| `category` | varchar |  |
| `weight_g` | integer |  |
| `volume_cm3` | integer |  |
| `photo_count` | integer |  |
| `weight_band` | varchar |  |

### `core.dim_seller`

Rows: 3,095

| Column | Type | Description |
|---|---|---|
| `seller_key` | varchar |  |
| `seller_id` | varchar |  |
| `city` | varchar |  |
| `state_code` | varchar |  |
| `latitude` | double |  |
| `longitude` | double |  |

### `core.fact_delivery_performance`
Grain = one delivered order with a delivery date and a promised date.

Rows: 96,470

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar |  |
| `customer_key` | varchar |  |
| `seller_key` | varchar |  |
| `purchase_date_key` | integer |  |
| `customer_location_key` | varchar |  |
| `seller_location_key` | varchar |  |
| `is_same_state` | boolean |  |
| `approval_hours` | double |  |
| `handling_days` | double | Days from payment approval to carrier hand-off. |
| `transit_days` | double | Days from carrier hand-off to delivery. |
| `cycle_time_days` | double | Days from purchase to delivery. |
| `promised_days` | bigint |  |
| `is_on_time` | boolean | Delivered on or before the estimated delivery date (compared at date level). |
| `days_late` | bigint | Days after the promised date; 0 when on time. |
| `lateness_band` | varchar |  |
| `freight_value` | decimal(38,2) |  |
| `review_score` | integer |  |

### `core.fact_order_finance`
Grain = one order. net_revenue is item value on delivered orders only; freight is reported separately; payment_variance = payments - (items + freight).

Rows: 99,441

| Column | Type | Description |
|---|---|---|
| `order_id` | varchar | Olist order id (natural key, grain of this table). |
| `customer_key` | varchar | md5 surrogate key to dim_customer. |
| `purchase_date_key` | integer |  |
| `location_key` | varchar |  |
| `order_status` | varchar |  |
| `is_revenue_recognized` | boolean |  |
| `is_lost_order` | boolean |  |
| `item_count` | bigint |  |
| `gross_merchandise_value` | decimal(38,2) | Item value of the order regardless of status. |
| `net_revenue` | decimal(38,2) | Item value if the order was delivered, otherwise 0. |
| `freight_value` | decimal(38,2) |  |
| `payment_total` | decimal(38,2) |  |
| `payment_variance` | decimal(38,2) | payment_total minus (items + freight). Non-zero values usually mean interest on instalments or vouchers. |
| `is_payment_mismatch` | boolean | True when abs(payment_variance) is above the payment_tolerance_brl variable (R$1). |
| `primary_payment_type` | varchar |  |
| `max_installments` | integer |  |
| `used_voucher` | boolean |  |

### `core.fact_order_items`
Grain = one order line.

Rows: 112,650

| Column | Type | Description |
|---|---|---|
| `order_item_key` | varchar |  |
| `order_id` | varchar |  |
| `product_key` | varchar |  |
| `seller_key` | varchar |  |
| `customer_key` | varchar |  |
| `purchase_date_key` | integer |  |
| `order_status` | varchar |  |
| `is_revenue_recognized` | boolean |  |
| `item_price` | decimal(12,2) |  |
| `freight_value` | decimal(12,2) |  |
| `net_revenue` | decimal(12,2) |  |

## Gold — governed KPI marts

### `metrics.kpi_category_performance`

Rows: 74

| Column | Type | Description |
|---|---|---|
| `category` | varchar |  |
| `orders` | bigint |  |
| `units` | bigint |  |
| `net_revenue` | decimal(38,2) |  |
| `revenue_share` | double |  |
| `avg_item_price` | double |  |
| `freight_to_price_ratio` | double |  |
| `avg_review_score` | double |  |
| `on_time_rate` | double |  |

### `metrics.kpi_delivery_by_state`

Rows: 27

| Column | Type | Description |
|---|---|---|
| `state_code` | varchar |  |
| `state_name` | varchar |  |
| `region` | varchar |  |
| `delivered_orders` | bigint |  |
| `on_time_rate` | double |  |
| `avg_cycle_time_days` | double |  |
| `avg_promised_days` | double |  |
| `avg_freight` | double |  |
| `avg_review_score` | double |  |
| `same_state_share` | double |  |

### `metrics.kpi_monthly`
Governed monthly KPIs. See Governance/metric_definitions.md for every formula.

Rows: 25

| Column | Type | Description |
|---|---|---|
| `month_start` | date |  |
| `orders_placed` | bigint |  |
| `orders_delivered` | bigint |  |
| `orders_lost` | bigint |  |
| `lost_order_rate` | double |  |
| `gmv` | decimal(38,2) |  |
| `net_revenue` | decimal(38,2) |  |
| `freight_collected` | decimal(38,2) |  |
| `avg_order_value` | double |  |
| `active_customers` | bigint |  |
| `new_customers` | bigint |  |
| `on_time_rate` | double |  |
| `avg_cycle_time_days` | double |  |
| `median_cycle_time_days` | double |  |
| `avg_review_score` | double |  |
| `is_complete_month` | boolean |  |

### `metrics.kpi_review_by_lateness`

Rows: 4

| Column | Type | Description |
|---|---|---|
| `lateness_band` | varchar |  |
| `delivered_orders` | bigint |  |
| `avg_review_score` | double |  |
| `negative_review_rate` | double |  |
| `five_star_rate` | double |  |

### `metrics.seller_scorecard`

Rows: 2,970

| Column | Type | Description |
|---|---|---|
| `seller_key` | varchar |  |
| `seller_id` | varchar |  |
| `state_code` | varchar |  |
| `delivered_orders` | bigint |  |
| `net_revenue` | decimal(38,2) |  |
| `on_time_rate` | double |  |
| `avg_review_score` | double |  |
| `avg_handling_days` | double |  |
| `seller_tier` | varchar |  |
