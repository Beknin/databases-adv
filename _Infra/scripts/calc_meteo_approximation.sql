do $$
begin

    -- функция: форматирование даты-времени в ДДЧЧМ
    -- вход: дата и время измерения
    -- выход: текст формата ДДЧЧМ
    drop function if exists format_ddchm(timestamp);
    create function format_ddchm(measure_time timestamp)
    returns text
    language plpgsql
    as $func$
    declare
        day text;
        hour text;
        ten_min text;
    begin
        -- ДД - день месяца
        day := lpad(extract(day from measure_time)::text, 2, '0');
        
        -- ЧЧ - часы
        hour := lpad(extract(hour from measure_time)::text, 2, '0');
        
        -- М - десятки минут
        ten_min := floor(extract(minute from measure_time) / 10)::text;
        
        return day || hour || ten_min;
    end;
    $func$;

    -- функция: форматирование высоты в ВВВВ
    -- вход: высота в метрах
    -- выход: текст из 4 цифр с ведущими нулями
    drop function if exists format_vvvv(numeric);
    create function format_vvvv(height numeric)
    returns text
    language plpgsql
    as $func$
    begin
        return lpad(round(height)::text, 4, '0');
    end;
    $func$;

    -- функция: форматирование отклонения давления в БББ
    -- вход: отклонение давления ΔH₀ (мм рт.ст.)
    -- выход: текст из 3 цифр
    -- если положительное: 007, 013
    -- если отрицательное: 507, 513 (первая цифра 5 вместо знака минус)
    drop function if exists format_bbb(numeric);
    create function format_bbb(delta_h numeric)
    returns text
    language plpgsql
    as $func$
    declare
        abs_val integer;
    begin
        abs_val := abs(round(delta_h)::integer);
        
        if delta_h >= 0 then
            -- положительное: 007, 013
            return lpad(abs_val::text, 3, '0');
        else
            -- отрицательное: 507, 513
            return '5' || lpad(abs_val::text, 2, '0');
        end if;
    end;
    $func$;

    -- функция: форматирование отклонения температуры в ТТ
    -- вход: отклонение виртуальной температуры ΔT₀мп
    -- выход: текст из 2 цифр
    -- если положительное: 09, 13
    -- если отрицательное: 59, 57
    drop function if exists format_tt(numeric);
    create function format_tt(delta_t numeric)
    returns text
    language plpgsql
    as $func$
    declare
        abs_val integer;
        rounded integer;
    begin
        -- округляем до целого
        rounded := round(delta_t)::integer;
        abs_val := abs(rounded);
        
        if rounded >= 0 then
            -- положительное: 09, 13
            return lpad(abs_val::text, 2, '0');
        else
            -- отрицательное: 59, 57
            return '5' || abs_val::text;
        end if;
    end;
    $func$;

    -- функция: расчет полного заголовка метеобюллетеня
    -- вход: log_id (идентификатор пачки измерений)
    -- выход: record с полями:
    --   ddchm - ДДЧЧМ
    --   vvvv - ВВВВ
    --   bbb - БББ (отклонение давления)
    --   tt - ТТ (отклонение температуры)
    --   full_header - полный заголовок (ДДЧЧМ ВВВВ БББТТ)
    drop function if exists calculate_meteo_header(integer);
    create function calculate_meteo_header(p_log_id integer)
    returns table (
        ddchm text,
        vvvv text,
        bbb text,
        tt text,
        full_header text
    )
    language plpgsql
    as $func$
    declare
        measure_time timestamp;
        height_m numeric;
        pressure_mmhg numeric;
        temperature_c numeric;
        delta_h numeric;
        delta_tv numeric;
        t0 numeric;
        delta_t_mp numeric;
        points interpolation_points;
    begin
        -- получаем дату/время измерения из logs
        select l.date into measure_time
        from logs l
        where l.log_id = p_log_id;
        
        if measure_time is null then
            raise exception 'log_id % не найден в таблице logs', p_log_id;
        end if;
        
        -- собираем параметры пачки
        select
            max(case when p.parameter_type_id = 1 then p.parameter_value end) as height,
            max(case when p.parameter_type_id = 2 then p.parameter_value end) as temperature,
            max(case when p.parameter_type_id = 3 then round(p.parameter_value / 133.32, 1) end) as pressure
        into height_m, temperature_c, pressure_mmhg
        from parameters p
        where p.parameter_id / 10 = p_log_id
        group by p.parameter_id / 10;
        
        -- проверка, что все параметры найдены
        if height_m is null or temperature_c is null or pressure_mmhg is null then
            raise exception 'не найдены все параметры для log_id %', p_log_id;
        end if;
        
        -- расчет ΔH₀ = H₀ - 750
        delta_h := pressure_mmhg - 750;
        
        -- расчет ΔT через интерполяцию
        points := get_interpolation_points(temperature_c);
        delta_tv := interpolate(temperature_c, points);
        
        -- расчет T₀ = t₀ + ΔT
        t0 := temperature_c + delta_tv;
        
        -- расчет ΔT₀мп = T₀ - 15.9
        delta_t_mp := t0 - 15.9;
        
        -- формируем части заголовка
        ddchm := format_ddchm(measure_time);
        vvvv := format_vvvv(height_m);
        bbb := format_bbb(delta_h);
        tt := format_tt(delta_t_mp);
        
        -- полный заголовок: ДДЧЧМ ВВВВ БББТТ
        full_header := ddchm || ' ' || vvvv || ' ' || bbb || tt;
        
        return next;
    end;
    $func$;

end $$;