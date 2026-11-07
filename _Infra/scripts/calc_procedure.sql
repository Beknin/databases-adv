-- хранимая процедура для выполнения расчетов

-- определение типа возвращаемых данных
drop type if exists meteo_calculation_result cascade;
create type meteo_calculation_result as (
    height integer, -- стандартная высота
    temp_deviation integer, -- среднее отклонение температуры
    wind_speed integer, -- скорость среднего ветра
    wind_dir_delta integer -- приращение направления ветра
);

-- создание функции расчета
drop function if exists calculate_meteo_approximation(parameter_pack, text);
create function calculate_meteo_approximation(
    in_params parameter_pack,
    in_equipment_type text
)
returns setof meteo_calculation_result
language plpgsql
as $func$
declare
    v_equipment_id integer;
    v_delta_t_mp integer;
    v_t0 numeric;
    v_delta_tv numeric;
    v_points interpolation_points;
    v_result meteo_calculation_result;
    v_type_id_temp integer;
    v_type_id_wind_speed integer;
    v_type_id_wind_dir integer;
    v_header_pos integer;
    v_height_id integer;
    v_wind_input integer;
begin
    -- определяем id оборудования
    if upper(in_equipment_type) = 'ДМК' then
        v_equipment_id := 1;
    elsif upper(in_equipment_type) = 'ВР' then
        v_equipment_id := 2;
    else
        raise exception 'Неверный тип оборудования: %. Допустимые значения: ДМК, ВР', in_equipment_type;
    end if;

    -- расчет виртуальной температуры
    v_points := get_interpolation_points(in_params.temperature);
    v_delta_tv := interpolate(in_params.temperature, v_points);
    v_t0 := in_params.temperature + v_delta_tv;

    v_delta_t_mp := round(v_t0 - 15.9)::integer;

    raise notice 'Расчет для t₀=%, ΔTᵥ=%, T₀=%, ΔT₀мп=%', 
        in_params.temperature, round(v_delta_tv::numeric, 1), round(v_t0::numeric, 1), v_delta_t_mp;

    -- определяем типы таблиц для поиска
    if v_delta_t_mp < 0 then
        select id into v_type_id_temp from calc_correction_types where description = 'Таблица 2: Отрицательные температуры';
    else
        select id into v_type_id_temp from calc_correction_types where description = 'Таблица 2: Положительные температуры';
    end if;

    if v_equipment_id = 1 then
        select id into v_type_id_wind_speed from calc_correction_types where description = 'Таблица 3: Скорость ветра (ДМК)';
        select id into v_type_id_wind_dir from calc_correction_types where description = 'Таблица 3: Направление ветра (ДМК)';
    else
        select id into v_type_id_wind_speed from calc_correction_types where description = 'Таблица 3: Скорость ветра (ВР)';
        select id into v_type_id_wind_dir from calc_correction_types where description = 'Таблица 3: Направление ветра (ВР)';
    end if;

    -- для каждой стандартной высоты находим значения
    for v_result.height in select height from calc_correction_heights order by height loop
        
        select id into v_height_id from calc_correction_heights where height = v_result.height;

        -- находим отклонение температуры
        select ch.position into v_header_pos from calc_correction_headers ch
        where ch.type_id = v_type_id_temp order by abs(ch.header_value - v_delta_t_mp) limit 1;

        select cc.row_values[v_header_pos] into v_result.temp_deviation
        from calc_correction cc where cc.height_id = v_height_id and cc.type_id = v_type_id_temp;

        -- находим скорость ветра
        if v_equipment_id = 1 then
            v_wind_input := round(in_params.wind_speed)::integer;
        else
            v_wind_input := round(in_params.bullet_drift)::integer;
            if v_wind_input < 40 then
                v_result.wind_speed := 0; -- особое правило для ВР
            end if;
        end if;

        if v_wind_input >= 40 or v_equipment_id = 1 then
            select ch.position into v_header_pos from calc_correction_headers ch
            where ch.type_id = v_type_id_wind_speed order by abs(ch.header_value - v_wind_input) limit 1;

            select cc.row_values[v_header_pos] into v_result.wind_speed
            from calc_correction cc where cc.height_id = v_height_id and cc.type_id = v_type_id_wind_speed;
        end if;

        -- находим приращение направления ветра
        select ch.position into v_header_pos from calc_correction_headers ch
        where ch.type_id = v_type_id_wind_dir order by abs(ch.header_value - v_wind_input) limit 1;

        select cc.row_values[v_header_pos] into v_result.wind_dir_delta
        from calc_correction cc where cc.height_id = v_height_id and cc.type_id = v_type_id_wind_dir;

        return next v_result;
    end loop;

    return;
end;
$func$;