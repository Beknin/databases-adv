select 
    'тест 1: дмк, t0=25°c, v0=6 м/с' as "тест",
    'дмк' as "оборудование",
    25::numeric as "t0, °c",
    6::numeric as "вход (v0/дг)",
    height as "высота, м",
    temp_deviation as "δty",
    wind_speed as "wy, м/с",
    wind_dir as "αwy"
from calculate_meteo_approximation(
    ('дмк', 100, 25, 765, 15, 6, null)::parameter_pack, 1)

union all

select 
    'тест 2: вр, t0=16.8°c, дг=2.1 м' as "тест",
    'вр' as "оборудование",
    16.8::numeric as "t0, °c",
    2.1::numeric as "вход (v0/дг)",
    height as "высота, м",
    temp_deviation as "δty",
    wind_speed as "wy, м/с",
    wind_dir as "αwy"
from calculate_meteo_approximation(
    ('вр', 102, 16.8, 745, 0, null, 2.1)::parameter_pack, 2)

union all

select 
    'тест 3: дмк, t0=-10°c, v0=8 м/с' as "тест",
    'дмк' as "оборудование",
    -10::numeric as "t0, °c",
    8::numeric as "вход (v0/дг)",
    height as "высота, м",
    temp_deviation as "δty",
    wind_speed as "wy, м/с",
    wind_dir as "αwy"
from calculate_meteo_approximation(
    ('дмк', 150, -10, 755, 25, 8, null)::parameter_pack, 1)

order by "тест", "высота, м";