--Ayush Majumdar Problem Set 2

set search_path to food_sec;
show search_path;
delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';
SELECT sub_region_name
FROM m49_codes_expanded
WHERE region_name = 'Africa'
GROUP BY sub_region_name
ORDER BY sub_region_name;
SELECT intermediate_region_name, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
GROUP BY intermediate_region_name, country_or_area
ORDER BY intermediate_region_name, country_or_area;
SELECT m49_code, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
AND intermediate_region_code IS NULL
ORDER BY country_or_area;
select m49_code , country_or_area
from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;
SELECT m49_code, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
AND NOT EXISTS (SELECT 1 FROM m49_codes_expanded WHERE intermediate_region_code IS NOT NULL)
ORDER BY country_or_area;
select count(*)
from africa_fs_ac
where area_code_m49 = '024';
select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49;
SELECT *
FROM africa_fs_ac afa
WHERE item LIKE 'Gross%';
select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;
SELECT a.area_code_m49, a.area, ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp
FROM africa_fs_ac AS a
WHERE a.item_code = '22013'
GROUP BY a.area_code_m49, a.area
ORDER BY a.area ASC;
SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(AVG(a.value)::NUMERIC, 0) AS avg_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = '22013'
GROUP BY 
    m.intermediate_region_code,
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;
   
SELECT 
    m.sub_region_name,
    ROUND(AVG(a.value)::NUMERIC, 2) AS avg_gdp_per_capita
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = '22013'  
    AND m.sub_region_name IS NOT NULL 
GROUP BY 
    m.sub_region_name
ORDER BY 
    m.sub_region_name;

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
    a.item_code = 'GDP'  
    AND m.region_name = 'Africa' 
    AND m.intermediate_region_name IS NOT NULL  
GROUP BY 
    m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;

SELECT 
    m.intermediate_region_name,
    AVG(a.value)::NUMERIC AS avg_gdp,
    MIN(a.value) AS min_gdp,
    MAX(a.value) AS max_gdp
FROM 
    africa_fs_ac a
JOIN 
    m49_codes_expanded m ON m.m49_code = a.area_code_m49
WHERE 
    a.item_code = 'GDP' 
    AND m.region_name = 'Africa'
GROUP BY 
    m.intermediate_region_name, a.country_or_area
HAVING 
    AVG(a.value)::NUMERIC <= 4000
ORDER BY 
    m.intermediate_region_name;








