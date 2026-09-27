drop table if exists base_units;
drop table if exists units;
drop table if exists parameter_types;

create table base_units
(
	base_unit_id integer not null unique,
	base_unit_name text not null
);
comment on table base_units is 'Базовые ед. изм., в которых будут производиться вычисления';
comment on column base_units.base_unit_id is 'Идентификатор ед. изм.';
comment on column base_units.base_unit_name is 'Название ед. изм.';

create table units
(
	unit_id integer not null unique,
	base_unit_id integer not null,
	unit_name text not null,
	unit_ratio numeric not null
);
comment on table units is 'Единицы измерения';
comment on column units.unit_id is 'Идентификатор ед. изм.';
comment on column units.base_unit_id is 'Идентификатор базовой ед. изм., к которой относится данная';
comment on column units.unit_name is 'Название ед. изм.';
comment on column units.unit_ratio is 'Коэффициент перевода из данной ед. изм. в базовую';

create table parameter_types
(
	parameter_type_id integer not null unique,
	parameter_type_name text not null,
	base_unit_id integer not null
);
comment on table parameter_types is 'Типы параметров';
comment on column parameter_types.parameter_type_id is 'Идентификатор типа параметров';
comment on column parameter_types.parameter_type_name is 'Название типа параметров';
comment on column parameter_types.base_unit_id is 'Базовая ед. изм. данного типа параметров';

insert into base_units(base_unit_id, base_unit_name) values (1, 'Метры');
insert into base_units(base_unit_id, base_unit_name) values (2, 'Градусы Цельсия');
insert into base_units(base_unit_id, base_unit_name) values (3, 'Паскали');
insert into base_units(base_unit_id, base_unit_name) values (4, 'Градусы');
insert into base_units(base_unit_id, base_unit_name) values (5, 'Метры в секунду');

insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (1, 1, 'м', 1);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (2, 2, 'градусы Цельсия', 1);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (3, 3, 'мм рт.ст.', 133.32);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (4, 4, 'градусы', 1);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (5, 5, 'м/с', 1);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (11, 1, 'см', 0.01);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (13, 3, 'Паскали', 1);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (14, 4, 'Радианы', 57.296);
insert into units(unit_id, base_unit_id, unit_name, unit_ratio) values (15, 5, 'км/ч', 3.6);

insert into parameter_types(parameter_type_id, parameter_type_name, base_unit_id) values (1, 'Высота', 1);
insert into parameter_types(parameter_type_id, parameter_type_name, base_unit_id) values (2, 'Температура', 2);
insert into parameter_types(parameter_type_id, parameter_type_name, base_unit_id) values (3, 'Давление', 3);
insert into parameter_types(parameter_type_id, parameter_type_name, base_unit_id) values (4, 'Направление ветра', 4);
insert into parameter_types(parameter_type_id, parameter_type_name, base_unit_id) values (5, 'Скорость ветра', 5);

--изменение старых таблиц
alter table parameters add column if not exists parameter_type_id integer;
alter table parameters add column if not exists unit_id integer;
alter table parameters add column if not exists parameter_value numeric;

alter table parameters alter column height drop not null;
alter table parameters alter column temperature drop not null;
alter table parameters alter column pressure drop not null;
alter table parameters alter column wind_dir drop not null;
alter table parameters alter column wind_spd drop not null;

insert into parameters(parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
select parameter_id * 10 + 1, equipment_id, 1, 1, height
from parameters;

insert into parameters(parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
select parameter_id * 10 + 2, equipment_id, 2, 2, temperature
from parameters;

insert into parameters(parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
select parameter_id * 10 + 3, equipment_id, 3, 3, pressure * 133.32
from parameters;

insert into parameters(parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
select parameter_id * 10 + 4, equipment_id, 4, 14, wind_dir
from parameters;

insert into parameters(parameter_id, equipment_id, parameter_type_id, unit_id, parameter_value)
select parameter_id * 10 + 5, equipment_id, 5, 15, wind_spd
from parameters;

delete from parameters where parameter_value is null;

alter table parameters drop column if exists height;
alter table parameters drop column if exists temperature;
alter table parameters drop column if exists pressure;
alter table parameters drop column if exists wind_dir;
alter table parameters drop column if exists wind_spd;

alter table parameters alter column parameter_type_id set not null;
alter table parameters alter column unit_id set not null;
alter table parameters alter column parameter_value set not null;

select
	logs.date,
	logs.parameter_id as log_id,
	lastname || ' ' || name as fio,
	parameter_type_name || ' (' || unit_name || ')' as param,
	round(parameter_value / unit_ratio, 3) as value
from logs, users, ranks, parameter_types, units, parameters
where
	users.rank_id = ranks.rank_id and
	logs.user_id = users.user_id and
	parameters.parameter_id / 10 = logs.parameter_id and
	parameters.parameter_type_id = parameter_types.parameter_type_id and
	parameters.unit_id = units.unit_id and
	units.base_unit_id = parameter_types.base_unit_id
order by logs.date, logs.parameter_id, parameter_types.parameter_type_id