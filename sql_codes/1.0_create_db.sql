IF DB_ID ('ecommerce_sales_dw') IS NULL
BEGIN
CREATE DATABASE ecommerce_sales_dw
END;

IF DB_ID ('ecommerce_sales_stg') IS NULL
BEGIN
CREATE DATABASE ecommerce_sales_stg
END;
