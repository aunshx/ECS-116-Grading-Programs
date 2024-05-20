set search_path to food_sec;

show search_path;

-- to the following to empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty? YES
select count(*) from m49_codes_expanded;

--also, as a sanity check, does the count of tuples in your
-- table match the count in the csv file? YES, there is 299 tuples
select count(*) from m49_codes_expanded;

-- specifically: create a query that gives the row of m49_codes_expanded
-- for the country "Angola"

select *
from m49_codes_expanded mce 
where country_or_area = 'Angola';

-- so: Angola is in
-- intermediate_region "Middle Africa"
-- sub_region "Sub-Saharan Africa"
-- region "Africa"

-- before we go on, let's see the values for itermediate_region
-- and sub_region that are associated with countries in Africa
-- (recall that "Africa" shows up in the region_name column)
-- the two queries are: find distinct sub-region names associated with
-- countries in Africa, and same thing for intermediate-region names

select distinct sub_region_name
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area ;

-- Here's a query that finds all countries in Africa for which the
-- sub_region name is NULL
select m49_code , country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
	and intermediate_region_code isnull
order by country_or_area;

-- so the query I wanted is
select m49_code , country_or_area
from m49_codes_expanded mce 
where region_name ='Africa'
	and intermediate_region_code = ''
order by country_or_area;

-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
select m49_code , country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
	and intermediate_region_code = ''
	and country_or_area not in (SELECT sub_region_name FROM m49_codes_expanded)
	AND country_or_area NOT IN (SELECT region_name FROM m49_codes_expanded)
order by country_or_area;

-- Here is a query that lists, for each country in Africa,
-- the country, the intermediate_region and the sub_region,
-- including both names and m49 codes for the countries/regions
-- (Condsider trying to create this query on your own, before seeing
-- how I do it)
-- hint: Lood at the answer to the above query, which has exactly one row
-- Ask yourself, as you look at that one row
-- what column is holding the m49 code for Angola?
-- what column is holding the m49 code for "Middle Africa"?
-- what column is holding the m49 code for "Sub-Saharan Africa"?
-- Now think in terms of a select query that identifies 3 tables
-- use africa_fs_ac to get m49 codes and country names for countries in Africa
-- use one copy of m49_codes_expanded to provide the intermediate region code
--and name
-- use a second copy of m49_codes_expanded to provide the sub region code and
--name
-- What are the WHERE conditions you need to put on tuples from these
-- three tables so that you will get the intermediate and sub regions
-- for a country from africa_fs_ac?
-- What columns do you need from the three tables for the query output?
-- in this query, I am using the table africa_fs_ac to get the
-- countries in Africa. I could create a similar query that
-- uses only the m49_codes_expanded 3 times
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

-- WAIT -- when I think of the cross product of
-- africa_fs_ac X m49_codes_expanded X m49_codes_expanded
-- how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
select count(*)
from africa_fs_ac afa 
where area_code_m49 = '024';

-- We can use the DISTINCT on the whole query, as follows
select distinct a.area_code_m49, a.area,
	ir.intermediate_region_code, ir.intermediate_region_name,
	sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
	and sr.m49_code = a.area_code_m49;

-- Now, I want to practice doing some aggregation (group-by) queries
-- that use groupings by sub- and intermediate-regions

-- Q1: find the average GDP per capita for each african country (going over all
--years)
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

-- remember: if you want both area_code_m49 and area in your SELECT
-- columns, then you have to include both of them in the group by
select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- hmm - would be nice to have the avg rounded to 2 digits; will make it
-- more readable
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- or, since we want it to look very pretty in the output

select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- well, it would look even more pretty if the avg_gdp column was
-- right-justified. Oh well. I'll just use Round to numeric with no
-- decimal places from here on)

-- Q2: find the average GDP per capita for each african intermediate region
select m.intermediate_region_code,
	m.intermediate_region_name,
	round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
group by m.intermediate_region_code,
	m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercises for you:
-- create a query for Q3 mentioned above (find the average GDP per capita for each african sub region
-- (ignore countries that do not fall into one of the sub regions))

select distinct sub_region_name
from m49_codes_expanded mce 
where region_name ='Africa'

select mce.sub_region_code,
	mce.sub_region_name,
	round(avg(value):: numeric, 0) as avg_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
	and item_code = '22013'
	and mce.sub_region_code != ''
group by mce.sub_region_code,
	mce.sub_region_name
order by mce.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica
select m.intermediate_region_code,
 	m.intermediate_region_name,
  	round(avg(value)::numeric, 0) as avg_gdp,
    round(max(value)::numeric, 0) as max_gdp,
    round(max(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m 
where m.m49_code = a.area_code_m49 
  and item_code = '22013'
  and m.intermediate_region_code != ''
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020


select m.intermediate_region_code,
	m.intermediate_region_name,
 	round(avg(a.value)::numeric, 0) AS avg_gdp,
    round(max(a.value)::numeric, 0) AS max_gdp,
    round(min(a.value)::numeric, 0) AS min_gdp
    
from africa_fs_ac afa, m49_codes_expanded mce 
where mce.m49_code = afa fr.area_code_m49 
	and item_code = '22013'
    and m.intermediate_region_code != ''
group by m.intermediate_region_code,
	m.intermediate_region_name
ORDER BY 
    m.intermediate_region_name;
   
-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
select area_code_m49 
from africa_fs_ac 
where item_code = '22013'
group by area_code_m49
having AVG(value) <= 4000;

select m.intermediate_region_code,
       m.intermediate_region_name,
       ROUND(MIN(value)::numeric, 0) AS min_gdp,
       ROUND(MAX(value)::numeric, 0) AS max_gdp
from africa_fs_ac a
join m49_codes_expanded m ON m.m49_code = a.area_code_m49 
where item_code = '22013'
  and m.intermediate_region_code != ''
  and a.area_code_m49 in (
  	select area_code_m49 
	from africa_fs_ac 
	where item_code = '22013'
	group by area_code_m49
	having AVG(value) <= 4000
  )
group by m.intermediate_region_code,
         m.intermediate_region_name
order by m.intermediate_region_name;

