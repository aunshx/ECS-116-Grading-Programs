set search_path to food_sec
delete from m49_codes_expanded mce 
select count(*) from m49_codes_expanded mce 
select * from m49_codes_expanded mce 
-- I checked by uploading the csv file, and the number of rows match.

-- specifically: create a query that gives the row of m49_codes_expanded for the country "Angola"
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';
-- Angola is an:
-- intermediate_region "Middle Africa"
-- sub_region "Sub-Saharan Africa"
-- region "Africa"

-- the two queries are: find distinct sub-region names associated with
-- countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- a query that finds all countries in Africa for which the intermediate_region_name is NULL
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code ISNULL
order by country_or_area;

-- a query that finds all countries in Africa for which the intermediate_region is an empty string ''
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

-- Exercise for you: list only the countries that have empty string for intermediate_region_code or name
select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- Q1: find the average GDP per capita for each african country (going over all years)
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2: find the average gdp per capita grouped by intermediate region 
-- (not including countries not in any intermediate region)
select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3: find the average GDP per capita for each african sub region 
-- (ignore countries that do not fall into one of the sub regions)
SELECT m.sub_region_code,
m.sub_region_name,
ROUND(avg(value)::numeric, 0) AS avg_gdp
FROM africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and item_code = '22013'
and m.sub_region_code!= ''
group by m.sub_region_code, m.sub_region_name
ORDER BY m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp over the years
-- for each intermeidate region in Africa and not including countries where intermediate region is empty
select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp for each intermediate region in Africa,
-- but just for 2011 to 2020(and not including countries where intermediate region is empty)
select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
and a.year >= '2012'
and '2020' >= a.year
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives min and max gdp for each intermediate region in Africa (going across all years)
-- but show only countries where the avg gdp is <= $4000 (and not including countries where intermediate region is empty)
select m.intermediate_region_code,
m.intermediate_region_name,
max(value) as max_gdp, min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
and value <= '4000'
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;


