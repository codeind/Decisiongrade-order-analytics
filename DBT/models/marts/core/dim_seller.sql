-- Grain: one row per seller.
select
    md5(s.seller_id)                                        as seller_key,
    s.seller_id,
    s.city,
    s.state_code,
    g.latitude,
    g.longitude
from {{ ref('stg_sellers') }} s
left join {{ ref('stg_geolocation') }} g on s.zip_prefix = g.zip_prefix
