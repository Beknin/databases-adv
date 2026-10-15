select table_name as name, 'таблица' as type from information_schema.tables
	where table_schema = 'public' and table_type = 'BASE TABLE' and table_catalog = current_database()
union all
select sequence_name as name, 'счетчик' as type from information_schema.sequences
	where sequence_schema = 'public' and sequence_catalog = current_database()