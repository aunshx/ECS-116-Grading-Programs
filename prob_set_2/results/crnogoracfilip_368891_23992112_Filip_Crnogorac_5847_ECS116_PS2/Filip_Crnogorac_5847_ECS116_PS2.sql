set search_path to food_sec

select count(value) from africa_fs_after_cleaning_db  where value <= 2 

delete from africa_fs_after_cleaning_db;
delete from m49_codes_expanded;
select count(*)from m49_codes_expanded;
select * from m49_codes_expanded where country_or_area  = 'Angola';

select distinct sub_region_name from m49_codes_expanded where region_name = 'Africa'; 
select distinct intermediate_region_name from m49_codes_expanded where region_name = 'Africa';

select distinct m49_code  from m49_codes_expanded where region_name = 'Africa' and intermediate_region_name = '';

select distinct country_or_area  from m49_codes_expanded where region_name = 'Africa' and
(intermediate_region_code ='' or intermediate_region_name = '');

select distinct a.area_code_m49, a.area, 
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
 
select *
from africa_fs_after_cleaning_db afa
where item LIKE('%Gross%');
 
 select round(avg(value)::numeric, 2) as avg_gdp, area from africa_fs_after_cleaning_db a where item_code = 22013 group by area;
 
 select round(avg(value)::numeric, 2) as avg_gdp, b.intermediate_region_name, b.intermediate_region_code  
from africa_fs_after_cleaning_db a, m49_codes_expanded b 
where b.m49_code = a.area_code_m49 and 
item_code = 22013 group by b.intermediate_region_name, b.intermediate_region_code ;

 select round(avg(value)::numeric, 2) as avg_gdp,min(value) as min, max(value) as max, a.year  
from africa_fs_after_cleaning_db a, m49_codes_expanded b 
where b.m49_code = a.area_code_m49 and 
item_code = 22013 group by a.year;


select round(avg(value)::numeric, 2) as avg_gdp,min(value) as min, max(value) as max, b.intermediate_region_name, b.intermediate_region_code  
from africa_fs_after_cleaning_db a, m49_codes_expanded b 
where b.m49_code = a.area_code_m49 and 
item_code = 22013 group by b.intermediate_region_name, b.intermediate_region_code ;

select SUBSTRING(a.year  FROM '^(?:.{2}(.{2}))')::INTEGER from africa_fs_after_cleaning_db a;
select (SUBSTRING(a.year  FROM  '^(?:.{7}(.{2}))')::INTEGER) from africa_fs_after_cleaning_db a;

select round(avg(value)::numeric, 2) as avg_gdp,min(value) as min, max(value) as max,
b.intermediate_region_name, b.intermediate_region_code  
from africa_fs_after_cleaning_db a, m49_codes_expanded b 
where item_code = 22013 and b.m49_code = a.area_code_m49 and 
10 < (SUBSTRING(a.year  FROM '^(?:.{2}(.{2}))')::INTEGER) and
20 >= (SUBSTRING(a.year  FROM  '^(?:.{7}(.{2}))')::INTEGER) 
group by b.intermediate_region_name, b.intermediate_region_code ;


select round(avg(value)::numeric, 2) as avg_gdp,min(value) as min, max(value) as max, b.intermediate_region_name, b.intermediate_region_code  
from africa_fs_after_cleaning_db a, m49_codes_expanded b 
where b.m49_code = a.area_code_m49 and 
item_code = 22013 
group by b.intermediate_region_name, b.intermediate_region_code
having avg(value) <= 4000;

