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

-- 1 Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.

select distinct t.brand
from transaction t
where t.standard_cost > 1500

-- 2 Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.

select *
from transaction
where order_status = 'Approved' and
      to_date(transaction_date, 'DD.MM.YYYY') between '2017-04-01' and '2017-04-09'

-- 3 Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.
-- Считаю уникальные профессии, так как в контексте задачи это имеет больше смысла.

select distinct job_title
from customer
where job_industry_category in ('IT', 'Financial Services')
      and job_title like 'Senior%'
      
-- 4 Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services.
-- Считаю, что в контексте задачи нужно выводить только уникальные бренды

-- Способ 1, через подзапрос. 
select distinct t.brand 
from transaction t
where customer_id in (select c.customer_id from customer c where c.job_industry_category = 'Financial Services')
  
-- Способ 2, через join, здесь также не выводила пустые строки.
select distinct t.brand
from transaction t
join customer c on t.customer_id = c.customer_id
where c.job_industry_category = 'Financial Services' and t.brand != ''


-- 5 Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.

select distinct t.customer_id
from transaction t
where t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles') AND t.online_order = 'True'
limit 10


-- 6 Вывести всех клиентов, у которых нет транзакций.

select c.customer_id
from customer c
left join transaction t ON c.customer_id = t.customer_id
where t.transaction_id is null

-- 7 Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.

select c.customer_id
from customer c
join transaction t on c.customer_id = t.customer_id 
where c.job_industry_category = 'IT' and t.standard_cost = (select max(t.standard_cost) from transaction t) 


-- 8 Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.

select distinct c.customer_id
from customer c
join transaction t on c.customer_id = t.customer_id
where c.job_industry_category in ('IT', 'Health') and
      t.order_status = 'Approved' and
      to_date(transaction_date, 'DD.MM.YYYY') between '2017-07-07' and '2017-07-17'
