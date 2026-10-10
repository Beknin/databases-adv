SELECT 'Равное число измерений' AS check_name,
    (SELECT COUNT(*) FROM (
        SELECT user_id FROM logs GROUP BY user_id
        HAVING COUNT(*) <> (SELECT MAX(c) FROM (SELECT COUNT(*) AS c FROM logs GROUP BY user_id) t)
    ) t) AS violations
UNION ALL
SELECT 'Пустые пачки',
    (SELECT COUNT(*) FROM logs l
     WHERE NOT EXISTS (SELECT 1 FROM parameters p WHERE p.parameter_id / 10 = l.parameter_id))
UNION ALL
SELECT 'Не 5 параметров в пачке',
    (SELECT COUNT(*) FROM (
        SELECT l.log_id FROM logs l
        LEFT JOIN parameters p ON p.parameter_id / 10 = l.parameter_id
        GROUP BY l.log_id HAVING COUNT(p.parameter_id) <> 5
    ) t)
UNION ALL
SELECT 'Значения вне диапазонов',
    (SELECT COUNT(*) FROM parameters p WHERE NOT (
        (p.parameter_type_id = 1 AND p.parameter_value BETWEEN 0 AND 15000)
        OR (p.parameter_type_id = 2 AND p.parameter_value BETWEEN -80 AND 60)
        OR (p.parameter_type_id = 3 AND p.parameter_value BETWEEN 40000 AND 120000)
        OR (p.parameter_type_id = 4 AND p.parameter_value BETWEEN 0 AND 360)
        OR (p.parameter_type_id = 5 AND p.parameter_value BETWEEN 0 AND 100)))
UNION ALL
SELECT 'Неверные единицы измерения',
    (SELECT COUNT(*) FROM parameters p
     JOIN units u ON u.unit_id = p.unit_id
     WHERE u.base_unit_id <> p.parameter_type_id);