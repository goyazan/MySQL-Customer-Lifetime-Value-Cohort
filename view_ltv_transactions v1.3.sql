select
	email,
	product_name,
	date_format(order_date, '%Y%m') as order_month,
    currencyisocode as currency_code,
	sum(amount) as amount
from
	(select
		email,
		product_name,
		order_date,
        status,
        type,
        currencyisocode,
		amount
	from
		view_braintree_transactions
	union all
	select
		billing_address_email,
		product_name,
		order_date,
        status,
        type,
        currency_code,
		amount
	from
		view_klarna_transactions
	) as tr
where
	status in ('SETTLED', 'SETTLING', 'SUBMITTED_FOR_SETTLEMENT') 
	and type = 'SALE'
group by
	email,
	product_name,
	order_month,
    currency_code