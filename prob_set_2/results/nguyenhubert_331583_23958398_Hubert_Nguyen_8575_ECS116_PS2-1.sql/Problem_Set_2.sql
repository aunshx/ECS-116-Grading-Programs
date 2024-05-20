-- Hubert Nguyen Problem Set 2
-- set search path
set search_path to food_sec;
show search_path;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

-- query that gives the row of m49_codes_expanded for the country "Angola"
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

-- find distinct sub-region names associated with 
-- countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- query that finds all countries in Africa for which the sub_region name is NULL
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code = ''
order by country_or_area;

-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
SELECT country_or_area, intermediate_region_code, intermediate_region_name
FROM m49_codes_expanded
WHERE (COALESCE(intermediate_region_code, '') = '' OR COALESCE(intermediate_region_name, '') = '')
  AND country_or_area IS NOT NULL
  AND country_or_area <> '';
 
-- Here is a query that lists, for each country in Africa,
-- the country, the intermediate_region and the sub_region,
-- including both names and m49 codes for the countries/regions
select distinct a.area_code_m49, a.area,
		ir.intermediate_region_code, ir.intermediate_region_name,
		sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
	and sr.m49_code = a.area_code_m49;

-- Q1: find the average GDP per capita for each african country (going over all years)
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2: find the average GDP per capita for each african intermediate region
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


-- Q3: find the average GDP per capita for each african sub region
select m.sub_region_code,
		m.sub_region_name,
		round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
group by m.sub_region_code,
		m.sub_region_name
order by m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years for each intermeidate region in AFrica and not including
-- countries where intermediate region is empty
select m.intermediate_region_code,
    m.intermediate_region_name,
    a.year,
    round(avg(a.value)::numeric, 0) as avg_gdp,
    max(a.value) as max_gdp,
    min(a.value) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013'  
    and m.intermediate_region_name is not null 
    and m.intermediate_region_name <> ''  
    and m.region_code = '002' 
group by m.intermediate_region_code,
    m.intermediate_region_name,
    a.year
order by m.intermediate_region_name,
    a.year;


-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa, but just for 2011 to 2020
-- and not including countries where the intermediate region is empty
select m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(a.value)::numeric, 0) as avg_gdp,
    max(a.value) as max_gdp,
    min(a.value) as min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013'  -- assuming this is the correct item code for gdp
    and cast(a.year as integer) between 2011 and 2020  
    and m.intermediate_region_name is not null  
    and m.intermediate_region_name <> ''  
group by m.intermediate_region_code,
    m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives min and max gdp for each intermediate region in Africa
-- (going across all years) but show only countries where the avg gdp is <= $4000
-- and not including countries where the intermediate region is empty
select m.intermediate_region_code,
    m.intermediate_region_name,
    min(a.value) as min_gdp,
    max(a.value) as max_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where m.intermediate_region_name is not null  
    and m.intermediate_region_name <> ''      
group by m.intermediate_region_code,
    m.intermediate_region_name
having avg(a.value)::numeric <= 4000         
order by m.intermediate_region_name;


   









