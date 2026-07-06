-- Product Analysis


CREATE TABLE product_level AS
SELECT 
    order_id,
    product_id,
    DATE(order_purchase_timestamp) AS order_date,

    price,
    freight_value,
    (price + freight_value) AS revenue

FROM all_3
WHERE order_status = 'delivered'
  AND price IS NOT NULL
  AND freight_value IS NOT NULL;


select *
from product_level;

-- missing values

SELECT *
FROM product_level
WHERE product_id IS NULL OR revenue <= 0;

-- duplicates

SELECT order_id, product_id, COUNT(*)
FROM product_level
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
# having dup is normal - no deleting

-- Business Questions & Insights

-- Q1. Top products by revenue - Revenue concentration
SELECT 
    product_id,
    SUM(revenue) AS total_revenue
FROM product_level
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 500;
# Seems to be a small number of products

-- Q2. Most frequently purchased products
SELECT 
    product_id,
    COUNT(*) AS total_units_sold
FROM product_level
GROUP BY product_id
ORDER BY total_units_sold DESC
LIMIT 10;

-- Q3. Revenue vs frequency
SELECT 
    product_id,
    COUNT(*) AS total_units_sold,
    SUM(revenue) AS total_revenue
FROM product_level
GROUP BY product_id
ORDER BY total_units_sold DESC;
# General trend: top selling products are top revenue

-- Q4. Average revenue per product - price positioning
SELECT 
    product_id,
    AVG(revenue) AS avg_revenue_per_sale,
    COUNT(*) AS total_units
FROM product_level
GROUP BY product_id
ORDER BY avg_revenue_per_sale DESC
LIMIT 10000;  
# High total revenue is primarily driven by sales volume, not high price
