-- table of cancel order
create table cancel_order as
select *
from master_table
where order_status = 'canceled';