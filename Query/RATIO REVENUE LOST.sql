-- ratio revenue lost
with
cte_real_revenue as (
select extract(year from order_purchase_timestamp) as year, sum(payment_value) as real_revenue
from master_table where order_status = 'delivered' group by 1),

cte_expected_revenue as (
select extract(year from order_purchase_timestamp) as year, sum(payment_value) as expect_revenue
from master_table where order_status in ('delivered','canceled') group by 1),

cte_lost_revenue as (
select extract(year from order_purchase_timestamp) as year, sum(payment_value) as lost_revenue
from master_table where order_status = 'canceled' group by 1 order by 1 asc)

select
	crr.year,
	crr.real_revenue,
	cer.expect_revenue,
	clr.lost_revenue,
	round(clr.lost_revenue / cer.expect_revenue * 100,2) as ratio_lost_revenue
from cte_real_revenue crr 
join cte_expected_revenue cer on crr.year = cer.year 
join cte_lost_revenue clr on cer.year = clr.year
order by 1;