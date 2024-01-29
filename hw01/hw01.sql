--ONLY THE SQL RELATED QUESTIONS

--Question 3. Count records 
--How many taxi trips were totally made on September 18th 2019?
select count(*)
from yellow_taxi_trips ytt -- the dataset is green taxi, but yeah.
where ytt.lpep_pickup_datetime::date = '2019-09-18'
and ytt.lpep_dropoff_datetime::date = '2019-09-18';
--15,612

--Question 4. Largest trip for each day
--Which was the pick up day with the largest trip distance
--Use the pick up time for your calculations.
select lpep_pickup_datetime::date, max(trip_distance) as max_trip_dist
from yellow_taxi_trips ytt
where lpep_pickup_datetime::date in ('2019-09-16', '2019-09-18', '2019-09-26', '2019-09-21')
group by lpep_pickup_datetime::date
order by max_trip_dist desc
limit 1;
--'2019-09-26'

--Question 5. Three biggest pick up Boroughs
--Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown
--Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
select *
from (
	select z."Borough", sum(total_amount) total_per_bor
	from yellow_taxi_trips ytt 
	join zones z
	on ytt."PULocationID" = z."LocationID"
	where ytt.lpep_pickup_datetime::date = '2019-09-18'
	and z."Borough" != 'Unknown'
	group by z."Borough" 
) foo where total_per_bor > 50000;
--Brooklyn, Manhattan, Queens

-- Question 6. Largest tip
--For the passengers picked up in September 2019 in the zone name Astoria
--which was the drop off zone that had the largest tip?
--We want the name of the zone, not the id.
select doz.DOZone, max(tip_amount) max_tip
from yellow_taxi_trips ytt 
join (
	select "LocationID" PULocID, "Zone" PUZone
	from zones
) puz
on ytt."PULocationID" = puz.PULocID
join (
	select "LocationID" DOLocID, "Zone" DOZone
	from zones
) doz
on ytt."DOLocationID" = doz.DOLocID
where extract(year from ytt.lpep_pickup_datetime) = 2019
and extract(month from ytt.lpep_pickup_datetime) = 9
and puz.PUZone = 'Astoria'
group by doz.DOZone
order by max_tip desc
limit 1;
--JFK Airport
