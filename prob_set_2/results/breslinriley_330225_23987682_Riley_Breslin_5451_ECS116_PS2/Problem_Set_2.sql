-- Riley Breslin, 920645451, Problem Set 2  

set search_path to food_sec;

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
      
-- empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

-- now import the file m49_codes_expanded.csv directly into
--    the table m49_codes_expanded

-- check that the data looks like the data in the csv file

-- also, as a sanity check, does the count of tuples in your
--    table match the count in the csv file?

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)

select * from m49_codes_expanded where country_or_area = 'Angola';

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
--    intermediate_region_name is NULL

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code ISNULL
order by country_or_area;

-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is:

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = ''
order by country_or_area;
     
-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

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
where area_code_m49 = '024';

-- 415 of them

-- But I only want one record for each country, not 400+ for each country

-- We can use the DISTINCT on the whole query, as follows

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;

-- Interestingly, most but not all countries from Africa have an intermediate region
  

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

-- create a query for Q3 mentioned above

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in Afrrica
--    and not including countries where intermediate region is empty

select m.intermediate_region_code,
       m.intermediate_region_name, a."year",
       round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, 
       min(value) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name,
         a."year"
order by m.intermediate_region_name;


-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

select m.intermediate_region_code,
       m.intermediate_region_name, a."year",
       round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, 
       min(value) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
  and cast(a."year" as integer) >= 2011
  and cast(a."year" as integer) <= 2020
group by m.intermediate_region_code,
         m.intermediate_region_name,
         a."year"
order by m.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

select m.intermediate_region_code,
       m.intermediate_region_name, 
       min(value) as min_gdp,
       max(value) as max_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
having avg(cast(a.value as numeric)) <= 4000
order by m.intermediate_region_name;



