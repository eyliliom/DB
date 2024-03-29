# Домашнее задание №1. Создание и нормализация базы данных.

## Анализ данных

Данные представлены в виде двух таблиц: **transactions** и **customers**

Таблица **transactions** находится во 2НФ, так как все её атрибуты атомарны и зависят от первичного ключа **transaction_id** Тем не менее, она не находится в 3НФ, так как существует транзитивная зависимость атрибутов продукта (brand, product_class, product_line, product_size) от **product_id** и **list_price**, то есть неключевых атрибутов. То есть информацию о продуктах нужно вынести в отдельную таблицу **products**.

Так как среди атрибутов, относящихся к продукту, не было того, который можно было отнести к первичному ключу, а составной ключ из **product_id** и **list_price** привёл бы к тому, что некоторые неключевые атрибуты зависели бы от половины ключа (**list_price**), ключ **item_id** был сгенерирован. Цены можно было бы перенести в таблицу **transactions**, но в таблице **products** практически в каждом поле есть пропуски или 0 по умолчанию, как в **product_id**, а **list_price** - единственное поле, определенное для всех уникальных записей. Так что цены переносить не стала. Так как **product_id** не является ключом, его значение может быть пустым в полученной базе, хотя изначально пустых значений в этом поле не было.

Таблицу **customers** нужно сначала привести в 1НФ, разделив атрибут **address** на **street** и **building**. В ней также есть транзитивная зависимость атрибутов **state** и **country** от **postcode**, то есть неключевого атрибута. То есть информацию об индексах нужно вынести в отдельную таблицу.

В таблице **customers** количество уникальных адресов (адрес + индекс) равно количеству клиентов, так что можно было бы оставить и так. Но так как задача состоит в проектировании базы, я бы выделила информацию об адресах в отдельную таблицу, создала уникальные ключи. Полученную таблицу можно привязать к **customers**, если считать, что это адреса прописки. Однако если адреса подразумеваются как адреса доставки, я бы их привязала к таблице **transactions**, обеспечив этим большую гибкость.

## Схема

В итоге получены следующие таблицы (синтаксис DBML, схема находится в *schema.pdf*)

Table transactions { \
  transaction_id integer [primary key] \
  customer_id integer \
  item_id integer \
  address_id integer \
  transaction_date timestamp \
  online_order varchar \
  order_status varchar \
}


Table product { \
  id integer [primary key] \
  product_id integer \
  brand varchar \
  product_line varchar \
  product_class varchar \
  product_size varchar \
  list_price float \
  standard_cost float \
}

Table customers { \
  id integer [primary key] \
  first_name varchar \
  last_name varchar \
  gender varchar \
  DOB date \
  job_title varchar \
  job_industry_category varchar \
  wealth_segment varchar \
  deceased_indicator varchar \
  owns_car varchar \
  property_valuation integer \
}

Table address { \
  id integer [primary key] \
  street varchar \
  building varchar \
  postcode integer \
}

Table region { \
  postcode integer [primary key] \
  state varchar \
  country varchar \
}

Ref: transactions.customer_id > customers.id \
Ref: transactions.address_id > address.id \
Ref: transactions.item_id > product.id \
Ref: address.postcode > region.postcode

## Создание таблиц

Код в файле *hw1_tables.sql*

## Загрузка данных

Данные были загружены через DBeaver, скриншоты в папке *insert_data/*