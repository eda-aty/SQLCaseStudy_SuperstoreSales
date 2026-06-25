SELECT * FROM Customer
SELECT * FROM Products
SELECT * FROM Shipping
SELECT * FROM Sales
SELECT * FROM TargetSales

--Q1. List the top 10 customers by total sales amount. Show CustomerID, full name, and total sales.

SELECT TOP 10 c.ID, c.FirstName + ' ' + c.LastName AS CustomerName,
		SUM(s.Price) AS TotalSales
FROM Customer c 
JOIN Sales s
ON c.ID = s.CustomerID
GROUP BY c.ID, c.FirstName, c.LastName
ORDER BY TotalSales DESC

---Q2. Show total sales per month for the year 2023, ordered by month.


select 
extract(year from orderdate)as year,
extract(month from orderdate)as month,
sum(s.price) as total_sales
from sales s
where extract(year from orderdate) ='2023'
group by 1,2
order by 2

--Q3. Find out the products that have never been sold
select *from sales
select*from products

select p.productid,
p.productname
from products p
LEFT JOIN sales s ON p.productid=s.productid
WHERE s.productid is null

--Q4. Find how many new customers were acquired in 2022
select * from sales


select 
count(*) as new_customers_2022
from(
  select 
 customerid as customers,
 MIN(orderdate) AS first_order_date
 from sales
 group by customerid) t
 WHERE EXTRACT(YEAR FROM first_order_date) = 2022;

--Q4 second way WITH CTE FUNCTİONS:
WITH first_orders AS (
    SELECT
        customerid,
        MIN(orderdate) AS first_order_date
    FROM sales
    GROUP BY customerid
)

select 
count(*) as new_customers_2022
from first_orders 
WHERE EXTRACT(YEAR FROM first_order_date) = 2022;

--Q5. Calculate the profit margin (Profit / Sales) percentage for each category.

select * from sales

select 
p.category,
 SUM(s.profit)/ sum(s.price) *100 as profit_margin
 from products p
 LEFT JOIN sales s ON s.productid =p.productid
group by p.category
ORDER BY 2 DESC

--Q6. For each category, show date-wise sales and a running total of sales over time.


WITH daily_sales AS (
    SELECT
        orderdate,
        category,
        SUM(sales) AS daily_sales
    FROM sales
    GROUP BY orderdate, category
)

SELECT
    orderdate,
    category,
    daily_sales,
SUM(daily_sales) OVER(PARTITION BY category ORDER BY orderdate) AS running_total_sales

FROM daily_sales
ORDER BY category, orderdate;

--Q7. Get the most recent order (by OrderDate) for every customer.
---"Her müşteri için en son siparişi getir."

WITH cte_most_recent as(
    select DISTINCT s.customerid,
    s.orderid,
    s.orderdate ,
   RANK() OVER (PARTITION BY s.customerid ORDER BY orderdate desc) as rank
from sales s
)
select orderid,
customerid,
orderdate
from cte_most_recent
WHERE rank=1

----Q7 alternative:
WITH cte_most_recent  AS (
    SELECT *,
    ROW_NUMBER()OVER(PARTITION BY customerid ORDER BY orderdate DESC) rn
    FROM sales
)
SELECT *
FROM cte_most_recent 
WHERE rn = 1;

---  How script become if Q7 questions was "latest date per customer"? 

select
customerid,
orderid,
max(orderdate) as recent_date
from sales
GROUP BY 1,2
ORDER BY 1;

----Q8 Classify customers based on their total sale, show customerid,name,totalsales

--platinium total sales>=15.000
--gold-10.000to<15.000
--silver--5000 to>10.000
--bronze <5.000

select*from customer
select*from sales

with cte_customer_sales as(
select 
c.id,
c.firstname as customer_name,
c.lastname,
sum(s.price) as total_sales
 from sales s 
 LEFT JOIN customer c ON s.customerid =c.id
 group by 1,2,3
)
select id,customer_name,total_sales,
CASE 
   WHEN total_sales >=15000 THEN 'platinum' 
   WHEN total_sales >= 10000 THEN 'gold'
   WHEN total_sales >= 5000 THEN 'silver'
   ELSE 'bronze' 
   end as sales_category
from cte_customer_sales 
ORDER BY total_sales

--Q9 For each category find the product with the highest totalsales

with cte_product_sales as (
select 
p.productname as product,
p.category,
sum(s.price) as total_sales,
rank () over (partition by category order by sum(s.price)desc) as rank
from sales s
LEFT JOIN products p on p.productid=s.productid
group by 1,2 
)

select category, product, total_sales from cte_product_sales
WHERE rank=1

-- Q10 