use sample_airport_db;
select count(*) from sample_airport_db.airport_db;
select * from airport_db;

-- Problem Statement 1. Get an idea of travel insight between 2 pairs of airports i.e. how many passengers are travelling
-- To find out 
-- 1.Most frequent route
-- 2.Number of passenger's travel details
-- Based on that we can take decisions to plan some airline operations
select
	Origin_airport,
	Destination_airport,
    sum(Passengers) as Total_Passengers
from
	airport_db
group by 
	Origin_airport,
    Destination_airport
order by
	Total_Passengers desc;
    
-- Problem Statement 2.Identify Highest and Lowest seat occupancy
-- To find out
-- 1.Optimize flight capacity
-- 2.Improving operational efficiency
select
	Origin_airport,
    Destination_airport,
    avg(CAST(Passengers as float)/NULLIF(Seats,0))*100 as average_seat_utilization
from
	airport_db
group by
	Origin_airport,
    Destination_airport
order by
	average_seat_utilization desc;
    
-- Problem Statement 3. Identify most frequent travel route(i.e. maximum number of passengers travelling)
-- To find out
-- 1.Optimize resource allocation
-- 2.Enhance the service
select
	Origin_airport,
    Destination_airport,
    sum(Passengers) as Total_passengers
from
	airport_db
group by
	Origin_airport,
    Destination_airport
order by
	Total_passengers desc;

-- Problem Statement 4. Identify the activity level at various origin cities
-- To find out
-- 1.Key hub
-- 2.Decisions for some flight operations & capacity management
select
	origin_city,
    count(flights) as total_flights,
    sum(passengers) as total_passengers
from
	airport_db
group by 
	origin_city
order by
	total_passengers desc;

-- Problem Statement 5. 
-- To find out 
-- 1. Find out travel pattern
-- 2. Future route planning

select
	Origin_airport,
    sum(distance) as Total_distance
from
	airport_db
group by 
	Origin_airport
order by
	Total_distance desc;
    
-- Problem statement 6. Identify the seasonal trends
-- To find out
-- 1. To increase or decrease the resources for a route
-- 2. Strategy making for some particular seasons

Select
	YEAR(Fly_date) as Year_flight,
    MONTH(fly_date) as Month_flight,
    count(Flights) as Total_flights,
    sum(Passengers) as Total_passengers,
    avg(Distance) as Avg_distance
from
	airport_db
group by
	Year_flight,Month_flight
order by
	Year_flight desc, Month_flight desc;
    
-- Problem statement 7: Identify under-utilised routes where passengers to seat ratio is less than 0.5
-- To find out-
-- 1.Proper capacity management
-- 2.Route adjustment  

select
	Origin_airport,
    Destination_airport,
    sum(Passengers) as Total_passengers,
    sum(Seats) as Total_seats,
    (sum(Passengers) *1.0/Nullif(sum(Seats),0)) as Passengers_to_seats_ratio
from
	airport_db
group by
	Origin_airport,
    Destination_airport
having
	Passengers_to_seats_ratio<0.5
order by
	Passengers_to_seats_ratio;
    
 -- Problem statement 8: Identify the most active airport where flight frequency is high
 -- To find out
 -- 1. Where the airline & stackholder should optimize the flight scheduling
 -- 2. Where to improve airline services
 
 select
	Origin_airport,
    count(Flights) as Total_flights
from
	airport_db
group by
	Origin_airport
Order by
	Total_flights desc;
    
-- Problem statement 9: Identify the flight details for a particular city or location
-- To find out-
-- 1.Requirement of flights for that particular location

select
	Origin_city,
    count(Flights) as Total_flights,
    sum(Passengers) as Total_passengers
from
	airport_db
where
	Destination_city="Bend, OR" and
    Origin_city<>"Bend, OR"
group by
	Origin_city
order by
	Total_flights desc;
    
-- Problem statement 10. Identify maximum extensive travel connection that is Which flights travel maximum distance
-- To find out-
-- 1. Proper service management 

select
	Origin_airport,
    Destination_airport,
    Max(Distance) as Long_distance
from
	airport_db
group by
	Origin_airport,
    Destination_airport
order by
	Long_distance desc
limit 5;

-- Problem statement 11: Insights on seasonal trends
-- To find out-
-- 1. Most and least count of flights across multiple years to provide services accordingly

with Monthly_flights as
(select
	MONTH(Fly_date) as Month,
    count(Flights) as Total_flights
from
	airport_db
group by
	Month
    )
select
	Month,
    Total_flights,
    CASE
		WHEN Total_flights=(select Max(Total_flights) from Monthly_flights) then 'Most Busy'
        WHEN Total_flights=(select Min(Total_flights) from Monthly_flights) then 'Least Busy'
        ELSE NULL
	End as status
    from 
		Monthly_flights
	where
		Total_flights=(select Max(Total_flights) from Monthly_flights) OR
        Total_flights=(select Min(Total_flights) from Monthly_flights);
        
-- Problem statement 12: Identify Passenger's traffic trend over time
-- To find out
-- 1. Proper route development
-- 2. Capacity management
-- 3. Requirement adjusting based on demands

With Passengers_summary as
(select 
	Origin_airport,
    Destination_airport,
    YEAR(Fly_date) as Year,
    sum(Passengers) as Total_passengers
from
	airport_db
group by
	Origin_airport,
    Destination_airport,
    YEAR(Fly_date)
    ),
Passengers_growth as
(select 
	Origin_airport,
    Destination_airport,
    Year,
    Total_passengers,
    Lag(Total_passengers) over
    (partition by Origin_airport,Destination_airport order by Year) as Previous_year_passengers
from
	Passengers_summary)
select
	Origin_airport,
    Destination_airport,
    Year,
    Total_passengers,
    CASE 
		WHEN Previous_year_passengers is not null then
        ((Total_passengers-Previous_year_passengers)* 100.0/ NULLIF(Previous_year_passengers,0))
        END as Growth_percentage
 from
	Passengers_growth
order by 
	Origin_airport,
    Destination_airport,
    Year;
    
-- Problem Statement 13: Identify the trending route with consistent growth
-- To find out
-- 1. Where to provide proper services

With Flight_summary as 
(select
	Origin_airport,
    Destination_airport,
    YEAR(Fly_date) as Year,
    count(Flights) as Total_flights
from
	airport_db
group by
	Origin_airport,
    Destination_airport,
    YEAR(Fly_date)
    )
Flight_growth as    
(select
	Origin_airport,
    Destination_airport,
    Year,
	Total_flights,
    Lag(Total_flights) over (partition by Origin_airport,Destination_airport order by Year)
    as Previous_year_flights
from
	Flight_summary)
select
	Origin_airport,
    Destination_airport,
    Year,
	Total_flights,
    CASE 
		WHEN Previous_year_flights is not null AND Previous_year_flights>0 THEN
        ((Total_flights-Previous_year_flights)* 100.0/Previous_year_flights)
        ELSE null
	END as Growth_rate,
    CASE 
		WHEN Previous_year_flights is not null AND Total_flights>Previous_year_flights THEN
        1
        ELSE 0
	END as Growth_indicator
from
	Flight_growth;














-- Problem statement 14: Identify passenger to seat ratio based on total number of flights
-- To find out-
-- 1. Operational effiency 
-- 2. Flight volume

with Utilization_ratio as	
    (select
		Origin_airport,
		sum(Passengers) as Total_passengers,
		sum(Seats) as Total_seats,
		count(Flights) as Total_flights,
		sum(Passengers)*1.0/sum(Seats) as Passengers_seat_ratio
	from
		airport_db
	group by
		Origin_airport),
	Weighted_utilization as
	(select
		Origin_airport,
		Total_passengers,
		Total_seats,
		Total_flights,
		Passengers_seat_ratio,
		(Passengers_seat_ratio * Total_flights) / sum(Total_flights)
        over () as Weighted_utilization
	from
		Utilization_ratio)
	select
		Origin_airport,
		Total_passengers,
		Total_seats,
		Total_flights,
		Passengers_seat_ratio,
        Weighted_utilization
	from
		Weighted_utilization
	order by Weighted_utilization desc
    limit 3;
    
-- Problem statement 15: Identify Seasonal travel pattern based on specific city  (Not done)
-- To find out-
-- 1. Where the airline needs to put proper marketing strategy
-- 2. Peak traffic month from each city with highest number of passengers

with Monthly_passenger_count as	(select
		Origin_city,
		YEAR(Fly_date) as year,
		MONTH(Fly_date) as month,
		sum(Passengers) as Total_passengers
	from
		airport_db
	group by
		Origin_city,
		year,
		month)
	Max_passengers_per_city as	(select
			Origin_city,
			max(Total_passengers) as peak_passengers
		from
			Monthly_passenger_count
		group by
			Origin_city)
	
    select
		mpc.Origin_city,
        mpc.year,
        mpc.month,
        mpc.Total_passengers
	from
		Monthly_passenger_count as mpc
	join
		Max_passengers_per_city as mp on mpc.Origin_city=mp.Origin_city and
		mpc.Total_passengers=mp.Peak_passengers
	order by
		mpc.Origin_city,
        mpc.year,
        mpc.month;
        





-- Problem statement 16: Identify the routes whose demands are reduced (Not done)
-- To find out-
-- 1.Strategic management for those routes

with Yearly_passenger_count as
	(select 
		Origin_airport,
		Destination_airport,
		Year(Fly_date) as year,
		sum(Passengers) as Total_passengers
	from
		airport_db
	group by
		Origin_airport,
		Destination_airport,
		year),

	Yearly_decline as (select
			y1.Destination_airport,
            y1.Origin_airport,
            y1.year as Year1,
            y1.Total_passengers as Passengers_Year1,
            y2.year as Year2,
            y2.Total_passengers as Passengers_Year2,
            ((y2.Total_passengers-y1.Total_passengers) / nullif(y1.Total_passengers,0))*100 as percentage_change
        from
			Yearly_passenger_count as y1
		join
			Yearly_passenger_count as y2
		on y1.Origin_airport = y2.Origin_airport
        and y1.Destination_airport = y2.Destination_airport
        and y1.year = y2.year+1)
	select
		Destination_airport,
		Origin_airport,
		Year1,
		Passengers_Year1,
		Year2,
		Passengers_Year2,
		percentage_change
    from
		Yearly_decline
     where
		percentage_change<0
	order by
		percentage_change
	limit 5;
    
    
    
    
-- Problem statement 17: Identify the underforming routes
-- To find out
-- 1.Proper capacity management for the route
-- 2.Adjustment of services

	With Flight_stats as (select
		Origin_airport,
		Destination_airport,
		count(Flights) as Total_flights,
		sum(Passengers) as Total_passengers,
		sum(Seats) as Total_seats,
		(sum(Passengers)/nullif(sum(Seats),0)) as avg_seat_utilization
	from
		airport_db
	group by
		Origin_airport,
		Destination_airport)
	select
		Origin_airport,
		Destination_airport,
        Total_flights,
		Total_passengers,
		Total_seats,
        round((avg_seat_utilization * 100),2) as avg_seat_utilization_percentage
    from
		Flight_stats
	where 
		Total_flights>=10 and
        round((avg_seat_utilization * 100),2)<50
	order by
		avg_seat_utilization_percentage;

-- Problem Statement 18: Identify longeest average distance route
-- To find out-
-- 1.Proper insights for a long haul travel pattern

	With Distance_stat as (select
		Origin_city,
		Destination_city,
		avg(Distance) as avg_flight_distance
	from
		airport_db
	group by
		Origin_city,
		Destination_city)
	select
		Origin_city,
		Destination_city,
        round(avg_flight_distance,2) as avg_flight_distance
	from
		Distance_stat
	order by
		avg_flight_distance desc;


-- Problem statement 19: Overview the annual trend
-- To find out-
-- 1. Growth to take proper strategic decisions

	With Yearly_summary as	(select
		YEAR(Fly_date) as Year,
		count(Flights) as Total_flights,
		sum(Passengers) as Total_passengers
	from
		airport_db
	group by
		Year),
	Yearly_growth as (select
			Year,
			Total_flights,
			Total_passengers,
			lag(Total_flights) over (order by Year) as Previous_flights,
			lag(Total_passengers) over (order by Year) as Previous_passengers
		from
			Yearly_summary)
		select
			Total_flights,
            Total_passengers,
            round(((Total_flights-Previous_flights)/nullif(Previous_flights,0)*100),2) as Flights_growth_percentage,
            round(((Total_passengers-Previous_passengers)/nullif(Previous_passengers,0)*100),2) as Passengers_growth_percentage
		from
			Yearly_growth 
		order by
			Year;
            
            
	-- Problem statement 20: Identify the most significant route
    -- To find out-
    -- 1. Proper resource allocation
    -- 2. Optimize the scheduling
    
		with Route_distance as (select
			Origin_airport,
			Destination_airport,
			sum(Flights) as Total_flights,
			sum(Distance) as Total_distance
		from
			airport_db
		group by
			Origin_airport,
			Destination_airport),
		 Weighted_route as  (select
				Origin_airport,
				Destination_airport,
				Total_flights,
				Total_distance,
				Total_distance * Total_flights as Weighted_distance
			from
				Route_distance)
		select
			Origin_airport,
			Destination_airport,
			Total_flights,
			Total_distance,
			Weighted_distance
		from
			Weighted_route
		order by
			Weighted_distance desc;
				
    
            
	







