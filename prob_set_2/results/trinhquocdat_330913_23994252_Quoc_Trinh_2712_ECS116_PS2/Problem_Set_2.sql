set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded
where country_or_area = 'Angola';

select distinct sub_region_name
from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

--There are null values here in these 2 queries because in query 1, I am trying to query the unique values given the
--region name is Africa and since there are null values for sub region name, this mean there have to be at least 1 empty values
--here. This same reason also applied for the second query

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code ISNULL
order by country_or_area;

--This query came up empty even when I tried to search for null values because the empty values are not actually null 
--but empty string

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and (intermediate_region_code = '' or intermediate_region_name = '')
order by country_or_area;

select distinct 
    a.area_code_m49,
    a.area,
    ir.intermediate_region_code,
    ir.intermediate_region_name,
    sr.sub_region_code,
    sr.sub_region_name
from
    africa_fs_after_cleaning_db a,
    m49_codes_expanded ir,
    m49_codes_expanded sr
where
    ir.m49_code = a.area_code_m49
    and sr.m49_code = a.area_code_m49;
    
-- Q1: find the average GDP per capita for each african country (going over all years)
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;
-- Q2: find the average GDP per capita for each african intermediate region
select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_code,
m.intermediate_region_name
order by m.intermediate_region_name;
-- Q3: find the average GDP per capita for each african sub region
-- (ignore countries that do not fall into one of the sub regions)
select m.sub_region_code ,m.sub_region_name , round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.sub_region_code ,
m.sub_region_name 
order by m.sub_region_name ;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica

select a.year_code, round(avg(value)::numeric, 0) as avg_gdp, round(max(value)::numeric, 0 ) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where item_code = '22013'
and intermediate_region_code != ''
and intermediate_region_name != ''
group by a.year_code 
order by a.year_code;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
select a.year_code,m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp, round(max(value)::numeric, 0 ) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where item_code = '22013'
and m.region_name = 'Africa'
and m.m49_code = a.area_code_m49 
and a.year_code::numeric between 2011 and 2022
and intermediate_region_code != ''
and intermediate_region_name != '' 
group by a.year_code, m.intermediate_region_code , m.intermediate_region_name 
order by a.year_code;

-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
select m.intermediate_region_code, m.intermediate_region_name, round(max(value)::numeric, 0 ) as max_gdp, round(min(value)::numeric, 0) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where item_code = '22013'
and m.region_name = 'Africa'
and m.m49_code = a.area_code_m49
and intermediate_region_code != ''
and intermediate_region_name != '' 
group by a.year_code, m.intermediate_region_code , m.intermediate_region_name 
having round(avg(value)::numeric, 0) <= 4000;