-- 1st solution that came to my mind I was just using the last line but hour and date sould also be same because if one date is 13:37:00 and another 12:08:00 
-- then diff in minutes is also 10 minutes but it shouldn't count because hour is different so I included the two lines above to match hour & date.

with cte as(
select merchant_id,credit_card_id,amount,transaction_timestamp,
lead(transaction_timestamp,1) 
over(partition by credit_card_id,merchant_id,amount order by transaction_timestamp) as nxt
from transactions)
select count(*) from cte 
where date(transaction_timestamp) = date(nxt) and
extract(hour from transaction_timestamp)=extract(hour from nxt) and
extract(minute from (nxt-transaction_timestamp)) <= 10;

-- Optimize it using just transaction_timestamp-nxt_time <= INTERVAL '10 MINUTES'

With cte as(SELECT *,lag(transaction_timestamp,1) 
over(partition by merchant_id,credit_card_id,amount order by transaction_timestamp)
as nxt_time
FROM transactions)
SELECT count(merchant_id) as payment_count
FROM cte
where transaction_timestamp-nxt_time <= INTERVAL '10 MINUTES'

-- 3rd soln using self join 
SELECT 
  COUNT(*) AS payment_count
FROM transactions AS t1
JOIN transactions AS t2
ON t1.merchant_id = t2.merchant_id
  AND t1.credit_card_id = t2.credit_card_id
  AND t1.amount = t2.amount
  AND t1.transaction_timestamp < t2.transaction_timestamp
  AND t2.transaction_timestamp - t1.transaction_timestamp <= INTERVAL '10 MINUTES';
