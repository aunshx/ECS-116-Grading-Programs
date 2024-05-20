set search_path to food_sec;

show search_path;

select * from m49_codes_expanded where country_or_area = 'Angola';

select distinct sub_region_name from m49_codes_expanded where region_name = 'Africa';

select distinct intermediate_region_name from m49_codes_expanded where region_name = 'Africa';

select country_or_area from m49_codes_expanded where region_name = 'Africa' 
and intermediate_region_name isnull;

select country_or_area from m49_codes_expanded where region_name = 'Africa' 
and intermediate_region_name = '';

select country_or_area from m49_codes_expanded where region_name = 'Africa' 
and intermediate_region_name = '' and country_or_area != sub_region_name;

select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49 and a.area_code_m49 = '24';

select count(*) from africa_fs_ac where area_code_m49 = '24';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

select * from africa_fs_ac afa where item LIKE('%Gross%');

select area_code_m49, area, avg(value) from africa_fs_ac a where item_code = '22013'
group by area_code_m49, area order by area;

select m.intermediate_region_code, m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name order by m.intermediate_region_name;

select m.sub_region_code, m.sub_region_name,
round(avg(value)::numeric, 0) as avg_gdp from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.sub_region_code != ''
group by m.sub_region_code, m.sub_region_name order by m.sub_region_name;

select a.year, AVG(a.value), MAX(a.value), MIN(a.value) from africa_fs_ac a where a.item_code = '22013'
group by a.year order by a.year;

select m.intermediate_region_name, AVG(a.value), MAX(a.value), MIN(a.value) 
from africa_fs_ac a, m49_codes_expanded m where a.item_code = '22013' and a.area_code_m49 = m.m49_code
and m.intermediate_region_name != ''
group by m.intermediate_region_name;

select m.intermediate_region_name, AVG(a.value), MAX(a.value), MIN(a.value) 
from africa_fs_ac a, m49_codes_expanded m where a.item_code = '22013' and a.area_code_m49 = m.m49_code
and m.intermediate_region_name != '' and a.year between '2011' and '2020'
group by m.intermediate_region_name;

select m.intermediate_region_name, MAX(a.value), MIN(a.value) 
from africa_fs_ac a, m49_codes_expanded m where a.item_code = '22013' and a.area_code_m49 = m.m49_code
and m.intermediate_region_name != ''
group by m.intermediate_region_name having AVG(a.value) <= 4000;






