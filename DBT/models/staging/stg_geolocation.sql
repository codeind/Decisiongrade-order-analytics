-- Grain: one row per 5-digit zip prefix. The raw file has ~1M rows with many
-- duplicate points per prefix; we keep the median coordinate per prefix.
with source as (
    select * from {{ raw_csv('olist_geolocation_dataset') }}
)
select
    lpad(trim(geolocation_zip_code_prefix), 5, '0')  as zip_prefix,
    median(cast(geolocation_lat as double))          as latitude,
    median(cast(geolocation_lng as double))          as longitude,
    mode(upper(trim(geolocation_state)))             as state_code,
    count(*)                                         as raw_point_count
from source
-- Brazil's bounding box; drops a handful of mis-geocoded points
where cast(geolocation_lat as double) between -34 and 6
  and cast(geolocation_lng as double) between -74 and -34
group by 1
