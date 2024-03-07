select 
	extract(year from order_purchase_timestamp) as year,
	sum(case when payment_type = 'boleto' then 1 else 0 end) as boleto,
	sum(case when payment_type = 'debit_card' then 1 else 0 end) as debit_card,
	sum(case when payment_type = 'voucher' then 1 else 0 end) as voucher,
	sum(case when payment_type = 'credit_card' then 1 else 0 end) as credit_card
from
	master_table
where
	order_status = 'delivered'
group by
	1
order by
	1;