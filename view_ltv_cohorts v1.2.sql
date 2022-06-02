select
	email,
	product_name,
    currencyisocode as currency_code,
	date_format(min(order_date), '%Y%m') as first_payment_month
from
	(select
		email,
		product_name,
		order_date,
        status,
        type,
        currencyisocode
	from
		view_braintree_transactions
	union all
	select
		billing_address_email,
		product_name,
		order_date,
        status,
        type,
        currency_code
	from
		view_klarna_transactions
	) as tr
where
	status in ('SETTLED', 'SETTLING', 'SUBMITTED_FOR_SETTLEMENT') 
	and type = 'SALE'
group by
	email,
	product_name,
    currency_code