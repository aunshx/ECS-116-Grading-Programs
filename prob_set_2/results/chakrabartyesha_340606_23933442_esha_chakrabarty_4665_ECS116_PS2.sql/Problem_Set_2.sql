set search_path to food_sec;

-- empty table
delete from m49_codes_expanded ;

-- sanity check ... is the table empty?
select count(*) from m49_codes_expanded;

--reate a query that gives the row of m49_codes_expanded
-- for the country "Angola"
select * from m49_codes_expanded mce
where country_or_area  = 'Angola';


-- let's see the values for itermediate_region
-- and sub_region that are associated with countries in Africa
select distinct sub_region_name  
from m49_codes_expanded mce 
where region_name = 'Africa';

select distinct intermediate_region_name  
from m49_codes_expanded mce 
where region_name = 'Africa';

-- Q1
select * from africa_fs_ac afa 
where item like('%Gross%');
-- item codes is 22013

select area, round(avg(value)::numeric,2) as avg_gdp
from africa_fs_ac afa 
where item_code = '22013'
group by area ;

-- Q2
select mce.intermediate_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code = '22013'
group by mce.intermediate_region_name;

-- create a query for Q3 mentioned above

select mce.sub_region_name, round(avg(value)::numeric, 0) as avg_gdp
from africa_fs_ac afa, m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code = '22013'
group by mce.sub_region_name  ;
-- create a query that gives the avg gdp, the max gdp, and the min gdp
-- over the years
-- for each intermeidate region in AFrica
select mce.intermediate_region_name, 
round(avg(value)::numeric, 0) as avg_gdp, 
round(max(value)::numeric, 0) as max_gdp, 
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code = '22013'
group by mce.intermediate_region_name ;

-- create a query that gives the avg, max and min gdp
-- for each intermediate region in Africa,
-- but just for 2011 to 2020

select mce.intermediate_region_name, 
round(avg(value)::numeric, 0) as avg_gdp, 
round(max(value)::numeric, 0) as max_gdp, 
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code = '22013'
and cast(substring(afa.year_code, 1, 4) as int) between 2011 and 2020
group by mce.intermediate_region_name ;

-- create a query that gives min and max gdp
-- for each intermediate region in Africa
-- (going across all years)
-- but show only countries where the avg gdp is <= $4000

select mce.intermediate_region_name,  
round(max(value)::numeric, 0) as max_gdp, 
round(min(value)::numeric, 0) as min_gdp
from africa_fs_ac afa , m49_codes_expanded mce 
where mce.m49_code = afa.area_code_m49 
and item_code = '22013'
group by mce.intermediate_region_name
having round(avg(value)::numeric, 0) <= 4000;
