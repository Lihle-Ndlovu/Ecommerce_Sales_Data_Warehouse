--EDA
-- Total number of rows

SELECT COUNT (* )AS  ROW_NUMBER
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
--10 000 ROWS

-------checking duplicates
SELECT
    order_id,
    order_date,
    ship_date,
    delivery_date,
    order_status,
    customer_id,
    customer_name,
    country,
    state,
    city,
    product_id,
    product_name,
    category,
    sub_category,
    brand,
    quantity,
    unit_price,
    discount,
    shipping_cost,
    total_sales,
    payment_method,
    COUNT(*) AS duplicate_count
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
GROUP BY
    order_id,
    order_date,
    ship_date,
    delivery_date,
    order_status,
    customer_id,
    customer_name,
    country,
    state,
    city,
    product_id,
    product_name,
    category,
    sub_category,
    brand,
    quantity,
    unit_price,
    discount,
    shipping_cost,
    total_sales,
    payment_method
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

----------------------------More important: check order_id + product_id
SELECT
    order_id,
    product_id,
    customer_id,
    COUNT(*) AS duplicate_count
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
GROUP BY
    order_id,
    product_id,
    customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

---------------Check how many duplicated combinations you have
SELECT
    COUNT(*) AS duplicate_groups
FROM (
    SELECT
        order_id,
        product_id
    FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
    GROUP BY
        order_id,
        product_id
    HAVING COUNT(*) > 1
) AS duplicates;

------------------------------------------------------------------------------------
---Check for NULL / blank values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_nulls,
    SUM(CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END) AS delivery_date_nulls,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS order_status_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS sub_category_nulls,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS brand_nulls,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
    SUM(CASE WHEN shipping_cost IS NULL THEN 1 ELSE 0 END) AS shipping_cost_nulls,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS total_sales_nulls,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_nulls
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg];

-------dates 
 SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    MIN(ship_date) AS earliest_ship,
    MAX(ship_date) AS latest_ship,
    MIN(delivery_date) AS earliest_delivery,
    MAX(delivery_date) AS latest_delivery
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]

-------how much data you have for January vs February.
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(TRY_CONVERT(decimal(18,2), total_sales)) AS total_sales
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;

-------Check product and customer counts
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT order_id) AS unique_orders
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]

----Order status
SELECT
    order_status,
    COUNT(*) AS order_count
FROM [ecommerce_sales_stg].[dbo].[ sales_raw_stg]
GROUP BY order_status
ORDER BY order_count DESC;

------Payment method

------Category

----Brand

----Unit price

---Quantity
---Total sales

---8. Find suspicious values

---Negative prices
SELECT *
FROM staging_ecommerce_sales
WHERE TRY_CONVERT(decimal(18,2), unit_price) < 0;

---Negative sales
SELECT *
FROM staging_ecommerce_sales
WHERE TRY_CONVERT(decimal(18,2), total_sales) < 0;

-----Check sales by country
SELECT
    country,
    COUNT(*) AS transactions,
    SUM(TRY_CONVERT(decimal(18,2), total_sales)) AS total_sales
FROM staging_ecommerce_sales
GROUP BY country

-----Check sales by category
SELECT
    category,
    SUM(TRY_CONVERT(decimal(18,2), total_sales)) AS total_sales,
    SUM(TRY_CONVERT(int, quantity)) AS units_sold
FROM staging_ecommerce_sales
GROUP BY category
ORDER BY total_sales DESC;


----Find your top products

SELECT TOP 10
    product_id,
    product_name,
    SUM(TRY_CONVERT(int, quantity)) AS units_sold,
    SUM(TRY_CONVERT(decimal(18,2), total_sales)) AS total_sales
FROM staging_ecommerce_sales
GROUP BY
    product_id,
    product_name
ORDER BY total_sales DESC;

----Find your top customers
SELECT TOP 10
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS orders,
    SUM(TRY_CONVERT(decimal(18,2), total_sales)) AS total_spent
FROM staging_ecommerce_sales
GROUP BY
    customer_id,
    customer_name
ORDER BY total_spent DESC;

------------------------
How many rows are in the dataset?
How many unique customers?
How many unique products?
How many unique orders?
Are there missing values?
Are there duplicates?
What date range does the data cover?
What are the most common order statuses?
Which payment method is most popular?
Which countries generate the most sales?
Which categories generate the most revenue?
Which products sell the most?
Which customers spend the most?
Are there invalid prices, quantities, or dates?
ORDER BY total_sales DESC;