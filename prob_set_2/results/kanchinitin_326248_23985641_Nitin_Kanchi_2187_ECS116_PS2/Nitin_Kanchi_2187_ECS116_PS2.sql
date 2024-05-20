-- Basics
set search_path to food_sec;

show search_path;

-- delete table
delete from m49_codes_expanded;

-- table isn't empty
select count(*) from m49_codes_expanded;



select * 
from m49_codes_expanded mce 
where country_or_area = 'Angola';

-- so: Angola is in
 -- intermediate_region "Middle Africa"
 -- sub_region  "Sub-Saharan Africa"
 -- region  "Africa"
     
-- before we go on, let's see the values for itermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
     
select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- Why are there null values in the answers to both of these queries?

-- Here's a query that finds all countries in Africa for which the
--    sub_region name is NULL

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
     

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;


-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
  
-- Q1:  
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- or, since we want it to look very pretty in the output
--   and still following the stackoverflow page
--   (although, this is too involved for putting on a test!)
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;



-- Q2

  
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
SELECT 
    m.sub_region_name,
    ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp_per_capita
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    m.region_name = 'Africa' AND
    m.sub_region_name IS NOT NULL  -- Ensuring that the sub-region is defined
GROUP BY 
    m.sub_region_name
ORDER BY 
    m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
SELECT 
    m.intermediate_region_name,
    ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp,
    MAX(a.value) AS max_gdp,
    MIN(a.value) AS min_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = '22013' -- Assuming 22013 is the code for GDP
GROUP BY 
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;




-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
SELECT 
    m.intermediate_region_name,
    ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp,
    MAX(a.value) AS max_gdp,
    MIN(a.value) AS min_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = '22013' AND 
    a.year BETWEEN 2011 AND 2020
GROUP BY 
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;



-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
SELECT 
    m.intermediate_region_name,
    MIN(a.value) AS min_gdp,
    MAX(a.value) AS max_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = '22013' AND
    (SELECT AVG(value) FROM africa_fs_ac WHERE area_code_m49 = a.area_code_m49 AND item_code = '22013') <= 4000
GROUP BY 
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;




