set search_path to food_sec;

show search_path;

alter table m49_codes_expanded
alter column global_code type varchar(3),
alter column region_code type varchar(3),
alter column sub_region_code type varchar(3),
alter column intermediate_region_code type varchar(3),
alter column m49_code type varchar(3);


-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)

select * from m49_codes_expanded mce 
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


select distinct intermediate_region_name, country_or_area from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

select distinct sub_region_name, country_or_area from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name;



-- Why are there null values in the answers to both of these queries?
-- missing values


-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL

select mce.m49_code , mce.country_or_area from m49_codes_expanded mce
where region_name = 'Africa' and intermediate_region_code ISNULL
order by country_or_area;
-- for some reason this is not empty but the next one is empty for me?



-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is



select m49_code , country_or_area from m49_codes_expanded 
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;
     
-- code returns different results? isnull returns results but empty string returns nothing for me


select a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
  and sr.m49_code = a.area_code_m49;
  

select a.area_code_m49, a.area, ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49 
  and a.area_code_m49 = '024';


-- why are there so many records, just for Angola ??
--  BTW, they all look the same.  Hmmm
  
-- WAIT -- when I think of the cross product of
--      africa_fs_ac X m49_codes_expanded X m49_codes_expanded
--   how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
  
select count(*)
from africa_fs_after_cleaning_db 
where area_code_m49 = '024';

select distinct a.area_code_m49, a.area,ir.intermediate_region_code, ir.intermediate_region_name,
       sr.sub_region_code, sr.sub_region_name 
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49 and sr.m49_code = a.area_code_m49;

-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
  
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)
  
-- Q1:  (try this yourself before looking at my answer!)
  
-- Hint: first, let's find where the values for GDP per capita are
select * from africa_fs_after_cleaning_db afacd 
where item like('%Gross%');

-- so the item_code for GDP is 22013
  

-- remember: if you want both area_code_m49 and area in your SELECT
--    columns, then you have to include both of them in the group by
  


select area_code_m49, area, avg(value)
from africa_fs_after_cleaning_db afacd
where item_code = '22013'
group by area_code_m49, area
order by area;





-- hmm - would be nice to have the avg rounded to 2 digits; will make it
--   more readable
-- e.g., see https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db afacd 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and not including countries not in any intermediate region)

-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
  
select mce.intermediate_region_code, mce.intermediate_region_name,
       round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db afacd , m49_codes_expanded mce 
where mce.m49_code = afacd.area_code_m49 and item_code = '22013'
  and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;


-- Exercises for you:

-- create a query for Q3 mentioned above

select sr.sub_region_code, sr.sub_region_name,
       round(avg(afacd.value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db afacd
join m49_codes_expanded m on m.m49_code = afacd.area_code_m49
join m49_codes_expanded sr on sr.m49_code = m.sub_region_code
where afacd.item_code = '22013'  
  and sr.sub_region_code != ''
group by sr.sub_region_code, sr.sub_region_name
order by sr.sub_region_name;


-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty

select mce.intermediate_region_code, mce.intermediate_region_name,
       round(avg(afacd.value)::numeric, 2) as avg_gdp,
       max(afacd.value) as max_gdp,
       min(afacd.value) as min_gdp
from africa_fs_after_cleaning_db afacd
join m49_codes_expanded mce on mce.m49_code = afacd.area_code_m49
where afacd.item_code = '22013'
  and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)


SELECT mce.intermediate_region_code,
       mce.intermediate_region_name,
       ROUND(AVG(afacd.value)::NUMERIC, 2) AS avg_gdp,
       MAX(afacd.value) AS max_gdp,
       MIN(afacd.value) AS min_gdp
FROM africa_fs_after_cleaning_db afacd
JOIN m49_codes_expanded mce ON mce.m49_code = afacd.area_code_m49
WHERE afacd.item_code = '22013'
  AND mce.intermediate_region_code != ''
  AND CAST(SUBSTRING(afacd.year FROM '^\d+') AS INTEGER) BETWEEN 2011 AND 2020 -- using regex to get first year
GROUP BY mce.intermediate_region_code, mce.intermediate_region_name
ORDER BY mce.intermediate_region_name;



-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

select mce.intermediate_region_code,
       mce.intermediate_region_name,
       min(afacd.value) as min_gdp,
       max(afacd.value) as max_gdp
from africa_fs_after_cleaning_db afacd
join m49_codes_expanded mce on mce.m49_code = afacd.area_code_m49
where afacd.item_code = '22013' 
  and mce.intermediate_region_code != ''
group by mce.intermediate_region_code, mce.intermediate_region_name
having round(avg(afacd.value)::numeric, 2) <= 4000
order by mce.intermediate_region_name;





