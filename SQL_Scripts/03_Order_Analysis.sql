-- Order Analysis


CREATE TABLE order_level AS
SELECT 
    order_id,
    customer_unique_id,
    DATE(order_purchase_timestamp) AS order_date,

    COUNT(*) AS items_per_order,
    SUM(price) AS product_value,
    SUM(freight_value) AS freight_value,
    SUM(price + freight_value) AS total_revenue

FROM all_3
WHERE order_status = 'delivered'
  AND price IS NOT NULL
  AND freight_value IS NOT NULL
GROUP BY order_id, customer_unique_id, DATE(order_purchase_timestamp);

# Controls:

SELECT 
    SUM(items_per_order IS NULL OR items_per_order = '') AS missing_item_id,
	SUM(customer_unique_id IS NULL OR customer_unique_id = '') AS missing_customer_unique_id
FROM order_level;
# 0 missing values

SELECT customer_unique_id, COUNT(*)
FROM order_level
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;
# Careful: customer_unique_id showing each real person, different than customer_id 

-- Business Questions & Insights

-- Q1. Distribution of items per order
SELECT 
    items_per_order,
    COUNT(*) AS num_orders
FROM order_level
GROUP BY items_per_order
ORDER BY items_per_order;
# Single item 86k, 2 items: 7k, and decreasing

-- Q2. Typical order size
SELECT 
    AVG(items_per_order) AS avg_items,
    MIN(items_per_order) AS min_items,
    MAX(items_per_order) AS max_items
FROM order_level;
# 1.14 items on average

-- Q3. Does revenue increase with more items?
SELECT 
    items_per_order,
    AVG(total_revenue) AS avg_revenue,
    COUNT(*) AS num_orders
FROM order_level
GROUP BY items_per_order
ORDER BY items_per_order;
# Peak and fluctuations

-- Q4. Check contributions
SELECT 
    items_per_order,
    SUM(total_revenue) AS total_revenue
FROM order_level
GROUP BY items_per_order
ORDER BY total_revenue DESC;
# Mostly single items
