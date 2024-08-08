-- Assume you're given a table containing information on Facebook user actions. Write a query to obtain number of monthly active users (MAUs) in July 2022, including the month in numerical format "1, 2, 3".

-- Hint:

-- An active user is defined as a user who has performed actions such as 'sign-in', 'like', or 'comment' in both the current month and the previous month.
with cte as(
SELECT user_id,extract(month from event_date) as month FROM user_actions
where event_type in ('sign-in','like','comment')
and extract(month from event_date) in (6,7)),
cte_2 as(
select user_id,count(distinct month) as month_count
from cte
group by user_id)
select '7' as month, count(user_id)
from cte_2 
where month_count=2
