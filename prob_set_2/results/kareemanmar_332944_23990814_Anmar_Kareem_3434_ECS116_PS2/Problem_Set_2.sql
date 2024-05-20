set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

-- Data looks like csv
select * from m49_codes_expanded;

-- tuple count matches
select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded m49
where country_or_area = 'Angola';

select distinct sub_region_name
from m49_codes_expanded m49
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded m49
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

select m49_code , country_or_area
from m49_codes_expanded m49
where region_name = 'Africa' and intermediate_region_code ISNULL
order by country_or_area;

select m49_code , country_or_area
from m49_codes_expanded m49
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;

-- Exercise (names column isn't specified so I will go with region_name)
select m49_code , country_or_area
from m49_codes_expanded m49
where intermediate_region_code = '' or region_name = ''
order by country_or_area;

select distinct a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, 
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

-- Q1
select area_code_m49, area, round(avg(value), 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;
-- Q2
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3
select m.sub_region_code, m.sub_region_name, round(avg(value)) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.sub_region_code != ''
group by m.sub_region_code, m.sub_region_name
order by m.sub_region_name;

-- Exercise 1
select m.intermediate_region_code, m.intermediate_region_name, round(avg(a.value)) as avg_gdp, 
max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercise 2
select m.intermediate_region_code, m.intermediate_region_name, round(avg(a.value)) as avg_gdp, 
max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' 
and m.intermediate_region_code != '' and cast(a.year_code as int) between 2011 and 2020
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercise 3
select m.intermediate_region_code, m.intermediate_region_name, round(avg(a.value)) as avg_gdp, 
max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
having round(avg(a.value)) <= 4000
order by m.intermediate_region_name;