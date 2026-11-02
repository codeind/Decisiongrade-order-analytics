-- Grain: one row per Brazilian state (federative unit).
select
    s.state_code                                    as location_key,
    s.state_code,
    s.state_name,
    s.region
from {{ ref('br_states') }} s
