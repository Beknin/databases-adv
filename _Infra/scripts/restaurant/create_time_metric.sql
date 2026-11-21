do $$
	begin
	create table if not exists dim_time (
	    code serial primary key,
	    date_start date,
	    date_end date,
	    month_name text,
	    year int,
	    quarter_number int,
	    quarter_name text
	);
	
	comment on table dim_time is 'Временная метрика';
	comment on column dim_time.code is 'Внутренний код записи';
	comment on column dim_time.date_start is 'Дата начала месяца';
	comment on column dim_time.date_end is 'Дата окончания месяца';
	comment on column dim_time.month_name is 'Название месяца';
	comment on column dim_time.year is 'Год';
	comment on column dim_time.quarter_number is 'Номер квартала';
	comment on column dim_time.quarter_name is 'Название квартала';
	
	delete from dim_time;
	
	insert into dim_time(date_start, date_end, month_name, year, quarter_number, quarter_name)
	select 
	    date_trunc('month', d)::date as date_start,
	    (date_trunc('month', d) + interval '1 month' - interval '1 day')::date as date_end,
	    to_char(d, 'TMMonth') as month_name,
	    extract(year from d)::int as year,
	    extract(quarter from d)::int as quarter_number,
	    
	    case
	        when extract(quarter from d) = 1 then 'Первый квартал'
	        when extract(quarter from d) = 2 then 'Второй квартал'
	        when extract(quarter from d) = 3 then 'Третий квартал'
	        when extract(quarter from d) = 4 then 'Четвертый квартал'
	    end as quarter_name
	    
	from generate_series('2020-01-01'::date, '2030-12-31'::date, '1 month'::interval) as d;
	
	--select * from dim_time limit 20;

	commit;
end $$;