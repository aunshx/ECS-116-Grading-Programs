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
     

-- I didn't run into the issues of this step, but I still wanted to try out the script
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
  and sr.m49_code = a.area_code_m49;


-- Q1
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


-- Exercises for you:

-- Previous Q3:  find the average GDP per capita for each african sub region

SELECT sr.sub_region_name, AVG(a.value) AS avg_gdp_per_capita
FROM africa_fs_ac a
JOIN m49_codes_expanded sr ON a.area_code_m49 = sr.m49_code
WHERE sr.region_name = 'Africa'
AND a.item LIKE '%GDP per capita%'
GROUP BY sr.sub_region_name
ORDER BY sr.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty

SELECT m.intermediate_region_name, 
       AVG(a.value) AS avg_gdp, 
       MAX(a.value) AS max_gdp, 
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON a.area_code_m49 = m.m49_code
WHERE m.region_name = 'Africa'
AND m.intermediate_region_code IS NOT NULL AND m.intermediate_region_code != ''
GROUP BY m.intermediate_region_name
ORDER BY m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)
SELECT m.intermediate_region_name, 
       AVG(a.value) AS avg_gdp, 
       MAX(a.value) AS max_gdp, 
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON a.area_code_m49 = m.m49_code
WHERE m.region_name = 'Africa'
AND a.year BETWEEN 2011 AND 2020
AND m.intermediate_region_code IS NOT NULL AND m.intermediate_region_code != ''
GROUP BY m.intermediate_region_name
ORDER BY m.intermediate_region_name;


-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

SELECT m.intermediate_region_name, 
       MIN(a.value) AS min_gdp, 
       MAX(a.value) AS max_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON a.area_code_m49 = m.m49_code
WHERE m.region_name = 'Africa'
AND m.intermediate_region_code IS NOT NULL AND m.intermediate_region_code != ''
GROUP BY m.intermediate_region_name
HAVING AVG(a.value) <= 4000
ORDER BY m.intermediate_region_name;
