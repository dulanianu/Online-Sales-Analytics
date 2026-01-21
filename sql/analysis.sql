USE bi_sales;

-- ----------------------------------
--      ANALYSIS
-- ----------------------------------
--    Sales and Profit
-- ----------------------------------
SELECT
    YEAR(order_date_converted) AS year,
    -- MONTH(order_date_converted) AS month,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM v_orders_with_date
group by year
order by year;

-- using inner join

SELECT year, SUM(sales)
FROM dim_date
	INNER JOIN fact_sales_new
		ON dim_date.date = fact_sales_new.order_date_converted
group by year
order by year;

-- ------------------------------
-- TOP 10 Products by Revenue
-- -------------------------------
SELECT
    p.product_name,
    SUM(f.sales) AS total_sales
FROM fact_sales_new f
JOIN dim_product p
    ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- -------------------------------
-- KPIs
-- ------------------------------
-- Total Revenue & Profit
SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM fact_sales_new;

-- Average Order Value (AOV)
SELECT
    SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM fact_sales_new;

-- Repeat vs One-Time Customers
SELECT
    customer_id, 
    COUNT(DISTINCT order_id) AS orders
FROM fact_sales_new
GROUP BY customer_id
order by orders DESC;

-- Create Customer Segmentation
ALTER TABLE dim_customer
ADD customer_type VARCHAR(20);

UPDATE dim_customer dc
JOIN (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS orders
    FROM fact_sales_new
    GROUP BY customer_id
) t
ON dc.customer_id = t.customer_id
SET dc.customer_type =
    CASE
        WHEN t.orders > 1 THEN 'Repeat'
        ELSE 'One-Time'
    END;