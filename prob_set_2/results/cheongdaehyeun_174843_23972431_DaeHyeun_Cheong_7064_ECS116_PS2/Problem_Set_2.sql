set search_path to food_sec;

show search_path;

delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

-- now let's look at one record in m49_codes_expanded, kind of closely

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)

select * 
from m49_codes_expanded
where country_or_area = 'Angola';

-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names

select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa';

select distinct intermediate_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa';

-- Why are there null values in the answers to both of these queries?

-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL

select distinct country_or_area 
from m49_codes_expanded 
where region_name = 'Africa' 
and intermediate_region_name isnull;

-- hmm - why is this coming up empty?
-- ahhhh, in the select distinct queries above, the empty values are
--    not NULL, they are ''  (empty string)
-- so the query I wanted is

select distinct country_or_area 
from m49_codes_expanded 
where region_name = 'Africa' 
and intermediate_region_name ='';

-- Hmm, this includes not only countries, but also bigger regions
-- Exercise for you: how to list only the countries that have
--    empty string for intermediate_region_code or name

select distinct country_or_area 
from m49_codes_expanded 
where region_name = 'Africa' 
	and intermediate_region_name =''
	and entity_category = 'current country';
	
-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions

select distinct a.area_code_m49, a.area,
       ir.intermediate_region_code, ir.intermediate_region_name,
       ir.sub_region_code, ir.sub_region_name 
from africa_fs_ac a, m49_codes_expanded ir
where ir.m49_code = a.area_code_m49;

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

select area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac
where item_code = 22013
group by area 
order by area;

-- now, how about Q2, getting avg gdp grouped by intermediate region
--    (and not including countries not in any intermediate region)

-- HINT: remember, we need to create groups of records from 
--    africa_fs_ac based on the intermediate regions they fall into
 
select mce.intermediate_region_name, round(avg(afa.value)::numeric, 2) as avg_gdp
from m49_codes_expanded mce
join africa_fs_ac afa on mce.m49_code = afa.area_code_m49 
where afa.item_code = 22013 and mce.intermediate_region_name != ''
group by mce.intermediate_region_name  

-- Exercises for you:

-- create a query for Q3 mentioned above

select mce.sub_region_name, round(avg(afa.value)::numeric, 2) as avg_gdp
from m49_codes_expanded mce
join africa_fs_ac afa on mce.m49_code = afa.area_code_m49 
where afa.item_code = 22013 and mce.sub_region_name != ''
group by mce.sub_region_name 

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in AFrica
--    and not including countries where intermediate region is empty

select mce.intermediate_region_name, afa.year, round(avg(afa.value)::numeric, 2) as avg_gdp,
round(max(afa.value)::numeric, 2) as max_gdp, round(min(afa.value)::numeric, 2) as min_gdp
from m49_codes_expanded mce
join africa_fs_ac afa on mce.m49_code = afa.area_code_m49 
where afa.item_code = 22013 and mce.intermediate_region_name != ''
group by mce.intermediate_region_name, afa.year
order by mce.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
--    (and not including countries where intermediate region is empty)

select mce.intermediate_region_name, afa.year, round(avg(afa.value)::numeric, 2) as avg_gdp,
round(max(afa.value)::numeric, 2) as max_gdp, round(min(afa.value)::numeric, 2) as min_gdp
from m49_codes_expanded mce
join africa_fs_ac afa on mce.m49_code = afa.area_code_m49 
where afa.item_code = 22013 
	and mce.intermediate_region_name != '' 
	and afa.year >= '2011' 
	and afa.year <= '2020'
group by mce.intermediate_region_name, afa.year
order by mce.intermediate_region_name, afa.year;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
--    (and not including countries where intermediate region is empty)

select mce.intermediate_region_name, 
	round(max(afa.value)::numeric, 2) as max_gdp, 
	round(min(afa.value)::numeric, 2) as min_gdp
from m49_codes_expanded mce
join africa_fs_ac afa on mce.m49_code = afa.area_code_m49 
where afa.item_code = 22013 
	and mce.intermediate_region_name != ''
group by mce.intermediate_region_name, afa.year
having avg(afa.value) <= 4000
order by mce.intermediate_region_name;


