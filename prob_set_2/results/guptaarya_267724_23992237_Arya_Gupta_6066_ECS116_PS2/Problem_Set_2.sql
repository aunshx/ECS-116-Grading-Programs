-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
--select * from m49_codes_expanded
-- where country_or_area = 'Angola'

-- find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
-- select distinct sub_region_name from m49_codes_expanded mce 
-- where region_name = 'Africa';

--select distinct intermediate_region_name 
--from m49_codes_expanded mce 
--where region_name = 'Africa';

-- finds all countries in Africa for which the sub_region name is NULL
select country_or_area 
from m49_codes_expanded
where region_name = 'AFRICA' and sub_region_name is null

-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name
select country_or_area from m49_codes_expanded
where intermediate_region_code = '' or intermediate_region_name = ''

-- for each country in Africa,
--   list the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions


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
--       (ignore countries that do not fall into one of the sub regions)

select m.sub_region_code,
       m.sub_region_name ,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       max(value) as max_gdp,
       min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
group by m.intermediate_region_code,
         m.intermediate_region_name,
         a.year
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       max(value) as max_gdp,
       min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
group by m.intermediate_region_code,
         m.intermediate_region_name,
         a.year
 having year between '2011' and '2020'
order by m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000

select m.intermediate_region_code,
       m.intermediate_region_name,
       max(value) as max_gdp,
       min(value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
group by m.intermediate_region_code,
         m.intermediate_region_name
having avg(value) <= 4000 
order by m.intermediate_region_name;

select * from m49_codes_expanded mce 
