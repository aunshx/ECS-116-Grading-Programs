-- Basics
set search_path to food_sec;
show search_path;

-- These exercises will focus on two tables
--     africa_fs_ac
--     m49_codes_expanded (which is available in the
--              file m49_codes_expanded.csv in Canvas)


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
      
-- to the following to empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
select * from m49_codes_expanded mce;

-- now import the file m49_codes_expanded.csv directly into
--    the table m49_codes_expanded

-- check that the data looks like the data in the csv file

-- also, as a sanity check, does the count of tuples in your
--    table match the count in the csv file?

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)
select * from m49_codes_expanded mce where mce.country_or_area = 'Angola';

-- so: Angola is in
 -- intermediate_region "Middle Africa"
 -- sub_region  "Sub-Saharan Africa"
 -- region  "Africa"
     
-- before we go on, let's see the values for intermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
select distinct mce.sub_region_name
from m49_codes_expanded mce
where mce.region_name = 'Africa'
order by mce.sub_region_name;

select distinct mce.intermediate_region_name
from m49_codes_expanded mce
where mce.region_name = 'Africa'
order by mce.intermediate_region_name;

-- Why are there null values in the answers to both of these queries?

-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL

select mce.country_or_area
from m49_codes_expanded mce
where mce.intermediate_region_name isnull;


-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is
select mce.country_or_area
from m49_codes_expanded mce
where mce.intermediate_region_name = '';

     
-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name
select mce.country_or_area
from m49_codes_expanded mce 
where mce.intermediate_region_code isnull
or mce.intermediate_region_name like '';

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
-- (Consider trying to create this query on your own, before seeing
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
select A.area_code_m49, A.area, I.intermediate_region_code, I.intermediate_region_name, S.sub_region_code, S.sub_region_name
from africa_fs_after_cleaning_db A, m49_codes_expanded I, m49_codes_expanded S
where I.m49_code = A.area_code_m49 and S.m49_code = A.area_code_m49;
  
-- hmm, I am getting 21,688 answers, when I was expecting only 54 answers
-- what is going wrong?
  
-- Let's restrict the query to just Angola to see if that tells us anything
select A.area_code_m49, A.area, I.intermediate_region_code, I.intermediate_region_name, S.sub_region_code, S.sub_region_name
from africa_fs_after_cleaning_db A, m49_codes_expanded I, m49_codes_expanded S
where I.m49_code = A.area_code_m49 and S.m49_code = A.area_code_m49
and A.area = 'Angola';

-- why are there so many records, just for Angola ??
--  BTW, they all look the same.  Hmmm
-- WAIT -- when I think of the cross product of
--      africa_fs_ac X m49_codes_expanded X m49_codes_expanded
--   how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
select a.* from africa_fs_after_cleaning_db a where a.area_code_m49 = '024';
-- 415 of them
-- But I only want one record for each country, not 400+ for each country
-- We can use the DISTINCT on the whole query, as follows
select distinct A.area_code_m49, A.area, I.intermediate_region_code, I.intermediate_region_name, S.sub_region_code, S.sub_region_name
from africa_fs_after_cleaning_db A, m49_codes_expanded I, m49_codes_expanded S
where I.m49_code = A.area_code_m49 and S.m49_code = A.area_code_m49;

-- Interestingly, most but not all countries from Africa have an intermediate region
select distinct A.area_code_m49, A.area, I.intermediate_region_code, I.intermediate_region_name, S.sub_region_code, S.sub_region_name
from africa_fs_after_cleaning_db A, m49_codes_expanded I, m49_codes_expanded S
where I.m49_code = A.area_code_m49 and S.m49_code = A.area_code_m49 and I.intermediate_region_code is not null;

-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
  
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
  
-- Q1:  (try this yourself before looking at my answer!)
-- Hint: first, let's find where the values for GDP per capita are
select a.*
from africa_fs_after_cleaning_db a
where a.item like '%Gross%';
-- so the item_code for GDP is 22013
  
-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by
select a.area_code_m49, a.area, a.item, avg(a.value)
from africa_fs_after_cleaning_db a
where a.item_code = '22013'
group by a.area_code_m49, a.item, a.area
order by a.area;

-- hmm - would be nice to have the avg rounded to 2 digits; will make it
--   more readable
-- e.g., see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql
select a.area_code_m49, a.area, a.item, round(cast(avg(a.value) as numeric), 2)
from africa_fs_after_cleaning_db a
where a.item_code = '22013'
group by a.area_code_m49, a.item, a.area
order by a.area;

-- or, since we want it to look very pretty in the output
--   and still following the stackoverflow page
--   (although, this is too involved for putting on a test!)
select a.area_code_m49, a.area, a.item, round(cast(avg(a.value) as numeric), 2) as avg_gdp
from africa_fs_after_cleaning_db a
where a.item_code = '22013'
group by a.area_code_m49, a.item, a.area
order by a.area;

-- well, it would look even more pretty if the avg_gdp column was
--   right-justified.  Oh well.  I'll just use Round to numeric with no
--   decimal places from here on)
select a.area_code_m49, a.area, a.item, round(cast(avg(a.value) as numeric)) as avg_gdp
from africa_fs_after_cleaning_db a
where a.item_code = '22013'
group by a.area_code_m49, a.item, a.area
order by a.area;

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and not including countries not in any intermediate region)
-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
select I.intermediate_region_code, I.intermediate_region_name, round(cast(avg(a.value) as numeric)) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded I
where a.area_code_m49 = I.m49_code and a.item_code = '22013' and I.intermediate_region_code is not null
group by I.intermediate_region_code, I.intermediate_region_name
order by I.intermediate_region_name;


-- Exercises for you:

-- create a query for Q3 mentioned above
select S.sub_region_code, S.sub_region_name, round(cast(avg(a.value) as numeric)) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded S
where a.area_code_m49 = S.m49_code and a.item_code = '22013' and S.sub_region_code is not null
group by S.sub_region_code, S.sub_region_name;
order by S.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermediate region in AFrica
--    and not including countries where intermediate region is empty
select I.intermediate_region_code, I.intermediate_region_name,
	round(cast(avg(a.value) as numeric)) as avg_gdp,
	round(cast(max(a.value) as numeric)) as max_gdp,
	round(cast(min(a.value) as numeric)) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded I
where a.area_code_m49 = I.m49_code and a.item_code = '22013' and I.intermediate_region_code is not null
group by I.intermediate_region_code, I.intermediate_region_name
order by I.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)
select I.intermediate_region_code, I.intermediate_region_name,
	round(cast(avg(a.value) as numeric)) as avg_gdp,
	round(cast(max(a.value) as numeric)) as max_gdp,
	round(cast(min(a.value) as numeric)) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded I
where a.area_code_m49 = I.m49_code and a.item_code = '22013'
	and cast(a."year" as numeric) >= 2011
	and cast(a."year" as numeric) <= 2020
	and I.intermediate_region_code is not null
group by I.intermediate_region_code, I.intermediate_region_name
order by I.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)
select I.intermediate_region_code, I.intermediate_region_name,
	round(cast(avg(a.value) as numeric)) as avg_gdp,	
	round(cast(max(a.value) as numeric)) as max_gdp,
	round(cast(min(a.value) as numeric)) as min_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded I
where a.area_code_m49 = I.m49_code and a.item_code = '22013'
	and I.intermediate_region_code is not null
group by I.intermediate_region_code, I.intermediate_region_name having cast(avg(a.value) as numeric) <= 4000
-- CONDITION FOR AVG_GDP <= $4000 MUST BE ADDED USING HAVING, BECAUSE AGGREGATE FUNCTIONS CANNOT BE USED IN WHERE --
order by I.intermediate_region_name;
