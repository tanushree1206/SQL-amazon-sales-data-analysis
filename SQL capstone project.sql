--- created databases with name as sales
 create database amazon;
# ------sets the active working database to "amazon" for subsequent operations.
 use amazon;
 ---- imported csv file using import wizard
 ---- modified all column datatypes
alter table amazondata modify invoice_id VARCHAR(30),
   modify branch VARCHAR(5),
    modify city VARCHAR(30),
    modify customer_type VARCHAR(30),
    modify gender VARCHAR(10),
    modify product_line VARCHAR(100),
    modify unit_price DECIMAL(10, 2),
    modify quantity INT,
   modify  VAT FLOAT(6, 4),
   modify  total DECIMAL(10, 2),
   modify  date DATEtime,
    modify time time,
   modify  payment_method varchar(200),
   modify  cogs DECIMAL(10, 2),
   modify  gross_margin_percentage FLOAT(11, 9),
    modify gross_income DECIMAL(10, 2),
    modify rating FLOAT;

select * from amazondata;

##### Analysis List
### 1. Product Analysis :
   ---  a) different product lines
SELECT DISTINCT product_line from amazondata;
------- There are 6 different product lines as
 # 1) Health and beauty
 # 2) Food and beverages
 # 3) Home and lifestyle
 # 4) Fashion accessories
 # 5) Electronic accessories
 # 6) Sports and travel

---- b) product line performing best
select product_line , sum(total) as totalsales from amazondata
group by product_line
order by totalsales desc;

#### Food and beverages seems to perform best among all. 
 ### And Home and lifestyle and Health and beauty needs an improvement.
 
 ### 2. Sales Analysis :
 ---- a) sales Trends over time:
 select date, sum(total) as dailysales from amazondata
 group by date order by dailysales desc;
 
 ---- b)  Effectiveness of payment methods (based on Total sales):
 select payment_method, sum(total) as totalsales from amazondata
 group by payment_method
 order by totalsales desc;
 
 ------ c) Analyze sales (based on different customer types)-----
SELECT customer_type, sum(total) AS total_sales
FROM amazondata
GROUP BY customer_type
ORDER BY total_sales DESC;

#### 3. Customer Analysis:
------- a) customor segmentation and purchase trends:
SELECT customer_type, DATE_FORMAT(`date`, '%Y-%m') AS month,
    COUNT(*) AS num_purchases
FROM amazondata
GROUP BY customer_type, month
ORDER BY customer_type, month;

------ b) Profitability by Customer Type-----
SELECT  customer_type, sum(gross_income) AS total_gross_income
from amazondata
group by  customer_type
order by  total_gross_income DESC
LIMIT 0, 1000;

##### cheecking for null values ###
SELECT * from  amazondata WHERE
  `Invoice_id` IS NULL OR
  `Branch` IS NULL OR
  `City` IS NULL OR
  `Customer_type` IS NULL OR
  `Gender` IS NULL OR
  `Product_line` IS NULL OR
  `Unit_price` IS NULL OR
  `Quantity` IS NULL OR
  `vat` IS NULL OR
  `total` IS NULL OR
  `date` IS NULL OR
  `time` IS NULL OR
  `payment_method` IS NULL OR
  `cogs` IS NULL OR
  `gross_margin_percentage` IS NULL OR
  `gross_income` IS NULL OR
  `rating` IS NULL;
  ### so their are no null value in our database ####
  
  ------- Feature Engineering: ------
  ### a) Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. ###
alter table amazondata
add column timeofday varchar(20);

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;
-- Update the timeofday column based on the time
UPDATE amazondata
SET timeofday =
    CASE
        WHEN TIME(time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END;

-- Re-enable safe update mode (optional)
SET SQL_SAFE_UPDATES = 1;

### b)  Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
ALTER TABLE amazondata
ADD COLUMN dayname VARCHAR(10);
---- after adding a column named dayname we are update the column based on date-----
UPDATE amazondata
SET dayname = DAYNAME(`date`)
WHERE invoice_id IS NOT NULL
LIMIT 1000; 

### c)  Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
ALTER TABLE amazondata
ADD COLUMN monthname VARCHAR(3);
---- after adding a column named monthname we are update the column based on date-----
UPDATE amazondata
SET monthname = UPPER(SUBSTRING(MONTHNAME(`date`), 1, 3))
WHERE invoice_id IS NOT NULL
LIMIT 1000; 

######  Exploratory Data Analysis (EDA): ####
# Exploratory data analysis is done to answer the listed questions and aims of this project.#
#### Business Questions To Answer: ###

# 1) What is the count of distinct cities in the dataset?
select count(distinct city) as num_distinct_cities from amazondata;
## Their are three distinct cities in the dataset. ##

# 2) For each branch, what is the corresponding city?
select distinct branch, city from amazondata;
## For branch A city is Yangon , for branch B city is Mandalay and for branch c city is Naypyitaw

# 3) What is the count of distinct product lines in the dataset?
select count(distinct product_line) as num_distinct_product_lines from amazondata;
## so their are 6 distinct product lines in the dataset. ##

# 4) Which payment method occurs most frequently?
select payment_method , count(*) as frequency from amazondata 
group by payment_method
order by frequency desc limit 1;
## The Ewallet payment method occurs most frequently. ## 

# 5) Which product line has the highest sales?
select product_line , round(sum(total),2)as total_sales from amazondata
group by product_line
order by total_sales desc limit 1;
## So Food and beverages product line has the highest sales. ##

# 6) How much revenue is generated each month?
SELECT monthname(max(date)) as month, sum(total) as total_revenue from amazondata
group by month(date)
order by month(date);
## The revenue generated in each month is January = 116291.86 ,February	= 97219.37 and March = 109455.50700000004
    
# 7) In which month did the cost of goods sold reach its peak?
select monthname ,max(cogs) as max_cogs from amazondata
group by monthname
order by max_cogs desc limit 1;
## In FEB month, the cost of goods sold reach its peak and is 993. ##

# 8) Which product line generated the highest revenue?
select product_line , round(sum(total),2) as total_revenue from amazondata
group by product_line
order by total_revenue desc limit 1;
## Food and beverages product line generated the highest revenue and its 56144.84 ##

# 9) In which city was the highest revenue recorded?
select city , round(sum(total),2) as total_revenue from amazondata
group by city
order by total_revenue desc limit 1;
## In Naypyitaw city highest revenue recorded and is 110568.71 ##

# 10) Which product line incurred the highest Value Added Tax?
select product_line , round(sum(vat),2) as total_value_added_tax from amazondata
group by product_line
order by total_value_added_tax desc limit 1;
## Food and beverages product line incurred the highest Value Added Tax and is 2673.56 ##

# 11) For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select *,
      case when total > avg(total) over (partition by product_line) then 'Good'
            else 'bad'
	  end as sales_evaluation
from amazondata;
## Analyzed sales data, categorizing each product line as "Good" if its sales are above average and "Bad" if below average.
##  Identified sales patterns, facilitating strategic decision-making for product improvement and performance optimization.

# 12) Identify the branch that exceeded the average number of products sold.
select branch from amazondata
group by branch
having avg(quantity) > (select avg(quantity) from amazondata);
## branche C where the average quantity sold is greater than the overall average across all branches. ##

# 13) Which product line is most frequently associated with each gender?
select gender , product_line , count(*) as frequency from amazondata
group by gender, product_line
order by gender, `frequency` desc ;
## NOTE - among females, Fashion accessories have the highest frequency, followed by Food and beverages and Sports and travel.
## For males, Health and beauty is the most frequently purchased product line, closely followed by Electronic accessories and Food and beverages. 
##This analysis provides insights into the preferred product lines for each gender group based on the transaction data.

# 14) Calculate the average rating for each product line.
select product_line , round(avg(rating),2) as avg_rating from amazondata
group by product_line;
## NOTE - Food and beverages receive the highest average rating at 7.11, suggesting strong customer approval,
 ##----while Home and lifestyle, with an average rating of 6.84, indicates a slightly lower satisfaction level.
 ##------Understanding these differences can guide targeted improvements and marketing strategies.


# 15) Count the sales occurrences for each time of day on every weekday.
select dayname, timeofday, count(*) as sales_occurrences from amazondata
where dayofweek(date) between 2 and 6
group by dayname, timeofday
order by timeofday, sales_occurrences desc;
## NOTE - The analysis reveals that Wednesday afternoons observe the highest sales occurrences, 
## followed closely by Thursday and Monday afternoons.
##  Additionally, sales tend to be lower during mornings, especially on Wednesday and Monday.

# 16) Identify the customer type contributing the highest revenue.
select customer_type, sum(total) as total_revenue from amazondata
group by customer_type
order by total_revenue desc limit 1;
## NOTE - The output "Member 164223.44" signifies that the "Member" customer type has generated the highest total revenue

# 17) Determine the city with the highest VAT percentage.
select city, avg(vat / total)* 100 as average_vat_percentage from amazondata
group by city
order by average_vat_percentage desc limit 1;
## NOTE - The result "Mandalay - 4.7619047690043566" indicates that Mandalay has the highest average VAT percentage among the cities in the dataset.
##  The percentage is approximately 4.76.

# 18) Identify the customer type with the highest VAT payments.
select customer_type , sum(VAT) as total_vat_payments from amazondata
group by customer_type
order by total_vat_payments desc limit 1;
## NOTE - THE member customer type with the highest VAT payments and is 7820.16

# 19) What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as num_distinct_customer_types from amazondata;
## NOTE - Their are 2 different distinct customer types in the dataset

# 20) What is the count of distinct payment methods in the dataset?
select count(distinct payment_method) as num_distinct_payment_method from amazondata;
## NOTE - Their are 3 distinct payment methods in the dataset.

# 21) Which customer type occurs most frequently?
select customer_type, count(*) as frequency from amazondata 
group by customer_type
order by frequency desc limit 1;
## NOTE - member customer type occurs most frequently.

# 22) Identify the customer type with the highest purchase frequency.
select customer_type, count(*) as highest_frequency from amazondata
group by customer_type
order by highest_frequency desc limit 1;
## NOTE - Member customer type with the highest purchase frequency and its 501.

# 23) Determine the predominant gender among customers.
select gender, count(*) as gender_count from amazondata
group by gender
order by gender_count desc limit 1;
## NOTE - the predominant gender is Female, and there are 501 occurrences of Female in the dataset.

# 24) Examine the distribution of genders within each branch.
select branch, gender , count(*) as gender_count from amazondata
group by branch, gender
order by branch, gender;
## NOTE - the distribution of genders within each branch, indicating the count of females and males for each branch (A, B, C). 
## The numbers represent the occurrences of each gender within the respective branches.

# 25) Identify the time of day when customers provide the most ratings.
select timeofday, count(*) as rating_occurences from amazondata
group by timeofday
order by rating_occurences desc limit 1;
## NOTE - The analysis reveals that the afternoon is the time of day when customers provide the most ratings.

# 26) Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, count(*) as rating_occurences from amazondata
group by branch, timeofday
order by branch ,rating_occurences desc limit 1 ;
## NOTE - The branch 'A' experiences the highest customer ratings in the afternoon, with 185 occurrences.

# 27) Identify the day of the week with the highest average ratings.
select dayname(date) as day_of_week, avg(rating) as average_rating from amazondata
group by dayname(date)
order by average_rating desc limit 1;
## NOTE - With an average rating of 7.15, Monday has the highest average ratings among all days of the week.

# 28) Determine the day of the week with the highest average ratings for each branch.
select branch, dayname, max(average_rating) as highest_average_rating
from(
     select branch, dayname, avg(rating) as average_rating from amazondata
     group by branch, dayname ) as subquery
     group by branch, dayname;
## NOTE - Result  shows the highest average ratings for each branch on different days of the week.
##  we can interpret this information to understand which days and branches receive the highest average ratings from customers.












 







































   
























    










  








 





 
    
         









