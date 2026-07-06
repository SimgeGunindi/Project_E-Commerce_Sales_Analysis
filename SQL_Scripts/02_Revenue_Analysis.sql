-- Revenue Analysis


CREATE TABLE order_revenue_clean AS
SELECT 
    order_id,
    DATE(order_purchase_timestamp) AS order_date,
    SUM(price + freight_value) AS revenue
FROM all_3
WHERE order_status = 'delivered'
  AND price IS NOT NULL
  AND freight_value IS NOT NULL
GROUP BY order_id, DATE(order_purchase_timestamp)
;

select *
from order_revenue_clean;

-- Controls:

SELECT *
FROM order_revenue_clean
WHERE revenue <= 0;
#0

SELECT 
    MIN(revenue),
    MAX(revenue),
    AVG(revenue)
FROM order_revenue_clean;

SELECT 
    MIN(order_date),
    MAX(order_date)
FROM order_revenue_clean;
# 2016 to 2018

SELECT COUNT(*)
FROM order_revenue_clean
WHERE order_date IS NULL;
#0 nulls

SELECT 
    YEAR(order_date) AS year,
    COUNT(*) AS orders
FROM order_revenue_clean
GROUP BY year
ORDER BY year;

SELECT order_id, COUNT(*)
FROM order_revenue_clean
GROUP BY order_id
HAVING COUNT(*) > 1;
# no duplicates

SELECT 
    SUM(order_id IS NULL OR order_id = '') AS missing_order_id,
    SUM(order_date IS NULL) AS missing_date,
    SUM(revenue IS NULL OR revenue = '') AS missing_revenue
FROM order_revenue_clean;
# all 0

-- Business Questions & Insights

-- Q1. Monthly revenue
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(revenue) AS total_revenue
FROM order_revenue_clean
GROUP BY month
ORDER BY month;
# Increasing

-- Q2. AOV (Average Order Value)
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    AVG(revenue) AS avg_order_value
FROM order_revenue_clean
GROUP BY month
ORDER BY month;
# Monthly average is stable

-- Q3. Order volume
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id) AS total_orders
FROM order_revenue_clean
GROUP BY month
ORDER BY month;
# Growth possibly comes from more orders

-- Q4. Revenue distribution
SELECT 
    CASE 
        WHEN revenue < 50 THEN '0-50'
        WHEN revenue < 100 THEN '50-100'
        WHEN revenue < 200 THEN '100-200'
        WHEN revenue < 300 THEN '200-300'
        WHEN revenue < 400 THEN '300-400'
        WHEN revenue < 500 THEN '400-500'
        ELSE '500+'
    END AS revenue_bucket,
    COUNT(*) AS num_orders
FROM order_revenue_clean
GROUP BY revenue_bucket
ORDER BY revenue_bucket;

-- or: top orders 
SELECT *
FROM order_revenue_clean
ORDER BY revenue DESC
LIMIT 1000;
