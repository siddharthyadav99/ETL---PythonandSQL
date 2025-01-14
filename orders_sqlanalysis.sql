#USE orders_analysis1  

CREATE TABLE df_orders (
   order_id INT PRIMARY KEY,
   order_date DATE,
   ship_mode VARCHAR(20),
   segment VARCHAR(20),
   country VARCHAR(20),
   city VARCHAR(20),
   state VARCHAR(20),
   postal_code VARCHAR(20),
   region VARCHAR(20),
   category VARCHAR(20),
   sub_category VARCHAR(20),
   product_id VARCHAR(50),
   quantity INT,
   discount DECIMAL(7,2),
   sale_price DECIMAL(7,2),
   profit DECIMAL(7,2)
); 


#Find Top 10 highest revenue generating products

SELECT product_id, sum(sale_price) AS Total_Sales
FROM df_orders
GROUP BY product_id
ORDER BY Total_Sales DESC
LIMIT 10;


#Find Top 5 highest selling products in each region

WITH CTE AS(
SELECT region, product_id, sum(sale_price) AS total_sales
FROM df_orders
GROUP BY region, product_id )
SELECT * FROM
(SELECT * , ROW_NUMBER() OVER(PARTITION BY region ORDER BY total_sales DESC) as rn
FROM CTE) AS sq
WHERE rn <= 5;


#Find month over month comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

WITH CTE AS
(SELECT year(order_date) as order_year , month(order_date) as order_month, sum(sale_price) AS sales
FROM df_orders
GROUP BY year(order_date), month(order_date)
	)
SELECT order_month
, sum(CASE WHEN order_year = 2022 then sales else 0 end) as sales_2022
, sum(CASE WHEN order_year = 2023 then sales else 0 end) as sales_2022
FROM CTE
group by order_month
order by order_month;    


# For which category which month had highest sales

WITH CTE AS
(SELECT category, year(order_date) as order_year, month(order_date) as order_month , sum(sale_price) as total_sales
FROM df_orders
GROUP BY category, year(order_date), month(order_date)
	)
SELECT * FROM    
(SELECT * ,
RANK() OVER(PARTITION BY category ORDER BY total_sales DESC) as rn
FROM CTE
	) as sq
WHERE rn = 1 ;

#Which subcategory had the highest growth by profit in 2023 compare to 2022

WITH CTE as
(SELECT sub_category, year(order_date) as order_year, sum(sale_price) as sales
FROM df_orders
GROUP BY sub_category,year(order_date)
	)
, CTE2 as 
(SELECT sub_category
,sum(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) as sales_2022
,sum(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) as sales_2023
FROM CTE
GROUP BY sub_category
	)
SELECT * 
,(sales_2023 - sales_2022)*100/sales_2022
FROM CTE2
ORDER BY (sales_2023 - sales_2022)*100/sales_2022 DESC
limit 1;







 









