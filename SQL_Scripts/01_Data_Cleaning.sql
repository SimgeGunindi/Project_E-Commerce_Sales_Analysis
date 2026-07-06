-- SQL CODE FOR ANALYSING E-COMMERCE DATASETS

-- Importing CSVs

CREATE DATABASE olist;

USE olist;

SET GLOBAL local_infile = 1;

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
)
;

LOAD DATA LOCAL INFILE 'C:/Users/Asus/Desktop/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#checking "orders" table
SELECT COUNT(*) 
FROM orders;
#row numbers
SELECT * 
FROM orders LIMIT 5;

-- Other tables were imported without writing a code

#checking "order_items" table
SELECT COUNT(*) 
FROM order_items
;
SELECT * 
FROM order_items 
LIMIT 5
;

# "customers" table
SELECT COUNT(*) 
FROM customers;
SELECT * 
FROM customers
LIMIT 5
;

-- Controlling the data

# Find cases where the same order item appears more than once:
SELECT order_id, order_item_id, COUNT(*) 
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
# 0

# How many order_items don’t have a matching order?
SELECT COUNT(*) 
FROM order_items oi
LEFT JOIN orders o 
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
# 0

# order_items dataset: one order_id can have more than one item
# need to be careful when summing up prices for the revenue 
# revenue should be calculated correctly
SELECT 
    o.order_id,
    SUM(oi.price + oi.freight_value) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_id;


SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
# orders should be unique per order_id--> 0

SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
#0

SELECT COUNT(*) 
FROM orders
WHERE order_id IS NULL;
#checking nulls->0
SELECT COUNT(*) 
FROM order_items
WHERE order_id IS NULL;
#0
#also in customers:
SELECT COUNT(*) 
FROM customers
WHERE customer_id IS NULL;

SELECT COUNT(*) 
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
#Will my join drop data?--> 0

SELECT COUNT(*) 
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
# 0

SHOW COLUMNS FROM orders;
SHOW COLUMNS FROM order_items;
SHOW COLUMNS FROM customers;
#check types

-- Making intermediate tables (joining 2 tables)

CREATE TABLE order_and_items_joined AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value

FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id;


SELECT COUNT(*) 
FROM order_and_items_joined;
# 112650 

SELECT COUNT(DISTINCT order_id) 
FROM order_and_items_joined;
#98666 -- 112,650 / 98,666 ≈ 1.14 items per order (on average)-- because we have more items than orders

-- Final table: all merged

CREATE TABLE all_3 AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code_prefix,

    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN customers c
    ON o.customer_id = c.customer_id;

select *
from all_3;

SELECT COUNT(*) 
FROM all_3;
# 112650

SELECT 
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM all_3;
# 0

-- Duplicates

SELECT 
    order_id,
    order_item_id,
    COUNT(*) AS cnt
FROM all_3
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
# 0 , no dup

-- Null

SELECT 
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_unique_id IS NULL) AS missing_cust_uniq,
    SUM(customer_id) AS missing_customer,
    SUM(order_item_id IS NULL) AS missing_item_id,
    SUM(price IS NULL) AS missing_price,
    SUM(freight_value IS NULL) AS missing_freight
FROM all_3;
# all 0

-- Invalidity

SELECT *
FROM all_3
WHERE price < 0 OR freight_value < 0;
# 0 rows 


SELECT DISTINCT order_status 
FROM all_3;
# order status are correct 


-- Next: 4 SQL scripts exploring business insights

-- After SQL: Python analysis