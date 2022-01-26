LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_data_set.csv'
INTO TABLE sales_joan
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

select * from sales_joan;

alter table sales_joan add column new_date date;
update sales_joan set new_date = str_to_date(Date,'%d/%m/%Y');

/*
Dataset information: 
- store: the store code
- dept: the department code
- date: the date of the first day of the week
- weekly_sales: sales of the week for the store and dept

### The challenge
The objective of this exercise is to analyze the performance of different stores ('store') and departments ('dept').

For each question, include both your answer to the question and the query you used to arrive at the answer.
*/
-- Exercise 1: Let's consider store 20
-- 1.1. What were the total sales of this store? -- "301397792.45999974"
select store, sum(Weekly_Sales) as total_sales from sales_joan
where store = 20;

-- 1.2. What were the total sales for department 51 (store 20)? -- "161.18"
select Store, sum(Weekly_Sales) as total_sales from sales_joan
where Store = 20
	and Dept = 51;

-- 1.3.1. In which week did store 20 achieve a sales record? How much turnover did they get? -- 26/11/2010  //  "422306.25"
select * from sales_joan
where Store = 20
order by Weekly_sales desc;

-- 1.3.2. Y la peor semana ? De cuanto fue la facturación ? -- 30/12/2011  //  "-798"
select * from sales_joan
where Store = 20
order by Weekly_sales asc;

-- 1.4. What is the historical average of total weekly sales for store 20? -- "100465930.82000007"
with ctt as(select sum(Weekly_Sales) as total_year, year(new_date) as historical_denominator from sales_joan
where Store = 20
group by year(new_date))
select sum(total_year)/count(historical_denominator) as historical_avg from ctt;

-- 1.5. What are the 10 stores that have the best historical average of weekly sales?
-- 	store	historical_avg
-- 	20	100465930.82000007
-- 	4	99847984.45999996
-- 	14	96333303.78000017
-- 	13	95505901.26666664
-- 	2	91794146.99333328
-- 	10	90539237.96333332
-- 	27	84618638.96000011
-- 	6	74585376.87999998
-- 	1	74134269.6166666
-- 	39	69148514.15666665
with ctt as(select store, sum(Weekly_Sales) as total_year, year(new_date) as historical_denominator from sales_joan
group by store, year(new_date))
select store, sum(total_year)/count(historical_denominator) as historical_avg from ctt
group by store
order by historical_avg desc
limit 10;

-- Exercise 2
-- The next objective is to detect the 'worst performing departments'. Specifically, we are interested in finding the departments that are farthest from the average sales of the store to which they belong.

-- 2.1. What were the total sales for department 51 of store 20? -- "161.18"
select Store, sum(Weekly_Sales) as total_sales from sales_joan
where Store = 20
	and Dept = 51;

-- 2.2. And the sales of the best and worst department of store 20? Which departments had fewer sales than dept 51? - Department 92 was the best one and departments 78 and 47 had fewer sales.
select dept, store, sum(Weekly_Sales) as total_sales from sales_joan
where store = 20 
group by dept
order by sum(Weekly_Sales) desc;

-- 2.3. How much did store 20 sell per department on average? (A number is requested as a result) -- "27057.53006296206"
with ctt as (select dept, store, avg(Weekly_Sales) as avg_sales from sales_joan
where store = 20
group by dept)
select store, avg(avg_sales) from ctt;
----------------------------------------------------------------------------------------------------------------------------
with ctt as (select dept, store, sum(Weekly_Sales) as total_sales from sales_joan -- "3864074.262307692"
where store = 20
group by dept)
select store, avg(total_sales) from ctt;

-- 2.4. What is the difference of the total sales of each department with respect to the average sales per department of store 20? What are the three worst departments in store 20?
-- 	store	dept	difference
-- 	20	47	-27436.110062962063
-- 	20	78	-27028.53006296206
-- 	20	51	-26896.35006296206
    
select store, dept,  (sum(Weekly_Sales) - (select avg(avg_sales) from (select dept, avg(Weekly_Sales) as avg_sales from sales_joan
where store = 20
group by dept) temp )) as difference 
from sales_joan
where store = 20  
group by dept
order by difference;
----------------------------------------------------------------------------------------------------------------------------------
-- 	store	dept	difference
-- 20	47	-3864452.842307692
-- 20	78	-3864045.262307692
-- 20	51	-3863913.0823076917

select store, dept,  (sum(Weekly_Sales) - (select avg(total_sales) from (select dept, sum(Weekly_Sales) as total_sales from sales_joan
where store = 20
group by dept) temp )) as difference 
from sales_joan
where store = 20  
group by dept
order by difference
limit 3;


-- 2.5. Finally, which are the 10 worst department-stores, considering the performance metric from the previous year,
-- that is, the difference of a department's sales with respect to the average sales per department of the corresponding store.

#average sales of department of the corresponding store 
-- select store, dept, avg(Weekly_Sales) as avg_sales from sales_joan 
-- group by store, dept - a template for average dept of store

-- select store, avg(avg_sales) as avrg - template for store 

# 10 worst overall
-- Year Store Dept Department_sum Store_average Difference
-- 2011	4	47		70				1481230.5777333337	-1481160.5777333337
-- 2011	4	45		283.72			1481230.5777333337	-1480946.8577333337
-- 2011	4	77		1158			1481230.5777333337	-1480072.5777333337
-- 2011	4	54		4116			1481230.5777333337	-1477114.4977333336
-- 2011	4	99		19518.5			1481230.5777333337	-1461712.0777333337
-- 2011	4	60		21634.7			1481230.5777333337	-1459595.8777333337
-- 2011	4	28		50537.6			1481230.5777333337	-1430692.9877333336
-- 2011	4	41		51237			1481230.5777333337	-1429993.5077333336
-- 2011	20	47		-622.6			1426454.5761038961	-1427077.1561038962
-- 2011	20	96		-2.5			1426454.5761038961	-1426457.0561038961

with ctt as(select years, store, avg(avg_sales) as avrg from (select Year(new_date) as years, store, dept, sum(Weekly_Sales) as avg_sales from sales_joan group by Year(new_date), store, dept HAVING years = 2011)temp GROUP BY Store)
select YEAR(new_date), store, dept,  sum(Weekly_Sales) as department_sum, (select avrg from ctt where ctt.store = s.Store) as store_average, (sum(weekly_sales) - (select avrg from ctt where ctt.store = s.Store) ) as difference from sales_joan s
WHERE YEAR(new_date) = 2011
group by Year(new_date), store, dept
order by difference
limit 10;

-- What do you think about the department performance metric used? Could it be measured in some other more appropriate way?






