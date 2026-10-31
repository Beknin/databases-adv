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
	    v_min numeric;
	    v_max numeric;
	begin
	    eq_upper := upper(trim(pack.equipment_code));
	
	    if eq_upper not in ('ДМК', 'ВР') then
	        errors := errors || 'неверный тип оборудования: ' || pack.equipment_code || '; ';
	    end if;
	
	    -- высота
	    select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'height';
	    if pack.height is null then errors := errors || 'высота не указана; ';
	    elsif pack.height < v_min or pack.height > v_max then
	        errors := errors || 'высота вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.height || '; ';
	    end if;
	
	    -- температура
	    select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'temperature';
	    if pack.temperature is null then errors := errors || 'температура не указана; ';
	    elsif pack.temperature < v_min or pack.temperature > v_max then
	        errors := errors || 'температура вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.temperature || '; ';
	    end if;
	
	    -- давление
	    select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'pressure';
	    if pack.pressure is null then errors := errors || 'давление не указано; ';
	    elsif pack.pressure < v_min or pack.pressure > v_max then
	        errors := errors || 'давление вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.pressure || '; ';
	    end if;
	
	    -- направление ветра
	    select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'wind_dir';
	    if pack.wind_dir is null then errors := errors || 'направление ветра не указано; ';
	    elsif pack.wind_dir < v_min or pack.wind_dir > v_max then
	        errors := errors || 'направление ветра вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.wind_dir || '; ';
	    end if;
	
	    -- проверка по типу оборудования
	    if eq_upper = 'ДМК' then
	        select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'wind_speed';
	        if pack.wind_speed is null then errors := errors || 'скорость ветра не указана (обязательно для дмк); ';
	        elsif pack.wind_speed < v_min or pack.wind_speed > v_max then
	            errors := errors || 'скорость ветра вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.wind_speed || '; ';
	        end if;
	        if pack.bullet_drift is not null then errors := errors || 'дальность сноса пуль не используется для дмк; ';
	        end if;
	
	    elsif eq_upper = 'ВР' then
	        select min_value, max_value into v_min, v_max from parameter_bounds where parameter_name = 'bullet_drift';
	        if pack.bullet_drift is null then errors := errors || 'дальность сноса пуль не указана (обязательно для вр); ';
	        elsif pack.bullet_drift < v_min or pack.bullet_drift > v_max then
	            errors := errors || 'дальность сноса пуль вне диапазона [' || v_min || ', ' || v_max || ']: ' || pack.bullet_drift || '; ';
	        end if;
	        if pack.wind_speed is not null then errors := errors || 'скорость ветра не используется для вр; ';
	        end if;
	    end if;
	
	    if errors <> '' then errors := rtrim(errors, '; '); end if;
	    return errors;
	end;
	$func$;

end $$;