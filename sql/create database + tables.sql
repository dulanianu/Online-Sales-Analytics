CREATE DATABASE bi_sales;
USE bi_sales;
DROP TABLE IF EXISTS superstore_raw;
-- ------- Create raw data table --------
CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(50),
    order_date VARCHAR(50),
    ship_date VARCHAR(50),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    market VARCHAR(50),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    order_priority VARCHAR(50)
);

-- date format conversion ------------------
CREATE OR REPLACE VIEW v_orders_with_date AS 
SELECT
    *,
    STR_TO_DATE(order_date, '%d/%m/%Y') AS order_date_converted
FROM superstore_raw;
-- -----------------------------------------
--   Create sales table 
-- -----------------------------------------
CREATE TABLE fact_sales_new AS
SELECT
    order_id,
    order_date_converted,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost
FROM v_orders_with_date;
-- -------------------------
-- Create Customer Table
-- -------------------------
SELECT customer_id, COUNT(*)
FROM dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- encounter duplicates

DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer AS
SELECT
    customer_id,
    MIN(customer_name) AS customer_name,
    MIN(segment) AS segment,
    MIN(city) AS city,
    MIN(state) AS state,
    MIN(country) AS country,
    MIN(region) AS region,
    MIN(market) AS market
FROM v_orders_with_date
GROUP BY customer_id;

-- Verify uniqueness
SELECT COUNT(*) 
FROM dim_customer;
SELECT COUNT(DISTINCT customer_id) 
FROM dim_customer;

-- if ther's no duplicates
CREATE TABLE dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    city,
    state,
    country,
    region,
    market
FROM v_orders_with_date;
-- --------------------------------
-- Create Product Table
-- --------------------------------
-- check for duplicates
SELECT product_id, COUNT(*)
FROM dim_product
GROUP BY product_id
HAVING COUNT(*) > 1;

DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product AS
SELECT
    product_id,
    MIN(product_name) AS product_name,
    MIN(category) AS category,
    MIN(sub_category) AS sub_category
FROM v_orders_with_date
GROUP BY product_id;

-- verify uniqueness
SELECT COUNT(*) 
FROM dim_product;
SELECT COUNT(DISTINCT product_id) 
FROM dim_product;


CREATE TABLE dim_product AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM v_orders_with_date;
-- ----------------------------------
--    Create date table
-- ----------------------------------
CREATE TABLE dim_date AS
SELECT DISTINCT
    order_date_converted AS date,
    YEAR(order_date_converted) AS year,
    MONTH(order_date_converted) AS month,
    MONTHNAME(order_date_converted) AS month_name,
    DAY(order_date_converted) AS day,
    DAYNAME(order_date_converted) AS weekday
FROM v_orders_with_date
WHERE order_date_converted IS NOT NULL;
-- ----------------------------------
-- VALIDATION
-- ----------------------------------
SELECT
    order_date,
    order_date_converted
FROM v_orders_with_date
LIMIT 10;

-- Validate dim_date table
SELECT * 
FROM dim_date 
ORDER BY date 
LIMIT 10;

SELECT COUNT(*) 
FROM dim_product;
