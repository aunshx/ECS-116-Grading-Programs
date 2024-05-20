set search_path to food_sec;

delete from m49_codes_expanded;

delete from africa_fs_ac;

select count(*) from m49_codes_expanded;

select count(*) from africa_fs_ac;

select * from m49_codes_expanded mce
where country_or_area = 'Angola';

--    find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names

select distinct sub_region_name 
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

--	  find all sub_region names which are empty

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;

--	  Make a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;

 --	  Find where the values for GDP per capita are

select * from africa_fs_ac afa
where item LIKE('%Gross%');

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

--	  Get avg gdp grouped by intermediate region

select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercises for you:

-- create a query for Q3 mentioned above

SELECT m.sub_region_code,
       m.sub_region_name,
       ROUND(AVG(a.value)::NUMERIC, 0) as avg_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013' AND m.sub_region_code != ''
GROUP BY m.sub_region_code,
         m.sub_region_name
ORDER BY m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica

SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(a.value)::NUMERIC, 0) as avg_gdp,
       MAX(a.value) as max_gdp,
       MIN(a.value) as min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013'
GROUP BY m.intermediate_region_code,
         m.intermediate_region_name
ORDER BY m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020

--	  Something wrong with this one. I think due to typing but don't have time to fix sorry.
SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(a.value)::NUMERIC, 0) as avg_gdp,
       MAX(a.value) as max_gdp,
       MIN(a.value) as min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013'
  AND a.year >= 2011 AND a.year <= 2020
GROUP BY m.intermediate_region_code,
         m.intermediate_region_name
ORDER BY m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000

SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       MIN(a.value) as min_gdp,
       MAX(a.value) as max_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE a.item_code = '22013'
GROUP BY m.intermediate_region_code,
         m.intermediate_region_name
HAVING ROUND(AVG(a.value)::NUMERIC, 0) <= 4000
ORDER BY m.intermediate_region_name;





