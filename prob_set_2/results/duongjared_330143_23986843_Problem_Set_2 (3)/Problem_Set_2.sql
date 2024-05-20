set search_path to food_sec;


-- now let's look at one record in m49_codes_expanded, kind of closely
-- specifically: create a query that gives the row of m49_codes_expanded
-- for the country "Angola"
-- (Try to build this by yourself, before looking how I do it!)
select *
from m49_codes_expanded mce
where country_or_area = 'Angola';


-- the two queries are: find distinct sub-region names associated with
-- countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;
select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name , country_or_area;

-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
-- Here is a query that lists, for each country in Africa,
-- the country, the intermediate_region and the sub_region,
-- including both names and m49 codes for the countries/regions
-- (Condsider trying to create this query on your own, before seeing
-- how I do it)
-- hint: Look at the answer to the fetching the one row about Angola
-- Ask yourself, as you look at that one row
-- what column is holding the m49 code for Angola?
-- what column is holding the m49 code for "Middle Africa"?
-- what column is holding the m49 code for "Sub-Saharan Africa"?
-- Now think in terms of a select query that identifies 3 tables
-- use africa_fs_ac to get m49 codes and country names for countriesin Africa
-- use one copy of m49_codes_expanded to provide the intermediateregion code and name
-- use a second copy of m49_codes_expanded to provide the sub regioncode and name
-- What are the WHERE conditions you need to put on tuples from these
-- three tables so that you will get the intermediate and sub regions
-- for a country from africa_fs_ac?
-- What columns do you need from the three tables for the query output?
-- in this query, I am using the table africa_fs_ac to get the
-- countries in Africa. I could create a similar query that
-- uses only the m49_codes_expanded 3 times


select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- Q3: find the average GDP per capita for each african sub region
-- (ignore countries that do not fall into one of the sub regions)
select *
from africa_fs_after_cleaning_db
where item LIKE('%Gross%');

select  m.sub_region_code,m.sub_region_name , avg(a.value)
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.sub_region_name != ''
group by m.sub_region_code,m.sub_region_name  
;
-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica
-- and not including countries where intermediate region is empty
select m.intermediate_region_code,m.intermediate_region_name,
avg(value) as avg_gdp, min(value) as min_gdp, max(value) as max_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and m.intermediate_region_name != ''
group by m.intermediate_region_code,
m.intermediate_region_name
;
-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
-- (and not including countries where intermediate region is empty)
select distinct "year", year_code  from africa_fs_after_cleaning_db afacd order by year_code ;
select m.intermediate_region_code,m.intermediate_region_name,
avg(value) as avg_gdp, min(value) as min_gdp, max(value) as max_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and year_code >= (select distinct year_code from africa_fs_after_cleaning_db where "year" = '2011')
and year_code <= (select distinct year_code from africa_fs_after_cleaning_db where "year" = '2020')
and m.intermediate_region_name != ''
group by m.intermediate_region_code,
m.intermediate_region_name
;
-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)
select m.intermediate_region_code,m.intermediate_region_name,
avg(value) as avg_gdp, min(value) as min_gdp, max(value) as max_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
and item_code = '22013'
and (a.area_code_m49  in (select a.area_code_m49 
	from africa_fs_after_cleaning_db a, m49_codes_expanded m
	where m.m49_code = a.area_code_m49
	and item_code = '22013'
	group by a.area_code_m49
	having avg(value)<=4000))
and m.intermediate_region_name != ''
group by m.intermediate_region_code,
m.intermediate_region_name
;