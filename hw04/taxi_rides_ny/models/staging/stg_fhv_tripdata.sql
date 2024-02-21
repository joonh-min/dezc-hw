{{
    config(
        materialized='view'
    )
}}

with source as 
(
    select * from {{ source('staging', 'fhv_tripdata') }}
),
renamed as (
    select
        -- identifiers
        {{ dbt.safe_cast("dispatching_base_num", api.Column.translate_type("text")) }} as dispatch_base_num,
        {{ dbt.safe_cast("Affiliated_base_number", api.Column.translate_type("text")) }} as affiliated_base_num,
        {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }} as pickup_locationid,
        {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }} as dropoff_locationid,
        
        -- timestamps
        cast(pickup_datetime as timestamp) as pickup_datetime,
        cast(dropOff_datetime as timestamp) as dropoff_datetime,
        
        -- trip info
        {{ dbt.safe_cast("SR_Flag", api.Column.translate_type("integer")) }} as sr_flag
    from source
)
select * from renamed


-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=false) %}

  limit 100

{% endif %}