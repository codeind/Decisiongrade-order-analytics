-- Grain: one row per product.
select
    md5(product_id)                                         as product_key,
    product_id,
    category,
    weight_g,
    length_cm * height_cm * width_cm                        as volume_cm3,
    photo_count,
    case
        when weight_g is null then 'unknown'
        when weight_g < 500   then 'light (<0.5kg)'
        when weight_g < 2000  then 'medium (0.5-2kg)'
        when weight_g < 10000 then 'heavy (2-10kg)'
        else 'bulky (10kg+)'
    end                                                     as weight_band
from {{ ref('stg_products') }}
