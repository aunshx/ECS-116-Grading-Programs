set search_path to food_sec;

-- delete data after changing column data types 
delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

-- sanity check after re-importing 
select count(*) from m49_codes_expanded;

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
select * from m49_codes_expanded 
where country_or_area = 'Angola';

-- so: Angola is in
 -- intermediate_region "Middle Africa"
 -- sub_region  "Sub-Saharan Africa"
 -- region  "Africa"
     
-- before we go on, let's see the values for itermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
   
-- for sub regions 
select distinct sub_region_name 
from m49_codes_expanded where region_name = 'Africa';

-- for intermediate regions
select distinct intermediate_region_name  
from m49_codes_expanded where region_name = 'Africa';

-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name
select m49_code, country_or_area, intermediate_region_name, intermediate_region_code
from m49_codes_expanded 
where intermediate_region_name  = '' or intermediate_region_code = '';

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
-- (Condsider trying to create this query on your own, before seeing
--    how I do it)

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
 
 -- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q1:  (try this yourself before looking at my answer!)
-- Hint: first, let's find where the values for GDP per capita are
 select area, round(avg(value)::numeric, 2) as avg_gdp from africa_fs_ac a where a.item_code = '22013'
group by area;
 
 -- Q2: find the average GDP per capita for each african intermediate region
select intermediate_region_name, round(avg(value)::numeric, 2)
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and a.item_code = '22013'
and m.intermediate_region_name != ''
group by intermediate_region_name
order by m.intermediate_region_name;


 -- Exercises for you:

-- create a query for Q3 mentioned above
 -- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
select sub_region_name, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and a.item_code = '22013'
group by sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
select intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp, max(value), min(value)
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and a.item_code = '22013'
and intermediate_region_name  != '' 
group by intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

select intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp, max(value), min(value)
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and a.item_code = '22013'
and intermediate_region_name  != ''  
and a.year_code::int <= 2020 and a.year_code::int >= 2011
group by intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

 select intermediate_region_name, max(value), min(value)
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 and a.item_code = '22013'
and intermediate_region_name  != ''  
group by intermediate_region_name
having avg(value) <=4000;
 
 
