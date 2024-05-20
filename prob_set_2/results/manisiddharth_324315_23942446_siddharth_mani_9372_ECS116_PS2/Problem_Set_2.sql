set search_path to food_sec_v01;

-- delete all data from m49_codes_expanded
delete from m49_codes_expanded;

-- specifically: create a query that gives the row of m49_codes_expanded
--    for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';

-- before we go on, let's see the values for itermediate_region
--   and sub_region that are associated with countries in Africa
--   (recall that "Africa" shows up in the region_name column)
     
-- the two queries are: find distinct sub-region names associated with
--    countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name;

select distinct intermediate_region_name, country_or_area  
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;


-- Why are there null values in the answers to both of these queries?

-- Here's a query that finds all countries in Africa for which the
--    intermediate_region_name is NULL
select *
from m49_codes_expanded mce
where intermediate_region_name = '' and region_name = 'Africa';

-- Here is a query that lists, for each country in Africa,
--    the country, the intermediate_region and the sub_region,
--    including both names and m49 codes for the countries/regions
     
-- (Condsider trying to create this query on your own, before seeing
--    how I do it)
select distinct
 	afa.area_code_m49,
 	afa.area,
 	ir.intermediate_region_name,
 	ir.intermediate_region_code,
 	sr.sub_region_name,
 	sr.sub_region_code
from africa_fs_ac afa
join m49_codes_expanded ir on ir.m49_code = afa.area_code_m49
join m49_codes_expanded sr on sr.m49_code = afa.area_code_m49

-- Now, I want to practice doing some aggregation (group-by) queries 
--    that use groupings by sub- and intermediate-regions
  
-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
--       (ignore countries that do not fall into one of the sub regions)

-- Q1
select 
	area_code_m49, 
	area, 
	round(avg(value)::numeric, 2) as average_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Q2
select 
	mce.intermediate_region_code, 
	mce.intermediate_region_name , 
	round(avg(value)::numeric, 2) as avg
from africa_fs_ac afa 
join m49_codes_expanded mce on mce.m49_code = afa.area_code_m49 
where afa.item_code = '22013' and mce.intermediate_region_code notnull
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- Q3
select 
	mce.sub_region_code, 
	mce.sub_region_name, 
	round(avg(value)::numeric, 2) as avg
from africa_fs_ac afa 
join m49_codes_expanded mce on mce.m49_code = afa.area_code_m49 
where afa.item_code = '22013'
group by mce.sub_region_code, mce.sub_region_name 
order by mce.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
--    over the years
--    for each intermeidate region in Africa
select 
	mce.intermediate_region_code, 
	mce.intermediate_region_name , 
	round(avg(value)::numeric, 2) as avg_gdp,
	max(value) as max_gdp,
	min(value) as min_gdp
from africa_fs_ac afa 
join m49_codes_expanded mce on mce.m49_code = afa.area_code_m49 
where afa.item_code = '22013' and mce.intermediate_region_code notnull
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
--    for each intermediate region in Africa,
--    but just for 2011 to 2020
select 
	mce.intermediate_region_code, 
	mce.intermediate_region_name, 
	round(avg(value)::numeric, 2) as avg_gdp,
	max(value) as max_gdp,
	min(value) as min_gdp
from africa_fs_ac afa 
join m49_codes_expanded mce on mce.m49_code = afa.area_code_m49 
where 
	afa.item_code = '22013' and 
	mce.intermediate_region_code notnull and
	afa.year_code::numeric between 2011 and 2020
group by mce.intermediate_region_code, mce.intermediate_region_name
order by mce.intermediate_region_name;

-- create a query that gives min and max gdp
--    for each intermediate region in Africa
--    (going across all years)
--    but show only countries where the avg gdp is <= $4000
select 
	mce.intermediate_region_code, 
	mce.intermediate_region_name , 
	round(avg(value)::numeric, 2) as avg_gdp,
	max(value) as max_gdp,
	min(value) as min_gdp
from africa_fs_ac afa 
join m49_codes_expanded mce on mce.m49_code = afa.area_code_m49 
where afa.item_code = '22013' and mce.intermediate_region_code notnull
group by mce.intermediate_region_code, mce.intermediate_region_name
having round(avg(value)::numeric, 2) <= 4000
order by mce.intermediate_region_name;