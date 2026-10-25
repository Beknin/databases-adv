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
    -- переменные для хранения констант из таблицы system_constants
    std_pressure numeric;
    std_temperature numeric;

    -- переменные для исходных данных
    measure_time timestamp;
    height_m numeric;
    pressure_mmhg numeric;
    temperature_c numeric;

    -- переменные для промежуточных расчётов
    delta_h numeric;
    delta_tv numeric;
    t0 numeric;
    delta_t_mp numeric;
    points interpolation_points;
begin
    -- получаем константы из таблицы system_constants
    select constant_value into std_pressure
    from system_constants
    where constant_key = 'standard_pressure';

    if std_pressure is null then
        raise exception 'константа standard_pressure не найдена в таблице system_constants';
    end if;

    select constant_value into std_temperature
    from system_constants
    where constant_key = 'standard_temperature';

    if std_temperature is null then
        raise exception 'константа standard_temperature не найдена в таблице system_constants';
    end if;

    -- получаем дату/время измерения из таблицы logs
    select l.date::timestamp into measure_time
    from logs l
    where l.log_id = p_log_id;

    if measure_time is null then
        raise exception 'log_id % не найден в таблице logs', p_log_id;
    end if;

    -- собираем параметры пачки
    -- конвертируем из базовых единиц в пользовательские
    select
        max(case when p.parameter_type_id = 1 then p.parameter_value end),
        max(case when p.parameter_type_id = 2 then p.parameter_value end),
        max(case when p.parameter_type_id = 3 then round(p.parameter_value / 133.32, 1) end)
    into height_m, temperature_c, pressure_mmhg
    from parameters p
    where p.parameter_id / 10 = p_log_id
    group by p.parameter_id / 10;

    if height_m is null or temperature_c is null or pressure_mmhg is null then
        raise exception 'не найдены все параметры для log_id %', p_log_id;
    end if;

    -- расчёт отклонения давления (ΔH₀ = H₀ - табличное)
    delta_h := pressure_mmhg - std_pressure;

    -- расчёт виртуальной температуры через интерполяцию
    points := get_interpolation_points(temperature_c);
    delta_tv := interpolate(temperature_c, points);

    -- T₀ = t₀ + ΔTᵥ
    t0 := temperature_c + delta_tv;

    -- расчёт отклонения виртуальной температуры
    -- (ΔT₀мп = T₀ - табличное)
    delta_t_mp := t0 - std_temperature;

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