set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

-- also, as a sanity check, does the count of tuples in your
--    table match the count in the csv file?

select count(*) from m49_codes_expanded;

-- count of tuples is 299... that matches the count of tuples in my csv file 

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)


select * 
from m49_codes_expanded mce 
where country_or_area='Angola'

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
where region_name='Africa'
order by sub_region_name;

select distinct intermediate_region_name,country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

-- Why are there null values in the answers to both of these queries?
-- In the cases when we are ordering several columns, there may be null values in one of the columns, which could lead to missing values.
-- There may be some countries  in Africa where intermediatte_region_name is Null.  


-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code ISNULL
order by country_or_area;

--this comes up Null. 
-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code =''
order by country_or_area;

-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

-- checking to make sure country_or_area not in sub_region_name and region_name
-- only using values of country_or area that are not in sub region and region name 

SELECT m49_code, country_or_area 
FROM m49_codes_expanded 
WHERE region_name = 'Africa'
  AND intermediate_region_code = ''
  AND country_or_area NOT IN (SELECT sub_region_name FROM m49_codes_expanded)
  AND country_or_area NOT IN (SELECT region_name FROM m49_codes_expanded)
ORDER BY country_or_area;


-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
     
-- (Condsider trying to create this query on your own, before seeing
--    how I do it)
     
-- hint: Look at the answer to the fetching the one row about Angola
--   Ask yourself, as you look at that one row
--         what column is holding the m49 code for Angola?
--         what column is holding the m49 code for "Middle Africa"?
--         what column is holding the m49 code for "Sub-Saharan Africa"?
     
--   Now think in terms of a select query that identifies 3 tables
--      use africa_fs_ac to get m49 codes and country names for countries in Africa
--      use one copy of m49_codes_expanded to provide the intermediate region code and name
--      use a second copy of m49_codes_expanded to provide the sub region code and name
     
--   What are the WHERE conditions you need to put on tuples from these
--      three tables so that you will get the intermediate and sub regions
--         for a country from africa_fs_ac?
--   What columns do you need from the three tables for the query output?
     
-- in this query, I am using the table africa_fs_ac to get the
--    countries in Africa.  I could create a similar query that
--    uses only the m49_codes_expanded 3 times
 
-- first try:
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
 
SELECT COUNT(*) AS row_count
FROM (
    SELECT a.area_code_m49, a.area,
           ir.intermediate_region_code, ir.intermediate_region_name,
           sr.sub_region_code, sr.sub_region_name 
    FROM africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
    WHERE ir.m49_code = a.area_code_m49
      AND sr.m49_code = a.area_code_m49
) AS query_result;


-- hmm, I am getting 21,688 answers, when I was expecting only 54 answers
-- what is going wrong?
  
-- Let's restrict the query to just Angola to see if that tells us anything
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49 
  and a.area_code_m49 = '024';


 
-- why are there so many records, just for Angola ??
--  BTW, they all look the same.  Hmmm
-- WAIT -- when I think of the cross product of
--      africa_fs_ac X m49_codes_expanded X m49_codes_expanded
--   how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?


select count(*)
from africa_fs_ac 
where area_code_m49 = '24';

/*
select count(*)
from africa_fs_ac 
where area_code_m49 = '024';
*/

-- 415 of them

-- But I only want one record for each country, not 400+ for each country

-- We can use the DISTINCT on the whole query, as follows

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;


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
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

 
 -- so the item_code for GDP is 22013
  

-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by

select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- hmm - would be nice to have the avg rounded to 2 digits; will make it
--   more readable
-- e.g., see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql

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


-- well, it would look even more pretty if the avg_gdp column was
--   right-justified.  Oh well.  I'll just use Round to numeric with no
--   decimal places from here on)

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and not including countries not in any intermediate region)

-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into

-- expect 4 differnt intermediate region name 
select distinct intermediate_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'


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

--- 

-- Exercises for you:

-- create a query for Q3 mentioned above

-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)


-- expect 2  differnt sub region name 

select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'



select m.sub_region_code,
       m.sub_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.sub_region_code != ''
group by m.sub_region_code,
         m.sub_region_name
order by m.sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty



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

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

-- first need to split the year so that we have a year begginign column and a year end column 
-- if there is only 1 year, year end will be an empty string 
-- we create two columns in africa_fs_ac so that this is possible 
-- to do this i had to do some reserach, including some stuff we havn't done yet
-- for year begginign looking a -; if there is a dash year beggining is everything to the left of the dash 
-- if no dash year beggingin is the only number 
-- for year end, if there is a dash, taking everything to the right of the dash 
-- if there is no dash, put nothing 
- 

UPDATE africa_fs_ac
SET 
    year_beginning = CASE 
                        WHEN POSITION('-' IN year) > 0 THEN LEFT(year, POSITION('-' IN year) - 1)
                        ELSE year
                    END,
    year_end = CASE 
                    WHEN POSITION('-' IN year) > 0 THEN RIGHT(year, LENGTH(year) - POSITION('-' IN year))
                    ELSE ''
                END;


select * 
from africa_fs_ac


-- we can then add an additional condition in the where 


SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(AVG(value)::numeric, 0) AS avg_gdp,
       ROUND(MAX(value)::numeric, 0) AS max_gdp,
       ROUND(MIN(value)::numeric, 0) AS min_gdp
FROM africa_fs_ac a,m49_codes_expanded m
WHERE m.m49_code=a.area_code_m49 
and item_code = '22013'
  AND m.intermediate_region_code != ''
  and(year_beginning >= '2011'
    AND (year_end <= '2020' OR year_end ='') )
  
GROUP BY m.intermediate_region_code,
         m.intermediate_region_name
ORDER BY m.intermediate_region_name;




-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)


-- first find countries where average GDP is<=4000
SELECT area_code_m49 
FROM africa_fs_ac 
WHERE item_code = '22013'
GROUP BY area_code_m49
HAVING AVG(value) <= 4000;



-- include above condition in the where statement 


SELECT m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(MIN(value)::numeric, 0) AS min_gdp,
       ROUND(MAX(value)::numeric, 0) AS max_gdp
FROM africa_fs_ac a,m49_codes_expanded m
WHERE m.m49_code = a.area_code_m49 
and item_code = '22013'
  AND m.intermediate_region_code != ''
  AND a.area_code_m49 in (
  	SELECT area_code_m49 
	FROM africa_fs_ac 
	WHERE item_code = '22013'
	GROUP BY area_code_m49
	HAVING AVG(value) <= 4000
  )
GROUP BY m.intermediate_region_code,
         m.intermediate_region_name
ORDER BY m.intermediate_region_name;


--- alternatively if we are just looking at the region with average GDP less than 4000

SELECT 
    m.intermediate_region_code,
    m.intermediate_region_name,
    ROUND(MIN(value)::numeric, 0) AS min_gdp,
    ROUND(MAX(value)::numeric, 0) AS max_gdp
FROM 
    africa_fs_ac a,
    m49_codes_expanded m
WHERE 
    m.m49_code = a.area_code_m49 
    AND item_code = '22013'
    AND m.intermediate_region_code != ''
GROUP BY 
    m.intermediate_region_code,
    m.intermediate_region_name
HAVING 
    AVG(CAST(a.value AS numeric)) <= 4000
ORDER BY 
    m.intermediate_region_name;
