-- . Total revenue and order volume by year and month.
SELECT 
DATE_FORMAT(odr.order_purchase_timestamp, '%Y-%m') AS month,
ROUND(SUM(py.payment_value),2) AS Revenue,
COUNT(DISTINCT odr.order_id) AS order_volume
FROM olist_orders odr
JOIN olist_order_payments py
ON odr.order_id=py.order_id
Where odr.order_status= "delivered"
GROUP BY DATE_FORMAT(odr.order_purchase_timestamp, '%Y-%m')
ORDER BY month ASC;




-- .Product categories generate the most revenue.
SELECT 
trans.product_category_name_english AS product_category,
ROUND(SUM(itm.price),2) AS product_revenue
FROM olist_order_items itm
JOIN olist_products pdr
ON itm.product_id=pdr.product_id
JOIN olist_category_translation trans
ON pdr.product_category_name=trans.product_category_name
JOIN olist_orders ord
ON itm.order_id=ord.order_id
WHERE ord.order_status="delivered"
GROUP BY trans.product_category_name_english
ORDER BY product_revenue DESC;



-- . Top sellers by revenue.

SELECT 
ROW_NUMBER() OVER(ORDER BY SUM(op.order_payment_total) DESC) AS seller_rank,
se.seller_id,
se.seller_city,
se.seller_state,
ROUND(SUM(op.order_payment_total),2) AS seller_revenue,
ROUND(SUM(op.order_payment_total)/SUM(SUM(op.order_payment_total)) OVER()*100,2) AS Revenue_pct,
COUNT(DISTINCT itm.order_id) AS total_orders
FROM olist_sellers se
JOIN olist_order_items itm ON se.seller_id=itm.seller_id
JOIN (
    SELECT order_id, SUM(payment_value) AS order_payment_total
    FROM olist_order_payments
    GROUP BY order_id
) AS op ON itm.order_id = op.order_id
GROUP BY se.seller_id, se.seller_city, se.seller_state
ORDER BY seller_revenue DESC
LIMIT 10;


-- .Average delivery time and how it varies by state.
SELECT cus.customer_state,
ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0) AS avg_delivery_days
FROM olist_customers cus
JOIN olist_orders ord
ON cus.customer_id=ord.customer_id
WHERE ord.order_status = 'delivered'
GROUP BY cus.customer_state
ORDER BY avg_delivery_days DESC;


-- .Which states have the most orders and highest revenue.
SELECT 
cus.customer_state AS State,
ROUND(SUM(pym.payment_value),2) AS State_revenue,
ROUND(SUM(pym.payment_value)/SUM(SUM(pym.payment_value)) OVER()*100,2) AS Revenue_Concentration,
COUNT(DISTINCT ord.order_id) AS Total_orders
FROM olist_customers cus
JOIN olist_orders ord
ON cus.customer_id=ord.customer_id
JOIN olist_order_payments pym
ON ord.order_id=pym.order_id
WHERE ord.order_status="delivered"
GROUP BY cus.customer_state
ORDER BY State_revenue DESC LIMIT 10;



-- .Most popular payment method and average order value.
SELECT
pyt.payment_type AS Payment_type,
COUNT(pyt.payment_type) AS Type_count,
COUNT(DISTINCT pyt.order_id) AS Total_orders,
ROUND(SUM(pyt.payment_value) / COUNT(DISTINCT pyt.order_id), 2) AS Average_order_value
FROM olist_order_payments pyt
JOIN olist_orders ord
ON ord.order_id=pyt.order_id
WHERE pyt.payment_type != 'not_defined' AND ord.order_status="delivered"
GROUP BY pyt.payment_type
ORDER BY Type_count DESC;


 

-- .Cancellation rate.
SELECT 
SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
COUNT(DISTINCT  order_id) AS total_orders,
ROUND(
(SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) /COUNT(DISTINCT  order_id)) * 100,2) 
AS cancellation_percentage
FROM olist_orders;




-- .Average freight cost by product category.
SELECT trans.product_category_name_english AS Product_category, 
ROUND(AVG(itm.freight_value),2) AS Average_freight 
FROM olist_order_items itm 
JOIN olist_products pdr 
ON itm.product_id=pdr.product_id 
JOIN olist_category_translation trans 
ON pdr.product_category_name=trans.product_category_name 
JOIN olist_orders ord
ON itm.order_id=ord.order_id
WHERE ord.order_status="delivered"
GROUP BY trans.product_category_name_english 
ORDER BY  Average_freight DESC; 




