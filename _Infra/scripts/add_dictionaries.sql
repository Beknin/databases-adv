do $$
begin

    create table if not exists temp_deviation_table (
        id integer primary key,
        height integer not null,
        delta_t_input integer not null,
        delta_t_result integer not null
    );

    create sequence if not exists public.seq_temp_deviation_table;
    alter table temp_deviation_table
        alter column id set default nextval('public.seq_temp_deviation_table');

    comment on table temp_deviation_table is 'Таблица 2: средние отклонения температуры воздуха на стандартных высотах';
    comment on column temp_deviation_table.height is 'Стандартная высота бюллетеня, м';
    comment on column temp_deviation_table.delta_t_input is 'Отклонение приземной виртуальной температуры, гр. Цельсия';
    comment on column temp_deviation_table.delta_t_result is 'Среднее отклонение температуры на высоте, гр. Цельсия';


    create table if not exists wind_table_dmk (
        id integer primary key,
        height integer not null,
        wind_speed_input integer not null,
        wind_speed_result integer not null,
        wind_dir_delta integer not null
    );

    create sequence if not exists public.seq_wind_table_dmk;
    alter table wind_table_dmk
        alter column id set default nextval('public.seq_wind_table_dmk');

    comment on table wind_table_dmk is 'Таблица 3 для ДМК: скорость и направление среднего ветра';
    comment on column wind_table_dmk.height is 'Стандартная высота бюллетеня, м';
    comment on column wind_table_dmk.wind_speed_input is 'Скорость приземного ветра, м/с';
    comment on column wind_table_dmk.wind_speed_result is 'Скорость среднего ветра на высоте, м/с';
    comment on column wind_table_dmk.wind_dir_delta is 'Приращение направления ветра, больш. дел.';


    create table if not exists wind_table_vr (
        id integer primary key,
        height integer not null,
        bullet_drift_input integer not null,
        wind_speed_result integer not null,
        wind_dir_delta integer not null
    );

    create sequence if not exists public.seq_wind_table_vr;
    alter table wind_table_vr
        alter column id set default nextval('public.seq_wind_table_vr');

    comment on table wind_table_vr is 'Таблица 3 для ВР: скорость и направление среднего ветра';
    comment on column wind_table_vr.height is 'Стандартная высота бюллетеня, м';
    comment on column wind_table_vr.bullet_drift_input is 'Дальность сноса ветровых пуль, м';
    comment on column wind_table_vr.wind_speed_result is 'Скорость среднего ветра на высоте, м/с';
    comment on column wind_table_vr.wind_dir_delta is 'Приращение направления ветра, больш. дел.';

	commit;
end $$;