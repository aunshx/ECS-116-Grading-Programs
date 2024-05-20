set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;
-- count is 0, sanity check -> the table is empty

-- give the row for Angola 
select * -- select all
from m49_codes_expanded mce
where country_or_area = 'Angola';


-- find sub-region names associated with counties in africa 

select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name;

-- find intermediate region names

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'; and intermediate_region_code isnull 
order by country_or_area;


-- all countries where sub_region is empty (not NULL)
select m49_code, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;


-- list only the countries that have empty string for intermediate_region_code or name 
select m49_code, country_or_area
from m49_codes_expanded mce
where region_name = '' or intermediate_region_code = ''
order by country_or_area;

-- list for each country in Africa the country, the intermediate_region and the sub_region. 
select distinct a.area_code_m49, a.area, 
ir.intermediate_region_code, ir.intermediate_region_name, 
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

-- Q1: average GDP per capita for each african country
select * 
from africa_fs_ac afa
where item like('%Gross%');

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

-- Q2: avg gdp grouped by intermediate region

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;



-- Q3: avg gdp per capita for each sub region

select m.intermediate_region_code, m.sub_region_name,
	round(avg(value)::numeric,0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.sub_region_code, m.sub_region_name 
order by m.sub_region_name;


-- avg gdp, max gdp, min gdp over the years for each intermediate region in africa

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;



-- avg, max, min gdp for each intermediate region in africa from 2011 to 2020


select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and year >= 2011 and year <= 2020
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and year >= 2011 and year <= 2020
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and year >= 2011 and year <= 2020
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;



-- min and max gdp for each intermediate region where avg gdp is <= $4000


select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and gdp <= 4000
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013'and gdp <= 4000
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;

select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric,0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and gdp <= 4000
group by m.intermediate_region_code, m.intermediate_region_name 
order by m.intermediate_region_name;




