set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;
--was 0
SELECT COUNT(*) FROM m49_codes_expanded;
--299

select * from m49_codes_expanded mce;

select * from m49_codes_expanded mce 
where country_or_area = 'Angola';

select distinct sub_region_name from m49_codes_expanded mce
where region_name = 'Africa';

select distinct intermediate_region_name  from m49_codes_expanded mce
where region_name = 'Africa';

--both had empty inputs in row 2

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

--how to list only the countries that have empty string for intermediate_region_code or name
select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and (intermediate_region_code = '' or intermediate_region_name = '')
order by country_or_area;
--include the "or" inside of the "and" to have the int region name included in this selection process

select country_or_area, intermediate_region_name, intermediate_region_code, sub_region_code, sub_region_name, m49_code 
from m49_codes_expanded 
where region_name = 'Africa'
order by country_or_area;

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code::integer = a.area_code_m49::integer and sr.m49_code::integer = a.area_code_m49::integer;
--was getting a bunch of table referencing errors

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code::integer = a.area_code_m49::integer
  and sr.m49_code::integer = a.area_code_m49::integer 
  and a.area_code_m49::integer = '024';

select count(*)
from africa_fs_ac 
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code::integer = a.area_code_m49::integer
  and sr.m49_code::integer = a.area_code_m49::integer;
 
 -- Q1: find the average GDP per capita for each african country (going over all years)
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and ignoring countries not in any intermediate region)
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code::integer = a.area_code_m49::integer 
  and item_code::integer = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
select m.sub_region_code ,
       m.sub_region_name ,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code::integer = a.area_code_m49::integer 
  and item_code::integer = '22013'
group by m.sub_region_code ,
         m.sub_region_name 
order by m.sub_region_name ;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp, min(value) as min_gdp, max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code::integer = a.area_code_m49::integer 
  and item_code::integer = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp, min(value) as min_gdp, max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code::integer = a.area_code_m49::integer 
  and item_code::integer = '22013'
  and a.year::integer between 2011 and 2020
  and intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
select m.intermediate_region_code,
       m.intermediate_region_name,
       min(value) as min_gdp, max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code::integer = a.area_code_m49::integer 
  and item_code::integer = '22013'
  and a.year::integer between 2011 and 2020
  and intermediate_region_code != ''
  and a.value <= 4000
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


