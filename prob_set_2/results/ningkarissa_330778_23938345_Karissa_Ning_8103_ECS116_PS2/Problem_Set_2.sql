-- Basics
set search_path to food_sec__v01;

show search_path;
      
-- to the following to empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

-- check that the data looks like the data in the csv file (looks good)

-- also, as a sanity check, does the count of tuples in your
--    table match the count in the csv file? (yes)
select count(*) from m49_codes_expanded;

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)
select *
from m49_codes_expanded mce
where mce.country_or_area = 'Angola';

-- so: Angola is in
 -- intermediate_region "Middle Africa"
 -- sub_region  "Sub-Saharan Africa"
 -- region  "Africa"
     
-- before we go on, let's see the values for itermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names (include country_or_area)
select distinct sub_region_name
from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area --no duplicate pairs
from m49_codes_expanded 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

-- Why are there null values in the answers to both of these queries?
-- (many rows don't have a value or have empty value for intermediate_region_name and 
-- some rows don't have a value for sub_region_name)

-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL
select m49_code, country_or_area 
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code isnull
order by country_or_area;

-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is
select m49_code, country_or_area
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;

-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name
-- A query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
-- hint: Lood at the answer to the above query, which has exactly one row
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
select distinct afa.area_code_m49, afa.area, 
	mce.intermediate_region_code, mce.intermediate_region_name,
	mce.sub_region_code, mce.sub_region_name
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code;
-- Interestingly, most mot not all countries from Africa have an intermediate region

-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Hint: first, let's find where the values for GDP per capita are
select *
from africa_fs_ac
where item like '%Gross%';
-- so the item_code for GDP is 22013
-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by
select area_code_m49, area, AVG(value)
from africa_fs_ac
where item_code = '22013'
group by area_code_m49, area
order by area;
-- hmm - would be nice to have the avg rounded to 2 digits; will make it
--   more readable
select area_code_m49, area, ROUND(AVG(value)::numeric, 2) as avg_gdp
from africa_fs_ac
where item_code = '22013'
group by area_code_m49, area
order by area;
-- or, since we want it to look very pretty in the output
select area_code_m49, area, TO_CHAR(AVG(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac
where item_code = '22013'
group by area_code_m49, area
order by area;
-- well, it would look even more pretty if the avg_gdp column was
--   right-justified.  Oh well.  I'll just use Round to numeric with no
--   decimal places from here on)

-- Q2: find the average GDP per capita for each african intermediate region
-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and ignoring countries not in any intermediate region)
-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
select mce.intermediate_region_code, mce.intermediate_region_name, 
	ROUND(AVG(afa.value)::numeric, 0) as avg_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code 
	and afa.item_code = '22013'
	and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name 
order by mce.intermediate_region_name;

-- Exercises for you:
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
-- create a query for Q3 mentioned above
select mce.sub_region_code, mce.sub_region_name, 
	ROUND(AVG(afa.value)::numeric, 0) as avg_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code 
	and afa.item_code = '22013'
	and mce.sub_region_code != ''
group by mce.sub_region_code, mce.sub_region_name 
order by mce.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
select mce.intermediate_region_code, mce.intermediate_region_name, 
	ROUND(AVG(afa.value)::numeric, 0) as avg_gdp,
	ROUND(MAX(afa.value)::numeric, 0) as max_gdp,
	ROUND(MIN(afa.value)::numeric, 0) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code 
	and afa.item_code = '22013'
	and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name 
order by mce.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
select mce.intermediate_region_code, mce.intermediate_region_name,
	ROUND(AVG(afa.value)::numeric, 0) as avg_gdp,
	ROUND(MAX(afa.value)::numeric, 0) as max_gdp,
	ROUND(MIN(afa.value)::numeric, 0) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code 
	and afa.item_code = '22013'
	and afa."year" between '2011' and '2020'
	and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
select mce.intermediate_region_code, mce.intermediate_region_name,
	ROUND(MAX(afa.value)::numeric, 0) as max_gdp,
	ROUND(MIN(afa.value)::numeric, 0) as min_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where afa.area_code_m49 = mce.m49_code 
	and afa.item_code = '22013'
	and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
having AVG(afa.value) <= 4000
order by mce.intermediate_region_name;





