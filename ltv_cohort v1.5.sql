select
	a.first_payment_month,
    a.order_month,
    period_diff(a.order_month, a.first_payment_month) as months_since_joining,
    a.product_name,
    a.currency_code,
    sum(b.amount) as amount,
    min(c.cohort_total_customers) as cohort_total_customers,
    sum(b.amount) / min(c.cohort_total_customers) as avg_cohort_order

from
	(select
		*
	from
		(select distinct product_name from gds_ltv_transactions) as pr
	cross join
		(select distinct order_month from gds_ltv_transactions) as mo
	cross join
		(select distinct order_month as first_payment_month from gds_ltv_transactions) as co
	cross join
		(select distinct currency_code from gds_ltv_transactions) as cu
	where
		co.first_payment_month <= mo.order_month
	) as a
    
left outer join
	(select
		co.first_payment_month,
		tr.order_month,
		tr.product_name,
        tr.currency_code,
		sum(tr.amount) as amount
	from
		gds_ltv_transactions as tr
	left outer join
		gds_ltv_cohorts as co
		on tr.email = co.email
		and tr.product_name = co.product_name
        and tr.currency_code = co.currency_code
	group by
		co.first_payment_month,
		tr.order_month,
		tr.product_name,
        tr.currency_code
	) as b
    on a.first_payment_month = b.first_payment_month
    and a.product_name = b.product_name
    and a.currency_code = b.currency_code

left outer join
	gds_ltv_cohort_totals as c
	on a.first_payment_month = c.first_payment_month
    and a.product_name = c.product_name
    and a.currency_code = c.currency_code

where
	a.order_month >= b.order_month

group by
	a.first_payment_month,
    a.order_month,
	months_since_joining,
	a.product_name,
    a.currency_code

order by
	a.first_payment_month,
    a.product_name,
	a.currency_code,
    a.order_month
