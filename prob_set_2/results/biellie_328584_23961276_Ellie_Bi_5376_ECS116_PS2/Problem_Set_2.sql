/*
 * Ellie Bi
 * ECS 116
 * Problem Set 2
 */

-- Basics
set search_path to food_sec;
show search_path;

-- Change m49 Data
delete from m49_codes_expanded;
select count(*) from m49_codes_expanded;

-- Select Angola 
select *
from m49_codes_expanded mce 
where country_or_area = 'Angola'; -- Africa, Sub-Saharan Africa, Middle Africa

-- Values in Africa: 
--- Distinct Sub-Region Name
select distinct sub_region_name
from m49_codes_expanded mce 
where region_name = 'Africa'
order by sub_region_name;

--- Distinct Intermediate-Region Name
select distinct intermediate_region_name, country_or_area 
from m49_codes_expanded mce 
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

-- Find NULL Values in African Countries
select m49_code, country_or_area 
from m49_codes_expanded mce 
where region_name = 'Africa'
and intermediate_region_code isnull
order by country_or_area;

---- Empty values are not null, they are empty strings.

-- Find Empty Strings in African Countries
select m49_code , country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
and intermediate_region_code = ''
order by country_or_area;

-- MY ATTEMPT: List Countries that have Empty Strings for Intermediate Region Code / Name 
select distinct a.area_code_m49, a.area, intr.intermediate_region_name, subr.sub_region_code, subr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded intr, m49_codes_expanded subr
where intr.m49_code = a.area_code_m49
and subr.m49_code = a.area_code_m49;

-- Answer: List Countries that have Empty Strings for Intermediate Region Code / Name 
--- First Try
select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

--- Restricting Query to Angola
select a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49
and a.area_code_m49 = '024';

--- Look at Cross Product
select count(*)
from africa_fs_after_cleaning_db afacd 
where area_code_m49 = '024';

--- Use DISTINCT
select distinct a.area_code_m49, a.area,
ir.intermediate_region_code, ir.intermediate_region_name,
sr.sub_region_code, sr.sub_region_name
from africa_fs_after_cleaning_db a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
and sr.m49_code = a.area_code_m49;

-- MY ATTEMPT: Q1 Average GDP per Capita for Each African Country
select area_code_m49, area, avg(value) as avggdp
from africa_fs_after_cleaning_db 
where item_code = '22013'
group by area_code_m49, area
order by area;

-- Answer: Q1 Average GDP per Capita for Each African Country
--- Values for GDP per Capita
select *
from africa_fs_after_cleaning_db afacd 
where item LIKE('%Gross%');

--- Select by Item Code
select area_code_m49, area, avg(value)
from africa_fs_after_cleaning_db
where item_code = '22013'
group by area_code_m49, area
order by area;

--- Round the Values
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_after_cleaning_db
where item_code = '22013'
group by area_code_m49, area
order by area;

--- Reformat Nicer
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_after_cleaning_db
where item_code = '22013'
group by area_code_m49, area
order by area;

-- MY ATTEMPT: Q2 Average GDP per Capita for Each African Intermediate Region
select a.intermediate_region_code, a.intermediate_region_name, round(avg(value)::numeric, 2) as avggdp
from africa_fs_after_cleaning_db b, m49_codes_expanded a 
where a.m49_code = b.area_code_m49 and item_code = '22013'
group by a.intermediate_region_code, a.intermediate_region_name 
order by a.intermediate_region_name;

-- Answer: Q2 Average GDP per Capita for Each African Intermediate Region
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- Exercises:
--- Q3 Average GDP per Capita for Each African Sub Region 
select m.sub_region_code, m.sub_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_after_cleaning_db a, m49_codes_expanded m
where m.m49_code = a.area_code_m49 and item_code = '22013' and m.sub_region_code != ''
group by m.sub_region_code, m.sub_region_name 
order by m.sub_region_name;

--- Q: Average GDP, Max GDP, and Min GDP over the Years for Each African Intermediate Region
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name;

--- Q: Average GDP, Max GDP, and Min GDP for 2011-2020 for Each African Intermediate Region
select m.intermediate_region_code, m.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where item_code = '22013' and m.intermediate_region_code != '' and (
        left(a.year_code, 4)::numeric between 2011 and 2020 
        and right(a.year_code, 4)::numeric between 2011 and 2020
    )
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

--- Q: Average GDP, Max GDP, and Min GDP for All Years for Countries where Average GDP <= $4,000
select m.intermediate_region_code, m.intermediate_region_name, round(avg(a.value)::numeric, 0) as avg_gdp, max(a.value) as max_gdp, min(a.value) as min_gdp
from africa_fs_after_cleaning_db a
join m49_codes_expanded m on m.m49_code = a.area_code_m49
where item_code = '22013' and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
having avg(a.value) <= 4000
order by m.intermediate_region_name, m.intermediate_region_name;


