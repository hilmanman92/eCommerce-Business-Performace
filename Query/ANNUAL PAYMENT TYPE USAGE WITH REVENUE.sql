with cte_payment as (
select 
	extract(year from order_purchase_timestamp) as year,
	sum(case when payment_type = 'boleto' then 1 else 0 end) as boleto,
	sum(case when payment_type = 'boleto' then payment_value else 0 end) as boleto_values,
	sum(case when payment_type = 'debit_card' then 1 else 0 end) as debit_card,
	sum(case when payment_type = 'debit_card' then payment_value else 0 end) as debit_card_values,
	sum(case when payment_type = 'voucher' then 1 else 0 end) as voucher,
	sum(case when payment_type = 'voucher' then payment_value else 0 end) as voucher_values,
	sum(case when payment_type = 'credit_card' then 1 else 0 end) as credit_card,
	sum(case when payment_type = 'credit_card' then payment_value else 0 end) as credit_card_values
from
	master_table
where
	order_status = 'delivered'
group by
	1
order by
	1)
	
select 
	year,
	boleto, boleto_values, round(boleto_values/boleto,2) as boleto_per_transaction,
	debit_card, debit_card_values, round(debit_card_values/debit_card,2) as debit_card_per_transaction,
	voucher, voucher_values, round(voucher_values/voucher,2) as voucher_per_transaction,
	credit_card, credit_card_values, round(credit_card_values/credit_card,2) as credit_card_per_transaction,
	boleto_values + voucher_values + debit_card_values + credit_card_values as total_payment_values
from cte_payment;