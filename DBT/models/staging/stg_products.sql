-- Grain: one row per product. Fixes the misspelled source column names
-- ("lenght") and attaches the English category name.
with source as (
    select * from {{ raw_csv('olist_products_dataset') }}
),
translation as (
    select
        trim(product_category_name)         as category_pt,
        trim(product_category_name_english) as category_en
    from {{ raw_csv('product_category_name_translation') }}
)
select
    trim(s.product_id)                                            as product_id,
    nullif(trim(s.product_category_name), '')                     as category_pt,
    coalesce(t.category_en, nullif(trim(s.product_category_name), ''), 'unknown') as category,
    try_cast(s.product_name_lenght as integer)                    as name_length,
    try_cast(s.product_description_lenght as integer)             as description_length,
    try_cast(s.product_photos_qty as integer)                     as photo_count,
    try_cast(s.product_weight_g as integer)                       as weight_g,
    try_cast(s.product_length_cm as integer)                      as length_cm,
    try_cast(s.product_height_cm as integer)                      as height_cm,
    try_cast(s.product_width_cm as integer)                       as width_cm
from source s
left join translation t
    on trim(s.product_category_name) = t.category_pt
