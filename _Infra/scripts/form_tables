drop table if exists logs;
drop table if exists users;
drop table if exists ranks;
drop table if exists parameters;
drop table if exists equipment;

create table logs
(
	log_id integer not null unique,
	user_id integer not null,
	parameter_id integer not null,
	date date
);

create table users
(
	user_id integer not null unique,
	rank_id integer not null,
	name text not null,
	lastname text not null
);

create table ranks
(
	rank_id integer not null unique,
	rank_name text not null
);

create table parameters
(
	parameter_id integer not null unique,
	equipment_id integer not null,
	height numeric not null,
	temperature numeric not null,
	pressure numeric not null,
	wind_dir numeric not null,
	wind_spd numeric not null
);

create table equipment
(
	equipment_id integer not null unique,
	equipment_name text not null
);

insert into users(user_id, rank_id, name, lastname) values(1, 2, 'Сергей', 'Петров');
insert into users(user_id, rank_id, name, lastname) values(2, 1, 'Дмитрий', 'Прохоров');
insert into users(user_id, rank_id, name, lastname) values(3, 3, 'Павел', 'Иванов');

insert into ranks(rank_id, rank_name) values(1, 'Мл. Лейтенант');
insert into ranks(rank_id, rank_name) values(2, 'Лейтенант');
insert into ranks(rank_id, rank_name) values(3, 'Ст. Лейтенант');

insert into parameters(parameter_id, equipment_id, height, temperature, pressure, wind_dir, wind_spd) values(1, 2, 76.3, 18.5, 740, 12, 3.2);
insert into parameters(parameter_id, equipment_id, height, temperature, pressure, wind_dir, wind_spd) values(2, 1, 102, 16.8, 745, 0, 2.1);

insert into logs(log_id, user_id, parameter_id, date) values(1, 3, 1, '2026-09-02');
insert into logs(log_id, user_id, parameter_id, date) values(2, 2, 2, '2026-09-03');

insert into equipment(equipment_id, equipment_name) values(1, 'ВР');
insert into equipment(equipment_id, equipment_name) values(2, 'ДМК');

select log_id, date, lastname, name, rank_name, equipment_name, height, temperature, pressure, wind_dir, wind_spd
from logs, users, ranks, equipment, parameters
where
	users.rank_id = ranks.rank_id and logs.parameter_id = parameters.parameter_id and
	logs.user_id = users.user_id and parameters.equipment_id = equipment.equipment_id