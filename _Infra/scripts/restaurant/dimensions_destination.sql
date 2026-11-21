do $$
	begin

	drop table if exists dim_ranges;
	drop sequence if exists seq_dim_ranges;
	create sequence seq_dim_ranges;
	create table dim_ranges
	(
	    id bigint primary key default nextval('public.seq_dim_ranges'),
	    external_id bigint,
	    name text,
	    factor float,
	    date_add timestamp default now()
	);
	
	comment on table dim_ranges is 'Единицы измерения';
	comment on column dim_ranges.id is 'Внутренний код';
	comment on column dim_ranges.external_id is 'Внешний код из старой БД';
	comment on column dim_ranges.name is 'Название единицы измерения';
	comment on column dim_ranges.factor is 'Коэффициент пересчёта';
	comment on column dim_ranges.date_add is 'Дата добавления записи';
	
	drop table if exists products;
	drop sequence if exists seq_products;
	create sequence seq_products;
	create table products
	(
	    id bigint primary key default nextval('public.seq_products'),
	    external_id bigint,
	    name text,
	    vendor_id bigint,
	    category_id bigint,
	    size_id bigint,
	    date_add timestamp default now()
	);
	
	comment on table products is 'Товары';
	comment on column products.id is 'Внутренний код';
	comment on column products.external_id is 'Внешний код из старой БД';
	comment on column products.name is 'Название товара';
	comment on column products.vendor_id is 'Код поставщика';
	comment on column products.category_id is 'Код категории';
	comment on column products.size_id is 'Код единицы измерения';
	comment on column products.date_add is 'Дата добавления записи';
	
	drop table if exists vendors;
	drop sequence if exists seq_vendors;
	create sequence seq_vendors;
	create table vendors
	(
	    id bigint primary key default nextval('public.seq_vendors'),
	    external_id bigint,
	    name text,
	    country_id int,
	    date_add timestamp default now()
	);
	
	comment on table vendors is 'Поставщики';
	comment on column vendors.id is 'Внутренний код';
	comment on column vendors.external_id is 'Внешний код из старой БД';
	comment on column vendors.name is 'Название поставщика';
	comment on column vendors.country_id is 'Код страны';
	comment on column vendors.date_add is 'Дата добавления записи';
	
	drop table if exists personnel;
	drop sequence if exists seq_personnel;
	create sequence seq_personnel;
	create table personnel
	(
	    id bigint primary key default nextval('public.seq_personnel'),
	    external_id bigint,
	    lastname text,
	    firstname text,
	    middlename text,
	    date_add timestamp default now()
	);
	
	comment on table personnel is 'Сотрудники';
	comment on column personnel.id is 'Внутренний код';
	comment on column personnel.external_id is 'Внешний код из старой БД';
	comment on column personnel.lastname is 'Фамилия';
	comment on column personnel.firstname is 'Имя';
	comment on column personnel.middlename is 'Отчество';
	comment on column personnel.date_add is 'Дата добавления записи';
	
	drop table if exists journal_types;
	drop sequence if exists seq_journal_types;
	create sequence seq_journal_types;
	create table journal_types
	(
	    id bigint primary key default nextval('public.seq_journal_types'),
	    external_id int,
	    name text,
	    date_add timestamp default now()
	);
	
	comment on table journal_types is 'Типы журналов';
	comment on column journal_types.id is 'Внутренний код';
	comment on column journal_types.external_id is 'Внешний код из старой БД';
	comment on column journal_types.name is 'Название типа журнала';
	comment on column journal_types.date_add is 'Дата добавления записи';
	
	drop table if exists journal_document_types;
	drop sequence if exists seq_journal_document_types;
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
	
	comment on table journal_document_types is 'Типы документов журнала';
	comment on column journal_document_types.id is 'Внутренний код';
	comment on column journal_document_types.external_id is 'Внешний код из старой БД';
	comment on column journal_document_types.description is 'Описание типа документа';
	comment on column journal_document_types.journal_id is 'Код типа журнала';
	comment on column journal_document_types.is_parent is 'Признак родительского типа';
	comment on column journal_document_types.date_add is 'Дата добавления записи';
	
	drop table if exists storages;
	drop sequence if exists seq_storages;
	create sequence seq_storages;
	create table storages
	(
	    id bigint primary key default nextval('public.seq_storages'),
	    external_id int,
	    description text,
	    responsible_id int,
	    date_add timestamp default now()
	);
	
	comment on table storages is 'Склады';
	comment on column storages.id is 'Внутренний код';
	comment on column storages.external_id is 'Внешний код из старой БД';
	comment on column storages.description is 'Описание склада';
	comment on column storages.responsible_id is 'Код ответственного лица';
	comment on column storages.date_add is 'Дата добавления записи';
	
	drop table if exists trans_types;
	drop sequence if exists seq_trans_types;
	create sequence seq_trans_types;
	create table trans_types
	(
	    id bigint primary key default nextval('public.seq_trans_types'),
	    external_id int,
	    group_id int,
	    description text,
	    date_add timestamp default now()
	);
	
	comment on table trans_types is 'Типы транзакций';
	comment on column trans_types.id is 'Внутренний код';
	comment on column trans_types.external_id is 'Внешний код из старой БД';
	comment on column trans_types.group_id is 'Код группы транзакций';
	comment on column trans_types.description is 'Описание типа транзакции';
	comment on column trans_types.date_add is 'Дата добавления записи';
	
	drop table if exists debit_reasons;
	drop sequence if exists seq_debit_reasons;
	create sequence seq_debit_reasons;
	create table debit_reasons
	(
	    id bigint primary key default nextval('public.seq_debit_reasons'),
	    external_id int,
	    parent_id int,
	    description text,
	    date_add timestamp default now()
	);
	
	comment on table debit_reasons is 'Причины списания';
	comment on column debit_reasons.id is 'Внутренний код';
	comment on column debit_reasons.external_id is 'Внешний код из старой БД';
	comment on column debit_reasons.parent_id is 'Код родительской причины';
	comment on column debit_reasons.description is 'Описание причины';
	comment on column debit_reasons.date_add is 'Дата добавления записи';
	
	drop table if exists categories;
	drop sequence if exists seq_categories;
	create sequence seq_categories;
	create table categories
	(
	    id bigint primary key default nextval('public.seq_categories'),
	    external_id int,
	    description text,
	    parent_id int,
	    date_add timestamp default now()
	);
	
	comment on table categories is 'Категории товаров';
	comment on column categories.id is 'Внутренний код';
	comment on column categories.external_id is 'Внешний код из старой БД';
	comment on column categories.description is 'Описание категории';
	comment on column categories.parent_id is 'Код родительской категории';
	comment on column categories.date_add is 'Дата добавления записи';
	
	drop table if exists payment_types;
	drop sequence if exists seq_payment_types;
	create sequence seq_payment_types;
	create table payment_types
	(
	    id bigint primary key default nextval('public.seq_payment_types'),
	    external_id int,
	    description text,
	    date_add timestamp default now()
	);
	
	comment on table payment_types is 'Виды оплаты';
	comment on column payment_types.id is 'Внутренний код';
	comment on column payment_types.external_id is 'Внешний код из старой БД';
	comment on column payment_types.description is 'Описание вида оплаты';
	comment on column payment_types.date_add is 'Дата добавления записи';

	commit;
end $$;