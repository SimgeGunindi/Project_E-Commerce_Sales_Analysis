-- Customer Analysis


CREATE TABLE customer_level AS
SELECT 
    customer_unique_id,

    COUNT(order_id) AS total_orders,
    SUM(total_revenue) AS total_spent,
    AVG(total_revenue) AS avg_order_value,
    SUM(items_per_order) AS total_items,

    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date

FROM order_level
GROUP BY customer_unique_id;


select *
from customer_level;

# Adding a column
ALTER TABLE customer_level
ADD COLUMN customer_lifetime_days INT;

UPDATE customer_level
SET customer_lifetime_days = DATEDIFF(last_order_date, first_order_date);

-- Business Questions & Insights

-- Q1. Repeat vs one-time
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'one-time'
        ELSE 'repeat'
    END AS customer_type,
    COUNT(*) AS num_customers
FROM customer_level
GROUP BY customer_type;
# once: 90557, repeat: 2801
# The business appears to rely heavily on customer acquisition rather than retention

-- Q2. Top customers
SELECT *
FROM customer_level
ORDER BY total_spent DESC
LIMIT 500;
# According to who generated most revenue

-- Q3. Spending distribution
SELECT 
    MIN(total_spent),
    MAX(total_spent),
    AVG(total_spent)
FROM customer_level;
# Skewed

-- Q4. Customer lifetime
SELECT 
    AVG(customer_lifetime_days),
    MAX(customer_lifetime_days)
FROM customer_level;
# Most customers do not return after their first purchase
