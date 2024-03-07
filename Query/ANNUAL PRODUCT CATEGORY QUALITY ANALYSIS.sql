-- create new table (master table)
-- master table
create table master_table as 
select 
	o.customer_id,
	o.order_id,
	o.order_status,
	o.order_purchase_timestamp,
	pr.product_category_name,
	oi.price,
	oi.freight_value,
	sl.seller_city,
	sl.seller_state,
	op.payment_type,
	op.payment_sequential,
	op.payment_installments,
	op.payment_value,
	oi.price + oi.freight_value as total_price,
	op.payment_sequential * op.payment_value as total_payment_value,
	(op.payment_sequential * op.payment_value) - (oi.price + oi.freight_value) as total_revenue
from orders o join order_items oi on o.order_id = oi.order_id
join order_payments op on oi.order_id = op.order_id
join products pr on oi.product_id = pr.product_id 
join sellers sl on oi.seller_id = sl.seller_id;

-- revenue yoy
select 
	extract(year from order_purchase_timestamp) as year,
	sum(payment_value) as revenue
from
	master_table
where
	order_status = 'delivered'
group by
	1;

-- cancel order
select
	extract(year from order_purchase_timestamp) as year,
	count(*) as total_cancel
from
	master_table
where
	order_status = 'canceled'
group by
	1;

-- top category by revenue yoy
-- create new table (product_revenue_yoy)
create table product_revenue_yoy as
select distinct
	product_category_name,
	extract(year from order_purchase_timestamp) as year,
	sum(payment_value) over(partition by product_category_name, extract(year from order_purchase_timestamp)) as revenue 
from
	master_table
where
	order_status = 'delivered';
-- rank based on revenue
select 
	product_category_name,
	year,
	revenue,
	rank_revenue
from 
	(select 
	 	product_category_name,
		year,
		revenue,
		rank() over(partition by year order by revenue desc)as rank_revenue
	from product_revenue_yoy) as ranked
where
	rank_revenue = 1;

-- total cancel order by product category yoy
-- create new table (product_category_cancel_yoy)
create table product_category_cancel_yoy as
select distinct
	product_category_name,
	extract(year from order_purchase_timestamp) as year,
	count(*) over(partition by product_category_name, extract(year from order_purchase_timestamp)) as total_cancel
from
	master_table
where
	order_status = 'canceled'
order by 
	2 asc, 3 desc;
-- rank based on total cancel
select
	product_category_name,
	year,
	total_cancel,
	rank_cancel
from(
	select
		product_category_name,
		year,
		total_cancel,
		rank() over(partition by year order by total_cancel desc) as rank_cancel
	from 
		product_category_cancel_yoy) as ranked
where
	rank_cancel = 1;

-- concat all
with 
cte_revenue as (
select 
	extract(year from order_purchase_timestamp) as year,
	sum(payment_value) as revenue
from
	master_table
where
	order_status = 'delivered'
group by
	1),
	
cte_cancel_order as(
select
	extract(year from order_purchase_timestamp) as year,
	count(*) as total_cancel
from
	master_table
where
	order_status = 'canceled'
group by
	1),
	
cte_rank_top as(
select 
	product_category_name,
	year,
	revenue,
	rank_revenue
from 
	(select 
	 	product_category_name,
		year,
		revenue,
		rank() over(partition by year order by revenue desc)as rank_revenue
	from product_revenue_yoy) as ranked
where
	rank_revenue = 1),
	
cte_rank_cancel as(
select
	product_category_name,
	year,
	total_cancel,
	rank_cancel
from(
	select
		product_category_name,
		year,
		total_cancel,
		rank() over(partition by year order by total_cancel desc) as rank_cancel
	from 
		product_category_cancel_yoy) as ranked
where
	rank_cancel = 1)
	
select
	cte_revenue.year,
	cte_revenue.revenue,
	cte_cancel_order.total_cancel as total_order_canceled,
	cte_rank_top.product_category_name as top_ranked_product,
	cte_rank_top.revenue as total_revenue_top_rank_product,
	cte_rank_cancel.product_category_name as most_canceled_product,
	cte_rank_cancel.total_cancel as total_top_canceled_product
from cte_revenue 
join cte_cancel_order on cte_revenue.year = cte_cancel_order.year
join cte_rank_top on cte_cancel_order.year = cte_rank_top.year
join cte_rank_cancel on cte_rank_top.year = cte_rank_cancel.year
order by year;