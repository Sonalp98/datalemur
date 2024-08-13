-- Monthly Merchant Balance [Visa SQL Interview Question]

-- Say you have access to all the transactions for a given merchant account. 

-- Write a query to print the cumulative balance of the merchant account at the end of each day, with the total balance reset back to zero at the end of the month.
Output the transaction date and cumulative balance.

-- transactions Table:

-- Column Name	Type
-- transaction_id	integer
-- type	string ('deposit', 'withdrawal')
-- amount	decimal
-- transaction_date	timestamp


-- transactions Example Input:

-- transaction_id	type	amount	transaction_date
-- 19153	deposit	65.90	07/10/2022 10:00:00
-- 53151	deposit	178.55	07/08/2022 10:00:00
-- 29776	withdrawal	25.90	07/08/2022 10:00:00
-- 16461	withdrawal	45.99	07/08/2022 10:00:00
-- 77134	deposit	32.60	07/10/2022 10:00:00


-- Example Output:

-- transaction_date	balance
-- 07/08/2022 12:00:00	106.66
-- 07/10/2022 12:00:00	98.50

drop table if exists transactions;
create table transactions( transaction_id	integer,
type text
,amount	decimal(4,2)
,transaction_date	timestamp);
Alter table transactions
modify column amount decimal(10,2);
Insert into transactions values( 19153,	'deposit',65.90,'2022-10-07 10:00:00'),
(53151,	'deposit',178.55,'2022-08-07 10:00:00'),
(29776,'withdrawal',25.90,'2022-08-07 10:00:00'),
(16461,'withdrawal',45.99,'2022-08-07 10:00:00'),
(77134,'deposit',32.60,'2022-10-07 10:00:00');
select * from transactions;
-- 1st

select year(transaction_date) as year,month(transaction_date) as month, sum(case when type='deposit' then amount else 0 end )-
sum(case when type='withdrawal' then amount else 0 end ) as e_a
from transactions
group by year(transaction_date),month(transaction_date);

-- 2nd
with cte as(
select distinct transaction_date,type,sum(amount) over(partition by month(transaction_date),type order by transaction_date) as amt
from transactions)
select distinct transaction_date,sum(case when type='deposit' then amt else -amt end) 
over(partition by month(transaction_date) order by transaction_date) as balance
from cte;

-- 3rd: We need to group by month(transaction_date) and year(transaction_date) as per question

select distinct transaction_date,sum(case when type='deposit' then amount else -amount end) as balance
from transactions
group by transaction_date
order by transaction_date;

-- 4th best ans
select distinct transaction_date,sum(case when type='deposit' then amount else -amount end) 
over(partition by month(transaction_date) order by day(transaction_date)) as balance
from transactions;

-- If you want running sum just use over( order by column)

select distinct transaction_date,sum(case when type='deposit' then amount else -amount end) 
over(order by transaction_date) as balance
from transactions;
