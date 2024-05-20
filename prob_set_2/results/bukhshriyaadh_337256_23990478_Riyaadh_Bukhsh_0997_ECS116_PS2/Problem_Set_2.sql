-- Basics

set search_path to food_sec;

delete from m49_codes_expanded;

-- Sanity Check
select count(*)
from m49_codes_expanded mce; 


-- After importing find teh row of data with country Angola
select *
from m49_codes_expanded mce 
where country_or_area  = 'Angola';


-- Find distinc intermediate region names with countries in Africa
select distinct intermediate_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name;

-- Find distinc sub region names with countries in Africa
select distinct sub_region_name  
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name; 

select *
from m49_codes_expanded mce 
where region_name  = 'Africa'
and intermediate_region_code = '';

select country_or_area , intermediate_region_name, sub_region_name 
from m49_codes_expanded mce 
where region_name  = 'Africa'
and intermediate_region_code = ''
and entity_category = 'current country';



-- Listing all countries is Africa

select country_or_area , intermediate_region_name, sub_region_name, m49_code  
from m49_codes_expanded mce 
where region_name  = 'Africa'
and entity_category = 'current country';






-- Query to include country,intermediate region sub region and m49 codes

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;


-- Q1 Find the average GDP per capita for each african country (going over all years)


select distinct item_code, item, unit 
from africa_fs_ac afa ;

-- We find that the item code for GDP is 22,013



select area,area_code_m49, avg(value) as average_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 ,area 
order by area;

-- Rounding the values to 2 digits

select area,area_code_m49, round(avg(value)::numeric, 2) as average_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 ,area 
order by area;

-- pretty output

select area,area_code_m49, to_char(avg(value), 'FM9999999999.00') as average_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49 ,area 
order by area;






-- Q2 

select avg(a.value) as average_gdp, m.intermediate_region_code ,m.intermediate_region_name 
from africa_fs_ac a , m49_codes_expanded m
where m.m49_code =a.area_code_m49 
and a.item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code ,m.intermediate_region_name 
order by m.intermediate_region_name ;




-- Q3


select avg(value) as average_gdp,m.sub_region_code ,m.sub_region_name 
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and m.sub_region_code != ''
and a.item_code = '22013'
group by m.sub_region_code ,m.sub_region_name 
order by m.sub_region_name; 




-- Q4




select  m.intermediate_region_code ,m.intermediate_region_name, avg(value) as average_gdp,
min(value) as min_gdp,max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and m.intermediate_region_code != ''
and a.item_code = '22013'
group by m.intermediate_region_code ,m.intermediate_region_name
order by m.intermediate_region_name ;


-- Q5

select  m.intermediate_region_code ,m.intermediate_region_name, avg(value) as average_gdp,
min(value) as min_gdp,max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and m.intermediate_region_code != ''
and a.item_code = '22013'
and a.year <='2020'
and a.year >= '2011'
group by m.intermediate_region_code ,m.intermediate_region_name
order by m.intermediate_region_name; 


-- Q6

select  m.intermediate_region_code ,m.intermediate_region_name,
min(value) as min_gdp,max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
and m.intermediate_region_code != ''
and a.item_code = '22013'
group by m.intermediate_region_code ,m.intermediate_region_name
having avg(value) <= 4000
order by m.intermediate_region_name; 



