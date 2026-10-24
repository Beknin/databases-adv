with packs as (
    -- собираем пачки параметров, конвертируя базовые единицы в пользовательские
    select
        l.log_id,
        l.user_id,
        e.equipment_name,
        max(case when p.parameter_type_id = 1 then p.parameter_value end) as height,
        max(case when p.parameter_type_id = 2 then p.parameter_value end) as temperature,
        max(case when p.parameter_type_id = 3 then round(p.parameter_value / 133.32, 1) end) as pressure,
        max(case when p.parameter_type_id = 4 then round(p.parameter_value / 6.0, 1) end) as wind_dir,
        max(case when p.parameter_type_id = 5 and e.equipment_name = 'ДМК' then p.parameter_value end) as wind_speed,
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
),
user_errors as (
    -- группируем по пользователям, считаем ошибки
    select
        v.user_id,
        u.lastname || ' ' || u.name as fio,
        r.rank_name,
        count(*) as total_packs,
        count(*) filter (where v.error_description <> '') as error_packs,
        count(*) filter (where v.error_description = '') as correct_packs,
        round(
            100.0 * count(*) filter (where v.error_description = '') / count(*),
            1
        ) as accuracy_percent
    from validation v
    join users u on u.user_id = v.user_id
    join ranks r on r.rank_id = u.rank_id
    group by v.user_id, u.lastname, u.name, r.rank_name
)
select
    row_number() over (order by error_packs asc, accuracy_percent desc) as "Место",
    fio as "Пользователь",
    rank_name as "Звание",
    total_packs as "Всего пачек",
    error_packs as "Ошибок",
    correct_packs as "Без ошибок",
    accuracy_percent || '%' as "Точность"
from user_errors
order by error_packs asc, accuracy_percent desc;