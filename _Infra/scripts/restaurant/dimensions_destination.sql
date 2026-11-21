create SEQUENCE seq_dim_ranges;

-- Ресурсы еди ницы изхмерения
create table dim_ranges
(
      --- Внутрений код
    id bigint primary key DEFAULT nextval('public.seq_dim_ranges'),
    external_id bigint,
    name text,
    factor float,
    -- Дата добавления
    date_add timestamp default now()
);

create sequence seq_products;
create table products
(
	id bigint primary key default nextval('public.seq_products'),
	external_id bigint,
	name text,
	vendor_id bigint,
	date_add timestamp default now(),
	is_use int,
	category_id bigint,
	size_id bigint
);

create sequence seq_vendors;
create table vendors
(
	id bigint primary key default nextval('public.seq_vendors'),
	external_id bigint,
	name text,
	birthday timestamp,
	country_id int,
	is_use int,
	date_add timestamp default now()
);

create sequence seq_personnel;
create table personnel
(
	id bigint primary key default nextval('public.seq_personnel'),
	external_id bigint,
	lastname text,
	firstname text,
	middlename text,
	password text,
	security_access int,
	date_add timestamp default now()
);

create sequence seq_personnel_security_access;
create table personnel_security_access
(
	id bigint primary key default nextval('public.seq_personnel_security_access'),
	external_id int,
	description text
);

create sequence seq_journal;
create table journal
(
	id bigint primary key default nextval('public.seq_journal'),
	external_id bigint,
	trans_type int,
	receipt_number bigint,
	price float,
	amount float,
	description text,
	discount float,
	discount_amount float,
	employee_id int,
	trans_number bigint,
	date_add timestamp default now()
);

create sequence seq_journal_details;
create table journal_details
(
	id bigint primary key default nextval('public.seq_journal_details'),
	external_id bigint,
	source_id int,
	product_id int,
	dish_id int,
	weight_brutto float,
	amount float,
	count float,
	ticket_number bigint,
	size_id int,
	storage_id int,
	date_add timestamp default now()
);

create sequence seq_journal_types;
create table journal_types
(
	id bigint primary key default nextval('public.seq_journal_types'),
	external_id int,
	name text,
	date_add timestamp default now()
);

create sequence seq_journal_document_types;
create table journal_document_types
(
	id bigint primary key default nextval('public.seq_journal_document_types'),
	external_id int,
	description text,
	journal_id int,
	is_parent int,
	date_add timestamp default now()
);

create sequence seq_storages;
create table storages
(
	id bigint primary key default nextval('public.seq_storages'),
	external_id int,
	description text,
	responsible_id int
);

create sequence seq_storage_operations;
create table storage_operations
(
	id bigint primary key default nextval('public.seq_storage_operations'),
	external_id int,
	document_id int,
	operation_id int,
	source_id int,
	dish_id int,
	product_id int,
	vendor_id int,
	storage_id int,
	size_id int,
	price float,
	price_cost float,
	count float,
	amount float,
	taxed float,
	taxed_amount float,
	date_add timestamp default now()
);

create sequence seq_storage_operation_types;
create table storage_operation_types
(
	id bigint primary key default nextval('public.seq_storage_operation_types'),
	external_id int,
	description text,
	factor int,
	date_add timestamp default now()
);

create sequence seq_document_headers;
create table document_headers
(
	id bigint primary key default nextval('public.seq_document_headers'),
	external_id int,
	journal_id int,
	shift_id int,
	document_number int,
	document_type_id int,
	person_id int,
	date_add timestamp default now()
);

create sequence seq_trans_types;
create table trans_types
(
	id bigint primary key default nextval('public.seq_trans_types'),
	external_id int,
	group_id int,
	group_type_preview text,
	description text
);

create sequence seq_pricelist;
create table pricelist
(
	id bigint primary key default nextval('public.seq_pricelist'),
	external_id int,
	document_id int,
	base_cost float,
	group_id int,
	product_id int
);