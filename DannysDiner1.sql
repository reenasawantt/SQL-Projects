CREATE SCHEMA dannys_diner;
use dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(10),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
show tables;

select * from members;
select * from menu;
select * from sales;

select 
	s.customer_id, m.price AS totalprice
FROM sales as s
join menu as m
on s.product_id = m.product_id;

-- First Question
select 
	s.customer_id, sum(m.price) AS totalprice
FROM sales as s
join menu as m
on s.product_id = m.product_id
group by s.customer_id
order by totalprice DESC;

-- Second Question
select customer_id, count(order_date) as total_days_visited
from sales
group by 1;

-- Third Question

WITH result AS
(
	select sales.customer_id, menu.product_name, sales.order_date,
	first_value (sales.product_id) over (partition by customer_id order by order_date  ASC ) as first_menu_item
	from sales
	join menu
	on sales.product_id=menu.product_id
)
select customer_id,product_name,order_date
from result
where first_menu_item=1;

-- Alternative method that's working and right

WITH result AS 
( 
	SELECT s.customer_id , s.order_date , m.product_name , 
	RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC ) AS num_purchase 
	FROM sales s 
	LEFT JOIN menu m 
	ON s.product_id = m.product_id 
) 
SELECT DISTINCT customer_id , order_date , product_name 
FROM result 
WHERE num_purchase = 1 ;

-- Fourth Question

select m.product_name , max(s.product_id) as most_purchased_item
from sales as s
join menu as m
on s.product_id=m.product_id
group by m.product_name, s.product_id
order by max(s.product_id) desc;

-- Right method

SELECT m.product_name , COUNT(s.product_id) AS most_purchased_item 
FROM menu m 
JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY 1 
ORDER BY 2 DESC 
LIMIT 3 ;

-- Fifth Question
with semiresult as
(
	SELECT s.customer_id,m.product_name , COUNT(s.product_id) AS most_purchased_item 
	FROM menu m 
	JOIN sales s 
	ON m.product_id = s.product_id 
	GROUP BY 1 ,2
	
),
result as
(
	select *,
    dense_rank() over (partition by customer_id order by most_purchased_item desc ) as purchaserank
    from semiresult
)
select customer_id, product_name, purchaserank
from result;

-- Check point 

select * from members;
select * from menu;
select * from sales;

-- Sixith Question


with semiresult as
(
	select members.customer_id, s.order_date, m.product_name
	from sales AS s
	join members
	on s.customer_id=members.customer_id
	join menu as M
	on s.product_id=m.product_id
	where s.order_date>join_date 
	order by customer_id, order_date
),
result as
(
select *,
rank() over(partition by customer_id order by order_date) as first_purchase
from semiresult
)
select customer_id,product_name,order_date
from result
where first_purchase=1 ;

-- Seeventh Question

with semiresult as
(
	select members.customer_id, s.order_date, m.product_name
	from sales AS s
	join members
	on s.customer_id=members.customer_id
	join menu as M
	on s.product_id=m.product_id
	where s.order_date<=join_date 
	order by customer_id, order_date
),
result as
(
select *,
rank() over(partition by customer_id order by order_date desc) as last_purchase
from semiresult
)
select customer_id,product_name,order_date
from result
where last_purchase=1 ;

-- Eight Question

with semiresult as
(
	select s.customer_id, s.order_date, s.product_id,m.price
	from sales  AS s
	join members
	on s.customer_id=members.customer_id
	join menu as M
	on s.product_id=m.product_id
	where s.order_date < join_date 
)
select customer_id,count(product_id) as Total_Items, sum(price) as Total_Amount_Spent
from semiresult
group by customer_id;


-- Ninth Question

with semiresult as 
(
	select s.customer_id, s.product_id, m.product_name, m.price,
    case when m.product_name='sushi' then m.price*20 Else m.price*10 End as points
    from sales as s
    join menu as m
    on s.product_id=m.product_id
)
select customer_id, sum(points) as Total_points
from semiresult
group by 1
order by 2 desc;

-- Tenth Question

with semiresult as 
(
	select s.customer_id, s.product_id, m.product_name, m.price, mem.join_date,
	CASE 
		WHEN m.product_name = 'sushi' THEN m.price*2*10 
		WHEN s.order_date >= mem.join_date 
		AND s.order_date < date_add(mem.join_date , interval 1 WEEK) 
		THEN m.price*2*10 ELSE m.price*10 END AS points
    from sales as s
    join menu as m
    on s.product_id=m.product_id
    join members as mem
    on s.customer_id=mem.customer_id
    where s.order_date <= '2021-01-31'
)
select customer_id, sum(points) as Total_points_for_members
from semiresult
group by 1 
order by 2 desc;
	
    


