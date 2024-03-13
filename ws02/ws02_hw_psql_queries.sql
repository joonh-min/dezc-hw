-- Question 1: Create a materialized view to compute the average, min and max trip time between each taxi zone.
CREATE MATERIALIZED VIEW trip_duration_btw_zones AS
SELECT pz.Zone AS pu_zone, dz.Zone AS do_zone, min_t, avg_t, max_t
FROM (
    SELECT
        trip_data.PULocationID, trip_data.DOLocationID,
        MIN(tpep_dropoff_datetime - tpep_pickup_datetime) AS min_t,
        AVG(tpep_dropoff_datetime - tpep_pickup_datetime) AS avg_t,
        MAX(tpep_dropoff_datetime - tpep_pickup_datetime) AS max_t
    FROM trip_data
    WHERE PULocationID != DOLocationID
    GROUP BY trip_data.DOLocationID, trip_data.PULocationID
) AS duration
JOIN taxi_zone AS pz ON duration.PULocationID = pz.location_id
JOIN taxi_zone AS dz ON duration.DOLocationID = dz.location_id;

--From this MV, find the pair of taxi zones with the highest average trip time. You may need to use the dynamic filter pattern for this.
SELECT * FROM trip_duration_btw_zones ORDER BY avg_t DESC LIMIT 10;

-- Question 2: Recreate the MV(s) in question 1, to also find the number of trips for the pair of taxi zones with the highest average trip time.
CREATE MATERIALIZED VIEW trip_duration_btw_zones_with_count AS
SELECT pz.Zone AS pu_zone, dz.Zone AS do_zone, min_t, avg_t, max_t, count
FROM (
    SELECT
        trip_data.PULocationID, trip_data.DOLocationID,
        MIN(tpep_dropoff_datetime - tpep_pickup_datetime) AS min_t,
        AVG(tpep_dropoff_datetime - tpep_pickup_datetime) AS avg_t,
        MAX(tpep_dropoff_datetime - tpep_pickup_datetime) AS max_t,
        count(1) as count
    FROM trip_data
    WHERE PULocationID != DOLocationID
    GROUP BY trip_data.DOLocationID, trip_data.PULocationID
) AS duration
JOIN taxi_zone AS pz ON duration.PULocationID = pz.location_id
JOIN taxi_zone AS dz ON duration.DOLocationID = dz.location_id;

SELECT * FROM trip_duration_btw_zones_with_count ORDER BY avg_t DESC LIMIT 10;

--Question 3: From the latest pickup time to 17 hours before, what are the top 3 busiest zones in terms of number of pickups?
--For example if the latest pickup time is 2020-01-01 12:00:00, then the query should return the top 3 busiest zones from 2020-01-01 11:00:00 to 2020-01-01 12:00:00.
CREATE MATERIALIZED VIEW pickup_count AS
SELECT tz.Zone, count(1) as pu_number
FROM trip_data t
JOIN taxi_zone tz
ON t.PULocationID = tz.location_id
WHERE tpep_pickup_datetime >= (
    select MAX(tpep_pickup_datetime) - interval '17 hours'
    FROM trip_data
)
GROUP BY tz.Zone;

SELECT * FROM pickup_count ORDER BY pu_number DESC LIMIT 3;
