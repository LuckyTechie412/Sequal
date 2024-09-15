# SQL PROJECT 

create database amazone;
use amazone; 
create table order_details (invoice_id VARCHAR(30), 
                            branch VARCHAR(5), 
                            city VARCHAR(30), 
                            customer_type VARCHAR(30), 
                            gender VARCHAR(10), 
                            product_line VARCHAR(100), 
                            unit_price DECIMAL(10, 2), 
                            quantity INT, 
                            VAT FLOAT, 
                            total DECIMAL(10, 2), 
                            order_date DATE, 
                            order_time TIME, 
                            payment_method varchar(25),
                            cogs DECIMAL(10, 2),
                            gross_margin_percentage FLOAT, 
                            gross_income DECIMAL(10, 2), 
                            rating FLOAT    ) ; 

select * from order_details;

#Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
#This will help answer the question on which part of the day most sales are made.

alter table order_details add column time_of_day varchar(30);

update order_details set time_of_day = 
case 
    when order_time < '12:00:00' then 'morning'  
    when order_time < '18:00:00' then 'afternoon'  
    else 'night' 
end ;


#Add a new column named dayname that contains the extracted days of the week 
#on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
#This will help answer the question on which week of the day each branch is busiest.                            

alter table order_details add column day_name varchar(25);

update order_details 
set day_name = dayname(order_date); 


#Add a new column named monthname that contains the extracted months of the year 
#on which the given transaction took place (Jan, Feb, Mar). 
#Help determine which month of the year has the most sales and profit.

alter table order_details add column month_name varchar(30); 

update order_details  
set month_name = monthname(order_date);

select * from order_details;
#Questions 

# 1. What is the count of distinct cities in the dataset?
select count(distinct city) from order_details;
select distinct city from order_details;
#commt - there are 3 distinct city in data 

# 2. For each branch, what is the corresponding city?
select distinct branch, city from order_details order by branch;

# 3. What is the count of distinct product lines in the dataset?
select count(distinct product_line) from order_details;
select distinct product_line from order_details;

#commt - there are 6 product line in data 

# 4. Which payment method occurs most frequently? 
select payment_method, count(payment_method) as num_payment from order_details group by payment_method 
order by num_payment desc #limit 1; 

#commt -- most frequently people used Ewallet and cash than credit card. 

# 5. Which product line has the highest sales?

select product_line, sum(total) as total_sales from order_details 
group by product_line 
order by total_sales desc 
limit 1;

#commt -- food and beverages have the highest sales than sports and travels and others. 

# 6. How much revenue is generated each month?
select month_name, sum(total) as total_sales from order_details 
group by month_name 
order by total_sales desc; 

#commt -- maximum revenue is generated in the month of january followed by march and february 

# 7. In which month did the cost of goods sold reach its peak? 
select month_name, sum(cogs) as total_cogs from order_details 
group by month_name 
order by total_cogs desc 
limit 1;

#commt -- in january the cost of goods reach its peak. 

# 8. Which product line generated the highest revenue?
-- same as question 5 


# 9. In which city was the highest revenue recorded? 
select city, sum(total) as city_revenue from order_details 
group by city 
order by city_revenue desc  
limit 1;

# commt -- in naypyitaw city highest revenue is generated 


# 10. Which product line incurred the highest Value Added Tax?
select product_line, max(vat) as max_vat from order_details 
group by product_line 
order by max_vat desc
limit 1;

-- commt -- Fashion accessories incurred highest vat. 


# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 
select od.product_line, od.total,
case 
    when od.total > avg_data.avg_sales then 'Good' 
    else 'Bad' 
end as sales_type 
from order_details od 
inner join 
           (select product_line, avg(total) as avg_sales from 
            order_details group by product_line ) as avg_data 
on od.product_line = avg_data.product_line;

# 12. Identify the branch that exceeded the average number of products sold.
select od.invoice_id, od.branch from order_details od 
inner join 
          ( select branch, avg(quantity) as avg_qty from order_details group by branch) as avg_data 
on od.branch = avg_data.branch 
where od.quantity > avg_data.avg_qty ;


# 13. Which product line is most frequently associated with each gender?
select product_line, 
count( case when gender = 'male' then 1 end) as male_count, 
count( case when gender = 'female' then 1 end) as female_count 
from order_details 
group by product_line 
order by male_count desc, female_count desc;


with gendercounts as ( 
select product_line, gender, count(gender) as gender_count from order_details 
group by product_line, gender ) , 
maxgendercounts as ( 
select gender, max(gender_count) as max_count from gendercounts 
group by gender ) 
select gc.product_line, mgc.gender, gc.gender_count from gendercounts gc 
inner join maxgendercounts mgc 
on gc.gender = mgc.gender                
and gc.gender_count = mgc.max_count;

#commt -- male are most frequently associated with 'health and beauty' where as female are most frequently associated with 
#'fashion accessories'. although in each product line data is almost similar not much difference between them.

# 14. Calculate the average rating for each product line.
select product_line, avg(rating) as avg_rating from order_details 
group by product_line
order by avg_rating desc;


# 15. Count the sales occurrences for each time of day on every weekday.
select  time_of_day, order_time, 
count(total) over( partition by time_of_day order by order_date range between interval '7' day preceding and current row) 
from order_details  ;

select day_name, time_of_day, count(invoice_id) as sales_occurences , sum(quantity) as total_qty_sold from order_details 
group by day_name, time_of_day  
order by sales_occurences desc ; 

# commt -- most of the sales occur during afternoon of every day.

# 16. Identify the customer type contributing the highest revenue.
select customer_type, sum(total) as total_rev from order_details 
group by customer_type  
order by total_rev desc
limit 1 ;

# commt -- highest revenue is contributed by 'member' . although there is not much difference between 
#contribytion of both the customer type

# 17. Determine the city with the highest VAT percentage.
select city, (max(vat) * 100) / sum(vat)  as highest_vat_percentage from order_details 
group by city 
order by highest_vat_percentage desc 
limit 1 ;

# commt -- Naypyitaw has the highest vat percentage among all the cities.  


# 18. Identify the customer type with the highest VAT payments.
select customer_type, sum(vat) as highest_vat_payment from order_details 
group by customer_type 
order by highest_vat_payment desc 
limit 1; 

# commt -- member paid the highest vat 


# 19. What is the count of distinct customer types in the dataset? 
select count( distinct customer_type) as count_of_customer_type from order_details;
 

# 20. What is the count of distinct payment methods in the dataset? 
select count(distinct payment_method) as count_of_payment_method from order_details; 


# 21. Which customer type occurs most frequently? 
select customer_type, count(customer_type) as count_of_customer_type from order_details 
group by customer_type; 

# commt -- member ocuurs most frequently followed by normal. although almost similar members are there in both the customer type.

# 22. Identify the customer type with the highest purchase frequency.
select customer_type, count(invoice_id) as purchase_frequency from order_details 
group by customer_type
order by purchase_frequency desc 
limit 1;


# 23. Determine the predominant gender among customers.
select customer_type, gender, count(gender) as gender_count from order_details 
group by customer_type, gender 
order by gender_count desc;


# commt -- in member female is predominant and in normal male is predominant customer.



with gendercounts as (
select customer_type, gender, count(*) as gender_count from order_details 
group by customer_type, gender ) , 
prominentgender as ( 
select customer_type, gender, gender_count, 
rank() over( partition by customer_type order by gender_count desc) as gender_rank 
from gendercounts ) 
select * from prominentgender 
where gender_rank = 1;







# 24. Examine the distribution of genders within each branch. 
select branch, gender, count(*) from order_details 
group by branch, gender
order by branch, count(*) desc

# commt -- in branch A and B distribution of male is more compare to female and in branch c distribution of female is more 
-- compare to male


# 25. Identify the time of day when customers provide the most ratings. 
select time_of_day, count(rating) as rating_count from order_details 
group by time_of_day
order by rating_count desc;

select time_of_day, count(rating) as rating_count from order_details 
where rating = 10
group by time_of_day
order by rating_count desc;

# commt -- during afternoon most of the customer provide the highest rating. 

select time_of_day, count(rating) as rating_count from order_details 
group by time_of_day
order by rating_count desc 
having rating = (select max(rating) from order_details group by time_of_day);


with maxratings as ( 
select time_of_day, max(rating) as max_rating from order_details 
group by time_of_day ), 
ratingcounts as ( 
select od.time_of_day, count(od.rating) as rating_count from order_details od 
inner join maxratings mr 
on od.time_of_day = mr.time_of_day 
and od.rating = mr.max_rating 
group by od.time_of_day ) 
select time_of_day, rating_count from ratingcounts 
order by rating_count desc; 
    
    
# 26. Determine the time of day with the highest customer ratings for each branch.
select branch, time_of_day, count(rating) as rating_count from order_details 
group by branch, time_of_day 
order by branch, rating_count desc; 

# commt -- in all branches afternoon is the time when most of the customers give  rating



# 27. Identify the day of the week with the highest average ratings. 
select day_name, avg(rating) as avg_rating from order_details 
group by day_name 
order by avg_rating desc 
limit 1 ;


# 28. Determine the day of the week with the highest average ratings for each branch. 
select branch, day_name, avg(rating) as avg_rating from order_details 
group by branch, day_name 
order by branch, avg_rating desc;




## Analysis 

# Product Analysis
select product_line, sum(quantity) total_qty_sold from order_details 
group by product_line
order by total_qty_sold desc;

-- commt -- maximum selling product is 'electronic accessories' followed by 'Food and beverages' and others.

select city, product_line, sum(quantity) as total_qty_sold from order_details 
group by city, product_line
order by total_qty_sold desc;

with ordercity as ( 
select city, product_line, sum(quantity) as total_qty_sold from order_details 
group by city, product_line 
order by total_qty_sold desc ) , 
prominantproduct as (
select city, product_line, total_qty_sold, 
rank() over (partition by city order by total_qty_sold desc) as city_rank 
from ordercity ) 
select city, product_line, total_qty_sold from prominantproduct 
where city_rank = 1;

#commt -- in Mandalay 'Sports and travel' is the most selling product line where as in 
#Naypyitaw 'Food and beverages' and in Yangon 'Home and lifestyle'  is the most selling. 

with ordercity as ( 
select city, product_line, sum(quantity) as total_qty_sold from order_details 
group by city, product_line 
order by total_qty_sold desc ) , 
prominantproduct as (
select city, product_line, total_qty_sold, 
rank() over (partition by city order by total_qty_sold ) as city_rank 
from ordercity ) 
select city, product_line, total_qty_sold from prominantproduct 
where city_rank = 1;

# commt -- in Mandalay 'Food and beverages' is the least selling product line where as in 
#Naypyitaw 'Home and lifestyle' and in Yangon 'Health and beauty'  is the least selling.

select product_line, sum(gross_income) as total_gross_income from order_details 
group by product_line 
order by total_gross_income desc;

# commt -- 'Food and beverages' is the most profitable product_line as per gross income followed by 'Sports and travel' and others
# and 'Health and beauty' is the least profitable product line. 



## Sales Analysis

select product_line, sum(gross_income) as total_gross_income from order_details 
group by product_line 
order by total_gross_income desc;

# commt -- 'Food and beverages' is the most profitable product_line as per gross income followed by 'Sports and travel' and others
# and 'Health and beauty' is the least profitable product line. 


## Customer Analysis

select customer_type, sum(quantity) as total_qty from order_details 
group by customer_type 
order by total_qty desc;

# commt -- member's are purchasing more products compare to normal customers 

select customer_type, sum(gross_income) as total_gross_income from order_details 
group by customer_type 
order by total_gross_income desc;

# commt -- most of profit is coming from members

select customer_type, product_line, count(*) as total_count from order_details 
group by customer_type, product_line
order by total_count desc;

# commt -- members are more purchasing 'Food and beverages' where as normal customers are most purchasing 'Electronic accessories'
#and members are least purchasing 'Health and beauty' and normal are 'Home and lifestyle'.
