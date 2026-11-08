-- скрипт исправления учебного скрипта
do $$
begin

    -- добавляем новую таблицу для хранения заголовков
    begin
        create sequence if not exists calc_correction_headers_seq;
        create table if not exists calc_correction_headers
        (
            id integer not null primary key default nextval('public.calc_correction_headers_seq'),
            type_id integer not null,
            header_value integer not null,
            position integer not null
        );

        comment on table calc_correction_headers is 'справочник заголовков таблиц корректировок';
        comment on column calc_correction_headers.id is 'уникальный код';
        comment on column calc_correction_headers.type_id is 'код типа таблицы';
        comment on column calc_correction_headers.header_value is 'значение в заголовке таблицы';
        comment on column calc_correction_headers.position is 'позиция значения в заголовке';
    end;

    -- добавляем внешние ключи для связывания таблиц
    begin
        alter table calc_correction_headers
            drop constraint if exists fk_calc_headers_type;
        alter table calc_correction_headers
            add constraint fk_calc_headers_type
            foreign key (type_id) references calc_correction_types(id);

        alter table calc_correction
            drop constraint if exists fk_calc_correction_height;
        alter table calc_correction
            add constraint fk_calc_correction_height
            foreign key (height_id) references calc_correction_heights(id);

        alter table calc_correction
            drop constraint if exists fk_calc_correction_type;
        alter table calc_correction
            add constraint fk_calc_correction_type
            foreign key (type_id) references calc_correction_types(id);
    end;

    -- исправляем и дополняем данные
    begin
        -- удаляем старые данные только для типов, которые будем перезаписывать
        delete from calc_correction where type_id in (4, 5, 6, 7, 8, 9);
        delete from calc_correction_headers where type_id in (4, 5, 6, 7, 8, 9);
        
        -- удаляем высоты, которых нет в новом списке
        delete from calc_correction_heights where height not in (200, 400, 600, 800, 1000, 1500, 2000, 2500, 3000, 3500, 4000);
        
        -- добавляем недостающие высоты
		insert into calc_correction_heights (height)
		select h from (values (600), (1000), (1500), (2500), (3500)) as t(h)
		where not exists (select 1 from calc_correction_heights where height = t.h);

        -- заголовки для таблицы 2, отрицательные температуры
        insert into calc_correction_headers (type_id, header_value, position) values
        (9, -30, 1), (9, -20, 2), (9, -10, 3), (9, -9, 4), (9, -8, 5), (9, -7, 6),
        (9, -6, 7), (9, -5, 8), (9, -4, 9), (9, -3, 10), (9, -2, 11), (9, -1, 12);

        -- заголовки для таблицы 2, положительные температуры
        insert into calc_correction_headers (type_id, header_value, position) values
        (8, 0, 1), (8, 1, 2), (8, 2, 3), (8, 3, 4), (8, 4, 5), (8, 5, 6),
        (8, 6, 7), (8, 7, 8), (8, 8, 9), (8, 9, 10), (8, 10, 11), (8, 20, 12), (8, 30, 13);

        -- заголовки для таблицы 3, скорость ветра ВР
        insert into calc_correction_headers (type_id, header_value, position) values
        (4, 40, 1), (4, 50, 2), (4, 60, 3), (4, 70, 4), (4, 80, 5), (4, 90, 6),
        (4, 100, 7), (4, 110, 8), (4, 120, 9), (4, 130, 10), (4, 140, 11), (4, 150, 12);

        -- заголовки для таблицы 3, направление ветра ВР
        insert into calc_correction_headers (type_id, header_value, position) values
        (5, 40, 1), (5, 50, 2), (5, 60, 3), (5, 70, 4), (5, 80, 5), (5, 90, 6),
        (5, 100, 7), (5, 110, 8), (5, 120, 9), (5, 130, 10), (5, 140, 11), (5, 150, 12);

        -- заголовки для таблицы 3, скорость ветра ДМК
        insert into calc_correction_headers (type_id, header_value, position) values
        (6, 3, 1), (6, 4, 2), (6, 5, 3), (6, 6, 4), (6, 7, 5), (6, 8, 6),
        (6, 9, 7), (6, 10, 8), (6, 11, 9), (6, 12, 10), (6, 13, 11), (6, 14, 12), (6, 15, 13);

        -- заголовки для таблицы 3, направление ветра ДМК
        insert into calc_correction_headers (type_id, header_value, position) values
        (7, 3, 1), (7, 4, 2), (7, 5, 3), (7, 6, 4), (7, 7, 5), (7, 8, 6),
        (7, 9, 7), (7, 10, 8), (7, 11, 9), (7, 12, 10), (7, 13, 11), (7, 14, 12), (7, 15, 13);

        
        -- таблица 2, отрицательные значения
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 9, array[-27, -18, -9, -8, -7, -6, -5, -4, -3, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 400), 9, array[-26, -17, -9, -8, -7, -6, -5, -4, -3, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 600), 9, array[-25, -16, -8, -7, -6, -5, -4, -3, -2, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 800), 9, array[-24, -15, -8, -7, -6, -5, -4, -3, -2, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 1000), 9, array[-23, -15, -7, -6, -5, -4, -3, -2, -1, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 1500), 9, array[-21, -13, -7, -6, -5, -4, -3, -2, -1, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 2000), 9, array[-19, -12, -6, -5, -4, -3, -2, -1, 0, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 2500), 9, array[-17, -11, -6, -5, -4, -3, -2, -1, 0, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 3000), 9, array[-16, -10, -5, -4, -3, -2, -1, 0, 0, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 3500), 9, array[-14, -9, -5, -4, -3, -2, -1, 0, 0, -3, -2, -1]),
        ((select id from calc_correction_heights where height = 4000), 9, array[-13, -8, -4, -3, -2, -1, 0, 0, 0, -3, -2, -1]);

        -- таблица 2, положительные значения
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 400), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 600), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 800), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 1000), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 1500), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 2000), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 2500), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 3000), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 3500), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]),
        ((select id from calc_correction_heights where height = 4000), 8, array[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]);

        -- таблица 3, скорость среднего ветра ВР
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 4, array[0, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12]),
        ((select id from calc_correction_heights where height = 400), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 600), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 800), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15]),
        ((select id from calc_correction_heights where height = 1000), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15]),
        ((select id from calc_correction_heights where height = 1500), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15]),
        ((select id from calc_correction_heights where height = 2000), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 2500), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 3000), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 3500), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
        ((select id from calc_correction_heights where height = 4000), 4, array[0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);

        -- таблица 3, направление среднего ветра ВР
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 5, array[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        ((select id from calc_correction_heights where height = 400), 5, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        ((select id from calc_correction_heights where height = 600), 5, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        ((select id from calc_correction_heights where height = 800), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 1000), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 1500), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 2000), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 2500), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 3000), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 3500), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 4000), 5, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]);

        -- таблица 3, скорость среднего ветра ДМК
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 6, array[0, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21]),
        ((select id from calc_correction_heights where height = 400), 6, array[0, 5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25]),
        ((select id from calc_correction_heights where height = 600), 6, array[0, 5, 7, 10, 11, 12, 14, 16, 18, 19, 21, 23, 24]),
        ((select id from calc_correction_heights where height = 800), 6, array[0, 5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27]),
        ((select id from calc_correction_heights where height = 1000), 6, array[0, 5, 8, 10, 12, 13, 15, 17, 19, 21, 23, 25, 27]),
        ((select id from calc_correction_heights where height = 1500), 6, array[0, 5, 8, 10, 12, 13, 15, 17, 19, 21, 23, 25, 26]),
        ((select id from calc_correction_heights where height = 2000), 6, array[0, 5, 8, 10, 11, 13, 15, 17, 18, 20, 22, 24, 25]),
        ((select id from calc_correction_heights where height = 2500), 6, array[0, 5, 7, 9, 11, 12, 14, 16, 18, 19, 21, 23, 24]),
        ((select id from calc_correction_heights where height = 3000), 6, array[0, 4, 7, 9, 10, 12, 14, 15, 17, 18, 20, 22, 23]),
        ((select id from calc_correction_heights where height = 3500), 6, array[0, 4, 7, 9, 10, 11, 13, 15, 16, 18, 19, 21, 22]),
        ((select id from calc_correction_heights where height = 4000), 6, array[0, 4, 6, 8, 10, 11, 12, 14, 15, 17, 18, 20, 21]);

        -- таблица 3, направление среднего ветра ДМК
        insert into calc_correction(height_id, type_id, row_values) values
        ((select id from calc_correction_heights where height = 200), 7, array[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        ((select id from calc_correction_heights where height = 400), 7, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 600), 7, array[0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]),
        ((select id from calc_correction_heights where height = 800), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 1000), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 1500), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 2000), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 2500), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 3000), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 3500), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]),
        ((select id from calc_correction_heights where height = 4000), 7, array[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]);

    end;

end $$;