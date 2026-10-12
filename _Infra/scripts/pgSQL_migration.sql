do $$
-- Создание новых таблиц и модификация существующих
begin
	begin
		create table if not exists base_units (
		    base_unit_id integer primary key,
		    base_unit_name text not null
		);
		
		create table if not exists units (
		    unit_id integer primary key,
		    base_unit_id integer not null,
		    unit_name text not null,
		    unit_ratio numeric not null
		);
		
		create table if not exists parameter_types (
		    parameter_type_id integer primary key,
		    parameter_type_name text not null,
		    base_unit_id integer not null
		);
		
		create table if not exists virtual_temp_correction (
		    correction_id integer primary key,
		    t0_range text not null,
		    correction_value numeric(3,1) not null
		);
		
		alter table parameters add column if not exists parameter_type_id integer;
		alter table parameters add column if not exists unit_id integer;
		alter table parameters add column if not exists parameter_value numeric;
		
		alter table parameters alter column height drop not null;
		alter table parameters alter column temperature drop not null;
		alter table parameters alter column pressure drop not null;
		alter table parameters alter column wind_dir drop not null;
		alter table parameters alter column wind_spd drop not null;

	end;
-- Создание счетчиков и их привязка к таблицам
	begin

		create sequence if not exists seq_base_units start with 1;
		alter table base_units alter column base_unit_id set default nextval('seq_base_units');
		alter sequence seq_base_units owned by base_units.base_unit_id;
		
		create sequence if not exists seq_units start with 1;
		alter table units alter column unit_id set default nextval('seq_units');
		alter sequence seq_units owned by units.unit_id;
		
		create sequence if not exists seq_parameter_types start with 1;
		alter table parameter_types alter column parameter_type_id set default nextval('seq_parameter_types');
		alter sequence seq_parameter_types owned by parameter_types.parameter_type_id;
		
		create sequence if not exists seq_virtual_temp start with 1;
		alter table virtual_temp_correction alter column correction_id set default nextval('seq_virtual_temp');
		alter sequence seq_virtual_temp owned by virtual_temp_correction.correction_id;
	end;
-- Наполнение данными (
	begin

		insert into base_units (base_unit_id, base_unit_name) values
		(1, 'метры'), (2, 'градусы цельсия'), (3, 'паскали'), (4, 'градусы'), (5, 'метры в секунду')
		on conflict (base_unit_id) do nothing;
		
		insert into units (unit_id, base_unit_id, unit_name, unit_ratio) values
		(1, 1, 'м', 1), (2, 2, 'градусы цельсия', 1), (3, 3, 'мм рт.ст.', 133.32),
		(4, 4, 'градусы', 1), (5, 5, 'м/с', 1), (11, 1, 'см', 0.01),
		(13, 3, 'паскали', 1), (14, 4, 'радианы', 57.296), (15, 5, 'км/ч', 0.277)
		on conflict (unit_id) do nothing;
		
		insert into parameter_types (parameter_type_id, parameter_type_name, base_unit_id) values
		(1, 'высота', 1), (2, 'температура', 2), (3, 'давление', 3),
		(4, 'направление ветра', 4), (5, 'скорость ветра', 5)
		on conflict (parameter_type_id) do nothing;
		
		insert into virtual_temp_correction (correction_id, t0_range, correction_value) values
		(1, 'Ниже 0', 0), (2, '0 - 5', 0.5), (3, '10 - 15', 1), (4, '20', 1.5),
		(5, '25', 2), (6, '30', 3.5), (7, '40', 4.5)
		on conflict (correction_id) do nothing;
		
		-- Миграция данных из старых колонок в новую структуру
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
		select parameter_id * 10 + 1, equipment_id, 1, 1, height from parameters where height is not null
		on conflict (parameter_id) do nothing;
		
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
		select parameter_id * 10 + 2, equipment_id, 2, 2, temperature from parameters where temperature is not null
		on conflict (parameter_id) do nothing;
		
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
		select parameter_id * 10 + 3, equipment_id, 3, 3, pressure * 133.32 from parameters where pressure is not null
		on conflict (parameter_id) do nothing;
		
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
		select parameter_id * 10 + 4, equipment_id, 4, 4, wind_dir from parameters where wind_dir is not null
		on conflict (parameter_id) do nothing;
		
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
		select parameter_id * 10 + 5, equipment_id, 5, 5, wind_spd from parameters where wind_spd is not null
		on conflict (parameter_id) do nothing;
		
		-- Тестовые данные (журнал измерений)
		insert into logs (log_id, user_id, parameter_id, date) values
		(3, 1, 3, '2026-10-04'), (4, 1, 4, '2026-10-04'), (5, 1, 5, '2026-10-04'),
		(6, 2, 6, '2026-10-05'), (7, 2, 7, '2026-10-05'), (8, 2, 8, '2026-10-05'),
		(9, 3, 9, '2026-10-06'), (10, 3, 10, '2026-10-06'), (11, 3, 11, '2026-10-06')
		on conflict (log_id) do nothing;
		
		-- Тестовые данные (параметры)
		insert into parameters (parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value) values
		(31, 1, 1, 11, 12.5), (32, 1, 2, 2, 18.5), (33, 1, 3, 3, 100656.6), (34, 1, 4, 4, 220.0), (35, 1, 5, 15, 3.33),
		(41, 1, 1, 1, 1255.0), (42, 1, 2, 2, 21.0), (43, 1, 3, 13, 101200.0), (44, 1, 4, 14, 60.16), (45, 1, 5, 5, 5.5),
		(51, 1, 1, 11, 12.6), (52, 1, 2, 2, 19.2), (53, 1, 3, 3, 100256.64), (54, 1, 4, 4, 245.0), (55, 1, 5, 15, 4.17),
		(61, 2, 1, 1, 850.0), (62, 2, 2, 2, 15.0), (63, 2, 3, 3, 101323.2), (64, 2, 4, 4, 45.0), (65, 2, 5, 5, 3.2),
		(71, 2, 1, 11, 852.0), (72, 2, 2, 2, 17.5), (73, 2, 3, 13, 101500.0), (74, 2, 4, 14, 44.69), (75, 2, 5, 15, 2.78),
		(81, 2, 1, 1, 855.0), (82, 2, 2, 2, 16.8), (83, 2, 3, 3, 101056.56), (84, 2, 4, 4, 90.0), (85, 2, 5, 5, 4.0),
		(91, 1, 1, 1, 1300.0), (92, 1, 2, 2, 14.0), (93, 1, 3, 3, 99723.36), (94, 1, 4, 4, 310.0), (95, 1, 5, 15, 5.56),
		(101, 1, 1, 11, 1305.0), (102, 1, 2, 2, 16.2), (103, 1, 3, 13, 99800.0), (104, 1, 4, 14, 89.95), (105, 1, 5, 5, 7.0),
		(111, 1, 1, 1, 1310.0), (112, 1, 2, 2, 15.5), (113, 1, 3, 3, 99323.4), (114, 1, 4, 4, 350.0), (115, 1, 5, 15, 6.11)
		on conflict (parameter_id) do nothing;

	end;
-- =========================================================
-- 4. Очистка старых колонок, добавление связей (FK) и ограничений (CHECK)
-- =========================================================
	begin

		alter table parameters drop column if exists height;
		alter table parameters drop column if exists temperature;
		alter table parameters drop column if exists pressure;
		alter table parameters drop column if exists wind_dir;
		alter table parameters drop column if exists wind_spd;
		
		delete from parameters where parameter_type_id is null or unit_id is null or parameter_value is null;
		
		alter table parameters alter column parameter_type_id set not null;
		alter table parameters alter column unit_id set not null;
		alter table parameters alter column parameter_value set not null;
		
		alter table parameters add constraint fk_parameters_equipment foreign key (equipment_id) references equipment(equipment_id);
		alter table parameters add constraint fk_parameters_type foreign key (parameter_type_id) references parameter_types(parameter_type_id);
		alter table parameters add constraint fk_parameters_unit foreign key (unit_id) references units(unit_id);
		alter table logs add constraint fk_logs_user foreign key (user_id) references users(user_id);
		alter table users add constraint fk_users_rank foreign key (rank_id) references ranks(rank_id);
		
		alter table parameters add constraint chk_height_range check ((parameter_type_id != 1) or (parameter_value between -1000 and 15000));
		alter table parameters add constraint chk_temperature_range check ((parameter_type_id != 2) or (parameter_value between -58 and 58));
		alter table parameters add constraint chk_pressure_range check ((parameter_type_id != 3) or (parameter_value between 66660 and 119988));
		alter table parameters add constraint chk_wind_direction_range check ((parameter_type_id != 4) or (parameter_value between 0 and 360));
		alter table parameters add constraint chk_wind_speed_range check ((parameter_type_id != 5) or (parameter_value between 0 and 150));

	end;
end $$;