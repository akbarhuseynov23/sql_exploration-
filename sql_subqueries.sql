 -- Select all the products from the health_beauty or perfumery categories that
# have been paid by credit card with a payment amount of more than 1000$,
# from orders that were purchased during 2018 and have a ‘delivered’ status?
USE magist;

with ctt as (select o.order_id, o.order_status, o.order_purchase_timestamp, op.payment_type, op.payment_value, oi.product_id, pcnt.product_category_name_english from orders o
join order_payments op on o.order_id = op.order_id
join order_items oi on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
join product_category_name_translation pcnt on p.product_category_name = pcnt.product_category_name 
where product_category_name_english in ("health_beauty","perfumery")
    and payment_type = "credit_card"
	and round(payment_value > 1000) 
    and year(order_purchase_timestamp) = "2018" 
    and order_status = "delivered")
select ctt.product_id
FROM ctt;


# The average weight of those products
with ctt as (select o.order_id, o.order_status, o.order_purchase_timestamp, op.payment_type, op.payment_value, oi.product_id, pcnt.product_category_name_english, p.product_weight_g from orders o
join order_payments op on o.order_id = op.order_id
join order_items oi on o.order_id = oi.order_id
join products p on p.product_id = oi.product_id
join product_category_name_translation pcnt on p.product_category_name = pcnt.product_category_name 
where product_category_name_english in ("health_beauty","perfumery")
    and payment_type = "credit_card"
	and round(payment_value > 1000) 
    and year(order_purchase_timestamp) = "2018" 
    and order_status = "delivered")
select avg(ctt.product_weight_g) from ctt;


# The cities where there are sellers that sell those products
with ctt as (select g.city from orders o
join order_payments op on o.order_id = op.order_id
join order_items oi on o.order_id = oi.order_id
join sellers s on oi.seller_id=s.seller_id
join geo g on s.seller_zip_code_prefix=g.zip_code_prefix
join products p on p.product_id = oi.product_id
join product_category_name_translation pcnt on p.product_category_name = pcnt.product_category_name 
where product_category_name_english in ("health_beauty","perfumery")
    and payment_type = "credit_card"
	and round(payment_value > 1000) 
    and year(order_purchase_timestamp) = "2018" 
    and order_status = "delivered")
select distinct ctt.city from ctt;


# The cities where there are customers who bought products
with ctt as (select g.city from orders o
    join order_payments op on o.order_id = op.order_id
    join order_items oi on o.order_id = oi.order_id
    join products p on p.product_id = oi.product_id
    join product_category_name_translation pcnt on p.product_category_name = pcnt.product_category_name 
    join customers c on o.customer_id = c.customer_id
    join geo g on c.customer_zip_code_prefix = g.zip_code_prefix
    where product_category_name_english in ("health_beauty","perfumery")
    and payment_type = "credit_card"
	and round(payment_value > 1000) 
    and year(order_purchase_timestamp) = "2018" 
    and order_status = "delivered")
select distinct ctt.city from ctt;
