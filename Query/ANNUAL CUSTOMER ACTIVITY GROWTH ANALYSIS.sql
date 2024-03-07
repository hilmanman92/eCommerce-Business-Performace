-- monthly active user in year
select year, floor(avg(total_customer)) as monthly_active_user
from (
        select extract(
                month
                from order_purchase_timestamp
            ) as month, extract(
                year
                from order_purchase_timestamp
            ) as year, count(distinct customer_unique_id) as total_customer
        from orders
            join customers on orders.customer_id = customers.customer_id
        group by
            extract(
                month
                from order_purchase_timestamp
            ), extract(
                year
                from order_purchase_timestamp
            )
        order by 2 asc, 1 asc
    ) as sq1
group by
    year;

-- total new customer
select year, sum(total_orders) as total_new_customer
from (
        select extract(
                year
                from orders.order_purchase_timestamp
            ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
        from orders
            join customers on orders.customer_id = customers.customer_id
        group by
            1, 2
    ) as sq2
where
    total_orders = 1
group by
    year;

-- total repeat customer
select year, sum(total_orders) as total_repeat_customer
from (
        select extract(
                year
                from orders.order_purchase_timestamp
            ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
        from orders
            join customers on orders.customer_id = customers.customer_id
        group by
            1, 2
    ) as sq3
where
    total_orders > 1
group by
    year;

-- avg frequency
select year, round(avg(total_orders),2) as average_orders
from (
        select extract(
                year
                from order_purchase_timestamp
            ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
        from orders
            join customers on orders.customer_id = customers.customer_id
        group by
            1, 2
    ) as sq4
group by
    year;

-- concat all
with
    cte1 as (
        select year, floor(avg(total_customer)) as monthly_active_user
        from (
                select extract(
                        month
                        from order_purchase_timestamp
                    ) as month, extract(
                        year
                        from order_purchase_timestamp
                    ) as year, count(distinct customer_unique_id) as total_customer
                from orders
                    join customers on orders.customer_id = customers.customer_id
                group by
                    extract(
                        month
                        from order_purchase_timestamp
                    ), extract(
                        year
                        from order_purchase_timestamp
                    )
                order by 2 asc, 1 asc
            ) as sq1
        group by
            year
    ),
    cte2 as (
        select year, sum(total_orders) as total_new_customer
        from (
                select extract(
                        year
                        from orders.order_purchase_timestamp
                    ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
                from orders
                    join customers on orders.customer_id = customers.customer_id
                group by
                    1, 2
            ) as sq2
        where
            total_orders = 1
        group by
            year
    ),

cte3 as (
    select year, sum(total_orders) as total_repeat_customer
    from (
            select extract(
                    year
                    from orders.order_purchase_timestamp
                ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
            from orders
                join customers on orders.customer_id = customers.customer_id
            group by
                1, 2
        ) as sq3
    where
        total_orders > 1
    group by
        year
),

cte4 as (
    select year, round(avg(total_orders),2) as average_orders
    from (
            select extract(
                    year
                    from order_purchase_timestamp
                ) as year, customers.customer_unique_id, count(orders.order_id) as total_orders
            from orders
                join customers on orders.customer_id = customers.customer_id
            group by
                1, 2
        ) as sq4
    group by
        year
)

select
    cte1.year,
    monthly_active_user,
    total_new_customer,
    total_repeat_customer,
    average_orders,
	round(monthly_active_user/total_new_customer,2)*100 as ratio_monthly_active_user,
	round(total_repeat_customer/total_new_customer,2)*100 as ratio_repeat_order
from
    cte1
    join cte2 on cte1.year = cte2.year
    join cte3 on cte2.year = cte3.year
    join cte4 on cte3.year = cte4.year;