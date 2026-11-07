-- структуры и справочники для Таблиц 2 и 3
do $$
begin
    -- таблица стандартных высот
    create table if not exists calc_correction_heights (
        id integer primary key,
        height integer not null unique
    );
    create sequence if not exists calc_correction_height_seq;
    alter table calc_correction_heights alter column id set default nextval('calc_correction_height_seq');

    -- таблица для хранения заголовков
    create table if not exists calc_correction_headers (
        id integer primary key,
        type_id integer not null,
        header_value integer not null,
        position integer not null
    );
    create sequence if not exists calc_correction_headers_seq;
    alter table calc_correction_headers alter column id set default nextval('calc_correction_headers_seq');

    -- справочник типов таблиц корректировок
    create table if not exists calc_correction_types (
        id integer primary key,
        parent_id integer,
        measurement_equipment_id integer,
        description text not null,
        header_values integer[]
    );
    create sequence if not exists calc_correction_types_seq;
    alter table calc_correction_types alter column id set default nextval('calc_correction_types_seq');

    -- универсальная таблица корректировок
    create table if not exists calc_correction (
        id integer primary key,
        height_id integer not null,
        type_id integer not null,
        row_values integer[]
    );
    create sequence if not exists calc_correction_seq;
    alter table calc_correction alter column id set default nextval('calc_correction_seq');

    -- настройка внешних ключей
    alter table calc_correction_headers drop constraint if exists fk_calc_headers_type;
    alter table calc_correction_headers add constraint fk_calc_headers_type foreign key (type_id) references calc_correction_types(id);

    alter table calc_correction drop constraint if exists fk_calc_correction_height;
    alter table calc_correction add constraint fk_calc_correction_height foreign key (height_id) references calc_correction_heights(id);

    alter table calc_correction drop constraint if exists fk_calc_correction_type;
    alter table calc_correction add constraint fk_calc_correction_type foreign key (type_id) references calc_correction_types(id);

    -- заполнение стандартных высот
    truncate table calc_correction_heights cascade;
    alter sequence calc_correction_height_seq restart with 1;
    insert into calc_correction_heights (height) values
    (200), (400), (600), (800), (1000), (1500), (2000), (2500), (3000), (3500), (4000);

    -- очистка и заполнение типов таблиц
    truncate table calc_correction cascade;
    truncate table calc_correction_headers cascade;
    truncate table calc_correction_types cascade;

    insert into calc_correction_types (id, description, header_values) values
    (1, 'Таблица 2: Средние отклонения температуры', array[-30, -20, -10, -3, 0, 3, 10, 20, 30]);

    insert into calc_correction_types (id, description, parent_id) values
    (8, 'Таблица 2: Отрицательные температуры', 1),
    (9, 'Таблица 2: Положительные температуры', 1),
    (2, 'Таблица 3: Скорость среднего ветра (Родитель)', null),
    (3, 'Таблица 3: Направление среднего ветра (Родитель)', null);

    insert into calc_correction_types (id, description, parent_id, measurement_equipment_id, header_values) values
    (4, 'Таблица 3: Скорость ветра (ВР)', 2, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),
    (5, 'Таблица 3: Направление ветра (ВР)', 3, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]),
    (6, 'Таблица 3: Скорость ветра (ДМК)', 2, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
    (7, 'Таблица 3: Направление ветра (ДМК)', 3, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

    -- заполнение таблицы заголовков
    insert into calc_correction_headers (type_id, header_value, position)
    select 8, unnest, generate_subscripts from (select array[-30, -20, -10, -3, 0, 3, 10, 20, 30] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);
    
    insert into calc_correction_headers (type_id, header_value, position)
    select 9, unnest, generate_subscripts from (select array[0, 3, 10, 20, 30] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);

    insert into calc_correction_headers (type_id, header_value, position)
    select 4, unnest, generate_subscripts from (select array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);

    insert into calc_correction_headers (type_id, header_value, position)
    select 5, unnest, generate_subscripts from (select array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);

    insert into calc_correction_headers (type_id, header_value, position)
    select 6, unnest, generate_subscripts from (select array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);

    insert into calc_correction_headers (type_id, header_value, position)
    select 7, unnest, generate_subscripts from (select array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] as vals) t, unnest(t.vals) with ordinality as u(unnest, generate_subscripts);

    -- таблица 2 отрицательные температуры
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  8, array[-27, -18, -9,  -3,  0,  3,  9, 18, 27]),
    (2,  8, array[-26, -17, -9,  -3,  0,  3,  9, 18, 26]),
    (3,  8, array[-25, -16, -8,  -3,  0,  3,  8, 17, 25]),
    (4,  8, array[-24, -15, -8,  -3,  0,  3,  8, 16, 24]),
    (5,  8, array[-23, -15, -7,  -3,  0,  3,  7, 15, 23]),
    (6,  8, array[-21, -13, -7,  -3,  0,  3,  7, 13, 21]),
    (7,  8, array[-19, -12, -6,  -3,  0,  3,  6, 12, 19]),
    (8,  8, array[-17, -11, -6,  -3,  0,  3,  6, 11, 17]),
    (9,  8, array[-16, -10, -5,  -3,  0,  3,  5, 10, 16]),
    (10, 8, array[-14,  -9, -5,  -3,  0,  3,  5,  9, 14]),
    (11, 8, array[-13,  -8, -4,  -2,  0,  2,  4,  8, 13]);

    -- таблица 2 положительные температуры
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  9, array[ 0,  3,  9, 18, 27]),
    (2,  9, array[ 0,  3,  9, 18, 26]),
    (3,  9, array[ 0,  3,  8, 17, 25]),
    (4,  9, array[ 0,  3,  8, 16, 24]),
    (5,  9, array[ 0,  3,  7, 15, 23]),
    (6,  9, array[ 0,  3,  7, 13, 21]),
    (7,  9, array[ 0,  3,  6, 12, 19]),
    (8,  9, array[ 0,  3,  6, 11, 17]),
    (9,  9, array[ 0,  3,  5, 10, 16]),
    (10, 9, array[ 0,  3,  5,  9, 14]),
    (11, 9, array[ 0,  2,  4,  8, 13]);

    -- таблица 3 Скорость ветра ВР
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  4, array[ 0,  3,  4,  5,  6,  7,  7,  8,  9, 10, 11, 12]),
    (2,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (3,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (4,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 13, 14, 15]),
    (5,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 12, 13, 14, 15]),
    (6,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 12, 13, 14, 15]),
    (7,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (8,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (9,  4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (10, 4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]),
    (11, 4, array[ 0,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14]);

    -- таблица 3 скорость ветра ДМК
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  6, array[ 0,  4,  6,  8,  9, 10, 12, 14, 15, 16, 18, 20, 21]),
    (2,  6, array[ 0,  5,  7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25]),
    (3,  6, array[ 0,  5,  7, 10, 11, 12, 14, 16, 18, 19, 21, 23, 24]),
    (4,  6, array[ 0,  5,  8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27]),
    (5,  6, array[ 0,  5,  8, 10, 12, 13, 15, 17, 19, 21, 23, 25, 27]),
    (6,  6, array[ 0,  5,  8, 10, 12, 13, 15, 17, 19, 21, 23, 25, 26]),
    (7,  6, array[ 0,  5,  8, 10, 11, 13, 15, 17, 18, 20, 22, 24, 25]),
    (8,  6, array[ 0,  5,  7,  9, 11, 12, 14, 16, 18, 19, 21, 23, 24]),
    (9,  6, array[ 0,  4,  7,  9, 10, 12, 14, 15, 17, 18, 20, 22, 23]),
    (10, 6, array[ 0,  4,  7,  9, 10, 11, 13, 15, 16, 18, 19, 21, 22]),
    (11, 6, array[ 0,  4,  6,  8, 10, 11, 12, 14, 15, 17, 18, 20, 21]);

    -- таблица 3 направление ветра ВР
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  5, array[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
    (2,  5, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
    (3,  5, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
    (4,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (5,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (6,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (7,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (8,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (9,  5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (10, 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (11, 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]);

    -- таблица 3 направление ветра ДМК
    insert into calc_correction (height_id, type_id, row_values) values
    (1,  7, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
    (2,  7, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (3,  7, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
    (4,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (5,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (6,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (7,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (8,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (9,  7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (10, 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
    (11, 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]);

end $$;