set search_path to food_sec;

show search_path;


delete from m49_codes_expanded;

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
and sr.m49_code = a.area_code_m49 

--Q1: find the average GDP per capita for reach african country (going over all years) 
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

--Q2: find the average GDP per capita for each african intermediate region

select m.intermediate_region_code,
	m.intermediate_region_name,
	round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
  and item_code = '22013'
group by m.intermediate_region_code,
	m.intermediate_region_name
order by m.intermediate_region_name;


--Q3: find the average GDP per capita for each african sub region 

select sr.sub_region_code, 
    sr.sub_region_name, 
    round(avg(afa.value)::numeric, 2) as avg_gdp_per_capita
from africa_fs_ac afa join m49_codes_expanded sr on sr.m49_code = afa.area_code_m49
where afa.item_code = '22013'  
group by sr.sub_region_code, sr.sub_region_name
order by sr.sub_region_name;

--query that gives avg gdp, max gdp, and min gdp over years for each intermediate region in Africa 

select ir.intermediate_region_code, 
    ir.intermediate_region_name, 
    round(avg(a.value)::numeric, 0) as avg_gdp,
    Max(a.value) as max_gdp,
    Min(a.value) as min_gdp
from africa_fs_ac a join m49_codes_expanded ir on ir.m49_code = a.area_code_m49
where a.item_code = '22013'
group by ir.intermediate_region_code, ir.intermediate_region_name
order by ir.intermediate_region_name;

--query that gives the avg, max and min gdp for each intermediate region in africa but just for 2011 and 2020

select ir.intermediate_region_code,
    ir.intermediate_region_name,
    round(avg(a.value)::numeric, 0) as avg_gdp,
    max(a.value) as max_gdp,
    min(a.value) as min_gdp
from africa_fs_ac a join m49_codes_expanded ir on ir.m49_code = a.area_code_m49
where a.item_code = '22013' and a.year between 2011 and 2020
group by ir.intermediate_region_code, ir.intermediate_region_name
order by ir.intermediate_region_name;

--query that gives min and max gdp for each intermediate region in Africa but only show countries where 
--avg gdp is <= $4000

select ir.intermediate_region_code,
    ir.intermediate_region_name,
    min(a.value) as min_gdp,
    max(a.value) as max_gdp
from africa_fs_ac a join m49_codes_expanded ir on ir.m49_code = a.area_code_m49
where a.item_code = '22013'
group by ir.intermediate_region_code, ir.intermediate_region_name
having round (avg(a.value)::numeric, 0) <= 4000
order by ir.intermediate_region_name;




