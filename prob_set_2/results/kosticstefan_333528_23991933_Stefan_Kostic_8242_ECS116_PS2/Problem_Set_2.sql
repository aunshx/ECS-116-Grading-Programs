set search_path to food_sec;

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)

-- Query Attempt
SELECT *
FROM m49_codes_expanded
WHERE country_or_area = 'Angola';


-- before we go on, let's see the values for itermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)

-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names

-- Query Attempt a
SELECT DISTINCT sub_region_name, country_or_area 
FROM m49_codes_expanded
WHERE region_name = 'Africa'
ORDER BY sub_region_name, country_or_area;

-- Query Attempt b
SELECT DISTINCT intermediate_region_name, country_or_area 
FROM m49_codes_expanded
WHERE region_name = 'Africa'
ORDER BY intermediate_region_name, country_or_area;


-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

-- Query Attempt
SELECT m49_code, country_or_area
FROM m49_codes_expanded
WHERE region_name = 'Africa'
	AND intermediate_region_code = ''
	AND entity_category = 'current country'
ORDER BY country_or_area;


-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
     
-- (Condsider trying to create this query on your own, before seeing
--    how I do it)

-- Query Attempt
SELECT country_or_area, m49_code, intermediate_region_name,
		intermediate_region_code, sub_region_name, sub_region_code
FROM m49_codes_expanded
WHERE region_name = 'Africa'
	AND entity_category = 'current country';
     

-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
  
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)

-- Q1:  (try this yourself before looking at my answer!)

--- Query Attempt
SELECT area, round(avg(value)::NUMERIC, 2) AS avg_gdp 
FROM africa_fs_ac
WHERE item_code = '22013'
GROUP BY area;


-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and not including countries not in any intermediate region)

--- Query Attempt
SELECT m.intermediate_region_name, round(avg(a.value)::NUMERIC, 2) AS avg_gdp 
FROM africa_fs_ac a, m49_codes_expanded m
WHERE a.item_code = '22013'
	AND m.m49_code = a.area_code_m49
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name;


-- Exercises for you:

-- create a query for Q3 mentioned above

--- Query Attempt
SELECT m.sub_region_name, round(avg(a.value)::NUMERIC, 2) AS avg_gdp 
FROM africa_fs_ac a, m49_codes_expanded m
WHERE a.item_code = '22013'
	AND m.m49_code = a.area_code_m49
	AND m.sub_region_name != ''
GROUP BY m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty

-- Query Attempt
SELECT m.intermediate_region_name, round(avg(a.value)::NUMERIC, 2) AS avg_gdp,
		max(a.value) AS max_gdp, min(a.value) AS min_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE a.item_code = '22013'
	AND m.m49_code = a.area_code_m49
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name;


-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

-- Query Attempt
SELECT m.intermediate_region_name, round(avg(a.value)::NUMERIC, 2) AS avg_gdp,
		max(a.value) AS max_gdp, min(a.value) AS min_gdp
FROM africa_fs_ac a, m49_codes_expanded m
WHERE a.item_code = '22013'
	AND m.m49_code = a.area_code_m49
	AND m.intermediate_region_name != ''
	AND (a.year_code LIKE '201%' OR a.year_code LIKE '2020')
	AND a.year_code NOT LIKE '2010'
GROUP BY m.intermediate_region_name;


-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

-- Query Attempt
SELECT m.intermediate_region_name, max(a.value) AS max_gdp, min(a.value) AS min_gdp
FROM africa_fs_ac a, m49_codes_expanded m,
	(SELECT area_code_m49, round(avg(value)::NUMERIC, 2) AS avg_gdp 
		FROM africa_fs_ac
		WHERE item_code = '22013'
		GROUP BY area_code_m49
		HAVING round(avg(value)::NUMERIC, 2) <= 4000) a2
WHERE a.item_code = '22013'
	AND m.m49_code = a.area_code_m49
	AND m.m49_code = a2.area_code_m49
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name;

