use sakila;



-- 1. Get a table of monthly active customers.

select * from rental;

create or replace view customer_activity as 
	select customer_id as active_customers,
    convert(rental_date,date) as rental_date,
    date_format(convert(rental_date, date), '%m') as activity_month,
	date_format(convert(rental_date, date), '%Y') as activity_year 
    from rental;

select * from customer_activity;

-- step2: create a view to get the total number of active users per month

create or replace view monthly_active_users as
select activity_month, activity_year, count(distinct active_customers) as active_users
from customer_activity
group by activity_month, activity_year
order by activity_month, activity_year;

select * from monthly_active_users;



-- 2. Active users in the previous month.

select * from monthly_active_users;

select activity_year, activity_month, active_users,
lag(active_users) over (partition by activity_year order by activity_month) as last_month_users
from monthly_active_users;



-- 3. Percentage change in the number of active customers.

select * from monthly_active_users;


create or replace view diff_monthly_active_users as
with cte_view as (
	select activity_year, activity_month, active_users,
    lag(active_users) over (partition by activity_year order by activity_month) as last_month_users
    from monthly_active_users
    )
    select activity_year, activity_month, active_users, (((active_users - last_month_users) * 100) / active_users) 
    as '%_monthly_difference'
    from cte_view;

select * from diff_monthly_active_users;

-- 4. Retained customers every month.

create or replace view monthly_active_users_retained as
with cte_view as (
	select activity_year, activity_month, active_users,
    lag(active_users) over (partition by activity_year order by activity_month) as last_month_users
    from monthly_active_users
    )
    select activity_year, activity_month, active_users, (active_users - last_month_users) 
    as users_retained
    from cte_view;

select * from monthly_active_users_retained;