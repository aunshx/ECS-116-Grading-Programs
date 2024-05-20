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
order by sub_region_name;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- There is null values because only east africa is a region with multiple countries. Some countries do not have a specified region. 

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code isnull
order by country_or_area;

select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code = ''
order by country_or_area;

-- Excersize 
select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code = ''
	and entity_category = 'current country'
order by country_or_area;

SELECT a.area_code_m49, a.area, 
	ir.intermediate_region_code, ir.intermediate_region_name, 
	sr.sub_region_code, sr.sub_region_name
FROM africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
WHERE ir.m49_code = a.area_code_m49
AND sr.m49_code = a.area_code_m49;

SELECT a.area_code_m49, a.area, 
	ir.intermediate_region_code, ir.intermediate_region_name, 
	sr.sub_region_code, sr.sub_region_name
FROM africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
WHERE ir.m49_code = a.area_code_m49
	AND sr.m49_code = a.area_code_m49
	and a.area_code_m49 = '024';

select count(*)
from africa_fs_ac
where area_code_m49 = '024';

SELECT distinct a.area_code_m49, a.area, 
	ir.intermediate_region_code, ir.intermediate_region_name, 
	sr.sub_region_code, sr.sub_region_name
FROM africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
WHERE ir.m49_code = a.area_code_m49
AND sr.m49_code = a.area_code_m49;

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
avg_gpd
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area_code_m49
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

-- Excersizes

select m.intermediate_region_code,
	m.intermediate_region_name,
	round(avg(value)::numeric, 0) as avg_gdp, 
	round(max(value)::numeric, 0) as max_gdp, 
	round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
	and item_code = '22013'
	and m.intermediate_region_code != ''
group by m.intermediate_region_code, 
	m.intermediate_region_name 
order by m.intermediate_region_name;

alter table africa_fs_ac 
add column start_year integer,
add column end_year integer;

update africa_fs_ac 
set 
	start_year = case
					when position('-' in year) > 0 then left(year, position('-' in year) - 1)::integer
					else year::integer 
				end,
	end_year = case 
					when position('-' in year) > 0 then right(year, position('-' in year) - 1)::integer	
				end;
			
SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(AVG(value)::numeric, 0) AS avg_gdp, 
    ROUND(MAX(value)::numeric, 0) AS max_gdp, 
    ROUND(MIN(value)::numeric, 0) AS min_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49 
WHERE 
    item_code = '22013'
    AND m.intermediate_region_code != ''
    AND (a.start_year >= 2011 OR a.end_year <= 2020)
GROUP BY 
    m.intermediate_region_code, 
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;
	
	

select m.intermediate_region_code,
	m.intermediate_region_name,
	round(max(value)::numeric, 0) as max_gdp, 
	round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 
	and item_code = '22013'
	and m.intermediate_region_code != ''
group by m.intermediate_region_code, 
	m.intermediate_region_name 
having AVG(value) <= 4000
order by m.intermediate_region_name;


