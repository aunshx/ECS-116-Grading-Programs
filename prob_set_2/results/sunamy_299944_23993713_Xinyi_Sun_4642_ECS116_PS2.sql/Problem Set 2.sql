
set search_path to food_sec;
show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

-- List distinct sub-region names associated with countries in Africa
-- null values in the answers
select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;

-- List distinct intermediate-region names and associated countries in Africa
-- null values in the answers
select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- Find Africa entries with an empty string intermediate_region_code
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

-- 415 of them
select count(*)
from africa_fs_ac
where area_code_m49 = '024';

-- Fetch data combining africa_fs_ac with m49_codes_expanded by m49_code
select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- Find all entries matching 'Gross' in their item description
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

-- Calculate average GDP per capita for each African country
select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Avg rounded to 2 digits
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- avg_gdp column was right-justified
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as
avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2, getting avg gdp grouped by intermediate region
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
-- Q3: find the average GDP per capita for each african sub region
SELECT sr.sub_region_name, ROUND(AVG(a.value)::numeric, 2) AS avg_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
JOIN m49_codes_expanded sr ON sr.sub_region_code = m.sub_region_code
WHERE a.item_code = '22013' AND sr.sub_region_code != ''
GROUP BY sr.sub_region_name
ORDER BY sr.sub_region_name;



-- (ignore countries that do not fall into one of the sub regions)
-- create a query for Q3 mentioned above

-- create a query that gives the avg gdp, the max gdp, and the min gdp over the years, for each intermeidate region in AFrica
-- and not including countries where intermediate region is empty
SELECT ir.intermediate_region_name, 
       ROUND(AVG(a.value)::numeric, 2) AS avg_gdp,
       MAX(a.value) AS max_gdp,
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
JOIN m49_codes_expanded ir ON ir.intermediate_region_code = m.intermediate_region_code
WHERE a.item_code = '22013' AND ir.intermediate_region_code != ''
GROUP BY ir.intermediate_region_name
ORDER BY ir.intermediate_region_name;


-- create a query that gives the avg, max and min gdp for each intermediate region in Africa, but just for 2011 to 2020
-- (and not including countries where intermediate region is empty)
SELECT ir.intermediate_region_name, 
       ROUND(AVG(a.value)::numeric, 2) AS avg_gdp,
       MAX(a.value) AS max_gdp,
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
JOIN m49_codes_expanded ir ON ir.intermediate_region_code = m.intermediate_region_code
WHERE a.item_code = '22013' 
      AND CAST(a.year AS INTEGER) BETWEEN 2011 AND 2020 
      AND ir.intermediate_region_code != ''
GROUP BY ir.intermediate_region_name
ORDER BY ir.intermediate_region_name;




-- create a query that gives min and max gdp, for each intermediate region in Africa
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)
WITH AvgGDP AS (
    SELECT a.area_code_m49, AVG(a.value) AS average_gdp
    FROM africa_fs_ac a
    WHERE a.item_code = '22013'
    GROUP BY a.area_code_m49
    HAVING AVG(a.value) <= 4000
)
SELECT ir.intermediate_region_name, 
       MIN(a.value) AS min_gdp, 
       MAX(a.value) AS max_gdp
FROM africa_fs_ac a
JOIN m49_codes_expanded m ON m.m49_code = a.area_code_m49
JOIN m49_codes_expanded ir ON ir.intermediate_region_code = m.intermediate_region_code
JOIN AvgGDP ag ON ag.area_code_m49 = a.area_code_m49
WHERE a.item_code = '22013' AND ir.intermediate_region_code != ''
GROUP BY ir.intermediate_region_name
ORDER BY ir.intermediate_region_name;

