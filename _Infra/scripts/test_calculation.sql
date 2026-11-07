SELECT 
    'Тест 1: ДМК, t0=25°C, V0=6 м/с' AS "Тест",
    'ДМК' AS "Оборудование",
    25::numeric AS "t0, °C",
    6::numeric AS "Вход (V0/Дг)",
    height AS "Высота, м",
    temp_deviation AS "ΔtY",
    wind_speed AS "Wy, м/с",
    wind_dir_delta AS "ΔαWY"
FROM calculate_meteo_approximation(
    ('ДМК', 100, 25, 765, 15, 6, null)::parameter_pack, 
    'ДМК'
)

UNION ALL

SELECT 
    'Тест 2: ВР, t0=16.8°C, Дг=2.1 м' AS "Тест",
    'ВР' AS "Оборудование",
    16.8::numeric AS "t0, °C",
    2.1::numeric AS "Вход (V0/Дг)",
    height AS "Высота, м",
    temp_deviation AS "ΔtY",
    wind_speed AS "Wy, м/с",
    wind_dir_delta AS "ΔαWY"
FROM calculate_meteo_approximation(
    ('ВР', 102, 16.8, 745, 0, null, 2.1)::parameter_pack, 
    'ВР'
)

UNION ALL

SELECT 
    'Тест 3: ДМК, t0=-10°C, V0=8 м/с' AS "Тест",
    'ДМК' AS "Оборудование",
    -10::numeric AS "t0, °C",
    8::numeric AS "Вход (V0/Дг)",
    height AS "Высота, м",
    temp_deviation AS "ΔtY",
    wind_speed AS "Wy, м/с",
    wind_dir_delta AS "ΔαWY"
FROM calculate_meteo_approximation(
    ('ДМК', 150, -10, 755, 25, 8, null)::parameter_pack, 
    'ДМК'
)

-- Сортировка итогового результата
ORDER BY "Тест", "Высота, м";