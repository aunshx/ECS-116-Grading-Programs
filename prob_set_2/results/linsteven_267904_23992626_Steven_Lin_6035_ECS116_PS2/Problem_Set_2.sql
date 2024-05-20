set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded mce; 
-- 0 entries

-- import csv file directly to table

select count(*) from m49_codes_expanded mce; 
-- 299 entries

select * from m49_codes_expanded mce where country_or_area = 'Angola';

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
-- does not work because fields are actually empty strings

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;

select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
  and intermediate_region_code = ''
  and entity_category = 'current country'
order by country_or_area;
-- only list countries in Africa (filter out bigger regions)

select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
 
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49 
  and a.area_code_m49 = '024';
 
 select count(*)
from africa_fs_ac 
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
 
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

-- Q3

-- Show avg, max, and min gdp for regions in Africa
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Show avg, max, and min gdp for regions in Africa between 2011 and 2020
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
  and (a.year_code = '2011' 
  	or a.year_code = '2012' 
  	or a.year_code = '2013' 
  	or a.year_code = '2014'
  	or a.year_code = '2015'
  	or a.year_code = '2016'
  	or a.year_code = '2017'
  	or a.year_code = '2018'
  	or a.year_code = '2019'
  	or a.year_code = '2020')
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Show max and min gdp for regions in Africa where avg gdp <= 4000
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(max(value)::numeric, 0) as max_gdp,
       round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
having avg(value) <= 4000
order by m.intermediate_region_name;

