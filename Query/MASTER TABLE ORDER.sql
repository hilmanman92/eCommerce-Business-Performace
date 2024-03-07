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