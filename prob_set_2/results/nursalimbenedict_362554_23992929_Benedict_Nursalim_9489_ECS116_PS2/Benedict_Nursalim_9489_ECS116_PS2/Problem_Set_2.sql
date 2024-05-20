set search_path to food_sec;


--delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;
select * 


-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"

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

-- Here's a query that finds all countries in Africa for which the
--    sub_region name is NULL

select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code ISNULL
order by country_or_area;

-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is


select m49_code , country_or_area 
from m49_codes_expanded 
where region_name = 'Africa'
  and intermediate_region_code = null 
order by country_or_area;

-- in this query, I am using the table africa_fs_ac to get the
--    countries in Africa.  I could create a similar query that
--    uses only the m49_codes_expanded 3 times
     
-- first try:
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
  
-- hmm, I am getting 21,688 answers, when I was expecting only 54 answers
-- what is going wrong?
  
-- Let's restrict the query to just Angola to see if that tells us anything
select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49 
  and a.area_code_m49 = '024';

-- why are there so many records, just for Angola ??
--  BTW, they all look the same.  Hmmm
  
-- WAIT -- when I think of the cross product of
--      africa_fs_ac X m49_codes_expanded X m49_codes_expanded
--   how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
  
-- 415 of them

-- But I only want one record for each country, not 400+ for each country

-- We can use the DISTINCT on the whole query, as follows

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
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
from africa_fs_after_cleaning_db afa
where item LIKE('%Gross%');

-- so the item_code for GDP is 22013
  

-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by
  
select area_code_m49, area, avg(value)
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- hmm - would be nice to have the avg rounded to 2 digits; will make it
--   more readable
-- e.g., see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- or, since we want it to look very pretty in the output
--   and still following the stackoverflow page
--   (although, this is too involved for putting on a test!)
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_after_cleaning_db a
where item_code = '22013'
group by area_code_m49, area
order by area;
-- well, it would look even more pretty if the avg_gdp column was
--   right-justified.  Oh well.  I'll just use Round to numeric with no
--   decimal places from here on)

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and ignoring countries not in any intermediate region)

-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
  
select m.intermediate_region_code,
       m.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermediate region in Africa

select  
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(value)::numeric, 0) as avg_gdp,
    min(value) as min_gdp,
    max(value) AS max_gdp
from 
    africa_fs_after_cleaning_db a
join 
    m49_codes_expanded m on m.m49_code = a.area_code_m49
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;


-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
  
select  
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(value)::numeric, 0) as avg_gdp,
    min(value) as min_gdp,
    max(value) AS max_gdp
from 
    africa_fs_after_cleaning_db a
join 
    m49_codes_expanded m on m.m49_code = a.area_code_m49
where
    a."year" between '2011' and '2020'
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;
  

-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

select 
    m.intermediate_region_code,
    m.intermediate_region_name,
    round(avg(value)::numeric, 0) as avg_gdp,
    min(value) as min_gdp,
    max(value) as max_gdp
from 
    africa_fs_after_cleaning_db a
join 
    m49_codes_expanded m on m.m49_code = a.area_code_m49 
group by 
    m.intermediate_region_code,
    m.intermediate_region_name
having 
    avg(value) <= 4000
order by 
    m.intermediate_region_name;

