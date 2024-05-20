-- Basics
set search_path to food_sec;
show search_path;


-- create a query that gives the row of m49_codes_expanded for 
-- the country "Angola"
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';


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


-- Here's a query that finds all countries in Africa for which the
-- intermediate_region_name is NULL
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;


-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;


-- Now, I want to practice doing some aggregation (group-by) queries
-- that use groupings by sub- and intermediate-regions
select *
from africa_fs_ac afa
where item LIKE('%Gross%');


-- rounded 2 to decimal places
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;


-- now, how about Q2, getting avg gdp grouped by intermediate region
-- and not including countries not in any intermediate region
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


-- Exercises for you:
-- create a query for Q3 mentioned above
select m.sub_region_code,
       m.sub_region_name,
       round(avg(a.value)::numeric, 0) AS avg_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m ON a.area_code_m49 = m.m49_code
where a.item_code = '22013'
  and m.sub_region_code != ''
group by m.sub_region_code, m.sub_region_name
order by m.sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica
-- and not including countries where intermediate region is empty
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(a.value)::numeric, 0) as avg_gdp,
       max(a.value) as max_gdp,
       min(a.value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on a.area_code_m49 = m.m49_code
where a.item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
-- (and not including countries where intermediate region is empty)
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(a.value)::numeric, 0) as avg_gdp,
       max(a.value) as max_gdp,
       min(a.value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on a.area_code_m49 = m.m49_code
where a.item_code = '22013'
  and m.intermediate_region_code != ''
  and cast(a.year as integer) between 2011 and 2020
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)
select m.intermediate_region_code,
       m.intermediate_region_name,
       min(a.value) as min_gdp,
       max(a.value) as max_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on a.area_code_m49 = m.m49_code
where a.item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
having avg(a.value) <= 4000
order by m.intermediate_region_name;


