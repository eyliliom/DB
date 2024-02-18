create table Transactions (
    transaction_id INT primary key,
    item_id INT not null,
    customer_id INT not null,
    address_id INT not null,
    transaction_date TIMESTAMP not null,
    online_order VARCHAR(30),
    order_status VARCHAR(30) not null
);

create table Products (
	id INT primary key,
	product_id INT,
	brand VARCHAR(30),
	product_line VARCHAR(30),
	product_class VARCHAR(30),
	product_size VARCHAR(30),
	list_price FLOAT4,
	standard_cost FLOAT4
);

create table Customers (
	id INT primary key,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	gender VARCHAR(30),
	DOB DATE,
	job_title VARCHAR(50),
	job_industry_category VARCHAR(50),
	wealth_segment VARCHAR(30),
	deceased_indicator VARCHAR(30),
	owns_car VARCHAR(30),
	property_valuation INT	
);

create table Address (
	id INT primary key,
	street VARCHAR(50),
	building VARCHAR(30),
	postcode INT not null
);

create table Region (
	postcode INT primary key,
	state VARCHAR(30),
	country VARCHAR(30)
);

alter table Transactions
add foreign key (item_id) references Products(id)

alter table Transactions
add foreign key (customer_id) references Customers(id)

alter table Transactions
add foreign key (address_id) references Address(id)

alter table Address
add foreign key (postcode) references Region(postcode)
