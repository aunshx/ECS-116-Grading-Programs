set search_path to food_sec;
show search_path;

-- empty everything out of m49_codes_expanded
delete from m49_codes_expanded;

-- sanity check ... is the table empty?
-- Answer: yes the table is empty
select * from m49_codes_expanded;

-- create a query that gives the row of m49_codes_expanded for the country "Angola"
select * from m49_codes_expanded mce
where country_or_area = 'Angola'; 

--find distinct sub-region names associated with countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name from m49_codes_expanded mce
where region_name = 'Africa';
select distinct intermediate_region_name from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name;


--Why are there null values in the answers to both of these queries?
--Answer: There are null values possibly because some countries might not have an administrative structure that uses sub-regions or intermediate regions
-- find all countries in Africa for which the intermediate_region_name is NULL
select m49_code , country_or_area from m49_codes_expanded
where region_name = 'Africa'
and intermediate_region_code isnull
order by country_or_area;

-- not NULL, we need '' (empty string)
select m49_code, country_or_area from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

--list only the countries that have empty string for intermediate_region_code or name
select country_or_area from m49_codes_expanded mce 
where intermediate_region_code = '' or intermediate_region_name = '';

--list, for each country in Africa, the country, the intermediate_region and the sub_region,
-- including both names and m49 codes for the countries/regions
select country_or_area as country, m49_code as country_code, intermediate_region_name as intermediate_region,
intermediate_region_code as intermediate_code, sub_region_name as sub_region, sub_region_code as sub_code from m49_codes_expanded mce 
where region_name = 'Africa'
order by country_or_area;

-- what column is holding the m49 code for Angola?
-- Answer: m49 code for Angola is 024

-- what column is holding the m49 code for "Middle Africa"?
-- m49 code is 017

-- what column is holding the m49 code for "Sub-Saharan Africa"?
-- m49 code is 202

--use africa_fs_ac to get m49 codes and country names for countries in Africa
-- use one copy of m49_codes_expanded to provide the intermediate region code and name
-- use a second copy of m49_codes_expanded to provide the sub region code and name
select area_code_m49, area, mc1.intermediate_region_code as intermediate_code, mc1.intermediate_region_name as intermediate_region,
mc2.sub_region_name as sub_region, mc2.sub_region_code as sub_code 
from africa_fs_ac afa, m49_codes_expanded mc1, m49_codes_expanded mc2
where afa.area_code_m49 = mc1.m49_code 
and afa.area_code_m49 = mc2.m49_code;

-- Let's restrict the query to just Angola
select area_code_m49, area, mc1.intermediate_region_code as intermediate_code, mc1.intermediate_region_name as intermediate_region,
mc2.sub_region_name as sub_region, mc2.sub_region_code as sub_code 
from africa_fs_ac afa, m49_codes_expanded mc1, m49_codes_expanded mc2
where afa.area_code_m49 = mc1.m49_code 
and afa.area_code_m49 = mc2.m49_code
and afa.area_code_m49 = '024';

-- how many records in africa_fs_ac have area_code_m49 = '024' (Angola)?
-- Answer: there are 415 records
select count(*)
from africa_fs_ac
where area_code_m49 = '024';

-- We can use the DISTINCT on the Angola query first (to check if we get one row)
select distinct area_code_m49, area, mc1.intermediate_region_code as intermediate_code, mc1.intermediate_region_name as intermediate_region,
mc2.sub_region_name as sub_region, mc2.sub_region_code as sub_code 
from africa_fs_ac afa, m49_codes_expanded mc1, m49_codes_expanded mc2
where afa.area_code_m49 = mc1.m49_code 
and afa.area_code_m49 = mc2.m49_code
and afa.area_code_m49 = '024';

-- We can use the DISTINCT on the whole query, as follows
-- Answer: We get 54 distinct records
select distinct area_code_m49, area, mc1.intermediate_region_code as intermediate_code, mc1.intermediate_region_name as intermediate_region,
mc2.sub_region_name as sub_region, mc2.sub_region_code as sub_code 
from africa_fs_ac afa, m49_codes_expanded mc1, m49_codes_expanded mc2
where afa.area_code_m49 = mc1.m49_code 
and afa.area_code_m49 = mc2.m49_code;

-- 22,013 is the item code for GDP
select distinct item_code, item from africa_fs_ac afa;
-- Q1: find the average GDP per capita for each african country (going over all years)
select avg(value) as avg_GDP, area, area_code_m49 from africa_fs_ac afa 
where item_code = '22013'
group by area, area_code_m49
order by area;

-- average the gdp per capita to 2-decimal places
-- this is the method found through the stackoverflow link:
select round(avg(value)::numeric, 2) as avg_GDP, area, area_code_m49 from africa_fs_ac afa 
where item_code = '22013'
group by area, area_code_m49
order by area;

-- format to have average gdp left-justified
select to_char(avg(value), 'FM999999999.00') as avg_GDP, area, area_code_m49 from africa_fs_ac afa 
where item_code = '22013'
group by area, area_code_m49
order by area;

-- Q2: getting avg gdp grouped by african intermediate region
select round(avg(afa.value)::numeric, 0) as avg_GDP, 
mc1.intermediate_region_code as intermediate_code, 
mc1.intermediate_region_name as intermediate_region 
from africa_fs_ac afa, m49_codes_expanded mc1
where afa.item_code = '22013'
and afa.area_code_m49 = mc1.m49_code
group by intermediate_code, intermediate_region
order by mc1.intermediate_region_name;


-- Exercises for you:

-- (i) create a query for Q3: find the average GDP per capita for each african sub region
select round(avg(afa.value)::numeric, 0) as avg_GDP, 
mc2.sub_region_code as sub_code, 
mc2.sub_region_name as sub_region 
from africa_fs_ac afa, m49_codes_expanded mc2
where afa.item_code = '22013'
and afa.area_code_m49 = mc2.m49_code
group by sub_code, sub_region
order by mc2.sub_region_name;

-- (ii) create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years for each intermeidate region in Africa and not including 
-- countries where intermediate region is empty
select round(avg(afa.value)::numeric, 0) as avg_GDP, round(min(afa.value)::numeric,0) as min_GDP, 
round(max(afa.value)::numeric,0) as max_GDP, mc1.intermediate_region_code as intermediate_code, 
mc1.intermediate_region_name as intermediate_region 
from africa_fs_ac afa, m49_codes_expanded mc1
where afa.item_code = '22013'
and mc1.intermediate_region_name != ''
and afa.area_code_m49 = mc1.m49_code
group by intermediate_code, intermediate_region
order by mc1.intermediate_region_name;

-- (iii) create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
-- (and not including countries where intermediate region is empty)
select round(avg(afa.value)::numeric, 0) as avg_GDP, round(min(afa.value)::numeric,0) as min_GDP, 
round(max(afa.value)::numeric,0) as max_GDP, mc1.intermediate_region_code as intermediate_code, 
mc1.intermediate_region_name as intermediate_region 
from africa_fs_ac afa, m49_codes_expanded mc1
where afa.item_code = '22013'
and mc1.intermediate_region_name != ''
and afa.area_code_m49 = mc1.m49_code
and afa.year_code::numeric between 2011 and 2020
group by intermediate_code, intermediate_region
order by mc1.intermediate_region_name;

-- (iv) create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
-- (and not including countries where intermediate region is empty)
select round(min(afa.value)::numeric,0) as min_GDP, 
round(max(afa.value)::numeric,0) as max_GDP, mc1.intermediate_region_code as intermediate_code, 
mc1.intermediate_region_name as intermediate_region 
from africa_fs_ac afa, m49_codes_expanded mc1
where afa.item_code = '22013'
and mc1.intermediate_region_name != ''
and afa.area_code_m49 = mc1.m49_code
group by intermediate_code, intermediate_region
having round(avg(afa.value)::numeric, 0) <= 4000
order by mc1.intermediate_region_name;

























