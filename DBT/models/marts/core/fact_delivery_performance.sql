-- Grain: one row per delivered order with complete delivery timestamps.
select
    o.order_id,
    md5(o.customer_unique_id)                               as customer_key,
    md5(o.primary_seller_id)                                as seller_key,
    cast(strftime(o.purchase_date, '%Y%m%d') as integer)    as purchase_date_key,
    o.customer_state                                        as customer_location_key,
    s.state_code                                            as seller_location_key,
    o.customer_state = s.state_code                         as is_same_state,
    o.approval_hours,
    o.handling_days,
    o.transit_days,
    o.cycle_time_days,
    o.promised_days,
    o.is_on_time,
    o.days_late,
    case
        when o.days_late = 0 then 'on time'
        when o.days_late <= 3 then '1-3 days late'
        when o.days_late <= 7 then '4-7 days late'
        else '8+ days late'
    end                                                     as lateness_band,
    o.freight_value,
    o.review_score
from {{ ref('int_orders_enriched') }} o
left join {{ ref('stg_sellers') }} s on o.primary_seller_id = s.seller_id
where o.is_delivered
  and o.estimated_delivery_at is not null
