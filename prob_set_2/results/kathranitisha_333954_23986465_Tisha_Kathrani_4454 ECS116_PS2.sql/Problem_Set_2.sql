set search_path to food_sec;
show search_path;
delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

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

select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and (intermediate_region_code = '' OR intermediate_region_name = '')
order by country_or_area;

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

select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
group by m.intermediate_region_code, m.intermediate_region_name

SELECT m.intermediate_region_code, m.intermediate_region_name,
       AVG(a.value) AS avg_gdp,
       MAX(a.value) AS max_gdp,
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013'  
GROUP BY m.intermediate_region_code, m.intermediate_region_name;

SELECT m.intermediate_region_code, m.intermediate_region_name,
       AVG(a.value) AS avg_gdp,
       MAX(a.value) AS max_gdp,
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013' AND CAST(a.year AS INTEGER) BETWEEN 2011 AND 2020
GROUP BY m.intermediate_region_code, m.intermediate_region_name;

SELECT m.intermediate_region_code, m.intermediate_region_name, m.country_or_area,
       MIN(a.value) AS min_gdp,
       MAX(a.value) AS max_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name, m.country_or_area
HAVING AVG(a.value) <= 4000;

