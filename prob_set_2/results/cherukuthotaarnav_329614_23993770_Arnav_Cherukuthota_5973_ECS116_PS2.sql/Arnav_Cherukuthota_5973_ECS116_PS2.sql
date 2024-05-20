SET search_path TO food_sec;

show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

select * from m49_codes_expanded mce where country_or_area like 'Angola';

select distinct sub_region_name from m49_codes_expanded mce where region_name like 'Africa' order by sub_region_name; 

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name like 'Africa'
order by intermediate_region_name , country_or_area;

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name like 'Africa' 
and intermediate_region_code isnull 
order by country_or_area;

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;


-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name

select intermediate_region_code , region_name 
from m49_codes_expanded
where intermediate_region_code isnull 
and region_name = '' 	
order by intermediate_region_code, region_name;

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, 
sr.sub_region_code, sr.sub_region_name from africa_fs_after_cleaning_db a, m49_codes_expanded ir, 
m49_codes_expanded sr where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;
	
select count(*) from africa_fs_ac where area_code_m49 = '024';

select distinct a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name from africa_fs_after_cleaning_db a, m49_codes_expanded ir, 
m49_codes_expanded sr where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

select * from africa_fs_after_cleaning_db afa where item LIKE('%Gross%');

select area_code_m49, area, avg(value) from africa_fs_after_cleaning_db a where item_code like '22013'
group by area_code_m49, area order by area;

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp from africa_fs_after_cleaning_db 
where item_code = '22013' group by area_code_m49, area order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_after_cleaning_db a where item_code = '22013' group by area_code_m49, area
order by area;

select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m where m.m49_code = a.area_code_m49
and item_code = '22013' group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- "Exercises for you"

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in Africa
select region_name, intermediate_region_name, avg(country_gdp) AS avg_gdp, max(country_gdp) AS max_gdp, 
min(country_gdp) AS min_gdp from m49_codes_expanded where region_name like 'Africa'
order by intermediate_region_name region_name;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020

select region_name, intermediate_region_name, avg(country_gdp) AS avg_gdp, max(country_gdp) 
AS max_gdp, min(country_gdp) AS min_gdp from m49_codes_expanded
where region_name like 'Africa' and year between 2011 and 2020
order by intermediate_region_name region_name;

-- ceate a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

select region_name, intermediate_region_name, avg(country_gdp) AS avg_gdp, max(country_gdp) 
AS max_gdp, min(country_gdp) AS min_gdp from m49_codes_expanded
where region_name like 'Africa' and avg(country_gdp) <= 4000
order by intermediate_region_name;
