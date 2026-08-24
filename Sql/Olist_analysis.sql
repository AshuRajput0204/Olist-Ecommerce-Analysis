create database olist;
use olist;
-- 1. Total Number of Orders and Total Revenue genrerated by each customer state.
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS Total_Orders,
    SUM(oi.price) AS Total_Revenue
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY Total_Revenue DESC;

-- 2.Category-wise Revenue and Order Count.
SELECT 
    p.product_category_name,
    sum(oi.price) AS Revenue,
    COUNT(distinct oi.order_id) AS Order_Count
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY Revenue DESC;

-- 3.Seller-wise Total revenue and order count.
SELECT 
    seller_id,
    SUM(price) AS Revenue,
    COUNT(DISTINCT order_id) AS Order_Count
FROM
    order_items
GROUP BY seller_id
ORDER BY Revenue DESC;

-- 4.States Having Revenue Greater than R$500,000.
SELECT 
    c.customer_state,
    SUM(oi.price) AS Revenue,
    COUNT(DISTINCT o.order_id) AS Order_count
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_state
HAVING Revenue > 500000 
order by Revenue desc;

-- 5. Order Status-wise Average Order Value.

SELECT 
    o.order_status,
    SUM(oi.price) AS Revenue,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS AOV
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status;

-- 6.Customers With More Than One Order.
SELECT 
    c.customer_unique_id, COUNT(DISTINCT o.order_id)
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY COUNT(DISTINCT o.order_id) DESC ;

-- 7.Customer-wise Total Spending.
SELECT 
    c.customer_unique_id, SUM(oi.price) AS Total_Spending
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY Total_spending DESC
LIMIT 10;

-- 8.Category-Wise average Review Score.

SELECT 
    p.product_category_name,
    AVG(r.review_score) AS Average_review_score
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    reviews r ON o.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY Average_review_score DESC;

-- 9.Sellers With Revenue Above Average Seller Revenue.
SELECT 
    seller_id, SUM(price) AS Revenue
FROM
    order_items
GROUP BY seller_id
HAVING SUM(price) > (SELECT 
        AVG(seller_revenue)
    FROM
        (SELECT 
            seller_id, SUM(price) AS seller_revenue
        FROM
            order_items
        GROUP BY seller_id) AS t);

-- 10.Top 3 Sellers By Revenue.
SELECT 
    seller_id, SUM(price) AS Revenue
FROM
    order_items
GROUP BY seller_id
ORDER BY Revenue DESC
LIMIT 3;

-- 11.Seller Revenue Ranking.
select 
	seller_id,
    Revenue,
    rank() over(order by Revenue desc) 
from (
	select seller_id,
		sum(price) as Revenue 
	from
        order_items
	group by 
			seller_id
		)
			as t ;

-- 12.Category Revenue Ranking.
select
 product_category_name,
 Revenue,rank() over(
			order by Revenue
 ) as Category_Rank
	from 
		(select
			p.product_category_name,
			sum(oi.price) as Revenue 
 from order_items oi
 join products p 
		on oi.product_id=
 p.product_id 
	group by
 p.product_category_name)
	as t ;
    
-- 13.Top 3 Categories
select
	product_category_name,
	Revenue,
    Category_Rank
from (
	select
		product_category_name,
        Revenue,
        rank() over(order by
Revenue desc) as Category_Rank 
	from (
		select p.product_category_name,
						sum(oi.price) as 
			Revenue 
			from order_items oi
            join products p
            on  oi.product_id=
            p.product_id
				group by 
			p.product_category_name
            ) as t1)
				as t2 
            where Category_Rank <=3;

-- 14.State-Wise Selller Count.

SELECT 
    c.customer_state,
    COUNT(DISTINCT oi.seller_id) AS Seller_Count
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY Seller_Count DESC ;

-- 15.State-Wise Average Review Score.
SELECT 
    c.customer_state,
    AVG(r.review_score) AS Average_Review_Score
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    reviews r ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY Average_Review_Score DESC;

-- 16.Payment Method-Wise Revenue.
SELECT 
    payment_type, SUM(payment_value) AS Revenue
FROM
    payments
GROUP BY payment_type
ORDER BY Revenue DESC;

-- 17.Payment Method Wise Average Installments.
SELECT 
    payment_type, AVG(payment_installments) AS Avg_Installments
FROM
    payments
GROUP BY payment_type
ORDER BY Avg_Installments DESC;

-- 18.Orders With Multiple items.
SELECT 
    order_id, COUNT(order_item_id) AS Items
FROM
    order_items
GROUP BY order_id
HAVING Items > 1
ORDER BY items DESC;

-- 19.Orders With Multiple Seller.
SELECT 
    order_id, COUNT(DISTINCT seller_id) AS seller
FROM
    order_items
GROUP BY order_id
HAVING seller > 1
ORDER BY seller DESC;

-- 20.Monthly Revenue.
SELECT 
    YEAR(o.order_purchase_timestamp) AS Year,
    MONTH(o.order_purchase_timestamp) AS Month,
    SUM(oi.price) AS Revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp)
ORDER BY Year , Month;

-- 21.Monthly Orders and Revenue.
SELECT 
    YEAR(o.order_purchase_timestamp) AS Year,
    MONTH(o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS Order_Count,
    SUM(oi.price) AS Revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp)
ORDER BY Year , Month;

-- 22.Year-Wise Revenue.
SELECT 
    YEAR(o.order_purchase_timestamp) AS Year,
    SUM(oi.price) AS Revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY Year;

-- 23.Year-Wise Order Status Distribution.
SELECT 
    YEAR(o.order_purchase_timestamp) AS year,
    o.order_status AS order_status,
    COUNT(DISTINCT o.order_id) AS order_count
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp) , o.order_status
ORDER BY Year;

-- 24.Average Delivery Days by Order Status.
SELECT 
    order_status,
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) AS Average_delivery_days
FROM
    orders
where order_delivered_customer_date is not null
GROUP BY order_status
ORDER BY Average_delivery_days DESC;

-- 25.Late vs On-time Orders.
SELECT 
    *,
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'On-Time'
    END AS Order_time
FROM
    orders;
    
-- 26.Late Delivery Percentage by State.
SELECT 
    c.customer_state,
    COUNT(CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
    END) AS Late_Orders,
    COUNT(o.order_id) AS Total_Orders,
    COUNT(CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
    END) * 100 / COUNT(o.order_id) AS Late_Delivery_Percentage
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
where o.order_delivered_customer_date is not null
and
o.order_estimated_delivery_date is not null
GROUP BY c.customer_state
ORDER BY Late_Delivery_Percentage DESC;

-- 27.Average Review Score for Order Status.
SELECT 
    o.order_status, AVG(r.review_score) AS Average_review_Score
FROM
    orders o
        JOIN
    reviews r ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY Average_review_Score DESC;