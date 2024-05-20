-- Basics
SET search_path TO food_sec;
SHOW search_path;

ALTER TABLE m49_codes_expanded
ALTER COLUMN global_code TYPE varchar(3),
ALTER COLUMN region_code TYPE varchar(3),
ALTER COLUMN sub_region_code TYPE varchar(3),
ALTER COLUMN intermediate_region_code TYPE varchar(3),
ALTER COLUMN m49_code TYPE varchar(3);

DELETE FROM m49_codes_expanded;

-- Check if m49_codes_expanded table is empty
SELECT COUNT(*) FROM m49_codes_expanded;

-- Query to retrieve information about Angola from m49_codes_expanded
SELECT * FROM m49_codes_expanded
WHERE country_or_area = 'Angola';

-- Query to find distinct sub-region names associated with countries in Africa
SELECT DISTINCT sub_region_name
FROM m49_codes_expanded
WHERE region_name = 'Africa'
ORDER BY sub_region_name;

-- Query to find distinct intermediate-region names associated with countries in Africa
SELECT DISTINCT intermediate_region_name, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
ORDER BY intermediate_region_name, country_or_area;

-- Query to find countries in Africa where the intermediate_region name is NULL
SELECT m49_code, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
AND intermediate_region_code = ''
ORDER BY country_or_area;

SELECT m49_code, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
AND (intermediate_region_code = '' OR intermediate_region_name IS NULL)
ORDER BY country_or_area;

SELECT a.area_code_m49,
       a.area AS country,
       ir.intermediate_region_code,
       ir.intermediate_region_name,
       sr.sub_region_code,
       sr.sub_region_name
FROM africa_fs_ac a
JOIN m49_codes_expanded ir ON a.area_code_m49 = ir.m49_code
JOIN m49_codes_expanded sr ON a.area_code_m49 = sr.m49_code
WHERE ir.region_name = 'Africa' AND sr.region_name = 'Africa'
ORDER BY a.area;

-- Query to retrieve average GDP per capita for each African country
SELECT area_code_m49, area, ROUND(AVG(value)::numeric, 2) AS avg_gdp
FROM africa_fs_ac
WHERE item_code = '22013'
GROUP BY area_code_m49, area
ORDER BY area;

-- Query to retrieve average GDP per capita for each African intermediate region
SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(value)::numeric, 0) AS avg_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49
AND item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name
ORDER BY m.intermediate_region_name;

SELECT m.sub_region_code,
       m.sub_region_name,
       ROUND(AVG(a.value)::numeric, 2) AS avg_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49
AND item_code = '22013'
GROUP BY m.sub_region_code, m.sub_region_name
ORDER BY m.sub_region_name;	
SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(a.value)::numeric, 2) AS avg_gdp,
       MAX(a.value) AS max_gdp,
       MIN(a.value) AS min_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49
AND item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name
ORDER BY m.intermediate_region_name;
SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(CASE WHEN year >= 2011 AND year <= 2020 THEN a.value END)::numeric, 2) AS avg_gdp_2011_2020,
       MAX(CASE WHEN year >= 2011 AND year <= 2020 THEN a.value END) AS max_gdp_2011_2020,
       MIN(CASE WHEN year >= 2011 AND year <= 2020 THEN a.value END) AS min_gdp_2011_2020
FROM africa_fs_ac a, m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49
AND item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name
ORDER BY m.intermediate_region_name;
SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       MIN(a.value) AS min_gdp,
       MAX(a.value) AS max_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49
AND item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name
HAVING AVG(a.value) <= 4000
ORDER BY m.intermediate_region_name;