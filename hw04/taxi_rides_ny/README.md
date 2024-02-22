#### Adding FHV datas
- Building a source table: ["stg_fhv_tripdata"](models/staging/stg_fhv_tripdata.sql)
- Adding "fhv_tripdata" to [schema](models/staging/schema.yml#L201-L220)
- Building a fact table: ["fact_fhv_trips"](models/core/fact_fhv_trips.sql)
- Adding "fhv_tripdata" to [schema](models/core/schema.yml#L131-L154)

#### Question 3
What is the count of records in the model fact_fhv_trips after running all dependencies with the test run variable disabled (:false)?

<img width="404" alt="image" src="https://github.com/joonh-min/dezc-hw/assets/60901057/f1c149e2-9ef7-4b6e-8503-7118a709354f">

Record count for `fact_fhv_trips` : **22,998,722**

#### Question 4
LINK TO LOOKER STUDIO BOARD
[LINK](https://lookerstudio.google.com/reporting/62ba9ee6-f945-47b9-8171-94133714b0e4)


#### MISC. DBT Dev brach commit histories
[LINK](https://github.com/joonh-min/dezc-hw/commits/new-branch/)
