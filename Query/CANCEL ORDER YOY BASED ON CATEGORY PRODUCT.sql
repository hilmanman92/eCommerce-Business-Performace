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