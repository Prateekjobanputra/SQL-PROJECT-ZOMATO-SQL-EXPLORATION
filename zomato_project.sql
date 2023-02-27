 create database zomato;
use zomato;


CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) VALUES (1, '2017-09-22'), (3, '2017-04-21');


CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) VALUES (1,'2014-09-02'), (2, '2015-01-15'), (3, '2014-04-11');


CREATE TABLE sales(userid integer,created_date date,product_id integer);

 INSERT INTO sales(userid,created_date,product_id) VALUES (1, '2017-04-19', 2), (3, '2019-12-18', 1), (2, '2020-07-20', 3), (1, '2019-10-23', 2);
 INSERT INTO sales(userid,created_date,product_id) VALUES (1, '2018-03-19', 3), (3, '2016-12-20', 2), (1, '2016-11-09', 1), (1, '2016-05-20', 3), 
 (2, '2017-09-24', 1), (1, '2017-03-11', 2), (1, '2016-03-11', 1), (3, '2016-11-10', 1), (3, '2017-12-07', 2), (3, '2016-12-15', 2), (2, '2017-11-08', 2), (2, '2018-09-10', 3);
 
 CREATE TABLE product(product_id integer,product_name text,price integer);
 INSERT INTO product(product_id,product_name,price) VALUES (1,'p1',980), (2,'p2',870), (3,'p3',330);
 
 select * from sales; 
select * from product;
 select * from goldusers_signup; 
select * from users;


Q1)...What is the total amount each customer spend on zomato...?

select s.userid, sum(p.price) total_amount_spend
from sales s inner join product p on s.product_id = p.product_id
group by userid;


Q2)...How any days has each customer visited zomato...?

select userid, count(distinct created_date) no_of_days from sales 
group by userid;


Q3)...first product purchase by customer...?

select a.* from
(select *, rank() over (partition by userid order by created_date) ranking from sales) a
where ranking = 1;


Q4)...What is the most purchase item on menu and how many time was it purchase by all customer...?

select userid, product_id, count(product_id) from sales where product_id = 
(select product_id from sales
group by product_id
order by count(product_id) desc limit 1)
group by userid;


Q5)...Which item most famous for each customer...?

select b.* from
(select a.*, rank() over (partition by userid order by counting desc ) ranking from
( select userid, product_id, count(product_id) counting from sales
group by product_id, userid ) a ) b
where b.ranking = 1;


Q6)...Which item was first purchase by customer after they become member...?

select b.* from
(select a.*, rank() over (partition by userid order by created_date) ranking from
(select s.*, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date) a) b
where ranking = 1;


Q7)...Which item was purchase just before the customer become member...?

select b.* from
(select a.*, rank() over (partition by userid order by created_date desc) ranking from
(select s.*, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid and created_date <= gold_signup_date)a) b
where ranking = 1;


Q8)...What is the total order and amount spend by each member before they become member...?

select b.userid, count(b.created_date) counting, sum(b.price) from 
(select a.*, p.price from
( select s.*, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid and created_date <= gold_signup_date ) a 
inner join product p on a.product_id = p.product_id ) b
group by userid;


Q9)...If buying each product generate points for eg- 5Rs = 2 zomato point and each product as different purchasing point  for 
eg-for P1 5rs = 1 zomato point for P2 10rs = 5 zomato point and P3 5rs = 1 zomato point  2Rs = 1 zomato point....?
calculate point collected by each customer and for which product most point have been given till now...?

 select userid, sum(total_point)*2.5 total_point_earn from
(select c.*, total_price/points total_point from 
(select b.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
( select a.userid, a.product_id, sum(a.price) total_price from
(select s.userid, s.product_id, p.price from sales s inner join product p on s.product_id = p.product_id) a
group by userid, product_id ) b ) c ) d
group by userid;


select * from 
(select e.*, rank() over (order by total_point_earn desc) ranking from
( select d.product_id , sum(d.total_point) total_point_earn from
(select c.*, total_price/points total_point from 
(select b.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
( select a.userid, a.product_id, sum(a.price) total_price from
(select s.userid, s.product_id, p.price from sales s inner join product p on s.product_id = p.product_id) a
group by userid, product_id ) b ) c ) d
group by product_id ) e ) f
where ranking = 1;


Q10)...In the first  year after the customer  join the gold program ( including  their joining date) irrespective of 
what the customer as purchase they earn 5 zomato point for every 10Rs spend Who earn more 1 or 3 
and what was their point earning in their first year...? 

select b.userid, b.price, b.price/2 total_points from
( select a.*, p.price from
( select s.*, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date 
and created_date <= adddate(gold_signup_date, interval 1 year) ) a
inner join product p on p.product_id = a.product_id ) b;


Q11)...Rank all the transaction of customers...?

select *, rank() over ( partition by userid order by created_date) rnk from sales;

Q12)...Rank all the transaction for each member whenever they are a zomato gold member for every non gold member transaction mark as 'na'...?

select a.*, case when a.gold_signup_date is null then 'na' else rank() over (partition by userid order by created_date desc) end  as rnk from
( select s.userid, s.created_date, s.product_id, g.gold_signup_date 
from sales s left join goldusers_signup g on s.userid = g.userid
and created_date >= gold_signup_date ) a;



























