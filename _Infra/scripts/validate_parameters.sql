do $$
begin

    -- тип данных "список параметров" (одна пачка измерений)
    drop type if exists parameter_pack cascade;
    create type parameter_pack as (
        equipment_code text,       -- 'дмк' или 'вр'
        height numeric,            -- высота метеопоста, м
        temperature numeric,       -- температура, °c
        pressure numeric,          -- давление, мм рт.ст.
        wind_dir numeric,          -- направление ветра, бол. дел. угломера (0-59)
        wind_speed numeric,        -- скорость ветра, м/с (только для дмк)
        bullet_drift numeric       -- дальность сноса пуль, м (только для вр)
    );

    -- тип данных "ошибка валидации" (для структурированного вывода)
    drop type if exists validation_error cascade;
    create type validation_error as (
        parameter_name text,       -- название параметра
        error_code text,           -- код ошибки
        error_message text         -- описание ошибки
    );

    -- функция проверки корректности параметров
    -- на вход: parameter_pack
    -- на выход: text (строка со списком ошибок, пустая если ошибок нет)
    drop function if exists validate_parameter_pack(parameter_pack);
    create function validate_parameter_pack(pack parameter_pack)
    returns text
    language plpgsql
    as $func$
    declare
        errors text := '';
        eq_upper text;
    begin
        eq_upper := upper(pack.equipment_code);

        -- проверка типа оборудования
        if eq_upper not in ('ДМК', 'ВР') then
            errors := errors || 'неверный тип оборудования: ' || pack.equipment_code || '; ';
        end if;

        -- высота: -1000 .. 15000 м
        if pack.height is null then
            errors := errors || 'высота не указана; ';
        elsif pack.height < -1000 or pack.height > 15000 then
            errors := errors || 'высота вне диапазона [-1000, 15000]: ' || pack.height || '; ';
        end if;

        -- температура: -58 .. 58 °c
        if pack.temperature is null then
            errors := errors || 'температура не указана; ';
        elsif pack.temperature < -58 or pack.temperature > 58 then
            errors := errors || 'температура вне диапазона [-58, 58]: ' || pack.temperature || '; ';
        end if;

        -- давление: 500 .. 900 мм рт.ст.
        if pack.pressure is null then
            errors := errors || 'давление не указано; ';
        elsif pack.pressure < 500 or pack.pressure > 900 then
            errors := errors || 'давление вне диапазона [500, 900]: ' || pack.pressure || '; ';
        end if;

        -- направление ветра: 0 .. 59 бол. дел. угломера
        if pack.wind_dir is null then
            errors := errors || 'направление ветра не указано; ';
        elsif pack.wind_dir < 0 or pack.wind_dir > 59 then
            errors := errors || 'направление ветра вне диапазона [0, 59]: ' || pack.wind_dir || '; ';
        end if;

        -- проверка по типу оборудования
        if eq_upper in ('дмк', 'dmk') then
            -- для дмк обязательна скорость ветра: 0 .. 15 м/с
            if pack.wind_speed is null then
                errors := errors || 'скорость ветра не указана (обязательно для дмк); ';
            elsif pack.wind_speed < 0 or pack.wind_speed > 15 then
                errors := errors || 'скорость ветра вне диапазона [0, 15]: ' || pack.wind_speed || '; ';
            end if;
            -- дальность сноса для дмк не используется
            if pack.bullet_drift is not null then
                errors := errors || 'дальность сноса пуль не используется для дмк; ';
            end if;
        elsif eq_upper in ('вр', 'bp') then
            -- для вр обязательна дальность сноса: 0 .. 150 м
            if pack.bullet_drift is null then
                errors := errors || 'дальность сноса пуль не указана (обязательно для вр); ';
            elsif pack.bullet_drift < 0 or pack.bullet_drift > 150 then
                errors := errors || 'дальность сноса пуль вне диапазона [0, 150]: ' || pack.bullet_drift || '; ';
            end if;
            -- скорость ветра для вр не используется
            if pack.wind_speed is not null then
                errors := errors || 'скорость ветра не используется для вр; ';
            end if;
        end if;

        -- убираем лишнюю точку с запятой в конце
        if errors <> '' then
            errors := rtrim(errors, '; ');
        end if;

        return errors;
    end;
    $func$;

end $$;