do $$
begin
    -- добавляем колонку для точного значения температуры
    alter table virtual_temp_correction add column if not exists t0_val numeric;

    -- заполняем точные узловые точки в соответствии с таблицей 1 из тз
    update virtual_temp_correction set t0_val = 0,  t0_range = 'ниже 0 / 0' where correction_id = 1;
    update virtual_temp_correction set t0_val = 5,  t0_range = '0 - 5'     where correction_id = 2;
    update virtual_temp_correction set t0_val = 15, t0_range = '10 - 15'   where correction_id = 3;
    update virtual_temp_correction set t0_val = 20, t0_range = '20'        where correction_id = 4;
    update virtual_temp_correction set t0_val = 25, t0_range = '25'        where correction_id = 5;
    update virtual_temp_correction set t0_val = 30, t0_range = '30'        where correction_id = 6;
    update virtual_temp_correction set t0_val = 40, t0_range = '40'        where correction_id = 7;

    drop type if exists interpolation_points cascade;

    create type interpolation_points as (
        x0 numeric,
        y0 numeric,
        x1 numeric,
        y1 numeric
    );

    -- функция определения точек интерполяции по температуре
    create or replace function get_interpolation_points(t numeric)
    returns interpolation_points
    language plpgsql
    as $func$
    declare
        result interpolation_points;
    begin
        select x0, y0, x1, y1 into result
        from (
            select
                lag(t0_val) over (order by t0_val) as x0,
                lag(correction_value) over (order by t0_val) as y0,
                t0_val as x1,
                correction_value as y1
            from virtual_temp_correction
            where t0_val is not null
            order by t0_val
        ) as pairs
        where t >= x0 and t < x1
        limit 1;

        -- обработка граничных случаев
        if result.x0 is null then
            if t < 0 then
                -- ниже 0 виртуальная поправка всегда равна 0
                result := (0::numeric, 0::numeric, 0::numeric, 0::numeric);
            else
                -- выше 40 фиксируем последнее известное значение (40, 4.5)
                select t0_val, correction_value, t0_val, correction_value
                into result.x0, result.y0, result.x1, result.y1
                from virtual_temp_correction
                order by t0_val desc
                limit 1;
            end if;
        end if;

        return result;
    end;
    $func$;

    -- функция расчёта линейной интерполяции
    create or replace function interpolate(x numeric, points interpolation_points)
    returns numeric
    language plpgsql
    as $func$
    begin
        if points.x0 = points.x1 then
            return points.y0;
        elsif x <= points.x0 then
            return points.y0;
        elsif x >= points.x1 then
            return points.y1;
        else
            return points.y0 + (points.y1 - points.y0) * (x - points.x0) / (points.x1 - points.x0);
        end if;
    end;
    $func$;
end $$;