set search_path to food_sec

show search_path

-- deletes everything from m49_codes_expanded
delete from m49_codes_expanded 

-- sanity check
select count(*) 
from m49_codes_expanded
-- yes, the table is now empty

select *
from m49_codes_expanded
-- it looks the same as the csv file that opened in my vscode

select count(*)
from m49_codes_expanded
-- yes, the number of tuples is the same as the csv file at 299

-- query for the country Angola
select *
from m49_codes_expanded
where country_or_area = 'Angola';

-- distinct sub-region names associated with countries in Africa
select distinct sub_region_name
from m49_codes_expanded
where region_name = 'Africa'
order by sub_region_name;

-- distinct intermediate-region names associated with countries in Africa
select distinct intermediate_region_name 
from m49_codes_expanded
where region_name = 'Africa'
order by intermediate_region_name;

-- there are null values because a tuple can fulfill the region_name of Africa, but not have a value else where

-- try 1 of removing null values
select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code isnull
order by country_or_area;

-- try 2 of removing null values
select m49_code, country_or_area, entity_category 
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code = ''
order by country_or_area;

-- exercise for you: list only countries that have empty string for intermediate_region_code or name
select m49_code, country_or_area, entity_category
from m49_codes_expanded
where region_name = 'Africa'
	and intermediate_region_code = ''
	and entity_category = 'current country'
order by country_or_area;

-- the area_code column in africa_fs_ac holds the m49 code for Angola
-- the intermediate_region_code column in m49_codes_expanded holds the m49 code for Middle Africa
-- the sub_region_code column in m49_codes_expanded holds the m49 code for Sub-Sahran Africa
-- we need a condtion that allows the three tables to connect on m49 code potentially
-- area code and name, intermediate region code and name, sub region cdoe and name 

-- first try
select a.area_code_m49, a.area, 
	ir.intermediate_region_code, ir.intermediate_region_name,
	sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
	and sr.m49_code = a.area_code_m49;
	
-- second try (restricting just to Angola)
select a.area_code_m49, a.area,
	ir.intermediate_region_code, ir.intermediate_region_name,
	sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
	and sr.m49_code = a.area_code_m49
	and a.area_code_m49 = '024';

-- records in africa_fs_ac with area_code_m49 = '024'
select count(*)
from africa_fs_ac
where area_code_m49 = '024';

-- third try (use distinct)
select distinct a.area_code_m49, a.area,
	ir.intermediate_region_code, ir.intermediate_region_name,
	sr.sub_region_code, sr.sub_region_name
from africa_fs_ac a, m49_codes_expanded ir, m49_codes_expanded sr
where ir.m49_code = a.area_code_m49
	and sr.m49_code = a.area_code_m49;

-- values for GDP per capita
select *
from africa_fs_ac afa
where item LIKE('%Gross%');

-- try 1: average GDP per capita for each african country
select area_code_m49, area, avg(value)
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- try 2: average GDP per capita for each african country (rounded to 2 digits)
select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp
from africa_fs_ac
where item_code = '22013'
group by area_code_m49, area
order by area;

-- try 3: average GDP per capita for each african country (fixed formatting)
select area_code_m49, area, to_char(avg(value), 'FM999999999.00') as avg_gdp
from africa_fs_ac a
where item_code = '22013'
group by area_code_m49, area
order by area;

-- average GDP per captia for each african intermediate region
select m.intermediate_region_code, m.intermediate_region_name, 
	round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
	and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- exercise for you part 1: query for q3 average GDP per captia for each african sub region
select m.sub_region_code, m.sub_region_name
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
	and m.sub_region_code != ''
group by m.sub_region_code, m.sub_region_name
order by m.sub_region_name

-- exercise for you part 2: query that gives the avg gdp, max gdp, and min gdp over the 
-- years for each intermediate region, not including empty intermediate reigon 
select m.intermediate_region_code, m.intermediate_region_name,
	round(avg(value)::numeric, 0) as avg_gdp, 
	round(max(value)::numeric, 0) as max_gdp,
	round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
	and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- exercise for you part 3: query that gives, avg, max, min gdp for each intermediate region,
-- just for 2011 to 2020 and not including empty intermediate region
select m.intermediate_region_code, m.intermediate_region_name,
	round(avg(value)::numeric, 0) as avg_gdp, 
	round(max(value)::numeric, 0) as max_gdp,
	round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
	and m.intermediate_region_code != ''
	and a.year >= '2011'
	and a.year <= '2020'
group by m.intermediate_region_code, m.intermediate_region_name
order by m.intermediate_region_name;

-- exercise for you part 4: query that give min and max for intermediate region across all years, 
-- but ony countries where avg gdp <= $4000, no including empty intermediate region
select m.intermediate_region_code, m.intermediate_region_name, m.country_or_area,
	round(avg(value)::numeric, 0) as avg_gdp, 
	round(max(value)::numeric, 0) as max_gdp,
	round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac a, m49_codes_expanded m
where m.m49_code = a.area_code_m49
	and item_code = '22013'
	and m.intermediate_region_code != ''
group by m.intermediate_region_code, m.intermediate_region_name, m.country_or_area
having avg(value) <= 4000;