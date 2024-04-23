-- Create database
create database if not exists walmart_sales_analysis;

-- create table
create table if not exists sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(15) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
tax_pct float(6,4),
total decimal(12,4) not null,
date datetime not null,
time Time not null,
payment varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal(12,4),
rating float(2,1)
);	

select * from sales;
alter table sales rename column payment to payment_type;
alter table sales rename column time to sales_time;


--- Data Wrangling
--- Check for null values

select invoice_id, branch from sales where invoice_id is null;

--------------------------------- Feature Engineering ------------------
--------   Add time_of_day

select sales_time,
( case 
	  when `sales_time` between "00:00:00" and "12:00:00" then "Morning"
      when `sales_time` between "12:00:01" and "16:00:00" then "Afternoon"
      else "Evening"
	end ) as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales set time_of_day=(
case 
	  when `sales_time` between "00:00:00" and "12:00:00" then "Morning"
      when `sales_time` between "12:00:01" and "16:00:00" then "Afternoon"
      else "Evening"
	end );
    
set sql_safe_updates=0;
select * from sales;
    
    
--- day name
    select date, dayname(date) from sales;
alter table sales add column day_name varchar(10);
update sales set day_name=dayname(date);

--- month name
select date, monthname(date) from sales;
alter table sales add column month_name varchar(10);
update sales set month_name= monthname(date);
      
-------------------------------------------------------------------
-------- Generic Questions ----------------------------------------

--  1. How many unique cities does the data have?
select distinct city from sales;   

-- 2. In which city is each branch?
select distinct city, branch from sales;

-- -----------------------------------------------------------------
-- ------ Product Questions ----------------------------------------

-- 3. How many unique product lines does the data have?
select count(distinct product_line) from sales;

-- 4. What is the most common payment method?
select payment_type, count(payment_type) as cnt from sales group by payment_type order by cnt desc;

-- 5. What is the most selling product line?
select product_line, count(product_line) as cnt from sales group by product_line order by cnt desc;

-- 6. What is the total revenue by month?
select month_name, sum(total) as total_revenue from sales group by month_name order by total_revenue desc;

-- 7. What month had the largest COGS?
select month_name, sum(cogs) as total_cogs from sales group by month_name order by total_cogs desc;

-- 8. What product line had the largest revenue?
select product_line, sum(total) as total_revenue from sales group by product_line order by total_revenue desc;

-- 9. What is the city with the largest revenue?
select city, sum(total) as total_revenue from sales group by city order by total_revenue desc ;

-- 10. What product line had the largest VAT?
select product_line, avg(tax_pct) as avg_tax from sales group by product_line order by avg_tax desc;

-- 11. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

-- 12. Which branch sold more products than average product sold?
select branch, sum(quantity) as qty
from sales
group by branch having qty >( select avg(quantity) from sales);

-- 13. What is the most common product line by gender?
select gender, product_line, count(gender) as total_cnt from sales
group by gender, product_line order by total_cnt desc;

-- 14. What is the average rating of each product line?
select round(avg(rating),2) as avg_rating , product_line from sales group by product_line order by avg_rating desc;

-- -----------------Sales Questions---------------------------------------------
-- -----------------------------------------------------------------------------

-- 15. Number of sales made in each time of the day per weekday
select time_of_day, count(*) as total_sales
from sales
group by time_of_day order by total_sales desc;

-- 16. Which of the customer types brings the most revenue?
select customer_type, round(sum(total),2) as total_rev
from sales
group by customer_type order by total_rev desc;


-- 17. Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(tax_pct) as tax from sales group by city order by tax desc; 

-- 18. Which customer type pays the most in VAT?
select customer_type, avg(tax_pct) as tax from sales group by customer_type order by tax desc; 

-- ------------------------------ Customers-----------------------------------------------------------

-- 19. How many unique customer types does the data have?
select distinct customer_type from sales;
    
-- 20. How many unique payment methods does the data have?
select distinct payment_type from sales;
    
 -- 21. What is the most common customer type?
 select customer_type, count(customer_type) from sales group by customer_type;
 
 -- 22. Which customer type buys the most?
select customer_type, count(*) as cstm_cnt, sum(quantity) from sales group by customer_type;

-- 23. What is the gender of most of the customers?
select gender, count(*) as gender_cnt from sales group by gender order by gender_cnt;

-- 24. What is the gender distribution per branch?
select branch, gender, count(*) as gender_cnt from sales  group by branch, gender order by branch, gender;
    
-- 25. Which time of the day do customers give most ratings?
select time_of_day, avg(rating) as avg_rating from sales group by time_of_day order by avg_rating desc; 

-- 26. Which time of the day do customers give most ratings per branch?
select time_of_day, branch, avg(rating) as avg_rating from sales group by branch,time_of_day order by time_of_day,branch,avg_rating desc;

-- 27. Which day fo the week has the best avg ratings?
select day_name, avg(rating)  as avg_rating from sales group by day_name order by avg_rating desc;

-- 28. Which day of the week has the best average ratings per branch?
select day_name, avg(rating) as avg_rating from sales where branch="B" group by day_name order by avg_rating desc;







   

