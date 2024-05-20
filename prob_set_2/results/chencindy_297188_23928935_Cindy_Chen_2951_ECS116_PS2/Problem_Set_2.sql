-- Basics
set search_path to food_sec_v1;

--delete from m49_codes_expanded;

select count(*) from m49_codes_expanded;

-- create a query that gives the row of m49_codes_expanded
-- for the country "Angola"
select *
from m49_codes_expanded 
where country_or_area = 'Angola';

-- the two queries are: find distinct sub-region names associated with
-- countries in Africa, and same thing for intermediate-region names
select distinct sub_region_name
from m49_codes_expanded mce 
where region_name = 'Africa';

select distinct intermediate_region_name 
from m49_codes_expanded mce 
where region_name = 'Africa';

-- Here's a query that finds all countries in Africa for which the
-- sub_region name is NULL
select country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and sub_region_name isnull;

select country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and sub_region_name = '';

-- Exercise for you: how to list only the countries that have
-- empty string for intermediate_region_code or name
select country_or_area
from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_name = '';

-- Here is a query that lists, for each country in Africa,
-- the country, the intermediate_region and the sub_region,
-- including both names and m49 codes for the countries/regions
select distinct country_or_area, intermediate_region_name, sub_region_name, m49_code
from m49_codes_expanded mce 
where region_name = 'Africa';

select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- For example, consider these 3 queries;
-- Q1: find the average GDP per capita for each african country (going over all years)
-- Q2: find the average GDP per capita for each african intermediate region
-- Q3: find the average GDP per capita for each african sub region
-- (ignore countries that do not fall into one of the sub regions)

-- Q1:
select area_code_m49, area, avg(value) as average_GDP
from africa_fs_ac afa 
where item_code = '22013'
group by area_code_m49, area;

-- Q2:
select mce.intermediate_region_code, mce.intermediate_region_name, avg(afa.value) as average_GDP
from africa_fs_ac afa 
join m49_codes_expanded mce 
on mce.m49_code = afa.area_code_m49 
where item_code = '22013'
group by mce.intermediate_region_code, mce.intermediate_region_name;

-- Q3:
select mce.sub_region_code, mce.sub_region_name , avg(afa.value) as average_GDP
from africa_fs_ac afa 
join m49_codes_expanded mce 
on mce.m49_code = afa.area_code_m49 
where item_code = '22013'
group by mce.sub_region_code, mce.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica
select mce.intermediate_region_code, mce.intermediate_region_name, avg(afa.value) as average_GDP, 
min(afa.value), max(afa.value)
from africa_fs_ac afa 
join m49_codes_expanded mce 
on mce.m49_code = afa.area_code_m49 
where item_code = '22013'
group by mce.intermediate_region_code, mce.intermediate_region_name;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020
select mce.intermediate_region_code, mce.intermediate_region_name, avg(afa.value) as average_GDP, 
min(afa.value), max(afa.value)
from africa_fs_ac afa 
join m49_codes_expanded mce 
on mce.m49_code = afa.area_code_m49 
where item_code = '22013'
and afa.year like '201%' or afa.year like '2020'
group by mce.intermediate_region_code, mce.intermediate_region_name;


-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000
select mce.intermediate_region_code, mce.intermediate_region_name, avg(afa.value) as average_GDP, 
min(afa.value), max(afa.value)
from africa_fs_ac afa 
join m49_codes_expanded mce 
on mce.m49_code = afa.area_code_m49 
where item_code = '22013'
group by mce.intermediate_region_code, mce.intermediate_region_name
having avg(afa.value) < 4000
order by avg(afa.value);