drop table if exists interpolation_test_results;
create temp table interpolation_test_results (
    t0 numeric,
    expected numeric,
    actual numeric
);

do $$
declare
    rec record;
    actual numeric;
begin
    for rec in
        select * from (values
            (23::numeric, 1.8::numeric),
            (3::numeric,  0.3::numeric),
            (0::numeric,  0::numeric),
            (5::numeric,  0.5::numeric),
            (15::numeric, 1::numeric),
            (20::numeric, 1.5::numeric),
            (25::numeric, 2::numeric),
            (30::numeric, 3.5::numeric),
            (40::numeric, 4.5::numeric),
            (-5::numeric, 0::numeric),
            (50::numeric, 4.5::numeric)
        ) as tests(t0, expected)
    loop
        actual := round(interpolate(rec.t0, get_interpolation_points(rec.t0))::numeric, 2);

        insert into interpolation_test_results values (
            rec.t0,
            rec.expected,
            actual
        );
    end loop;
end $$;

select * from interpolation_test_results;