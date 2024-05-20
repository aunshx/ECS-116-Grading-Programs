SET SEARCH_PATH TO FOOD_SEC;

SHOW SEARCH_PATH;

-- Here is one way to pull in the m49_codes_expanded.csv file
--    (put this in the same schema (food_sec) where you have africa_fs_ac)

-- import file m49_codes_expanded.csv with DBeaver
-- replace data types for the following with varchar(3)
--   (all of these columns hold codes for countries or regions)
--       global_code
--       region_code
--       sub_region_code
--       intermediate_region_code
--       m49_code

-- do the following to empty everything out of m49_codes_expanded
DELETE FROM m49_codes_expanded

-- sanity check ... is the table empty?
SELECT count(*)
FROM m49_codes_expanded;

-- now import the file m49_codes_expanded.csv directly into the table m49_codes_expanded

-- check that the data looks like the data in the csv file
--	YES, but some columns with TRUE/FALSE values instead have [] and [v].

-- also, as a sanity check, does the count of tuples in your table match the count in the csv file?
--	YES - 299 rows
SELECT count(*)
FROM m49_codes_expanded;

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded for the country "Angola"
SELECT *
FROM m49_codes_expanded m
WHERE m.country_or_area = 'Angola';

-- so: Angola is in
 -- intermediate_region "Middle Africa"
 -- sub_region  "Sub-Saharan Africa"
 -- region  "Africa"
     
-- before we go on, let's see the values for intermediate_region and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with countries in Africa, 
--	 and same thing for intermediate-region names
SELECT DISTINCT sub_region_name
FROM m49_codes_expanded m
WHERE region_name = 'Africa'
ORDER BY sub_region_name;

SELECT DISTINCT intermediate_region_name, country_or_area
FROM m49_codes_expanded m
WHERE region_name = 'Africa'
ORDER BY intermediate_region_name, country_or_area;

-- Why are there null values in the answers to both of these queries?

-- Here's a query that finds all countries in Africa for which the intermediate_region_name is NULL
SELECT m49_code, country_or_area
FROM m49_codes_expanded m
WHERE region_name = 'Africa' AND intermediate_region_code ISNULL
ORDER BY country_or_area;

-- hmm - why is this coming up empty?
-- in the select distinct queries above, the empty values are not NULL, they are ''  (empty string)
SELECT m49_code, country_or_area
FROM m49_codes_expanded m
WHERE region_name = 'Africa' AND intermediate_region_code = ''
ORDER BY country_or_area;

-- Hmm, this includes not only countries, but also bigger regions (countries in Africa for which the sub_region name is NULL)
-- Exercise for you: how to list only the countries that have empty string for intermediate_region_code or name
select m49_code, country_or_area
FROM m49_codes_expanded m
WHERE region_name = 'Africa' AND intermediate_region_code = '' AND intermediate_region_name = ''
ORDER BY country_or_area;

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region, including both names and m49 codes for the countries/regions

-- Hint: Look at the answer to the above query, which has exactly one row
--   Ask yourself, as you look at that one row
--         what column is holding the m49 code for Angola?
--         what column is holding the m49 code for "Middle Africa"?
--         what column is holding the m49 code for "Sub-Saharan Africa"?

--   Now think in terms of a select query that identifies 3 tables
--      use africa_fs_ac to get m49 codes and country names for countries in Africa
--      use one copy of m49_codes_expanded to provide the intermediate region code and name
--      use a second copy of m49_codes_expanded to provide the sub region code and name
     
--   What are the WHERE conditions you need to put on tuples from these
--      three tables so that you will get the intermediate and sub regions for a country from africa_fs_ac?
--   What columns do you need from the three tables for the query output?
     
-- in this query, I am using the table africa_fs_ac to get the
--    countries in Africa.  I could create a similar query that
--    uses only the m49_codes_expanded 3 times
SELECT ac.area_code_m49, ac.area, ir.intermediate_region_name, ir.intermediate_region_code, sr.sub_region_name, sr.sub_region_code
FROM m49_codes_expanded ir, m49_codes_expanded sr, africa_fs_ac ac
WHERE ir.m49_code = ac.area_code_m49
	AND sr.m49_code = ac.area_code_m49;
 
-- hmm, I am getting 21,688 answers, when I was expecting only 54 answers
-- Let's restrict the query to just Angola to see if that tells us anything
SELECT ac.area_code_m49, ac.area, ir.intermediate_region_name, ir.intermediate_region_code, sr.sub_region_name, sr.sub_region_code
FROM africa_fs_ac ac, m49_codes_expanded ir, m49_codes_expanded sr
WHERE ir.m49_code = '024' AND ac.area_code_m49 = '24'
	AND sr.m49_code = '024' AND ac.area_code_m49 = '24'
	AND ac.area_code_m49 = '24';
--My code is slightly different, rather than the sr m49 code = ac area code m49, i had to create a bunch of and statements specifying
--the exact format to the 24 - for the africa_fs_ac it is '24' despite being data type varchar(3). for m49_codes_expanded it IS '024'.

-- why are there so many records, just for Angola ??
--  BTW, they all look the same.  Hmmm
  
-- WAIT -- when I think of the cross product of
--      africa_fs_ac X m49_codes_expanded X m49_codes_expanded
--   how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
SELECT count(*)
FROM africa_fs_ac
WHERE area_code_m49 = '24';

-- 415 of them
-- But I only want one record for each country, not 400+ for each country
-- We can use the DISTINCT on the whole query, as follows
SELECT DISTINCT ac.area_code_m49, ac.area, ir.intermediate_region_name, ir.intermediate_region_code, sr.sub_region_name, sr.sub_region_code
FROM africa_fs_ac ac, m49_codes_expanded ir, m49_codes_expanded sr
WHERE ir.m49_code = '024' AND ac.area_code_m49 = '24'
	AND sr.m49_code = '024' AND ac.area_code_m49 = '24'
	AND ac.area_code_m49 = '24';

-- Interestingly, most mot not all countries from Africa have an intermediate region
  
-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
  
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
  
-- Q1:  (try this yourself before looking at my answer!)
  
-- Hint: first, let's find where the values for GDP per capita are
SELECT *
FROM africa_fs_ac
WHERE item LIKE '%Gross%';

-- so the item_code for GDP is 22013
 
-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by
SELECT area_code_m49, area, avg(value) 
FROM africa_fs_ac
WHERE item_code = '22013'
GROUP BY area_code_m49, area
ORDER BY area;

-- hmm - would be nice to have the avg rounded to 2 digits; will make it more readable
-- e.g., see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql
SELECT area_code_m49, area, round(avg(value)::NUMERIC, 2) AS avg_gdp
FROM africa_fs_ac
WHERE item_code = '22013'
GROUP BY area_code_m49, area
ORDER BY area;

-- or, since we want it to look very pretty in the output
--   and still following the stackoverflow page (although, this is too involved for putting on a test!)
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- well, it would look even more pretty if the avg_gdp column was right-justified.  Oh well. 
-- I'll just use Round to numeric with no decimal places from here on)

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and ignoring countries not in any intermediate region)

-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
SELECT m.intermediate_region_code, 
	m.intermediate_region_name, 
	round(avg(ac.value)::NUMERIC, 2) as avg_gdp
FROM m49_codes_expanded m, africa_fs_ac ac
WHERE m.m49_code = area_code_m49
	AND item_code = '22013'
GROUP BY m.intermediate_region_code, m.intermediate_region_name
ORDER BY m.intermediate_region_name;


-- Exercises for you:

-- create a query for Q3 mentioned above
-- Q3: find the average GDP per capita for each african sub region
	--  (ignore countries that do not fall into one of the sub regions)
SELECT m.sub_region_name, 
	round(avg(ac.value)::NUMERIC, 2) as avg_gdp
FROM m49_codes_expanded m, africa_fs_ac ac
WHERE m.m49_code = ac.area_code_m49 
	AND item_code = '22013'
GROUP BY m.sub_region_name
ORDER BY m.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermediate region in Africa
-- 	  and not including countries where intermediate region is empty
SELECT ac.year, m.intermediate_region_name, 
	round(avg(ac.value)::NUMERIC, 2) as avg_gdp, 
	max(ac.value) AS max_gdp, 
	min(ac.value) AS min_gdp
FROM africa_fs_ac ac, m49_codes_expanded m
WHERE m.m49_code = area_code_m49
	AND item_code = '22013'
	AND m.intermediate_region_code != ''
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name, ac.year 
ORDER BY m.intermediate_region_name, ac.year;


-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

SELECT m.intermediate_region_name, 
	ac.year, 
	round(avg(ac.value)) AS avg_gdp, 
	max(ac.value) AS max_gdp, 
	min(ac.value) AS min_gdp
FROM africa_fs_ac ac, m49_codes_expanded m
WHERE m.m49_code = ac.area_code_m49
	AND item_code = '22013'
	AND ac.YEAR BETWEEN '2011' AND '2020'
	AND m.intermediate_region_code != ''
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name, ac.year
ORDER BY m.intermediate_region_name, ac.year;


-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

SELECT m.intermediate_region_name, 
	ac.year, 
	max(ac.value) AS max_gdp, 
	min(ac.value) AS min_gdp
FROM africa_fs_ac ac, m49_codes_expanded m
WHERE m.m49_code = ac.area_code_m49
	AND item_code = '22013'
	AND m.intermediate_region_code != ''
	AND m.intermediate_region_name != ''
GROUP BY m.intermediate_region_name, ac.YEAR
HAVING round(avg(ac.value)) <= '4000'
ORDER BY m.intermediate_region_name, ac.year;
	
