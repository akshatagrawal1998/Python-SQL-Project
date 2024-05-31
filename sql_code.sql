
create database project 

use project
-- either we can import the data from csv or build a connection with Python and get the data in SQL Server data


select * from [dbo].[orders_data]
drop table orders_data
-- select * from  order_dataset
-- Write a SQL query to list all distinct cities where orders have been shipped.

select distinct city from orders_data

-- Calculate the total selling price and profits for all orders.
select [Order Id], sum(quantity*Unit_Selling_Price) as 'Total Selling Price',
cast(sum(quantity*unit_profit) as decimal(10,2)) as 'Total Profit'
-- , [Total Profit] (as it was already present in the table, we could directly use that column
from orders_data
group by [Order ID]
order by [Total Profit] desc

-- Write a query to find all orders from the 'Technology' category 
-- that were shipped using 'Second Class' ship mode, ordered by order date.
select [Order Id], [Order Date]
from orders_data
where category = 'Technology' and [Ship Mode] = 'Second Class'
order by [order date]

-- Write a query to find the average order value
select cast(avg(quantity * unit_selling_price) as decimal(10, 2)) as AOV
from orders_data

-- find the city with the highest total quantity of products ordered.
select top 1 city, sum(quantity) as 'Total Quantity'
from orders_data
group by city order by [Total Quantity] desc

-- Use a window function to rank orders in each region by quantity in descending order.
select [order id], region, quantity as 'Total_Quantity',
dense_rank() over (partition by region order by quantity desc) as rnk
from orders_data 
order by region, rnk 


-- Write a SQL query to list all orders placed in the first quarter of any year (January to March), including the total cost for these orders.
-- select * from orders_data where [order id] = 137

select [order id], [order date], month([order date]) as month from orders_data

select [Order Id], sum(Quantity*unit_selling_price) as 'Total Value'
from orders_data
where month([order date]) in (1,2,3) 
group by [Order Id]
order by [Total Value] desc

 select * from orders_data

-- Q1. find top 10 highest profit generating products 
select top 10 [product id],sum([Total Profit]) as profit
from [orders_data]
group by [product id]
order by profit desc

;
-- alternate -> using window function     
with cte as (
select [product id], sum([Total Profit]) as profit
, dense_rank() over (order by sum([Total Profit]) desc) as rn
from orders_data
group by [Product Id]
)
select [Product Id], Profit
from cte where rn<=10


-- now the question couuld also be for top n products acc to revenue/sales.


--find top 3 highest selling products in each region

;
with cte as (
select region, [product id], sum(quantity*Unit_selling_price) as sales
, row_number() over(partition by region order by sum(quantity*Unit_selling_price) desc) as rn
from [orders_data]
group by region, [product id]
) 
select * 
from cte
where rn<=3

;

with cte as (
select region, [product id], sum(quantity*Unit_selling_price) as sales
from [orders_data]
group by region, [product id]
) 
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=3




-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
;
with cte as (
select year([order date]) as order_year,month([order date]) as order_month,
sum(quantity*Unit_selling_price) as sales
from orders_data
group by year([order date]),month([order date])
--order by year(order_date),month(order_date)
)
select order_month
, round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
, round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte 
group by order_month
order by order_month

-- now we can also calculate % of growth



-- for each category which month had highest sales 
with cte as (
select category, format([order date],'yyyy-MM') as order_year_month
, sum(quantity*Unit_selling_price) as sales,
row_number() over(partition by category order by sum(quantity*Unit_selling_price) desc) as rn
from orders_data
group by category,format([order date],'yyyy-MM')
--order by category,format(order_date,'yyyyMM')
)
select category as Category, order_year_month as 'Order Year-Month', sales as [Total Sales]
from cte
where rn=1



select * from order_data
-- which sub category had highest growth by sales in 2023 compare to 2022
;
with cte as (
select [sub category] as sub_category, year([order date]) as order_year,
sum(quantity*Unit_selling_price) as sales
from orders_data
group by [sub category],year([order date])
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
, round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte 
group by sub_category
)
-- select * from cte2
select top 1 sub_category as 'Sub Category', sales_2022 as 'Sales in 2022',
sales_2023 as 'Sales in 2023'
,(sales_2023-sales_2022) as 'Diff in Amount'
from  cte2
order by (sales_2023-sales_2022) desc


/*
For more challenging analysis tasks using SQL on this dataset, here are some complex questions that will require you to use a variety of SQL features,
including advanced joins, nested queries, and sophisticated aggregation techniques. These questions are aimed at providing deep insights into the dataset:

1. Market Basket Analysis
   - Write a SQL query to identify the most commonly ordered pair of products within the same order. 
   This requires understanding how to count pairs of products across orders.

2. Customer Segmentation
   - Use SQL to segment customers based on their purchasing patterns, such as frequent vs. infrequent buyers, high vs. low spenders, 
   or by the categories they purchase from most often. This might involve multiple joins and aggregations to calculate the metrics that 
   define each segment.

3. Time Series Analysis
   - Analyze the month-over-month growth rate in sales by category. This will involve calculating total sales per month per category and then 
   finding the percentage change from one month to the next.

4. Profitability Analysis
   - Calculate the profitability of each product by subtracting the cost price from the list price, then aggregating this data to see which 
   category is the most profitable. Enhance this analysis by considering the discount and quantity sold.

5. Geographical Analysis
   - Determine which city or state is the most lucrative market in terms of total sales revenue and compare this to the average discount given in 
   each location. This will involve complex aggregations and possibly creating custom geographical segments.

6. Inventory Turnover
   - Analyze which sub-categories have the highest inventory turnover rate. This will require calculating the rate at which inventory is 
   sold (quantity/list price) and may involve date functions to determine the period of time products are held before being sold.

7. Customer Lifetime Value (CLV)
   - Estimate the lifetime value of customers by calculating the total revenue each customer has generated over time and projecting future 
   purchases based on their order history. This might require predictive SQL functions if available, or just complex aggregations.

8. Seasonal Trends
   - Investigate seasonal trends in order types or shipping modes. For instance, determine if certain products are more popular during specific 
   times of the year and if certain shipping modes are preferred in different seasons.

9. Predictive Analysis
   - Write a query to predict the next month’s top-performing product category based on past performance trends. This could involve trend analysis 
   and linear regression directly in SQL if supported.

10. Complex Correlations
    - Explore correlations between discount levels and customer segments, order quantities, or profitability. This analysis might involve multiple 
	nested queries and the use of statistical functions in SQL to calculate correlation coefficients.
11. 
- Assuming there is another table that records customer feedback scores for each product, write a query to find the average feedback score of 
products in each category, only including products that have more than 10 orders.
*/