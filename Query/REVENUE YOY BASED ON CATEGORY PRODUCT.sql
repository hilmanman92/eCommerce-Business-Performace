-- revenue based on category product
create table product_revenue_yoy as
select distinct
	product_category_name,
	extract(year from order_purchase_timestamp) as year,
	sum(payment_value) over(partition by product_category_name, extract(year from order_purchase_timestamp)) as revenue 
from
	master_table
where
	order_status = 'delivered';