-- basics
set search_path to food_sec;

-- empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check
select count(*) from m49_codes_expanded;
-- I imported the file m49_codes_expanded.csv directly into the table m49_codes_expanded


select *
from m49_codes_expanded 
where country_or_area = 'Angola'


select distinct intermediate_region_name, sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'

select m49_code, country_or_area
from m49_codes_expanded 
where region_name = 'Africa' 
and intermediate_region_name = ''


select m49_code, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and (intermediate_region_code = '' or intermediate_region_name = '')


select distinct a.area_code_m49 as area_code, a.area as country, m1.intermediate_region_name,
m1.intermediate_region_code, m2.sub_region_name, m2.sub_region_code
from africa_fs_ac a, m49_codes_expanded m1, m49_codes_expanded m2
where m1.m49_code = a.area_code_m49 
and m2.m49_code = a.area_code_m49 


select * 
from africa_fs_ac afa
where item LIKE(%Gross%)

select area, avg(value)
from africa_fs_ac 
where item_code = '22013'
group by area 

select area, round(avg(value) :: numeric, 2) as avg_gdp
from africa_fs_ac 
where item_code = '22013'
group by area 


select m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_name


select m.sub_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by  m.sub_region_name


select m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp,
round(min(value)::numeric, 0) as min_gdp, round(max(value)::numeric, 0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_name


select m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp,
round(min(value)::numeric, 0) as min_gdp, round(max(value)::numeric, 0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013' and (year_code = 2011 or year_code = 2012 or year_code = 2013
or year_code = 2014 or year_code = 2015 or year_code = 2016 or year_code = 2017
or year_code = 2018 or year_code = 2019 or year_code = 2020)
group by m.intermediate_region_name


select m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp,
round(min(value)::numeric, 0) as min_gdp, round(max(value)::numeric, 0) as max_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_name
having avg(a.value) <= 4000


