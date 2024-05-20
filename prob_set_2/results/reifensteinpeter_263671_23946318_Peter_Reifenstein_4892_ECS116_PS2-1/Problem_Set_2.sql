set search_path to food_sec;
show search_path;

-- Kemper 47 OH (Basement) 12-2 Thursday

-- manually imported table
-- I manually altered the table to change the data types
delete from m49_codes_expanded ;
-- table is clear
select count(*) from m49_codes_expanded ;

-- now I added the data back into the table

-- test query
select * from m49_codes_expanded m where m.country_or_area  = 'Angola';

-- find distrinct sub_region_names and intermediate_region names
select distinct mce.sub_region_name from m49_codes_expanded mce where mce.region_name = 'Africa';
select distinct mce.intermediate_region_name from m49_codes_expanded mce where mce.region_name = 'Africa';

-- investigating null values, and list only countries
select m49_code , country_or_area, sub_region_name from m49_codes_expanded 
where region_name = 'Africa'and intermediate_region_code = '' and country_or_area != sub_region_name
order by country_or_area;

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
SELECT mce.country_or_area, mce.m49_code, mce.intermediate_region_name, mce.intermediate_region_code
, mce.sub_region_name, mce.sub_region_code FROM m49_codes_expanded mce where mce.region_name = 'Africa';

-- OR
select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where a.area_code_m49 = ir.m49_code
and a.area_code_m49 = sr.m49_code;

-- restrict to angola to see how many there are of the same region
select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where a.area_code_m49 = ir.m49_code
and a.area_code_m49 = sr.m49_code
and a.area_code_m49  = '24';

-- how many are there?
select count(*) from africa_fs_after_cleaning_db afacd 
where afacd.area_code_m49 = '24';

-- get only the distrinct entries
select distinct a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where a.area_code_m49 = ir.m49_code
and a.area_code_m49 = sr.m49_code;

-- 1) avg. gdp per capita for each country
-- searching for correct col
select *
from africa_fs_after_cleaning_db afacd
where afacd.item like('%Gross%');

-- we can see that the item code is 22013

-- final query
select afacd.area_code_m49 , afacd.area, AVG(afacd.value)
from africa_fs_after_cleaning_db afacd
where afacd.item_code = '22013'
group by afacd.area, afacd.area_code_m49
order by afacd.area;

-- rounded
select afacd.area_code_m49 , afacd.area, round(AVG(afacd.value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db afacd
where afacd.item_code = '22013'
group by afacd.area, afacd.area_code_m49
order by afacd.area;

-- extra pretty (left oriented as characters)
select afacd.area_code_m49 , afacd.area, to_char(AVG(afacd.value), 'FM999999999.00') as avg_gdp
from africa_fs_after_cleaning_db afacd
where afacd.item_code = '22013'
group by afacd.area, afacd.area_code_m49
order by afacd.area;

-- 2) avg. gdp per capita for intermediate regions
select m.intermediate_region_code , m.intermediate_region_name, round(AVG(a.value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where a.item_code = '22013'
and a.area_code_m49 = m.m49_code 
group by m.intermediate_region_code , m.intermediate_region_name 
order by m.intermediate_region_name;

-- 3)average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)

select m.sub_region_code , m.sub_region_name, round(AVG(a.value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where a.item_code = '22013'
and a.area_code_m49 = m.m49_code -- this is the country code
group by m.sub_region_code  , m.sub_region_name  
order by m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica

select m.intermediate_region_code , m.intermediate_region_name, round(AVG(a.value)::numeric, 0) as avg_gdp, 
MAX(a.value) as max_gdp, MIN(a.value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where a.item_code = '22013'
and a.area_code_m49 = m.m49_code 
group by m.intermediate_region_code , m.intermediate_region_name 
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
select m.intermediate_region_code , m.intermediate_region_name, round(AVG(a.value)::numeric, 0) as avg_gdp, 
MAX(a.value) as max_gdp, MIN(a.value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where a.item_code = '22013'
and a.area_code_m49 = m.m49_code 
and cast(a.year_code as int) >= 2011 and cast(a.year_code as int) <= 2020
group by m.intermediate_region_code , m.intermediate_region_name 
order by m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only INTERMEDIATE REGIONS where the avg gdp is <= $4000

select m.intermediate_region_code , m.intermediate_region_name, MIN(a.value) as min_gdp, MAX(a.value) as max_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where a.item_code = '22013'
and a.area_code_m49 = m.m49_code 
group by m.intermediate_region_code , m.intermediate_region_name 
having avg(a.value) < 4000
order by m.intermediate_region_name;

