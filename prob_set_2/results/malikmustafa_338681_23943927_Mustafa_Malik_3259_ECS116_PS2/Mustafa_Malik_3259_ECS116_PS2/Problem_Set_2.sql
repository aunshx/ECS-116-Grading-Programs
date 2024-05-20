set search_path to food_sec

show search_path

delete from m49_codes_expanded

select count(*) from m49_codes_expanded

select *
from m49_codes_expanded mce
where mce.country_or_area = 'Angola'


select distinct mce.sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name 



select distinct mce.intermediate_region_name, mce.country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name, country_or_area 


select distinct a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
				sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49


-- Q1: find the average GDP per capita for each african country (going over all years)

select afa.area, avg(afa.value) as avg_gdp
from africa_fs_ac afa
where item_code = '22013' 
group by afa.area
order by afa.area


-- Q2: find the average GDP per capita for each african intermediate region

select mce.intermediate_region_name, avg(afa.value) as avg_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.item_code = '22013'
and mce.m49_code = afa.area_code_m49
group by mce.intermediate_region_name 
order by mce.intermediate_region_name


-- Q3: find the average GDP per capita for each african sub region

select mce.sub_region_name, avg(afa.value) as avg_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.item_code = '22013'
and mce.m49_code = afa.area_code_m49
group by mce.sub_region_name 
order by mce.sub_region_name


-- Create a query that gives the avg gdp, the max gdp, and the min gdp for each intermediate region in Africa

select mce.intermediate_region_name, avg(afa.value) as avg_gdp,
									 max(afa.value) as max_gdp,
									 min(afa.value) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.item_code = '22013'
and mce.m49_code = afa.area_code_m49
group by mce.intermediate_region_name 
order by mce.intermediate_region_name


-- Create a query that gives the avg, max and min gdp for each intermediate region in Africa, but just for 2011 to 2020

select mce.intermediate_region_name, avg(afa.value) as avg_gdp,
									 max(afa.value) as max_gdp,
									 min(afa.value) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.item_code = '22013'
and mce.m49_code = afa.area_code_m49
and cast(afa."year" as int) > 2010
and cast(afa."year" as int) < 2021
group by mce.intermediate_region_name 
order by mce.intermediate_region_name


-- Create a query that gives min and max gdp for each intermediate region but show only countries where the avg gdp is <= $4000

select mce.intermediate_region_name, afa.area, max(afa.value) as max_gdp, min(afa.value) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.item_code = '22013'
and mce.m49_code = afa.area_code_m49
group by mce.intermediate_region_name, afa.area
having avg(afa.value) <= 4000
order by mce.intermediate_region_name

