-- Basics
set search_path to food_sec;

show search_path;

-- empty m49_codes_expanded
delete from m49_codes_expanded;

--check if table is empty
select count(*) from m49_codes_expanded;
-- After reimporting into the table itself, the count matches the csv file

-- specifically: create a query that gives the row of m49_codes_expanded for the country "Angola"
select *
from m49_codes_expanded
where country_or_area = 'Angola';

-- the values for itermediate_region and sub_region that are associated with countries in Africa (recall that "Africa" shows up in the region_name column)
-- the two queries are: find distinct sub-region names associated with countries in Africa, and same thing for intermediate-region names

select distinct sub_region_name
from m49_codes_expanded
where region_name = 'Africa';

select distinct intermediate_region_name
from m49_codes_expanded
where region_name = 'Africa';

-- Solution:
select distinct sub_region_name
from m49_codes_expanded mce
where region_name = 'Africa'
order by sub_region_name ;

select distinct intermediate_region_name, country_or_area
from m49_codes_expanded mce
where region_name = 'Africa'
order by intermediate_region_name, country_or_area;

-- finds all countries in Africa for which the sub_region name is NULL
select m49_code, country_or_area -- select m49_code bc sub_region is null
from m49_codes_expanded
where region_name = 'Africa' and intermediate_region_code isnull
order by country_or_area;

-- Solution:
select m49_code, country_or_area
from m49_codes_expanded
where region_name = 'Africa' and intermediate_region_code = ''
order by country_or_area;

-- Exercise: how to list only the countries that have empty string for intermediate_region_code or name
select m49_code, country_or_area
from m49_codes_expanded
where intermediate_region_code = '' or region_name = ''
order by country_or_area;

-- For each country in Africa, list: the country, the intermediate_region and the sub_region, including both names and m49 codes for the countries/regions
select distinct afa.area_code_m49, afa.area, i.intermediate_region_code, i.intermediate_region_name, s.sub_region_code, s.sub_region_name
from africa_fs_after_cleaning_db afa, m49_codes_expanded i, m49_codes_expanded s
where i.m49_code = afa.area_code_m49 and s.m49_code = afa.area_code_m49;

-- Q1: find the average GDP per capita for each african country (going over all years
select * 
from africa_fs_after_cleaning_db afacd 
where item like '%Gross%'; -- find the item_code for GDP

select area_code_m49, area, round(avg(value)::numeric, 2) as avg_gdp -- round to 2 digits
from africa_fs_after_cleaning_db afa
where item_code = '22013' -- item code for GDP
group by area_code_m49, area -- need this to be able to select both of them
order by area;

-- Q2: find the average GDP per capita for each african intermediate region
select i.intermediate_region_code, i.intermediate_region_name, round(avg(value):: numeric, 2) as avg_gdp
from m49_codes_expanded i, africa_fs_after_cleaning_db afa
where item_code = '22013' and i.m49_code = afa.area_code_m49
group by i.intermediate_region_code, i.intermediate_region_name 
order by i.intermediate_region_name;

-- Q3: find the average GDP per capita for each african sub region
select s.sub_region_code, s.sub_region_name, round(avg(value)::numeric, 2) as avg_gdp
from m49_codes_expanded s, africa_fs_after_cleaning_db afa
where item_code = '22013' and s.m49_code = afa.area_code_m49 
group by s.sub_region_code, s.sub_region_name
order by s.sub_region_name;

-- create a query that gives the avg gdp, the max gdp, and the min gdp over the years for each intermeidate region in Africa
select i.intermediate_region_code, i.intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from m49_codes_expanded i, africa_fs_after_cleaning_db afa
where item_code = '22013' and i.m49_code = afa.area_code_m49 
group by i.intermediate_region_code, i.intermediate_region_name
order by i.intermediate_region_name;

-- create a query that gives the avg, max and min gdp for each intermediate region in Africa, but just for 2011 to 2020
select i.intermediate_region_code, i.intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from m49_codes_expanded i, africa_fs_after_cleaning_db afa
where item_code = '22013' and i.m49_code = afa.area_code_m49 
and (
	case
		when length(afa.year_code) = 4 then cast(afa.year_code as int) between 2011 and 2020 
		when length(afa.year_code) = 8 then ((cast(substring(afa.year, 1, 4) as int) + cast(substring(afa.year, 6, 4) as int)) / 2) between 2011 and 2020
	end
	)
group by i.intermediate_region_code, i.intermediate_region_name
order by i.intermediate_region_name;


-- create a query that gives min and max gdp for each intermediate region in Africa (going across all years) but show only countries where the avg gdp is <= $4000
select i.intermediate_region_code, i.intermediate_region_name, round(avg(value)::numeric, 2) as avg_gdp, max(value) as max_gdp, min(value) as min_gdp
from m49_codes_expanded i, africa_fs_after_cleaning_db afa
where item_code = '22013' and i.m49_code = afa.area_code_m49
group by i.intermediate_region_code, i.intermediate_region_name
having avg(value) <= 4000
order by i.intermediate_region_name;
