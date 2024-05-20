-- basics
set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

select * from m49_codes_expanded mce 
where country_or_area = 'Angola';

select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa' and intermediate_region_code isnull
order by country_or_area;

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

select count(*) from africa_fs_ac
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';


-- Q1
select *
from africa_fs_ac a
where item like('%Gross%');

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

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;


-- Q2
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;


-- exercises
-- create query for Q3: find the average GDP per capita for each african sub region
select m.sub_region_code, m.sub_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.sub_region_code, m.sub_region_name
order by m.sub_region_name;

-- create a query that gives avg gdp, max gdp, and min gdp over the years for each intermediate region
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp, 
round(max(value)::numeric, 0) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives avg, max, and min gdp for each intermediate region but only for 2011 to 2020
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp, 
round(max(value)::numeric, 0) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and item_code = '22013' and (a.year_code::numeric between 2011 and 2020)
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives min and max gdp for each intermediate region but show only countries where avg gdp is <= $4000
select m.intermediate_region_code, m.intermediate_region_name,
round(max(value)::numeric, 0) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name
having round(avg(value)::numeric, 0) <= 4000
order by m.intermediate_region_name;