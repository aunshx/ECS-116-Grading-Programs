set search_path to food_sec;

show search_path;

select * 
from m49_codes_expanded mce 
where country_or_area = 'Angola';

select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

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



-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

select *
from m49_codes_expanded
where intermediate_region_code = '' or intermediate_region_name = '';

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;

 
 -- Q1
 
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

  
select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2
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

-- Q3:  find the average GDP per capita for each african sub region

select m.sub_region_code,
       m.sub_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.sub_region_code != ''
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       min(value) as min_gdp,
       max(value) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       min(value) as min_gdp,
       max(value) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and ROUND(year_code / 10000, 0) >= 2011 or ROUND(year_code / 10000, 0) <= 2020
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       min(value) as min_gdp,
       max(value) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
having avg(value) <= 4000
order by m.intermediate_region_name;






