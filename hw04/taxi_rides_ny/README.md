#### Adding FHV datas
- Building a source table: ["stg_fhv_tripdata"](models/staging/stg_fhv_tripdata.sql)
- Adding "fhv_tripdata" to [schema](models/staging/schema.yml#L201-L220)
- Building a fact table: ["fact_fhv_trips"](models/core/fact_fhv_trips.sql)
- Adding "fhv_tripdata" to [schema](models/core/schema.yml#L131-L154)

#### DBT Dev brach commit histories
[LINK](https://github.com/joonh-min/dezc-hw/commits/new-branch/)

#### LINK TO LOOKER STUDIO BOARD
[LINK](https://lookerstudio.google.com/reporting/62ba9ee6-f945-47b9-8171-94133714b0e4)
