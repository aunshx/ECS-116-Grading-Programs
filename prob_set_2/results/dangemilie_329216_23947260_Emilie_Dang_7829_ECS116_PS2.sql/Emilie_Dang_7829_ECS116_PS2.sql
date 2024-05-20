set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;
-- The table is empty

select count(*) from m49_codes_expanded;
--- The count of tuples in my table match the count in the csv file

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
order by intermediate_region_name, country_or_area;

select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_name isnull 
order by country_or_area;

select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_name = ''
order by country_or_area;

-- Exercise for you
select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa' 
and entity_category = 'current country'
and intermediate_region_name = '' or intermediate_region_code = '';

select afa.area_code_m49, afa.area,
ir. intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac afa , m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = afa.area_code_m49
and sr.m49_code = afa.area_code_m49;

select afa.area_code_m49, afa.area,
ir. intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac afa , m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = afa.area_code_m49
and sr.m49_code = afa.area_code_m49
and afa.area_code_m49 = '24';

select count(*)
from africa_fs_ac afa
where area_code_m49 = '24';

select distinct afa.area_code_m49, afa.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac afa, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = afa.area_code_m49 
and sr.m49_code = afa.area_code_m49;

-- Q1
select * from africa_fs_ac afa 
where item like('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Rounding the average gdp to two decimal places
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Formatting it to look nicer
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2
select mce.intermediate_region_code, mce.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code  = '22013' and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name 
order by mce.intermediate_region_name;

-- Exercises for you
-- Create a query for Q3
select mce.sub_region_code, mce.sub_region_name, afa.area,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code  = '22013' and mce.sub_region_code != ''
group by mce.sub_region_code, mce.sub_region_name, afa.area
order by mce.sub_region_name;

-- Create a query that gives the avg gdp, max gdp, and min gdp over the years for each intermediate region in Africa
select mce.intermediate_region_code, mce.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp,
round(max(value)::numeric, 0) as max_gdp,
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code  = '22013'
and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- Create a query that gives the avg, max, and min gdp for each intermediate region in Africa but just for 2011 to 2020
select mce.intermediate_region_code, mce.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp,
round(max(value)::numeric, 0) as max_gdp,
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code  = '22013' and afa."year" >= '2011' and afa."year" <= '2020' 
and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name; 

-- Create a query that gives the max and min gdp for each intermediate region in Africa but show only countries where the avg gdp is <= $4000
select mce.intermediate_region_code, mce.intermediate_region_name, afa.area,
round(max(value)::numeric, 0) as max_gdp,
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code  = '22013'
and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name, afa.area
having avg(value) <= 4000
order by mce.intermediate_region_name;