--Leah Avilez (920788059)
set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded 
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
and intermediate_region_code is NULL
order by country_or_area;

select m49_code , country_or_area 
from m49_codes_expanded  
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;


select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;


select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

select count(*)
from africa_fs_after_cleaning_db a
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select *
from africa_fs_after_cleaning_db a
where item LIKE('%Gross%');

select area_code_m49, area, avg(value)
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;


select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp


select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(value)::numeric, 0) as avg_gdp
from 
    africa_fs_after_cleaning_db a 
join 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
where 
    item_code = '22013'
    and m.intermediate_region_code IS NOT NULL
group by 
    m.intermediate_region_code,
    m.intermediate_region_name
order by 
    m.intermediate_region_name;

   ----excercises for me
select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(AVG(a.value)::NUMERIC, 0) as avg_gdp,
    MAX(a.value) as max_gdp,
    MIN(a.value) as min_gdp
from 
    africa_fs_after_cleaning_db a
join 
    m49_codes_expanded m on m.m49_code = a.area_code_m49
where 
    a.item_code = '22013'
    and m.intermediate_region_code IS NOT NULL
group by 
    m.intermediate_region_code,
    m.intermediate_region_name
order by 
    m.intermediate_region_name;
   
 --query 2
 
  SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(a.value)::numeric, 0) AS avg_gdp,
    max(a.value) as max_gdp,
    min(a.value) as min_gdp
from 
    africa_fs_after_cleaning_db a
join 
    m49_codes_expanded m on m.m49_code = a.area_code_m49
where 
    a.item_code = '22013'
    and m.intermediate_region_code IS NOT NULL
    and cast(a.year as integer) between 2011 and 2020
group by
    m.intermediate_region_code,
    m.intermediate_region_name
order by 
    m.intermediate_region_name;
   
   --query 4
   
   select
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(AVG(a.value)::numeric, 0) AS avg_gdp,
    max(a.value) as max_gdp,
    min(a.value) as min_gdp
from 
    africa_fs_after_cleaning_db a join m49_codes_expanded m on m.m49_code = a.area_code_m49
where
    a.item_code = '22013'
    and m.intermediate_region_code IS NOT NULL
group by
    m.intermediate_region_code,
    m.intermediate_region_name
having
    avg(a.value) <= 4000
order by
    m.intermediate_region_name;

 


