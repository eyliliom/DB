drop table if exists customer
create table customer (
    customer_id INT4 primary key,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(30),
    DOB VARCHAR(50),
    job_title VARCHAR(50),
    job_industry_category VARCHAR(50),
    wealth_segment VARCHAR(50),
    deceased_indicator VARCHAR(50),
    owns_car VARCHAR(30),
    address VARCHAR(50),
    postcode VARCHAR(30),
    state VARCHAR(30),
    country VARCHAR(30),
    property_valuation INT4
)

drop table if exists transaction
create table transaction (
    transaction_id INT4 primary key,
    product_id INT4,
    customer_id INT4 references customer(customer_id),
    transaction_date VARCHAR(30),
    online_order VARCHAR(30),
    order_status VARCHAR(30),
    brand VARCHAR(30),
    product_line VARCHAR(30),
    product_class VARCHAR(30),
    product_size VARCHAR(30),
    list_price FLOAT4,
    standard_cost FLOAT4
)

-- Перед загрузкой удалены несколько наблюдений, чтобы не было нарушений условия ключа
-- Если бы таблицы создавались без ключей, то удалённые данные можно было бы вывести следующим способом:
select * from transaction t where t.customer_id = 5034

-- Данные по customer загружены
select *
from customer c;

-- Данные по transaction загружены
select *
from transaction t;

-- Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества

select c.job_industry_category, count(c.customer_id) 
from customer c
group by c.job_industry_category
order by count(c.customer_id) desc

-- Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности

-- Так как данные в таблице только за 2017 год, можно месяц выводить цифрой и не перегружать таблицу
select extract (month from to_date(t.transaction_date, 'DD.MM.YYYY')), c.job_industry_category, sum(t.list_price)
from customer c
join transaction t on c.customer_id = t.customer_id
group by extract (month from to_date(t.transaction_date, 'DD.MM.YYYY')),c.job_industry_category
order by extract (month from to_date(t.transaction_date, 'DD.MM.YYYY')),c.job_industry_category

-- Вариант, если бы данные были за несколько лет
select date_trunc('month', to_date(t.transaction_date, 'DD.MM.YYYY')) as month, c.job_industry_category,  sum(t.list_price)
from customer c
join transaction t on c.customer_id = t.customer_id
group by month, c.job_industry_category
order by month,c.job_industry_category

-- Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT

select t.brand, count(t.transaction_id)
from customer c
join transaction t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT' and t.order_status = 'Approved' and t.online_order = 'True'
group by t.brand
order by t.brand

-- Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, отсортировав 
-- результат по убыванию суммы транзакций и количества клиентов. Выполните двумя способами: используя только group by 
-- и используя только оконные функции. Сравните результат

-- 1 вариант (group by)
select c.customer_id, sum(t.list_price), max(t.list_price),
	min(t.list_price), count(t.transaction_id)
from customer c
join transaction t on c.customer_id = t.customer_id
group by c.customer_id 
order by sum(t.list_price) desc, count(t.transaction_id) desc

-- Count выдаёт 3493 строки
select count(*)
from
	(select c.customer_id, sum(t.list_price), max(t.list_price),
		min(t.list_price), count(t.transaction_id)
	from customer c
	join transaction t on c.customer_id = t.customer_id
	group by c.customer_id 
	order by sum(t.list_price) desc, count(t.transaction_id) desc)


-- 2 вариант (оконные функции)
select c.customer_id,
	sum(t.list_price) over (partition by c.customer_id),
	max(t.list_price) over (partition by c.customer_id),
	min(t.list_price) over (partition by c.customer_id),
	count(t.transaction_id) over (partition by c.customer_id)
from customer c
join transaction t on c.customer_id = t.customer_id
order by sum(t.list_price) over (partition by c.customer_id) desc,
	count(t.transaction_id) over (partition by c.customer_id) desc
	
-- Count выдаёт 19997 строк
select count(*)
from
	(select c.customer_id,
		sum(t.list_price) over (partition by c.customer_id),
		max(t.list_price) over (partition by c.customer_id),
		min(t.list_price) over (partition by c.customer_id),
		count(t.transaction_id) over (partition by c.customer_id)
	from customer c
	join transaction t on c.customer_id = t.customer_id
	order by sum(t.list_price) over (partition by c.customer_id) desc,
		count(t.transaction_id) over (partition by c.customer_id) desc)

-- Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не 
-- может быть null). Напишите отдельные запросы для минимальной и максимальной суммы
	
-- Максимальная сумма
with ss as	
	(select distinct c.customer_id,c.first_name, c.last_name,
		coalesce(sum(t.list_price)
		over (partition by c.customer_id), 0) as transaction_sum
	from customer c
	left join transaction t on c.customer_id = t.customer_id)
select * from ss
where ss.transaction_sum = (select max(ss.transaction_sum) from ss)

-- Минимальная сумма
with ss as
	(select distinct c.customer_id, c.first_name, c.last_name,
		coalesce(sum(t.list_price)
		over (partition by c.customer_id), 0) as transaction_sum
	from customer c
	left join transaction t on c.customer_id = t.customer_id)
select * from ss
where ss.transaction_sum = (select min(ss.transaction_sum) from ss)


-- Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций
-- В ходе анализа обнаружено, что transaction_id увеличиваются не в хронологическом порядке, поэтому
-- первые транзакции считаются по дате. В выводе приведены transaction_id и transaction_date.

with tt as
	(select c.customer_id, t.transaction_id, t.transaction_date,
		first_value(to_date(t.transaction_date, 'DD.MM.YYYY'))  
		over (partition by c.customer_id order by to_date(t.transaction_date, 'DD.MM.YYYY') asc) as first_transaction_date
	from customer c
	join transaction t on c.customer_id = t.customer_id)
select * from tt
where to_date(tt.transaction_date, 'DD.MM.YYYY') = tt.first_transaction_date



-- Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал 
-- вычисляется в днях)
with ss as
	(select c.customer_id, c.first_name, c.last_name, c.job_title,
		coalesce(lead(to_date(t.transaction_date, 'DD.MM.YYYY')) 
		over (partition by c.customer_id  order by to_date(t.transaction_date, 'DD.MM.YYYY') asc) - 
		to_date(t.transaction_date, 'DD.MM.YYYY'), 0) as diff
	from customer c
	join transaction t on c.customer_id = t.customer_id)
select * from ss
where ss.diff = (select max(ss.diff) from ss)

