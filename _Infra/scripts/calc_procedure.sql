-- хранимая процедура для выполнения расчетов
do $$
begin
    -- определение типа возвращаемых данных
    drop type if exists meteo_calculation_result cascade;
    create type meteo_calculation_result as (
        height integer,
        temp_deviation integer,
        wind_speed integer,
        wind_dir integer
    );
    
    -- создание функции расчета
    drop function if exists calculate_meteo_approximation(parameter_pack, integer);
    create function calculate_meteo_approximation(
        in_params parameter_pack,
        in_equipment_id integer
    )
    returns setof meteo_calculation_result
    language plpgsql
    as $func$
    declare
        v_std_temperature numeric;
        v_delta_t_mp integer;
        v_t0 numeric;
        v_delta_tv numeric;
        v_points interpolation_points;
        v_result meteo_calculation_result;
        v_type_id_temp integer;
        v_type_id_wind_speed integer;
        v_type_id_wind_dir integer;
        v_height_id integer;
        v_wind_input integer;
        v_tens integer;
        v_units integer;
    begin
        -- проверка id оборудования
        if in_equipment_id not in (1, 2) then
            raise exception 'неверный id оборудования: %', in_equipment_id;
        end if;
    
        -- получаем табличное значение температуры
        select constant_value into v_std_temperature
        from system_constants
        where constant_key = 'standard_temperature';
    
        -- расчет виртуальной температуры
        v_points := get_interpolation_points(in_params.temperature);
        v_delta_tv := interpolate(in_params.temperature, v_points);
        v_t0 := in_params.temperature + v_delta_tv;
        v_delta_t_mp := round(v_t0 - v_std_temperature)::integer;
    
        -- определяем типы таблиц
        v_type_id_temp := case when v_delta_t_mp < 0 then 9 else 8 end;
        v_type_id_wind_speed := case when in_equipment_id = 1 then 6 else 4 end;
        v_type_id_wind_dir := case when in_equipment_id = 1 then 7 else 5 end;
    
        -- определяем входной параметр для ветра
        v_wind_input := case 
            when in_equipment_id = 1 then round(in_params.wind_speed)::integer
            else round(in_params.bullet_drift)::integer
        end;
    
        -- для каждой стандартной высоты
        for v_result.height in 
            select height from calc_correction_heights order by height
        loop
            select id into v_height_id 
            from calc_correction_heights 
            where height = v_result.height;
    
            -- отклонение температуры
            v_tens := (v_delta_t_mp / 10) * 10;
            v_units := v_delta_t_mp - v_tens;
            
            -- получаем сумму значений для десятков и единиц
            select coalesce(t1.val, 0) + coalesce(t2.val, 0)
            into v_result.temp_deviation
            from 
                (select row_values[(select position from calc_correction_headers 
                  where type_id = v_type_id_temp and header_value = v_tens limit 1)] as val
                 from calc_correction 
                 where height_id = v_height_id and type_id = v_type_id_temp) t1,
                (select row_values[(select position from calc_correction_headers 
                  where type_id = v_type_id_temp and header_value = v_units limit 1)] as val
                 from calc_correction 
                 where height_id = v_height_id and type_id = v_type_id_temp) t2;
    
            -- скорость и направление ветра
            if (in_equipment_id = 1 and v_wind_input < 3) or
               (in_equipment_id = 2 and v_wind_input < 40) then
                v_result.wind_speed := 0;
                v_result.wind_dir := 0;
            else
                -- скорость ветра
                select row_values[(select position from calc_correction_headers 
                  where type_id = v_type_id_wind_speed and header_value = v_wind_input limit 1)]
                into v_result.wind_speed
                from calc_correction 
                where height_id = v_height_id and type_id = v_type_id_wind_speed;
    
                -- направление ветра
                select in_params.wind_dir + row_values[(select position from calc_correction_headers 
                  where type_id = v_type_id_wind_dir and header_value = v_wind_input limit 1)]
                into v_result.wind_dir
                from calc_correction 
                where height_id = v_height_id and type_id = v_type_id_wind_dir;
                
                -- нормализация угла
                v_result.wind_dir := ((v_result.wind_dir % 60) + 60) % 60;
            end if;
    
            return next v_result;
        end loop;
    
        return;
    end;
    $func$;
end $$;