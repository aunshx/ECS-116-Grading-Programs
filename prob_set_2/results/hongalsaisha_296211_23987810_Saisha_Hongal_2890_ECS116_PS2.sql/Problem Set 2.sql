set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name; 

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code ISNULL
order by country_or_area;

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

select count(*)
from africa_fs_ac
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select *
from africa_fs_ac afa
where item LIKE('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;


-- Excercises for you
--create a query for Q3 mentioned above
select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in Africa
-- and not including countries where intermediate region is empty
select area_code_m49, year, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp, to_char(max(value), 'FM999999999.00') as
max_gdp, to_char(min(value), 'FM999999999.00') as
min_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area, year
order by area;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
-- (and not including countries where intermediate region is empty)
select area_code_m49, year, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp, to_char(max(value), 'FM999999999.00') as
max_gdp, to_char(min(value), 'FM999999999.00') as
min_gdp
from africa_fs_ac a
where item_code = '22013' and year >= '2011' and year <= '2020'
group by area_code_m49, area, year
order by year;

-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)
select area_code_m49, year, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp, to_char(max(value), 'FM999999999.00') as
max_gdp, to_char(min(value), 'FM999999999.00') as
min_gdp
from africa_fs_ac a
where item_code = '22013'  
group by area_code_m49, area, year
having round(avg(value)::numeric, 0) <= '4000'
order by year;

