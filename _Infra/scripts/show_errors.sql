with packs as (
    -- собираем пачки параметров, конвертируя базовые единицы в пользовательские для валидации
    select
        l.log_id,
        l.user_id,
        e.equipment_name,
        -- высота: базовая = м, пользовательская = м
        max(case when p.parameter_type_id = 1 then p.parameter_value end) as height,
        -- температура: базовая = °C, пользовательская = °C
        max(case when p.parameter_type_id = 2 then p.parameter_value end) as temperature,
        -- давление: базовая = Па, пользовательская = мм рт.ст. (делим на 133.32)
        max(case when p.parameter_type_id = 3 then round(p.parameter_value / 133.32, 1) end) as pressure,
        -- направление ветра: базовая = градусы, пользовательская = бол. дел. (1 бол. дел. = 6°, делим на 6)
        max(case when p.parameter_type_id = 4 then round(p.parameter_value / 6.0, 1) end) as wind_dir,
        -- скорость ветра (только для ДМК): базовая = м/с, пользовательская = м/с
        max(case when p.parameter_type_id = 5 and e.equipment_name = 'ДМК' then p.parameter_value end) as wind_speed,
        -- дальность сноса (только для ВР): базовая = м, пользовательская = м
        max(case when p.parameter_type_id = 5 and e.equipment_name = 'ВР' then p.parameter_value end) as bullet_drift
    from logs l
    join parameters p on p.parameter_id / 10 = l.log_id
    join equipment e on e.equipment_id = p.equipment_id
    group by l.log_id, l.user_id, e.equipment_name
),
validation as (
    -- вызываем функцию проверки для каждой пачки
    select
        log_id,
        user_id,
        equipment_name,
        height,
        temperature,
        pressure,
        wind_dir,
        wind_speed,
        bullet_drift,
        validate_parameter_pack((
            equipment_name,
            height,
            temperature,
            pressure,
            wind_dir,
            wind_speed,
            bullet_drift
        )::parameter_pack) as error_description
    from packs
)
select
    row_number() over (order by log_id) as "№",
    equipment_name as "Тип оборудования",
    height as "Высота",
    temperature as "Температура",
    pressure as "Давление",
    wind_dir as "Направление",
    wind_speed as "Скорость ветра",
    bullet_drift as "Дальность сноса",
    case when error_description <> '' then 'Да' else 'Нет' end as "Есть ошибка",
    nullif(error_description, '') as "Описание ошибки"
from validation
order by log_id;