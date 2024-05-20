-- set path to food_sec schema
set search_path to food_sec;

-- empty out m49 table
delete from m49_codes_expanded;

-- double check
select count(*) from m49_codes_expanded;

-- after confirming count is 0, reimport the data directly into table

-- now select the row for the country 'Angola'
select * 
from m49_codes_expanded mce 
where country_or_area = 'Angola';

-- find distinct sub-region names associated with countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- there are empty/null values in the data that are causing the queries to return partially empty tables

-- list only the countries that have empty string for intermediate_region_code or name
select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
  
-- Q1: find the average GDP per capita for each african country (going over all years)
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2: find the average GDP per capita for each african intermediate region
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- Q3: find the average GDP per capita for each african sub region
select m.sub_region_code,
       m.sub_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;

-- Q4: the avg gdp, the max gdp, and the min gdp over the years for each intermeidate region in Africa
SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(AVG(a.value)::numeric, 0) AS avg_gdp,
    ROUND(MAX(a.value)::numeric, 0) AS max_gdp,
    ROUND(MIN(a.value)::numeric, 0) AS min_gdp
FROM 
    africa_fs_after_cleaning_db a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    item_code = '22013'
GROUP BY 
    m.intermediate_region_code,
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;
    
-- Q5: the avg, max and min gdp for each intermediate region in Africa, but just for 2011 to 2020
SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(AVG(a.value)::numeric, 0) AS avg_gdp,
    ROUND(MAX(a.value)::numeric, 0) AS max_gdp,
    ROUND(MIN(a.value)::numeric, 0) AS min_gdp
FROM 
    africa_fs_after_cleaning_db a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    CAST(a."year"  AS INTEGER) BETWEEN 2011 AND 2020
    AND a.item_code = '22013'
GROUP BY 
    m.intermediate_region_code,
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;
   
-- Q6: min and max gdp for each intermediate region in Africa but only countries where the avg gdp is <= $4000
WITH AvgGDP AS (
    SELECT 
        a.area_code_m49,
        AVG(a.value) AS avg_gdp
    FROM 
        africa_fs_after_cleaning_db a
    WHERE 
        a.item_code = '22013'
    GROUP BY 
        a.area_code_m49
    HAVING 
        AVG(a.value) <= 4000
)
SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(MIN(a.value)::numeric, 0) AS min_gdp,
    ROUND(MAX(a.value)::numeric, 0) AS max_gdp
FROM 
    africa_fs_after_cleaning_db a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
JOIN 
    AvgGDP ON AvgGDP.area_code_m49 = a.area_code_m49
WHERE 
    a.item_code = '22013'
GROUP BY 
    m.intermediate_region_code,
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;   
   