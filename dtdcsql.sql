 ## Total number of shipments.
select count(*) from dt;

  ## Top 5 delivery destination cities.
select Destination, count(*) from dt
group by destination
order by count(*) desc limit 5

  ## Shipment count,% by delivery mode.
select Mode, count(*),
count(*)*100/(select count(*) from dt) as percentagee
 from dt
group by mode

  
 ##  Number of consignments where Value-Added Services (VAS)= 'COD'.
SELECT `Value Added Services`, COUNT(*) AS total_with_vas
FROM dt
WHERE `Value Added Services` = 'COD'


 ##  Dox vs Non-Dox shipment percentage.
 
 SELECT `Nature of Consignment`,
 count(*) total_no,
 round(count(*)* 100/(select count(*) from dt),2)
 from dt
 group by `Nature of Consignment`
 
 ## PART 2
 ALTER TABLE dt 
 ADD COLUMN send DATE;
  ALTER TABLE dt 
 ADD COLUMN receive DATE;
 
## Update date in both columns
update dt
SET send = STR_TO_DATE(`Sender Date`, '%d-%m-%Y');
update dt
set receive = str_to_date(`Receive Date`,'%d-%m-%Y');
 SET SQL_SAFE_UPDATES = 0

## Drop old columns
ALTER table dt
drop column `Sender Date`

ALTER table dt
drop column `Receive Date`
 

 
  ## Average delivery time by mode.
 SELECT mode,
 round(avg(datediff(receive, send)),1) difu
 from dt
 group by 1
 
  ## Top 3 booking codes by total revenue.
   SELECT `Booking Code`, round(sum(`Total Amount`),2) total
   FROM dt
   group by 1
   order by total desc limit 3
  
 ##  Most common sender cities by revenue.
 select `Sender City`, sum(`Total Amount`) rev, count(*) freq
 from dt
 group by 1
 order by 3 desc
 
  ## Average chargeable weight by sender state.
  SELECT `Sender State`,
 round(avg(`Chargeable Wt`),2) avg_weight
  from dt
  group by 1
  order by 2 desc
  
 ##  Total tariff collected per sender state.
   SELECT `Sender State`,
  round(sum(Tariff),2) total_tariff
  from dt
  group by 1 
  
## Convert Expiry Date column type from text to date
ALTER TABLE dt
ADD column exp_date date

update dt
SET exp_date = STR_TO_DATE(`Expiry Date`, '%d-%m-%Y');


##  Identify late deliveries (delivered after expiry).
select `Pouch No`, `Sender State`, `Recipient City`, receive, exp_date
from  dt
where receive > exp_date

## Early Delivery data (Count no of days)
SELECT 
  `Sender State`,
  receive, 
  exp_date,
  DATEDIFF(receive, exp_date) AS days_early
FROM dt
WHERE receive < exp_date;

##  Top sender cities by revenue in the last 60 days.
SELECT 
  `Sender City`, round(SUM(Tariff),2) AS total_revenue
FROM dt
WHERE send >= CURDATE() - INTERVAL 50 DAY
GROUP BY `Sender City`
ORDER BY total_revenue DESC
LIMIT 3;


##  Average delivery time across all modes.
select mode,
round(avg(receive-send),2) ang_delivery_time
 from dt
 group by 1


##  Count of shipments per mode in the last 30 days.
select mode, count(*) from dt
where send >= CURDATE() - INTERVAL 30 DAY
group by 1

##  % of shipments with missing receiver signatures.
select
round(sum(case when `Receiver Signature` is null or `Receiver Signature` ='' then 1 else 0
end)/ count(*)*100,0) percent_value
from dt

# another method using subquery
select 
(select 
count(*) missing from dt
where `Receiver Signature`='')/count(*)*100 from dt

# another cte method 
with cte as(
select count(*) missing from dt 
where `Receiver Signature`=''),
cte2 as(
select count(*) totall from dt)
select cte.missing/cte2.totall*100 from
cte,cte2;

##  VAS usage analysis by shipment mode.
SELECT mode,
  COUNT(*) AS total_shipments,
  SUM(CASE WHEN `Value Added Services` <> 'None' THEN 1 ELSE 0 END) AS vas_used,
  SUM(CASE WHEN `Value Added Services` <> 'None' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS vas_usage_percentage
FROM dt
GROUP BY mode

select mode,
count(*),
sum(case when `Value Added Services` <> 'None' then 1 else 0 end) vas_used,
sum(case when `Value Added Services` <> 'None' then 1 else 0 end)/ count(*)*100 percent_used_of_vas
from dt
group by mode