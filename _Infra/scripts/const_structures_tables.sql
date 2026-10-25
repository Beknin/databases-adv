do $$
begin

    -- таблица системных констант
    create table if not exists system_constants (
        constant_key text primary key,
        constant_value numeric not null,
        description text
    );

    insert into system_constants (constant_key, constant_value, description) values
    ('standard_pressure', 750, 'табличное значение наземного давления, мм рт.ст.'),
    ('standard_temperature', 15.9, 'табличное значение приземной виртуальной температуры, °C')
    on conflict (constant_key) do nothing;


    -- таблица граничных условий для параметров
    create table if not exists parameter_bounds (
        parameter_name text primary key,
        min_value numeric not null,
        max_value numeric not null,
        is_required boolean not null default true,
        description text
    );

    insert into parameter_bounds (parameter_name, min_value, max_value, is_required, description) values
    ('height', -1000, 15000, true, 'высота метеопоста, м'),
    ('temperature', -58, 58, true, 'температура воздуха, °C'),
    ('pressure', 500, 900, true, 'давление, мм рт.ст.'),
    ('wind_dir', 0, 59, true, 'направление ветра, бол. дел. угломера'),
    ('wind_speed', 0, 15, true, 'скорость ветра, м/с (только для ДМК)'),
    ('bullet_drift', 0, 150, true, 'дальность сноса пуль, м (только для ВР)')
    on conflict (parameter_name) do nothing;


    -- таблица 1 из тз: виртуальная поправка температуры
    create table if not exists virtual_temp_correction (
        correction_id integer primary key,
        t0_range text not null,
        t0_val numeric not null,
        correction_value numeric(3,1) not null
    );

    insert into virtual_temp_correction (correction_id, t0_range, t0_val, correction_value) values
    (1, 'ниже 0',   0,  0),
    (2, '0 - 5',    5,  0.5),
    (3, '10 - 15',  15, 1),
    (4, '20',       20, 1.5),
    (5, '25',       25, 2),
    (6, '30',       30, 3.5),
    (7, '40',       40, 4.5)
    on conflict (correction_id) do nothing;

	-- функция получения константы по ключу
    drop function if exists get_constant(text);
    create function get_constant(p_key text)
    returns numeric
    language plpgsql
    as $func$
    declare
        result numeric;
    begin
        select constant_value into result
        from system_constants
        where constant_key = p_key;

        if result is null then
            raise exception 'константа % не найдена', p_key;
        end if;

        return result;
    end;
    $func$;

    -- функция получения границ параметра
    drop function if exists get_parameter_bounds(text);
    create function get_parameter_bounds(p_param_name text)
    returns table (min_val numeric, max_val numeric)
    language plpgsql
    as $func$
    begin
        return query
        select pb.min_value, pb.max_value
        from parameter_bounds pb
        where pb.parameter_name = p_param_name;
    end;
    $func$;

end $$;