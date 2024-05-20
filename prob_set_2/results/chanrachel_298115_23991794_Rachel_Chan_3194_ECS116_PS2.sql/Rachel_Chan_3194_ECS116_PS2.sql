set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

-- region_name: Africa
--sub_region_name: Sub-Saharan Africa
-- intermediate_region_code: 17
-- intermediate_region_name: Middle Africa

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
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name, sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

select count(*)
from africa_fs_ac a
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

select *
from africa_fs_ac a
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

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

select m.intermediate_region_code,
m.intermediate_region_name,
round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code,
m.intermediate_region_name 
order by m.intermediate_region_name;


-- query 1
select m.intermediate_region_code, m.intermediate_region_name, ROUND(AVG(a.value)::NUMERIC, 0) AS avg_gdp_per_capita
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

--q query 2
with avg_gdp_per_region as(select m.intermediate_region_code, m.intermediate_region_name, a.year,
ROUND(AVG(a.value)::numeric, 0) AS avg_gdp,
MAX(a.value) AS max_gdp,
MIN(a.value) AS min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.intermediate_region_code != '' 
group by m.intermediate_region_code, m.intermediate_region_name, a.year
)
select intermediate_region_code, intermediate_region_name, AVG(avg_gdp) AS avg_avg_gdp, MAX(max_gdp) AS max_max_gdp, MIN(min_gdp) AS min_min_gdp
from avg_gdp_per_region
group by intermediate_region_code, intermediate_region_name
order by intermediate_region_name;


--query 3
with avg_gdp_per_region as(select m.intermediate_region_code, m.intermediate_region_name, a.year,
ROUND(AVG(a.value)::numeric, 0) AS avg_gdp,
MAX(a.value) AS max_gdp,
MIN(a.value) AS min_gdp
from africa_fs_ac a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where a.item_code = '22013' and m.intermediate_region_code != '' and a.year between '2011' and '2020'
group by m.intermediate_region_code, m.intermediate_region_name, a.year
)
select intermediate_region_code, intermediate_region_name, AVG(avg_gdp) AS avg_avg_gdp, MAX(max_gdp) AS max_max_gdp, MIN(min_gdp) AS min_min_gdp
from avg_gdp_per_region
group by intermediate_region_code, intermediate_region_name
order by intermediate_region_name;


--query 4
with avg_gdp_per_region as( 
select m.intermediate_region_code, m.intermediate_region_name, ROUND(AVG(a.value)::numeric, 0) AS avg_gdp
from africa_fs_ac a
where a.item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
having AVG(a.value) <= 4000
)
select intermediate_region_code, intermediate_region_name, MAX(avg_gdp) AS max_avg_gdp, MIN(avg_gdp) AS min_avg_gdp
from avg_gdp_per_region
group by intermediate_region_code, intermediate_region_name
order by intermediate_region_name;

