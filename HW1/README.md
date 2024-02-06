# Домашнее задание №1. Создание и нормализация базы данных.

## Анализ данных

Данные представлены в виде двух таблиц: **transactions** и **customers**

Таблица **transactions** находится во 2НФ, так как все её атрибуты атомарны и зависят от первичного ключа **transaction_id** Тем не менее, она на находится в 3НФ, так как существует транзитивная зависимость атрибутов продукта (brand, product_class, product_line, product_size) от **product_id** и **list_price**, то есть неключевых атрибутов. То есть информацию о продуктах нужно вынести в отдельную таблицу.

Так как среди атрибутов, относящихся к продукту, не было того, который можно было отнести к первичному ключу, а составной ключ из **product_id** и **list_price** привёл бы к тому, что некоторые неключевые атрибуты зависели бы от половины ключа (**list_price**), ключ **item_id** был сгенерирован. 

Таблица **customers** нужно сначала привести в 1НФ, разделив атрибут **address** на **street** и **building**. В ней также есть транзитивная зависимость атрибутов **state** и **country** от **postcode**, то есть неключевого атрибута. То есть информацию об индексах нужно вынести в отдельную таблицу.

В таблице **customers** количество уникальных адресов (адрес + индекс) равно количеству клиентов, так что можно было бы оставить и так. Но так как задача состоит в проектировании базы, я бы выделила информацию об адресах в отдельную таблицу, создала уникальные ключи. Полученную таблицу можно привязать к **customers**, если считать, что это адреса прописки. Однако если адреса подразумеваются как адреса доставки, я бы их привязала к таблице **transactions**, обеспечив этим большую гибкость.



