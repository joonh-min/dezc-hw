-- SETUP:
--    Create an external table using the Green Taxi Trip Records Data for 2022.
--    Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).
-- Creating external table referring to gcs path
CREATE
OR REPLACE EXTERNAL TABLE `ny_taxi.external_green_tripdata` OPTIONS (
    format = 'parquet',
    uris = ['gs://{my-bucket}/nyc_taxi_data/green/2022/green_tripdata_2022-*.parquet']
);

-- Create a non partitioned table from external table
CREATE
OR REPLACE TABLE ny_taxi.green_tripdata AS
SELECT
    *
FROM
    ny_taxi.external_green_tripdata;

-- Homework Answers
-- Question 1: What is count of records for the 2022 Green Taxi Data??
SELECT
    count(*)
FROM
    `ny_taxi.external_green_tripdata`;

-- 840,402
-- Question 2: Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
-- What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?
SELECT
    DISTINCT(PULocationID)
FROM
    ny_taxi.external_green_tripdata;

-- 0B
SELECT
    DISTINCT(PULocationID)
FROM
    ny_taxi.green_tripdata;

-- 6.41 MB
-- Question 3: How many records have a fare_amount of 0?
SELECT
    count(*)
FROM
    ny_taxi.external_green_tripdata
WHERE
    fare_amount = 0;

-- Question 4: What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)
-- Cluster on lpep_pickup_datetime Partition by PUlocationID
-- Partition by lpep_pickup_datetime Cluster on PUlocationID
-- Partition by lpep_pickup_datetime and Partition by PUlocationID
-- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID
-- Check max(PUlocationID) and the the busiest day.
SELECT
    max(PUlocationID)
FROM
    ny_taxi.external_green_tripdata;

-- 265
SELECT
    DATE(lpep_pickup_datetime) AS date,
    count(*) AS count
FROM
    ny_taxi.external_green_tripdata
GROUP BY
    DATE(lpep_pickup_datetime);

-- 2022-12-21
-- Cluster on lpep_pickup_datetime Partition by PUlocationID
CREATE
OR REPLACE TABLE `ny_taxi.green_partitioned_tripdata` PARTITION BY RANGE_BUCKET(PUlocationID, GENERATE_ARRAY(0, 265, 1)) CLUSTER BY lpep_pickup_datetime AS (
    SELECT
        *
    FROM
        `ny_taxi.green_tripdata`
);

-- 0s, 113.86MB, 4329 slot/ms
-- Partition by lpep_pickup_datetime Cluster on PUlocationID
CREATE
OR REPLACE TABLE `ny_taxi.green_partitioned_tripdata` PARTITION BY DATE(lpep_pickup_datetime) CLUSTER BY PUlocationID AS (
    SELECT
        *
    FROM
        `ny_taxi.green_tripdata`
);

-- 0s, 414.55KB, 26 slot/ms
-- Partition by lpep_pickup_datetime and Partition by PUlocationID
-- ** Seems like BQ doesn't support multi-column partiitoning
-- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID
CREATE
OR REPLACE TABLE `ny_taxi.green_partitioned_tripdata` CLUSTER BY lpep_pickup_datetime,
PUlocationID AS
SELECT
    *
FROM
    `ny_taxi.green_tripdata`;

-- 0s, 114.11MB, 247 slot/ms
-- Verification query
SELECT
    *
FROM
    ny_taxi.green_partitioned_tripdata
WHERE
    DATE(lpep_pickup_datetime) = '2022-12-21'
ORDER BY
    PUlocationID;

-- Question 5: Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)
-- Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?
-- Choose the answer which most closely matches.
-- Querying from materialized table:
SELECT
    DISTINCT(PULocationID)
FROM
    `ny_taxi.green_tripdata`
WHERE
    DATE(lpep_pickup_datetime) BETWEEN '2022-01-06'
    AND '2022-06-30';

-- result: 12.82MB
-- Querying from partitioned table:
SELECT
    DISTINCT(PULocationID)
FROM
    `ny_taxi.green_partitioned_tripdata`
WHERE
    DATE(lpep_pickup_datetime) BETWEEN '2022-01-06'
    AND '2022-06-30';

-- result: 6.53MB
-- Trying different method:
SELECT
    DISTINCT(PULocationID)
FROM
    `ny_taxi.green_partitioned_tripdata`
WHERE
    DATE(lpep_pickup_datetime) >= '2022-01-06'
    AND DATE(lpep_pickup_datetime) <= '2022-06-30';

-- result: 6.53MB