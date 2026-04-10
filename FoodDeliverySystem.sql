-- Zomato Advanced SQL Script

-- Q1. Find the Top 10 Restaurants by Total Orders
SELECT TOP 10 
    r.name AS Restaurant,r.city, r.cuisine,
    COUNT(o.order_id) AS TotalOrders
FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.name,r.city, r.cuisine
ORDER BY TotalOrders DESC;

--Q2. Find Total Revenue per City
SELECT        Restaurants.city, SUM(Orders.amount - Orders.discount) AS TotalRevenue
FROM            Restaurants INNER JOIN
                         Orders ON Restaurants.restaurant_id = Orders.restaurant_id
WHERE        (Orders.delivery_status = N'Delivered')
GROUP BY Restaurants.city
ORDER BY TotalRevenue DESC

--Q3. Find Top 5 Customers by Total Spend
SELECT        Customers.customer_id, Customers.name, Customers.city, Customers.phone, SUM(Orders.amount - Orders.discount) AS TotalSpent
FROM            Customers INNER JOIN
                         Orders ON Customers.customer_id = Orders.customer_id
GROUP BY Customers.customer_id, Customers.name, Customers.city, Customers.phone
ORDER BY TotalSpent DESC

--Q4. Top 3 Restaurants per City by Revenue
WITH RankedRestaurants AS (
    SELECT 
        r.city,
        r.name AS Restaurant,
        SUM(o.amount - o.discount) AS Revenue,
        RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.amount - o.discount) DESC) AS rnk
    FROM Orders o
    JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY r.city, r.name
)
SELECT city, Restaurant, Revenue
FROM RankedRestaurants
WHERE rnk <= 3;

--Q5. Top 5 Delivery Partners by Number of Deliveries
SELECT TOP 5 
    d.[name] AS DriverName,
    COUNT(o.order_id) AS NoOfDeliveries
FROM Orders o
JOIN Delivery_Partners d ON o.driver_id = d.driver_id
WHERE o.delivery_status = 'Delivered'
GROUP BY d.[name]
ORDER BY NoOfDeliveries DESC;

--Q6. Find Running Total of Revenue Over Time
select FORMAT(order_date,'yyMM') as YearMonth
,SUM(amount-discount) as MonthlyRevenue
,SUM(SUM(amount-discount)) over(order by FORMAT(order_date,'yyMM') ) as RunningTotal
from Orders
WHERE delivery_status = 'Delivered'
group by FORMAT(order_date,'yyMM')
order by YearMonth

with CTERunningTotal as(
SELECT 
    FORMAT(order_date, 'yyMM') AS YearMonth,
    SUM(amount - discount) AS MonthlyRevenue     
FROM Orders
WHERE delivery_status = 'Delivered'
GROUP BY FORMAT(order_date, 'yyMM')

)
select *
, sum(cast(MonthlyRevenue as BIGINT))  over(order by cast(YearMonth as VARCHAR)) as RunningTotal
from CTERunningTotal
order by YearMonth

--Q7.Top 10 Rank Restaurants by Average Rating
SELECT 
    r.name AS Restaurant,
    AVG(rv.rating*1.0) AS AvgRating,
    RANK() OVER (ORDER BY AVG(rv.rating*1.0) DESC) AS RatingRank
FROM Reviews rv
JOIN Restaurants r ON rv.restaurant_id = r.restaurant_id
GROUP BY r.name;

--Q8. Find Customers Who Ordered Every Cuisine

WITH customer as (
SELECT DISTINCT   dbo.Customers.customer_id, dbo.Customers.name, dbo.Restaurants.cuisine
FROM            dbo.Customers INNER JOIN
                         dbo.Orders ON dbo.Customers.customer_id = dbo.Orders.customer_id INNER JOIN
                         dbo.Restaurants ON dbo.Orders.restaurant_id = dbo.Restaurants.restaurant_id
),
customerCusionCount as(
select customer_id,name,COUNT(cuisine) as NoOfCuisine
from customer
group by customer_id,name
)
select customer_id,name  from customerCusionCount where NoOfCuisine >= ( SELECT COUNT(*) from (SELECT DISTINCT r.cuisine
    FROM Orders o
    JOIN Restaurants r ON o.restaurant_id = r.restaurant_id) x)
order by customer_id

--Q9. Find Restaurants with Best Delivery Efficiency (Avg Time < 60 min)

SELECT r.name, AVG(o.delivery_time) AS AvgDeliveryTime
FROM Restaurants r
JOIN Orders o ON r.restaurant_id = r.restaurant_id
WHERE o.delivery_status = 'Delivered'
GROUP BY r.name
HAVING AVG(o.delivery_time) < 60;

--10 . Find Top 3 Items Contributing to Revenue per Restaurant

WITH ItemRevenue AS (
    SELECT 
        r.name AS Restaurant,
        m.item_name,
        SUM(oi.quantity * oi.item_price) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY r.restaurant_id ORDER BY SUM(oi.quantity * oi.item_price) DESC) AS rn
    FROM Order_Items oi
    JOIN Menu m ON oi.menu_id = m.menu_id
    JOIN Restaurants r ON m.restaurant_id = r.restaurant_id
    GROUP BY r.name, r.restaurant_id, m.item_name
)
SELECT Restaurant, item_name, Revenue
FROM ItemRevenue
WHERE rn <= 3;

--11 .Find the Percentage of Veg vs Non-Veg Items Ordered

SELECT 
     m.veg_nonveg   AS Category,
	 COUNT(veg_nonveg),
    COUNT(veg_nonveg) * 100.0 / (SELECT COUNT(*) FROM Order_Items) AS Percentage
FROM Order_Items oi
JOIN Menu m ON oi.menu_id = m.menu_id
GROUP BY m.veg_nonveg;

--12 .Find Customers Who Never Used Promo Codes

SELECT c.name
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o WHERE o.customer_id = c.customer_id AND o.promo_code IS NOT NULL
);

select C.name from Customers c where c.customer_id in (
SELECT       dbo.Orders.customer_id
FROM            dbo.Orders INNER JOIN
                         dbo.Customers ON dbo.Orders.customer_id = dbo.Customers.customer_id
GROUP BY dbo.Orders.customer_id

HAVING        COUNT(dbo.Orders.promo_code) <1

)


--13 .Find Peak Ordering Hour

SELECT DATEPART(HOUR, order_date) AS OrderHour, COUNT(*) AS TotalOrders
FROM Orders
GROUP BY DATEPART(HOUR, order_date)
ORDER BY TotalOrders DESC;

--14 .Find Restaurants with Most Loyal Customers (Repeat Orders)

SELECT r.name, c.name AS Customer, COUNT(o.order_id) AS OrdersCount
FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY r.name, c.name
HAVING COUNT(o.order_id) >= 5
ORDER BY OrdersCount DESC;

--15 .Find Average Rating per Driver (Based on Orders Delivered)

SELECT d.name, ROUND(AVG(rv.rating * 1.0),2) AS AvgRating
FROM Delivery_Partners d
JOIN Orders o ON d.driver_id = o.driver_id
JOIN Reviews rv ON o.order_id = rv.order_id
WHERE o.delivery_status = 'Delivered'
GROUP BY d.name
order by AvgRating desc

--16 .Top 5 High Value Orders (After Discount)

SELECT TOP 5 order_id, customer_id, restaurant_id, (amount - discount) AS NetAmount
FROM Orders
ORDER BY NetAmount DESC;

--17 .Best-Selling Item per Restaurant

WITH ItemPopularity AS (
    SELECT 
        r.name AS Restaurant,
        m.item_name,
        COUNT(oi.order_item_id) AS TimesOrdered,
        ROW_NUMBER() OVER (PARTITION BY r.restaurant_id ORDER BY COUNT(oi.order_item_id) DESC) AS rn
    FROM Order_Items oi
    JOIN Menu m ON oi.menu_id = m.menu_id
    JOIN Restaurants r ON m.restaurant_id = r.restaurant_id
    GROUP BY r.name, r.restaurant_id, m.item_name
)
SELECT Restaurant, item_name, TimesOrdered
FROM ItemPopularity
WHERE rn = 1;

--18 .Restaurants with More Negatives than Positives

SELECT 
    r.name,
    SUM(CASE WHEN rv.sentiment = 'Positive' THEN 1 ELSE 0 END) AS Positives,
    SUM(CASE WHEN rv.sentiment = 'Negative' THEN 1 ELSE 0 END) AS Negatives
	--,ROW_NUMBER() over(order by SUM(CASE WHEN rv.sentiment = 'Positive' THEN 1 ELSE 0 END) asc)
FROM Restaurants r
JOIN Reviews rv ON r.restaurant_id = rv.restaurant_id
GROUP BY r.name
HAVING SUM(CASE WHEN rv.sentiment = 'Negative' THEN 1 ELSE 0 END) >
       SUM(CASE WHEN rv.sentiment = 'Positive' THEN 1 ELSE 0 END);
























