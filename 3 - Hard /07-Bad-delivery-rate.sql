-- The Growth Team at DoorDash wants to ensure that new users, who make orders within their first 14 days on the platform, have a positive experience. 

-- However, they have noticed several issues with deliveries that result in a bad experience.

-- These issues include:

-- Orders being completed incorrectly, with missing items or wrong orders.
-- Orders not being received due to incorrect addresses or drop-off spots.
-- Orders being delivered late, with the actual delivery time being 30 minutes later than the order placement time. 

-- Note that the estimated_delivery_timestamp is automatically set to 30 minutes after the order_timestamp.

-- Write a query that calculates the bad experience rate for new users who signed up in June 2022 during their first 14 days on the platform. 

-- The output should include the percentage of bad experiences, rounded to 2 decimal places.


-- orders Table:

-- Column Name	Type
-- order_id	integer
-- customer_id	integer
-- trip_id	integer
-- status	string ('completed successfully', 'completed incorrectly', 'never received')
-- order_timestamp	timestamp

-- orders Example Input:

-- order_id	customer_id	trip_id	status	order_timestamp
-- 727424	8472	100463	completed successfully	06/05/2022 09:12:00
-- 242513	2341	100482	completed incorrectly	06/05/2022 14:40:00
-- 141367	1314	100362	completed incorrectly	06/07/2022 15:03:00
-- 582193	5421	100657	never_received	07/07/2022 15:22:00
-- 253613	1314	100213	completed successfully	06/12/2022 13:43:00

-- trips Table:

-- Column Name	Type
-- dasher_id	integer
-- trip_id	integer
-- estimated_delivery_timestamp	timestamp
-- actual_delivery_timestamp	timestamp

-- trips Example Input:
- dasher_id	trip_id	estimated_delivery_timestamp	actual_delivery_timestamp
-- 101	100463	06/05/2022 09:42:00	06/05/2022 09:38:00
-- 102	100482	06/05/2022 15:10:00	06/05/2022 15:46:00
-- 101	100362	06/07/2022 15:33:00	06/07/2022 16:45:00
-- 102	100657	07/07/2022 15:52:00	-
-- 103	100213	06/12/2022 14:13:00	06/12/2022 14:10:00

-- customers Table:

-- Column Name	Type
-- customer_id	integer
-- signup_timestamp	timestamp

-- customers Example Input:

-- customer_id	signup_timestamp
-- 8472	05/30/2022 00:00:00
-- 2341	06/01/2022 00:00:00
-- 1314	06/03/2022 00:00:00
-- 1435	06/05/2022 00:00:00
-- 5421	06/07/2022 00:00:00

-- Example Output:

-- bad_experience_pct
-- 75.00

-- Explanation:

-- Order 727424 is excluded from the analysis as it was placed after the first 14 days upon signing up.

-- Out of the remaining orders, there are a total of 4 orders. 
-- However, only 3 of these orders resulted in a bad experience, as one order with ID 253613 was completed successfully. 
-- Therefore, the bad experience rate is 75% (3 out of 4 orders).

drop table if exists orders;
create table orders( order_id	integer,
customer_id	integer,
trip_id	integer
,status	text,
order_timestamp	timestamp );
Insert into orders values( 72742,8472,100463,'completed successfully','2022-06-05 09:12:00'),
(242513,2341,100482,'completed incorrectly','2022-06-05 14:40:00'),
(141367,1314,100362,'completed incorrectly','2022-06-07 15:03:00'),
(582193,5421,100657,'never_received','2022-07-07 15:22:00'),
(253613,	1314,100213,'completed successfully','2022-06-12 13:43:00');
drop table if exists customer;
create table customer(
customer_id	integer,
signup_timestamp timestamp);
set sql_safe_updates=0;
update customer
set signup_timestamp='2022-06-03 00:00:00' where customer_id=1314;
Insert into customer values( 8472,'2022-05-30 00:00:00'),
(2341,'2022-06-01 00:00:00'),
(1314,'2022-06-30 00:00:00'),
(1435,'2022-06-05 00:00:00'),
(5421,'2022-06-07 00:00:00');
drop table if exists trips;
create table trips( dasher_id	integer,
trip_id	integer,
estimated_delivery_timestamp timestamp,
actual_delivery_timestamp timestamp);
Insert into trips values(101,100463,'2022-06-05 09:42:00','2022-06-05 09:38:00'),
(102,100482,'2022-06-05 15:10:00','2022-06-05 15:46:00'),
(101,100362,'2022-06-07 15:33:00','2022-06-07 16:45:00'),
(102,100657,'2022-07-07 15:52:00',null),
(103,100213,'2022-06-12 14:13:00','2022-06-12 14:10:00');
select * from customer;
select * from orders;
select * from trips;
with cte as(
select c.*,o.status,o.order_timestamp,estimated_delivery_timestamp,actual_delivery_timestamp 
from orders o 
join customer c
on c.customer_id=o.customer_id
join trips t
on o.trip_id=t.trip_id
where month(signup_timestamp)=6 and (order_timestamp <= signup_timestamp + INTERVAL 14 day or actual_delivery_timestamp is null))
select sum(case when status !='completed successfully' or actual_delivery_timestamp > estimated_delivery_timestamp 
                                       or actual_delivery_timestamp is null  then 1 else 0 end )*100/count(*) as pct
from cte;

-- or select 100-sum(case when status ='completed successfully'  and actual_delivery_timestamp < estimated_delivery_timestamp then 1 else 0 end )*100/count(*) 
-- as pct
from cte;
